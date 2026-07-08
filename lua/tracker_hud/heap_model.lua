-- lua/tracker_hud/heap_model.lua
--
-- Heap record construction and labeling.
--
-- This module owns the data shape for Heap entries. It does not analyze source
-- code and does not render HUD lines directly.

local core = require("tracker_hud.core")

local M = {}


local heap_entry_kind_labels = {
    memory_region = "memory region",
    heap_allocation = "heap allocation",
    heap_deallocation = "heap deallocation",
    heap_boundary = "heap boundary",
    unknown = "unknown",
}


function M.get_kind_label(kind)
    if not core.is_non_empty_string(kind) then
        return nil
    end

    return heap_entry_kind_labels[kind] or kind
end


local function get_produced_kind(boundary_effect)
    local known_effect = boundary_effect.known_effect or {}

    if core.is_table(known_effect.produces)
        and core.is_non_empty_string(known_effect.produces.kind)
    then
        return known_effect.produces.kind
    end

    return nil
end


local function get_consumed_kind(boundary_effect)
    local known_effect = boundary_effect.known_effect or {}

    if core.is_table(known_effect.consumes)
        and core.is_non_empty_string(known_effect.consumes.kind)
    then
        return known_effect.consumes.kind
    end

    return nil
end


function M.kind_from_boundary_effect(boundary_effect)
    if not core.is_table(boundary_effect) then
        return "unknown"
    end

    local produced_kind = get_produced_kind(boundary_effect)

    if produced_kind then
        return produced_kind
    end

    local consumed_kind = get_consumed_kind(boundary_effect)

    if consumed_kind then
        return consumed_kind
    end

    if boundary_effect.name == "munmap" then
        return "heap_deallocation"
    end

    if boundary_effect.name == "brk" then
        return "heap_boundary"
    end

    return "unknown"
end


function M.build_label(entry)
    if not core.is_table(entry) then
        return ""
    end

    local name = entry.name or "<unknown>"
    local kind_label = M.get_kind_label(entry.kind)
    local label = name

    if core.is_non_empty_string(kind_label) then
        label = "(" .. kind_label .. ") " .. label
    end

    if core.is_non_empty_string(entry.effect_key) then
        label = label .. " #" .. entry.effect_key
    end

    if core.is_non_empty_string(entry.result_register) then
        label = label .. " -> " .. entry.result_register
    end

    return label
end


function M.new(opts)
    opts = opts or {}

    local name = opts.name

    if not core.is_non_empty_string(name) then
        return nil
    end

    local entry = {
        id = opts.id or ("heap:" .. tostring(opts.source_line or 0) .. ":" .. name),
        name = name,
        kind = opts.kind or "unknown",
        category = opts.category or "heap",
        effect_key = opts.effect_key,
        result_register = opts.result_register,
        pointer_register = opts.pointer_register,
        size_register = opts.size_register,
        role = opts.role,
        source = opts.source,

        reads = opts.reads or {},
        writes = opts.writes or {},

        source_line = opts.source_line,
        source_column = opts.source_column or 0,
        source_start_line = opts.source_start_line or opts.source_line,
        source_start_column = opts.source_start_column or opts.source_column or 0,
        source_end_line = opts.source_end_line or opts.source_line,
        source_end_column = opts.source_end_column or opts.source_column or 0,

        metadata = opts.metadata or {},
    }

    entry.label = M.build_label(entry)

    return entry
end


function M.add(entries, seen, opts)
    if not core.is_table(entries) then
        return nil
    end

    opts = opts or {}

    local entry = M.new(opts)

    if not entry then
        return nil
    end

    seen = seen or {}

    if seen[entry.id] then
        return nil
    end

    seen[entry.id] = true

    table.insert(entries, entry)

    return entry
end


return M
