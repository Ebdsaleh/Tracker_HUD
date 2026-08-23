-- lua/tracker_hud/adapters/asm/arch/x86_64/stack_effects/control.lua
--
-- x86-64 call/return stack effects.
--
-- Tree-sitter-first, mnemonic-indexed stack-effect specs.

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
                {
                    index = 1,
                    role = "call_target",
                },
            },

            effect = {
                kind = "stack_call",
                name = "call_return_address",
                value_operand = 1,
                stack_push_value = "return address",
                stack_push_source_kind = "control_flow",
                stack_push_source_text = "return address after call",
                size = 8,
                offset_delta = -8,
                role = "pushed return address and transferred control",
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
                {
                    index = 1,
                    role = "call_target",
                },
            },

            effect = {
                kind = "stack_call",
                name = "callq_return_address",
                value_operand = 1,
                stack_push_value = "return address",
                stack_push_source_kind = "control_flow",
                stack_push_source_text = "return address after callq",
                size = 8,
                offset_delta = -8,
                role = "pushed return address and transferred control",
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
                {
                    index = 1,
                    role = "call_target",
                },
            },

            effect = {
                kind = "stack_call",
                name = "calll_return_address",
                value_operand = 1,
                stack_push_value = "return address",
                stack_push_source_kind = "control_flow",
                stack_push_source_text = "return address after calll",
                size = 4,
                offset_delta = -4,
                role = "pushed return address and transferred control",
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
                {
                    index = 1,
                    role = "call_target",
                },
            },

            effect = {
                kind = "stack_call",
                name = "callw_return_address",
                value_operand = 1,
                stack_push_value = "return address",
                stack_push_source_kind = "control_flow",
                stack_push_source_text = "return address after callw",
                size = 2,
                offset_delta = -2,
                role = "pushed return address and transferred control",
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
                kind = "stack_return",
                name = "ret_return_address",
                value_from_stack_top = true,
                stack_reads_top = true,
                destination_register = "rip",
                size = 8,
                offset_delta = 8,
                role = "popped return address and returned to caller",
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

            operands = {
                {
                    index = 1,
                    kind = "integer",
                    role = "callee_cleanup_size",
                },
            },

            effect = {
                kind = "stack_deallocate",
                name = "ret_releases_arguments",
                size_operand = 1,
                role = "released caller argument stack space after return",
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
                kind = "stack_return",
                name = "retn_return_address",
                value_from_stack_top = true,
                stack_reads_top = true,
                destination_register = "rip",
                size = 8,
                offset_delta = 8,
                role = "popped near return address and returned to caller",
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

            operands = {
                {
                    index = 1,
                    kind = "integer",
                    role = "callee_cleanup_size",
                },
            },

            effect = {
                kind = "stack_deallocate",
                name = "retn_releases_arguments",
                size_operand = 1,
                role = "released caller argument stack space after near return",
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
                kind = "stack_return",
                name = "retq_return_address",
                value_from_stack_top = true,
                stack_reads_top = true,
                destination_register = "rip",
                size = 8,
                offset_delta = 8,
                role = "popped quadword return address and returned to caller",
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

            operands = {
                {
                    index = 1,
                    kind = "integer",
                    role = "callee_cleanup_size",
                },
            },

            effect = {
                kind = "stack_deallocate",
                name = "retq_releases_arguments",
                size_operand = 1,
                role = "released caller argument stack space after quadword return",
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
                kind = "stack_return",
                name = "retl_return_address",
                value_from_stack_top = true,
                stack_reads_top = true,
                destination_register = "rip",
                size = 4,
                offset_delta = 4,
                role = "popped long return address and returned to caller",
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

            operands = {
                {
                    index = 1,
                    kind = "integer",
                    role = "callee_cleanup_size",
                },
            },

            effect = {
                kind = "stack_deallocate",
                name = "retl_releases_arguments",
                size_operand = 1,
                role = "released caller argument stack space after long return",
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
                kind = "stack_return",
                name = "retw_return_address",
                value_from_stack_top = true,
                stack_reads_top = true,
                destination_register = "rip",
                size = 2,
                offset_delta = 2,
                role = "popped word return address and returned to caller",
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

            operands = {
                {
                    index = 1,
                    kind = "integer",
                    role = "callee_cleanup_size",
                },
            },

            effect = {
                kind = "stack_deallocate",
                name = "retw_releases_arguments",
                size_operand = 1,
                role = "released caller argument stack space after word return",
            },
        },
    },
}

