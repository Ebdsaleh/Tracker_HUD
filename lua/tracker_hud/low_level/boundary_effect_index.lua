-- lua/tracker_hud/low_level/boundary_effect_index.lua
--
-- Boundary-effect indexing.
--
-- Adapter syntax interpretation remains owned by context_engine and is
-- injected here. This module owns only the weak-key cache and the
-- node-type/mnemonic index for boundary-effect rules.

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

    mnemonic = normalize_mnemonic(
        mnemonic
    )

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


function M.build(
    boundary_effects,
    opts
)
    opts = opts or {}

    local index = {
        node_types = {},
        by_node_type = {},
    }

    if not core.is_table(boundary_effects)
        or type(opts.get_node_type) ~= "function"
        or type(opts.get_mnemonic) ~= "function"
    then
        return index
    end

    for _, effect_spec in ipairs(
        boundary_effects
    ) do
        add_to_index(
            index,
            effect_spec,
            nil,
            opts
        )
    end

    for mnemonic, effect_specs in pairs(
        boundary_effects
    ) do
        if type(mnemonic) == "string"
            and core.is_table(effect_specs)
        then
            for _, effect_spec in ipairs(
                effect_specs
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
            adapter.boundary_effects
        )
    then
        return M.build(nil, opts)
    end

    local boundary_effects =
        adapter.boundary_effects

    local cached = cache[
        boundary_effects
    ]

    if cached then
        return cached
    end

    local index = M.build(
        boundary_effects,
        opts
    )

    cache[boundary_effects] = index

    return index
end


return M
