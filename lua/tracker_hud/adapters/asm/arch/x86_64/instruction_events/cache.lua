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
}

