-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/processor/protection_state.lua
--
-- x86-64 register effects: processor / protection and security state.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD register semantics are layered onto that syntax.

return {

    ["rdpkru"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdpkru",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdpkru_writes_rax",
            target_register = "rax",
            role = "written with protection-key rights by rdpkru",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdpkru",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdpkru_writes_rdx",
            target_register = "rdx",
            role = "cleared high result by rdpkru",
        },
        },
    },

    ["rdsspd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdsspd",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdsspd_writes_gpr",
            target_operand = 1,
            role = "written with 32-bit shadow stack pointer by rdsspd",
        },
        },
    },

    ["rdsspq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdsspq",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdsspq_writes_gpr",
            target_operand = 1,
            role = "written with 64-bit shadow stack pointer by rdsspq",
        },
        },
    },

    ["bndmk"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "bndmk",
                    },
                },
            },

        operands = {
            { index = 1, role = "bounds_destination" },
            { index = 2, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "bndmk_updates_bounds_state",
            target_register = "rip",
            role = "made bounds register from address by bndmk",
        },
        },
    },

    ["bndmov"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "bndmov",
                    },
                },
            },

        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "bndmov_updates_bounds_state",
            target_register = "rip",
            role = "moved bounds register state by bndmov",
        },
        },
    },

    ["bndldx"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "bndldx",
                    },
                },
            },

        operands = {
            { index = 1, role = "bounds_destination" },
            { index = 2, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "bndldx_updates_bounds_state",
            target_register = "rip",
            role = "loaded bounds using address translation by bndldx",
        },
        },
    },

    ["eenter"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "eenter",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "eenter_updates_rip",
            target_register = "rip",
            role = "entered sgx enclave by eenter",
        },
        },
    },

    ["eexit"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "eexit",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "eexit_updates_rip",
            target_register = "rip",
            role = "exited sgx enclave by eexit",
        },
        },
    },

    ["eresume"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "eresume",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "eresume_updates_rip",
            target_register = "rip",
            role = "resumed sgx enclave by eresume",
        },
        },
    },

    ["pvalidate"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pvalidate",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "pvalidate_updates_rflags",
                target_register = "rflags",
                role = "updated by page validation pvalidate",
            },
        },
    },
}
