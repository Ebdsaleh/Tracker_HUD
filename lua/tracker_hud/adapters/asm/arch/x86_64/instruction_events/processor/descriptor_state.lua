-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor/descriptor_state.lua
--
-- x86-64 instruction events: processor / descriptor state.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["lgdt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lgdt",
                    },
                },
            },

            kind = "processor_state_event",
            category = "descriptor_state",
            name = "lgdt",
            role = "loads the global descriptor table register",

            operands = {
                { index = 1, role = "source", },
            },

            event = {
                name = "lgdt_loads_gdtr",
                display_name = "lgdt",
                role = "loads the global descriptor table register",
            },

            effect = {
                kind = "descriptor_state_load",
                name = "lgdt_loads_gdtr",
                role = "loads the global descriptor table register",
            },
        },
    },

    ["sgdt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sgdt",
                    },
                },
            },

            kind = "processor_state_event",
            category = "descriptor_state",
            name = "sgdt",
            role = "stores the global descriptor table register",

            operands = {
                { index = 1, role = "destination", },
            },

            event = {
                name = "sgdt_stores_gdtr",
                display_name = "sgdt",
                role = "stores the global descriptor table register",
            },

            effect = {
                kind = "descriptor_state_store",
                name = "sgdt_stores_gdtr",
                role = "stores the global descriptor table register",
            },
        },
    },

    ["lidt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lidt",
                    },
                },
            },

            kind = "processor_state_event",
            category = "descriptor_state",
            name = "lidt",
            role = "loads the interrupt descriptor table register",

            operands = {
                { index = 1, role = "source", },
            },

            event = {
                name = "lidt_loads_idtr",
                display_name = "lidt",
                role = "loads the interrupt descriptor table register",
            },

            effect = {
                kind = "descriptor_state_load",
                name = "lidt_loads_idtr",
                role = "loads the interrupt descriptor table register",
            },
        },
    },

    ["sidt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sidt",
                    },
                },
            },

            kind = "processor_state_event",
            category = "descriptor_state",
            name = "sidt",
            role = "stores the interrupt descriptor table register",

            operands = {
                { index = 1, role = "destination", },
            },

            event = {
                name = "sidt_stores_idtr",
                display_name = "sidt",
                role = "stores the interrupt descriptor table register",
            },

            effect = {
                kind = "descriptor_state_store",
                name = "sidt_stores_idtr",
                role = "stores the interrupt descriptor table register",
            },
        },
    },

    ["lldt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lldt",
                    },
                },
            },

            kind = "processor_state_event",
            category = "descriptor_state",
            name = "lldt",
            role = "loads the local descriptor table register",

            operands = {
                { index = 1, role = "source", },
            },

            event = {
                name = "lldt_loads_ldtr",
                display_name = "lldt",
                role = "loads the local descriptor table register",
            },

            effect = {
                kind = "descriptor_state_load",
                name = "lldt_loads_ldtr",
                role = "loads the local descriptor table register",
            },
        },
    },

    ["sldt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sldt",
                    },
                },
            },

            kind = "processor_state_event",
            category = "descriptor_state",
            name = "sldt",
            role = "stores the local descriptor table register",

            operands = {
                { index = 1, role = "destination", },
            },

            event = {
                name = "sldt_stores_ldtr",
                display_name = "sldt",
                role = "stores the local descriptor table register",
            },

            effect = {
                kind = "descriptor_state_store",
                name = "sldt_stores_ldtr",
                role = "stores the local descriptor table register",
            },
        },
    },

    ["ltr"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ltr",
                    },
                },
            },

            kind = "processor_state_event",
            category = "descriptor_state",
            name = "ltr",
            role = "loads the task register",

            operands = {
                { index = 1, role = "source", },
            },

            event = {
                name = "ltr_loads_task_register",
                display_name = "ltr",
                role = "loads the task register",
            },

            effect = {
                kind = "descriptor_state_load",
                name = "ltr_loads_task_register",
                role = "loads the task register",
            },
        },
    },

    ["str"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "str",
                    },
                },
            },

            kind = "processor_state_event",
            category = "descriptor_state",
            name = "str",
            role = "stores the task register",

            operands = {
                { index = 1, role = "destination", },
            },

            event = {
                name = "str_stores_task_register",
                display_name = "str",
                role = "stores the task register",
            },

            effect = {
                kind = "descriptor_state_store",
                name = "str_stores_task_register",
                role = "stores the task register",
            },
        },
    },
}

