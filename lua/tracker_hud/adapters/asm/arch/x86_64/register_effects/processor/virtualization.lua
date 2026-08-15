-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/processor/virtualization.lua
--
-- x86-64 register effects: processor / virtualization state.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD register semantics are layered onto that syntax.

return {

    ["vmclear"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmclear",
                    },
                },
            },

        operands = {
            { index = 1, role = "vmcs_region" },
        },
        effect = {
            kind = "register_write",
            name = "vmclear_updates_rflags",
            target_register = "rflags",
            role = "updated by vmclear",
        },
        },
    },

    ["vmptrld"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmptrld",
                    },
                },
            },

        operands = {
            { index = 1, role = "vmcs_region" },
        },
        effect = {
            kind = "register_write",
            name = "vmptrld_updates_rflags",
            target_register = "rflags",
            role = "updated by vmptrld",
        },
        },
    },

    ["vmread"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmread",
                    },
                },
            },

        operands = {
            { index = 1, role = "field" },
            { index = 2, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "vmread_writes_destination",
            target_operand = 2,
            role = "written with vmcs field by vmread",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmread",
                    },
                },
            },

        operands = {
            { index = 1, role = "field" },
            { index = 2, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "vmread_updates_rflags",
            target_register = "rflags",
            role = "updated by vmread",
        },
        },
    },

    ["vmwrite"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmwrite",
                    },
                },
            },

        operands = {
            { index = 1, role = "source" },
            { index = 2, role = "field" },
        },
        effect = {
            kind = "register_write",
            name = "vmwrite_updates_rflags",
            target_register = "rflags",
            role = "updated by vmwrite",
        },
        },
    },

    ["invept"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "invept",
                    },
                },
            },

        operands = {
            { index = 1, role = "type" },
            { index = 2, role = "descriptor" },
        },
        effect = {
            kind = "register_write",
            name = "invept_updates_rflags",
            target_register = "rflags",
            role = "updated by invept",
        },
        },
    },

    ["invvpid"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "invvpid",
                    },
                },
            },

        operands = {
            { index = 1, role = "type" },
            { index = 2, role = "descriptor" },
        },
        effect = {
            kind = "register_write",
            name = "invvpid_updates_rflags",
            target_register = "rflags",
            role = "updated by invvpid",
        },
        },
    },

    ["stgi"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "stgi",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "stgi_updates_system_state",
            target_register = "rflags",
            role = "global interrupt flag set by stgi",
        },
        },
    },

    ["clgi"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "clgi",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "clgi_updates_system_state",
            target_register = "rflags",
            role = "global interrupt flag cleared by clgi",
        },
        },
    },
}
