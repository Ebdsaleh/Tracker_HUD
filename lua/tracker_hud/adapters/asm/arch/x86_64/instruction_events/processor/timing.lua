-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor/timing.lua
--
-- x86-64 instruction events: processor / timing.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["rdtsc"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdtsc",
                    },
                },
            },

            kind = "processor_event",
            category = "timestamp",
            name = "rdtsc",
            role = "reads the processor timestamp counter",

            operands = {
            },

            event = {
                name = "rdtsc_timestamp_read",
                display_name = "rdtsc",
                role = "reads the processor timestamp counter",
            },

            effect = {
                kind = "timestamp_read",
                name = "rdtsc_timestamp_read",
                role = "reads the processor timestamp counter",
            },
        },
    },

    ["rdtscp"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdtscp",
                    },
                },
            },

            kind = "processor_event",
            category = "timestamp",
            name = "rdtscp",
            role = "reads the processor timestamp counter with ordering",

            operands = {
            },

            event = {
                name = "rdtscp_timestamp_read",
                display_name = "rdtscp",
                role = "reads the processor timestamp counter with ordering",
            },

            effect = {
                kind = "timestamp_read",
                name = "rdtscp_timestamp_read",
                role = "reads the processor timestamp counter with ordering",
            },
        },
    },
}

