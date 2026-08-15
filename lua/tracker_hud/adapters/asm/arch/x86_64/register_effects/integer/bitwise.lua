-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/integer/bitwise.lua
--
-- x86-64 register effects: integer / bitwise.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["not"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "not",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "destination",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "not_register",
                        target_operand = 1,
                        role = "bitwise inverted by not",
                    },
    },
    },

    ["and"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "and",
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
                            role = "mask_register",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "and_register_register",
                        target_operand = 1,
                        role = "bitwise-and mutated by register",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "and",
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
                            role = "mask",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "and_register_immediate",
                        target_operand = 1,
                        role = "bitwise-and mutated by immediate",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "and",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "and_updates_rflags",
                        target_register = "rflags",
                        role = "updated by and",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "and",
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
                            role = "mask",
                            value = "0",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "and_register_zero",
                        target_operand = 1,
                        value = "0",
                        role = "zeroed by and",
                    },
    },
    },

    ["or"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "or",
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
                        name = "or_register_register",
                        target_operand = 1,
                        role = "bitwise-or mutated by register",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "or",
                },
            },
        },

        operands =
                    {
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
                        name = "or_register_immediate",
                        target_operand = 1,
                        role = "bitwise-or mutated by immediate",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "or",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "or_updates_rflags",
                        target_register = "rflags",
                        role = "updated by or",
                    },
    },
    },

    ["xor"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xor",
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
                        name = "xor_register_register",
                        target_operand = 1,
                        role = "bitwise-xor mutated by register",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xor",
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
                        name = "xor_register_immediate",
                        target_operand = 1,
                        role = "bitwise-xor mutated by immediate",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xor",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "xor_updates_rflags",
                        target_register = "rflags",
                        role = "updated by xor",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xor",
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
                            role = "source",
                        },
                    },
            
                    condition = {
                        operands_equal = { 1, 2 },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "xor_register_self_zero",
                        target_operand = 1,
                        value = "0",
                        role = "zeroed by xor",
                    },
    },
    },

    ["andb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "andb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "andb_writes_destination",
                        target_operand = 1,
                        role = "bitwise-and byte source by andb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "andb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "andb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte bitwise-and andb",
                    },
    },
    },

    ["andw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "andw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "andw_writes_destination",
                        target_operand = 1,
                        role = "bitwise-and word source by andw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "andw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "andw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word bitwise-and andw",
                    },
    },
    },

    ["andl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "andl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "andl_writes_destination",
                        target_operand = 1,
                        role = "bitwise-and long source by andl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "andl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "andl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long bitwise-and andl",
                    },
    },
    },

    ["andq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "andq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "andq_writes_destination",
                        target_operand = 1,
                        role = "bitwise-and quadword source by andq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "andq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "andq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword bitwise-and andq",
                    },
    },
    },

    ["orb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "orb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "orb_writes_destination",
                        target_operand = 1,
                        role = "bitwise-or byte source by orb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "orb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "orb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte bitwise-or orb",
                    },
    },
    },

    ["orw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "orw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "orw_writes_destination",
                        target_operand = 1,
                        role = "bitwise-or word source by orw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "orw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "orw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word bitwise-or orw",
                    },
    },
    },

    ["orl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "orl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "orl_writes_destination",
                        target_operand = 1,
                        role = "bitwise-or long source by orl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "orl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "orl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long bitwise-or orl",
                    },
    },
    },

    ["orq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "orq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "orq_writes_destination",
                        target_operand = 1,
                        role = "bitwise-or quadword source by orq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "orq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "orq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword bitwise-or orq",
                    },
    },
    },

    ["xorb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xorb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xorb_writes_destination",
                        target_operand = 1,
                        role = "bitwise-xor byte source by xorb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xorb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xorb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte bitwise-xor xorb",
                    },
    },
    },

    ["xorw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xorw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xorw_writes_destination",
                        target_operand = 1,
                        role = "bitwise-xor word source by xorw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xorw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xorw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word bitwise-xor xorw",
                    },
    },
    },

    ["xorl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xorl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xorl_writes_destination",
                        target_operand = 1,
                        role = "bitwise-xor long source by xorl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xorl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xorl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long bitwise-xor xorl",
                    },
    },
    },

    ["xorq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xorq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xorq_writes_destination",
                        target_operand = 1,
                        role = "bitwise-xor quadword source by xorq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xorq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xorq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword bitwise-xor xorq",
                    },
    },
    },

    ["notb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "notb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "notb_writes_destination",
                        target_operand = 1,
                        role = "bitwise inverted byte by notb",
                    },
    },
    },

    ["notw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "notw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "notw_writes_destination",
                        target_operand = 1,
                        role = "bitwise inverted word by notw",
                    },
    },
    },

    ["notl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "notl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "notl_writes_destination",
                        target_operand = 1,
                        role = "bitwise inverted long by notl",
                    },
    },
    },

    ["notq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "notq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "notq_writes_destination",
                        target_operand = 1,
                        role = "bitwise inverted quadword by notq",
                    },
    },
    },

}

