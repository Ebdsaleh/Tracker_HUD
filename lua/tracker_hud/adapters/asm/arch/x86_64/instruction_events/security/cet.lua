-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/security/cet.lua
--
-- x86-64 instruction events: security / cet.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["endbr32"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "endbr32",
                    },
                },
            },

            kind = "security_event",
            category = "cet_indirect_branch_tracking",
            name = "endbr32",
            role = "marks a valid 32-bit indirect branch target",

            operands = {
            },

            event = {
                name = "endbr32_cet_branch_target",
                display_name = "endbr32",
                role = "marks a valid 32-bit indirect branch target",
            },

            effect = {
                kind = "indirect_branch_tracking",
                name = "endbr32_cet_branch_target",
                role = "marks a valid 32-bit indirect branch target",
            },
        },
    },

    ["endbr64"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "endbr64",
                    },
                },
            },

            kind = "security_event",
            category = "cet_indirect_branch_tracking",
            name = "endbr64",
            role = "marks a valid 64-bit indirect branch target",

            operands = {
            },

            event = {
                name = "endbr64_cet_branch_target",
                display_name = "endbr64",
                role = "marks a valid 64-bit indirect branch target",
            },

            effect = {
                kind = "indirect_branch_tracking",
                name = "endbr64_cet_branch_target",
                role = "marks a valid 64-bit indirect branch target",
            },
        },
    },

    ["setssbsy"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "setssbsy",
                    },
                },
            },

            kind = "security_event",
            category = "shadow_stack",
            name = "setssbsy",
            role = "marks the shadow stack busy",

            operands = {
            },

            event = {
                name = "setssbsy_updates_shadow_stack",
                display_name = "setssbsy",
                role = "marks the shadow stack busy",
            },

            effect = {
                kind = "shadow_stack_busy_state",
                name = "setssbsy_updates_shadow_stack",
                role = "marks the shadow stack busy",
            },
        },
    },

    ["clrssbsy"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "clrssbsy",
                    },
                },
            },

            kind = "security_event",
            category = "shadow_stack",
            name = "clrssbsy",
            role = "clears a shadow-stack busy token",

            operands = {
                { index = 1, role = "token", },
            },

            event = {
                name = "clrssbsy_updates_shadow_stack",
                display_name = "clrssbsy",
                role = "clears a shadow-stack busy token",
            },

            effect = {
                kind = "shadow_stack_busy_state",
                name = "clrssbsy_updates_shadow_stack",
                role = "clears a shadow-stack busy token",
            },
        },
    },

    ["incsspd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "incsspd",
                    },
                },
            },

            kind = "security_event",
            category = "shadow_stack",
            name = "incsspd",
            role = "advances the shadow-stack pointer by a 32-bit count",

            operands = {
                { index = 1, role = "count", },
            },

            event = {
                name = "incsspd_advances_shadow_stack_pointer",
                display_name = "incsspd",
                role = "advances the shadow-stack pointer by a 32-bit count",
            },

            effect = {
                kind = "shadow_stack_pointer_update",
                name = "incsspd_advances_shadow_stack_pointer",
                role = "advances the shadow-stack pointer by a 32-bit count",
            },
        },
    },

    ["incsspq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "incsspq",
                    },
                },
            },

            kind = "security_event",
            category = "shadow_stack",
            name = "incsspq",
            role = "advances the shadow-stack pointer by a 64-bit count",

            operands = {
                { index = 1, role = "count", },
            },

            event = {
                name = "incsspq_advances_shadow_stack_pointer",
                display_name = "incsspq",
                role = "advances the shadow-stack pointer by a 64-bit count",
            },

            effect = {
                kind = "shadow_stack_pointer_update",
                name = "incsspq_advances_shadow_stack_pointer",
                role = "advances the shadow-stack pointer by a 64-bit count",
            },
        },
    },

    ["rstorssp"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rstorssp",
                    },
                },
            },

            kind = "security_event",
            category = "shadow_stack",
            name = "rstorssp",
            role = "restores shadow-stack pointer state",

            operands = {
                { index = 1, role = "source", },
            },

            event = {
                name = "rstorssp_restores_shadow_stack_pointer",
                display_name = "rstorssp",
                role = "restores shadow-stack pointer state",
            },

            effect = {
                kind = "shadow_stack_pointer_restore",
                name = "rstorssp_restores_shadow_stack_pointer",
                role = "restores shadow-stack pointer state",
            },
        },
    },

    ["saveprevssp"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "saveprevssp",
                    },
                },
            },

            kind = "security_event",
            category = "shadow_stack",
            name = "saveprevssp",
            role = "saves the previous shadow-stack pointer",

            operands = {
            },

            event = {
                name = "saveprevssp_saves_previous_shadow_stack_pointer",
                display_name = "saveprevssp",
                role = "saves the previous shadow-stack pointer",
            },

            effect = {
                kind = "shadow_stack_pointer_save",
                name = "saveprevssp_saves_previous_shadow_stack_pointer",
                role = "saves the previous shadow-stack pointer",
            },
        },
    },

    ["wrssd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "wrssd",
                    },
                },
            },

            kind = "security_event",
            category = "shadow_stack",
            name = "wrssd",
            role = "writes 32-bit shadow-stack memory",

            operands = {
                { index = 1, role = "destination", },
                { index = 2, role = "source", },
            },

            event = {
                name = "wrssd_writes_shadow_stack",
                display_name = "wrssd",
                role = "writes 32-bit shadow-stack memory",
            },

            effect = {
                kind = "shadow_stack_write",
                name = "wrssd_writes_shadow_stack",
                role = "writes 32-bit shadow-stack memory",
            },
        },
    },

    ["wrssq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "wrssq",
                    },
                },
            },

            kind = "security_event",
            category = "shadow_stack",
            name = "wrssq",
            role = "writes 64-bit shadow-stack memory",

            operands = {
                { index = 1, role = "destination", },
                { index = 2, role = "source", },
            },

            event = {
                name = "wrssq_writes_shadow_stack",
                display_name = "wrssq",
                role = "writes 64-bit shadow-stack memory",
            },

            effect = {
                kind = "shadow_stack_write",
                name = "wrssq_writes_shadow_stack",
                role = "writes 64-bit shadow-stack memory",
            },
        },
    },

    ["wrussd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "wrussd",
                    },
                },
            },

            kind = "security_event",
            category = "shadow_stack",
            name = "wrussd",
            role = "writes 32-bit user shadow-stack memory",

            operands = {
                { index = 1, role = "destination", },
                { index = 2, role = "source", },
            },

            event = {
                name = "wrussd_writes_user_shadow_stack",
                display_name = "wrussd",
                role = "writes 32-bit user shadow-stack memory",
            },

            effect = {
                kind = "shadow_stack_write",
                name = "wrussd_writes_user_shadow_stack",
                role = "writes 32-bit user shadow-stack memory",
            },
        },
    },

    ["wrussq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "wrussq",
                    },
                },
            },

            kind = "security_event",
            category = "shadow_stack",
            name = "wrussq",
            role = "writes 64-bit user shadow-stack memory",

            operands = {
                { index = 1, role = "destination", },
                { index = 2, role = "source", },
            },

            event = {
                name = "wrussq_writes_user_shadow_stack",
                display_name = "wrussq",
                role = "writes 64-bit user shadow-stack memory",
            },

            effect = {
                kind = "shadow_stack_write",
                name = "wrussq_writes_user_shadow_stack",
                role = "writes 64-bit user shadow-stack memory",
            },
        },
    },
}

