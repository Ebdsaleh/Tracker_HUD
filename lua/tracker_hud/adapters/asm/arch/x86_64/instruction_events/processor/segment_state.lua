-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor/segment_state.lua
--
-- x86-64 instruction events: processor / segment state.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["swapgs"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "swapgs",
                    },
                },
            },

            kind = "processor_state_event",
            category = "processor_state",
            name = "swapgs",
            role = "swaps GS base with kernel GS base",

            operands = {
            },

            event = {
                name = "swapgs_swaps_gs_base",
                display_name = "swapgs",
                role = "swaps GS base with kernel GS base",
            },

            effect = {
                kind = "processor_state_update",
                name = "swapgs_swaps_gs_base",
                role = "swaps GS base with kernel GS base",
            },
        },
    },

    ["wrfsbase"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "wrfsbase",
                    },
                },
            },

            kind = "processor_state_event",
            category = "segment_base_state",
            name = "wrfsbase",
            role = "writes FS base address state",

            operands = {
                { index = 1, role = "source", },
            },

            event = {
                name = "wrfsbase_writes_fs_base",
                display_name = "wrfsbase",
                role = "writes FS base address state",
            },

            effect = {
                kind = "segment_base_state_write",
                name = "wrfsbase_writes_fs_base",
                role = "writes FS base address state",
            },
        },
    },

    ["wrgsbase"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "wrgsbase",
                    },
                },
            },

            kind = "processor_state_event",
            category = "segment_base_state",
            name = "wrgsbase",
            role = "writes GS base address state",

            operands = {
                { index = 1, role = "source", },
            },

            event = {
                name = "wrgsbase_writes_gs_base",
                display_name = "wrgsbase",
                role = "writes GS base address state",
            },

            effect = {
                kind = "segment_base_state_write",
                name = "wrgsbase_writes_gs_base",
                role = "writes GS base address state",
            },
        },
    },
}

