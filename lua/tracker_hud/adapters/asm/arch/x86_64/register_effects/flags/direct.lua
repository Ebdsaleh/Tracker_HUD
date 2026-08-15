-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/flags/direct.lua
--
-- x86-64 register effects: flags / direct.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["clc"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "clc",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "clc_updates_rflags",
                                target_register = "rflags",
                                role = "carry flag cleared by clc",
                            },
        },
    },

    ["stc"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "stc",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "stc_updates_rflags",
                                target_register = "rflags",
                                role = "carry flag set by stc",
                            },
        },
    },

    ["cmc"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmc",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "cmc_updates_rflags",
                                target_register = "rflags",
                                role = "carry flag complemented by cmc",
                            },
        },
    },

    ["lahf"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lahf",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "lahf_writes_rax_family",
                                target_register = "rax",
                                role = "loaded status flags into ah by lahf",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lahf",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "lahf_writes_rax_alias",
                                target_register = "rax",
                                written_alias = "ah",
                                role = "loaded status flags into ah by lahf",
                            },
        },
    },

    ["sahf"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sahf",
                    },
                },
            },

            operands = {},

                            effect = {
                                kind = "register_write",
                                name = "sahf_updates_rflags",
                                target_register = "rflags",
                                role = "loaded status flags from ah by sahf",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sahf",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "sahf_updates_rflags_alias",
                                target_register = "rflags",
                                role = "loaded status flags from ah by sahf",
                            },
        },
    },

    ["clui"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "clui",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "clui_updates_user_interrupt_state",
                                target_register = "rflags",
                                role = "cleared user interrupt flag by clui",
                            },
        },
    },

    ["stui"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "stui",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "stui_updates_user_interrupt_state",
                                target_register = "rflags",
                                role = "set user interrupt flag by stui",
                            },
        },
    },

    ["testui"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "testui",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "testui_updates_rflags",
                                target_register = "rflags",
                                role = "tested user interrupt flag by testui",
                            },
        },
    },

    ["cld"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cld",
                    },
                },
            },

            operands = {},

                        effect = {
                            kind = "register_write",
                            name = "cld_updates_rflags",
                            target_register = "rflags",
                            role = "direction flag cleared by cld",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cld",
                    },
                },
            },

            operands = {},

                        effect = {
                            kind = "register_write",
                            name = "cld_updates_rflags",
                            target_register = "rflags",
                            role = "direction flag cleared by cld",
                        },
        },
    },

    ["std"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "std",
                    },
                },
            },

            operands = {},

                        effect = {
                            kind = "register_write",
                            name = "std_updates_rflags",
                            target_register = "rflags",
                            role = "direction flag set by std",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "std",
                    },
                },
            },

            operands = {},

                        effect = {
                            kind = "register_write",
                            name = "std_updates_rflags",
                            target_register = "rflags",
                            role = "direction flag set by std",
                        },
        },
    },

    ["cli"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cli",
                    },
                },
            },

            operands = {},

                        effect = {
                            kind = "register_write",
                            name = "cli_updates_rflags",
                            target_register = "rflags",
                            role = "interrupt flag cleared by cli",
                        },
        },
    },

    ["sti"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sti",
                    },
                },
            },

            operands = {},

                        effect = {
                            kind = "register_write",
                            name = "sti_updates_rflags",
                            target_register = "rflags",
                            role = "interrupt flag set by sti",
                        },
        },
    },

    ["clac"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "clac",
                    },
                },
            },

            operands = {},

                        effect = {
                            kind = "register_write",
                            name = "clac_updates_rflags",
                            target_register = "rflags",
                            role = "access-control flag cleared by clac",
                        },
        },
    },

    ["stac"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "stac",
                    },
                },
            },

            operands = {},

                        effect = {
                            kind = "register_write",
                            name = "stac_updates_rflags",
                            target_register = "rflags",
                            role = "access-control flag set by stac",
                        },
        },
    },

}
