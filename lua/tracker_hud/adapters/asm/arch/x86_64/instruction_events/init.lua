-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/init.lua

local M = {}

local function append_events(events)
    for _, event in ipairs(events or {}) do
        table.insert(M, event)
    end
end

append_events(require("tracker_hud.adapters.asm.arch.x86_64.instruction_events.processor"))
append_events(require("tracker_hud.adapters.asm.arch.x86_64.instruction_events.cache"))
append_events(require("tracker_hud.adapters.asm.arch.x86_64.instruction_events.virtualization"))
append_events(require("tracker_hud.adapters.asm.arch.x86_64.instruction_events.security"))


return M
