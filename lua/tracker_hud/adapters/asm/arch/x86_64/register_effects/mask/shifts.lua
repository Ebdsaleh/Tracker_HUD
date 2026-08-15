-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/mask/shifts.lua
--
-- x86-64 register effects: mask / shifts.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["kshiftlb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kshiftlb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftlb_mask_shift",
                target_register = "rip",
                role = "shifted byte mask state left by kshiftlb",
            },
        },
    },

    ["kshiftlw"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kshiftlw",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftlw_mask_shift",
                target_register = "rip",
                role = "shifted word mask state left by kshiftlw",
            },
        },
    },

    ["kshiftld"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kshiftld",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftld_mask_shift",
                target_register = "rip",
                role = "shifted doubleword mask state left by kshiftld",
            },
        },
    },

    ["kshiftlq"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kshiftlq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftlq_mask_shift",
                target_register = "rip",
                role = "shifted quadword mask state left by kshiftlq",
            },
        },
    },

    ["kshiftrb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kshiftrb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftrb_mask_shift",
                target_register = "rip",
                role = "shifted byte mask state right by kshiftrb",
            },
        },
    },

    ["kshiftrw"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kshiftrw",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftrw_mask_shift",
                target_register = "rip",
                role = "shifted word mask state right by kshiftrw",
            },
        },
    },

    ["kshiftrd"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kshiftrd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftrd_mask_shift",
                target_register = "rip",
                role = "shifted doubleword mask state right by kshiftrd",
            },
        },
    },

    ["kshiftrq"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kshiftrq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftrq_mask_shift",
                target_register = "rip",
                role = "shifted quadword mask state right by kshiftrq",
            },
        },
    },

}
