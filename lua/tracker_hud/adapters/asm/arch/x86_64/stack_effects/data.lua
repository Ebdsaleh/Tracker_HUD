-- lua/tracker_hud/adapters/asm/arch/x86_64/stack_effects/data.lua
--
-- x86-64 stack data-transfer effects.
--
-- Tree-sitter-first, mnemonic-indexed stack-effect specs.

return {
    ["push"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "push",
                    },
                },
            },

            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "pushed_value",
                },
            },

            effect = {
                kind = "stack_push",
                name = "push_register",
                value_operand = 1,
                size = 8,
                offset_delta = -8,
                role = "pushed register onto stack",
            },
        },

        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "push",
                    },
                },
            },

            operands = {
                {
                    index = 1,
                    kind = "integer",
                    role = "pushed_value",
                },
            },

            effect = {
                kind = "stack_push",
                name = "push_immediate",
                value_operand = 1,
                size = 8,
                offset_delta = -8,
                role = "pushed immediate onto stack",
            },
        },

        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "push",
                    },
                },
            },

            operands = {
                {
                    index = 1,
                    kind = "symbol",
                    role = "pushed_value",
                },
            },

            effect = {
                kind = "stack_push",
                name = "push_symbol",
                value_operand = 1,
                size = 8,
                offset_delta = -8,
                role = "pushed symbol onto stack",
            },
        },
    },

    ["pop"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pop",
                    },
                },
            },

            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
            },

            effect = {
                kind = "stack_pop",
                name = "pop_register",
                value_operand = 1,
                size = 8,
                offset_delta = 8,
                role = "popped stack value into register",
            },
        },
    },
}
