-- lua/tracker_hud/register_model.lua
--
-- Register record construction and labeling.
--
-- This module owns the data shape for Registers. It does not analyze source
-- code and does not render HUD lines directly.

local core = require("tracker_hud.core")

local M = {}


local register_kind_labels = {
    general = "general",
    pointer = "pointer",
    stack_pointer = "stack pointer",
    base_pointer = "base pointer",
    instruction_pointer = "instruction pointer",
    flags = "flags",
    floating_point = "floating point",
    vector = "vector",
    unknown = "unknown",
}


function M.get_kind_label(kind)
    if not core.is_non_empty_string(kind) then
        return nil
    end

    return register_kind_labels[kind] or kind
end


function M.build_label(register)
    if not core.is_table(register) then
        return ""
    end

    local name = register.name or "<unknown>"
    local value = register.value
    local kind_label = M.get_kind_label(register.kind)

    local label = name

    if core.is_non_empty_string(kind_label) then
        label = "(" .. kind_label .. ") " .. label
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

    local register = {
        id = opts.id or ("register:" .. name),
        name = name,
        kind = opts.kind or "unknown",
        value = opts.value,
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

    register.label = M.build_label(register)

    return register
end


function M.add(registers, seen, opts)
    if not core.is_table(registers) then
        return nil
    end

    opts = opts or {}

    local register = M.new(opts)

    if not register then
        return nil
    end

    seen = seen or {}

    if seen[register.id] then
        return nil
    end

    seen[register.id] = true

    table.insert(registers, register)

    return register
end


return M
