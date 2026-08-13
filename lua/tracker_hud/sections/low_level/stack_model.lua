-- lua/tracker_hud/sections/low_level/stack_model.lua
--
-- Stack record construction and labeling.
--
-- This module owns the data shape for Stack entries. It does not analyze source
-- code and does not render HUD lines directly.

local core = require("tracker_hud.core")

local M = {}


local stack_entry_kind_labels = {
    frame = "frame",
    slot = "slot",
    local_ = "local",
    parameter = "parameter",
    return_address = "return address",
    saved_register = "saved register",
    stack_pointer = "stack pointer",
    base_pointer = "base pointer",
    unknown = "unknown",
}


function M.get_kind_label(kind)
    if not core.is_non_empty_string(kind) then
        return nil
    end

    return stack_entry_kind_labels[kind] or kind
end


function M.build_label(entry)
    if not core.is_table(entry) then
        return ""
    end

    local name = entry.name or "<unknown>"
    local value = entry.value
    local offset = entry.offset
    local kind_label = M.get_kind_label(entry.kind)

    local label = name

    if core.is_non_empty_string(kind_label) then
        label = "(" .. kind_label .. ") " .. label
    end

    if offset ~= nil then
        label = label .. " @ " .. tostring(offset)
    end

    if value ~= nil then
        label = label .. " = " .. tostring(value)
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
        id = opts.id or ("stack:" .. name),
        name = name,
        kind = opts.kind or "unknown",
        value = opts.value,
        offset = opts.offset,
        size = opts.size,
        role = opts.role,
        source = opts.source,

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
