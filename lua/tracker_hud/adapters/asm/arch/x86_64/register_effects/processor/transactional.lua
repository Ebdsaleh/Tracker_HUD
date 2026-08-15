-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/processor/transactional.lua
--
-- x86-64 register effects: processor / transactional state.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD register semantics are layered onto that syntax.

return {

    ["xbegin"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xbegin",
                    },
                },
            },

        operands = {
            { index = 1, role = "abort_target" },
        },
        effect = {
            kind = "register_write",
            name = "xbegin_may_write_rax",
            target_register = "rax",
            written_alias = "eax",
            role = "may receive transaction abort status by xbegin",
        },
        },
    },

    ["xtest"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xtest",
                    },
                },
            },

        operands = {},
        effect = {
            kind = "register_write",
            name = "xtest_updates_rflags",
            target_register = "rflags",
            role = "updated by transactional state test xtest",
        },
        },
    },
}
