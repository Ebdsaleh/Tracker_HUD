-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/system.lua
--
-- x86-64 legacy system register effects.
--
-- Temporary compatibility while the final non-vector leftovers are migrated.

return {
    {
                                node_type = "instruction",
                                mnemonic = "iretw",
                                operands = {},
                                effect = {
                                    kind = "register_write",
                                    name = "iretw_updates_rip",
                                    target_register = "rip",
                                    role = "returned from interrupt by iretw",
                                },
                            },

    {
                                node_type = "instruction",
                                mnemonic = "iretd",
                                operands = {},
                                effect = {
                                    kind = "register_write",
                                    name = "iretd_updates_rip",
                                    target_register = "rip",
                                    role = "returned from interrupt by iretd",
                                },
                            },

    {
                                node_type = "instruction",
                                mnemonic = "iretw",
                                operands = {},
                                effect = {
                                    kind = "register_write",
                                    name = "iretw_updates_rip",
                                    target_register = "rip",
                                    role = "returned from word interrupt by iretw",
                                },
                            },

    {
                                node_type = "instruction",
                                mnemonic = "iretd",
                                operands = {},
                                effect = {
                                    kind = "register_write",
                                    name = "iretd_updates_rip",
                                    target_register = "rip",
                                    role = "returned from doubleword interrupt by iretd",
                                },
                            },

    {
                                node_type = "instruction",
                                mnemonic = "iretq",
                                operands = {},
                                effect = {
                                    kind = "register_write",
                                    name = "iretq_updates_rip",
                                    target_register = "rip",
                                    role = "returned from quadword interrupt by iretq",
                                },
                            },

    {
                                node_type = "instruction",
                                mnemonic = "syscall",

                                operands = {},

                                effect = {
                                    kind = "register_write",
                                    name = "syscall_clobber_rcx",
                                    target_register = "rcx",
                                    role = "clobbered by Linux syscall",
                                    platform = "linux",
                                    abi = "linux_syscall",
                                },
                            },

    {
                                node_type = "instruction",
                                mnemonic = "syscall",

                                operands = {},

                                effect = {
                                    kind = "register_write",
                                    name = "syscall_clobber_r11",
                                    target_register = "r11",
                                    role = "clobbered by Linux syscall",
                                    platform = "linux",
                                    abi = "linux_syscall",
                                },
                            },

    {
                                node_type = "instruction",
                                mnemonic = "syscall",

                                operands = {},

                                effect = {
                                    kind = "register_write",
                                    name = "syscall_return_rax",
                                    target_register = "rax",
                                    role = "receives Linux syscall return value",
                                    platform = "linux",
                                    abi = "linux_syscall",
                                },
                            },

}
