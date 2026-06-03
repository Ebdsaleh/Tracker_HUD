-- lua/tracker_hud/registers.lua
--
-- Register discovery / collection.
--
-- Registers v1 establishes the analyzer boundary for future register tracking.
-- Static registers can come from adapters/architectures.
-- Instruction-derived register facts can also be provided by adapters.

local core = require("tracker_hud.core")
local register_model = require("tracker_hud.register_model")

local M = {}


local function collect_adapter_dynamic_registers(registers, seen, context, adapter, opts)
    if not core.is_table(adapter) then
        return
    end

    if type(adapter.collect_registers) ~= "function" then
        return
    end

    local ok, dynamic_registers = pcall(adapter.collect_registers, context, opts)

    if not ok or not core.is_table(dynamic_registers) then
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
    collect_adapter_dynamic_registers(registers, seen, context, adapter, opts)
    collect_adapter_static_registers(registers, seen, context, adapter)

    table.sort(registers, function(left, right)
        return tostring(left.name or "") < tostring(right.name or "")
    end)

    return registers
end


return M
