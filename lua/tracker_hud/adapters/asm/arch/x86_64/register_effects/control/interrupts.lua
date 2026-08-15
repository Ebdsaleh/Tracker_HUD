-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/control/interrupts.lua
--
-- x86-64 register effects: control / interrupts.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies instruction syntax first. x86-64 / Tracker_HUD
-- register semantics are layered onto that syntax.

return {

    ["iretw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "iretw",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "iretw_updates_rip",
                target_register = "rip",
                role = "returned from interrupt by iretw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "iretw",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "iretw_updates_rip",
                target_register = "rip",
                role = "returned from word interrupt by iretw",
            },
        },
    },

    ["iretd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "iretd",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "iretd_updates_rip",
                target_register = "rip",
                role = "returned from interrupt by iretd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "iretd",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "iretd_updates_rip",
                target_register = "rip",
                role = "returned from doubleword interrupt by iretd",
            },
        },
    },

    ["iretq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "iretq",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "iretq_updates_rip",
                target_register = "rip",
                role = "returned from quadword interrupt by iretq",
            },
        },
    },

}
