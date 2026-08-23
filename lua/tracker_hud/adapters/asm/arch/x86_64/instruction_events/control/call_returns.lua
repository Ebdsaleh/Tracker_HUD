-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/control/call_returns.lua
--
-- x86-64 instruction events: control / calls and returns.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.

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

            kind = "control_event",
            category = "control_flow",
            name = "call",
            role = "calls target and records a return address",

            operands = {
                { index = 1, role = "call_target" },
            },

            event = {
                name = "call_control_transfer",
                display_name = "call",
                role = "calls target and records a return address",
            },

            effect = {
                kind = "control_transfer",
                name = "call_control_transfer",
                role = "calls target and records a return address",
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

            kind = "control_event",
            category = "control_flow",
            name = "callq",
            role = "calls quadword target and records a return address",

            operands = {
                { index = 1, role = "call_target" },
            },

            event = {
                name = "callq_control_transfer",
                display_name = "callq",
                role = "calls quadword target and records a return address",
            },

            effect = {
                kind = "control_transfer",
                name = "callq_control_transfer",
                role = "calls quadword target and records a return address",
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

            kind = "control_event",
            category = "control_flow",
            name = "calll",
            role = "calls long target and records a return address",

            operands = {
                { index = 1, role = "call_target" },
            },

            event = {
                name = "calll_control_transfer",
                display_name = "calll",
                role = "calls long target and records a return address",
            },

            effect = {
                kind = "control_transfer",
                name = "calll_control_transfer",
                role = "calls long target and records a return address",
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

            kind = "control_event",
            category = "control_flow",
            name = "callw",
            role = "calls word target and records a return address",

            operands = {
                { index = 1, role = "call_target" },
            },

            event = {
                name = "callw_control_transfer",
                display_name = "callw",
                role = "calls word target and records a return address",
            },

            effect = {
                kind = "control_transfer",
                name = "callw_control_transfer",
                role = "calls word target and records a return address",
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

            kind = "control_event",
            category = "control_flow",
            name = "ret",
            role = "returns to caller using the stack return address",

            operands = {},

            event = {
                name = "ret_control_return",
                display_name = "ret",
                role = "returns to caller using the stack return address",
            },

            effect = {
                kind = "control_return",
                name = "ret_control_return",
                role = "returns to caller using the stack return address",
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

            kind = "control_event",
            category = "control_flow",
            name = "retn",
            role = "returns near using the stack return address",

            operands = {},

            event = {
                name = "retn_control_return",
                display_name = "retn",
                role = "returns near using the stack return address",
            },

            effect = {
                kind = "control_return",
                name = "retn_control_return",
                role = "returns near using the stack return address",
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

            kind = "control_event",
            category = "control_flow",
            name = "retq",
            role = "returns using a quadword stack return address",

            operands = {},

            event = {
                name = "retq_control_return",
                display_name = "retq",
                role = "returns using a quadword stack return address",
            },

            effect = {
                kind = "control_return",
                name = "retq_control_return",
                role = "returns using a quadword stack return address",
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

            kind = "control_event",
            category = "control_flow",
            name = "retl",
            role = "returns using a long stack return address",

            operands = {},

            event = {
                name = "retl_control_return",
                display_name = "retl",
                role = "returns using a long stack return address",
            },

            effect = {
                kind = "control_return",
                name = "retl_control_return",
                role = "returns using a long stack return address",
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

            kind = "control_event",
            category = "control_flow",
            name = "retw",
            role = "returns using a word stack return address",

            operands = {},

            event = {
                name = "retw_control_return",
                display_name = "retw",
                role = "returns using a word stack return address",
            },

            effect = {
                kind = "control_return",
                name = "retw_control_return",
                role = "returns using a word stack return address",
            },
        },
    },
}
