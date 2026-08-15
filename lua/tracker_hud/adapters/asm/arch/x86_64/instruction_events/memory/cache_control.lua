-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/memory/cache_control.lua
--
-- x86-64 instruction events: memory / cache control.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Each entry starts with the exact Tree-sitter syntax identity used to select
-- the instruction. Event/effect data then describes what that syntax means to
-- x86-64 and Tracker_HUD.

return {

    ["clflush"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "clflush",
                    },
                },
            },

            kind = "cache_event",
            category = "cache",
            name = "clflush",
            role = "flushes a cache line",

            operands = {},

            event = {
                name = "clflush_cache_operation",
                display_name = "clflush",
                role = "flushes a cache line",
            },

            effect = {
                kind = "cache_operation",
                name = "clflush_cache_operation",
                role = "flushes a cache line",
            },
        },
    },

    ["clflushopt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "clflushopt",
                    },
                },
            },

            kind = "cache_event",
            category = "cache",
            name = "clflushopt",
            role = "flushes a cache line with optimized ordering",

            operands = {},

            event = {
                name = "clflushopt_cache_operation",
                display_name = "clflushopt",
                role = "flushes a cache line with optimized ordering",
            },

            effect = {
                kind = "cache_operation",
                name = "clflushopt_cache_operation",
                role = "flushes a cache line with optimized ordering",
            },
        },
    },

    ["clwb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "clwb",
                    },
                },
            },

            kind = "cache_event",
            category = "cache",
            name = "clwb",
            role = "writes back a cache line",

            operands = {},

            event = {
                name = "clwb_cache_operation",
                display_name = "clwb",
                role = "writes back a cache line",
            },

            effect = {
                kind = "cache_operation",
                name = "clwb_cache_operation",
                role = "writes back a cache line",
            },
        },
    },

    ["invd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "invd",
                    },
                },
            },

            kind = "cache_event",
            category = "cache",
            name = "invd",
            role = "invalidates processor caches",

            operands = {},

            event = {
                name = "invd_cache_operation",
                display_name = "invd",
                role = "invalidates processor caches",
            },

            effect = {
                kind = "cache_operation",
                name = "invd_cache_operation",
                role = "invalidates processor caches",
            },
        },
    },

    ["wbinvd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "wbinvd",
                    },
                },
            },

            kind = "cache_event",
            category = "cache",
            name = "wbinvd",
            role = "writes back and invalidates processor caches",

            operands = {},

            event = {
                name = "wbinvd_cache_operation",
                display_name = "wbinvd",
                role = "writes back and invalidates processor caches",
            },

            effect = {
                kind = "cache_operation",
                name = "wbinvd_cache_operation",
                role = "writes back and invalidates processor caches",
            },
        },
    },

    ["wbnoinvd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "wbnoinvd",
                    },
                },
            },

            kind = "cache_event",
            category = "cache",
            name = "wbnoinvd",
            role = "writes back processor caches without invalidating them",

            operands = {},

            event = {
                name = "wbnoinvd_cache_writeback",
                display_name = "wbnoinvd",
                role = "writes back processor caches without invalidating them",
            },

            effect = {
                kind = "cache_operation",
                name = "wbnoinvd_cache_writeback",
                role = "writes back processor caches without invalidating them",
            },
        },
    },

    ["clzero"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "clzero",
                    },
                },
            },

            kind = "cache_event",
            category = "cache",
            name = "clzero",
            role = "zeros a cache line",

            operands = {},

            event = {
                name = "clzero_cache_zero",
                display_name = "clzero",
                role = "zeros a cache line",
            },

            effect = {
                kind = "cache_operation",
                name = "clzero_cache_zero",
                role = "zeros a cache line",
            },
        },
    },

    ["cldemote"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cldemote",
                    },
                },
            },

            kind = "cache_event",
            category = "cache",
            name = "cldemote",
            role = "requests demotion of a cache line",

            operands = {
                { index = 1, role = "address" },
            },

            event = {
                name = "cldemote_cache_line_demotion",
                display_name = "cldemote",
                role = "requests demotion of a cache line",
            },

            effect = {
                kind = "cache_operation",
                name = "cldemote_cache_line_demotion",
                role = "requests demotion of a cache line",
            },
        },
    },
}

