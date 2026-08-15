-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/stack/frames.lua
--
-- x86-64 register effects: stack / frames.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {

    ["enter"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "enter",
                    },
                },
            },

            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enter_updates_rsp",
                target_register = "rsp",
                role = "changed by stack frame entry enter",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "enter",
                    },
                },
            },

            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enter_updates_rbp",
                target_register = "rbp",
                role = "established frame base by enter",
            },
        },
    },

    ["leave"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "leave",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "leave_updates_rsp",
                target_register = "rsp",
                role = "restored stack pointer by leave",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "leave",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "leave_updates_rbp",
                target_register = "rbp",
                role = "restored frame base by leave",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "leave",
                    },
                },
            },

            operands = {},

            effect = {
                kind = "register_write",
                name = "leave_restores_rsp",
                target_register = "rsp",
                value_from_register = "rbp",
                role = "restored stack pointer from  frame base by leave",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "leave",
                    },
                },
            },

            operands = {},

            effect = {
                kind = "register_write",
                name = "leave_restores_rbp",
                target_register = "rbp",
                role = "loaded previous frame base from stack by leave",
            },
        },
    },

    ["leaveq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "leaveq",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "leaveq_restores_rsp",
                target_register = "rsp",
                role = "restored from frame pointer by leaveq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "leaveq",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "leaveq_restores_rbp",
                target_register = "rbp",
                role = "restored by frame teardown leaveq",
            },
        },
    },

    ["leavel"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "leavel",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "leavel_restores_rsp",
                target_register = "rsp",
                role = "restored from frame pointer by leavel",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "leavel",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "leavel_restores_rbp",
                target_register = "rbp",
                role = "restored by frame teardown leavel",
            },
        },
    },

    ["leavew"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "leavew",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "leavew_restores_rsp",
                target_register = "rsp",
                role = "restored from frame pointer by leavew",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "leavew",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "leavew_restores_rbp",
                target_register = "rbp",
                role = "restored by frame teardown leavew",
            },
        },
    },

    ["enterq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "enterq",
                    },
                },
            },

            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enterq_updates_rsp",
                target_register = "rsp",
                role = "updated by quadword stack frame setup enterq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "enterq",
                    },
                },
            },

            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enterq_updates_rbp",
                target_register = "rbp",
                role = "updated by quadword stack frame setup enterq",
            },
        },
    },

    ["enterl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "enterl",
                    },
                },
            },

            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enterl_updates_rsp",
                target_register = "rsp",
                role = "updated by long stack frame setup enterl",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "enterl",
                    },
                },
            },

            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enterl_updates_rbp",
                target_register = "rbp",
                role = "updated by long stack frame setup enterl",
            },
        },
    },

    ["enterw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "enterw",
                    },
                },
            },

            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enterw_updates_rsp",
                target_register = "rsp",
                role = "updated by word stack frame setup enterw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "enterw",
                    },
                },
            },

            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enterw_updates_rbp",
                target_register = "rbp",
                role = "updated by word stack frame setup enterw",
            },
        },
    },

}

