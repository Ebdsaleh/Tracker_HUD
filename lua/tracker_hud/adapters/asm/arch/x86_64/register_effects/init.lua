-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/init.lua
--
-- x86-64 register-effect module aggregator.
--
-- Every register-effect rule is categorized, Tree-sitter-first, and
-- mnemonic-indexed. No legacy flat register-effect module is consumed.

local M = {}


local function merge_indexed_rules(rules)
    if type(rules) ~= "table" then
        return
    end

    for mnemonic, effect_specs in pairs(rules) do
        if type(mnemonic) == "string"
            and type(effect_specs) == "table"
        then
            M[mnemonic] = M[mnemonic] or {}

            for _, effect_spec in ipairs(effect_specs) do
                table.insert(M[mnemonic], effect_spec)
            end
        end
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
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.control.system_calls",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.control.interrupts",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.stack.push_pop",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.stack.frames",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.flags.direct",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.processor.io",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.processor.identification",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.processor.descriptor_segment",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.processor.control_state",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.processor.protection_state",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.processor.timing_random",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.processor.profiling",
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
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.mask.shifts",
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
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.crypto.sm3_sm4",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.legacy.bcd_ascii",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.legacy.segment",
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.legacy.compatibility",
}


for _, module_name in ipairs(categorized_modules) do
    merge_indexed_rules(require(module_name))
end


return M
