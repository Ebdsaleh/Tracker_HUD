-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor/control_state.lua
--
-- x86-64 instruction events: processor / control state.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["wrmsr"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "wrmsr",
                    },
                },
            },

            kind = "processor_state_event",
            category = "processor_state",
            name = "wrmsr",
            role = "writes a model-specific register",

            operands = {
            },

            event = {
                name = "wrmsr_processor_state_write",
                display_name = "wrmsr",
                role = "writes a model-specific register",
            },

            effect = {
                kind = "processor_state_write",
                name = "wrmsr_processor_state_write",
                role = "writes a model-specific register",
            },
        },
    },

    ["rdmsr"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rdmsr",
                    },
                },
            },

            kind = "processor_state_event",
            category = "processor_state",
            name = "rdmsr",
            role = "reads a model-specific register",

            operands = {
            },

            event = {
                name = "rdmsr_processor_state_read",
                display_name = "rdmsr",
                role = "reads a model-specific register",
            },

            effect = {
                kind = "processor_state_read",
                name = "rdmsr_processor_state_read",
                role = "reads a model-specific register",
            },
        },
    },

    ["smsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "smsw",
                    },
                },
            },

            kind = "processor_state_event",
            category = "machine_status",
            name = "smsw",
            role = "stores the machine status word",

            operands = {
                { index = 1, role = "destination", },
            },

            event = {
                name = "smsw_stores_machine_status",
                display_name = "smsw",
                role = "stores the machine status word",
            },

            effect = {
                kind = "machine_status_store",
                name = "smsw_stores_machine_status",
                role = "stores the machine status word",
            },
        },
    },

    ["lmsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lmsw",
                    },
                },
            },

            kind = "processor_state_event",
            category = "machine_status",
            name = "lmsw",
            role = "loads the machine status word",

            operands = {
                { index = 1, role = "source", },
            },

            event = {
                name = "lmsw_loads_machine_status",
                display_name = "lmsw",
                role = "loads the machine status word",
            },

            effect = {
                kind = "machine_status_load",
                name = "lmsw_loads_machine_status",
                role = "loads the machine status word",
            },
        },
    },

    ["clts"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "clts",
                    },
                },
            },

            kind = "processor_state_event",
            category = "processor_state",
            name = "clts",
            role = "clears the task-switched flag",

            operands = {
            },

            event = {
                name = "clts_clears_task_switched_flag",
                display_name = "clts",
                role = "clears the task-switched flag",
            },

            effect = {
                kind = "processor_state_update",
                name = "clts_clears_task_switched_flag",
                role = "clears the task-switched flag",
            },
        },
    },
}

