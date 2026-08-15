-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/misc.lua
--
-- x86-64 legacy miscellaneous SIMD register effects.
--
-- Temporary compatibility while the final non-vector leftovers are migrated.

return {
    {
                            node_type = "instruction",
                            mnemonic = "verr",
                            operands = {
                                { index = 1, role = "selector" },
                            },
                            effect = {
                                kind = "register_write",
                                name = "verr_updates_rflags",
                                target_register = "rflags",
                                role = "updated by readable-segment test verr",
                            },
                        },

    {
                            node_type = "instruction",
                            mnemonic = "verw",
                            operands = {
                                { index = 1, role = "selector" },
                            },
                            effect = {
                                kind = "register_write",
                                name = "verw_updates_rflags",
                                target_register = "rflags",
                                role = "updated by writable-segment test verw",
                            },
                        },

    {
                            node_type = "instruction",
                            mnemonic = "prefetch",
                            operands = {
                                { index = 1, role = "memory_operand" },
                            },
                            effect = {
                                kind = "register_write",
                                name = "prefetch_touches_memory",
                                target_register = "rip",
                                role = "prefetched memory by prefetch",
                            },
                        },

    {
                            node_type = "instruction",
                            mnemonic = "prefetchw",
                            operands = {
                                { index = 1, role = "memory_operand" },
                            },
                            effect = {
                                kind = "register_write",
                                name = "prefetchw_touches_memory",
                                target_register = "rip",
                                role = "prefetched memory for write by prefetchw",
                            },
                        },

}
