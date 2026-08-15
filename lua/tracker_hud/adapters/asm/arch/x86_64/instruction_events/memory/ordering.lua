-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/memory/ordering.lua
--
-- x86-64 instruction events: memory / ordering.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Each entry starts with the exact Tree-sitter syntax identity used to select
-- the instruction. Event/effect data then describes what that syntax means to
-- x86-64 and Tracker_HUD.

return {

    ["lfence"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lfence",
                    },
                },
            },

            kind = "memory_order_event",
            category = "memory_order",
            name = "lfence",
            role = "orders prior loads before later operations",

            operands = {},

            event = {
                name = "lfence_memory_order",
                display_name = "lfence",
                role = "orders prior loads before later operations",
            },

            effect = {
                kind = "memory_order",
                name = "lfence_memory_order",
                role = "orders prior loads before later operations",
            },
        },
    },

    ["sfence"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sfence",
                    },
                },
            },

            kind = "memory_order_event",
            category = "memory_order",
            name = "sfence",
            role = "orders prior stores before later operations",

            operands = {},

            event = {
                name = "sfence_memory_order",
                display_name = "sfence",
                role = "orders prior stores before later operations",
            },

            effect = {
                kind = "memory_order",
                name = "sfence_memory_order",
                role = "orders prior stores before later operations",
            },
        },
    },

    ["mfence"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "mfence",
                    },
                },
            },

            kind = "memory_order_event",
            category = "memory_order",
            name = "mfence",
            role = "orders prior memory operations before later operations",

            operands = {},

            event = {
                name = "mfence_memory_order",
                display_name = "mfence",
                role = "orders prior memory operations before later operations",
            },

            effect = {
                kind = "memory_order",
                name = "mfence_memory_order",
                role = "orders prior memory operations before later operations",
            },
        },
    },
}

