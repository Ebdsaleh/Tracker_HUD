-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/control/system_calls.lua
--
-- x86-64 register effects: control / system calls.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies instruction syntax first. x86-64 / Tracker_HUD
-- register semantics are layered onto that syntax.

return {

    ["sysretl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sysretl",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "sysretl_updates_rip",
                target_register = "rip",
                role = "returned from system call in compatibility form by sysretl",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sysretl",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "sysretl_clobbers_rcx",
                target_register = "rcx",
                role = "clobbered by system call return sysretl",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sysretl",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "sysretl_clobbers_r11",
                target_register = "r11",
                role = "clobbered by system call return sysretl",
            },
        },
    },

    ["sysexitl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sysexitl",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "sysexitl_updates_rip",
                target_register = "rip",
                role = "returned from fast system call in compatibility form by sysexitl",
            },
        },
    },

    ["syscall"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "syscall",
                    },
                },
            },

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
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "syscall",
                    },
                },
            },

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
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "syscall",
                    },
                },
            },

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
    },

}
