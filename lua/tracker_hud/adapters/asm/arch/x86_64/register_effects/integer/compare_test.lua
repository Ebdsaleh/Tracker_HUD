-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/integer/compare_test.lua
--
-- x86-64 register effects: integer / compare test.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["cmp"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmp",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            role = "left",
                        },
                        {
                            index = 2,
                            role = "right",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "cmp_updates_rflags",
                        target_register = "rflags",
                        role = "updated by cmp",
                    },
    },
    },

    ["cmpb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpb",
                },
            },
        },

        operands = {
                        { index = 1, role = "left" },
                        { index = 2, role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmpb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte compare cmpb",
                    },
    },
    },

    ["cmpw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpw",
                },
            },
        },

        operands = {
                        { index = 1, role = "left" },
                        { index = 2, role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmpw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word compare cmpw",
                    },
    },
    },

    ["cmpl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpl",
                },
            },
        },

        operands = {
                        { index = 1, role = "left" },
                        { index = 2, role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmpl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long compare cmpl",
                    },
    },
    },

    ["cmpq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpq",
                },
            },
        },

        operands = {
                        { index = 1, role = "left" },
                        { index = 2, role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmpq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword compare cmpq",
                    },
    },
    },

    ["testb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "testb",
                },
            },
        },

        operands = {
                        { index = 1, role = "left" },
                        { index = 2, role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "testb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte test testb",
                    },
    },
    },

    ["testw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "testw",
                },
            },
        },

        operands = {
                        { index = 1, role = "left" },
                        { index = 2, role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "testw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word test testw",
                    },
    },
    },

    ["testl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "testl",
                },
            },
        },

        operands = {
                        { index = 1, role = "left" },
                        { index = 2, role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "testl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long test testl",
                    },
    },
    },

    ["testq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "testq",
                },
            },
        },

        operands = {
                        { index = 1, role = "left" },
                        { index = 2, role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "testq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword test testq",
                    },
    },
    },

    ["test"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "test",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            role = "left",
                        },
                        {
                            index = 2,
                            role = "right",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "test_updates_rflags",
                        target_register = "rflags",
                        role = "updated by test",
                    },
    },
    },

}

