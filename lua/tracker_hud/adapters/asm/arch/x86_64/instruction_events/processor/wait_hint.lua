-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor/wait_hint.lua
--
-- x86-64 instruction events: processor / wait hint.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["monitor"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "monitor",
                    },
                },
            },

            kind = "processor_event",
            category = "monitor_wait",
            name = "monitor",
            role = "arms a monitored memory address",

            operands = {
            },

            event = {
                name = "monitor_arms_monitored_address",
                display_name = "monitor",
                role = "arms a monitored memory address",
            },

            effect = {
                kind = "monitor_wait_setup",
                name = "monitor_arms_monitored_address",
                role = "arms a monitored memory address",
            },
        },
    },

    ["mwait"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "mwait",
                    },
                },
            },

            kind = "processor_event",
            category = "monitor_wait",
            name = "mwait",
            role = "waits for a monitored memory event",

            operands = {
            },

            event = {
                name = "mwait_waits_for_monitored_event",
                display_name = "mwait",
                role = "waits for a monitored memory event",
            },

            effect = {
                kind = "monitor_wait",
                name = "mwait_waits_for_monitored_event",
                role = "waits for a monitored memory event",
            },
        },
    },

    ["umwait"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "umwait",
                    },
                },
            },

            kind = "processor_event",
            category = "monitor_wait",
            name = "umwait",
            role = "waits in user mode until timeout or event",

            operands = {
            },

            event = {
                name = "umwait_user_mode_wait",
                display_name = "umwait",
                role = "waits in user mode until timeout or event",
            },

            effect = {
                kind = "monitor_wait",
                name = "umwait_user_mode_wait",
                role = "waits in user mode until timeout or event",
            },
        },
    },

    ["tpause"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tpause",
                    },
                },
            },

            kind = "processor_event",
            category = "processor_wait",
            name = "tpause",
            role = "pauses execution until timeout or event",

            operands = {
            },

            event = {
                name = "tpause_timed_pause",
                display_name = "tpause",
                role = "pauses execution until timeout or event",
            },

            effect = {
                kind = "processor_wait",
                name = "tpause_timed_pause",
                role = "pauses execution until timeout or event",
            },
        },
    },

    ["pause"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pause",
                    },
                },
            },

            kind = "processor_event",
            category = "processor_hint",
            name = "pause",
            role = "hints a spin-wait loop to the processor",

            operands = {
            },

            event = {
                name = "pause_spin_wait_hint",
                display_name = "pause",
                role = "hints a spin-wait loop to the processor",
            },

            effect = {
                kind = "processor_hint",
                name = "pause_spin_wait_hint",
                role = "hints a spin-wait loop to the processor",
            },
        },
    },

    ["hlt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "hlt",
                    },
                },
            },

            kind = "processor_event",
            category = "processor_wait",
            name = "hlt",
            role = "halts processor execution until an interrupt or event",

            operands = {
            },

            event = {
                name = "hlt_halts_processor",
                display_name = "hlt",
                role = "halts processor execution until an interrupt or event",
            },

            effect = {
                kind = "processor_halt",
                name = "hlt_halts_processor",
                role = "halts processor execution until an interrupt or event",
            },
        },
    },

    ["nop"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "nop",
                    },
                },
            },

            kind = "processor_event",
            category = "processor_hint",
            name = "nop",
            role = "performs no operation",

            operands = {
            },

            event = {
                name = "nop_no_operation",
                display_name = "nop",
                role = "performs no operation",
            },

            effect = {
                kind = "processor_no_operation",
                name = "nop_no_operation",
                role = "performs no operation",
            },
        },
    },

    ["fwait"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fwait",
                    },
                },
            },

            kind = "processor_event",
            category = "processor_wait",
            name = "fwait",
            role = "waits for pending floating-point operations",

            operands = {
            },

            event = {
                name = "fwait_waits_for_fpu",
                display_name = "fwait",
                role = "waits for pending floating-point operations",
            },

            effect = {
                kind = "processor_wait",
                name = "fwait_waits_for_fpu",
                role = "waits for pending floating-point operations",
            },
        },
    },

    ["monitorx"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "monitorx",
                    },
                },
            },

            kind = "processor_event",
            category = "monitor_wait",
            name = "monitorx",
            role = "arms an extended monitored memory address",

            operands = {
            },

            event = {
                name = "monitorx_arms_extended_monitored_address",
                display_name = "monitorx",
                role = "arms an extended monitored memory address",
            },

            effect = {
                kind = "monitor_wait_setup",
                name = "monitorx_arms_extended_monitored_address",
                role = "arms an extended monitored memory address",
            },
        },
    },

    ["mwaitx"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "mwaitx",
                    },
                },
            },

            kind = "processor_event",
            category = "monitor_wait",
            name = "mwaitx",
            role = "waits for an extended monitored memory event",

            operands = {
            },

            event = {
                name = "mwaitx_waits_for_extended_monitored_event",
                display_name = "mwaitx",
                role = "waits for an extended monitored memory event",
            },

            effect = {
                kind = "monitor_wait",
                name = "mwaitx_waits_for_extended_monitored_event",
                role = "waits for an extended monitored memory event",
            },
        },
    },

    ["umonitor"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "umonitor",
                    },
                },
            },

            kind = "processor_event",
            category = "monitor_wait",
            name = "umonitor",
            role = "arms a user-mode monitored memory address",

            operands = {
                { index = 1, role = "address", },
            },

            event = {
                name = "umonitor_arms_user_monitored_address",
                display_name = "umonitor",
                role = "arms a user-mode monitored memory address",
            },

            effect = {
                kind = "monitor_wait_setup",
                name = "umonitor_arms_user_monitored_address",
                role = "arms a user-mode monitored memory address",
            },
        },
    },
}

