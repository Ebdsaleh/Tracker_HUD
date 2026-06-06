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
        if core.is_table(register_spec) then
            register_model.add(registers, seen, {
                name = register_spec.name,
                kind = register_spec.kind,
                value = register_spec.value,
                role = register_spec.role,
                source = register_spec.source or "analysis",

                source_line = register_spec.source_line,
                source_column = register_spec.source_column,
                source_start_line = register_spec.source_start_line,
                source_start_column = register_spec.source_start_column,
                source_end_line = register_spec.source_end_line,
                source_end_column = register_spec.source_end_column,

                metadata = register_spec.metadata or {},
            })
        end
    end
end


local function collect_adapter_static_registers(registers, seen, context, adapter)
    if not core.is_table(adapter) or not core.is_table(adapter.registers) then
        return
    end

    local static_registers = adapter.registers.static or {}

    for _, register_spec in ipairs(static_registers) do
        if core.is_table(register_spec) then
            register_model.add(registers, seen, {
                name = register_spec.name,
                kind = register_spec.kind,
                value = register_spec.value,
                role = register_spec.role,
                source = register_spec.source or "adapter",
                metadata = {
                    adapter = adapter.name,
                    context = context,
                },
            })
        end
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
