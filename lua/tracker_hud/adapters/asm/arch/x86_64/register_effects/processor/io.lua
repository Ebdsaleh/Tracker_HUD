-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/processor/io.lua
--
-- x86-64 register effects: processor / I/O and device commands.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD register semantics are layered onto that syntax.

return {

    ["enqcmd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "enqcmd",
                    },
                },
            },

        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "enqcmd_device_enqueue",
            target_register = "rflags",
            role = "updated by device enqueue command enqcmd",
        },
        },
    },

    ["enqcmds"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "enqcmds",
                    },
                },
            },

        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "enqcmds_device_enqueue",
            target_register = "rflags",
            role = "updated by supervisor device enqueue command enqcmds",
        },
        },
    },

    ["in"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "in",
                    },
                },
            },

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "port" },
        },

        effect = {
            kind = "register_write",
            name = "in_writes_register",
            target_operand = 1,
            role = "written from input port by in",
        },
        },
    },
}
