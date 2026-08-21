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
    },
}
