-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/integer/conditional.lua
--
-- x86-64 register effects: integer / conditional.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["salc"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "salc",
                },
            },
        },

        operands = {},
                    effect = {
                        kind = "register_write",
                        name = "salc_writes_rax",
                        target_register = "rax",
                        written_alias = "al",
                        role = "set al from carry flag by salc",
                    },
    },
    },

    ["seto"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "seto",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "seto_register",
                        target_operand = 1,
                        role = "set byte from overflow condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "seto",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "seto_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if overflow by seto",
                    },
    },
    },

    ["setno"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setno",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setno_register",
                        target_operand = 1,
                        role = "set byte from not-overflow condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setno",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setno_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if not overflow by setno",
                    },
    },
    },

    ["setb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setb_register",
                        target_operand = 1,
                        role = "set byte from below condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setb",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setb_writes_destination",
                        target_operand = 1,
                        role = "set byte from below condition by setb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setb_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if unsigned below by setb",
                    },
    },
    },

    ["setnae"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnae",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setnae_register",
                        target_operand = 1,
                        role = "set byte from not-above-or-equal condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnae",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setnae_writes_destination",
                        target_operand = 1,
                        role = "set byte from not-above-or-equal condition by setnae",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnae",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setnae_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if not unsigned above-or-equal by setnae",
                    },
    },
    },

    ["setc"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setc",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setc_register",
                        target_operand = 1,
                        role = "set byte from carry condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setc",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setc_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if carry by setc",
                    },
    },
    },

    ["setae"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setae",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setae_register",
                        target_operand = 1,
                        role = "set byte from above-or-equal condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setae",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setae_writes_destination",
                        target_operand = 1,
                        role = "set byte from above-or-equal condition by setae",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setae",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setae_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if unsigned above-or-equal by setae",
                    },
    },
    },

    ["setnb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setnb_register",
                        target_operand = 1,
                        role = "set byte from not-below condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnb",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setnb_writes_destination",
                        target_operand = 1,
                        role = "set byte from not-below condition by setnb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setnb_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if not unsigned below by setnb",
                    },
    },
    },

    ["setnc"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnc",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setnc_register",
                        target_operand = 1,
                        role = "set byte from not-carry condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnc",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setnc_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if not carry by setnc",
                    },
    },
    },

    ["sete"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sete",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "sete_register",
                        target_operand = 1,
                        role = "set byte from equal condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sete",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sete_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if equal by sete",
                    },
    },
    },

    ["setz"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setz",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setz_register",
                        target_operand = 1,
                        role = "set byte from zero condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setz",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setz_writes_destination",
                        target_operand = 1,
                        role = "set byte from zero condition by setz",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setz",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setz_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if zero by setz",
                    },
    },
    },

    ["setne"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setne",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setne_register",
                        target_operand = 1,
                        role = "set byte from not-equal condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setne",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setne_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if not equal by setne",
                    },
    },
    },

    ["setnz"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnz",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setnz_register",
                        target_operand = 1,
                        role = "set byte from not-zero condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnz",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setnz_writes_destination",
                        target_operand = 1,
                        role = "set byte from not-zero condition by setnz",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnz",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setnz_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if not zero by setnz",
                    },
    },
    },

    ["setbe"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setbe",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setbe_register",
                        target_operand = 1,
                        role = "set byte from below-or-equal condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setbe",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setbe_writes_destination",
                        target_operand = 1,
                        role = "set byte from below-or-equal condition by setbe",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setbe",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setbe_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if unsigned below-or-equal by setbe",
                    },
    },
    },

    ["setna"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setna",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setna_register",
                        target_operand = 1,
                        role = "set byte from not-above condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setna",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setna_writes_destination",
                        target_operand = 1,
                        role = "set byte from not-above condition by setna",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setna",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setna_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if not unsigned above by setna",
                    },
    },
    },

    ["seta"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "seta",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "seta_register",
                        target_operand = 1,
                        role = "set byte from above condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "seta",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "seta_writes_destination",
                        target_operand = 1,
                        role = "set byte from above condition by seta",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "seta",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "seta_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if unsigned above by seta",
                    },
    },
    },

    ["setnbe"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnbe",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setnbe_register",
                        target_operand = 1,
                        role = "set byte from not-below-or-equal condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnbe",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setnbe_writes_destination",
                        target_operand = 1,
                        role = "set byte from not-below-or-equal condition by setnbe",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnbe",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setnbe_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if not unsigned below-or-equal by setnbe",
                    },
    },
    },

    ["sets"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sets",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "sets_register",
                        target_operand = 1,
                        role = "set byte from sign condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sets",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "sets_writes_destination",
                        target_operand = 1,
                        role = "set byte from sign condition by sets",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sets",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sets_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if sign by sets",
                    },
    },
    },

    ["setns"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setns",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setns_register",
                        target_operand = 1,
                        role = "set byte from not-sign condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setns",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setns_writes_destination",
                        target_operand = 1,
                        role = "set byte from not-sign condition by setns",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setns",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setns_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if not sign by setns",
                    },
    },
    },

    ["setp"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setp",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setp_register",
                        target_operand = 1,
                        role = "set byte from parity condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setp",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setp_writes_destination",
                        target_operand = 1,
                        role = "set byte from parity condition by setp",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setp",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setp_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if parity by setp",
                    },
    },
    },

    ["setpe"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setpe",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setpe_register",
                        target_operand = 1,
                        role = "set byte from parity-even condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setpe",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setpe_writes_destination",
                        target_operand = 1,
                        role = "set byte from parity-even condition by setpe",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setpe",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setpe_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if parity even by setpe",
                    },
    },
    },

    ["setnp"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnp",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setnp_register",
                        target_operand = 1,
                        role = "set byte from not-parity condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnp",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setnp_writes_destination",
                        target_operand = 1,
                        role = "set byte from not-parity condition by setnp",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnp",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setnp_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if not parity by setnp",
                    },
    },
    },

    ["setpo"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setpo",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setpo_register",
                        target_operand = 1,
                        role = "set byte from parity-odd condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setpo",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setpo_writes_destination",
                        target_operand = 1,
                        role = "set byte from parity-odd condition by setpo",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setpo",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setpo_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if parity odd by setpo",
                    },
    },
    },

    ["setl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setl_register",
                        target_operand = 1,
                        role = "set byte from less-than condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setl_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if signed less by setl",
                    },
    },
    },

    ["setnge"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnge",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setnge_register",
                        target_operand = 1,
                        role = "set byte from not-greater-or-equal condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnge",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setnge_writes_destination",
                        target_operand = 1,
                        role = "set byte from not-greater-or-equal condition by setnge",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnge",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setnge_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if not signed greater-or-equal by setnge",
                    },
    },
    },

    ["setge"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setge",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setge_register",
                        target_operand = 1,
                        role = "set byte from greater-or-equal condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setge",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setge_writes_destination",
                        target_operand = 1,
                        role = "set byte from greater-or-equal condition by setge",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setge",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setge_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if signed greater-or-equal by setge",
                    },
    },
    },

    ["setnl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setnl_register",
                        target_operand = 1,
                        role = "set byte from not-less-than condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnl",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setnl_writes_destination",
                        target_operand = 1,
                        role = "set byte from not-less condition by setnl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setnl_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if not signed less by setnl",
                    },
    },
    },

    ["setle"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setle",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setle_register",
                        target_operand = 1,
                        role = "set byte from less-or-equal condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setle",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setle_writes_destination",
                        target_operand = 1,
                        role = "set byte from less-or-equal condition by setle",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setle",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setle_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if signed less-or-equal by setle",
                    },
    },
    },

    ["setng"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setng",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setng_register",
                        target_operand = 1,
                        role = "set byte from not-greater-than condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setng",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setng_writes_destination",
                        target_operand = 1,
                        role = "set byte from not-greater condition by setng",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setng",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setng_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if not signed greater by setng",
                    },
    },
    },

    ["setg"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setg",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setg_register",
                        target_operand = 1,
                        role = "set byte from greater-than condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setg",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setg_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if signed greater by setg",
                    },
    },
    },

    ["setnle"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnle",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "setnle_register",
                        target_operand = 1,
                        role = "set byte from not-less-or-equal condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnle",
                },
            },
        },

        operands = { { index = 1, kind = "register", role = "destination" } },
                    effect = {
                        kind = "register_write",
                        name = "setnle_writes_destination",
                        target_operand = 1,
                        role = "set byte from not-less-or-equal condition by setnle",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "setnle",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "setnle_writes_destination",
                        target_operand = 1,
                        written_alias = "byte",
                        role = "set byte if not signed less-or-equal by setnle",
                    },
    },
    },

    ["cmovo"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovo",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovo_register",
                        target_operand = 1,
                        role = "conditionally moved from overflow condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovo",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovo_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from overflow condition by cmovo",
                    },
    },
    },

    ["cmovno"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovno",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovno_register",
                        target_operand = 1,
                        role = "conditionally moved from not-overflow condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovno",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovno_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from not-overflow condition by cmovno",
                    },
    },
    },

    ["cmovb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovb_register",
                        target_operand = 1,
                        role = "conditionally moved from below condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovb_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from below condition by cmovb",
                    },
    },
    },

    ["cmovc"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovc",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovc_register",
                        target_operand = 1,
                        role = "conditionally moved from carry condition",
                    },
    },
    },

    ["cmovae"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovae",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovae_register",
                        target_operand = 1,
                        role = "conditionally moved from above-or-equal condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovae",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovae_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from above-or-equal condition by cmovae",
                    },
    },
    },

    ["cmovnc"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnc",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnc_register",
                        target_operand = 1,
                        role = "conditionally moved from not-carry condition",
                    },
    },
    },

    ["cmove"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmove",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmove_register",
                        target_operand = 1,
                        role = "conditionally moved from equal condition",
                    },
    },
    },

    ["cmovz"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovz",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovz_register",
                        target_operand = 1,
                        role = "conditionally moved from zero condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovz",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovz_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from zero condition by cmovz",
                    },
    },
    },

    ["cmovne"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovne",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovne_register",
                        target_operand = 1,
                        role = "conditionally moved from not-equal condition",
                    },
    },
    },

    ["cmovnz"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnz",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnz_register",
                        target_operand = 1,
                        role = "conditionally moved from not-zero condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnz",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnz_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from not-zero condition by cmovnz",
                    },
    },
    },

    ["cmovbe"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovbe",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovbe_register",
                        target_operand = 1,
                        role = "conditionally moved from below-or-equal condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovbe",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovbe_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from below-or-equal condition by cmovbe",
                    },
    },
    },

    ["cmova"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmova",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmova_register",
                        target_operand = 1,
                        role = "conditionally moved from above condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmova",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmova_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from above condition by cmova",
                    },
    },
    },

    ["cmovs"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovs",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovs_register",
                        target_operand = 1,
                        role = "conditionally moved from sign condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovs",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovs_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from sign condition by cmovs",
                    },
    },
    },

    ["cmovns"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovns",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovns_register",
                        target_operand = 1,
                        role = "conditionally moved from not-sign condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovns",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovns_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from not-sign condition by cmovns",
                    },
    },
    },

    ["cmovp"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovp",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovp_register",
                        target_operand = 1,
                        role = "conditionally moved from parity condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovp",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovp_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from parity condition by cmovp",
                    },
    },
    },

    ["cmovnp"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnp",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnp_register",
                        target_operand = 1,
                        role = "conditionally moved from not-parity condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnp",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnp_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from not-parity condition by cmovnp",
                    },
    },
    },

    ["cmovl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovl_register",
                        target_operand = 1,
                        role = "conditionally moved from less-than condition",
                    },
    },
    },

    ["cmovge"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovge",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovge_register",
                        target_operand = 1,
                        role = "conditionally moved from greater-or-equal condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovge",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovge_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from greater-or-equal condition by cmovge",
                    },
    },
    },

    ["cmovle"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovle",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovle_register",
                        target_operand = 1,
                        role = "conditionally moved from less-or-equal condition",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovle",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovle_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from less-or-equal condition by cmovle",
                    },
    },
    },

    ["cmovg"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovg",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovg_register",
                        target_operand = 1,
                        role = "conditionally moved from greater-than condition",
                    },
    },
    },

    ["cmovpe"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovpe",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovpe_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from parity-even condition by cmovpe",
                    },
    },
    },

    ["cmovpo"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovpo",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovpo_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from parity-odd condition by cmovpo",
                    },
    },
    },

    ["cmovna"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovna",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovna_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from not-above condition by cmovna",
                    },
    },
    },

    ["cmovnbe"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnbe",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnbe_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from not-below-or-equal condition by cmovnbe",
                    },
    },
    },

    ["cmovnae"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnae",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnae_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from not-above-or-equal condition by cmovnae",
                    },
    },
    },

    ["cmovnb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnb_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from not-below condition by cmovnb",
                    },
    },
    },

    ["cmovnge"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnge",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnge_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from not-greater-or-equal condition by cmovnge",
                    },
    },
    },

    ["cmovng"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovng",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovng_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from not-greater condition by cmovng",
                    },
    },
    },

    ["cmovnl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnl_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from not-less condition by cmovnl",
                    },
    },
    },

    ["cmovnle"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnle",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnle_writes_destination",
                        target_operand = 1,
                        role = "conditionally moved from not-less-or-equal condition by cmovnle",
                    },
    },
    },

    ["cmoveq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmoveq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmoveq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if equal by cmoveq",
                    },
    },
    },

    ["cmovel"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovel",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovel_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if equal by cmovel",
                    },
    },
    },

    ["cmovew"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovew",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovew_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if equal by cmovew",
                    },
    },
    },

    ["cmovzq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovzq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovzq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if zero by cmovzq",
                    },
    },
    },

    ["cmovzl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovzl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovzl_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if zero by cmovzl",
                    },
    },
    },

    ["cmovzw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovzw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovzw_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if zero by cmovzw",
                    },
    },
    },

    ["cmovneq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovneq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovneq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not equal by cmovneq",
                    },
    },
    },

    ["cmovnel"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnel",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnel_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not equal by cmovnel",
                    },
    },
    },

    ["cmovnew"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnew",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnew_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not equal by cmovnew",
                    },
    },
    },

    ["cmovnzq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnzq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnzq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not zero by cmovnzq",
                    },
    },
    },

    ["cmovnzl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnzl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnzl_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not zero by cmovnzl",
                    },
    },
    },

    ["cmovnzw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnzw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnzw_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not zero by cmovnzw",
                    },
    },
    },

    ["cmovgq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovgq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovgq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if signed greater by cmovgq",
                    },
    },
    },

    ["cmovgl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovgl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovgl_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if signed greater by cmovgl",
                    },
    },
    },

    ["cmovgew"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovgew",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovgew_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if signed greater-or-equal by cmovgew",
                    },
    },
    },

    ["cmovgeq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovgeq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovgeq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if signed greater-or-equal by cmovgeq",
                    },
    },
    },

    ["cmovgel"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovgel",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovgel_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if signed greater-or-equal by cmovgel",
                    },
    },
    },

    ["cmovlq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovlq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovlq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if signed less by cmovlq",
                    },
    },
    },

    ["cmovll"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovll",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovll_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if signed less by cmovll",
                    },
    },
    },

    ["cmovlw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovlw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovlw_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if signed less by cmovlw",
                    },
    },
    },

    ["cmovleq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovleq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovleq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if signed less-or-equal by cmovleq",
                    },
    },
    },

    ["cmovlel"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovlel",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovlel_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if signed less-or-equal by cmovlel",
                    },
    },
    },

    ["cmovlew"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovlew",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovlew_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if signed less-or-equal by cmovlew",
                    },
    },
    },

    ["cmovaq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovaq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovaq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if unsigned above by cmovaq",
                    },
    },
    },

    ["cmovaeq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovaeq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovaeq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if unsigned above-or-equal by cmovaeq",
                    },
    },
    },

    ["cmovbq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovbq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovbq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if unsigned below by cmovbq",
                    },
    },
    },

    ["cmovbeq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovbeq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovbeq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if unsigned below-or-equal by cmovbeq",
                    },
    },
    },

    ["cmovcq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovcq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovcq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if carry by cmovcq",
                    },
    },
    },

    ["cmovncq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovncq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovncq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not carry by cmovncq",
                    },
    },
    },

    ["cmovsq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovsq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovsq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if sign by cmovsq",
                    },
    },
    },

    ["cmovnsq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnsq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnsq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not sign by cmovnsq",
                    },
    },
    },

    ["cmovoq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovoq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovoq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if overflow by cmovoq",
                    },
    },
    },

    ["cmovnoq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnoq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnoq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not overflow by cmovnoq",
                    },
    },
    },

    ["cmovpq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovpq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovpq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if parity by cmovpq",
                    },
    },
    },

    ["cmovnpq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnpq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnpq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not parity by cmovnpq",
                    },
    },
    },

    ["cmovnaq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnaq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnaq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not unsigned above by cmovnaq",
                    },
    },
    },

    ["cmovnaeq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnaeq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnaeq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not unsigned above-or-equal by cmovnaeq",
                    },
    },
    },

    ["cmovnbq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnbq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnbq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not unsigned below by cmovnbq",
                    },
    },
    },

    ["cmovnbeq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnbeq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnbeq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not unsigned below-or-equal by cmovnbeq",
                    },
    },
    },

    ["cmovnal"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnal",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnal_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not unsigned above by cmovnal",
                    },
    },
    },

    ["cmovnael"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnael",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnael_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not unsigned above-or-equal by cmovnael",
                    },
    },
    },

    ["cmovnbl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnbl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnbl_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not unsigned below by cmovnbl",
                    },
    },
    },

    ["cmovnbel"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnbel",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnbel_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not unsigned below-or-equal by cmovnbel",
                    },
    },
    },

    ["cmovngq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovngq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovngq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not signed greater by cmovngq",
                    },
    },
    },

    ["cmovngeq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovngeq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovngeq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not signed greater-or-equal by cmovngeq",
                    },
    },
    },

    ["cmovnlq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnlq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnlq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not signed less by cmovnlq",
                    },
    },
    },

    ["cmovnleq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnleq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnleq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not signed less-or-equal by cmovnleq",
                    },
    },
    },

    ["cmovngl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovngl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovngl_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not signed greater by cmovngl",
                    },
    },
    },

    ["cmovngel"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovngel",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovngel_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not signed greater-or-equal by cmovngel",
                    },
    },
    },

    ["cmovnll"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnll",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnll_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not signed less by cmovnll",
                    },
    },
    },

    ["cmovnlel"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovnlel",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovnlel_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if not signed less-or-equal by cmovnlel",
                    },
    },
    },

    ["cmovpeq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovpeq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovpeq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if parity even by cmovpeq",
                    },
    },
    },

    ["cmovpoq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovpoq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovpoq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if parity odd by cmovpoq",
                    },
    },
    },

    ["cmovpel"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovpel",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovpel_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if parity even by cmovpel",
                    },
    },
    },

    ["cmovpol"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmovpol",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmovpol_writes_destination",
                        target_operand = 1,
                        role = "conditionally written if parity odd by cmovpol",
                    },
    },
    },

}

