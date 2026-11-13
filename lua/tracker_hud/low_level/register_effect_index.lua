-- lua/tracker_hud/low_level/register_effect_index.lua
--
-- Register-effect indexing and candidate selection.
--
-- Adapter syntax access, instruction parsing, operand matching and condition
-- matching are injected by context_engine. This module owns only the cached
-- node-type/mnemonic index and selection of matching rules from that index.

local core = require("tracker_hud.core")

local M = {}

local cache = setmetatable({}, {
    __mode = "k",
})


local function normalize_mnemonic(value)
    if not core.is_non_empty_string(value) then
        return nil
    end

    return value:lower()
end


local function add_to_index(
    index,
    effect_spec,
    fallback_mnemonic,
    opts
)
    if not core.is_table(index)
        or not core.is_table(effect_spec)
        or type(opts.get_node_type) ~= "function"
        or type(opts.get_mnemonic) ~= "function"
    then
        return
    end

    local node_type =
        opts.get_node_type(effect_spec)

    local mnemonic =
        opts.get_mnemonic(
            effect_spec,
            fallback_mnemonic
        )

    if not core.is_non_empty_string(node_type)
        or not core.is_non_empty_string(mnemonic)
    then
        return
    end

    mnemonic =
        normalize_mnemonic(mnemonic)

    if not mnemonic then
        return
    end

    index.node_types[node_type] = true
    index.by_node_type[node_type] =
        index.by_node_type[node_type]
        or {}

    local node_bucket =
        index.by_node_type[node_type]

    node_bucket[mnemonic] =
        node_bucket[mnemonic]
        or {}

    table.insert(
        node_bucket[mnemonic],
        effect_spec
    )

    node_bucket.__first =
        node_bucket.__first
        or effect_spec
end


function M.build(register_effects, opts)
    opts = opts or {}

    local index = {
        node_types = {},
        by_node_type = {},
    }

    if not core.is_table(register_effects)
        or type(opts.get_node_type) ~= "function"
        or type(opts.get_mnemonic) ~= "function"
    then
        return index
    end

    -- Current/legacy flat rule array.
    for _, effect_spec in ipairs(
        register_effects
    ) do
        add_to_index(
            index,
            effect_spec,
            nil,
            opts
        )
    end

    -- Tree-sitter-first mnemonic-indexed rule table.
    for mnemonic, rules in pairs(
        register_effects
    ) do
        if type(mnemonic) == "string"
            and core.is_table(rules)
        then
            for _, effect_spec in ipairs(
                rules
            ) do
                add_to_index(
                    index,
                    effect_spec,
                    mnemonic,
                    opts
                )
            end
        end
    end

    return index
end


function M.get(adapter, opts)
    opts = opts or {}

    if not core.is_table(adapter)
        or not core.is_table(
            adapter.register_effects
        )
    then
        return M.build(nil, opts)
    end

    local register_effects =
        adapter.register_effects

    local cached = cache[
        register_effects
    ]

    if cached then
        return cached
    end

    local index = M.build(
        register_effects,
        opts
    )

    cache[register_effects] = index

    return index
end


function M.match_node(
    index,
    instruction_node,
    opts
)
    opts = opts or {}

    if not core.is_table(index)
        or not instruction_node
        or type(opts.parse_instruction) ~= "function"
        or type(opts.operands_match) ~= "function"
        or type(opts.condition_match) ~= "function"
    then
        return nil, {}
    end

    local node_bucket =
        index.by_node_type
        and index.by_node_type[
            instruction_node:type()
        ]
        or nil

    if not node_bucket then
        return nil, {}
    end

    local instruction =
        opts.parse_instruction(
            instruction_node,
            node_bucket.__first
        )

    if not core.is_table(instruction) then
        return nil, {}
    end

    local mnemonic =
        normalize_mnemonic(
            instruction.mnemonic
        )

    local candidates =
        mnemonic
        and node_bucket[mnemonic]
        or nil

    local matching = {}

    for _, effect_spec in ipairs(
        candidates or {}
    ) do
        if opts.operands_match(
            instruction,
            effect_spec
        )
            and opts.condition_match(
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

    return instruction, matching
end


return M
