-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/processor/control_state.lua
--
-- x86-64 register effects: processor / architectural control state.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD register semantics are layered onto that syntax.

return {

    ["rdmsr"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdmsr",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdmsr_writes_rax",
            target_register = "rax",
            role = "written with model-specific register low bits by rdmsr",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdmsr",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdmsr_writes_rdx",
            target_register = "rdx",
            role = "written with model-specific register high bits by rdmsr",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdmsr",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdmsr_writes_rax",
            target_register = "rax",
            role = "written with model-specific register low value by rdmsr",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdmsr",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdmsr_writes_rdx",
            target_register = "rdx",
            role = "written with model-specific register high value by rdmsr",
        },
        },
    },

    ["xgetbv"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xgetbv",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "xgetbv_writes_rax",
            target_register = "rax",
            role = "written with extended control register low bits by xgetbv",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xgetbv",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "xgetbv_writes_rdx",
            target_register = "rdx",
            role = "written with extended control register high bits by xgetbv",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xgetbv",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "xgetbv_writes_rax",
            target_register = "rax",
            role = "written with extended control register low value by xgetbv",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xgetbv",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "xgetbv_writes_rdx",
            target_register = "rdx",
            role = "written with extended control register high value by xgetbv",
        },
        },
    },

    ["smsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "smsw",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "smsw_writes_destination",
            target_operand = 1,
            role = "written with machine status word by smsw",
        },
        },
    },

    ["rdpru"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdpru",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdpru_writes_rax",
            target_register = "rax",
            role = "written with processor register value low by rdpru",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdpru",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdpru_writes_rdx",
            target_register = "rdx",
            role = "written with processor register value high by rdpru",
        },
        },
    },
}
