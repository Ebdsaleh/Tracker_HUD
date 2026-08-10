-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/init.lua

local M = {}

local function append_rules(rules)
    for _, rule in ipairs(rules or {}) do
        table.insert(M, rule)
    end
end

append_rules(require("tracker_hud.adapters.asm.arch.x86_64.register_effects.data_movement"))
append_rules(require("tracker_hud.adapters.asm.arch.x86_64.register_effects.arithmetic"))
append_rules(require("tracker_hud.adapters.asm.arch.x86_64.register_effects.bitwise"))
append_rules(require("tracker_hud.adapters.asm.arch.x86_64.register_effects.control_flow"))
append_rules(require("tracker_hud.adapters.asm.arch.x86_64.register_effects.stack_frame"))
append_rules(require("tracker_hud.adapters.asm.arch.x86_64.register_effects.system_flags"))
append_rules(require("tracker_hud.adapters.asm.arch.x86_64.register_effects.system"))
append_rules(require("tracker_hud.adapters.asm.arch.x86_64.register_effects.simd"))
append_rules(require("tracker_hud.adapters.asm.arch.x86_64.register_effects.crypto"))
append_rules(require("tracker_hud.adapters.asm.arch.x86_64.register_effects.misc"))

return M
