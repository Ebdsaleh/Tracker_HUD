-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/processor/profiling.lua
--
-- x86-64 register effects: processor / profiling and monitoring.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD register semantics are layered onto that syntax.

return {

    ["rdpmc"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdpmc",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdpmc_writes_rax",
            target_register = "rax",
            role = "written with performance counter low bits by rdpmc",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdpmc",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdpmc_writes_rdx",
            target_register = "rdx",
            role = "written with performance counter high bits by rdpmc",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdpmc",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdpmc_writes_rax",
            target_register = "rax",
            role = "written with performance counter low value by rdpmc",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdpmc",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "rdpmc_writes_rdx",
            target_register = "rdx",
            role = "written with performance counter high value by rdpmc",
        },
        },
    },

    ["slwpcb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "slwpcb",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "slwpcb_writes_destination",
            target_operand = 1,
            role = "written with lightweight profiling control block address by slwpcb",
        },
        },
    },
}
