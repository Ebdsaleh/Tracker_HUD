-- lua/tracker_hud/registers.lua
--
-- Register discovery / collection.
--
-- Registers v1 establishes the analyzer boundary for future register tracking.
-- It currently returns no register facts unless a future adapter/analyzer
-- provides them.

local core = require("tracker_hud.core")
local register_model = require("tracker_hud.register_model")

local M = {}


local function collect_adapter_registers(registers, seen, context, adapter)
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
                source = "adapter",
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

    collect_adapter_registers(registers, seen, context, adapter)

    table.sort(registers, function(left, right)
        return tostring(left.name or "") < tostring(right.name or "")
    end)

    return registers
end


return M
