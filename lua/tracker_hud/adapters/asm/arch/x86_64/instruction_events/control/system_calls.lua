-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/control/system_calls.lua
--
-- x86-64 instruction events: control / system calls.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Each entry starts with the exact Tree-sitter syntax identity used to select
-- the instruction. Event/effect data then describes what that syntax means to
-- x86-64 and Tracker_HUD.

return {

    ["sysenter"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sysenter",
                    },
                },
            },

            kind = "processor_event",
            category = "system_call",
            name = "sysenter",
            role = "enters a fast system-call handler",

            operands = {},

            event = {
                name = "sysenter_system_call_entry",
                display_name = "sysenter",
                role = "enters a fast system-call handler",
            },

            effect = {
                kind = "system_call_entry",
                name = "sysenter_system_call_entry",
                role = "enters a fast system-call handler",
            },
        },
    },

    ["sysexit"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sysexit",
                    },
                },
            },

            kind = "processor_event",
            category = "system_call",
            name = "sysexit",
            role = "returns from a fast system-call handler",

            operands = {},

            event = {
                name = "sysexit_system_call_return",
                display_name = "sysexit",
                role = "returns from a fast system-call handler",
            },

            effect = {
                kind = "system_call_return",
                name = "sysexit_system_call_return",
                role = "returns from a fast system-call handler",
            },
        },
    },

    ["sysret"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sysret",
                    },
                },
            },

            kind = "processor_event",
            category = "system_call",
            name = "sysret",
            role = "returns from a system-call handler",

            operands = {},

            event = {
                name = "sysret_system_call_return",
                display_name = "sysret",
                role = "returns from a system-call handler",
            },

            effect = {
                kind = "system_call_return",
                name = "sysret_system_call_return",
                role = "returns from a system-call handler",
            },
        },
    },

    ["sysretq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sysretq",
                    },
                },
            },

            kind = "processor_event",
            category = "system_call",
            name = "sysretq",
            role = "returns from a system-call handler in 64-bit mode",

            operands = {},

            event = {
                name = "sysretq_system_call_return",
                display_name = "sysretq",
                role = "returns from a system-call handler in 64-bit mode",
            },

            effect = {
                kind = "system_call_return",
                name = "sysretq_system_call_return",
                role = "returns from a system-call handler in 64-bit mode",
            },
        },
    },
}

