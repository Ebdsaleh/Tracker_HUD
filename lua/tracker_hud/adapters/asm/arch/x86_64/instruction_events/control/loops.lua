-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/control/loops.lua
--
-- x86-64 instruction events: control / counted loops.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.

return {

    ["loop"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loop",
                    },
                },
            },

            kind = "loop_event",
            category = "control_flow",
            name = "loop",
            role = "decrements rcx and jumps if rcx is not zero",
            condition_description = "RCX after decrement != 0",

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
                    role = "loop_counter",
                    location = "register",
                    register = "rcx",
                },
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "loop_decrement_and_branch",
                display_name = "loop",
                role = "decrements rcx and jumps if rcx is not zero",
            },

            effect = {
                kind = "control_transfer",
                name = "loop_decrement_and_branch",
                role = "decrements rcx and jumps if rcx is not zero",
            },
        },
    },

    ["loope"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loope",
                    },
                },
            },

            kind = "loop_event",
            category = "control_flow",
            name = "loope",
            role = "decrements rcx and jumps if rcx is not zero and equal / zero flag is set",
            condition_description = "RCX after decrement != 0 and ZF = 1",

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
                    role = "loop_counter",
                    location = "register",
                    register = "rcx",
                },
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "loope_decrement_and_branch",
                display_name = "loope",
                role = "decrements rcx and jumps if rcx is not zero and equal / zero flag is set",
            },

            effect = {
                kind = "control_transfer",
                name = "loope_decrement_and_branch",
                role = "decrements rcx and jumps if rcx is not zero and equal / zero flag is set",
            },
        },
    },

    ["loopz"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loopz",
                    },
                },
            },

            kind = "loop_event",
            category = "control_flow",
            name = "loopz",
            role = "decrements rcx and jumps if rcx is not zero and zero flag is set",
            condition_description = "RCX after decrement != 0 and ZF = 1",

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
                    role = "loop_counter",
                    location = "register",
                    register = "rcx",
                },
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "loopz_decrement_and_branch",
                display_name = "loopz",
                role = "decrements rcx and jumps if rcx is not zero and zero flag is set",
            },

            effect = {
                kind = "control_transfer",
                name = "loopz_decrement_and_branch",
                role = "decrements rcx and jumps if rcx is not zero and zero flag is set",
            },
        },
    },

    ["loopne"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loopne",
                    },
                },
            },

            kind = "loop_event",
            category = "control_flow",
            name = "loopne",
            role = "decrements rcx and jumps if rcx is not zero and equal / zero flag is clear",
            condition_description = "RCX after decrement != 0 and ZF = 0",

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
                    role = "loop_counter",
                    location = "register",
                    register = "rcx",
                },
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "loopne_decrement_and_branch",
                display_name = "loopne",
                role = "decrements rcx and jumps if rcx is not zero and equal / zero flag is clear",
            },

            effect = {
                kind = "control_transfer",
                name = "loopne_decrement_and_branch",
                role = "decrements rcx and jumps if rcx is not zero and equal / zero flag is clear",
            },
        },
    },

    ["loopnz"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loopnz",
                    },
                },
            },

            kind = "loop_event",
            category = "control_flow",
            name = "loopnz",
            role = "decrements rcx and jumps if rcx is not zero and zero flag is clear",
            condition_description = "RCX after decrement != 0 and ZF = 0",

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
                    role = "loop_counter",
                    location = "register",
                    register = "rcx",
                },
                {
                    role = "instruction_pointer",
                    location = "register",
                    register = "rip",
                },
            },

            event = {
                name = "loopnz_decrement_and_branch",
                display_name = "loopnz",
                role = "decrements rcx and jumps if rcx is not zero and zero flag is clear",
            },

            effect = {
                kind = "control_transfer",
                name = "loopnz_decrement_and_branch",
                role = "decrements rcx and jumps if rcx is not zero and zero flag is clear",
            },
        },
    },
}

