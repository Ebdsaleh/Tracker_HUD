-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/legacy/compatibility.lua
--
-- x86-64 register effects: legacy / compatibility control transfer.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD register semantics are layered onto that syntax.

return {

    ["lret"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lret",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "lret_updates_rip",
            target_register = "rip",
            role = "far return changed instruction pointer by lret",
        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lret",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "lret_updates_rsp",
            target_register = "rsp",
            role = "far return adjusted stack pointer by lret",
        },
        },
    },

    ["ljmp"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ljmp",
                    },
                },
            },

        operands = {
            { index = 1, role = "far_target" },
        },
        effect = {
            kind = "register_write",
            name = "ljmp_updates_rip",
            target_register = "rip",
            role = "far jump changed instruction pointer by ljmp",
        },
        },
    },
}
