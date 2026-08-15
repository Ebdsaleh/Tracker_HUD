-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/processor/descriptor_segment.lua
--
-- x86-64 register effects: processor / descriptor and segment state.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD register semantics are layered onto that syntax.

return {

    ["sldt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sldt",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "sldt_writes_destination",
            target_operand = 1,
            role = "written with local descriptor table selector by sldt",
        },
        },
    },

    ["str"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "str",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "str_writes_destination",
            target_operand = 1,
            role = "written with task register selector by str",
        },
        },
    },

    ["rdfsbase"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdfsbase",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdfsbase_writes_destination",
            target_operand = 1,
            role = "written with fs base by rdfsbase",
        },
        },
    },

    ["rdgsbase"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdgsbase",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdgsbase_writes_destination",
            target_operand = 1,
            role = "written with gs base by rdgsbase",
        },
        },
    },

    ["lar"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lar",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "lar_updates_rflags",
            target_register = "rflags",
            role = "updated by lar",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lar",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "lar_writes_destination",
            target_operand = 1,
            role = "written with access rights by lar",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lar",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "lar_writes_destination",
            target_operand = 1,
            role = "written with access rights by lar",
        },
        },
    },

    ["lsl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lsl",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "lsl_updates_rflags",
            target_register = "rflags",
            role = "updated by lsl",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lsl",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "lsl_writes_destination",
            target_operand = 1,
            role = "written with segment limit by lsl",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lsl",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "lsl_writes_destination",
            target_operand = 1,
            role = "written with segment limit by lsl",
        },
        },
    },

    ["verr"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "verr",
                    },
                },
            },

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
    },

    ["verw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "verw",
                    },
                },
            },

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
    },
}
