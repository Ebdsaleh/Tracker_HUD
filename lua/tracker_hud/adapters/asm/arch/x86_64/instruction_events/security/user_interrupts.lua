-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/security/user_interrupts.lua
--
-- x86-64 instruction events: security / user interrupts.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["senduipi"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "senduipi",
                    },
                },
            },

            kind = "security_event",
            category = "user_interrupt",
            name = "senduipi",
            role = "sends a user interprocessor interrupt",

            operands = {
                { index = 1, role = "destination", },
            },

            event = {
                name = "senduipi_sends_user_interrupt",
                display_name = "senduipi",
                role = "sends a user interprocessor interrupt",
            },

            effect = {
                kind = "user_interrupt_send",
                name = "senduipi_sends_user_interrupt",
                role = "sends a user interprocessor interrupt",
            },
        },
    },
}

