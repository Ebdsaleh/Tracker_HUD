-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/crypto/aes.lua
--
-- x86-64 register effects: crypto / aes.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["aesenc"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "aesenc",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "aesenc_crypto",
                target_register = "rip",
                role = "performed aes encryption round by aesenc",
            },
        },
    },

    ["aesenclast"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "aesenclast",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "aesenclast_crypto",
                target_register = "rip",
                role = "performed final aes encryption round by aesenclast",
            },
        },
    },

    ["aesdec"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "aesdec",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "aesdec_crypto",
                target_register = "rip",
                role = "performed aes decryption round by aesdec",
            },
        },
    },

    ["aesdeclast"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "aesdeclast",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "aesdeclast_crypto",
                target_register = "rip",
                role = "performed final aes decryption round by aesdeclast",
            },
        },
    },

    ["aesimc"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "aesimc",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "aesimc_crypto",
                target_register = "rip",
                role = "generated inverse aes mix columns key by aesimc",
            },
        },
    },

    ["aeskeygenassist"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "aeskeygenassist",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "round_constant" },
            },
            effect = {
                kind = "register_write",
                name = "aeskeygenassist_crypto",
                target_register = "rip",
                role = "assisted aes key generation by aeskeygenassist",
            },
        },
    },

    ["vaesenc"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vaesenc",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesenc_crypto",
                target_register = "rip",
                role = "performed vector aes encryption round by vaesenc",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vaesenc",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesenc_vector_crypto_round",
                target_register = "rip",
                role = "performed vector AES encryption round by vaesenc",
            },
        },
    },

    ["vaesenclast"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vaesenclast",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesenclast_crypto",
                target_register = "rip",
                role = "performed final vector aes encryption round by vaesenclast",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vaesenclast",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesenclast_vector_crypto_round",
                target_register = "rip",
                role = "performed final vector AES encryption round by vaesenclast",
            },
        },
    },

    ["vaesdec"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vaesdec",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesdec_crypto",
                target_register = "rip",
                role = "performed vector aes decryption round by vaesdec",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vaesdec",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesdec_vector_crypto_round",
                target_register = "rip",
                role = "performed vector AES decryption round by vaesdec",
            },
        },
    },

    ["vaesdeclast"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vaesdeclast",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesdeclast_crypto",
                target_register = "rip",
                role = "performed final vector aes decryption round by vaesdeclast",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vaesdeclast",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesdeclast_vector_crypto_round",
                target_register = "rip",
                role = "performed final vector AES decryption round by vaesdeclast",
            },
        },
    },

}
