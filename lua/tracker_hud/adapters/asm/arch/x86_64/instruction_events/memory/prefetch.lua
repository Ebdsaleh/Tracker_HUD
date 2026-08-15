-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/memory/prefetch.lua
--
-- x86-64 instruction events: memory / prefetch.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Each entry starts with the exact Tree-sitter syntax identity used to select
-- the instruction. Event/effect data then describes what that syntax means to
-- x86-64 and Tracker_HUD.

return {

    ["prefetchnta"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "prefetchnta",
                    },
                },
            },

            kind = "cache_event",
            category = "cache_prefetch",
            name = "prefetchnta",
            role = "prefetches memory with non-temporal locality",

            operands = {
                { index = 1, role = "memory_operand" },
            },

            event = {
                name = "prefetchnta_prefetches_memory",
                display_name = "prefetchnta",
                role = "prefetches memory with non-temporal locality",
            },

            effect = {
                kind = "cache_prefetch",
                name = "prefetchnta_prefetches_memory",
                role = "prefetches memory with non-temporal locality",
            },
        },
    },

    ["prefetcht0"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "prefetcht0",
                    },
                },
            },

            kind = "cache_event",
            category = "cache_prefetch",
            name = "prefetcht0",
            role = "prefetches memory into all cache levels",

            operands = {
                { index = 1, role = "memory_operand" },
            },

            event = {
                name = "prefetcht0_prefetches_memory",
                display_name = "prefetcht0",
                role = "prefetches memory into all cache levels",
            },

            effect = {
                kind = "cache_prefetch",
                name = "prefetcht0_prefetches_memory",
                role = "prefetches memory into all cache levels",
            },
        },
    },

    ["prefetcht1"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "prefetcht1",
                    },
                },
            },

            kind = "cache_event",
            category = "cache_prefetch",
            name = "prefetcht1",
            role = "prefetches memory with temporal locality hint T1",

            operands = {
                { index = 1, role = "memory_operand" },
            },

            event = {
                name = "prefetcht1_prefetches_memory",
                display_name = "prefetcht1",
                role = "prefetches memory with temporal locality hint T1",
            },

            effect = {
                kind = "cache_prefetch",
                name = "prefetcht1_prefetches_memory",
                role = "prefetches memory with temporal locality hint T1",
            },
        },
    },

    ["prefetcht2"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "prefetcht2",
                    },
                },
            },

            kind = "cache_event",
            category = "cache_prefetch",
            name = "prefetcht2",
            role = "prefetches memory with temporal locality hint T2",

            operands = {
                { index = 1, role = "memory_operand" },
            },

            event = {
                name = "prefetcht2_prefetches_memory",
                display_name = "prefetcht2",
                role = "prefetches memory with temporal locality hint T2",
            },

            effect = {
                kind = "cache_prefetch",
                name = "prefetcht2_prefetches_memory",
                role = "prefetches memory with temporal locality hint T2",
            },
        },
    },
}

