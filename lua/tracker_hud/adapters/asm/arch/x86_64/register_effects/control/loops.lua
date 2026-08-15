-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/control/loops.lua
--
-- x86-64 register effects: control / loops.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {

    ["loop"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loop",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },

            effect = {
                kind = "register_write",
                name = "loop_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loop",
            },
        },
    },

    ["loope"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loope",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },

            effect = {
                kind = "register_write",
                name = "loope_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loope",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loope",
                    },
                },
            },

            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loope_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loope",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loope",
                    },
                },
            },

            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loope_updates_rip",
                target_register = "rip",
                role = "conditional loop branch by loope",
            },
        },
    },

    ["loopz"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loopz",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },

            effect = {
                kind = "register_write",
                name = "loopz_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loopz",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loopz",
                    },
                },
            },

            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loopz_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loopz",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loopz",
                    },
                },
            },

            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loopz_updates_rip",
                target_register = "rip",
                role = "conditional loop branch by loopz",
            },
        },
    },

    ["loopne"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loopne",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },

            effect = {
                kind = "register_write",
                name = "loopne_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loopne",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loopne",
                    },
                },
            },

            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loopne_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loopne",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loopne",
                    },
                },
            },

            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loopne_updates_rip",
                target_register = "rip",
                role = "conditional loop branch by loopne",
            },
        },
    },

    ["loopnz"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loopnz",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },

            effect = {
                kind = "register_write",
                name = "loopnz_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loopnz",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loopnz",
                    },
                },
            },

            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loopnz_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loopnz",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loopnz",
                    },
                },
            },

            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loopnz_updates_rip",
                target_register = "rip",
                role = "conditional loop branch by loopnz",
            },
        },
    },

    ["jcxz"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jcxz",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jcxz_updates_rip",
                target_register = "rip",
                role = "conditional jump if cx is zero by jcxz",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jcxz",
                    },
                },
            },

            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "jcxz_updates_rip",
                target_register = "rip",
                role = "conditional jump if cx zero by jcxz",
            },
        },
    },

    ["jecxz"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jecxz",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jecxz_updates_rip",
                target_register = "rip",
                role = "conditional jump if ecx is zero by jecxz",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jecxz",
                    },
                },
            },

            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "jecxz_updates_rip",
                target_register = "rip",
                role = "conditional jump if ecx zero by jecxz",
            },
        },
    },

    ["jrcxz"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jrcxz",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jrcxz_updates_rip",
                target_register = "rip",
                role = "conditional jump if rcx is zero by jrcxz",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jrcxz",
                    },
                },
            },

            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "jrcxz_updates_rip",
                target_register = "rip",
                role = "conditional jump if rcx zero by jrcxz",
            },
        },
    },

}

