-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/integer/data_movement.lua
--
-- x86-64 register effects: integer / data movement.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["mov"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mov",
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
                            role = "source_value",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "mov_register_immediate",
                        target_operand = 1,
                        value_operand = 2,
                        role = "written by mov",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mov",
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
                            kind = "register",
                            role = "source_register",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "mov_register_register",
                        target_operand = 1,
                        value_from_register_operand = 2,
                        role = "copied from register",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mov",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "frame_pointer",
                            value = "rbp",
                        },
                        {
                            index = 2,
                            kind = "register",
                            role = "stack_pointer",
                            value = "rsp",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "mov_rbp_rsp_frame_base",
                        target_operand = 1,
                        value_from_register_operand = 2,
                        role = "established frame base from rsp",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mov",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "stack_pointer",
                            value = "rsp",
                        },
                        {
                            index = 2,
                            kind = "register",
                            role = "frame_pointer",
                            value = "rbp",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "mov_rsp_rbp_restore_stack",
                        target_operand = 1,
                        value_from_register_operand = 2,
                        role = "restored stack pointer from frame base",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mov",
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
                            kind = "symbol",
                            role = "source_symbol",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "mov_register_symbol",
                        target_operand = 1,
                        value_operand = 2,
                        role = "loaded symbol by mov",
                    },
    },
    },

    ["movzx"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movzx",
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
                            kind = "register",
                            role = "source_register",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "movzx_register_register",
                        target_operand = 1,
                        role = "zero-extended from register by movzx",
                    },
    },
    },

    ["movsx"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movsx",
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
                            kind = "register",
                            role = "source_register",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "movsx_register_register",
                        target_operand = 1,
                        role = "sign-extended from register by movsx",
                    },
    },
    },

    ["movsxd"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movsxd",
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
                            kind = "register",
                            role = "source_register",
                        },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movsxd_register_register",
                        target_operand = 1,
                        role = "sign-extended dword from register by movsxd",
                    },
    },
    },

    ["xchg"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xchg",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "left",
                        },
                        {
                            index = 2,
                            kind = "register",
                            role = "right",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "xchg_register_register_left",
                        target_operand = 1,
                        role = "swapped with register by xchg",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xchg",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "left",
                        },
                        {
                            index = 2,
                            kind = "register",
                            role = "right",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "xchg_register_register_right",
                        target_operand = 2,
                        role = "swapped with register by xchg",
                    },
    },
    },

    ["movdiri"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movdiri",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movdiri_direct_store",
                        target_register = "rip",
                        role = "direct-stored integer value by movdiri",
                    },
    },
    },

    ["movdir64b"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movdir64b",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movdir64b_direct_store",
                        target_register = "rip",
                        role = "direct-stored 64-byte value by movdir64b",
                    },
    },
    },

    ["movsxw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movsxw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movsxw_writes_destination",
                        target_operand = 1,
                        role = "written with sign-extended word by movsxw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movsxw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movsxw_writes_destination",
                        target_operand = 1,
                        source_operand = 2,
                        role = "written with sign-extended word by movsxw",
                    },
    },
    },

    ["movsxb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movsxb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movsxb_writes_destination",
                        target_operand = 1,
                        role = "written with sign-extended byte by movsxb",
                    },
    },
    },

    ["movzxw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movzxw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movzxw_writes_destination",
                        target_operand = 1,
                        role = "written with zero-extended word by movzxw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movzxw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movzxw_writes_destination",
                        target_operand = 1,
                        source_operand = 2,
                        role = "written with zero-extended word by movzxw",
                    },
    },
    },

    ["movzxb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movzxb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movzxb_writes_destination",
                        target_operand = 1,
                        role = "written with zero-extended byte by movzxb",
                    },
    },
    },

    ["movabs"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movabs",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movabs_writes_destination",
                        target_operand = 1,
                        source_operand = 2,
                        role = "written with absolute move by movabs",
                    },
    },
    },

    ["movb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movb_writes_destination",
                        target_operand = 1,
                        source_operand = 2,
                        written_alias = "byte",
                        role = "written by byte move movb",
                    },
    },
    },

    ["movw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movw_writes_destination",
                        target_operand = 1,
                        source_operand = 2,
                        written_alias = "word",
                        role = "written by word move movw",
                    },
    },
    },

    ["movl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movl_writes_destination",
                        target_operand = 1,
                        source_operand = 2,
                        written_alias = "dword",
                        role = "written by long move movl",
                    },
    },
    },

    ["movq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movq_writes_destination",
                        target_operand = 1,
                        source_operand = 2,
                        written_alias = "qword",
                        role = "written by quadword move movq",
                    },
    },
    },

    ["movbe"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movbe",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movbe_writes_destination",
                        target_operand = 1,
                        role = "written with byte-swapped value by movbe",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movbe",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movbe_stores_byteswapped_source",
                        target_register = "rip",
                        role = "stored byte-swapped register value by movbe",
                    },
    },
    },

    ["xchgb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xchgb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "left" },
                        { index = 2, kind = "register", role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xchgb_writes_left",
                        target_operand = 1,
                        role = "swapped byte value with register by xchgb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xchgb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "left" },
                        { index = 2, kind = "register", role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xchgb_writes_right",
                        target_operand = 2,
                        role = "swapped byte value with register by xchgb",
                    },
    },
    },

    ["xchgw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xchgw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "left" },
                        { index = 2, kind = "register", role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xchgw_writes_left",
                        target_operand = 1,
                        role = "swapped word value with register by xchgw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xchgw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "left" },
                        { index = 2, kind = "register", role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xchgw_writes_right",
                        target_operand = 2,
                        role = "swapped word value with register by xchgw",
                    },
    },
    },

    ["xchgl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xchgl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "left" },
                        { index = 2, kind = "register", role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xchgl_writes_left",
                        target_operand = 1,
                        role = "swapped long value with register by xchgl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xchgl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "left" },
                        { index = 2, kind = "register", role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xchgl_writes_right",
                        target_operand = 2,
                        role = "swapped long value with register by xchgl",
                    },
    },
    },

    ["xchgq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xchgq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "left" },
                        { index = 2, kind = "register", role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xchgq_writes_left",
                        target_operand = 1,
                        role = "swapped quadword value with register by xchgq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xchgq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "left" },
                        { index = 2, kind = "register", role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xchgq_writes_right",
                        target_operand = 2,
                        role = "swapped quadword value with register by xchgq",
                    },
    },
    },

    ["movsbw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movsbw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "source" },
                        { index = 2, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movsbw_writes_destination",
                        target_operand = 2,
                        source_operand = 1,
                        role = "written with sign-extended byte to word by movsbw",
                    },
    },
    },

    ["movsbl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movsbl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "source" },
                        { index = 2, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movsbl_writes_destination",
                        target_operand = 2,
                        source_operand = 1,
                        role = "written with sign-extended byte to long by movsbl",
                    },
    },
    },

    ["movsbq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movsbq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "source" },
                        { index = 2, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movsbq_writes_destination",
                        target_operand = 2,
                        source_operand = 1,
                        role = "written with sign-extended byte to quadword by movsbq",
                    },
    },
    },

    ["movswl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movswl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "source" },
                        { index = 2, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movswl_writes_destination",
                        target_operand = 2,
                        source_operand = 1,
                        role = "written with sign-extended word to long by movswl",
                    },
    },
    },

    ["movswq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movswq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "source" },
                        { index = 2, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movswq_writes_destination",
                        target_operand = 2,
                        source_operand = 1,
                        role = "written with sign-extended word to quadword by movswq",
                    },
    },
    },

    ["movslq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movslq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "source" },
                        { index = 2, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movslq_writes_destination",
                        target_operand = 2,
                        source_operand = 1,
                        role = "written with sign-extended long to quadword by movslq",
                    },
    },
    },

    ["movsxl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movsxl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movsxl_writes_destination",
                        target_operand = 1,
                        source_operand = 2,
                        role = "written with sign-extended long by movsxl",
                    },
    },
    },

    ["movsxq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movsxq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movsxq_writes_destination",
                        target_operand = 1,
                        source_operand = 2,
                        role = "written with sign-extended quadword by movsxq",
                    },
    },
    },

    ["movzbw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movzbw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "source" },
                        { index = 2, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movzbw_writes_destination",
                        target_operand = 2,
                        source_operand = 1,
                        role = "written with zero-extended byte to word by movzbw",
                    },
    },
    },

    ["movzbl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movzbl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "source" },
                        { index = 2, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movzbl_writes_destination",
                        target_operand = 2,
                        source_operand = 1,
                        role = "written with zero-extended byte to long by movzbl",
                    },
    },
    },

    ["movzbq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movzbq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "source" },
                        { index = 2, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movzbq_writes_destination",
                        target_operand = 2,
                        source_operand = 1,
                        role = "written with zero-extended byte to quadword by movzbq",
                    },
    },
    },

    ["movzwl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movzwl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "source" },
                        { index = 2, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movzwl_writes_destination",
                        target_operand = 2,
                        source_operand = 1,
                        role = "written with zero-extended word to long by movzwl",
                    },
    },
    },

    ["movzwq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movzwq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "source" },
                        { index = 2, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movzwq_writes_destination",
                        target_operand = 2,
                        source_operand = 1,
                        role = "written with zero-extended word to quadword by movzwq",
                    },
    },
    },

    ["movzxl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movzxl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movzxl_writes_destination",
                        target_operand = 1,
                        source_operand = 2,
                        role = "written with zero-extended long by movzxl",
                    },
    },
    },

    ["movzxq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "movzxq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movzxq_writes_destination",
                        target_operand = 1,
                        source_operand = 2,
                        role = "written with zero-extended quadword by movzxq",
                    },
    },
    },

    ["lea"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "lea",
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
                            kind = "symbol",
                            role = "source_address",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "lea_register_symbol",
                        target_operand = 1,
                        value_operand = 2,
                        role = "loaded address by lea",
                    },
    },
    },

    ["cbw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cbw",
                },
            },
        },

        operands = {},
            
                    effect = {
                        kind = "register_write",
                        name = "cbw_writes_rax_family",
                        target_register = "rax",
                        role = "sign-extended al into ax by cbw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cbw",
                },
            },
        },

        operands = {},
                    effect = {
                        kind = "register_write",
                        name = "cbw_writes_rax",
                        target_register = "rax",
                        role = "sign-extended byte accumulator to word by cbw",
                    },
    },
    },

    ["cwde"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cwde",
                },
            },
        },

        operands = {},
            
                    effect = {
                        kind = "register_write",
                        name = "cwde_writes_rax_family",
                        target_register = "rax",
                        role = "sign-extended ax into eax by cwde",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cwde",
                },
            },
        },

        operands = {},
                    effect = {
                        kind = "register_write",
                        name = "cwde_writes_rax",
                        target_register = "rax",
                        role = "sign-extended word accumulator to doubleword by cwde",
                    },
    },
    },

    ["cdqe"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cdqe",
                },
            },
        },

        operands = {},
            
                    effect = {
                        kind = "register_write",
                        name = "cdqe_writes_rax",
                        target_register = "rax",
                        role = "sign-extended eax into rax by cdqe",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cdqe",
                },
            },
        },

        operands = {},
                    effect = {
                        kind = "register_write",
                        name = "cdqe_writes_rax",
                        target_register = "rax",
                        role = "sign-extended doubleword accumulator to quadword by cdqe",
                    },
    },
    },

    ["cwd"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cwd",
                },
            },
        },

        operands = {},
            
                    effect = {
                        kind = "register_write",
                        name = "cwd_writes_rdx_family",
                        target_register = "rdx",
                        role = "sign-extended ax into dx by cwd",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cwd",
                },
            },
        },

        operands = {},
                    effect = {
                        kind = "register_write",
                        name = "cwd_writes_rdx",
                        target_register = "rdx",
                        role = "sign-extended word accumulator into dx by cwd",
                    },
    },
    },

    ["cdq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cdq",
                },
            },
        },

        operands = {},
            
                    effect = {
                        kind = "register_write",
                        name = "cdq_writes_rdx_family",
                        target_register = "rdx",
                        role = "sign-extended eax into edx by cdq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cdq",
                },
            },
        },

        operands = {},
                    effect = {
                        kind = "register_write",
                        name = "cdq_writes_rdx",
                        target_register = "rdx",
                        role = "sign-extended doubleword accumulator into edx by cdq",
                    },
    },
    },

    ["cqo"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cqo",
                },
            },
        },

        operands = {},
            
                    effect = {
                        kind = "register_write",
                        name = "cqo_writes_rdx",
                        target_register = "rdx",
                        role = "sign-extended rax into rdx by cqo",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cqo",
                },
            },
        },

        operands = {},
                    effect = {
                        kind = "register_write",
                        name = "cqo_writes_rdx",
                        target_register = "rdx",
                        role = "sign-extended quadword accumulator into rdx by cqo",
                    },
    },
    },

    ["cbtw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cbtw",
                },
            },
        },

        operands = {},
                    effect = {
                        kind = "register_write",
                        name = "cbtw_writes_rax",
                        target_register = "rax",
                        role = "sign-extended byte accumulator to word by cbtw",
                    },
    },
    },

    ["cwtl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cwtl",
                },
            },
        },

        operands = {},
                    effect = {
                        kind = "register_write",
                        name = "cwtl_writes_rax",
                        target_register = "rax",
                        role = "sign-extended word accumulator to long by cwtl",
                    },
    },
    },

    ["cltq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cltq",
                },
            },
        },

        operands = {},
                    effect = {
                        kind = "register_write",
                        name = "cltq_writes_rax",
                        target_register = "rax",
                        role = "sign-extended long accumulator to quadword by cltq",
                    },
    },
    },

    ["cwtd"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cwtd",
                },
            },
        },

        operands = {},
                    effect = {
                        kind = "register_write",
                        name = "cwtd_writes_rdx",
                        target_register = "rdx",
                        role = "sign-extended word accumulator into dx by cwtd",
                    },
    },
    },

    ["cltd"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cltd",
                },
            },
        },

        operands = {},
                    effect = {
                        kind = "register_write",
                        name = "cltd_writes_rdx",
                        target_register = "rdx",
                        role = "sign-extended long accumulator into edx by cltd",
                    },
    },
    },

    ["cqto"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cqto",
                },
            },
        },

        operands = {},
                    effect = {
                        kind = "register_write",
                        name = "cqto_writes_rdx",
                        target_register = "rdx",
                        role = "sign-extended quadword accumulator into rdx by cqto",
                    },
    },
    },

    ["xlat"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xlat",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "xlat_writes_rax",
                target_register = "rax",
                written_alias = "al",
                role = "loaded translated byte into al by xlat",
            },
        },
    },

    ["xlatb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xlatb",
                    },
                },
            },

            operands = {},

            effect = {
                kind = "register_write",
                name = "xlatb_writes_rax",
                target_register = "rax",
                role = "loaded translated byte into al by xlatb",
            },
        },
    },

}
