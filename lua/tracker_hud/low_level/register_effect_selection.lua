-- lua/tracker_hud/low_level/register_effect_selection.lua
--
-- Register-effect candidate selection.
--
-- This module owns generic operand/condition filtering once a register-effect
-- index exists. Parsing and mnemonic normalization remain injected so adapter
-- parser and syntax policy stay outside this selector.

local core = require("tracker_hud.core")
local effect_match =
    require("tracker_hud.low_level.effect_match")

local M = {}


local function node_bucket(
    index,
    instruction_node
)
    if not core.is_table(index)
        or not core.is_table(
            index.by_node_type
        )
        or not instruction_node
    then
        return nil
    end

    return index.by_node_type[
        instruction_node:type()
    ]
end


function M.match_instruction(
    index,
    instruction_node,
    instruction,
    opts
)
    opts = opts or {}

    if not core.is_table(instruction)
        or type(opts.normalize_mnemonic)
            ~= "function"
    then
        return {}
    end

    local bucket =
        node_bucket(
            index,
            instruction_node
        )

    if not bucket then
        return {}
    end

    local mnemonic =
        opts.normalize_mnemonic(
            instruction.mnemonic
        )

    local candidates =
        mnemonic
        and bucket[mnemonic]
        or nil

    local matching = {}

    for _, effect_spec in ipairs(
        candidates or {}
    ) do
        if effect_match.operands_match_effect(
            instruction,
            effect_spec
        )
            and effect_match.condition_matches(
                instruction,
                effect_spec.condition
            )
        then
            table.insert(
                matching,
                effect_spec
            )
        end
    end

    return matching
end


function M.match_node(
    index,
    instruction_node,
    opts
)
    opts = opts or {}

    if type(opts.parse_instruction)
            ~= "function"
        or type(opts.normalize_mnemonic)
            ~= "function"
    then
        return nil, {}
    end

    local bucket =
        node_bucket(
            index,
            instruction_node
        )

    if not bucket then
        return nil, {}
    end

    local instruction =
        opts.parse_instruction(
            instruction_node,
            bucket.__first
        )

    if not core.is_table(instruction) then
        return nil, {}
    end

    return instruction,
        M.match_instruction(
            index,
            instruction_node,
            instruction,
            opts
        )
end


return M
