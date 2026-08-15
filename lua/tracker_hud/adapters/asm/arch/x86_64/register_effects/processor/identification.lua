-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/processor/identification.lua
--
-- x86-64 register effects: processor / identification.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD register semantics are layered onto that syntax.

return {

    ["cpuid"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cpuid",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "cpuid_writes_rax",
            target_register = "rax",
            role = "written by cpuid",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cpuid",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "cpuid_writes_rbx",
            target_register = "rbx",
            role = "written by cpuid",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cpuid",
                    },
                },
            },

        operands = {},

        effect = {
            kind = "register_write",
            name = "cpuid_writes_rcx",
            target_register = "rcx",
            role = "written by cpuid",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cpuid",
                    },
                },
            },

        operands = {},

        effect = {
            kind = "register_write",
            name = "cpuid_writes_rdx",
            target_register = "rdx",
            role = "written by cpuid",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cpuid",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "cpuid_writes_rax",
            target_register = "rax",
            role = "written with processor identification leaf result by cpuid",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cpuid",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "cpuid_writes_rbx",
            target_register = "rbx",
            role = "written with processor identification leaf result by cpuid",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cpuid",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "cpuid_writes_rcx",
            target_register = "rcx",
            role = "written with processor identification leaf result by cpuid",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cpuid",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "cpuid_writes_rdx",
            target_register = "rdx",
            role = "written with processor identification leaf result by cpuid",
        },
        },
    },

    ["rdpid"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdpid",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdpid_writes_destination",
            target_operand = 1,
            role = "written with processor id by rdpid",
        },
        },
    },
}
