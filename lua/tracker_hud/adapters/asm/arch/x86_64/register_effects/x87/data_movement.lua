-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/x87/data_movement.lua
--
-- x86-64 register effects: x87 / data movement.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["fld"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fld",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fld_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 value by fld",
            },
        },
    },

    ["fst"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fst",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fst_updates_fpu_stack",
                target_register = "rip",
                role = "stored x87 value by fst",
            },
        },
    },

    ["fstp"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fstp",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fstp_updates_fpu_stack",
                target_register = "rip",
                role = "stored and popped x87 value by fstp",
            },
        },
    },

    ["fild"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fild",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fild_updates_fpu_stack",
                target_register = "rip",
                role = "loaded integer into x87 stack by fild",
            },
        },
    },

    ["fist"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fist",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fist_updates_fpu_stack",
                target_register = "rip",
                role = "stored integer from x87 stack by fist",
            },
        },
    },

    ["fistp"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fistp",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fistp_updates_fpu_stack",
                target_register = "rip",
                role = "stored integer and popped x87 stack by fistp",
            },
        },
    },

    ["fisttp"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fisttp",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fisttp_updates_fpu_stack",
                target_register = "rip",
                role = "stored truncated integer and popped x87 stack by fisttp",
            },
        },
    },

    ["fbld"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fbld",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fbld_updates_fpu_stack",
                target_register = "rip",
                role = "loaded bcd value into x87 stack by fbld",
            },
        },
    },

    ["fbstp"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fbstp",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fbstp_updates_fpu_stack",
                target_register = "rip",
                role = "stored bcd value and popped x87 stack by fbstp",
            },
        },
    },

    ["fxch"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fxch",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fxch_updates_fpu_stack",
                target_register = "rip",
                role = "exchanged x87 stack registers by fxch",
            },
        },
    },

    ["fld1"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fld1",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fld1_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 constant one by fld1",
            },
        },
    },

    ["fldz"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fldz",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fldz_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 constant zero by fldz",
            },
        },
    },

    ["fldpi"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fldpi",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fldpi_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 constant pi by fldpi",
            },
        },
    },

    ["fldl2e"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fldl2e",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fldl2e_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 constant log2 e by fldl2e",
            },
        },
    },

    ["fldl2t"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fldl2t",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fldl2t_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 constant log2 ten by fldl2t",
            },
        },
    },

    ["fldlg2"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fldlg2",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fldlg2_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 constant log10 two by fldlg2",
            },
        },
    },

    ["fldln2"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fldln2",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fldln2_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 constant ln two by fldln2",
            },
        },
    },

}
