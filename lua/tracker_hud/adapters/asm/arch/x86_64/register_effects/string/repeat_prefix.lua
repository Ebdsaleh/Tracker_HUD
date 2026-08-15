-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/string/repeat_prefix.lua
--
-- x86-64 register effects: string / repeat prefix.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["repe_cmpsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repe_cmpsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repe_cmpsb_updates_rflags",
                                target_register = "rflags",
                                role = "updated by repeated byte string compare while equal repe_cmpsb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repe_cmpsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repe_cmpsb_updates_rsi",
                                target_register = "rsi",
                                role = "advanced by repeated byte compare source repe_cmpsb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repe_cmpsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repe_cmpsb_updates_rdi",
                                target_register = "rdi",
                                role = "advanced by repeated byte compare destination repe_cmpsb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repe_cmpsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repe_cmpsb_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by repe_cmpsb",
                            },
        },
    },

    ["repz_cmpsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repz_cmpsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repz_cmpsb_updates_rflags",
                                target_register = "rflags",
                                role = "updated by repeated byte string compare while zero repz_cmpsb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repz_cmpsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repz_cmpsb_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by repz_cmpsb",
                            },
        },
    },

    ["repne_scasb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repne_scasb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repne_scasb_updates_rflags",
                                target_register = "rflags",
                                role = "updated by repeated byte string scan while not equal repne_scasb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repne_scasb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repne_scasb_updates_rdi",
                                target_register = "rdi",
                                role = "advanced by repeated byte string scan destination repne_scasb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repne_scasb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repne_scasb_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by repne_scasb",
                            },
        },
    },

    ["repnz_scasb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repnz_scasb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repnz_scasb_updates_rflags",
                                target_register = "rflags",
                                role = "updated by repeated byte string scan while not zero repnz_scasb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repnz_scasb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repnz_scasb_updates_rdi",
                                target_register = "rdi",
                                role = "advanced by repeated byte string scan destination repnz_scasb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repnz_scasb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repnz_scasb_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by repnz_scasb",
                            },
        },
    },

    ["rep"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_consumes_rcx",
                                target_register = "rcx",
                                role = "used as repeat count by rep",
                            },
        },
    },

    ["repe"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repe",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repe_consumes_rcx",
                                target_register = "rcx",
                                role = "used as repeat count by repe",
                            },
        },
    },

    ["repz"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repz",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repz_consumes_rcx",
                                target_register = "rcx",
                                role = "used as repeat count by repz",
                            },
        },
    },

    ["repne"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repne",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repne_consumes_rcx",
                                target_register = "rcx",
                                role = "used as repeat count by repne",
                            },
        },
    },

    ["repnz"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "repnz",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "repnz_consumes_rcx",
                                target_register = "rcx",
                                role = "used as repeat count by repnz",
                            },
        },
    },

    ["rep_movsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_movsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_movsb_updates_rsi",
                                target_register = "rsi",
                                role = "advanced by repeated byte string move source rep_movsb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_movsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_movsb_updates_rdi",
                                target_register = "rdi",
                                role = "advanced by repeated byte string move destination rep_movsb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_movsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_movsb_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by rep_movsb",
                            },
        },
    },

    ["rep_movsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_movsw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_movsw_updates_rsi",
                                target_register = "rsi",
                                role = "advanced by repeated word string move source rep_movsw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_movsw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_movsw_updates_rdi",
                                target_register = "rdi",
                                role = "advanced by repeated word string move destination rep_movsw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_movsw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_movsw_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by rep_movsw",
                            },
        },
    },

    ["rep_movsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_movsd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_movsd_updates_rsi",
                                target_register = "rsi",
                                role = "advanced by repeated doubleword string move source rep_movsd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_movsd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_movsd_updates_rdi",
                                target_register = "rdi",
                                role = "advanced by repeated doubleword string move destination rep_movsd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_movsd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_movsd_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by rep_movsd",
                            },
        },
    },

    ["rep_movsq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_movsq",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_movsq_updates_rsi",
                                target_register = "rsi",
                                role = "advanced by repeated quadword string move source rep_movsq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_movsq",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_movsq_updates_rdi",
                                target_register = "rdi",
                                role = "advanced by repeated quadword string move destination rep_movsq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_movsq",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_movsq_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by rep_movsq",
                            },
        },
    },

    ["rep_stosb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_stosb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_stosb_updates_rdi",
                                target_register = "rdi",
                                role = "advanced by repeated byte string store destination rep_stosb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_stosb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_stosb_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by rep_stosb",
                            },
        },
    },

    ["rep_stosw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_stosw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_stosw_updates_rdi",
                                target_register = "rdi",
                                role = "advanced by repeated word string store destination rep_stosw",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_stosw",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_stosw_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by rep_stosw",
                            },
        },
    },

    ["rep_stosd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_stosd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_stosd_updates_rdi",
                                target_register = "rdi",
                                role = "advanced by repeated doubleword string store destination rep_stosd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_stosd",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_stosd_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by rep_stosd",
                            },
        },
    },

    ["rep_stosq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_stosq",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_stosq_updates_rdi",
                                target_register = "rdi",
                                role = "advanced by repeated quadword string store destination rep_stosq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_stosq",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_stosq_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by rep_stosq",
                            },
        },
    },

    ["rep_lodsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_lodsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_lodsb_updates_rax",
                                target_register = "rax",
                                role = "loaded repeated byte string value into accumulator by rep_lodsb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_lodsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_lodsb_updates_rsi",
                                target_register = "rsi",
                                role = "advanced by repeated byte string load source rep_lodsb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_lodsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_lodsb_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by rep_lodsb",
                            },
        },
    },

    ["rep_lodsq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_lodsq",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_lodsq_updates_rax",
                                target_register = "rax",
                                role = "loaded repeated quadword string value into accumulator by rep_lodsq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_lodsq",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_lodsq_updates_rsi",
                                target_register = "rsi",
                                role = "advanced by repeated quadword string load source rep_lodsq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_lodsq",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_lodsq_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by rep_lodsq",
                            },
        },
    },

    ["rep_insb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_insb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_insb_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by repeated byte input string rep_insb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_insb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_insb_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by rep_insb",
                            },
        },
    },

    ["rep_insq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_insq",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_insq_updates_rdi",
                                target_register = "rdi",
                                role = "advanced destination pointer by repeated quadword input string rep_insq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_insq",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_insq_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by rep_insq",
                            },
        },
    },

    ["rep_outsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_outsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_outsb_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by repeated byte output string rep_outsb",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_outsb",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_outsb_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by rep_outsb",
                            },
        },
    },

    ["rep_outsq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_outsq",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_outsq_updates_rsi",
                                target_register = "rsi",
                                role = "advanced source pointer by repeated quadword output string rep_outsq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rep_outsq",
                    },
                },
            },

            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "rep_outsq_updates_rcx",
                                target_register = "rcx",
                                role = "consumed repeat count by rep_outsq",
                            },
        },
    },

}
