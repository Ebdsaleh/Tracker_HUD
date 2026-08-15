-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/init.lua
--
-- x86-64 register-effect module aggregator.
--
-- The categorized modules are the destination for the Tree-sitter-first
-- migration. Legacy modules remain loaded during migration so behavior is
-- unchanged while entries are moved in small, testable batches.

local M = {}


local function append_rules(rules)
    for _, rule in ipairs(rules or {}) do
        table.insert(M, rule)
    end
end


local categorized_modules = {
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.integer.arithmetic",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.integer.multiply_divide",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.integer.compare_test",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.integer.bitwise",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.integer.shifts_rotates",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.integer.bit_manipulation",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.integer.data_movement",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.integer.conditional",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.integer.atomic",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.string.movement",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.string.compare_scan",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.string.io",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.string.repeat_prefix",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.control.branches",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.control.calls_returns",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.control.loops",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.stack.push_pop",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.stack.frames",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.flags.direct",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.processor.io",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.processor.descriptor_segment",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.processor.control_state",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.processor.timing_random",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.processor.transactional",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.processor.virtualization",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.vector.movement",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.vector.integer_arithmetic",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.vector.floating_arithmetic",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.vector.logical",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.vector.compare",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.vector.convert",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.vector.shuffle_permute",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.vector.broadcast_insert_extract",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.mask.movement",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.mask.arithmetic",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.mask.logical",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.mask.compare",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.x87.data_movement",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.x87.arithmetic",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.x87.compare",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.x87.control_state",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.amx.configuration",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.amx.movement",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.amx.compute",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.crypto.aes",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.crypto.sha",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.crypto.carryless_gfni",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.crypto.key_locker",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.legacy.bcd_ascii",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.legacy.segment",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.legacy.compatibility",
}


for _, module_name in ipairs(categorized_modules) do
    append_rules(require(module_name))
end


-- Temporary migration compatibility.
-- Remove a legacy module from this list only after every entry in that module
-- has been moved into the categorized Tree-sitter-first files.
local legacy_modules = {
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.data_movement",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.arithmetic",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.bitwise",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.control_flow",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.stack_frame",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.system_flags",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.system",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.simd",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.crypto",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.misc",
}


for _, module_name in ipairs(legacy_modules) do
    append_rules(require(module_name))
end


return M
