-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/control/branches.lua
--
-- x86-64 instruction events: control / branches.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
-- These specs describe branch control flow only; inference/display logic lives
-- in low_level/control_infer.lua and event_tree.lua.

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

            kind = "branch_event",
            category = "control_flow",
            name = "jmp",
            role = "jumps unconditionally to target",

            operands = {
                { index = 1, role = "jump_target" },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump",
                display_name = "jmp",
                role = "jumps unconditionally to target",
            },

            effect = {
                kind = "control_transfer",
                name = "jump",
                role = "jumps unconditionally to target",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "je",
            role = "jumps if equal / zero",
            condition_description = "ZF = 1",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_equal",
                display_name = "je",
                role = "jumps if equal / zero",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_equal",
                role = "jumps if equal / zero",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jz",
            role = "jumps if zero",
            condition_description = "ZF = 1",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_zero",
                display_name = "jz",
                role = "jumps if zero",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_zero",
                role = "jumps if zero",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jne",
            role = "jumps if not equal / not zero",
            condition_description = "ZF = 0",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_not_equal",
                display_name = "jne",
                role = "jumps if not equal / not zero",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_not_equal",
                role = "jumps if not equal / not zero",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jnz",
            role = "jumps if not zero",
            condition_description = "ZF = 0",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_not_zero",
                display_name = "jnz",
                role = "jumps if not zero",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_not_zero",
                role = "jumps if not zero",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "ja",
            role = "jumps if unsigned above",
            condition_description = "CF = 0 and ZF = 0",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_above",
                display_name = "ja",
                role = "jumps if unsigned above",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_above",
                role = "jumps if unsigned above",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jnbe",
            role = "jumps if unsigned above / not below-or-equal",
            condition_description = "CF = 0 and ZF = 0",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_not_below_or_equal",
                display_name = "jnbe",
                role = "jumps if unsigned above / not below-or-equal",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_not_below_or_equal",
                role = "jumps if unsigned above / not below-or-equal",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jae",
            role = "jumps if unsigned above-or-equal",
            condition_description = "CF = 0",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_above_or_equal",
                display_name = "jae",
                role = "jumps if unsigned above-or-equal",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_above_or_equal",
                role = "jumps if unsigned above-or-equal",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jnb",
            role = "jumps if unsigned not below",
            condition_description = "CF = 0",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_not_below",
                display_name = "jnb",
                role = "jumps if unsigned not below",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_not_below",
                role = "jumps if unsigned not below",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jnc",
            role = "jumps if not carry",
            condition_description = "CF = 0",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_not_carry",
                display_name = "jnc",
                role = "jumps if not carry",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_not_carry",
                role = "jumps if not carry",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jb",
            role = "jumps if unsigned below",
            condition_description = "CF = 1",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_below",
                display_name = "jb",
                role = "jumps if unsigned below",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_below",
                role = "jumps if unsigned below",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jnae",
            role = "jumps if unsigned below / not above-or-equal",
            condition_description = "CF = 1",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_not_above_or_equal",
                display_name = "jnae",
                role = "jumps if unsigned below / not above-or-equal",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_not_above_or_equal",
                role = "jumps if unsigned below / not above-or-equal",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jc",
            role = "jumps if carry",
            condition_description = "CF = 1",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_carry",
                display_name = "jc",
                role = "jumps if carry",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_carry",
                role = "jumps if carry",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jbe",
            role = "jumps if unsigned below-or-equal",
            condition_description = "CF = 1 or ZF = 1",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_below_or_equal",
                display_name = "jbe",
                role = "jumps if unsigned below-or-equal",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_below_or_equal",
                role = "jumps if unsigned below-or-equal",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jna",
            role = "jumps if unsigned not above",
            condition_description = "CF = 1 or ZF = 1",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_not_above",
                display_name = "jna",
                role = "jumps if unsigned not above",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_not_above",
                role = "jumps if unsigned not above",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jg",
            role = "jumps if signed greater",
            condition_description = "ZF = 0 and SF = OF",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_greater",
                display_name = "jg",
                role = "jumps if signed greater",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_greater",
                role = "jumps if signed greater",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jnle",
            role = "jumps if signed greater / not less-or-equal",
            condition_description = "ZF = 0 and SF = OF",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_not_less_or_equal",
                display_name = "jnle",
                role = "jumps if signed greater / not less-or-equal",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_not_less_or_equal",
                role = "jumps if signed greater / not less-or-equal",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jge",
            role = "jumps if signed greater-or-equal",
            condition_description = "SF = OF",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_greater_or_equal",
                display_name = "jge",
                role = "jumps if signed greater-or-equal",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_greater_or_equal",
                role = "jumps if signed greater-or-equal",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jnl",
            role = "jumps if signed not less",
            condition_description = "SF = OF",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_not_less",
                display_name = "jnl",
                role = "jumps if signed not less",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_not_less",
                role = "jumps if signed not less",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jl",
            role = "jumps if signed less",
            condition_description = "SF ~= OF",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_less",
                display_name = "jl",
                role = "jumps if signed less",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_less",
                role = "jumps if signed less",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jnge",
            role = "jumps if signed less / not greater-or-equal",
            condition_description = "SF ~= OF",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_not_greater_or_equal",
                display_name = "jnge",
                role = "jumps if signed less / not greater-or-equal",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_not_greater_or_equal",
                role = "jumps if signed less / not greater-or-equal",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jle",
            role = "jumps if signed less-or-equal",
            condition_description = "ZF = 1 or SF ~= OF",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_less_or_equal",
                display_name = "jle",
                role = "jumps if signed less-or-equal",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_less_or_equal",
                role = "jumps if signed less-or-equal",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jng",
            role = "jumps if signed not greater",
            condition_description = "ZF = 1 or SF ~= OF",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_not_greater",
                display_name = "jng",
                role = "jumps if signed not greater",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_not_greater",
                role = "jumps if signed not greater",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jo",
            role = "jumps if overflow",
            condition_description = "OF = 1",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_overflow",
                display_name = "jo",
                role = "jumps if overflow",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_overflow",
                role = "jumps if overflow",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jno",
            role = "jumps if not overflow",
            condition_description = "OF = 0",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_not_overflow",
                display_name = "jno",
                role = "jumps if not overflow",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_not_overflow",
                role = "jumps if not overflow",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jp",
            role = "jumps if parity",
            condition_description = "PF = 1",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_parity",
                display_name = "jp",
                role = "jumps if parity",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_parity",
                role = "jumps if parity",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jpe",
            role = "jumps if parity even",
            condition_description = "PF = 1",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_parity_even",
                display_name = "jpe",
                role = "jumps if parity even",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_parity_even",
                role = "jumps if parity even",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jnp",
            role = "jumps if not parity",
            condition_description = "PF = 0",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_not_parity",
                display_name = "jnp",
                role = "jumps if not parity",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_not_parity",
                role = "jumps if not parity",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jpo",
            role = "jumps if parity odd",
            condition_description = "PF = 0",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_parity_odd",
                display_name = "jpo",
                role = "jumps if parity odd",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_parity_odd",
                role = "jumps if parity odd",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "js",
            role = "jumps if sign",
            condition_description = "SF = 1",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_sign",
                display_name = "js",
                role = "jumps if sign",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_sign",
                role = "jumps if sign",
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

            kind = "conditional_branch_event",
            category = "control_flow",
            name = "jns",
            role = "jumps if not sign",
            condition_description = "SF = 0",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "condition_flags",
                    location = "register",
                    register = "rflags",
                    required = true,
                    present_means_resolved = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_not_sign",
                display_name = "jns",
                role = "jumps if not sign",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_not_sign",
                role = "jumps if not sign",
            },
        },
    },

    ["jcxz"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jcxz",
                    },
                },
            },

            kind = "counter_branch_event",
            category = "control_flow",
            name = "jcxz",
            role = "jumps if cx is zero",
            condition_description = "CX = 0",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "counter",
                    location = "register",
                    register = "cx",
                    required = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_cx_zero",
                display_name = "jcxz",
                role = "jumps if cx is zero",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_cx_zero",
                role = "jumps if cx is zero",
            },
        },
    },

    ["jecxz"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jecxz",
                    },
                },
            },

            kind = "counter_branch_event",
            category = "control_flow",
            name = "jecxz",
            role = "jumps if ecx is zero",
            condition_description = "ECX = 0",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "counter",
                    location = "register",
                    register = "ecx",
                    required = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_ecx_zero",
                display_name = "jecxz",
                role = "jumps if ecx is zero",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_ecx_zero",
                role = "jumps if ecx is zero",
            },
        },
    },

    ["jrcxz"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "jrcxz",
                    },
                },
            },

            kind = "counter_branch_event",
            category = "control_flow",
            name = "jrcxz",
            role = "jumps if rcx is zero",
            condition_description = "RCX = 0",

            operands = {
                { index = 1, role = "jump_target" },
            },

            reads_before = {
                {
                    role = "counter",
                    location = "register",
                    register = "rcx",
                    required = true,
                },
            },

            writes_after = {
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "jump_rcx_zero",
                display_name = "jrcxz",
                role = "jumps if rcx is zero",
            },

            effect = {
                kind = "control_transfer",
                name = "jump_rcx_zero",
                role = "jumps if rcx is zero",
            },
        },
    },
}

