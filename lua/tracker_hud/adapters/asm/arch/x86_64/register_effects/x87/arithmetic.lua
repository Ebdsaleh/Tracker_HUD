-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/x87/arithmetic.lua
--
-- x86-64 register effects: x87 / arithmetic.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["fadd"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fadd",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fadd_updates_fpu_stack",
                target_register = "rip",
                role = "updated x87 stack by fadd",
            },
        },
    },

    ["faddp"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "faddp",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "faddp_updates_fpu_stack",
                target_register = "rip",
                role = "updated and popped x87 stack by faddp",
            },
        },
    },

    ["fiadd"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fiadd",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fiadd_updates_fpu_stack",
                target_register = "rip",
                role = "added integer to x87 stack by fiadd",
            },
        },
    },

    ["fsub"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fsub",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fsub_updates_fpu_stack",
                target_register = "rip",
                role = "updated x87 stack by fsub",
            },
        },
    },

    ["fsubp"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fsubp",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fsubp_updates_fpu_stack",
                target_register = "rip",
                role = "updated and popped x87 stack by fsubp",
            },
        },
    },

    ["fisub"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fisub",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fisub_updates_fpu_stack",
                target_register = "rip",
                role = "subtracted integer from x87 stack by fisub",
            },
        },
    },

    ["fisubr"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fisubr",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fisubr_updates_fpu_stack",
                target_register = "rip",
                role = "reverse-subtracted integer with x87 stack by fisubr",
            },
        },
    },

    ["fmul"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fmul",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fmul_updates_fpu_stack",
                target_register = "rip",
                role = "updated x87 stack by fmul",
            },
        },
    },

    ["fmulp"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fmulp",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fmulp_updates_fpu_stack",
                target_register = "rip",
                role = "updated and popped x87 stack by fmulp",
            },
        },
    },

    ["fimul"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fimul",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fimul_updates_fpu_stack",
                target_register = "rip",
                role = "multiplied integer with x87 stack by fimul",
            },
        },
    },

    ["fdiv"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fdiv",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fdiv_updates_fpu_stack",
                target_register = "rip",
                role = "updated x87 stack by fdiv",
            },
        },
    },

    ["fdivp"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fdivp",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fdivp_updates_fpu_stack",
                target_register = "rip",
                role = "updated and popped x87 stack by fdivp",
            },
        },
    },

    ["fidiv"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fidiv",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fidiv_updates_fpu_stack",
                target_register = "rip",
                role = "divided x87 stack by integer with fidiv",
            },
        },
    },

    ["fidivr"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fidivr",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fidivr_updates_fpu_stack",
                target_register = "rip",
                role = "reverse-divided integer with x87 stack by fidivr",
            },
        },
    },

    ["fabs"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fabs",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fabs_updates_fpu_stack",
                target_register = "rip",
                role = "absolute-valued x87 top by fabs",
            },
        },
    },

    ["fchs"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fchs",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fchs_updates_fpu_stack",
                target_register = "rip",
                role = "changed sign of x87 top by fchs",
            },
        },
    },

    ["frndint"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "frndint",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "frndint_updates_fpu_stack",
                target_register = "rip",
                role = "rounded x87 top to integer by frndint",
            },
        },
    },

    ["fsqrt"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fsqrt",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fsqrt_updates_fpu_stack",
                target_register = "rip",
                role = "square-rooted x87 top by fsqrt",
            },
        },
    },

    ["fscale"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fscale",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fscale_updates_fpu_stack",
                target_register = "rip",
                role = "scaled x87 value by fscale",
            },
        },
    },

    ["fprem"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fprem",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fprem_updates_fpu_stack",
                target_register = "rip",
                role = "computed x87 partial remainder by fprem",
            },
        },
    },

    ["fprem1"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fprem1",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fprem1_updates_fpu_stack",
                target_register = "rip",
                role = "computed ieee x87 partial remainder by fprem1",
            },
        },
    },

    ["fyl2x"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fyl2x",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fyl2x_updates_fpu_stack",
                target_register = "rip",
                role = "computed y times log2 x by fyl2x",
            },
        },
    },

    ["fyl2xp1"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fyl2xp1",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fyl2xp1_updates_fpu_stack",
                target_register = "rip",
                role = "computed y times log2 x-plus-one by fyl2xp1",
            },
        },
    },

    ["f2xm1"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "f2xm1",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "f2xm1_updates_fpu_stack",
                target_register = "rip",
                role = "computed two-power-x-minus-one by f2xm1",
            },
        },
    },

    ["fsin"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fsin",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fsin_updates_fpu_stack",
                target_register = "rip",
                role = "computed sine by fsin",
            },
        },
    },

    ["fcos"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fcos",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fcos_updates_fpu_stack",
                target_register = "rip",
                role = "computed cosine by fcos",
            },
        },
    },

    ["fsincos"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fsincos",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fsincos_updates_fpu_stack",
                target_register = "rip",
                role = "computed sine and cosine by fsincos",
            },
        },
    },

    ["fptan"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fptan",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fptan_updates_fpu_stack",
                target_register = "rip",
                role = "computed partial tangent by fptan",
            },
        },
    },

    ["fpatan"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fpatan",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "fpatan_updates_fpu_stack",
                target_register = "rip",
                role = "computed partial arctangent by fpatan",
            },
        },
    },

}
