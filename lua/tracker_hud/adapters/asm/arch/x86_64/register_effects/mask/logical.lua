-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/mask/logical.lua
--
-- x86-64 register effects: mask / logical.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["kandb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kandb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandb_mask_logic",
                target_register = "rip",
                role = "bitwise-and byte mask state by kandb",
            },
        },
    },

    ["kandw"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kandw",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandw_mask_logic",
                target_register = "rip",
                role = "bitwise-and word mask state by kandw",
            },
        },
    },

    ["kandd"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kandd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandd_mask_logic",
                target_register = "rip",
                role = "bitwise-and doubleword mask state by kandd",
            },
        },
    },

    ["kandq"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kandq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandq_mask_logic",
                target_register = "rip",
                role = "bitwise-and quadword mask state by kandq",
            },
        },
    },

    ["kandnb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kandnb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandnb_mask_logic",
                target_register = "rip",
                role = "bitwise-and-not byte mask state by kandnb",
            },
        },
    },

    ["kandnw"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kandnw",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandnw_mask_logic",
                target_register = "rip",
                role = "bitwise-and-not word mask state by kandnw",
            },
        },
    },

    ["kandnd"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kandnd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandnd_mask_logic",
                target_register = "rip",
                role = "bitwise-and-not doubleword mask state by kandnd",
            },
        },
    },

    ["kandnq"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kandnq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandnq_mask_logic",
                target_register = "rip",
                role = "bitwise-and-not quadword mask state by kandnq",
            },
        },
    },

    ["korb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "korb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "korb_mask_logic",
                target_register = "rip",
                role = "bitwise-or byte mask state by korb",
            },
        },
    },

    ["korw"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "korw",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "korw_mask_logic",
                target_register = "rip",
                role = "bitwise-or word mask state by korw",
            },
        },
    },

    ["kord"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kord",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kord_mask_logic",
                target_register = "rip",
                role = "bitwise-or doubleword mask state by kord",
            },
        },
    },

    ["korq"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "korq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "korq_mask_logic",
                target_register = "rip",
                role = "bitwise-or quadword mask state by korq",
            },
        },
    },

    ["kxorb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kxorb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kxorb_mask_logic",
                target_register = "rip",
                role = "bitwise-xor byte mask state by kxorb",
            },
        },
    },

    ["kxorw"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kxorw",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kxorw_mask_logic",
                target_register = "rip",
                role = "bitwise-xor word mask state by kxorw",
            },
        },
    },

    ["kxord"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kxord",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kxord_mask_logic",
                target_register = "rip",
                role = "bitwise-xor doubleword mask state by kxord",
            },
        },
    },

    ["kxorq"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kxorq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kxorq_mask_logic",
                target_register = "rip",
                role = "bitwise-xor quadword mask state by kxorq",
            },
        },
    },

    ["knotb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "knotb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "knotb_mask_logic",
                target_register = "rip",
                role = "bitwise-inverted byte mask state by knotb",
            },
        },
    },

    ["knotw"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "knotw",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "knotw_mask_logic",
                target_register = "rip",
                role = "bitwise-inverted word mask state by knotw",
            },
        },
    },

    ["knotd"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "knotd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "knotd_mask_logic",
                target_register = "rip",
                role = "bitwise-inverted doubleword mask state by knotd",
            },
        },
    },

    ["knotq"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "knotq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "knotq_mask_logic",
                target_register = "rip",
                role = "bitwise-inverted quadword mask state by knotq",
            },
        },
    },

}
