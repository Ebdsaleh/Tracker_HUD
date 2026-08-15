-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd.lua

-- x86-64 legacy SIMD register-effect aggregator.
--
-- Most SIMD effects have migrated into categorized Tree-sitter-first vector,
-- mask, crypto, x87, and AMX modules. Only the final legacy leftovers remain
-- here until their proper non-vector destinations are completed.

local M = {}


local function extend(result, entries)
    for _, entry in ipairs(entries or {}) do
        table.insert(result, entry)
    end
end


extend(M, require("tracker_hud.adapters.asm.arch.x86_64.register_effects.simd.misc"))
extend(M, require("tracker_hud.adapters.asm.arch.x86_64.register_effects.simd.crypto"))
extend(M, require("tracker_hud.adapters.asm.arch.x86_64.register_effects.simd.vector_move"))


return M
