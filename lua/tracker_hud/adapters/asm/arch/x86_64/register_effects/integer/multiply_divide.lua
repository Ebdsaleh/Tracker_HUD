-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/integer/multiply_divide.lua
--
-- x86-64 register effects: integer / multiply divide.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["mul"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mul",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "multiplier",
                        },
                    },

                    effect = {
                        kind = "register_write",
                        name = "mul_writes_rax",
                        target_register = "rax",
                        role = "written by unsigned multiply",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mul",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "multiplier",
                        },
                    },

                    effect = {
                        kind = "register_write",
                        name = "mul_writes_rdx",
                        target_register = "rdx",
                        role = "written by unsigned multiply high result",
                    },
    },
    },

    ["imul"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "imul",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "multiplier",
                        },
                    },

                    effect = {
                        kind = "register_write",
                        name = "imul_writes_rax",
                        target_register = "rax",
                        role = "written by signed multiply",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "imul",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "multiplier",
                        },
                    },

                    effect = {
                        kind = "register_write",
                        name = "imul_writes_rdx",
                        target_register = "rdx",
                        role = "written by signed multiply high result",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "imul",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "imul_two_operand_writes_destination",
                        target_operand = 1,
                        role = "written with signed multiply result by imul",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "imul",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "multiplier" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "imul_three_operand_writes_destination",
                        target_operand = 1,
                        role = "written with signed multiply result by imul",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "imul",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination_or_source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "imul_updates_rflags",
                        target_register = "rflags",
                        role = "updated by imul",
                    },
    },
    },

    ["div"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "div",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "divisor",
                        },
                    },

                    effect = {
                        kind = "register_write",
                        name = "div_writes_rax",
                        target_register = "rax",
                        role = "written with unsigned division quotient",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "div",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "divisor",
                        },
                    },

                    effect = {
                        kind = "register_write",
                        name = "div_writes_rdx",
                        target_register = "rdx",
                        role = "written with unsigned division remainder",
                    },
    },
    },

    ["idiv"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "idiv",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "divisor",
                        },
                    },

                    effect = {
                        kind = "register_write",
                        name = "idiv_writes_rax",
                        target_register = "rax",
                        role = "written with signed division quotient",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "idiv",
                },
            },
        },

        operands = {
                        {
                            index = 1,
                            kind = "register",
                            role = "divisor",
                        },
                    },

                    effect = {
                        kind = "register_write",
                        name = "idiv_writes_rdx",
                        target_register = "rdx",
                        role = "written with signed division remainder",
                    },
    },
    },

    ["mulx"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mulx",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "low_destination" },
                        { index = 2, kind = "register", role = "high_destination" },
                        { index = 3, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "mulx_writes_low_destination",
                        target_operand = 1,
                        role = "written with unsigned multiply low result by mulx",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mulx",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "low_destination" },
                        { index = 2, kind = "register", role = "high_destination" },
                        { index = 3, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "mulx_writes_high_destination",
                        target_operand = 2,
                        role = "written with unsigned multiply high result by mulx",
                    },
    },
    },

    ["imulb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "imulb",
                },
            },
        },

        operands = {
                        { index = 1, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "imulb_writes_rax",
                        target_register = "rax",
                        role = "written with byte signed multiply result by imulb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "imulb",
                },
            },
        },

        operands = {
                        { index = 1, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "imulb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte signed multiply imulb",
                    },
    },
    },

    ["imulw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "imulw",
                },
            },
        },

        operands = {
                        { index = 1, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "imulw_writes_rax",
                        target_register = "rax",
                        role = "written with word signed multiply result low by imulw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "imulw",
                },
            },
        },

        operands = {
                        { index = 1, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "imulw_writes_rdx",
                        target_register = "rdx",
                        role = "written with word signed multiply result high by imulw",
                    },
    },
    },

    ["imull"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "imull",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination_or_source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "imull_writes_operand_or_rax",
                        target_operand = 1,
                        role = "written by long signed multiply imull",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "imull",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination_or_source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "imull_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long signed multiply imull",
                    },
    },
    },

    ["imulq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "imulq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination_or_source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "imulq_writes_operand_or_rax",
                        target_operand = 1,
                        role = "written by quadword signed multiply imulq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "imulq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination_or_source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "imulq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword signed multiply imulq",
                    },
    },
    },

    ["mulb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mulb",
                },
            },
        },

        operands = {
                        { index = 1, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "mulb_writes_rax",
                        target_register = "rax",
                        role = "written with byte unsigned multiply result by mulb",
                    },
    },
    },

    ["mulq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mulq",
                },
            },
        },

        operands = {
                        { index = 1, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "mulq_writes_rax",
                        target_register = "rax",
                        role = "written with quadword unsigned multiply result low by mulq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mulq",
                },
            },
        },

        operands = {
                        { index = 1, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "mulq_writes_rdx",
                        target_register = "rdx",
                        role = "written with quadword unsigned multiply result high by mulq",
                    },
    },
    },

    ["divb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "divb",
                },
            },
        },

        operands = {
                        { index = 1, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "divb_writes_rax",
                        target_register = "rax",
                        role = "written with byte unsigned divide quotient/remainder by divb",
                    },
    },
    },

    ["divq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "divq",
                },
            },
        },

        operands = {
                        { index = 1, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "divq_writes_rax",
                        target_register = "rax",
                        role = "written with quadword unsigned divide quotient by divq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "divq",
                },
            },
        },

        operands = {
                        { index = 1, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "divq_writes_rdx",
                        target_register = "rdx",
                        role = "written with quadword unsigned divide remainder by divq",
                    },
    },
    },

    ["idivb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "idivb",
                },
            },
        },

        operands = {
                        { index = 1, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "idivb_writes_rax",
                        target_register = "rax",
                        role = "written with byte signed divide quotient/remainder by idivb",
                    },
    },
    },

    ["idivq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "idivq",
                },
            },
        },

        operands = {
                        { index = 1, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "idivq_writes_rax",
                        target_register = "rax",
                        role = "written with quadword signed divide quotient by idivq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "idivq",
                },
            },
        },

        operands = {
                        { index = 1, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "idivq_writes_rdx",
                        target_register = "rdx",
                        role = "written with quadword signed divide remainder by idivq",
                    },
    },
    },

    ["mulxl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mulxl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "low_destination" },
                        { index = 2, kind = "register", role = "high_destination" },
                        { index = 3, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "mulxl_writes_low_destination",
                        target_operand = 1,
                        role = "written with long unsigned multiply low result by mulxl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mulxl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "low_destination" },
                        { index = 2, kind = "register", role = "high_destination" },
                        { index = 3, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "mulxl_writes_high_destination",
                        target_operand = 2,
                        role = "written with long unsigned multiply high result by mulxl",
                    },
    },
    },

    ["mulxq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mulxq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "low_destination" },
                        { index = 2, kind = "register", role = "high_destination" },
                        { index = 3, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "mulxq_writes_low_destination",
                        target_operand = 1,
                        role = "written with quadword unsigned multiply low result by mulxq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "mulxq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "low_destination" },
                        { index = 2, kind = "register", role = "high_destination" },
                        { index = 3, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "mulxq_writes_high_destination",
                        target_operand = 2,
                        role = "written with quadword unsigned multiply high result by mulxq",
                    },
    },
    },

}

