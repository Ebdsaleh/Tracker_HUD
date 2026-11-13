-- lua/tracker_hud/low_level/instruction_event_index.lua
--
-- Instruction-event indexing and mnemonic matching.
--
-- Adapter syntax access remains owned by context_engine and is injected here.
-- This module owns only the weak-key cache, node-type/mnemonic buckets and
-- mnemonic equality check used by instruction-event collection.

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
    event_spec,
    fallback_mnemonic,
    opts
)
    if not core.is_table(index)
        or not core.is_table(event_spec)
        or type(opts.get_node_type) ~= "function"
        or type(opts.get_mnemonic) ~= "function"
    then
        return
    end

    local node_type =
        opts.get_node_type(event_spec)

    local mnemonic =
        opts.get_mnemonic(
            event_spec,
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
        event_spec
    )

    node_bucket.__first =
        node_bucket.__first
        or event_spec
end


function M.build(
    instruction_events,
    opts
)
    opts = opts or {}

    local index = {
        node_types = {},
        by_node_type = {},
    }

    if not core.is_table(
        instruction_events
    )
        or type(opts.get_node_type)
            ~= "function"
        or type(opts.get_mnemonic)
            ~= "function"
    then
        return index
    end

    -- Remaining legacy flat event specs.
    for _, event_spec in ipairs(
        instruction_events
    ) do
        add_to_index(
            index,
            event_spec,
            nil,
            opts
        )
    end

    -- Tree-sitter-first mnemonic-indexed event specs.
    for mnemonic, rules in pairs(
        instruction_events
    ) do
        if type(mnemonic) == "string"
            and core.is_table(rules)
        then
            for _, event_spec in ipairs(
                rules
            ) do
                add_to_index(
                    index,
                    event_spec,
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
            adapter.instruction_events
        )
    then
        return M.build(nil, opts)
    end

    local instruction_events =
        adapter.instruction_events

    local cached = cache[
        instruction_events
    ]

    if cached then
        return cached
    end

    local index = M.build(
        instruction_events,
        opts
    )

    cache[instruction_events] = index

    return index
end


function M.matches(
    instruction,
    event_spec,
    opts
)
    opts = opts or {}

    if not core.is_table(instruction)
        or not core.is_table(event_spec)
        or type(opts.get_mnemonic)
            ~= "function"
    then
        return false
    end

    local expected_mnemonic =
        opts.get_mnemonic(event_spec)

    if not expected_mnemonic then
        return true
    end

    return normalize_mnemonic(
        instruction.mnemonic
    ) == normalize_mnemonic(
        expected_mnemonic
    )
end


return M
