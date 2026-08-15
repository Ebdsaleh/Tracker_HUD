-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor/entropy.lua
--
-- x86-64 instruction events: processor / entropy.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["rdrand"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdrand",
                    },
                },
            },

            kind = "processor_event",
            category = "random",
            name = "rdrand",
            role = "reads hardware-generated random data",

            operands = {
            },

            event = {
                name = "rdrand_hardware_random_read",
                display_name = "rdrand",
                role = "reads hardware-generated random data",
            },

            effect = {
                kind = "hardware_random_read",
                name = "rdrand_hardware_random_read",
                role = "reads hardware-generated random data",
            },
        },
    },

    ["rdseed"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdseed",
                    },
                },
            },

            kind = "processor_event",
            category = "random",
            name = "rdseed",
            role = "reads hardware-generated seed data",

            operands = {
            },

            event = {
                name = "rdseed_hardware_random_read",
                display_name = "rdseed",
                role = "reads hardware-generated seed data",
            },

            effect = {
                kind = "hardware_random_read",
                name = "rdseed_hardware_random_read",
                role = "reads hardware-generated seed data",
            },
        },
    },
}

