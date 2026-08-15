-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/misc.lua
--
-- x86-64 legacy miscellaneous register effects.
--
-- Temporary compatibility while the final non-vector leftovers are migrated.

return {
    {
                                    node_type = "instruction",
                                    mnemonic = "sysretl",
                                    operands = {},
                                    effect = {
                                        kind = "register_write",
                                        name = "sysretl_updates_rip",
                                        target_register = "rip",
                                        role = "returned from system call in compatibility form by sysretl",
                                    },
                                },

    {
                                    node_type = "instruction",
                                    mnemonic = "sysretl",
                                    operands = {},
                                    effect = {
                                        kind = "register_write",
                                        name = "sysretl_clobbers_rcx",
                                        target_register = "rcx",
                                        role = "clobbered by system call return sysretl",
                                    },
                                },

    {
                                    node_type = "instruction",
                                    mnemonic = "sysretl",
                                    operands = {},
                                    effect = {
                                        kind = "register_write",
                                        name = "sysretl_clobbers_r11",
                                        target_register = "r11",
                                        role = "clobbered by system call return sysretl",
                                    },
                                },

    {
                                    node_type = "instruction",
                                    mnemonic = "sysexitl",
                                    operands = {},
                                    effect = {
                                        kind = "register_write",
                                        name = "sysexitl_updates_rip",
                                        target_register = "rip",
                                        role = "returned from fast system call in compatibility form by sysexitl",
                                    },
                                },

}
