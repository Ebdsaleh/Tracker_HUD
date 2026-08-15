-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/processor/timing_random.lua
--
-- x86-64 register effects: processor / timing and random state.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD register semantics are layered onto that syntax.

return {

    ["rdtsc"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdtsc",
                    },
                },
            },

        operands = {},

        effect = {
            kind = "register_write",
            name = "rdtsc_writes_rax",
            target_register = "rax",
            role = "written with timestamp low result by rdtsc",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdtsc",
                    },
                },
            },

        operands = {},

        effect = {
            kind = "register_write",
            name = "rdtsc_writes_rdx",
            target_register = "rdx",
            role = "written with timestamp high result by rdtsc",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdtsc",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdtsc_writes_rax",
            target_register = "rax",
            role = "written with timestamp counter low value by rdtsc",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdtsc",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdtsc_writes_rdx",
            target_register = "rdx",
            role = "written with timestamp counter high value by rdtsc",
        },
        },
    },

    ["rdtscp"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdtscp",
                    },
                },
            },

        operands = {},

        effect = {
            kind = "register_write",
            name = "rdtscp_writes_rax",
            target_register = "rax",
            role = "written with timestamp low result by rdtscp",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdtscp",
                    },
                },
            },

        operands = {},

        effect = {
            kind = "register_write",
            name = "rdtscp_writes_rdx",
            target_register = "rdx",
            role = "written with timestamp high result by rdtscp",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdtscp",
                    },
                },
            },

        operands = {},

        effect = {
            kind = "register_write",
            name = "rdtscp_writes_rcx",
            target_register = "rcx",
            role = "written with processor id by rdtscp",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdtscp",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdtscp_writes_rax",
            target_register = "rax",
            role = "written with timestamp counter low value by rdtscp",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdtscp",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdtscp_writes_rdx",
            target_register = "rdx",
            role = "written with timestamp counter high value by rdtscp",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdtscp",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdtscp_writes_rcx",
            target_register = "rcx",
            role = "written with auxiliary timestamp value by rdtscp",
        },
        },
    },

    ["rdrand"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdrand",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },

        effect = {
            kind = "register_write",
            name = "rdrand_register",
            target_operand = 1,
            role = "written with hardware random value by rdrand",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdrand",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },

        effect = {
            kind = "register_write",
            name = "rdrand_updates_rflags",
            target_register = "rflags",
            role = "updated by rdrand",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdrand",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdrand_updates_rflags",
            target_register = "rflags",
            role = "updated by hardware random value generation rdrand",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdrand",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdrand_writes_destination",
            target_operand = 1,
            role = "written with random value by rdrand",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdrand",
                    },
                },
            },

        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdrand_updates_rflags",
            target_register = "rflags",
            role = "updated with random-value availability status by rdrand",
        },
        },
    },

    ["rdseed"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdseed",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },

        effect = {
            kind = "register_write",
            name = "rdseed_register",
            target_operand = 1,
            role = "written with hardware seed value by rdseed",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdseed",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },

        effect = {
            kind = "register_write",
            name = "rdseed_updates_rflags",
            target_register = "rflags",
            role = "updated by rdseed",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdseed",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdseed_updates_rflags",
            target_register = "rflags",
            role = "updated by hardware seed generation rdseed",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdseed",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdseed_writes_destination",
            target_operand = 1,
            role = "written with random seed value by rdseed",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdseed",
                    },
                },
            },

        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdseed_updates_rflags",
            target_register = "rflags",
            role = "updated with random-seed availability status by rdseed",
        },
        },
    },
}
