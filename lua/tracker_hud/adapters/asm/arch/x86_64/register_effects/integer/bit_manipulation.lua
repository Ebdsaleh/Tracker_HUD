-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/integer/bit_manipulation.lua
--
-- x86-64 register effects: integer / bit manipulation.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {

    ["popcnt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcnt",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcnt_writes_destination",
                target_operand = 1,
                role = "written with population count by popcnt",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcnt",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcnt_updates_rflags",
                target_register = "rflags",
                role = "updated by popcnt",
            },
        },
    },

    ["popcntw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcntw",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntw_writes_destination",
                target_operand = 1,
                role = "written with word population count by popcntw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcntw",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntw_updates_rflags",
                target_register = "rflags",
                role = "updated by word population count popcntw",
            },
        },
    },

    ["popcntl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcntl",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntl_writes_destination",
                target_operand = 1,
                role = "written with long population count by popcntl",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcntl",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntl_updates_rflags",
                target_register = "rflags",
                role = "updated by long population count popcntl",
            },
        },
    },

    ["popcntq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcntq",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntq_writes_destination",
                target_operand = 1,
                role = "written with quadword population count by popcntq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcntq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword population count popcntq",
            },
        },
    },

}

