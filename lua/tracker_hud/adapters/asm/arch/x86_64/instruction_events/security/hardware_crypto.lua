-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/security/hardware_crypto.lua
--
-- x86-64 instruction events: security / hardware crypto.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["xstore"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xstore",
                    },
                },
            },

            kind = "security_event",
            category = "hardware_crypto",
            name = "xstore",
            role = "stores hardware-generated random bytes",

            operands = {
            },

            event = {
                name = "xstore_stores_hardware_random_bytes",
                display_name = "xstore",
                role = "stores hardware-generated random bytes",
            },

            effect = {
                kind = "hardware_random_operation",
                name = "xstore_stores_hardware_random_bytes",
                role = "stores hardware-generated random bytes",
            },
        },
    },

    ["xcryptecb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xcryptecb",
                    },
                },
            },

            kind = "security_event",
            category = "hardware_crypto",
            name = "xcryptecb",
            role = "performs a hardware AES ECB operation",

            operands = {
            },

            event = {
                name = "xcryptecb_hardware_aes_ecb",
                display_name = "xcryptecb",
                role = "performs a hardware AES ECB operation",
            },

            effect = {
                kind = "hardware_crypto_operation",
                name = "xcryptecb_hardware_aes_ecb",
                role = "performs a hardware AES ECB operation",
            },
        },
    },

    ["xcryptcbc"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xcryptcbc",
                    },
                },
            },

            kind = "security_event",
            category = "hardware_crypto",
            name = "xcryptcbc",
            role = "performs a hardware AES CBC operation",

            operands = {
            },

            event = {
                name = "xcryptcbc_hardware_aes_cbc",
                display_name = "xcryptcbc",
                role = "performs a hardware AES CBC operation",
            },

            effect = {
                kind = "hardware_crypto_operation",
                name = "xcryptcbc_hardware_aes_cbc",
                role = "performs a hardware AES CBC operation",
            },
        },
    },

    ["xcryptcfb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xcryptcfb",
                    },
                },
            },

            kind = "security_event",
            category = "hardware_crypto",
            name = "xcryptcfb",
            role = "performs a hardware AES CFB operation",

            operands = {
            },

            event = {
                name = "xcryptcfb_hardware_aes_cfb",
                display_name = "xcryptcfb",
                role = "performs a hardware AES CFB operation",
            },

            effect = {
                kind = "hardware_crypto_operation",
                name = "xcryptcfb_hardware_aes_cfb",
                role = "performs a hardware AES CFB operation",
            },
        },
    },

    ["xcryptofb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xcryptofb",
                    },
                },
            },

            kind = "security_event",
            category = "hardware_crypto",
            name = "xcryptofb",
            role = "performs a hardware AES OFB operation",

            operands = {
            },

            event = {
                name = "xcryptofb_hardware_aes_ofb",
                display_name = "xcryptofb",
                role = "performs a hardware AES OFB operation",
            },

            effect = {
                kind = "hardware_crypto_operation",
                name = "xcryptofb_hardware_aes_ofb",
                role = "performs a hardware AES OFB operation",
            },
        },
    },

    ["xcryptctr"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xcryptctr",
                    },
                },
            },

            kind = "security_event",
            category = "hardware_crypto",
            name = "xcryptctr",
            role = "performs a hardware AES CTR operation",

            operands = {
            },

            event = {
                name = "xcryptctr_hardware_aes_ctr",
                display_name = "xcryptctr",
                role = "performs a hardware AES CTR operation",
            },

            effect = {
                kind = "hardware_crypto_operation",
                name = "xcryptctr_hardware_aes_ctr",
                role = "performs a hardware AES CTR operation",
            },
        },
    },

    ["montmul"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "montmul",
                    },
                },
            },

            kind = "security_event",
            category = "hardware_crypto",
            name = "montmul",
            role = "performs a hardware Montgomery multiplication",

            operands = {
            },

            event = {
                name = "montmul_hardware_montgomery_multiply",
                display_name = "montmul",
                role = "performs a hardware Montgomery multiplication",
            },

            effect = {
                kind = "hardware_crypto_operation",
                name = "montmul_hardware_montgomery_multiply",
                role = "performs a hardware Montgomery multiplication",
            },
        },
    },
}

