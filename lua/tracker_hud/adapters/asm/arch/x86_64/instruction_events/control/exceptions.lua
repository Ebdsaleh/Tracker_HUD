-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/control/exceptions.lua
--
-- x86-64 instruction events: control / exceptions.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Each entry starts with the exact Tree-sitter syntax identity used to select
-- the instruction. Event/effect data then describes what that syntax means to
-- x86-64 and Tracker_HUD.

return {

    ["bound"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "bound",
                    },
                },
            },

            kind = "processor_event",
            category = "exception_check",
            name = "bound",
            role = "checks an array index against bounds",

            operands = {
                { index = 1, role = "index" },
                { index = 2, role = "bounds" },
            },

            event = {
                name = "bound_checks_array_bounds",
                display_name = "bound",
                role = "checks an array index against bounds",
            },

            effect = {
                kind = "bounds_check",
                name = "bound_checks_array_bounds",
                role = "checks an array index against bounds",
            },
        },
    },

    ["ud0"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ud0",
                    },
                },
            },

            kind = "processor_event",
            category = "exception",
            name = "ud0",
            role = "raises an invalid-instruction exception",

            operands = {},

            event = {
                name = "ud0_invalid_instruction_exception",
                display_name = "ud0",
                role = "raises an invalid-instruction exception",
            },

            effect = {
                kind = "exception",
                name = "ud0_invalid_instruction_exception",
                role = "raises an invalid-instruction exception",
            },
        },
    },

    ["ud1"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ud1",
                    },
                },
            },

            kind = "processor_event",
            category = "exception",
            name = "ud1",
            role = "raises an invalid-instruction exception",

            operands = {},

            event = {
                name = "ud1_invalid_instruction_exception",
                display_name = "ud1",
                role = "raises an invalid-instruction exception",
            },

            effect = {
                kind = "exception",
                name = "ud1_invalid_instruction_exception",
                role = "raises an invalid-instruction exception",
            },
        },
    },

    ["ud2"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ud2",
                    },
                },
            },

            kind = "processor_event",
            category = "exception",
            name = "ud2",
            role = "raises an invalid-instruction exception",

            operands = {},

            event = {
                name = "ud2_invalid_instruction_exception",
                display_name = "ud2",
                role = "raises an invalid-instruction exception",
            },

            effect = {
                kind = "processor_exception",
                name = "ud2_invalid_instruction_exception",
                role = "raises an invalid-instruction exception",
            },
        },
    },

    ["ud2a"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ud2a",
                    },
                },
            },

            kind = "processor_event",
            category = "exception",
            name = "ud2a",
            role = "raises an invalid-instruction exception",

            operands = {},

            event = {
                name = "ud2a_invalid_instruction_exception",
                display_name = "ud2a",
                role = "raises an invalid-instruction exception",
            },

            effect = {
                kind = "exception",
                name = "ud2a_invalid_instruction_exception",
                role = "raises an invalid-instruction exception",
            },
        },
    },
}

