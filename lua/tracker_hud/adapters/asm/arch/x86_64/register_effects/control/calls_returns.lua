-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/control/calls_returns.lua
--
-- x86-64 register effects: control / calls and returns.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {

    ["call"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "call",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },

            effect = {
                kind = "register_write",
                name = "call_updates_rip",
                target_register = "rip",
                role = "changed by call",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "call",
                    },
                },
            },

            operands = {
                {
                    index = 1,
                    role = "call_target",
                },
            },

            effect = {
                kind = "register_write",
                name = "call_updates_rsp",
                target_register = "rsp",
                value_delta = -8,
                role = "decreased by call",
            },
        },
    },

    ["ret"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ret",
                    },
                },
            },

            operands = {},

            effect = {
                kind = "register_write",
                name = "ret_updates_rip",
                target_register = "rip",
                value_from_stack_top = true,
                value_from_stack = "top",
                role = "restored from return address by ret",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ret",
                    },
                },
            },

            operands = {},

            effect = {
                kind = "register_write",
                name = "ret_updates_rsp",
                target_register = "rsp",
                value_delta = 8,
                role = "increased by ret",
            },
        },
    },

    ["retf"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retf",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retf_updates_rip",
                target_register = "rip",
                role = "far return changed instruction pointer by retf",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retf",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retf_updates_rsp",
                target_register = "rsp",
                role = "far return adjusted stack pointer by retf",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retf",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retf_updates_rip",
                target_register = "rip",
                role = "returned far by retf",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retf",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retf_increases_rsp",
                target_register = "rsp",
                role = "increased by far return retf",
                value_delta = 16,
            },
        },
    },

    ["callf"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "callf",
                    },
                },
            },

            operands = {
                { index = 1, role = "far_target" },
            },
            effect = {
                kind = "register_write",
                name = "callf_updates_rip",
                target_register = "rip",
                role = "far call changed instruction pointer by callf",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "callf",
                    },
                },
            },

            operands = {
                { index = 1, role = "far_target" },
            },
            effect = {
                kind = "register_write",
                name = "callf_updates_rsp",
                target_register = "rsp",
                role = "far call adjusted stack pointer by callf",
            },
        },
    },

    ["retn"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retn",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retn_updates_rip",
                target_register = "rip",
                role = "returned near by retn",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retn",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retn_increases_rsp",
                target_register = "rsp",
                role = "increased by near return retn",
                value_delta = 8,
            },
        },
    },

    ["retfq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retfq",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retfq_updates_rip",
                target_register = "rip",
                role = "returned far quadword by retfq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retfq",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retfq_increases_rsp",
                target_register = "rsp",
                role = "increased by far quadword return retfq",
                value_delta = 16,
            },
        },
    },

    ["retfw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retfw",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retfw_updates_rip",
                target_register = "rip",
                role = "returned far word by retfw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retfw",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retfw_increases_rsp",
                target_register = "rsp",
                role = "increased by far word return retfw",
                value_delta = 4,
            },
        },
    },

    ["callq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "callq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "callq_updates_rip",
                target_register = "rip",
                role = "called quadword target by callq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "callq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "callq_decreases_rsp",
                target_register = "rsp",
                role = "decreased by quadword call return-address push callq",
                value_delta = -8,
            },
        },
    },

    ["calll"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "calll",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "calll_updates_rip",
                target_register = "rip",
                role = "called long target by calll",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "calll",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "calll_decreases_rsp",
                target_register = "rsp",
                role = "decreased by long call return-address push calll",
                value_delta = -4,
            },
        },
    },

    ["callw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "callw",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "callw_updates_rip",
                target_register = "rip",
                role = "called word target by callw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "callw",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "callw_decreases_rsp",
                target_register = "rsp",
                role = "decreased by word call return-address push callw",
                value_delta = -2,
            },
        },
    },

    ["retq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retq",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retq_updates_rip",
                target_register = "rip",
                role = "returned quadword by retq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retq",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retq_increases_rsp",
                target_register = "rsp",
                role = "increased by quadword return retq",
                value_delta = 8,
            },
        },
    },

    ["retl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retl",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retl_updates_rip",
                target_register = "rip",
                role = "returned long by retl",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retl",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retl_increases_rsp",
                target_register = "rsp",
                role = "increased by long return retl",
                value_delta = 4,
            },
        },
    },

    ["retw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retw",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retw_updates_rip",
                target_register = "rip",
                role = "returned word by retw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "retw",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "retw_increases_rsp",
                target_register = "rsp",
                role = "increased by word return retw",
                value_delta = 2,
            },
        },
    },

}
