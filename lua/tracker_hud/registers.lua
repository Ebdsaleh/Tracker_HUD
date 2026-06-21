-- lua/tracker_hud/registers.lua
--
-- Register discovery / collection.
--
-- Static registers come from adapters / variant specs.
-- Dynamic register facts come from declarative register effects interpreted by
-- the context engine.

local core = require("tracker_hud.core")
local context_engine = require("tracker_hud.context_engine")
local register_model = require("tracker_hud.register_model")

local M = {}


local function merge_metadata(base, extra)
    local metadata = {}

    for key, value in pairs(base or {}) do
        metadata[key] = value
    end

    for key, value in pairs(extra or {}) do
        metadata[key] = value
    end

    return metadata
end


local function normalize_register_spec(register_spec, context, adapter, source)
    if not core.is_table(register_spec) then
        return nil
    end

    local raw_name = register_spec.name

    if not core.is_non_empty_string(raw_name) then
        return nil
    end

    local normalized_name = raw_name:lower()
    local resolved = register_model.resolve_alias(adapter, normalized_name)
    local name = normalized_name
    local family = nil
    local alias = nil
    local alias_name = nil

    if resolved then
        name = resolved.canonical
        family = resolved.family
        alias = resolved.alias
        alias_name = resolved.alias_name
    else
        family = register_model.family_for_register(adapter, normalized_name)
    end

    local metadata = merge_metadata(register_spec.metadata, {
        adapter = adapter and adapter.name,
        context = context,
        family = family,
        family_name = family and family.canonical or register_spec.family,
        alias_spec = alias,
        alias_written = alias_name,
        raw_name = normalized_name,
    })

    return {
        id = "register:" .. name,
        name = name,
        kind = register_spec.kind or (family and family.kind) or "unknown",
        value = register_spec.value,
        role = register_spec.role or (family and family.role),
        source = register_spec.source or source,

        source_line = register_spec.source_line,
        source_column = register_spec.source_column,
        source_start_line = register_spec.source_start_line,
        source_start_column = register_spec.source_start_column,
        source_end_line = register_spec.source_end_line,
        source_end_column = register_spec.source_end_column,

        metadata = metadata,
    }
end


local function add_normalized_register(registers, seen, register_spec, context, adapter, source)
    local normalized = normalize_register_spec(register_spec, context, adapter, source)

    if not normalized then
        return nil
    end

    return register_model.add(registers, seen, normalized)
end


local function collect_engine_register_effects(registers, seen, context, adapter, opts)
    if not core.is_table(adapter) then
        return
    end

    local dynamic_registers = context_engine.collect_register_effects(
        context,
        adapter,
        opts
    )

    if not core.is_table(dynamic_registers) then
        return
    end

    for _, register_spec in ipairs(dynamic_registers) do
        add_normalized_register(
            registers,
            seen,
            register_spec,
            context,
            adapter,
            "analysis"
        )
    end
end


local function collect_adapter_static_registers(registers, seen, context, adapter)
    if not core.is_table(adapter) or not core.is_table(adapter.registers) then
        return
    end

    local static_registers = adapter.registers.static or {}

    for _, register_spec in ipairs(static_registers) do
        add_normalized_register(
            registers,
            seen,
            register_spec,
            context,
            adapter,
            "adapter"
        )
    end
end


function M.collect(context, adapter, opts)
    local registers = {}
    local seen = {}

    opts = opts or {}

    if opts.enabled == false then
        return registers
    end

    -- Dynamic facts go first so they override same-id static architecture rows.
    collect_engine_register_effects(registers, seen, context, adapter, opts)
    collect_adapter_static_registers(registers, seen, context, adapter)

    table.sort(registers, function(left, right)
        return tostring(left.name or "") < tostring(right.name or "")
    end)

    return registers
end


return M
