-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/vector_move.lua
--
-- x86-64 legacy vector effects formerly grouped under move register effects.
--
-- Temporary compatibility while the final non-vector leftovers are migrated.

return {
    {
                        node_type = "instruction",
                        mnemonic = "prefetch0",
                        operands = {
                            { index = 1, role = "address" },
                        },
                        effect = {
                            kind = "register_write",
                            name = "prefetch0_cache_hint",
                            target_register = "rip",
                            role = "prefetched data with level-zero locality hint by prefetch0",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "prefetch1",
                        operands = {
                            { index = 1, role = "address" },
                        },
                        effect = {
                            kind = "register_write",
                            name = "prefetch1_cache_hint",
                            target_register = "rip",
                            role = "prefetched data with level-one locality hint by prefetch1",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "prefetch2",
                        operands = {
                            { index = 1, role = "address" },
                        },
                        effect = {
                            kind = "register_write",
                            name = "prefetch2_cache_hint",
                            target_register = "rip",
                            role = "prefetched data with level-two locality hint by prefetch2",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "prefetchit0",
                        operands = {
                            { index = 1, role = "address" },
                        },
                        effect = {
                            kind = "register_write",
                            name = "prefetchit0_code_prefetch_hint",
                            target_register = "rip",
                            role = "prefetched code with level-zero locality hint by prefetchit0",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "prefetchit1",
                        operands = {
                            { index = 1, role = "address" },
                        },
                        effect = {
                            kind = "register_write",
                            name = "prefetchit1_code_prefetch_hint",
                            target_register = "rip",
                            role = "prefetched code with level-one locality hint by prefetchit1",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "ptwrite",
                        operands = {
                            { index = 1, role = "source" },
                        },
                        effect = {
                            kind = "register_write",
                            name = "ptwrite_updates_trace_state",
                            target_register = "rip",
                            role = "wrote value to processor trace stream by ptwrite",
                        },
                    },

}
