-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/crypto/sha.lua
--
-- x86-64 register effects: crypto / sha.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["sha1msg1"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sha1msg1",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha1msg1_crypto",
                target_register = "rip",
                role = "performed sha1 message schedule step by sha1msg1",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sha1msg1",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha1msg1_crypto_message_schedule",
                target_register = "rip",
                role = "computed SHA1 message schedule part by sha1msg1",
            },
        },
    },

    ["sha1msg2"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sha1msg2",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha1msg2_crypto",
                target_register = "rip",
                role = "performed sha1 message schedule step by sha1msg2",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sha1msg2",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha1msg2_crypto_message_schedule",
                target_register = "rip",
                role = "computed SHA1 message schedule part by sha1msg2",
            },
        },
    },

    ["sha1nexte"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sha1nexte",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha1nexte_crypto",
                target_register = "rip",
                role = "performed sha1 next-state step by sha1nexte",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sha1nexte",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha1nexte_crypto_round_assist",
                target_register = "rip",
                role = "computed SHA1 next E round helper by sha1nexte",
            },
        },
    },

    ["sha1rnds4"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sha1rnds4",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "function" },
            },
            effect = {
                kind = "register_write",
                name = "sha1rnds4_crypto",
                target_register = "rip",
                role = "performed four sha1 rounds by sha1rnds4",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sha1rnds4",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "sha1rnds4_crypto_rounds",
                target_register = "rip",
                role = "computed four SHA1 rounds by sha1rnds4",
            },
        },
    },

    ["sha256msg1"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sha256msg1",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha256msg1_crypto",
                target_register = "rip",
                role = "performed sha256 message schedule step by sha256msg1",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sha256msg1",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha256msg1_crypto_message_schedule",
                target_register = "rip",
                role = "computed SHA256 message schedule part by sha256msg1",
            },
        },
    },

    ["sha256msg2"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sha256msg2",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha256msg2_crypto",
                target_register = "rip",
                role = "performed sha256 message schedule step by sha256msg2",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sha256msg2",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha256msg2_crypto_message_schedule",
                target_register = "rip",
                role = "computed SHA256 message schedule part by sha256msg2",
            },
        },
    },

    ["sha256rnds2"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sha256rnds2",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha256rnds2_crypto",
                target_register = "rip",
                role = "performed two sha256 rounds by sha256rnds2",
            },
        },
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sha256rnds2",
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
                name = "sha256rnds2_crypto_rounds",
                target_register = "rip",
                role = "computed two SHA256 rounds by sha256rnds2",
            },
        },
    },

    ["xsha1"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xsha1",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "xsha1_updates_crypto_state",
                target_register = "rip",
                role = "performed hardware sha1 operation by xsha1",
            },
        },
    },

    ["xsha256"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xsha256",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "xsha256_updates_crypto_state",
                target_register = "rip",
                role = "performed hardware sha256 operation by xsha256",
            },
        },
    },

    ["vsha512msg1"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsha512msg1",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vsha512msg1_vector_crypto_message_schedule",
                target_register = "rip",
                role = "computed vector SHA512 message schedule part by vsha512msg1",
            },
        },
    },

    ["vsha512msg2"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsha512msg2",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vsha512msg2_vector_crypto_message_schedule",
                target_register = "rip",
                role = "computed vector SHA512 message schedule part by vsha512msg2",
            },
        },
    },

    ["vsha512rnds2"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsha512rnds2",
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
                name = "vsha512rnds2_vector_crypto_rounds",
                target_register = "rip",
                role = "computed vector SHA512 rounds by vsha512rnds2",
            },
        },
    },

}
