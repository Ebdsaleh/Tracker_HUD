-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/security/platform_security.lua
--
-- x86-64 instruction events: security / platform security.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["pconfig"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pconfig",
                    },
                },
            },

            kind = "security_event",
            category = "platform_configuration",
            name = "pconfig",
            role = "configures platform feature state",

            operands = {
            },

            event = {
                name = "pconfig_configures_platform_state",
                display_name = "pconfig",
                role = "configures platform feature state",
            },

            effect = {
                kind = "platform_configuration",
                name = "pconfig_configures_platform_state",
                role = "configures platform feature state",
            },
        },
    },

    ["rmpadjust"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rmpadjust",
                    },
                },
            },

            kind = "security_event",
            category = "platform_memory_security",
            name = "rmpadjust",
            role = "adjusts reverse map table state",

            operands = {
            },

            event = {
                name = "rmpadjust_adjusts_reverse_map_state",
                display_name = "rmpadjust",
                role = "adjusts reverse map table state",
            },

            effect = {
                kind = "platform_security_state_update",
                name = "rmpadjust_adjusts_reverse_map_state",
                role = "adjusts reverse map table state",
            },
        },
    },

    ["rmpupdate"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rmpupdate",
                    },
                },
            },

            kind = "security_event",
            category = "platform_memory_security",
            name = "rmpupdate",
            role = "updates reverse map table state",

            operands = {
            },

            event = {
                name = "rmpupdate_updates_reverse_map_state",
                display_name = "rmpupdate",
                role = "updates reverse map table state",
            },

            effect = {
                kind = "platform_security_state_update",
                name = "rmpupdate_updates_reverse_map_state",
                role = "updates reverse map table state",
            },
        },
    },

    ["psmash"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psmash",
                    },
                },
            },

            kind = "security_event",
            category = "platform_security",
            name = "psmash",
            role = "split secure nested paging mapping by psmash",

            operands = {},

            event = {
                name = "psmash_updates_platform_state",
                display_name = "psmash",
                role = "split secure nested paging mapping by psmash",
            },

            effect = {
                kind = "platform_security_state",
                name = "psmash_updates_platform_state",
                role = "split secure nested paging mapping by psmash",
            },
        },
    },
}
