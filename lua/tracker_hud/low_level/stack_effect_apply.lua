-- lua/tracker_hud/low_level/stack_effect_apply.lua
--
-- Stack-effect matching, fact construction, and append semantics.
--
-- Syntax-derived mnemonic policy is injected by the caller. Stack state
-- preparation, depth tracking, and value carry remain owned by stack_infer.

local core = require("tracker_hud.core")
local effect_match =
    require("tracker_hud.low_level.effect_match")
local stack_effect_match =
    require("tracker_hud.low_level.stack_effect_match")
local stack_infer =
    require("tracker_hud.low_level.stack_infer")

local M = {}


function M.matches(
    adapter,
    instruction,
    effect_spec,
    opts
)
    opts = opts or {}

    if not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
        or type(opts.get_mnemonic)
            ~= "function"
        or type(opts.normalize_mnemonic)
            ~= "function"
    then
        return false
    end

    local expected_mnemonic =
        opts.get_mnemonic(
            effect_spec
        )

    if expected_mnemonic
        and opts.normalize_mnemonic(
            instruction.mnemonic
        ) ~= expected_mnemonic
    then
        return false
    end

    if not stack_effect_match
        .operands_match_effect(
            adapter,
            instruction,
            effect_spec
        )
    then
        return false
    end

    if not effect_match.condition_matches(
        instruction,
        effect_spec.condition
    )
    then
        return false
    end

    return true
end


function M.build(
    adapter,
    instruction,
    effect_spec,
    instruction_state
)
    return stack_infer.make_effect_fact(
        adapter,
        instruction,
        effect_spec,
        instruction_state
    )
end


function M.apply(
    facts,
    adapter,
    instruction,
    effect_spec,
    instruction_state,
    opts
)
    opts = opts or {}

    if not core.is_table(facts)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return
    end

    if not M.matches(
        adapter,
        instruction,
        effect_spec,
        opts
    )
    then
        return
    end

    local fact =
        M.build(
            adapter,
            instruction,
            effect_spec,
            instruction_state
        )

    if fact then
        table.insert(facts, fact)
    end
end


return M
