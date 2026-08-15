-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/x87/control_state.lua
--
-- x86-64 register effects: x87 / control state.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["fstsw"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fstsw",
                    },
                },
            },
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fstsw_writes_register",
                target_operand = 1,
                role = "written with x87 status word by fstsw",
            },
        },
    },

    ["fnstsw"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fnstsw",
                    },
                },
            },
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fnstsw_writes_register",
                target_operand = 1,
                role = "written with x87 status word by fnstsw",
            },
        },
    },

    ["fstcw"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fstcw",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fstcw_stores_control_word",
                target_register = "rip",
                role = "stored x87 control word by fstcw",
            },
        },
    },

    ["fnstcw"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fnstcw",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fnstcw_stores_control_word",
                target_register = "rip",
                role = "stored x87 control word by fnstcw",
            },
        },
    },

    ["fldcw"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fldcw",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fldcw_loads_control_word",
                target_register = "rip",
                role = "loaded x87 control word by fldcw",
            },
        },
    },

    ["fsave"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fsave",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fsave_stores_fpu_state",
                target_register = "rip",
                role = "saved x87 fpu state by fsave",
            },
        },
    },

    ["fnsave"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fnsave",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fnsave_stores_fpu_state",
                target_register = "rip",
                role = "saved x87 fpu state by fnsave",
            },
        },
    },

    ["frstor"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "frstor",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "frstor_restores_fpu_state",
                target_register = "rip",
                role = "restored x87 fpu state by frstor",
            },
        },
    },

    ["fstenv"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fstenv",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fstenv_stores_fpu_environment",
                target_register = "rip",
                role = "stored x87 environment by fstenv",
            },
        },
    },

    ["fnstenv"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fnstenv",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fnstenv_stores_fpu_environment",
                target_register = "rip",
                role = "stored x87 environment by fnstenv",
            },
        },
    },

    ["fldenv"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fldenv",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fldenv_loads_fpu_environment",
                target_register = "rip",
                role = "loaded x87 environment by fldenv",
            },
        },
    },

}
