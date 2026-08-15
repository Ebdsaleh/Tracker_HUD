-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/control/branches.lua
--
-- x86-64 register effects: control / branches.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {

    ["jmp"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jmp",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },

            effect = {
                kind = "register_write",
                name = "jmp_updates_rip",
                target_register = "rip",
                role = "changed by jmp",
            },
        },
    },

    ["ja"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ja",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "ja_updates_rip",
                target_register = "rip",
                role = "conditional jump above by ja",
            },
        },
    },

    ["jae"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jae",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jae_updates_rip",
                target_register = "rip",
                role = "conditional jump above-or-equal by jae",
            },
        },
    },

    ["jb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jb",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jb_updates_rip",
                target_register = "rip",
                role = "conditional jump below by jb",
            },
        },
    },

    ["jbe"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jbe",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jbe_updates_rip",
                target_register = "rip",
                role = "conditional jump below-or-equal by jbe",
            },
        },
    },

    ["jc"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jc",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jc_updates_rip",
                target_register = "rip",
                role = "conditional jump on carry by jc",
            },
        },
    },

    ["jnc"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnc",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnc_updates_rip",
                target_register = "rip",
                role = "conditional jump on not-carry by jnc",
            },
        },
    },

    ["je"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "je",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "je_updates_rip",
                target_register = "rip",
                role = "conditional jump equal by je",
            },
        },
    },

    ["jne"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jne",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jne_updates_rip",
                target_register = "rip",
                role = "conditional jump not-equal by jne",
            },
        },
    },

    ["jz"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jz",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jz_updates_rip",
                target_register = "rip",
                role = "conditional jump zero by jz",
            },
        },
    },

    ["jnz"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnz",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnz_updates_rip",
                target_register = "rip",
                role = "conditional jump not-zero by jnz",
            },
        },
    },

    ["jg"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jg",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jg_updates_rip",
                target_register = "rip",
                role = "conditional jump greater-than by jg",
            },
        },
    },

    ["jge"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jge",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jge_updates_rip",
                target_register = "rip",
                role = "conditional jump greater-or-equal by jge",
            },
        },
    },

    ["jl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jl",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jl_updates_rip",
                target_register = "rip",
                role = "conditional jump less-than by jl",
            },
        },
    },

    ["jle"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jle",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jle_updates_rip",
                target_register = "rip",
                role = "conditional jump less-or-equal by jle",
            },
        },
    },

    ["jo"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jo",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jo_updates_rip",
                target_register = "rip",
                role = "conditional jump on overflow by jo",
            },
        },
    },

    ["jno"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jno",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jno_updates_rip",
                target_register = "rip",
                role = "conditional jump on not-overflow by jno",
            },
        },
    },

    ["js"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "js",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "js_updates_rip",
                target_register = "rip",
                role = "conditional jump on sign by js",
            },
        },
    },

    ["jns"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jns",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jns_updates_rip",
                target_register = "rip",
                role = "conditional jump on not-sign by jns",
            },
        },
    },

    ["jp"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jp",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jp_updates_rip",
                target_register = "rip",
                role = "conditional jump on parity by jp",
            },
        },
    },

    ["jnp"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnp",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnp_updates_rip",
                target_register = "rip",
                role = "conditional jump on not-parity by jnp",
            },
        },
    },

    ["jna"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jna",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jna_updates_rip",
                target_register = "rip",
                role = "conditional jump not-above by jna",
            },
        },
    },

    ["jnae"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnae",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnae_updates_rip",
                target_register = "rip",
                role = "conditional jump not-above-or-equal by jnae",
            },
        },
    },

    ["jnb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnb",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnb_updates_rip",
                target_register = "rip",
                role = "conditional jump not-below by jnb",
            },
        },
    },

    ["jnbe"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnbe",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnbe_updates_rip",
                target_register = "rip",
                role = "conditional jump not-below-or-equal by jnbe",
            },
        },
    },

    ["jnge"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnge",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnge_updates_rip",
                target_register = "rip",
                role = "conditional jump not-greater-or-equal by jnge",
            },
        },
    },

    ["jng"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jng",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jng_updates_rip",
                target_register = "rip",
                role = "conditional jump not-greater by jng",
            },
        },
    },

    ["jnl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnl",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnl_updates_rip",
                target_register = "rip",
                role = "conditional jump not-less by jnl",
            },
        },
    },

    ["jnle"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnle",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnle_updates_rip",
                target_register = "rip",
                role = "conditional jump not-less-or-equal by jnle",
            },
        },
    },

    ["jpe"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jpe",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jpe_updates_rip",
                target_register = "rip",
                role = "conditional jump parity-even by jpe",
            },
        },
    },

    ["jpo"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jpo",
                    },
                },
            },

            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jpo_updates_rip",
                target_register = "rip",
                role = "conditional jump parity-odd by jpo",
            },
        },
    },

    ["jmpf"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jmpf",
                    },
                },
            },

            operands = {
                { index = 1, role = "far_target" },
            },
            effect = {
                kind = "register_write",
                name = "jmpf_updates_rip",
                target_register = "rip",
                role = "far jump changed instruction pointer by jmpf",
            },
        },
    },

    ["jmpq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jmpq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jmpq_updates_rip",
                target_register = "rip",
                role = "jumped to quadword target by jmpq",
            },
        },
    },

    ["jmpl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jmpl",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jmpl_updates_rip",
                target_register = "rip",
                role = "jumped to long target by jmpl",
            },
        },
    },

    ["jmpw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jmpw",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jmpw_updates_rip",
                target_register = "rip",
                role = "jumped to word target by jmpw",
            },
        },
    },

    ["jeq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jeq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jeq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if equal by jeq",
            },
        },
    },

    ["jel"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jel",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jel_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if equal by jel",
            },
        },
    },

    ["jew"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jew",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jew_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if equal by jew",
            },
        },
    },

    ["jzq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jzq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jzq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if zero by jzq",
            },
        },
    },

    ["jzl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jzl",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jzl_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if zero by jzl",
            },
        },
    },

    ["jzw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jzw",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jzw_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if zero by jzw",
            },
        },
    },

    ["jneq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jneq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jneq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not equal by jneq",
            },
        },
    },

    ["jnel"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnel",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnel_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not equal by jnel",
            },
        },
    },

    ["jnew"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnew",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnew_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not equal by jnew",
            },
        },
    },

    ["jnzq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnzq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnzq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not zero by jnzq",
            },
        },
    },

    ["jnzl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnzl",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnzl_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not zero by jnzl",
            },
        },
    },

    ["jnzw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnzw",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnzw_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not zero by jnzw",
            },
        },
    },

    ["jgq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jgq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jgq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed greater by jgq",
            },
        },
    },

    ["jgl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jgl",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jgl_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed greater by jgl",
            },
        },
    },

    ["jgw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jgw",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jgw_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed greater by jgw",
            },
        },
    },

    ["jgeq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jgeq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jgeq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed greater-or-equal by jgeq",
            },
        },
    },

    ["jgel"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jgel",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jgel_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed greater-or-equal by jgel",
            },
        },
    },

    ["jgew"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jgew",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jgew_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed greater-or-equal by jgew",
            },
        },
    },

    ["jlq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jlq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jlq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed less by jlq",
            },
        },
    },

    ["jll"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jll",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jll_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed less by jll",
            },
        },
    },

    ["jlw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jlw",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jlw_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed less by jlw",
            },
        },
    },

    ["jleq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jleq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jleq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed less-or-equal by jleq",
            },
        },
    },

    ["jlel"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jlel",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jlel_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed less-or-equal by jlel",
            },
        },
    },

    ["jlew"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jlew",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jlew_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed less-or-equal by jlew",
            },
        },
    },

    ["jaq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jaq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jaq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned above by jaq",
            },
        },
    },

    ["jal"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jal",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jal_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned above by jal",
            },
        },
    },

    ["jaw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jaw",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jaw_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned above by jaw",
            },
        },
    },

    ["jaeq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jaeq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jaeq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned above-or-equal by jaeq",
            },
        },
    },

    ["jael"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jael",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jael_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned above-or-equal by jael",
            },
        },
    },

    ["jaew"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jaew",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jaew_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned above-or-equal by jaew",
            },
        },
    },

    ["jbq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jbq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jbq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned below by jbq",
            },
        },
    },

    ["jbl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jbl",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jbl_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned below by jbl",
            },
        },
    },

    ["jbw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jbw",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jbw_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned below by jbw",
            },
        },
    },

    ["jbeq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jbeq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jbeq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned below-or-equal by jbeq",
            },
        },
    },

    ["jbel"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jbel",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jbel_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned below-or-equal by jbel",
            },
        },
    },

    ["jbew"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jbew",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jbew_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned below-or-equal by jbew",
            },
        },
    },

    ["jcq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jcq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jcq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if carry by jcq",
            },
        },
    },

    ["jncq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jncq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jncq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not carry by jncq",
            },
        },
    },

    ["jsq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jsq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jsq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if sign by jsq",
            },
        },
    },

    ["jnsq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnsq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnsq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not sign by jnsq",
            },
        },
    },

    ["joq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "joq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "joq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if overflow by joq",
            },
        },
    },

    ["jnoq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnoq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnoq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not overflow by jnoq",
            },
        },
    },

    ["jpq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jpq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jpq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if parity by jpq",
            },
        },
    },

    ["jnpq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnpq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnpq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not parity by jnpq",
            },
        },
    },

    ["jpeq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jpeq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jpeq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if parity even by jpeq",
            },
        },
    },

    ["jpoq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jpoq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jpoq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if parity odd by jpoq",
            },
        },
    },

    ["jngq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jngq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jngq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not signed greater by jngq",
            },
        },
    },

    ["jngeq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jngeq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jngeq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not signed greater-or-equal by jngeq",
            },
        },
    },

    ["jnlq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnlq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnlq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not signed less by jnlq",
            },
        },
    },

    ["jnleq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jnleq",
                    },
                },
            },

            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnleq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not signed less-or-equal by jnleq",
            },
        },
    },

}

