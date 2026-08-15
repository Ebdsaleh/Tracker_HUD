-- lua/tracker_hud/adapters/asm/arch/x86_64/stack_effects/allocation.lua
--
-- x86-64 explicit stack allocation/deallocation effects.
--
-- Tree-sitter-first, mnemonic-indexed stack-effect specs.

return {
    ["sub"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sub",
                    },
                },
            },

            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "stack_pointer",
                    value = "rsp",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "allocation_size",
                },
            },

            effect = {
                kind = "stack_allocate",
                name = "sub_rsp_immediate",
                size_operand = 2,
                role = "allocated stack space",
            },
        },
    },

    ["add"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "add",
                    },
                },
            },

            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "stack_pointer",
                    value = "rsp",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "deallocation_size",
                },
            },

            effect = {
                kind = "stack_deallocate",
                name = "add_rsp_immediate",
                size_operand = 2,
                role = "released stack space",
            },
        },
    },
}
