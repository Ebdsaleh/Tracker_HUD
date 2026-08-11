-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor.lua
--
-- x86-64 instruction event specs: processor.
--
-- Rich event specs preserve instruction-event metadata now, so
-- fake RIP register-effect entries can be removed without losing
-- the instruction's event/effect meaning.

return {

    -- processor

    -- cpuid
    {
        kind = "processor_event",
        category = "processor",
        name = "cpuid",
        role = "queries processor information and feature flags",

        node_type = "instruction",
        mnemonic = "cpuid",

        operands = {},

        event = {
            name = "cpuid_processor_query",
            display_name = "cpuid",
            role = "queries processor information and feature flags",
        },

        effect = {
            kind = "processor_query",
            name = "cpuid_processor_query",
            role = "queries processor information and feature flags",
        },
    },

    -- serialization

    -- serialize
    {
        kind = "processor_event",
        category = "serialization",
        name = "serialize",
        role = "serializes instruction execution",

        node_type = "instruction",
        mnemonic = "serialize",

        operands = {},

        event = {
            name = "serialize_processor_serialization",
            display_name = "serialize",
            role = "serializes instruction execution",
        },

        effect = {
            kind = "processor_serialization",
            name = "serialize_processor_serialization",
            role = "serializes instruction execution",
        },
    },

    -- timestamp

    -- rdtsc
    {
        kind = "processor_event",
        category = "timestamp",
        name = "rdtsc",
        role = "reads the processor timestamp counter",

        node_type = "instruction",
        mnemonic = "rdtsc",

        operands = {},

        event = {
            name = "rdtsc_timestamp_read",
            display_name = "rdtsc",
            role = "reads the processor timestamp counter",
        },

        effect = {
            kind = "timestamp_read",
            name = "rdtsc_timestamp_read",
            role = "reads the processor timestamp counter",
        },
    },

    -- rdtscp
    {
        kind = "processor_event",
        category = "timestamp",
        name = "rdtscp",
        role = "reads the processor timestamp counter with ordering",

        node_type = "instruction",
        mnemonic = "rdtscp",

        operands = {},

        event = {
            name = "rdtscp_timestamp_read",
            display_name = "rdtscp",
            role = "reads the processor timestamp counter with ordering",
        },

        effect = {
            kind = "timestamp_read",
            name = "rdtscp_timestamp_read",
            role = "reads the processor timestamp counter with ordering",
        },
    },

    -- random

    -- rdrand
    {
        kind = "processor_event",
        category = "random",
        name = "rdrand",
        role = "reads hardware-generated random data",

        node_type = "instruction",
        mnemonic = "rdrand",

        operands = {},

        event = {
            name = "rdrand_hardware_random_read",
            display_name = "rdrand",
            role = "reads hardware-generated random data",
        },

        effect = {
            kind = "hardware_random_read",
            name = "rdrand_hardware_random_read",
            role = "reads hardware-generated random data",
        },
    },

    -- rdseed
    {
        kind = "processor_event",
        category = "random",
        name = "rdseed",
        role = "reads hardware-generated seed data",

        node_type = "instruction",
        mnemonic = "rdseed",

        operands = {},

        event = {
            name = "rdseed_hardware_random_read",
            display_name = "rdseed",
            role = "reads hardware-generated seed data",
        },

        effect = {
            kind = "hardware_random_read",
            name = "rdseed_hardware_random_read",
            role = "reads hardware-generated seed data",
        },
    },

    -- processor_state

    -- wrmsr
    {
        kind = "processor_state_event",
        category = "processor_state",
        name = "wrmsr",
        role = "writes a model-specific register",

        node_type = "instruction",
        mnemonic = "wrmsr",

        operands = {},

        event = {
            name = "wrmsr_processor_state_write",
            display_name = "wrmsr",
            role = "writes a model-specific register",
        },

        effect = {
            kind = "processor_state_write",
            name = "wrmsr_processor_state_write",
            role = "writes a model-specific register",
        },
    },

    -- rdmsr
    {
        kind = "processor_state_event",
        category = "processor_state",
        name = "rdmsr",
        role = "reads a model-specific register",

        node_type = "instruction",
        mnemonic = "rdmsr",

        operands = {},

        event = {
            name = "rdmsr_processor_state_read",
            display_name = "rdmsr",
            role = "reads a model-specific register",
        },

        effect = {
            kind = "processor_state_read",
            name = "rdmsr_processor_state_read",
            role = "reads a model-specific register",
        },
    },

    -- xgetbv
    {
        kind = "processor_state_event",
        category = "processor_state",
        name = "xgetbv",
        role = "reads extended control register state",

        node_type = "instruction",
        mnemonic = "xgetbv",

        operands = {},

        event = {
            name = "xgetbv_processor_state_read",
            display_name = "xgetbv",
            role = "reads extended control register state",
        },

        effect = {
            kind = "processor_state_read",
            name = "xgetbv_processor_state_read",
            role = "reads extended control register state",
        },
    },

    -- xsetbv
    {
        kind = "processor_state_event",
        category = "processor_state",
        name = "xsetbv",
        role = "writes extended control register state",

        node_type = "instruction",
        mnemonic = "xsetbv",

        operands = {},

        event = {
            name = "xsetbv_processor_state_write",
            display_name = "xsetbv",
            role = "writes extended control register state",
        },

        effect = {
            kind = "processor_state_write",
            name = "xsetbv_processor_state_write",
            role = "writes extended control register state",
        },
    },

    -- extended_state

    -- xsave
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xsave",
        role = "saves extended processor state",

        node_type = "instruction",
        mnemonic = "xsave",

        operands = {},

        event = {
            name = "xsave_processor_state_save",
            display_name = "xsave",
            role = "saves extended processor state",
        },

        effect = {
            kind = "processor_state_save",
            name = "xsave_processor_state_save",
            role = "saves extended processor state",
        },
    },

    -- xsave64
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xsave64",
        role = "saves extended processor state in 64-bit mode",

        node_type = "instruction",
        mnemonic = "xsave64",

        operands = {},

        event = {
            name = "xsave64_processor_state_save",
            display_name = "xsave64",
            role = "saves extended processor state in 64-bit mode",
        },

        effect = {
            kind = "processor_state_save",
            name = "xsave64_processor_state_save",
            role = "saves extended processor state in 64-bit mode",
        },
    },

    -- xsaveopt
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xsaveopt",
        role = "saves modified extended processor state",

        node_type = "instruction",
        mnemonic = "xsaveopt",

        operands = {},

        event = {
            name = "xsaveopt_processor_state_save",
            display_name = "xsaveopt",
            role = "saves modified extended processor state",
        },

        effect = {
            kind = "processor_state_save",
            name = "xsaveopt_processor_state_save",
            role = "saves modified extended processor state",
        },
    },

    -- xsaveopt64
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xsaveopt64",
        role = "saves modified extended processor state in 64-bit mode",

        node_type = "instruction",
        mnemonic = "xsaveopt64",

        operands = {},

        event = {
            name = "xsaveopt64_processor_state_save",
            display_name = "xsaveopt64",
            role = "saves modified extended processor state in 64-bit mode",
        },

        effect = {
            kind = "processor_state_save",
            name = "xsaveopt64_processor_state_save",
            role = "saves modified extended processor state in 64-bit mode",
        },
    },

    -- xsaves
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xsaves",
        role = "saves supervisor/user extended processor state",

        node_type = "instruction",
        mnemonic = "xsaves",

        operands = {},

        event = {
            name = "xsaves_processor_state_save",
            display_name = "xsaves",
            role = "saves supervisor/user extended processor state",
        },

        effect = {
            kind = "processor_state_save",
            name = "xsaves_processor_state_save",
            role = "saves supervisor/user extended processor state",
        },
    },

    -- xsaves64
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xsaves64",
        role = "saves supervisor/user extended processor state in 64-bit mode",

        node_type = "instruction",
        mnemonic = "xsaves64",

        operands = {},

        event = {
            name = "xsaves64_processor_state_save",
            display_name = "xsaves64",
            role = "saves supervisor/user extended processor state in 64-bit mode",
        },

        effect = {
            kind = "processor_state_save",
            name = "xsaves64_processor_state_save",
            role = "saves supervisor/user extended processor state in 64-bit mode",
        },
    },

    -- xsavec
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xsavec",
        role = "saves compacted extended processor state",

        node_type = "instruction",
        mnemonic = "xsavec",

        operands = {},

        event = {
            name = "xsavec_processor_state_save",
            display_name = "xsavec",
            role = "saves compacted extended processor state",
        },

        effect = {
            kind = "processor_state_save",
            name = "xsavec_processor_state_save",
            role = "saves compacted extended processor state",
        },
    },

    -- xsavec64
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xsavec64",
        role = "saves compacted extended processor state in 64-bit mode",

        node_type = "instruction",
        mnemonic = "xsavec64",

        operands = {},

        event = {
            name = "xsavec64_processor_state_save",
            display_name = "xsavec64",
            role = "saves compacted extended processor state in 64-bit mode",
        },

        effect = {
            kind = "processor_state_save",
            name = "xsavec64_processor_state_save",
            role = "saves compacted extended processor state in 64-bit mode",
        },
    },

    -- xrstor
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xrstor",
        role = "restores extended processor state",

        node_type = "instruction",
        mnemonic = "xrstor",

        operands = {},

        event = {
            name = "xrstor_processor_state_restore",
            display_name = "xrstor",
            role = "restores extended processor state",
        },

        effect = {
            kind = "processor_state_restore",
            name = "xrstor_processor_state_restore",
            role = "restores extended processor state",
        },
    },

    -- xrstor64
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xrstor64",
        role = "restores extended processor state in 64-bit mode",

        node_type = "instruction",
        mnemonic = "xrstor64",

        operands = {},

        event = {
            name = "xrstor64_processor_state_restore",
            display_name = "xrstor64",
            role = "restores extended processor state in 64-bit mode",
        },

        effect = {
            kind = "processor_state_restore",
            name = "xrstor64_processor_state_restore",
            role = "restores extended processor state in 64-bit mode",
        },
    },

    -- xrstors
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xrstors",
        role = "restored supervisor extended processor state by xrstors",

        node_type = "instruction",
        mnemonic = "xrstors",

        operands = {},

        event = {
            name = "xrstors_processor_state_restore",
            display_name = "xrstors",
            role = "restored supervisor extended processor state by xrstors",
        },

        effect = {
            kind = "processor_state_restore",
            name = "xrstors_processor_state_restore",
            role = "restored supervisor extended processor state by xrstors",
        },
    },

    -- xrstors64
    {
        kind = "processor_state_event",
        category = "extended_state",
        name = "xrstors64",
        role = "restored supervisor 64-bit extended processor state by xrstors64",

        node_type = "instruction",
        mnemonic = "xrstors64",

        operands = {},

        event = {
            name = "xrstors64_processor_state_restore",
            display_name = "xrstors64",
            role = "restored supervisor 64-bit extended processor state by xrstors64",
        },

        effect = {
            kind = "processor_state_restore",
            name = "xrstors64_processor_state_restore",
            role = "restored supervisor 64-bit extended processor state by xrstors64",
        },
    },

    -- descriptor / control state

    -- lgdt
    {
        kind = "processor_state_event",
        category = "descriptor_state",
        name = "lgdt",
        role = "loads the global descriptor table register",

        node_type = "instruction",
        mnemonic = "lgdt",

        operands = {
            { index = 1, role = "source" },
        },

        event = {
            name = "lgdt_loads_gdtr",
            display_name = "lgdt",
            role = "loads the global descriptor table register",
        },

        effect = {
            kind = "descriptor_state_load",
            name = "lgdt_loads_gdtr",
            role = "loads the global descriptor table register",
        },
    },

    -- sgdt
    {
        kind = "processor_state_event",
        category = "descriptor_state",
        name = "sgdt",
        role = "stores the global descriptor table register",

        node_type = "instruction",
        mnemonic = "sgdt",

        operands = {
            { index = 1, role = "destination" },
        },

        event = {
            name = "sgdt_stores_gdtr",
            display_name = "sgdt",
            role = "stores the global descriptor table register",
        },

        effect = {
            kind = "descriptor_state_store",
            name = "sgdt_stores_gdtr",
            role = "stores the global descriptor table register",
        },
    },

    -- lidt
    {
        kind = "processor_state_event",
        category = "descriptor_state",
        name = "lidt",
        role = "loads the interrupt descriptor table register",

        node_type = "instruction",
        mnemonic = "lidt",

        operands = {
            { index = 1, role = "source" },
        },

        event = {
            name = "lidt_loads_idtr",
            display_name = "lidt",
            role = "loads the interrupt descriptor table register",
        },

        effect = {
            kind = "descriptor_state_load",
            name = "lidt_loads_idtr",
            role = "loads the interrupt descriptor table register",
        },
    },

    -- sidt
    {
        kind = "processor_state_event",
        category = "descriptor_state",
        name = "sidt",
        role = "stores the interrupt descriptor table register",

        node_type = "instruction",
        mnemonic = "sidt",

        operands = {
            { index = 1, role = "destination" },
        },

        event = {
            name = "sidt_stores_idtr",
            display_name = "sidt",
            role = "stores the interrupt descriptor table register",
        },

        effect = {
            kind = "descriptor_state_store",
            name = "sidt_stores_idtr",
            role = "stores the interrupt descriptor table register",
        },
    },

    -- lldt
    {
        kind = "processor_state_event",
        category = "descriptor_state",
        name = "lldt",
        role = "loads the local descriptor table register",

        node_type = "instruction",
        mnemonic = "lldt",

        operands = {
            { index = 1, role = "source" },
        },

        event = {
            name = "lldt_loads_ldtr",
            display_name = "lldt",
            role = "loads the local descriptor table register",
        },

        effect = {
            kind = "descriptor_state_load",
            name = "lldt_loads_ldtr",
            role = "loads the local descriptor table register",
        },
    },

    -- sldt
    {
        kind = "processor_state_event",
        category = "descriptor_state",
        name = "sldt",
        role = "stores the local descriptor table register",

        node_type = "instruction",
        mnemonic = "sldt",

        operands = {
            { index = 1, role = "destination" },
        },

        event = {
            name = "sldt_stores_ldtr",
            display_name = "sldt",
            role = "stores the local descriptor table register",
        },

        effect = {
            kind = "descriptor_state_store",
            name = "sldt_stores_ldtr",
            role = "stores the local descriptor table register",
        },
    },

    -- ltr
    {
        kind = "processor_state_event",
        category = "descriptor_state",
        name = "ltr",
        role = "loads the task register",

        node_type = "instruction",
        mnemonic = "ltr",

        operands = {
            { index = 1, role = "source" },
        },

        event = {
            name = "ltr_loads_task_register",
            display_name = "ltr",
            role = "loads the task register",
        },

        effect = {
            kind = "descriptor_state_load",
            name = "ltr_loads_task_register",
            role = "loads the task register",
        },
    },

    -- str
    {
        kind = "processor_state_event",
        category = "descriptor_state",
        name = "str",
        role = "stores the task register",

        node_type = "instruction",
        mnemonic = "str",

        operands = {
            { index = 1, role = "destination" },
        },

        event = {
            name = "str_stores_task_register",
            display_name = "str",
            role = "stores the task register",
        },

        effect = {
            kind = "descriptor_state_store",
            name = "str_stores_task_register",
            role = "stores the task register",
        },
    },

    -- smsw
    {
        kind = "processor_state_event",
        category = "machine_status",
        name = "smsw",
        role = "stores the machine status word",

        node_type = "instruction",
        mnemonic = "smsw",

        operands = {
            { index = 1, role = "destination" },
        },

        event = {
            name = "smsw_stores_machine_status",
            display_name = "smsw",
            role = "stores the machine status word",
        },

        effect = {
            kind = "machine_status_store",
            name = "smsw_stores_machine_status",
            role = "stores the machine status word",
        },
    },

    -- lmsw
    {
        kind = "processor_state_event",
        category = "machine_status",
        name = "lmsw",
        role = "loads the machine status word",

        node_type = "instruction",
        mnemonic = "lmsw",

        operands = {
            { index = 1, role = "source" },
        },

        event = {
            name = "lmsw_loads_machine_status",
            display_name = "lmsw",
            role = "loads the machine status word",
        },

        effect = {
            kind = "machine_status_load",
            name = "lmsw_loads_machine_status",
            role = "loads the machine status word",
        },
    },

    -- swapgs
    {
        kind = "processor_state_event",
        category = "processor_state",
        name = "swapgs",
        role = "swaps GS base with kernel GS base",

        node_type = "instruction",
        mnemonic = "swapgs",

        operands = {},

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
}

