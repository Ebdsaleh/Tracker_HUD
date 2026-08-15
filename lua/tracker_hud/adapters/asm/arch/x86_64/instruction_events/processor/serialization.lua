-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor/serialization.lua
--
-- x86-64 instruction events: processor / serialization.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["serialize"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "serialize",
                    },
                },
            },

            kind = "processor_event",
            category = "serialization",
            name = "serialize",
            role = "serializes instruction execution",

            operands = {
            },

            event = {
                name = "serialize_processor_serialization",
                display_name = "serialize",
                role = "serializes instruction execution",
            },

            effect = {
                kind = "processor_serialization",
                name = "serialize_processor_serialization",
                role = "serializes instruction execution",
            },
        },
    },
}

