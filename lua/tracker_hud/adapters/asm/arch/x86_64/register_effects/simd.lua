-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd.lua

-- x86-64 SIMD register effect specs.
--
-- Split into smaller modules so fake RIP visibility effects can be cleaned
-- up one category at a time without editing one giant file.

local M = {}

local function extend(result, entries)
    for _, entry in ipairs(entries or {}) do
        table.insert(result, entry)
    end
end

extend(M, require("tracker_hud.adapters.asm.arch.x86_64.register_effects.simd.misc"))
extend(M, require("tracker_hud.adapters.asm.arch.x86_64.register_effects.simd.packed_fp"))
extend(M, require("tracker_hud.adapters.asm.arch.x86_64.register_effects.simd.vector_logic"))
extend(M, require("tracker_hud.adapters.asm.arch.x86_64.register_effects.simd.vector_compare"))
extend(M, require("tracker_hud.adapters.asm.arch.x86_64.register_effects.simd.vector_shuffle"))
extend(M, require("tracker_hud.adapters.asm.arch.x86_64.register_effects.simd.vector_convert"))
extend(M, require("tracker_hud.adapters.asm.arch.x86_64.register_effects.simd.scalar_fp"))
extend(M, require("tracker_hud.adapters.asm.arch.x86_64.register_effects.simd.amx"))
extend(M, require("tracker_hud.adapters.asm.arch.x86_64.register_effects.simd.crypto"))
extend(M, require("tracker_hud.adapters.asm.arch.x86_64.register_effects.simd.vector_move"))

return M
