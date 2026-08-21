-- lua/tracker_hud/sections/low_level/stack_model.lua
--
-- Stack record construction and labeling.
--
-- This module owns the data shape for Stack entries. It does not analyze source
-- code and does not render HUD lines directly.

local core = require("tracker_hud.core")
local lookup_model = require("tracker_hud.sections.templates.lookup_model")

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

    local entry = lookup_model.new(opts, "stack")

    if not entry then
        return nil
    end

    entry.resolved = opts.resolved
    entry.destination = opts.destination
    entry.destination_register = opts.destination_register
    entry.offset = opts.offset
    entry.size = opts.size

    entry.label = M.build_label(entry)

    return entry
end


function M.add(entries, seen, opts)
    local entry = M.new(opts)

    if not entry then
        return nil
    end

    return lookup_model.add(entries, seen, entry)
end

return M
