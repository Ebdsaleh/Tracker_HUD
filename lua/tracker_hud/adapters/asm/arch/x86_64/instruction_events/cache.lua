-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/cache.lua
--
-- x86-64 instruction event specs: cache.
--
-- Rich event specs preserve instruction-event metadata now, so
-- fake RIP register-effect entries can be removed without losing
-- the instruction's event/effect meaning.

return {

    -- memory_order

    -- lfence
    {
        kind = "memory_order_event",
        category = "memory_order",
        name = "lfence",
        role = "orders prior loads before later operations",

        node_type = "instruction",
        mnemonic = "lfence",

        operands = {},

        event = {
            name = "lfence_memory_order",
            display_name = "lfence",
            role = "orders prior loads before later operations",
        },

        effect = {
            kind = "memory_order",
            name = "lfence_memory_order",
            role = "orders prior loads before later operations",
        },
    },

    -- sfence
    {
        kind = "memory_order_event",
        category = "memory_order",
        name = "sfence",
        role = "orders prior stores before later operations",

        node_type = "instruction",
        mnemonic = "sfence",

        operands = {},

        event = {
            name = "sfence_memory_order",
            display_name = "sfence",
            role = "orders prior stores before later operations",
        },

        effect = {
            kind = "memory_order",
            name = "sfence_memory_order",
            role = "orders prior stores before later operations",
        },
    },

    -- mfence
    {
        kind = "memory_order_event",
        category = "memory_order",
        name = "mfence",
        role = "orders prior memory operations before later operations",

        node_type = "instruction",
        mnemonic = "mfence",

        operands = {},

        event = {
            name = "mfence_memory_order",
            display_name = "mfence",
            role = "orders prior memory operations before later operations",
        },

        effect = {
            kind = "memory_order",
            name = "mfence_memory_order",
            role = "orders prior memory operations before later operations",
        },
    },

    -- cache

    -- clflush
    {
        kind = "cache_event",
        category = "cache",
        name = "clflush",
        role = "flushes a cache line",

        node_type = "instruction",
        mnemonic = "clflush",

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

    -- clflushopt
    {
        kind = "cache_event",
        category = "cache",
        name = "clflushopt",
        role = "flushes a cache line with optimized ordering",

        node_type = "instruction",
        mnemonic = "clflushopt",

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

    -- clwb
    {
        kind = "cache_event",
        category = "cache",
        name = "clwb",
        role = "writes back a cache line",

        node_type = "instruction",
        mnemonic = "clwb",

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

    -- invd
    {
        kind = "cache_event",
        category = "cache",
        name = "invd",
        role = "invalidates processor caches",

        node_type = "instruction",
        mnemonic = "invd",

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

    -- wbinvd
    {
        kind = "cache_event",
        category = "cache",
        name = "wbinvd",
        role = "writes back and invalidates processor caches",

        node_type = "instruction",
        mnemonic = "wbinvd",

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

        -- prefetchnta
    {
        kind = "cache_event",
        category = "cache_prefetch",
        name = "prefetchnta",
        role = "prefetches memory with non-temporal locality",

        node_type = "instruction",
        mnemonic = "prefetchnta",

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

    -- prefetcht0
    {
        kind = "cache_event",
        category = "cache_prefetch",
        name = "prefetcht0",
        role = "prefetches memory into all cache levels",

        node_type = "instruction",
        mnemonic = "prefetcht0",

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

    -- prefetcht1
    {
        kind = "cache_event",
        category = "cache_prefetch",
        name = "prefetcht1",
        role = "prefetches memory with temporal locality hint T1",

        node_type = "instruction",
        mnemonic = "prefetcht1",

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

    -- prefetcht2
    {
        kind = "cache_event",
        category = "cache_prefetch",
        name = "prefetcht2",
        role = "prefetches memory with temporal locality hint T2",

        node_type = "instruction",
        mnemonic = "prefetcht2",

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

    -- wbnoinvd
    {
        kind = "cache_event",
        category = "cache",
        name = "wbnoinvd",
        role = "writes back processor caches without invalidating them",

        node_type = "instruction",
        mnemonic = "wbnoinvd",

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

    -- clzero
    {
        kind = "cache_event",
        category = "cache",
        name = "clzero",
        role = "zeros a cache line",

        node_type = "instruction",
        mnemonic = "clzero",

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

    -- cldemote
    {
        kind = "cache_event",
        category = "cache",
        name = "cldemote",
        role = "requests demotion of a cache line",

        node_type = "instruction",
        mnemonic = "cldemote",

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
}

