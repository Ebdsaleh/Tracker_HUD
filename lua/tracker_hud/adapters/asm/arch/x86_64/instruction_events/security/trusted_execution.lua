-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/security/trusted_execution.lua
--
-- x86-64 instruction events: security / trusted execution.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["egetsec"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "egetsec",
                    },
                },
            },

            kind = "security_event",
            category = "trusted_execution",
            name = "egetsec",
            role = "enters a measured security operation",

            operands = {
            },

            event = {
                name = "egetsec_enters_measured_security_operation",
                display_name = "egetsec",
                role = "enters a measured security operation",
            },

            effect = {
                kind = "trusted_execution_operation",
                name = "egetsec_enters_measured_security_operation",
                role = "enters a measured security operation",
            },
        },
    },

    ["senter"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "senter",
                    },
                },
            },

            kind = "security_event",
            category = "trusted_execution",
            name = "senter",
            role = "enters the measured launch environment",

            operands = {
            },

            event = {
                name = "senter_enters_measured_launch_environment",
                display_name = "senter",
                role = "enters the measured launch environment",
            },

            effect = {
                kind = "measured_launch_entry",
                name = "senter_enters_measured_launch_environment",
                role = "enters the measured launch environment",
            },
        },
    },

    ["sexit"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sexit",
                    },
                },
            },

            kind = "security_event",
            category = "trusted_execution",
            name = "sexit",
            role = "exits the measured launch environment",

            operands = {
            },

            event = {
                name = "sexit_exits_measured_launch_environment",
                display_name = "sexit",
                role = "exits the measured launch environment",
            },

            effect = {
                kind = "measured_launch_exit",
                name = "sexit_exits_measured_launch_environment",
                role = "exits the measured launch environment",
            },
        },
    },

    ["getsec"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "getsec",
                    },
                },
            },

            kind = "security_event",
            category = "trusted_execution",
            name = "getsec",
            role = "executes a GETSEC trusted-execution function",

            operands = {
            },

            event = {
                name = "getsec_executes_trusted_execution_function",
                display_name = "getsec",
                role = "executes a GETSEC trusted-execution function",
            },

            effect = {
                kind = "trusted_execution_operation",
                name = "getsec_executes_trusted_execution_function",
                role = "executes a GETSEC trusted-execution function",
            },
        },
    },

    ["skinit"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "skinit",
                    },
                },
            },

            kind = "security_event",
            category = "trusted_execution",
            name = "skinit",
            role = "starts secure kernel initialization",

            operands = {
            },

            event = {
                name = "skinit_starts_secure_kernel_initialization",
                display_name = "skinit",
                role = "starts secure kernel initialization",
            },

            effect = {
                kind = "trusted_execution_operation",
                name = "skinit_starts_secure_kernel_initialization",
                role = "starts secure kernel initialization",
            },
        },
    },
}

