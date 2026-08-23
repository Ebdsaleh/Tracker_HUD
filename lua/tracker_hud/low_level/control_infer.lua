-- lua/tracker_hud/low_level/control_infer.lua
--
-- Generic low-level control-flow inference helpers.
--
-- This module consumes adapter-declared instruction-event specs and annotates
-- those events with lightweight read/write facts. It is deliberately
-- architecture-neutral: adapters name the registers, roles, conditions, and
-- targets; this module only resolves those declarations against already-known
-- section facts.

local core = require("tracker_hud.core")
local register_infer = require("tracker_hud.low_level.register_infer")

local M = {}


local function copy_scalar_fields(source, target)
    if not core.is_table(source) or not core.is_table(target) then
        return target
    end

    for key, value in pairs(source) do
        if type(value) ~= "table" then
            target[key] = value
        end
    end

    return target
end


local function first_non_empty(...)
    for index = 1, select("#", ...) do
        local value = select(index, ...)

        if core.is_non_empty_string(value) then
            return value
        end
    end

    return nil
end


local function get_register_read_value(context, read_spec)
    local register = first_non_empty(
        read_spec.register,
        read_spec.name,
        read_spec.location
    )

    if not register then
        return nil, false, nil
    end

    local fact = register_infer.get_fact_from_context(
        context,
        register
    )

    if not core.is_table(fact) then
        return nil, false, nil
    end

    if read_spec.present_means_resolved == true then
        return first_non_empty(
            fact.value,
            fact.role,
            fact.name,
            register
        ), true, fact
    end

    if register_infer.fact_is_resolved(fact) then
        return fact.value, true, fact
    end

    return fact.value, false, fact
end


local function make_read_fact(context, read_spec)
    if not core.is_table(read_spec) then
        return nil
    end

    local location = read_spec.location or "register"
    local register = first_non_empty(
        read_spec.register,
        read_spec.name,
        read_spec.location
    )

    local value = read_spec.value
    local resolved = value ~= nil
    local source_fact = nil

    if location == "register" and register then
        value, resolved, source_fact = get_register_read_value(
            context,
            read_spec
        )
    end

    local result = copy_scalar_fields(read_spec, {
        role = read_spec.role or "input",
        location = location,
        register = register,
        value = value,
        resolved = resolved ~= false,
        required = read_spec.required == true,
    })

    if core.is_table(source_fact) then
        result.source_role = source_fact.role
        result.source_value = source_fact.value
        result.source_resolved = source_fact.resolved ~= false
        result.source_line = source_fact.source_line
        result.source_column = source_fact.source_column
    end

    return result
end


local function make_write_fact(write_spec)
    if not core.is_table(write_spec) then
        return nil
    end

    local register = first_non_empty(
        write_spec.register,
        write_spec.name,
        write_spec.location
    )

    return copy_scalar_fields(write_spec, {
        role = write_spec.role or "output",
        location = write_spec.location or "register",
        register = register,
        value = write_spec.value,
        resolved = write_spec.resolved ~= false,
    })
end


function M.collect_reads(context, event_spec)
    local reads = {}

    if not core.is_table(event_spec) then
        return reads
    end

    for _, read_spec in ipairs(event_spec.reads_before or event_spec.reads or {}) do
        local read = make_read_fact(context, read_spec)

        if read then
            table.insert(reads, read)
        end
    end

    return reads
end


function M.collect_writes(event_spec)
    local writes = {}

    if not core.is_table(event_spec) then
        return writes
    end

    for _, write_spec in ipairs(event_spec.writes_after or event_spec.writes or {}) do
        local write = make_write_fact(write_spec)

        if write then
            table.insert(writes, write)
        end
    end

    return writes
end


function M.make_event_metadata(context, event_spec)
    if not core.is_table(event_spec) then
        return {}
    end

    return {
        reads = M.collect_reads(context, event_spec),
        writes = M.collect_writes(event_spec),
        condition = event_spec.condition,
        condition_description = event_spec.condition_description,
        control_flow = event_spec.control_flow,
    }
end


return M

