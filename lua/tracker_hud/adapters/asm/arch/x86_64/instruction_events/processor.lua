-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor.lua
--


return {

    -- processor_events

    -- cpuid
    {
        kind = "processor_event",
        category = "processor",
        name = "cpuid",
        role = "queries processor information and feature flags",
        node_type = "instruction",
        mnemonic = "cpuid",
    },

    -- serialize
    {
        kind = "processor_event",
        category = "serialization",
        name = "serialize",
        role = "serializes instruction execution",
        node_type = "instruction",
        mnemonic = "serialize",
    },

    -- rdtsc
    {
        kind = "processor_event",
        category = "timestamp",
        name = "rdtsc",
        role = "reads the processor timestamp counter",
        node_type = "instruction",
        mnemonic = "rdtsc",
    },

    -- rdtscp
    {
        kind = "processor_event",
        category = "timestamp",
        name = "rdtscp",
        role = "reads the processor timestamp counter with ordering",
        node_type = "instruction",
        mnemonic = "rdtscp",
    },

    -- rdrand
    {
        kind = "processor_event",
        category = "random",
        name = "rdrand",
        role = "reads hardware-generated random data",
        node_type = "instruction",
        mnemonic = "rdrand",
    },

    -- rdseed
    {
        kind = "processor_event",
        category = "random",
        name = "rdseed",
        role = "reads hardware-generated seed data",
        node_type = "instruction",
        mnemonic = "rdseed",
    },


    -- processor_state_events

    -- wrmsr
    {
        kind = "processor_state_event",
        category = "processor_state",
        name = "wrmsr",
        role = "writes a model-specific register",
        node_type = "instruction",
        mnemonic = "wrmsr",
    },

    -- rdmsr
    {
        kind = "processor_state_event",
        category = "processor_state",
        name = "rdmsr",
        role = "reads a model-specific register",
        node_type = "instruction",
        mnemonic = "rdmsr",
    },

    -- xgetbv
    {
        kind = "processor_state_event",
        category = "processor_state",
        name = "xgetbv",
        role = "reads extended control register state",
        node_type = "instruction",
        mnemonic = "xgetbv",
    },

    -- xsetbv
    {
        kind = "processor_state_event",
        category = "processor_state",
        name = "xsetbv",
        role = "writes extended control register state",
        node_type = "instruction",
        mnemonic = "xsetbv",
    },

    -- xsave
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xsave",
        role = "saves extended processor state",
        node_type = "instruction",
        mnemonic = "xsave",
    },

    -- xsave64
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xsave64",
        role = "saves extended processor state in 64-bit mode",
        node_type = "instruction",
        mnemonic = "xsave64",
    },

    -- xsaveopt
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xsaveopt",
        role = "saves modified extended processor state",
        node_type = "instruction",
        mnemonic = "xsaveopt",
    },

    -- xsaveopt64
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xsaveopt64",
        role = "saves modified extended processor state in 64-bit mode",
        node_type = "instruction",
        mnemonic = "xsaveopt64",
    },

    -- xsaves
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xsaves",
        role = "saves supervisor/user extended processor state",
        node_type = "instruction",
        mnemonic = "xsaves",
    },

    -- xsaves64
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xsaves64",
        role = "saves supervisor/user extended processor state in 64-bit mode",
        node_type = "instruction",
        mnemonic = "xsaves64",
    },

    -- xrstor
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xrstor",
        role = "restores extended processor state",
        node_type = "instruction",
        mnemonic = "xrstor",
    },

    -- xrstor64
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xrstor64",
        role = "restores extended processor state in 64-bit mode",
        node_type = "instruction",
        mnemonic = "xrstor64",
    },


}
