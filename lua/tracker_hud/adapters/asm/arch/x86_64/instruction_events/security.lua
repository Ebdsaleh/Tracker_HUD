-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/security.lua
--
-- x86-64 instruction event specs: security / enclave / platform state.
--
-- These events replace fake RIP register-effect visibility entries.

return {

    -- seamcall
    {
        kind = "security_event",
        category = "tdx_seam",
        name = "seamcall",
        role = "calls into SEAM secure module code",

        node_type = "instruction",
        mnemonic = "seamcall",

        operands = {},

        event = {
            name = "seamcall_calls_seam_module",
            display_name = "seamcall",
            role = "calls into SEAM secure module code",
        },

        effect = {
            kind = "security_module_call",
            name = "seamcall_calls_seam_module",
            role = "calls into SEAM secure module code",
        },
    },

    -- seamret
    {
        kind = "security_event",
        category = "tdx_seam",
        name = "seamret",
        role = "returns from SEAM secure module code",

        node_type = "instruction",
        mnemonic = "seamret",

        operands = {},

        event = {
            name = "seamret_returns_from_seam_module",
            display_name = "seamret",
            role = "returns from SEAM secure module code",
        },

        effect = {
            kind = "security_module_return",
            name = "seamret_returns_from_seam_module",
            role = "returns from SEAM secure module code",
        },
    },

    -- encls
    {
        kind = "security_event",
        category = "sgx_enclave",
        name = "encls",
        role = "executes a privileged SGX enclave operation",

        node_type = "instruction",
        mnemonic = "encls",

        operands = {},

        event = {
            name = "encls_executes_privileged_enclave_operation",
            display_name = "encls",
            role = "executes a privileged SGX enclave operation",
        },

        effect = {
            kind = "enclave_operation",
            name = "encls_executes_privileged_enclave_operation",
            role = "executes a privileged SGX enclave operation",
        },
    },

    -- enclu
    {
        kind = "security_event",
        category = "sgx_enclave",
        name = "enclu",
        role = "executes an unprivileged SGX enclave operation",

        node_type = "instruction",
        mnemonic = "enclu",

        operands = {},

        event = {
            name = "enclu_executes_unprivileged_enclave_operation",
            display_name = "enclu",
            role = "executes an unprivileged SGX enclave operation",
        },

        effect = {
            kind = "enclave_operation",
            name = "enclu_executes_unprivileged_enclave_operation",
            role = "executes an unprivileged SGX enclave operation",
        },
    },

    -- enclv
    {
        kind = "security_event",
        category = "sgx_enclave",
        name = "enclv",
        role = "executes a virtualization SGX enclave operation",

        node_type = "instruction",
        mnemonic = "enclv",

        operands = {},

        event = {
            name = "enclv_executes_virtualization_enclave_operation",
            display_name = "enclv",
            role = "executes a virtualization SGX enclave operation",
        },

        effect = {
            kind = "enclave_operation",
            name = "enclv_executes_virtualization_enclave_operation",
            role = "executes a virtualization SGX enclave operation",
        },
    },

    -- getsec
    {
        kind = "security_event",
        category = "trusted_execution",
        name = "getsec",
        role = "executes a GETSEC trusted-execution function",

        node_type = "instruction",
        mnemonic = "getsec",

        operands = {},

        event = {
            name = "getsec_executes_trusted_execution_function",
            display_name = "getsec",
            role = "executes a GETSEC trusted-execution function",
        },

        effect = {
            kind = "trusted_execution_operation",
            name = "getsec_executes_trusted_execution_function",
            role = "executes a GETSEC trusted-execution function",
        },
    },

        -- cet / shadow stack / platform security

    -- wrssd
    {
        kind = "security_event",
        category = "shadow_stack",
        name = "wrssd",
        role = "writes 32-bit shadow-stack memory",

        node_type = "instruction",
        mnemonic = "wrssd",

        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },

        event = {
            name = "wrssd_writes_shadow_stack",
            display_name = "wrssd",
            role = "writes 32-bit shadow-stack memory",
        },

        effect = {
            kind = "shadow_stack_write",
            name = "wrssd_writes_shadow_stack",
            role = "writes 32-bit shadow-stack memory",
        },
    },

    -- wrssq
    {
        kind = "security_event",
        category = "shadow_stack",
        name = "wrssq",
        role = "writes 64-bit shadow-stack memory",

        node_type = "instruction",
        mnemonic = "wrssq",

        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },

        event = {
            name = "wrssq_writes_shadow_stack",
            display_name = "wrssq",
            role = "writes 64-bit shadow-stack memory",
        },

        effect = {
            kind = "shadow_stack_write",
            name = "wrssq_writes_shadow_stack",
            role = "writes 64-bit shadow-stack memory",
        },
    },

    -- wrussd
    {
        kind = "security_event",
        category = "shadow_stack",
        name = "wrussd",
        role = "writes 32-bit user shadow-stack memory",

        node_type = "instruction",
        mnemonic = "wrussd",

        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },

        event = {
            name = "wrussd_writes_user_shadow_stack",
            display_name = "wrussd",
            role = "writes 32-bit user shadow-stack memory",
        },

        effect = {
            kind = "shadow_stack_write",
            name = "wrussd_writes_user_shadow_stack",
            role = "writes 32-bit user shadow-stack memory",
        },
    },

    -- wrussq
    {
        kind = "security_event",
        category = "shadow_stack",
        name = "wrussq",
        role = "writes 64-bit user shadow-stack memory",

        node_type = "instruction",
        mnemonic = "wrussq",

        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },

        event = {
            name = "wrussq_writes_user_shadow_stack",
            display_name = "wrussq",
            role = "writes 64-bit user shadow-stack memory",
        },

        effect = {
            kind = "shadow_stack_write",
            name = "wrussq_writes_user_shadow_stack",
            role = "writes 64-bit user shadow-stack memory",
        },
    },

    -- senduipi
    {
        kind = "security_event",
        category = "user_interrupt",
        name = "senduipi",
        role = "sends a user interprocessor interrupt",

        node_type = "instruction",
        mnemonic = "senduipi",

        operands = {
            { index = 1, role = "destination" },
        },

        event = {
            name = "senduipi_sends_user_interrupt",
            display_name = "senduipi",
            role = "sends a user interprocessor interrupt",
        },

        effect = {
            kind = "user_interrupt_send",
            name = "senduipi_sends_user_interrupt",
            role = "sends a user interprocessor interrupt",
        },
    },

    -- seamops
    {
        kind = "security_event",
        category = "tdx_seam",
        name = "seamops",
        role = "performs a SEAM platform operation",

        node_type = "instruction",
        mnemonic = "seamops",

        operands = {},

        event = {
            name = "seamops_performs_seam_operation",
            display_name = "seamops",
            role = "performs a SEAM platform operation",
        },

        effect = {
            kind = "security_module_operation",
            name = "seamops_performs_seam_operation",
            role = "performs a SEAM platform operation",
        },
    },

    -- pconfig
    {
        kind = "security_event",
        category = "platform_configuration",
        name = "pconfig",
        role = "configures platform feature state",

        node_type = "instruction",
        mnemonic = "pconfig",

        operands = {},

        event = {
            name = "pconfig_configures_platform_state",
            display_name = "pconfig",
            role = "configures platform feature state",
        },

        effect = {
            kind = "platform_configuration",
            name = "pconfig_configures_platform_state",
            role = "configures platform feature state",
        },
    },
}
