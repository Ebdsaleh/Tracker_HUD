-- lua/tracker_hud/warnings.lua
--
-- Warning collection for Tracker HUD.
--
-- Warnings are derived from already-collected context facts.
-- This module should not parse source directly and should not hard-code
-- architecture-specific parsing behavior.

local core = require("tracker_hud.core")

local M = {}


local function make_warning(message, opts)
    opts = opts or {}

    return {
        message = message,
        kind = opts.kind or "warning",
        category = opts.category or "state",
        source = opts.source or "analysis",

        source_line = opts.source_line,
        source_column = opts.source_column,

        source_start_line = opts.source_start_line,
        source_start_column = opts.source_start_column,
        source_end_line = opts.source_end_line,
        source_end_column = opts.source_end_column,

        metadata = opts.metadata or {},
    }
end


local function find_boundary_read(reads, role)
    if not core.is_table(reads) then
        return nil
    end

    for _, read in ipairs(reads) do
        if core.is_table(read) and read.role == role then
            return read
        end
    end

    return nil
end


local function append_unknown_syscall_number_warning(warnings, boundary_effect)
    if not core.is_table(boundary_effect) then
        return
    end

    if boundary_effect.kind ~= "syscall" then
        return
    end

    local number_read = find_boundary_read(boundary_effect.reads, "number")

    if not core.is_table(number_read) then
        return
    end

    if number_read.value == nil then
        table.insert(warnings, make_warning(
            "syscall number register "
                .. tostring(number_read.register or "<unknown>")
                .. " has no known value",
            {
                category = "boundary",
                source_line = boundary_effect.source_line,
                source_column = boundary_effect.source_column,
                source_start_line = boundary_effect.source_start_line,
                source_start_column = boundary_effect.source_start_column,
                source_end_line = boundary_effect.source_end_line,
                source_end_column = boundary_effect.source_end_column,
                metadata = {
                    boundary_kind = boundary_effect.kind,
                    register = number_read.register,
                },
            }
        ))

        return
    end

    if not core.is_table(boundary_effect.known_effect) then
        table.insert(warnings, make_warning(
            "unknown syscall number #" .. tostring(number_read.value),
            {
                category = "boundary",
                source_line = boundary_effect.source_line,
                source_column = boundary_effect.source_column,
                source_start_line = boundary_effect.source_start_line,
                source_start_column = boundary_effect.source_start_column,
                source_end_line = boundary_effect.source_end_line,
                source_end_column = boundary_effect.source_end_column,
                metadata = {
                    boundary_kind = boundary_effect.kind,
                    syscall_number = number_read.value,
                },
            }
        ))
    end
end


local function append_heap_argument_warnings(warnings, boundary_effect)
    if not core.is_table(boundary_effect) then
        return
    end

    if boundary_effect.category ~= "heap" then
        return
    end

    if not core.is_table(boundary_effect.known_effect) then
        return
    end

    for _, read in ipairs(boundary_effect.reads or {}) do
        if core.is_table(read)
            and read.role == "argument"
            and read.value == nil
        then
            table.insert(warnings, make_warning(
                tostring(boundary_effect.name or "heap syscall")
                    .. " argument "
                    .. tostring(read.index or "?")
                    .. " register "
                    .. tostring(read.register or "<unknown>")
                    .. " has no known value",
                {
                    category = "heap",
                    source_line = boundary_effect.source_line,
                    source_column = boundary_effect.source_column,
                    source_start_line = boundary_effect.source_start_line,
                    source_start_column = boundary_effect.source_start_column,
                    source_end_line = boundary_effect.source_end_line,
                    source_end_column = boundary_effect.source_end_column,
                    metadata = {
                        boundary_kind = boundary_effect.kind,
                        boundary_name = boundary_effect.name,
                        argument_index = read.index,
                        register = read.register,
                    },
                }
            ))
        end
    end
end


function M.collect(context, adapter, _opts)
    local warnings = {}

    if not core.is_table(context) or not core.is_table(adapter) then
        return warnings
    end

    for _, boundary_effect in ipairs(context.boundary_effects or {}) do
        append_unknown_syscall_number_warning(warnings, boundary_effect)
        append_heap_argument_warnings(warnings, boundary_effect)
    end

    return warnings
end


return M
