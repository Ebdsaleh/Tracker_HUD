-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor/identification.lua
--
-- x86-64 instruction events: processor / identification.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["cpuid"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cpuid",
                    },
                },
            },

            kind = "processor_event",
            category = "processor",
            name = "cpuid",
            role = "queries processor information and feature flags",

            operands = {
            },

            event = {
                name = "cpuid_processor_query",
                display_name = "cpuid",
                role = "queries processor information and feature flags",
            },

            effect = {
                kind = "processor_query",
                name = "cpuid_processor_query",
                role = "queries processor information and feature flags",
            },
        },
    },
}

