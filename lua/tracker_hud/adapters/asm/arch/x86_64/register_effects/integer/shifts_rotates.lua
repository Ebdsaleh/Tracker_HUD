-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/integer/shifts_rotates.lua
--
-- x86-64 register effects: integer / shifts rotates.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["shl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shl",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "destination",
                        },
                        {
                            index = 2,
                            kind = "integer",
                            role = "shift_count",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "shl_register_immediate",
                        target_operand = 1,
                        role = "shifted left by shl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "shift_count" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "shl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by shl",
                    },
    },
    },

    ["sal"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sal",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "destination",
                        },
                        {
                            index = 2,
                            kind = "integer",
                            role = "shift_count",
                        },
            
                    },
            
            
                    effect = {
                        kind = "register_write",
                        name = "sal_register_immediate",
                        target_operand = 1,
                        role = "arithmetically shifted left by sal",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sal",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "shift_count" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "sal_updates_rflags",
                        target_register = "rflags",
                        role = "updated by sal",
                    },
    },
    },

    ["shr"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shr",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "destination",
                        },
                        {
                            index = 2,
                            kind = "integer",
                            role = "shift_count",
                        },
                    },
            
                    effect = {
                                kind = "register_write",
                                name = "shr_register_immediate",
                                target_operand = 1,
                                role = "logically shifted right by shr",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shr",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "shift_count" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "shr_updates_rflags",
                        target_register = "rflags",
                        role = "updated by shr",
                    },
    },
    },

    ["sar"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sar",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "destination",
                        },
                        {
                            index = 2,
                            kind = "integer",
                            role = "shift_count",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "sar_register_immediate",
                        target_operand = 1,
                        role = "arithmetically shifted right by sar",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sar",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "shift_count" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "sar_updates_rflags",
                        target_register = "rflags",
                        role = "updated by sar",
                    },
    },
    },

    ["rol"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rol",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "destination",
                        },
                        {
                            index = 2,
                            kind = "integer",
                            role = "rotate_count",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "rol_register_immediate",
                        target_operand = 1,
                        role = "rotated left by rol",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rol",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "rotate_count" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "rol_updates_rflags",
                        target_register = "rflags",
                        role = "updated by rol",
                    },
    },
    },

    ["ror"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "ror",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "destination",
                        },
                        {
                            index = 2,
                            kind = "integer",
                            role = "rotate_count",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "ror_register_immediate",
                        target_operand = 1,
                        role = "rotated right by ror",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "ror",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "rotate_count" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "ror_updates_rflags",
                        target_register = "rflags",
                        role = "updated by ror",
                    },
    },
    },

    ["rcl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rcl",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "destination",
                        },
                        {
                            index = 2,
                            kind = "integer",
                            role = "rotate_count",
                        },
                    },
            
            
                    effect = {
                        kind = "register_write",
                        name = "rcl_register_immediate",
                        target_operand = 1,
                        role = "rotate left through carry by rcl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rcl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "rotate_count" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "rcl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by rcl",
                    },
    },
    },

    ["rcr"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rcr",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "destination",
                        },
                        {
                            index = 2,
                            kind = "integer",
                            role = "rotate_count",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "rcr_register_immediate",
                        target_operand = 1,
                        role = "rotated right through carry by rcr",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rcr",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "rotate_count" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "rcr_updates_rflags",
                        target_register = "rflags",
                        role = "updated by rcr",
                    },
    },
    },

    ["shld"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shld",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "shift_count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shld_writes_destination",
                        target_operand = 1,
                        role = "double-precision shifted left by shld",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shld",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "shift_count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shld_updates_rflags",
                        target_register = "rflags",
                        role = "updated by shld",
                    },
    },
    },

    ["shrd"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shrd",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "shift_count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shrd_writes_destination",
                        target_operand = 1,
                        role = "double-precision shifted right by shrd",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shrd",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "shift_count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shrd_updates_rflags",
                        target_register = "rflags",
                        role = "updated by shrd",
                    },
    },
    },

    ["rorx"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rorx",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "rotate_count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rorx_writes_destination",
                        target_operand = 1,
                        role = "written with rotate-right result by rorx",
                    },
    },
    },

    ["shlx"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shlx",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "shift_count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shlx_writes_destination",
                        target_operand = 1,
                        role = "written with variable shift-left result by shlx",
                    },
    },
    },

    ["shrx"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shrx",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "shift_count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shrx_writes_destination",
                        target_operand = 1,
                        role = "written with variable logical shift-right result by shrx",
                    },
    },
    },

    ["sarx"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sarx",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "shift_count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sarx_writes_destination",
                        target_operand = 1,
                        role = "written with variable arithmetic shift-right result by sarx",
                    },
    },
    },

    ["shlb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shlb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shlb_writes_destination",
                        target_operand = 1,
                        role = "shifted byte left by shlb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shlb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shlb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte shift left shlb",
                    },
    },
    },

    ["shlw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shlw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shlw_writes_destination",
                        target_operand = 1,
                        role = "shifted word left by shlw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shlw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shlw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word shift left shlw",
                    },
    },
    },

    ["shll"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shll",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shll_writes_destination",
                        target_operand = 1,
                        role = "shifted long left by shll",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shll",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shll_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long shift left shll",
                    },
    },
    },

    ["shlq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shlq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shlq_writes_destination",
                        target_operand = 1,
                        role = "shifted quadword left by shlq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shlq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shlq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword shift left shlq",
                    },
    },
    },

    ["salb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "salb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "salb_writes_destination",
                        target_operand = 1,
                        role = "arithmetically shifted byte left by salb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "salb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "salb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte arithmetic shift left salb",
                    },
    },
    },

    ["salq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "salq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "salq_writes_destination",
                        target_operand = 1,
                        role = "arithmetically shifted quadword left by salq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "salq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "salq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword arithmetic shift left salq",
                    },
    },
    },

    ["shrb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shrb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shrb_writes_destination",
                        target_operand = 1,
                        role = "logically shifted byte right by shrb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shrb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shrb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte logical shift right shrb",
                    },
    },
    },

    ["shrw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shrw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shrw_writes_destination",
                        target_operand = 1,
                        role = "logically shifted word right by shrw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shrw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shrw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word logical shift right shrw",
                    },
    },
    },

    ["shrl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shrl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shrl_writes_destination",
                        target_operand = 1,
                        role = "logically shifted long right by shrl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shrl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shrl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long logical shift right shrl",
                    },
    },
    },

    ["shrq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shrq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shrq_writes_destination",
                        target_operand = 1,
                        role = "logically shifted quadword right by shrq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shrq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shrq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword logical shift right shrq",
                    },
    },
    },

    ["sarq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sarq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sarq_writes_destination",
                        target_operand = 1,
                        role = "arithmetically shifted quadword right by sarq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sarq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sarq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword arithmetic shift right sarq",
                    },
    },
    },

    ["rolb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rolb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rolb_writes_destination",
                        target_operand = 1,
                        role = "rotated byte left by rolb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rolb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rolb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte rotate left rolb",
                    },
    },
    },

    ["rolq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rolq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rolq_writes_destination",
                        target_operand = 1,
                        role = "rotated quadword left by rolq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rolq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rolq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword rotate left rolq",
                    },
    },
    },

    ["rorb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rorb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rorb_writes_destination",
                        target_operand = 1,
                        role = "rotated byte right by rorb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rorb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rorb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte rotate right rorb",
                    },
    },
    },

    ["rorq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rorq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rorq_writes_destination",
                        target_operand = 1,
                        role = "rotated quadword right by rorq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rorq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rorq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword rotate right rorq",
                    },
    },
    },

    ["rclb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rclb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rclb_writes_destination",
                        target_operand = 1,
                        role = "rotated byte left through carry by rclb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rclb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rclb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte rotate left through carry rclb",
                    },
    },
    },

    ["rclw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rclw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rclw_writes_destination",
                        target_operand = 1,
                        role = "rotated word left through carry by rclw",
                    },
    },
    },

    ["rcll"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rcll",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rcll_writes_destination",
                        target_operand = 1,
                        role = "rotated long left through carry by rcll",
                    },
    },
    },

    ["rclq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rclq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rclq_writes_destination",
                        target_operand = 1,
                        role = "rotated quadword left through carry by rclq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rclq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rclq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword rotate left through carry rclq",
                    },
    },
    },

    ["rcrb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rcrb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rcrb_writes_destination",
                        target_operand = 1,
                        role = "rotated byte right through carry by rcrb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rcrb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rcrb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte rotate right through carry rcrb",
                    },
    },
    },

    ["rcrw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rcrw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rcrw_writes_destination",
                        target_operand = 1,
                        role = "rotated word right through carry by rcrw",
                    },
    },
    },

    ["rcrl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rcrl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rcrl_writes_destination",
                        target_operand = 1,
                        role = "rotated long right through carry by rcrl",
                    },
    },
    },

    ["rcrq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rcrq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rcrq_writes_destination",
                        target_operand = 1,
                        role = "rotated quadword right through carry by rcrq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rcrq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rcrq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword rotate right through carry rcrq",
                    },
    },
    },

    ["salw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "salw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "salw_writes_destination",
                        target_operand = 1,
                        role = "arithmetically shifted word left by salw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "salw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "salw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word arithmetic shift left salw",
                    },
    },
    },

    ["sall"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sall",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sall_writes_destination",
                        target_operand = 1,
                        role = "arithmetically shifted long left by sall",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sall",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sall_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long arithmetic shift left sall",
                    },
    },
    },

    ["sarb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sarb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sarb_writes_destination",
                        target_operand = 1,
                        role = "arithmetically shifted byte right by sarb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sarb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sarb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte arithmetic shift right sarb",
                    },
    },
    },

    ["sarw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sarw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sarw_writes_destination",
                        target_operand = 1,
                        role = "arithmetically shifted word right by sarw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sarw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sarw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word arithmetic shift right sarw",
                    },
    },
    },

    ["sarl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sarl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sarl_writes_destination",
                        target_operand = 1,
                        role = "arithmetically shifted long right by sarl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sarl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sarl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long arithmetic shift right sarl",
                    },
    },
    },

    ["rolw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rolw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rolw_writes_destination",
                        target_operand = 1,
                        role = "rotated word left by rolw",
                    },
    },
    },

    ["roll"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "roll",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "roll_writes_destination",
                        target_operand = 1,
                        role = "rotated long left by roll",
                    },
    },
    },

    ["rorw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rorw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rorw_writes_destination",
                        target_operand = 1,
                        role = "rotated word right by rorw",
                    },
    },
    },

    ["rorl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rorl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rorl_writes_destination",
                        target_operand = 1,
                        role = "rotated long right by rorl",
                    },
    },
    },

    ["shlxl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shlxl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shlxl_writes_destination",
                        target_operand = 1,
                        role = "written with long variable shift-left result by shlxl",
                    },
    },
    },

    ["shlxq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shlxq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shlxq_writes_destination",
                        target_operand = 1,
                        role = "written with quadword variable shift-left result by shlxq",
                    },
    },
    },

    ["shrxl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shrxl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shrxl_writes_destination",
                        target_operand = 1,
                        role = "written with long variable logical shift-right result by shrxl",
                    },
    },
    },

    ["shrxq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "shrxq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "shrxq_writes_destination",
                        target_operand = 1,
                        role = "written with quadword variable logical shift-right result by shrxq",
                    },
    },
    },

    ["sarxl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sarxl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sarxl_writes_destination",
                        target_operand = 1,
                        role = "written with long variable arithmetic shift-right result by sarxl",
                    },
    },
    },

    ["sarxq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sarxq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sarxq_writes_destination",
                        target_operand = 1,
                        role = "written with quadword variable arithmetic shift-right result by sarxq",
                    },
    },
    },

    ["rorxl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rorxl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rorxl_writes_destination",
                        target_operand = 1,
                        role = "written with long rotate-right result by rorxl",
                    },
    },
    },

    ["rorxq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "rorxq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "count" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "rorxq_writes_destination",
                        target_operand = 1,
                        role = "written with quadword rotate-right result by rorxq",
                    },
    },
    },

}

