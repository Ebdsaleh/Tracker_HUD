-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/integer/arithmetic.lua
--
-- x86-64 register effects: integer / arithmetic.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["neg"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "neg",
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
                        name = "neg_register",
                        target_operand = 1,
                        role = "arithmetically negated by neg",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "neg",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "neg_updates_rflags",
                        target_register = "rflags",
                        role = "updated by neg",
                    },
    },
    },

    ["add"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "add",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "add_updates_rflags",
                        target_register = "rflags",
                        role = "updated by add",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "add",
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
                            role = "increment_value",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "add_register_immediate",
                        target_operand = 1,
                        value_delta_operand = 2,
                        role = "increased by immediate",
                    },
    },
    },

    ["sub"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sub",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "sub_updates_rflags",
                        target_register = "rflags",
                        role = "updated by sub",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sub",
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
                        name = "sub_register_self_zero",
                        target_operand = 1,
                        value = "0",
                        role = "zeroed by sub",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sub",
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
                            role = "decrement_value",
                        },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "sub_register_immediate",
                        target_operand = 1,
                        value_delta_operand = 2,
                        value_delta_sign = -1,
                        role = "decreased by immediate",
                    },
    },
    },

    ["inc"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "inc",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "inc_updates_rflags",
                        target_register = "rflags",
                        role = "updated by inc",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "inc",
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
                        name = "inc_register",
                        target_operand = 1,
                        value_delta = 1,
                        role = "incremented",
                    },
    },
    },

    ["dec"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "dec",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "dec_updates_rflags",
                        target_register = "rflags",
                        role = "updated by dec",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "dec",
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
                        name = "dec_register",
                        target_operand = 1,
                        value_delta = -1,
                        role = "decremented",
                    },
    },
    },

    ["adc"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adc",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source_register" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "adc_register_register",
                        target_operand = 1,
                        role = "added with carry from register",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adc",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "integer", role = "source_value" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "adc_register_immediate",
                        target_operand = 1,
                        role = "added with carry from immediate",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adc",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "adc_updates_rflags",
                        target_register = "rflags",
                        role = "updated by adc",
                    },
    },
    },

    ["sbb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sbb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source_register" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "sbb_register_register",
                        target_operand = 1,
                        role = "subtracted with borrow from register",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sbb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "integer", role = "source_value" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "sbb_register_immediate",
                        target_operand = 1,
                        role = "subtracted with borrow from immediate",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sbb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "sbb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by sbb",
                    },
    },
    },

    ["adcx"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adcx",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "adcx_writes_destination",
                        target_operand = 1,
                        role = "added with carry by adcx",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adcx",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "adcx_updates_rflags",
                        target_register = "rflags",
                        role = "updated by adcx",
                    },
    },
    },

    ["adox"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adox",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "adox_writes_destination",
                        target_operand = 1,
                        role = "added with overflow by adox",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adox",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "adox_updates_rflags",
                        target_register = "rflags",
                        role = "updated by adox",
                    },
    },
    },

    ["addb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "addb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "addb_writes_destination",
                        target_operand = 1,
                        role = "added byte source by addb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "addb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "addb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte add addb",
                    },
    },
    },

    ["addw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "addw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "addw_writes_destination",
                        target_operand = 1,
                        role = "added word source by addw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "addw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "addw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word add addw",
                    },
    },
    },

    ["addl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "addl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "addl_writes_destination",
                        target_operand = 1,
                        role = "added long source by addl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "addl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "addl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long add addl",
                    },
    },
    },

    ["addq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "addq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "addq_writes_destination",
                        target_operand = 1,
                        role = "added quadword source by addq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "addq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "addq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword add addq",
                    },
    },
    },

    ["subb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "subb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "subb_writes_destination",
                        target_operand = 1,
                        role = "subtracted byte source by subb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "subb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "subb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte subtract subb",
                    },
    },
    },

    ["subw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "subw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "subw_writes_destination",
                        target_operand = 1,
                        role = "subtracted word source by subw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "subw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "subw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word subtract subw",
                    },
    },
    },

    ["subl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "subl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "subl_writes_destination",
                        target_operand = 1,
                        role = "subtracted long source by subl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "subl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "subl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long subtract subl",
                    },
    },
    },

    ["subq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "subq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "subq_writes_destination",
                        target_operand = 1,
                        role = "subtracted quadword source by subq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "subq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "subq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword subtract subq",
                    },
    },
    },

    ["adcb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adcb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "adcb_writes_destination",
                        target_operand = 1,
                        role = "added byte source with carry by adcb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adcb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "adcb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte add with carry adcb",
                    },
    },
    },

    ["adcw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adcw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "adcw_writes_destination",
                        target_operand = 1,
                        role = "added word source with carry by adcw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adcw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "adcw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word add with carry adcw",
                    },
    },
    },

    ["adcl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adcl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "adcl_writes_destination",
                        target_operand = 1,
                        role = "added long source with carry by adcl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adcl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "adcl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long add with carry adcl",
                    },
    },
    },

    ["adcq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adcq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "adcq_writes_destination",
                        target_operand = 1,
                        role = "added quadword source with carry by adcq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "adcq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "adcq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword add with carry adcq",
                    },
    },
    },

    ["sbbb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sbbb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sbbb_writes_destination",
                        target_operand = 1,
                        role = "subtracted byte source with borrow by sbbb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sbbb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sbbb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte subtract with borrow sbbb",
                    },
    },
    },

    ["sbbw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sbbw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sbbw_writes_destination",
                        target_operand = 1,
                        role = "subtracted word source with borrow by sbbw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sbbw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sbbw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word subtract with borrow sbbw",
                    },
    },
    },

    ["sbbl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sbbl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sbbl_writes_destination",
                        target_operand = 1,
                        role = "subtracted long source with borrow by sbbl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sbbl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sbbl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long subtract with borrow sbbl",
                    },
    },
    },

    ["sbbq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sbbq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sbbq_writes_destination",
                        target_operand = 1,
                        role = "subtracted quadword source with borrow by sbbq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "sbbq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "sbbq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword subtract with borrow sbbq",
                    },
    },
    },

    ["incb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "incb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "incb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte increment incb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "incb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "incb_writes_destination",
                        target_operand = 1,
                        role = "incremented byte by incb",
                        value_delta = 1,
                    },
    },
    },

    ["incw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "incw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "incw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word increment incw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "incw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "incw_writes_destination",
                        target_operand = 1,
                        role = "incremented word by incw",
                        value_delta = 1,
                    },
    },
    },

    ["incl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "incl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "incl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long increment incl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "incl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "incl_writes_destination",
                        target_operand = 1,
                        role = "incremented long by incl",
                        value_delta = 1,
                    },
    },
    },

    ["incq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "incq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "incq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword increment incq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "incq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "incq_writes_destination",
                        target_operand = 1,
                        role = "incremented quadword by incq",
                        value_delta = 1,
                    },
    },
    },

    ["decq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "decq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "decq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword decrement decq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "decq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "decq_writes_destination",
                        target_operand = 1,
                        role = "decremented quadword by decq",
                        value_delta = -1,
                    },
    },
    },

    ["negb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "negb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "negb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte negate negb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "negb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "negb_writes_destination",
                        target_operand = 1,
                        role = "arithmetically negated byte by negb",
                    },
    },
    },

    ["negw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "negw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "negw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word negate negw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "negw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "negw_writes_destination",
                        target_operand = 1,
                        role = "arithmetically negated word by negw",
                    },
    },
    },

    ["negl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "negl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "negl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long negate negl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "negl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "negl_writes_destination",
                        target_operand = 1,
                        role = "arithmetically negated long by negl",
                    },
    },
    },

    ["negq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "negq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "negq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword negate negq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "negq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "negq_writes_destination",
                        target_operand = 1,
                        role = "arithmetically negated quadword by negq",
                    },
    },
    },

    ["decb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "decb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "decb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte decrement decb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "decb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "decb_writes_destination",
                        target_operand = 1,
                        role = "decremented byte by decb",
                        value_delta = -1,
                    },
    },
    },

    ["decw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "decw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "decw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word decrement decw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "decw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "decw_writes_destination",
                        target_operand = 1,
                        role = "decremented word by decw",
                        value_delta = -1,
                    },
    },
    },

    ["decl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "decl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "decl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long decrement decl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "decl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "decl_writes_destination",
                        target_operand = 1,
                        role = "decremented long by decl",
                        value_delta = -1,
                    },
    },
    },

}

