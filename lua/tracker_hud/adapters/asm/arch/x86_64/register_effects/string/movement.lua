-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/string/movement.lua
--
-- x86-64 register effects: string / movement.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["movsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movsb",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "movsb_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by movsb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movsb",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "movsb_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by movsb",
                            },
        },
    },

    ["movsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movsw",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "movsw_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by movsw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movsw",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "movsw_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by movsw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movsw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "movsw_advances_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by movsw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movsw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "movsw_advances_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by movsw",
                            },
        },
    },

    ["movsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movsd",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "movsd_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by movsd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movsd",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "movsd_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by movsd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movsd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "movsd_advances_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by movsd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movsd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "movsd_advances_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by movsd",
                            },
        },
    },

    ["movsq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movsq",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "movsq_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by movsq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movsq",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "movsq_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by movsq",
                            },
        },
    },

    ["stosb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "stosb",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "stosb_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by stosb",
                            },
        },
    },

    ["stosw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "stosw",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "stosw_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by stosw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "stosw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "stosw_advances_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by stosw",
                            },
        },
    },

    ["stosd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "stosd",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "stosd_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by stosd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "stosd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "stosd_advances_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by stosd",
                            },
        },
    },

    ["stosq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "stosq",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "stosq_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by stosq",
                            },
        },
    },

    ["lodsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lodsb",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "lodsb_writes_rax",
                                target_register = "rax",
                                role = "loaded byte into al by lodsb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lodsb",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "lodsb_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by lodsb",
                            },
        },
    },

    ["lodsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lodsw",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "lodsw_writes_rax",
                                target_register = "rax",
                                role = "loaded word into ax by lodsw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lodsw",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "lodsw_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by lodsw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lodsw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "lodsw_writes_rax",
                                target_register = "rax",
                                role = "loaded word into ax by lodsw",
                                written_alias = "ax",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lodsw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "lodsw_advances_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by lodsw",
                            },
        },
    },

    ["lodsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lodsd",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "lodsd_writes_rax",
                                target_register = "rax",
                                role = "loaded dword into eax by lodsd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lodsd",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "lodsd_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by lodsd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lodsd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "lodsd_writes_rax",
                                target_register = "rax",
                                role = "loaded doubleword into eax by lodsd",
                                written_alias = "eax",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lodsd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "lodsd_advances_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by lodsd",
                            },
        },
    },

    ["lodsq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lodsq",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "lodsq_writes_rax",
                                target_register = "rax",
                                role = "loaded qword into rax by lodsq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lodsq",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "lodsq_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by lodsq",
                            },
        },
    },

    ["movs"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movs",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "movs_advances_rsi",
                                target_register = "rsi",
                                role = "advanced by unsuffixed string move movs",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movs",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "movs_advances_rdi",
                                target_register = "rdi",
                                role = "advanced by unsuffixed string move movs",
                            },
        },
    },

    ["lods"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lods",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "lods_writes_rax",
                                target_register = "rax",
                                role = "loaded by unsuffixed string load lods",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lods",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "lods_advances_rsi",
                                target_register = "rsi",
                                role = "advanced by unsuffixed string load lods",
                            },
        },
    },

    ["stos"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "stos",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "stos_advances_rdi",
                                target_register = "rdi",
                                role = "advanced by unsuffixed string store stos",
                            },
        },
    },

}
