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
}
