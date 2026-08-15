-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/stack/push_pop.lua
--
-- x86-64 register effects: stack / push and pop.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {

    ["pushfq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pushfq",
                    },
                },
            },

            operands = {},

            effect = {
                kind = "register_write",
                name = "pushfq_updates_rsp",
                target_register = "rsp",
                value_delta = -8,
                role = "decreased by pushfq",
            },
        },
    },

    ["popfq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popfq",
                    },
                },
            },

            operands = {},

            effect = {
                kind = "register_write",
                name = "popfq_updates_rsp",
                target_register = "rsp",
                value_delta = 8,
                role = "increased by popfq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popfq",
                    },
                },
            },

            operands = {},

            effect = {
                kind = "register_write",
                name = "popfq_updates_rflags",
                target_register = "rflags",
                role = "restored from stack by popfq",
            },
        },
    },

    ["pushf"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pushf",
                    },
                },
            },

            operands = {},

            effect = {
                kind = "register_write",
                name = "pushf_updates_rsp",
                target_register = "rsp",
                value_delta = -8,
                role = "decreased by pushf",
            },
        },
    },

    ["popf"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popf",
                    },
                },
            },

            operands = {},

            effect = {
                kind = "register_write",
                name = "popf_updates_rsp",
                target_register = "rsp",
                value_delta = 8,
                role = "increased by popf",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popf",
                    },
                },
            },

            operands = {},

            effect = {
                kind = "register_write",
                name = "popf_updates_rflags",
                target_register = "rflags",
                role = "restored from stack by popf",
            },
        },
    },

    ["popa"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popa",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "popa_increases_rsp",
                target_register = "rsp",
                role = "increased by legacy pop-all popa",
                value_delta = 32,
            },
        },
    },

    ["popad"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popad",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "popad_increases_rsp",
                target_register = "rsp",
                role = "increased by legacy pop-all doubleword popad",
                value_delta = 32,
            },
        },
    },

    ["popal"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popal",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "popal_increases_rsp",
                target_register = "rsp",
                role = "increased by legacy pop-all long popal",
                value_delta = 32,
            },
        },
    },

    ["popaw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popaw",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "popaw_increases_rsp",
                target_register = "rsp",
                role = "increased by legacy pop-all word popaw",
                value_delta = 16,
            },
        },
    },

    ["pushfd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pushfd",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "pushfd_decreases_rsp",
                target_register = "rsp",
                role = "decreased by push flags doubleword pushfd",
                value_delta = -4,
            },
        },
    },

    ["pushfw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pushfw",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "pushfw_decreases_rsp",
                target_register = "rsp",
                role = "decreased by push flags word pushfw",
                value_delta = -2,
            },
        },
    },

    ["popfd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popfd",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "popfd_increases_rsp",
                target_register = "rsp",
                role = "increased by pop flags doubleword popfd",
                value_delta = 4,
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popfd",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "popfd_updates_rflags",
                target_register = "rflags",
                role = "restored by pop flags doubleword popfd",
            },
        },
    },

    ["popfw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popfw",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "popfw_increases_rsp",
                target_register = "rsp",
                role = "increased by pop flags word popfw",
                value_delta = 2,
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popfw",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "popfw_updates_rflags",
                target_register = "rflags",
                role = "restored by pop flags word popfw",
            },
        },
    },

    ["pushq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pushq",
                    },
                },
            },

            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pushq_decreases_rsp",
                target_register = "rsp",
                role = "decreased by quadword push pushq",
                value_delta = -8,
            },
        },
    },

    ["pushl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pushl",
                    },
                },
            },

            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pushl_decreases_rsp",
                target_register = "rsp",
                role = "decreased by long push pushl",
                value_delta = -4,
            },
        },
    },

    ["pushw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pushw",
                    },
                },
            },

            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pushw_decreases_rsp",
                target_register = "rsp",
                role = "decreased by word push pushw",
                value_delta = -2,
            },
        },
    },

    ["popq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popq",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "popq_writes_destination",
                target_operand = 1,
                role = "written by quadword pop popq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "popq_increases_rsp",
                target_register = "rsp",
                role = "increased by quadword pop popq",
                value_delta = 8,
            },
        },
    },

    ["popl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popl",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "popl_writes_destination",
                target_operand = 1,
                role = "written by long pop popl",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popl",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "popl_increases_rsp",
                target_register = "rsp",
                role = "increased by long pop popl",
                value_delta = 4,
            },
        },
    },

    ["popw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popw",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "popw_writes_destination",
                target_operand = 1,
                role = "written by word pop popw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popw",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "popw_increases_rsp",
                target_register = "rsp",
                role = "increased by word pop popw",
                value_delta = 2,
            },
        },
    },

    ["pop"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pop",
                    },
                },
            },

            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
            },

            effect = {
                kind = "register_write",
                name = "pop_register_unknown",
                target_operand = 1,
                role = "loaded from stack by pop",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pop",
                    },
                },
            },

            operands = {
                {
                    index = 1,
                    role = "destination",
                },
            },

            effect = {
                kind = "register_write",
                name = "pop_updates_rsp",
                target_register = "rsp",
                value_delta = 8,
                role = "increased by pop",
            },
        },
    },

    ["push"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "push",
                    },
                },
            },

            operands = {
                {
                    index = 1,
                    role = "pushed_value",
                },
            },

            effect = {
                kind = "register_write",
                name = "push_updates_rsp",
                target_register = "rsp",
                value_delta = -8,
                role = "decreased by push",
            },
        },
    },

    ["pusha"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pusha",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "pusha_decreases_rsp",
                target_register = "rsp",
                role = "decreased by legacy push-all pusha",
                value_delta = -32,
            },
        },
    },

    ["pushad"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pushad",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "pushad_decreases_rsp",
                target_register = "rsp",
                role = "decreased by legacy push-all doubleword pushad",
                value_delta = -32,
            },
        },
    },

    ["pushal"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pushal",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "pushal_decreases_rsp",
                target_register = "rsp",
                role = "decreased by legacy push-all long pushal",
                value_delta = -32,
            },
        },
    },

    ["pushaw"] = {
    {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pushaw",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "pushaw_decreases_rsp",
                target_register = "rsp",
                role = "decreased by legacy push-all word pushaw",
                value_delta = -16,
            },
        },
    },

}
