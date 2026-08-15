-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/string/compare_scan.lua
--
-- x86-64 register effects: string / compare scan.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["scasb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "scasb",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "scasb_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by scasb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "scasb",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "scasb_updates_rflags",
                                target_register = "rflags",
                                role = "updated by scasb",
                            },
        },
    },

    ["scasw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "scasw",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "scasw_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by scasw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "scasw",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "scasw_updates_rflags",
                                target_register = "rflags",
                                role = "updated by scasw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "scasw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "scasw_advances_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by scasw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "scasw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "scasw_updates_rflags",
                                target_register = "rflags",
                                role = "updated by scasw",
                            },
        },
    },

    ["scasd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "scasd",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "scasd_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by scasd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "scasd",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "scasd_updates_rflags",
                                target_register = "rflags",
                                role = "updated by scasd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "scasd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "scasd_advances_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by scasd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "scasd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "scasd_updates_rflags",
                                target_register = "rflags",
                                role = "updated by scasd",
                            },
        },
    },

    ["scasq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "scasq",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "scasq_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by scasq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "scasq",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "scasq_updates_rflags",
                                target_register = "rflags",
                                role = "updated by scasq",
                            },
        },
    },

    ["cmpsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsb",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "cmpsb_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by cmpsb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsb",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "cmpsb_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by cmpsb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsb",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "cmpsb_updates_rflags",
                                target_register = "rflags",
                                role = "updated by cmpsb",
                            },
        },
    },

    ["cmpsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsw",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "cmpsw_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by cmpsw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsw",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "cmpsw_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by cmpsw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsw",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "cmpsw_updates_rflags",
                                target_register = "rflags",
                                role = "updated by cmpsw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "cmpsw_advances_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by cmpsw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "cmpsw_advances_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by cmpsw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "cmpsw_updates_rflags",
                                target_register = "rflags",
                                role = "updated by cmpsw",
                            },
        },
    },

    ["cmpsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsd",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "cmpsd_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by cmpsd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsd",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "cmpsd_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by cmpsd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsd",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "cmpsd_updates_rflags",
                                target_register = "rflags",
                                role = "updated by cmpsd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "cmpsd_advances_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by cmpsd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "cmpsd_advances_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by cmpsd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "cmpsd_updates_rflags",
                                target_register = "rflags",
                                role = "updated by cmpsd",
                            },
        },
    },

    ["cmpsq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsq",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "cmpsq_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by cmpsq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsq",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "cmpsq_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by cmpsq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsq",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "cmpsq_updates_rflags",
                                target_register = "rflags",
                                role = "updated by cmpsq",
                            },
        },
    },

    ["cmps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmps",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "cmps_advances_rsi",
                                target_register = "rsi",
                                role = "advanced by unsuffixed string compare cmps",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmps",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "cmps_advances_rdi",
                                target_register = "rdi",
                                role = "advanced by unsuffixed string compare cmps",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmps",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "cmps_updates_rflags",
                                target_register = "rflags",
                                role = "updated by unsuffixed string compare cmps",
                            },
        },
    },

    ["scas"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "scas",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "scas_advances_rdi",
                                target_register = "rdi",
                                role = "advanced by unsuffixed string scan scas",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "scas",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "scas_updates_rflags",
                                target_register = "rflags",
                                role = "updated by unsuffixed string scan scas",
                            },
        },
    },

}
