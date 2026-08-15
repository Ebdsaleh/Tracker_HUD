-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor/profiling.lua
--
-- x86-64 instruction events: processor / profiling.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["llwpcb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "llwpcb",
                    },
                },
            },

            kind = "processor_event",
            category = "profiling",
            name = "llwpcb",
            role = "loads the lightweight profiling control block",

            operands = {
                { index = 1, role = "address", },
            },

            event = {
                name = "llwpcb_loads_profiling_control_block",
                display_name = "llwpcb",
                role = "loads the lightweight profiling control block",
            },

            effect = {
                kind = "profiling_state_update",
                name = "llwpcb_loads_profiling_control_block",
                role = "loads the lightweight profiling control block",
            },
        },
    },

    ["lwpins"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lwpins",
                    },
                },
            },

            kind = "processor_state_event",
            category = "lightweight_profiling",
            name = "lwpins",
            role = "inserts a lightweight profiling event",

            operands = {
                { index = 1, role = "event_id", },
                { index = 2, role = "event_data", },
                { index = 3, role = "flags", },
            },

            event = {
                name = "lwpins_inserts_profiling_event",
                display_name = "lwpins",
                role = "inserts a lightweight profiling event",
            },

            effect = {
                kind = "profiling_state_update",
                name = "lwpins_inserts_profiling_event",
                role = "inserts a lightweight profiling event",
            },
        },
    },

    ["lwpval"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lwpval",
                    },
                },
            },

            kind = "processor_state_event",
            category = "lightweight_profiling",
            name = "lwpval",
            role = "validates a lightweight profiling event",

            operands = {
                { index = 1, role = "event_id", },
                { index = 2, role = "event_data", },
                { index = 3, role = "flags", },
            },

            event = {
                name = "lwpval_validates_profiling_event",
                display_name = "lwpval",
                role = "validates a lightweight profiling event",
            },

            effect = {
                kind = "profiling_state_update",
                name = "lwpval_validates_profiling_event",
                role = "validates a lightweight profiling event",
            },
        },
    },
}

