-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/string/io.lua
--
-- x86-64 register effects: string / I/O.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["outsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "outsb",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "outsb_updates_rsi",
                                target_register = "rsi",
                                role = "advanced by outsb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "outsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "outsb_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by byte output string outsb",
                            },
        },
    },

    ["outsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "outsw",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "outsw_updates_rsi",
                                target_register = "rsi",
                                role = "advanced by outsw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "outsw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "outsw_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by word output string outsw",
                            },
        },
    },

    ["outsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "outsd",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "outsd_updates_rsi",
                                target_register = "rsi",
                                role = "advanced by outsd",
                            },
        },
    },

    ["insb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "insb",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "insb_updates_rdi",
                                target_register = "rdi",
                                role = "advanced by insb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "insb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "insb_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by byte input string insb",
                            },
        },
    },

    ["insw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "insw",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "insw_updates_rdi",
                                target_register = "rdi",
                                role = "advanced by insw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "insw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "insw_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by word input string insw",
                            },
        },
    },

    ["insd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "insd",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "insd_updates_rdi",
                                target_register = "rdi",
                                role = "advanced by insd",
                            },
        },
    },

    ["ins"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ins",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "ins_advances_rdi",
                                target_register = "rdi",
                                role = "advanced by unsuffixed port input string ins",
                            },
        },
    },

    ["outs"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "outs",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "outs_advances_rsi",
                                target_register = "rsi",
                                role = "advanced by unsuffixed port output string outs",
                            },
        },
    },

    ["insl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "insl",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "insl_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by long input string insl",
                            },
        },
    },

    ["insq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "insq",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "insq_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by quadword input string insq",
                            },
        },
    },

    ["outsl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "outsl",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "outsl_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by long output string outsl",
                            },
        },
    },

    ["outsq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "outsq",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "outsq_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by quadword output string outsq",
                            },
        },
    },

}
