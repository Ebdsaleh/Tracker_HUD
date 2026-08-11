-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor.lua
--
-- x86-64 instruction event specs: processor.
--
-- Rich event specs preserve instruction-event metadata now, so
-- fake RIP register-effect entries can be removed without losing
-- the instruction's event/effect meaning.
--  759
-- 2095
--


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


        -- interrupt / system-call control transfer

    -- int
    {
        kind = "processor_event",
        category = "interrupt",
        name = "int",
        role = "transfers control through a software interrupt",

        node_type = "instruction",
        mnemonic = "int",

        operands = {
            { index = 1, role = "interrupt_vector" },
        },

        event = {
            name = "int_software_interrupt",
            display_name = "int",
            role = "transfers control through a software interrupt",
        },

        effect = {
            kind = "interrupt_transfer",
            name = "int_software_interrupt",
            role = "transfers control through a software interrupt",
        },
    },

    -- int3
    {
        kind = "processor_event",
        category = "interrupt",
        name = "int3",
        role = "transfers control through the breakpoint interrupt",

        node_type = "instruction",
        mnemonic = "int3",

        operands = {},

        event = {
            name = "int3_breakpoint_interrupt",
            display_name = "int3",
            role = "transfers control through the breakpoint interrupt",
        },

        effect = {
            kind = "interrupt_transfer",
            name = "int3_breakpoint_interrupt",
            role = "transfers control through the breakpoint interrupt",
        },
    },

    -- into
    {
        kind = "processor_event",
        category = "interrupt",
        name = "into",
        role = "transfers control through the overflow interrupt when overflow is set",

        node_type = "instruction",
        mnemonic = "into",

        operands = {},

        event = {
            name = "into_overflow_interrupt",
            display_name = "into",
            role = "transfers control through the overflow interrupt when overflow is set",
        },

        effect = {
            kind = "interrupt_transfer",
            name = "into_overflow_interrupt",
            role = "transfers control through the overflow interrupt when overflow is set",
        },
    },

    -- iret
    {
        kind = "processor_event",
        category = "interrupt_return",
        name = "iret",
        role = "returns from an interrupt handler",

        node_type = "instruction",
        mnemonic = "iret",

        operands = {},

        event = {
            name = "iret_interrupt_return",
            display_name = "iret",
            role = "returns from an interrupt handler",
        },

        effect = {
            kind = "interrupt_return",
            name = "iret_interrupt_return",
            role = "returns from an interrupt handler",
        },
    },

    -- iretw
    {
        kind = "processor_event",
        category = "interrupt_return",
        name = "iretw",
        role = "returns from an interrupt handler using word operand size",

        node_type = "instruction",
        mnemonic = "iretw",

        operands = {},

        event = {
            name = "iretw_interrupt_return",
            display_name = "iretw",
            role = "returns from an interrupt handler using word operand size",
        },

        effect = {
            kind = "interrupt_return",
            name = "iretw_interrupt_return",
            role = "returns from an interrupt handler using word operand size",
        },
    },

    -- iretd
    {
        kind = "processor_event",
        category = "interrupt_return",
        name = "iretd",
        role = "returns from an interrupt handler using doubleword operand size",

        node_type = "instruction",
        mnemonic = "iretd",

        operands = {},

        event = {
            name = "iretd_interrupt_return",
            display_name = "iretd",
            role = "returns from an interrupt handler using doubleword operand size",
        },

        effect = {
            kind = "interrupt_return",
            name = "iretd_interrupt_return",
            role = "returns from an interrupt handler using doubleword operand size",
        },
    },

    -- iretq
    {
        kind = "processor_event",
        category = "interrupt_return",
        name = "iretq",
        role = "returns from an interrupt handler in 64-bit mode",

        node_type = "instruction",
        mnemonic = "iretq",

        operands = {},

        event = {
            name = "iretq_interrupt_return",
            display_name = "iretq",
            role = "returns from an interrupt handler in 64-bit mode",
        },

        effect = {
            kind = "interrupt_return",
            name = "iretq_interrupt_return",
            role = "returns from an interrupt handler in 64-bit mode",
        },
    },

    -- sysenter
    {
        kind = "processor_event",
        category = "system_call",
        name = "sysenter",
        role = "enters a fast system-call handler",

        node_type = "instruction",
        mnemonic = "sysenter",

        operands = {},

        event = {
            name = "sysenter_system_call_entry",
            display_name = "sysenter",
            role = "enters a fast system-call handler",
        },

        effect = {
            kind = "system_call_entry",
            name = "sysenter_system_call_entry",
            role = "enters a fast system-call handler",
        },
    },

    -- sysexit
    {
        kind = "processor_event",
        category = "system_call",
        name = "sysexit",
        role = "returns from a fast system-call handler",

        node_type = "instruction",
        mnemonic = "sysexit",

        operands = {},

        event = {
            name = "sysexit_system_call_return",
            display_name = "sysexit",
            role = "returns from a fast system-call handler",
        },

        effect = {
            kind = "system_call_return",
            name = "sysexit_system_call_return",
            role = "returns from a fast system-call handler",
        },
    },

    -- sysret
    {
        kind = "processor_event",
        category = "system_call",
        name = "sysret",
        role = "returns from a system-call handler",

        node_type = "instruction",
        mnemonic = "sysret",

        operands = {},

        event = {
            name = "sysret_system_call_return",
            display_name = "sysret",
            role = "returns from a system-call handler",
        },

        effect = {
            kind = "system_call_return",
            name = "sysret_system_call_return",
            role = "returns from a system-call handler",
        },
    },

    -- sysretq
    {
        kind = "processor_event",
        category = "system_call",
        name = "sysretq",
        role = "returns from a system-call handler in 64-bit mode",

        node_type = "instruction",
        mnemonic = "sysretq",

        operands = {},

        event = {
            name = "sysretq_system_call_return",
            display_name = "sysretq",
            role = "returns from a system-call handler in 64-bit mode",
        },

        effect = {
            kind = "system_call_return",
            name = "sysretq_system_call_return",
            role = "returns from a system-call handler in 64-bit mode",
        },
    },

       -- icebp
    {
        kind = "processor_event",
        category = "interrupt",
        name = "icebp",
        role = "transfers control through the one-byte debug interrupt",

        node_type = "instruction",
        mnemonic = "icebp",

        operands = {},

        event = {
            name = "icebp_debug_interrupt",
            display_name = "icebp",
            role = "transfers control through the one-byte debug interrupt",
        },

        effect = {
            kind = "interrupt_transfer",
            name = "icebp_debug_interrupt",
            role = "transfers control through the one-byte debug interrupt",
        },
    },

    -- int1
    {
        kind = "processor_event",
        category = "interrupt",
        name = "int1",
        role = "transfers control through the debug interrupt",

        node_type = "instruction",
        mnemonic = "int1",

        operands = {},

        event = {
            name = "int1_debug_interrupt",
            display_name = "int1",
            role = "transfers control through the debug interrupt",
        },

        effect = {
            kind = "interrupt_transfer",
            name = "int1_debug_interrupt",
            role = "transfers control through the debug interrupt",
        },
    },

    -- ud0
    {
        kind = "processor_event",
        category = "exception",
        name = "ud0",
        role = "raises an invalid-instruction exception",

        node_type = "instruction",
        mnemonic = "ud0",

        operands = {},

        event = {
            name = "ud0_invalid_instruction_exception",
            display_name = "ud0",
            role = "raises an invalid-instruction exception",
        },

        effect = {
            kind = "exception",
            name = "ud0_invalid_instruction_exception",
            role = "raises an invalid-instruction exception",
        },
    },

    -- ud1
    {
        kind = "processor_event",
        category = "exception",
        name = "ud1",
        role = "raises an invalid-instruction exception",

        node_type = "instruction",
        mnemonic = "ud1",

        operands = {},

        event = {
            name = "ud1_invalid_instruction_exception",
            display_name = "ud1",
            role = "raises an invalid-instruction exception",
        },

        effect = {
            kind = "exception",
            name = "ud1_invalid_instruction_exception",
            role = "raises an invalid-instruction exception",
        },
    },

    -- ud2
    {
        kind = "processor_event",
        category = "exception",
        name = "ud2",
        role = "raises an invalid-instruction exception",

        node_type = "instruction",
        mnemonic = "ud2",

        operands = {},

        event = {
            name = "ud2_invalid_instruction_exception",
            display_name = "ud2",
            role = "raises an invalid-instruction exception",
        },

        effect = {
            kind = "processor_exception",
            name = "ud2_invalid_instruction_exception",
            role = "raises an invalid-instruction exception",
        },
    },


    -- ud2a
    {
        kind = "processor_event",
        category = "exception",
        name = "ud2a",
        role = "raises an invalid-instruction exception",

        node_type = "instruction",
        mnemonic = "ud2a",

        operands = {},

        event = {
            name = "ud2a_invalid_instruction_exception",
            display_name = "ud2a",
            role = "raises an invalid-instruction exception",
        },

        effect = {
            kind = "exception",
            name = "ud2a_invalid_instruction_exception",
            role = "raises an invalid-instruction exception",
        },
    },

    -- user interrupt / lightweight profiling

    -- uiret
    {
        kind = "processor_event",
        category = "interrupt_return",
        name = "uiret",
        role = "returns from a user interrupt handler",

        node_type = "instruction",
        mnemonic = "uiret",

        operands = {},

        event = {
            name = "uiret_user_interrupt_return",
            display_name = "uiret",
            role = "returns from a user interrupt handler",
        },

        effect = {
            kind = "interrupt_return",
            name = "uiret_user_interrupt_return",
            role = "returns from a user interrupt handler",
        },
    },


 -- processor control / wait / invalidation

    -- monitor
    {
        kind = "processor_event",
        category = "monitor_wait",
        name = "monitor",
        role = "arms a monitored memory address",

        node_type = "instruction",
        mnemonic = "monitor",

        operands = {},

        event = {
            name = "monitor_arms_monitored_address",
            display_name = "monitor",
            role = "arms a monitored memory address",
        },

        effect = {
            kind = "monitor_wait_setup",
            name = "monitor_arms_monitored_address",
            role = "arms a monitored memory address",
        },
    },

    -- mwait
    {
        kind = "processor_event",
        category = "monitor_wait",
        name = "mwait",
        role = "waits for a monitored memory event",

        node_type = "instruction",
        mnemonic = "mwait",

        operands = {},

        event = {
            name = "mwait_waits_for_monitored_event",
            display_name = "mwait",
            role = "waits for a monitored memory event",
        },

        effect = {
            kind = "monitor_wait",
            name = "mwait_waits_for_monitored_event",
            role = "waits for a monitored memory event",
        },
    },

    -- umwait
    {
        kind = "processor_event",
        category = "monitor_wait",
        name = "umwait",
        role = "waits in user mode until timeout or event",

        node_type = "instruction",
        mnemonic = "umwait",

        operands = {},

        event = {
            name = "umwait_user_mode_wait",
            display_name = "umwait",
            role = "waits in user mode until timeout or event",
        },

        effect = {
            kind = "monitor_wait",
            name = "umwait_user_mode_wait",
            role = "waits in user mode until timeout or event",
        },
    },

    -- tpause
    {
        kind = "processor_event",
        category = "processor_wait",
        name = "tpause",
        role = "pauses execution until timeout or event",

        node_type = "instruction",
        mnemonic = "tpause",

        operands = {},

        event = {
            name = "tpause_timed_pause",
            display_name = "tpause",
            role = "pauses execution until timeout or event",
        },

        effect = {
            kind = "processor_wait",
            name = "tpause_timed_pause",
            role = "pauses execution until timeout or event",
        },
    },

    -- pause
    {
        kind = "processor_event",
        category = "processor_hint",
        name = "pause",
        role = "hints a spin-wait loop to the processor",

        node_type = "instruction",
        mnemonic = "pause",

        operands = {},

        event = {
            name = "pause_spin_wait_hint",
            display_name = "pause",
            role = "hints a spin-wait loop to the processor",
        },

        effect = {
            kind = "processor_hint",
            name = "pause_spin_wait_hint",
            role = "hints a spin-wait loop to the processor",
        },
    },

    -- hlt
    {
        kind = "processor_event",
        category = "processor_wait",
        name = "hlt",
        role = "halts processor execution until an interrupt or event",

        node_type = "instruction",
        mnemonic = "hlt",

        operands = {},

        event = {
            name = "hlt_halts_processor",
            display_name = "hlt",
            role = "halts processor execution until an interrupt or event",
        },

        effect = {
            kind = "processor_halt",
            name = "hlt_halts_processor",
            role = "halts processor execution until an interrupt or event",
        },
    },

    -- rsm
    {
        kind = "processor_event",
        category = "processor_mode",
        name = "rsm",
        role = "resumes execution from system management mode",

        node_type = "instruction",
        mnemonic = "rsm",

        operands = {},

        event = {
            name = "rsm_resumes_from_system_management_mode",
            display_name = "rsm",
            role = "resumes execution from system management mode",
        },

        effect = {
            kind = "processor_mode_return",
            name = "rsm_resumes_from_system_management_mode",
            role = "resumes execution from system management mode",
        },
    },

    -- skinit
    {
        kind = "security_event",
        category = "trusted_execution",
        name = "skinit",
        role = "starts secure kernel initialization",

        node_type = "instruction",
        mnemonic = "skinit",

        operands = {},

        event = {
            name = "skinit_starts_secure_kernel_initialization",
            display_name = "skinit",
            role = "starts secure kernel initialization",
        },

        effect = {
            kind = "trusted_execution_operation",
            name = "skinit_starts_secure_kernel_initialization",
            role = "starts secure kernel initialization",
        },
    },

    -- processor no-op / wait / base / transaction state

    -- nop
    {
        kind = "processor_event",
        category = "processor_hint",
        name = "nop",
        role = "performs no operation",

        node_type = "instruction",
        mnemonic = "nop",

        operands = {},

        event = {
            name = "nop_no_operation",
            display_name = "nop",
            role = "performs no operation",
        },

        effect = {
            kind = "processor_no_operation",
            name = "nop_no_operation",
            role = "performs no operation",
        },
    },

    -- fwait
    {
        kind = "processor_event",
        category = "processor_wait",
        name = "fwait",
        role = "waits for pending floating-point operations",

        node_type = "instruction",
        mnemonic = "fwait",

        operands = {},

        event = {
            name = "fwait_waits_for_fpu",
            display_name = "fwait",
            role = "waits for pending floating-point operations",
        },

        effect = {
            kind = "processor_wait",
            name = "fwait_waits_for_fpu",
            role = "waits for pending floating-point operations",
        },
    },

   -- xbegin
    {
        kind = "processor_event",
        category = "transactional_memory",
        name = "xbegin",
        role = "begins a transactional execution region",

        node_type = "instruction",
        mnemonic = "xbegin",

        operands = {
            { index = 1, role = "abort_target" },
        },

        event = {
            name = "xbegin_begins_transaction",
            display_name = "xbegin",
            role = "begins a transactional execution region",
        },

        effect = {
            kind = "transaction_begin",
            name = "xbegin_begins_transaction",
            role = "begins a transactional execution region",
        },
    },

    -- xend
    {
        kind = "processor_event",
        category = "transactional_memory",
        name = "xend",
        role = "ends a transactional execution region",

        node_type = "instruction",
        mnemonic = "xend",

        operands = {},

        event = {
            name = "xend_ends_transaction",
            display_name = "xend",
            role = "ends a transactional execution region",
        },

        effect = {
            kind = "transaction_end",
            name = "xend_ends_transaction",
            role = "ends a transactional execution region",
        },
    },

    -- xabort
    {
        kind = "processor_event",
        category = "transactional_memory",
        name = "xabort",
        role = "aborts a transactional execution region",

        node_type = "instruction",
        mnemonic = "xabort",

        operands = {
            { index = 1, role = "abort_code" },
        },

        event = {
            name = "xabort_aborts_transaction",
            display_name = "xabort",
            role = "aborts a transactional execution region",
        },

        effect = {
            kind = "transaction_abort",
            name = "xabort_aborts_transaction",
            role = "aborts a transactional execution region",
        },
    },

    -- xsusldtrk
    {
        kind = "processor_event",
        category = "transactional_memory",
        name = "xsusldtrk",
        role = "suspends transactional load tracking",

        node_type = "instruction",
        mnemonic = "xsusldtrk",

        operands = {},

        event = {
            name = "xsusldtrk_suspends_load_tracking",
            display_name = "xsusldtrk",
            role = "suspends transactional load tracking",
        },

        effect = {
            kind = "transaction_load_tracking_suspend",
            name = "xsusldtrk_suspends_load_tracking",
            role = "suspends transactional load tracking",
        },
    },

    -- xresldtrk
    {
        kind = "processor_event",
        category = "transactional_memory",
        name = "xresldtrk",
        role = "resumes transactional load tracking",

        node_type = "instruction",
        mnemonic = "xresldtrk",

        operands = {},

        event = {
            name = "xresldtrk_resumes_load_tracking",
            display_name = "xresldtrk",
            role = "resumes transactional load tracking",
        },

        effect = {
            kind = "transaction_load_tracking_resume",
            name = "xresldtrk_resumes_load_tracking",
            role = "resumes transactional load tracking",
        },
    },

    -- monitorx
    {
        kind = "processor_event",
        category = "monitor_wait",
        name = "monitorx",
        role = "arms an extended monitored memory address",

        node_type = "instruction",
        mnemonic = "monitorx",

        operands = {},

        event = {
            name = "monitorx_arms_extended_monitored_address",
            display_name = "monitorx",
            role = "arms an extended monitored memory address",
        },

        effect = {
            kind = "monitor_wait_setup",
            name = "monitorx_arms_extended_monitored_address",
            role = "arms an extended monitored memory address",
        },
    },

    -- mwaitx
    {
        kind = "processor_event",
        category = "monitor_wait",
        name = "mwaitx",
        role = "waits for an extended monitored memory event",

        node_type = "instruction",
        mnemonic = "mwaitx",

        operands = {},

        event = {
            name = "mwaitx_waits_for_extended_monitored_event",
            display_name = "mwaitx",
            role = "waits for an extended monitored memory event",
        },

        effect = {
            kind = "monitor_wait",
            name = "mwaitx_waits_for_extended_monitored_event",
            role = "waits for an extended monitored memory event",
        },
    },

    -- umonitor
    {
        kind = "processor_event",
        category = "monitor_wait",
        name = "umonitor",
        role = "arms a user-mode monitored memory address",

        node_type = "instruction",
        mnemonic = "umonitor",

        operands = {
            { index = 1, role = "address" },
        },

        event = {
            name = "umonitor_arms_user_monitored_address",
            display_name = "umonitor",
            role = "arms a user-mode monitored memory address",
        },

        effect = {
            kind = "monitor_wait_setup",
            name = "umonitor_arms_user_monitored_address",
            role = "arms a user-mode monitored memory address",
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

        -- fpu / simd state management

    -- fxsave
    {
        kind = "processor_state_event",
        category = "fpu_simd_state",
        name = "fxsave",
        role = "saves x87 FPU, MMX, and SSE state",

        node_type = "instruction",
        mnemonic = "fxsave",

        operands = {
            { index = 1, role = "destination" },
        },

        event = {
            name = "fxsave_saves_fpu_simd_state",
            display_name = "fxsave",
            role = "saves x87 FPU, MMX, and SSE state",
        },

        effect = {
            kind = "processor_state_save",
            name = "fxsave_saves_fpu_simd_state",
            role = "saves x87 FPU, MMX, and SSE state",
        },
    },

    -- fxsave64
    {
        kind = "processor_state_event",
        category = "fpu_simd_state",
        name = "fxsave64",
        role = "saves x87 FPU, MMX, and SSE state in 64-bit mode",

        node_type = "instruction",
        mnemonic = "fxsave64",

        operands = {
            { index = 1, role = "destination" },
        },

        event = {
            name = "fxsave64_saves_fpu_simd_state",
            display_name = "fxsave64",
            role = "saves x87 FPU, MMX, and SSE state in 64-bit mode",
        },

        effect = {
            kind = "processor_state_save",
            name = "fxsave64_saves_fpu_simd_state",
            role = "saves x87 FPU, MMX, and SSE state in 64-bit mode",
        },
    },

    -- fxrstor
    {
        kind = "processor_state_event",
        category = "fpu_simd_state",
        name = "fxrstor",
        role = "restores x87 FPU, MMX, and SSE state",

        node_type = "instruction",
        mnemonic = "fxrstor",

        operands = {
            { index = 1, role = "source" },
        },

        event = {
            name = "fxrstor_restores_fpu_simd_state",
            display_name = "fxrstor",
            role = "restores x87 FPU, MMX, and SSE state",
        },

        effect = {
            kind = "processor_state_restore",
            name = "fxrstor_restores_fpu_simd_state",
            role = "restores x87 FPU, MMX, and SSE state",
        },
    },

    -- fxrstor64
    {
        kind = "processor_state_event",
        category = "fpu_simd_state",
        name = "fxrstor64",
        role = "restores x87 FPU, MMX, and SSE state in 64-bit mode",

        node_type = "instruction",
        mnemonic = "fxrstor64",

        operands = {
            { index = 1, role = "source" },
        },

        event = {
            name = "fxrstor64_restores_fpu_simd_state",
            display_name = "fxrstor64",
            role = "restores x87 FPU, MMX, and SSE state in 64-bit mode",
        },

        effect = {
            kind = "processor_state_restore",
            name = "fxrstor64_restores_fpu_simd_state",
            role = "restores x87 FPU, MMX, and SSE state in 64-bit mode",
        },
    },

    -- ldmxcsr
    {
        kind = "processor_state_event",
        category = "mxcsr_state",
        name = "ldmxcsr",
        role = "loads MXCSR control and status state",

        node_type = "instruction",
        mnemonic = "ldmxcsr",

        operands = {
            { index = 1, role = "source" },
        },

        event = {
            name = "ldmxcsr_loads_mxcsr",
            display_name = "ldmxcsr",
            role = "loads MXCSR control and status state",
        },

        effect = {
            kind = "mxcsr_state_load",
            name = "ldmxcsr_loads_mxcsr",
            role = "loads MXCSR control and status state",
        },
    },

    -- stmxcsr
    {
        kind = "processor_state_event",
        category = "mxcsr_state",
        name = "stmxcsr",
        role = "stores MXCSR control and status state",

        node_type = "instruction",
        mnemonic = "stmxcsr",

        operands = {
            { index = 1, role = "destination" },
        },

        event = {
            name = "stmxcsr_stores_mxcsr",
            display_name = "stmxcsr",
            role = "stores MXCSR control and status state",
        },

        effect = {
            kind = "mxcsr_state_store",
            name = "stmxcsr_stores_mxcsr",
            role = "stores MXCSR control and status state",
        },
    },

    -- emms
    {
        kind = "processor_state_event",
        category = "mmx_state",
        name = "emms",
        role = "clears MMX state",

        node_type = "instruction",
        mnemonic = "emms",

        operands = {},

        event = {
            name = "emms_clears_mmx_state",
            display_name = "emms",
            role = "clears MMX state",
        },

        effect = {
            kind = "mmx_state_clear",
            name = "emms_clears_mmx_state",
            role = "clears MMX state",
        },
    },

    -- femms
    {
        kind = "processor_state_event",
        category = "mmx_state",
        name = "femms",
        role = "clears MMX state using fast EMMS",

        node_type = "instruction",
        mnemonic = "femms",

        operands = {},

        event = {
            name = "femms_clears_mmx_state",
            display_name = "femms",
            role = "clears MMX state using fast EMMS",
        },

        effect = {
            kind = "mmx_state_clear",
            name = "femms_clears_mmx_state",
            role = "clears MMX state using fast EMMS",
        },
    },

    -- fninit
    {
        kind = "processor_state_event",
        category = "x87_state",
        name = "fninit",
        role = "initializes x87 FPU state without checking pending exceptions",

        node_type = "instruction",
        mnemonic = "fninit",

        operands = {},

        event = {
            name = "fninit_initializes_fpu_state",
            display_name = "fninit",
            role = "initializes x87 FPU state without checking pending exceptions",
        },

        effect = {
            kind = "x87_state_init",
            name = "fninit_initializes_fpu_state",
            role = "initializes x87 FPU state without checking pending exceptions",
        },
    },

    -- finit
    {
        kind = "processor_state_event",
        category = "x87_state",
        name = "finit",
        role = "initializes x87 FPU state",

        node_type = "instruction",
        mnemonic = "finit",

        operands = {},

        event = {
            name = "finit_initializes_fpu_state",
            display_name = "finit",
            role = "initializes x87 FPU state",
        },

        effect = {
            kind = "x87_state_init",
            name = "finit_initializes_fpu_state",
            role = "initializes x87 FPU state",
        },
    },

    -- fnclex
    {
        kind = "processor_state_event",
        category = "x87_state",
        name = "fnclex",
        role = "clears x87 FPU exception flags without checking pending exceptions",

        node_type = "instruction",
        mnemonic = "fnclex",

        operands = {},

        event = {
            name = "fnclex_clears_fpu_exceptions",
            display_name = "fnclex",
            role = "clears x87 FPU exception flags without checking pending exceptions",
        },

        effect = {
            kind = "x87_exception_clear",
            name = "fnclex_clears_fpu_exceptions",
            role = "clears x87 FPU exception flags without checking pending exceptions",
        },
    },

    -- fclex
    {
        kind = "processor_state_event",
        category = "x87_state",
        name = "fclex",
        role = "clears x87 FPU exception flags",

        node_type = "instruction",
        mnemonic = "fclex",

        operands = {},

        event = {
            name = "fclex_clears_fpu_exceptions",
            display_name = "fclex",
            role = "clears x87 FPU exception flags",
        },

        effect = {
            kind = "x87_exception_clear",
            name = "fclex_clears_fpu_exceptions",
            role = "clears x87 FPU exception flags",
        },
    },

    -- fnstsw
    {
        kind = "processor_state_event",
        category = "x87_state",
        name = "fnstsw",
        role = "stores x87 FPU status word without checking pending exceptions",

        node_type = "instruction",
        mnemonic = "fnstsw",

        operands = {
            { index = 1, role = "destination" },
        },

        event = {
            name = "fnstsw_stores_status_word",
            display_name = "fnstsw",
            role = "stores x87 FPU status word without checking pending exceptions",
        },

        effect = {
            kind = "x87_status_store",
            name = "fnstsw_stores_status_word",
            role = "stores x87 FPU status word without checking pending exceptions",
        },
    },

    -- fstsw
    {
        kind = "processor_state_event",
        category = "x87_state",
        name = "fstsw",
        role = "stores x87 FPU status word",

        node_type = "instruction",
        mnemonic = "fstsw",

        operands = {
            { index = 1, role = "destination" },
        },

        event = {
            name = "fstsw_stores_status_word",
            display_name = "fstsw",
            role = "stores x87 FPU status word",
        },

        effect = {
            kind = "x87_status_store",
            name = "fstsw_stores_status_word",
            role = "stores x87 FPU status word",
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

    -- lwpins
    {
        kind = "processor_state_event",
        category = "lightweight_profiling",
        name = "lwpins",
        role = "inserts a lightweight profiling event",

        node_type = "instruction",
        mnemonic = "lwpins",

        operands = {
            { index = 1, role = "event_id" },
            { index = 2, role = "event_data" },
            { index = 3, role = "flags" },
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

     -- lwpval
    {
        kind = "processor_state_event",
        category = "lightweight_profiling",
        name = "lwpval",
        role = "validates a lightweight profiling event",

        node_type = "instruction",
        mnemonic = "lwpval",

        operands = {
            { index = 1, role = "event_id" },
            { index = 2, role = "event_data" },
            { index = 3, role = "flags" },
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

   
    -- sti
    {
        kind = "processor_state_event",
        category = "interrupt_state",
        name = "sti",
        role = "sets the interrupt flag",

        node_type = "instruction",
        mnemonic = "sti",

        operands = {},

        event = {
            name = "sti_sets_interrupt_flag",
            display_name = "sti",
            role = "sets the interrupt flag",
        },

        effect = {
            kind = "interrupt_state_enable",
            name = "sti_sets_interrupt_flag",
            role = "sets the interrupt flag",
        },
    },

    -- cli
    {
        kind = "processor_state_event",
        category = "interrupt_state",
        name = "cli",
        role = "clears the interrupt flag",

        node_type = "instruction",
        mnemonic = "cli",

        operands = {},

        event = {
            name = "cli_clears_interrupt_flag",
            display_name = "cli",
            role = "clears the interrupt flag",
        },

        effect = {
            kind = "interrupt_state_disable",
            name = "cli_clears_interrupt_flag",
            role = "clears the interrupt flag",
        },
    },

    -- clts
    {
        kind = "processor_state_event",
        category = "processor_state",
        name = "clts",
        role = "clears the task-switched flag",

        node_type = "instruction",
        mnemonic = "clts",

        operands = {},

        event = {
            name = "clts_clears_task_switched_flag",
            display_name = "clts",
            role = "clears the task-switched flag",
        },

        effect = {
            kind = "processor_state_update",
            name = "clts_clears_task_switched_flag",
            role = "clears the task-switched flag",
        },
    },

    -- invlpg
    {
        kind = "processor_state_event",
        category = "tlb_invalidation",
        name = "invlpg",
        role = "invalidates a TLB entry for a memory page",

        node_type = "instruction",
        mnemonic = "invlpg",

        operands = {
            { index = 1, role = "memory_operand" },
        },

        event = {
            name = "invlpg_invalidates_page_tlb_entry",
            display_name = "invlpg",
            role = "invalidates a TLB entry for a memory page",
        },

        effect = {
            kind = "tlb_invalidation",
            name = "invlpg_invalidates_page_tlb_entry",
            role = "invalidates a TLB entry for a memory page",
        },
    },

    -- invlpga
    {
        kind = "processor_state_event",
        category = "tlb_invalidation",
        name = "invlpga",
        role = "invalidates a TLB entry for an address space",

        node_type = "instruction",
        mnemonic = "invlpga",

        operands = {},

        event = {
            name = "invlpga_invalidates_address_space_tlb_entry",
            display_name = "invlpga",
            role = "invalidates a TLB entry for an address space",
        },

        effect = {
            kind = "tlb_invalidation",
            name = "invlpga_invalidates_address_space_tlb_entry",
            role = "invalidates a TLB entry for an address space",
        },
    },

    -- invpcid
    {
        kind = "processor_state_event",
        category = "tlb_invalidation",
        name = "invpcid",
        role = "invalidates cached translations by process-context identifier",

        node_type = "instruction",
        mnemonic = "invpcid",

        operands = {
            { index = 1, role = "invalidation_type" },
            { index = 2, role = "descriptor" },
        },

        event = {
            name = "invpcid_invalidates_context_translations",
            display_name = "invpcid",
            role = "invalidates cached translations by process-context identifier",
        },

        effect = {
            kind = "tlb_invalidation",
            name = "invpcid_invalidates_context_translations",
            role = "invalidates cached translations by process-context identifier",
        },
    },

    -- rdpkru
    {
        kind = "processor_state_event",
        category = "protection_key_state",
        name = "rdpkru",
        role = "reads protection-key rights state",

        node_type = "instruction",
        mnemonic = "rdpkru",

        operands = {},

        event = {
            name = "rdpkru_reads_protection_key_rights",
            display_name = "rdpkru",
            role = "reads protection-key rights state",
        },

        effect = {
            kind = "protection_key_state_read",
            name = "rdpkru_reads_protection_key_rights",
            role = "reads protection-key rights state",
        },
    },

    -- wrpkru
    {
        kind = "processor_state_event",
        category = "protection_key_state",
        name = "wrpkru",
        role = "writes protection-key rights state",

        node_type = "instruction",
        mnemonic = "wrpkru",

        operands = {},

        event = {
            name = "wrpkru_writes_protection_key_rights",
            display_name = "wrpkru",
            role = "writes protection-key rights state",
        },

        effect = {
            kind = "protection_key_state_write",
            name = "wrpkru_writes_protection_key_rights",
            role = "writes protection-key rights state",
        },
    },


    -- wrfsbase
    {
        kind = "processor_state_event",
        category = "segment_base_state",
        name = "wrfsbase",
        role = "writes FS base address state",

        node_type = "instruction",
        mnemonic = "wrfsbase",

        operands = {
            { index = 1, role = "source" },
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

    -- wrgsbase
    {
        kind = "processor_state_event",
        category = "segment_base_state",
        name = "wrgsbase",
        role = "writes GS base address state",

        node_type = "instruction",
        mnemonic = "wrgsbase",

        operands = {
            { index = 1, role = "source" },
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

 }

