-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/crypto/sm3_sm4.lua
--
-- x86-64 register effects: crypto / sm3 sm4.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["vsm3msg1"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsm3msg1",
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
                name = "vsm3msg1_crypto",
                target_register = "rip",
                role = "performed sm3 message schedule step by vsm3msg1",
            },
        },
    },

    ["vsm3msg2"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsm3msg2",
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
                name = "vsm3msg2_crypto",
                target_register = "rip",
                role = "performed sm3 message schedule step by vsm3msg2",
            },
        },
    },

    ["vsm3rnds2"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsm3rnds2",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "round_selector" },
            },
            effect = {
                kind = "register_write",
                name = "vsm3rnds2_crypto",
                target_register = "rip",
                role = "performed two sm3 rounds by vsm3rnds2",
            },
        },
    },

    ["vsm4key4"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsm4key4",
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
                name = "vsm4key4_crypto",
                target_register = "rip",
                role = "performed four sm4 key schedule rounds by vsm4key4",
            },
        },
    },

    ["vsm4rnds4"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsm4rnds4",
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
                name = "vsm4rnds4_crypto",
                target_register = "rip",
                role = "performed four sm4 encryption rounds by vsm4rnds4",
            },
        },
    },

}
