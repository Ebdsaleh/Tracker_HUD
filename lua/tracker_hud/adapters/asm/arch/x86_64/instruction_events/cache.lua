-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/cache.lua

return {

    -- memory_order_events
    -- lfence
    {
        kind = "memory_order_event",
        category = "memory_order",
        name = "lfence",
        role = "orders prior loads before later operations",
        node_type = "instruction",
        mnemonic = "lfence",
    },

    -- sfence
    {
        kind = "memory_order_event",
        category = "memory_order",
        name = "sfence",
        role = "orders prior stores before later operations",
        node_type = "instruction",
        mnemonic = "sfence",
    },

    -- mfence
    {
        kind = "memory_order_event",
        category = "memory_order",
        name = "mfence",
        role = "orders prior memory operations before later operations",
        node_type = "instruction",
        mnemonic = "mfence",
    },


    -- cache_events
    -- clflush
    {
        kind = "cache_event",
        category = "cache",
        name = "clflush",
        role = "flushes a cache line",
        node_type = "instruction",
        mnemonic = "clflush",
    },

    -- clflushopt
    {
        kind = "cache_event",
        category = "cache",
        name = "clflushopt",
        role = "flushes a cache line with optimized ordering",
        node_type = "instruction",
        mnemonic = "clflushopt",
    },

    -- clwb
    {
        kind = "cache_event",
        category = "cache",
        name = "clwb",
        role = "writes back a cache line",
        node_type = "instruction",
        mnemonic = "clwb",
    },

    -- invd
    {
        kind = "cache_event",
        category = "cache",
        name = "invd",
        role = "invalidates processor caches",
        node_type = "instruction",
        mnemonic = "invd",
    },

    -- wbinvd
    {
        kind = "cache_event",
        category = "cache",
        name = "wbinvd",
        role = "writes back and invalidates processor caches",
        node_type = "instruction",
        mnemonic = "wbinvd",
    },

}
