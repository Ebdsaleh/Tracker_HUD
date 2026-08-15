-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/crypto/carryless_gfni.lua
--
-- x86-64 register effects: crypto / carryless gfni.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["pclmulqdq"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pclmulqdq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "pclmulqdq_crypto",
                target_register = "rip",
                role = "performed carry-less quadword multiply by pclmulqdq",
            },
        },
    },

    ["vpclmulqdq"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpclmulqdq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "vpclmulqdq_crypto",
                target_register = "rip",
                role = "performed vector carry-less quadword multiply by vpclmulqdq",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpclmulqdq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vpclmulqdq_vector_crypto_carryless_multiply",
                target_register = "rip",
                role = "performed vector carry-less multiply by vpclmulqdq",
            },
        },
    },

    ["gf2p8mulb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "gf2p8mulb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "gf2p8mulb_crypto",
                target_register = "rip",
                role = "multiplied packed bytes in gf2p8 by gf2p8mulb",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "gf2p8mulb",
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
                name = "gf2p8mulb_vector_gfni",
                target_register = "rip",
                role = "performed Galois-field byte multiply by gf2p8mulb",
            },
        },
    },

    ["gf2p8affineqb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "gf2p8affineqb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "matrix" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "gf2p8affineqb_crypto",
                target_register = "rip",
                role = "applied gf2p8 affine transform by gf2p8affineqb",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "gf2p8affineqb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "gf2p8affineqb_vector_gfni",
                target_register = "rip",
                role = "performed Galois-field affine transform by gf2p8affineqb",
            },
        },
    },

    ["gf2p8affineinvqb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "gf2p8affineinvqb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "matrix" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "gf2p8affineinvqb_crypto",
                target_register = "rip",
                role = "applied inverse gf2p8 affine transform by gf2p8affineinvqb",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "gf2p8affineinvqb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "gf2p8affineinvqb_vector_gfni",
                target_register = "rip",
                role = "performed inverse Galois-field affine transform by gf2p8affineinvqb",
            },
        },
    },

    ["vgf2p8mulb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgf2p8mulb",
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
                name = "vgf2p8mulb_crypto",
                target_register = "rip",
                role = "multiplied packed bytes in gf2p8 by vgf2p8mulb",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgf2p8mulb",
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
                name = "vgf2p8mulb_vector_gfni",
                target_register = "rip",
                role = "performed vector Galois-field byte multiply by vgf2p8mulb",
            },
        },
    },

    ["vgf2p8affineqb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgf2p8affineqb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vgf2p8affineqb_crypto",
                target_register = "rip",
                role = "applied vector gf2p8 affine transform by vgf2p8affineqb",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgf2p8affineqb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vgf2p8affineqb_vector_gfni",
                target_register = "rip",
                role = "performed vector Galois-field affine transform by vgf2p8affineqb",
            },
        },
    },

    ["vgf2p8affineinvqb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgf2p8affineinvqb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vgf2p8affineinvqb_crypto",
                target_register = "rip",
                role = "applied inverse vector gf2p8 affine transform by vgf2p8affineinvqb",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgf2p8affineinvqb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vgf2p8affineinvqb_vector_gfni",
                target_register = "rip",
                role = "performed vector inverse Galois-field affine transform by vgf2p8affineinvqb",
            },
        },
    },

}
