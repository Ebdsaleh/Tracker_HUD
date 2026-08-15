-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/control/transactional.lua
--
-- x86-64 instruction events: control / transactional.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Each entry starts with the exact Tree-sitter syntax identity used to select
-- the instruction. Event/effect data then describes what that syntax means to
-- x86-64 and Tracker_HUD.

return {

    ["xbegin"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xbegin",
                    },
                },
            },

            kind = "processor_event",
            category = "transactional_memory",
            name = "xbegin",
            role = "begins a transactional execution region",

            operands = {
                { index = 1, role = "abort_target" },
            },

            event = {
                name = "xbegin_begins_transaction",
                display_name = "xbegin",
                role = "begins a transactional execution region",
            },

            effect = {
                kind = "transaction_begin",
                name = "xbegin_begins_transaction",
                role = "begins a transactional execution region",
            },
        },
    },

    ["xend"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xend",
                    },
                },
            },

            kind = "processor_event",
            category = "transactional_memory",
            name = "xend",
            role = "ends a transactional execution region",

            operands = {},

            event = {
                name = "xend_ends_transaction",
                display_name = "xend",
                role = "ends a transactional execution region",
            },

            effect = {
                kind = "transaction_end",
                name = "xend_ends_transaction",
                role = "ends a transactional execution region",
            },
        },
    },

    ["xabort"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xabort",
                    },
                },
            },

            kind = "processor_event",
            category = "transactional_memory",
            name = "xabort",
            role = "aborts a transactional execution region",

            operands = {
                { index = 1, role = "abort_code" },
            },

            event = {
                name = "xabort_aborts_transaction",
                display_name = "xabort",
                role = "aborts a transactional execution region",
            },

            effect = {
                kind = "transaction_abort",
                name = "xabort_aborts_transaction",
                role = "aborts a transactional execution region",
            },
        },
    },

    ["xsusldtrk"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xsusldtrk",
                    },
                },
            },

            kind = "processor_event",
            category = "transactional_memory",
            name = "xsusldtrk",
            role = "suspends transactional load tracking",

            operands = {},

            event = {
                name = "xsusldtrk_suspends_load_tracking",
                display_name = "xsusldtrk",
                role = "suspends transactional load tracking",
            },

            effect = {
                kind = "transaction_load_tracking_suspend",
                name = "xsusldtrk_suspends_load_tracking",
                role = "suspends transactional load tracking",
            },
        },
    },

    ["xresldtrk"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xresldtrk",
                    },
                },
            },

            kind = "processor_event",
            category = "transactional_memory",
            name = "xresldtrk",
            role = "resumes transactional load tracking",

            operands = {},

            event = {
                name = "xresldtrk_resumes_load_tracking",
                display_name = "xresldtrk",
                role = "resumes transactional load tracking",
            },

            effect = {
                kind = "transaction_load_tracking_resume",
                name = "xresldtrk_resumes_load_tracking",
                role = "resumes transactional load tracking",
            },
        },
    },
}

