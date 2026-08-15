-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/integer/atomic.lua
--
-- x86-64 register effects: integer / atomic.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["xadd"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xadd",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "xadd_mutates_destination",
                        target_operand = 1,
                        role = "exchanged and added by xadd",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xadd",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "xadd_writes_source",
                        target_operand = 2,
                        role = "received original destination by xadd",
                    },
    },
    },

    ["cmpxchg"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchg",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "cmpxchg_conditional_destination",
                        target_operand = 1,
                        role = "conditionally exchanged by cmpxchg",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchg",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "cmpxchg_updates_accumulator",
                        target_register = "rax",
                        role = "conditionally updated by cmpxchg comparison",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchg",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "cmpxchg_updates_rflags",
                        target_register = "rflags",
                        role = "updated by cmpxchg",
                    },
    },
    },

    ["cmpxchg8b"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchg8b",
                },
            },
        },

        operands = {
                        { index = 1, role = "memory" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "cmpxchg8b_updates_rax",
                        target_register = "rax",
                        role = "updated by cmpxchg8b comparison",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchg8b",
                },
            },
        },

        operands = {
                        { index = 1, role = "memory" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "cmpxchg8b_updates_rdx",
                        target_register = "rdx",
                        role = "updated by cmpxchg8b comparison",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchg8b",
                },
            },
        },

        operands = {
                        { index = 1, role = "memory" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "cmpxchg8b_updates_rflags",
                        target_register = "rflags",
                        role = "updated by cmpxchg8b",
                    },
    },
    },

    ["cmpxchg16b"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchg16b",
                },
            },
        },

        operands = {
                        { index = 1, role = "memory" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "cmpxchg16b_updates_rax",
                        target_register = "rax",
                        role = "updated by cmpxchg16b comparison",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchg16b",
                },
            },
        },

        operands = {
                        { index = 1, role = "memory" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "cmpxchg16b_updates_rdx",
                        target_register = "rdx",
                        role = "updated by cmpxchg16b comparison",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchg16b",
                },
            },
        },

        operands = {
                        { index = 1, role = "memory" },
                    },

                    effect = {
                        kind = "register_write",
                        name = "cmpxchg16b_updates_rflags",
                        target_register = "rflags",
                        role = "updated by cmpxchg16b",
                    },
    },
    },

    ["cmpxchgb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchgb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmpxchgb_writes_destination",
                        target_operand = 1,
                        role = "conditionally written by byte compare-exchange cmpxchgb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchgb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmpxchgb_updates_rax",
                        target_register = "rax",
                        role = "updated by byte compare-exchange cmpxchgb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchgb",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmpxchgb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte compare-exchange cmpxchgb",
                    },
    },
    },

    ["cmpxchgw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchgw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmpxchgw_writes_destination",
                        target_operand = 1,
                        role = "conditionally written by word compare-exchange cmpxchgw",
                    },
    },
    },

    ["cmpxchgl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchgl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmpxchgl_writes_destination",
                        target_operand = 1,
                        role = "conditionally written by long compare-exchange cmpxchgl",
                    },
    },
    },

    ["cmpxchgq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchgq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmpxchgq_writes_destination",
                        target_operand = 1,
                        role = "conditionally written by quadword compare-exchange cmpxchgq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchgq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmpxchgq_updates_rax",
                        target_register = "rax",
                        role = "updated by quadword compare-exchange cmpxchgq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "cmpxchgq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmpxchgq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword compare-exchange cmpxchgq",
                    },
    },
    },

    ["xaddb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xaddb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xaddb_writes_destination",
                        target_operand = 1,
                        role = "written by byte exchange-add xaddb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xaddb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xaddb_writes_source",
                        target_operand = 2,
                        role = "written with original byte destination by xaddb",
                    },
    },
    },

    ["xaddq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xaddq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xaddq_writes_destination",
                        target_operand = 1,
                        role = "written by quadword exchange-add xaddq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xaddq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xaddq_writes_source",
                        target_operand = 2,
                        role = "written with original quadword destination by xaddq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xaddq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xaddq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword exchange-add xaddq",
                    },
    },
    },

    ["xaddw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xaddw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xaddw_writes_destination",
                        target_operand = 1,
                        role = "written by word exchange-add xaddw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xaddw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xaddw_writes_source",
                        target_operand = 2,
                        role = "written with original word destination by xaddw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xaddw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xaddw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word exchange-add xaddw",
                    },
    },
    },

    ["xaddl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xaddl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xaddl_writes_destination",
                        target_operand = 1,
                        role = "written by long exchange-add xaddl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xaddl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, kind = "register", role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xaddl_writes_source",
                        target_operand = 2,
                        role = "written with original long destination by xaddl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xaddl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "xaddl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long exchange-add xaddl",
                    },
    },
    },

}

