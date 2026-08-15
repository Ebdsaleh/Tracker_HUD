-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/x87/compare.lua
--
-- x86-64 register effects: x87 / compare.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["fcom"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fcom",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fcom_updates_fpu_status",
                target_register = "rip",
                role = "compared x87 values by fcom",
            },
        },
    },

    ["fcomp"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fcomp",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fcomp_updates_fpu_status",
                target_register = "rip",
                role = "compared and popped x87 value by fcomp",
            },
        },
    },

    ["fcompp"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fcompp",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fcompp_updates_fpu_status",
                target_register = "rip",
                role = "compared and popped two x87 values by fcompp",
            },
        },
    },

    ["fucom"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fucom",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fucom_updates_fpu_status",
                target_register = "rip",
                role = "unordered-compared x87 values by fucom",
            },
        },
    },

    ["fucomp"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fucomp",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fucomp_updates_fpu_status",
                target_register = "rip",
                role = "unordered-compared and popped x87 value by fucomp",
            },
        },
    },

    ["fucompp"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fucompp",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fucompp_updates_fpu_status",
                target_register = "rip",
                role = "unordered-compared and popped two x87 values by fucompp",
            },
        },
    },

    ["fcomi"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fcomi",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fcomi_updates_rflags",
                target_register = "rflags",
                role = "updated by x87 compare fcomi",
            },
        },
    },

    ["fcomip"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fcomip",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fcomip_updates_rflags",
                target_register = "rflags",
                role = "updated by x87 compare-and-pop fcomip",
            },
        },
    },

    ["fucomi"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fucomi",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fucomi_updates_rflags",
                target_register = "rflags",
                role = "updated by unordered x87 compare fucomi",
            },
        },
    },

    ["fucomip"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fucomip",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fucomip_updates_rflags",
                target_register = "rflags",
                role = "updated by unordered x87 compare-and-pop fucomip",
            },
        },
    },

    ["ftst"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ftst",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "ftst_updates_fpu_status",
                target_register = "rip",
                role = "tested x87 value against zero by ftst",
            },
        },
    },

    ["fxam"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fxam",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fxam_updates_fpu_status",
                target_register = "rip",
                role = "examined x87 value by fxam",
            },
        },
    },

}
