-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/control/interrupts.lua
--
-- x86-64 instruction events: control / interrupts.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Each entry starts with the exact Tree-sitter syntax identity used to select
-- the instruction. Event/effect data then describes what that syntax means to
-- x86-64 and Tracker_HUD.

return {

    ["int"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "int",
                    },
                },
            },

            kind = "processor_event",
            category = "interrupt",
            name = "int",
            role = "transfers control through a software interrupt",

            operands = {
                { index = 1, role = "interrupt_vector" },
            },

            event = {
                name = "int_software_interrupt",
                display_name = "int",
                role = "transfers control through a software interrupt",
            },

            effect = {
                kind = "interrupt_transfer",
                name = "int_software_interrupt",
                role = "transfers control through a software interrupt",
            },
        },
    },

    ["int3"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "int3",
                    },
                },
            },

            kind = "processor_event",
            category = "interrupt",
            name = "int3",
            role = "transfers control through the breakpoint interrupt",

            operands = {},

            event = {
                name = "int3_breakpoint_interrupt",
                display_name = "int3",
                role = "transfers control through the breakpoint interrupt",
            },

            effect = {
                kind = "interrupt_transfer",
                name = "int3_breakpoint_interrupt",
                role = "transfers control through the breakpoint interrupt",
            },
        },
    },

    ["into"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "into",
                    },
                },
            },

            kind = "processor_event",
            category = "interrupt",
            name = "into",
            role = "transfers control through the overflow interrupt when overflow is set",

            operands = {},

            event = {
                name = "into_overflow_interrupt",
                display_name = "into",
                role = "transfers control through the overflow interrupt when overflow is set",
            },

            effect = {
                kind = "interrupt_transfer",
                name = "into_overflow_interrupt",
                role = "transfers control through the overflow interrupt when overflow is set",
            },
        },
    },

    ["iret"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "iret",
                    },
                },
            },

            kind = "processor_event",
            category = "interrupt_return",
            name = "iret",
            role = "returns from an interrupt handler",

            operands = {},

            event = {
                name = "iret_interrupt_return",
                display_name = "iret",
                role = "returns from an interrupt handler",
            },

            effect = {
                kind = "interrupt_return",
                name = "iret_interrupt_return",
                role = "returns from an interrupt handler",
            },
        },
    },

    ["iretw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "iretw",
                    },
                },
            },

            kind = "processor_event",
            category = "interrupt_return",
            name = "iretw",
            role = "returns from an interrupt handler using word operand size",

            operands = {},

            event = {
                name = "iretw_interrupt_return",
                display_name = "iretw",
                role = "returns from an interrupt handler using word operand size",
            },

            effect = {
                kind = "interrupt_return",
                name = "iretw_interrupt_return",
                role = "returns from an interrupt handler using word operand size",
            },
        },
    },

    ["iretd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "iretd",
                    },
                },
            },

            kind = "processor_event",
            category = "interrupt_return",
            name = "iretd",
            role = "returns from an interrupt handler using doubleword operand size",

            operands = {},

            event = {
                name = "iretd_interrupt_return",
                display_name = "iretd",
                role = "returns from an interrupt handler using doubleword operand size",
            },

            effect = {
                kind = "interrupt_return",
                name = "iretd_interrupt_return",
                role = "returns from an interrupt handler using doubleword operand size",
            },
        },
    },

    ["iretq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "iretq",
                    },
                },
            },

            kind = "processor_event",
            category = "interrupt_return",
            name = "iretq",
            role = "returns from an interrupt handler in 64-bit mode",

            operands = {},

            event = {
                name = "iretq_interrupt_return",
                display_name = "iretq",
                role = "returns from an interrupt handler in 64-bit mode",
            },

            effect = {
                kind = "interrupt_return",
                name = "iretq_interrupt_return",
                role = "returns from an interrupt handler in 64-bit mode",
            },
        },
    },

    ["icebp"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "icebp",
                    },
                },
            },

            kind = "processor_event",
            category = "interrupt",
            name = "icebp",
            role = "transfers control through the one-byte debug interrupt",

            operands = {},

            event = {
                name = "icebp_debug_interrupt",
                display_name = "icebp",
                role = "transfers control through the one-byte debug interrupt",
            },

            effect = {
                kind = "interrupt_transfer",
                name = "icebp_debug_interrupt",
                role = "transfers control through the one-byte debug interrupt",
            },
        },
    },

    ["int1"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "int1",
                    },
                },
            },

            kind = "processor_event",
            category = "interrupt",
            name = "int1",
            role = "transfers control through the debug interrupt",

            operands = {},

            event = {
                name = "int1_debug_interrupt",
                display_name = "int1",
                role = "transfers control through the debug interrupt",
            },

            effect = {
                kind = "interrupt_transfer",
                name = "int1_debug_interrupt",
                role = "transfers control through the debug interrupt",
            },
        },
    },

    ["uiret"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "uiret",
                    },
                },
            },

            kind = "processor_event",
            category = "interrupt_return",
            name = "uiret",
            role = "returns from a user interrupt handler",

            operands = {},

            event = {
                name = "uiret_user_interrupt_return",
                display_name = "uiret",
                role = "returns from a user interrupt handler",
            },

            effect = {
                kind = "interrupt_return",
                name = "uiret_user_interrupt_return",
                role = "returns from a user interrupt handler",
            },
        },
    },

    ["smi"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "smi",
                    },
                },
            },

            kind = "processor_event",
            category = "processor_mode",
            name = "smi",
            role = "enters the system-management interrupt path",

            operands = {},

            event = {
                name = "smi_enters_system_management_interrupt",
                display_name = "smi",
                role = "enters the system-management interrupt path",
            },

            effect = {
                kind = "processor_mode_entry",
                name = "smi_enters_system_management_interrupt",
                role = "enters the system-management interrupt path",
            },
        },
    },

    ["rsm"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rsm",
                    },
                },
            },

            kind = "processor_event",
            category = "processor_mode",
            name = "rsm",
            role = "resumes execution from system management mode",

            operands = {},

            event = {
                name = "rsm_resumes_from_system_management_mode",
                display_name = "rsm",
                role = "resumes execution from system management mode",
            },

            effect = {
                kind = "processor_mode_return",
                name = "rsm_resumes_from_system_management_mode",
                role = "resumes execution from system management mode",
            },
        },
    },

    ["sti"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sti",
                    },
                },
            },

            kind = "processor_state_event",
            category = "interrupt_state",
            name = "sti",
            role = "sets the interrupt flag",

            operands = {},

            event = {
                name = "sti_sets_interrupt_flag",
                display_name = "sti",
                role = "sets the interrupt flag",
            },

            effect = {
                kind = "interrupt_state_enable",
                name = "sti_sets_interrupt_flag",
                role = "sets the interrupt flag",
            },
        },
    },

    ["cli"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cli",
                    },
                },
            },

            kind = "processor_state_event",
            category = "interrupt_state",
            name = "cli",
            role = "clears the interrupt flag",

            operands = {},

            event = {
                name = "cli_clears_interrupt_flag",
                display_name = "cli",
                role = "clears the interrupt flag",
            },

            effect = {
                kind = "interrupt_state_disable",
                name = "cli_clears_interrupt_flag",
                role = "clears the interrupt flag",
            },
        },
    },
}

