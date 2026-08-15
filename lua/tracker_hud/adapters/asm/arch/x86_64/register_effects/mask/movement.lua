-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/mask/movement.lua
--
-- x86-64 register effects: mask / movement.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["kmovb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kmovb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "kmovb_mask_move",
                target_register = "rip",
                role = "moved byte mask register state by kmovb",
            },
        },
    },

    ["kmovw"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kmovw",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "kmovw_mask_move",
                target_register = "rip",
                role = "moved word mask register state by kmovw",
            },
        },
    },

    ["kmovd"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kmovd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "kmovd_mask_move",
                target_register = "rip",
                role = "moved doubleword mask register state by kmovd",
            },
        },
    },

    ["kmovq"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kmovq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "kmovq_mask_move",
                target_register = "rip",
                role = "moved quadword mask register state by kmovq",
            },
        },
    },

}
