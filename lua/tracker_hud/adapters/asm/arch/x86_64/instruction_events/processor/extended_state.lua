-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor/extended_state.lua
--
-- x86-64 instruction events: processor / extended state.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["xgetbv"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xgetbv",
                    },
                },
            },

            kind = "processor_state_event",
            category = "processor_state",
            name = "xgetbv",
            role = "reads extended control register state",

            operands = {
            },

            event = {
                name = "xgetbv_processor_state_read",
                display_name = "xgetbv",
                role = "reads extended control register state",
            },

            effect = {
                kind = "processor_state_read",
                name = "xgetbv_processor_state_read",
                role = "reads extended control register state",
            },
        },
    },

    ["xsetbv"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xsetbv",
                    },
                },
            },

            kind = "processor_state_event",
            category = "processor_state",
            name = "xsetbv",
            role = "writes extended control register state",

            operands = {
            },

            event = {
                name = "xsetbv_processor_state_write",
                display_name = "xsetbv",
                role = "writes extended control register state",
            },

            effect = {
                kind = "processor_state_write",
                name = "xsetbv_processor_state_write",
                role = "writes extended control register state",
            },
        },
    },

    ["xsave"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xsave",
                    },
                },
            },

            kind = "processor_state_event",
            category = "extended_state",
            name = "xsave",
            role = "saves extended processor state",

            operands = {
            },

            event = {
                name = "xsave_processor_state_save",
                display_name = "xsave",
                role = "saves extended processor state",
            },

            effect = {
                kind = "processor_state_save",
                name = "xsave_processor_state_save",
                role = "saves extended processor state",
            },
        },
    },

    ["xsave64"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xsave64",
                    },
                },
            },

            kind = "processor_state_event",
            category = "extended_state",
            name = "xsave64",
            role = "saves extended processor state in 64-bit mode",

            operands = {
            },

            event = {
                name = "xsave64_processor_state_save",
                display_name = "xsave64",
                role = "saves extended processor state in 64-bit mode",
            },

            effect = {
                kind = "processor_state_save",
                name = "xsave64_processor_state_save",
                role = "saves extended processor state in 64-bit mode",
            },
        },
    },

    ["xsaveopt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xsaveopt",
                    },
                },
            },

            kind = "processor_state_event",
            category = "extended_state",
            name = "xsaveopt",
            role = "saves modified extended processor state",

            operands = {
            },

            event = {
                name = "xsaveopt_processor_state_save",
                display_name = "xsaveopt",
                role = "saves modified extended processor state",
            },

            effect = {
                kind = "processor_state_save",
                name = "xsaveopt_processor_state_save",
                role = "saves modified extended processor state",
            },
        },
    },

    ["xsaveopt64"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xsaveopt64",
                    },
                },
            },

            kind = "processor_state_event",
            category = "extended_state",
            name = "xsaveopt64",
            role = "saves modified extended processor state in 64-bit mode",

            operands = {
            },

            event = {
                name = "xsaveopt64_processor_state_save",
                display_name = "xsaveopt64",
                role = "saves modified extended processor state in 64-bit mode",
            },

            effect = {
                kind = "processor_state_save",
                name = "xsaveopt64_processor_state_save",
                role = "saves modified extended processor state in 64-bit mode",
            },
        },
    },

    ["xsaves"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xsaves",
                    },
                },
            },

            kind = "processor_state_event",
            category = "extended_state",
            name = "xsaves",
            role = "saves supervisor/user extended processor state",

            operands = {
            },

            event = {
                name = "xsaves_processor_state_save",
                display_name = "xsaves",
                role = "saves supervisor/user extended processor state",
            },

            effect = {
                kind = "processor_state_save",
                name = "xsaves_processor_state_save",
                role = "saves supervisor/user extended processor state",
            },
        },
    },

    ["xsaves64"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xsaves64",
                    },
                },
            },

            kind = "processor_state_event",
            category = "extended_state",
            name = "xsaves64",
            role = "saves supervisor/user extended processor state in 64-bit mode",

            operands = {
            },

            event = {
                name = "xsaves64_processor_state_save",
                display_name = "xsaves64",
                role = "saves supervisor/user extended processor state in 64-bit mode",
            },

            effect = {
                kind = "processor_state_save",
                name = "xsaves64_processor_state_save",
                role = "saves supervisor/user extended processor state in 64-bit mode",
            },
        },
    },

    ["xsavec"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xsavec",
                    },
                },
            },

            kind = "processor_state_event",
            category = "extended_state",
            name = "xsavec",
            role = "saves compacted extended processor state",

            operands = {
            },

            event = {
                name = "xsavec_processor_state_save",
                display_name = "xsavec",
                role = "saves compacted extended processor state",
            },

            effect = {
                kind = "processor_state_save",
                name = "xsavec_processor_state_save",
                role = "saves compacted extended processor state",
            },
        },
    },

    ["xsavec64"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xsavec64",
                    },
                },
            },

            kind = "processor_state_event",
            category = "extended_state",
            name = "xsavec64",
            role = "saves compacted extended processor state in 64-bit mode",

            operands = {
            },

            event = {
                name = "xsavec64_processor_state_save",
                display_name = "xsavec64",
                role = "saves compacted extended processor state in 64-bit mode",
            },

            effect = {
                kind = "processor_state_save",
                name = "xsavec64_processor_state_save",
                role = "saves compacted extended processor state in 64-bit mode",
            },
        },
    },

    ["xrstor"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xrstor",
                    },
                },
            },

            kind = "processor_state_event",
            category = "extended_state",
            name = "xrstor",
            role = "restores extended processor state",

            operands = {
            },

            event = {
                name = "xrstor_processor_state_restore",
                display_name = "xrstor",
                role = "restores extended processor state",
            },

            effect = {
                kind = "processor_state_restore",
                name = "xrstor_processor_state_restore",
                role = "restores extended processor state",
            },
        },
    },

    ["xrstor64"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xrstor64",
                    },
                },
            },

            kind = "processor_state_event",
            category = "extended_state",
            name = "xrstor64",
            role = "restores extended processor state in 64-bit mode",

            operands = {
            },

            event = {
                name = "xrstor64_processor_state_restore",
                display_name = "xrstor64",
                role = "restores extended processor state in 64-bit mode",
            },

            effect = {
                kind = "processor_state_restore",
                name = "xrstor64_processor_state_restore",
                role = "restores extended processor state in 64-bit mode",
            },
        },
    },

    ["xrstors"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xrstors",
                    },
                },
            },

            kind = "processor_state_event",
            category = "extended_state",
            name = "xrstors",
            role = "restored supervisor extended processor state by xrstors",

            operands = {
            },

            event = {
                name = "xrstors_processor_state_restore",
                display_name = "xrstors",
                role = "restored supervisor extended processor state by xrstors",
            },

            effect = {
                kind = "processor_state_restore",
                name = "xrstors_processor_state_restore",
                role = "restored supervisor extended processor state by xrstors",
            },
        },
    },

    ["xrstors64"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xrstors64",
                    },
                },
            },

            kind = "processor_state_event",
            category = "extended_state",
            name = "xrstors64",
            role = "restored supervisor 64-bit extended processor state by xrstors64",

            operands = {
            },

            event = {
                name = "xrstors64_processor_state_restore",
                display_name = "xrstors64",
                role = "restored supervisor 64-bit extended processor state by xrstors64",
            },

            effect = {
                kind = "processor_state_restore",
                name = "xrstors64_processor_state_restore",
                role = "restored supervisor 64-bit extended processor state by xrstors64",
            },
        },
    },
}

