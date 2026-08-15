-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor/protection_state.lua
--
-- x86-64 instruction events: processor / protection state.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["rdpkru"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdpkru",
                    },
                },
            },

            kind = "processor_state_event",
            category = "protection_key_state",
            name = "rdpkru",
            role = "reads protection-key rights state",

            operands = {
            },

            event = {
                name = "rdpkru_reads_protection_key_rights",
                display_name = "rdpkru",
                role = "reads protection-key rights state",
            },

            effect = {
                kind = "protection_key_state_read",
                name = "rdpkru_reads_protection_key_rights",
                role = "reads protection-key rights state",
            },
        },
    },

    ["wrpkru"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "wrpkru",
                    },
                },
            },

            kind = "processor_state_event",
            category = "protection_key_state",
            name = "wrpkru",
            role = "writes protection-key rights state",

            operands = {
            },

            event = {
                name = "wrpkru_writes_protection_key_rights",
                display_name = "wrpkru",
                role = "writes protection-key rights state",
            },

            effect = {
                kind = "protection_key_state_write",
                name = "wrpkru_writes_protection_key_rights",
                role = "writes protection-key rights state",
            },
        },
    },
}

