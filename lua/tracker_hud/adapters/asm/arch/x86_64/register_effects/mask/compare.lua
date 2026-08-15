-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/mask/compare.lua
--
-- x86-64 register effects: mask / compare.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["kortestb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kortestb",
                    },
                },
            },

            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kortestb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte mask or-test kortestb",
            },
        },
    },

    ["kortestw"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kortestw",
                    },
                },
            },

            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kortestw_updates_rflags",
                target_register = "rflags",
                role = "updated by word mask or-test kortestw",
            },
        },
    },

    ["kortestd"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kortestd",
                    },
                },
            },

            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kortestd_updates_rflags",
                target_register = "rflags",
                role = "updated by doubleword mask or-test kortestd",
            },
        },
    },

    ["kortestq"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "kortestq",
                    },
                },
            },

            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kortestq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword mask or-test kortestq",
            },
        },
    },

    ["ktestb"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ktestb",
                    },
                },
            },

            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "ktestb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte mask test ktestb",
            },
        },
    },

    ["ktestw"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ktestw",
                    },
                },
            },

            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "ktestw_updates_rflags",
                target_register = "rflags",
                role = "updated by word mask test ktestw",
            },
        },
    },

    ["ktestd"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ktestd",
                    },
                },
            },

            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "ktestd_updates_rflags",
                target_register = "rflags",
                role = "updated by doubleword mask test ktestd",
            },
        },
    },

    ["ktestq"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ktestq",
                    },
                },
            },

            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "ktestq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword mask test ktestq",
            },
        },
    },

}
