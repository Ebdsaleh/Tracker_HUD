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


        -- key locker

    -- loadiwkey
    {
        kind = "security_event",
        category = "key_locker",
        name = "loadiwkey",
        role = "loads the internal wrapping key",

        node_type = "instruction",
        mnemonic = "loadiwkey",

        operands = {
            { index = 1, role = "control" },
            { index = 2, role = "key_source" },
        },

        event = {
            name = "loadiwkey_loads_internal_wrapping_key",
            display_name = "loadiwkey",
            role = "loads the internal wrapping key",
        },

        effect = {
            kind = "key_locker_state_update",
            name = "loadiwkey_loads_internal_wrapping_key",
            role = "loads the internal wrapping key",
        },
    },

    -- encodekey128
    {
        kind = "security_event",
        category = "key_locker",
        name = "encodekey128",
        role = "encodes a 128-bit AES key handle",

        node_type = "instruction",
        mnemonic = "encodekey128",

        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },

        event = {
            name = "encodekey128_encodes_key_handle",
            display_name = "encodekey128",
            role = "encodes a 128-bit AES key handle",
        },

        effect = {
            kind = "key_locker_key_encode",
            name = "encodekey128_encodes_key_handle",
            role = "encodes a 128-bit AES key handle",
        },
    },

    -- encodekey256
    {
        kind = "security_event",
        category = "key_locker",
        name = "encodekey256",
        role = "encodes a 256-bit AES key handle",

        node_type = "instruction",
        mnemonic = "encodekey256",

        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },

        event = {
            name = "encodekey256_encodes_key_handle",
            display_name = "encodekey256",
            role = "encodes a 256-bit AES key handle",
        },

        effect = {
            kind = "key_locker_key_encode",
            name = "encodekey256_encodes_key_handle",
            role = "encodes a 256-bit AES key handle",
        },
    },


    -- cet / shadow stack / platform security

        -- endbr32
    {
        kind = "security_event",
        category = "cet_indirect_branch_tracking",
        name = "endbr32",
        role = "marks a valid 32-bit indirect branch target",

        node_type = "instruction",
        mnemonic = "endbr32",

        operands = {},

        event = {
            name = "endbr32_cet_branch_target",
            display_name = "endbr32",
            role = "marks a valid 32-bit indirect branch target",
        },

        effect = {
            kind = "indirect_branch_tracking",
            name = "endbr32_cet_branch_target",
            role = "marks a valid 32-bit indirect branch target",
        },
    },

    -- endbr64
    {
        kind = "security_event",
        category = "cet_indirect_branch_tracking",
        name = "endbr64",
        role = "marks a valid 64-bit indirect branch target",

        node_type = "instruction",
        mnemonic = "endbr64",

        operands = {},

        event = {
            name = "endbr64_cet_branch_target",
            display_name = "endbr64",
            role = "marks a valid 64-bit indirect branch target",
        },

        effect = {
            kind = "indirect_branch_tracking",
            name = "endbr64_cet_branch_target",
            role = "marks a valid 64-bit indirect branch target",
        },
    },

    -- setssbsy
    {
        kind = "security_event",
        category = "shadow_stack",
        name = "setssbsy",
        role = "marks the shadow stack busy",

        node_type = "instruction",
        mnemonic = "setssbsy",

        operands = {},

        event = {
            name = "setssbsy_updates_shadow_stack",
            display_name = "setssbsy",
            role = "marks the shadow stack busy",
        },

        effect = {
            kind = "shadow_stack_busy_state",
            name = "setssbsy_updates_shadow_stack",
            role = "marks the shadow stack busy",
        },
    },

    -- clrssbsy
    {
        kind = "security_event",
        category = "shadow_stack",
        name = "clrssbsy",
        role = "clears a shadow-stack busy token",

        node_type = "instruction",
        mnemonic = "clrssbsy",

        operands = {
            { index = 1, role = "token" },
        },

        event = {
            name = "clrssbsy_updates_shadow_stack",
            display_name = "clrssbsy",
            role = "clears a shadow-stack busy token",
        },

        effect = {
            kind = "shadow_stack_busy_state",
            name = "clrssbsy_updates_shadow_stack",
            role = "clears a shadow-stack busy token",
        },
    },


        -- incsspd
    {
        kind = "security_event",
        category = "shadow_stack",
        name = "incsspd",
        role = "advances the shadow-stack pointer by a 32-bit count",

        node_type = "instruction",
        mnemonic = "incsspd",

        operands = {
            { index = 1, role = "count" },
        },

        event = {
            name = "incsspd_advances_shadow_stack_pointer",
            display_name = "incsspd",
            role = "advances the shadow-stack pointer by a 32-bit count",
        },

        effect = {
            kind = "shadow_stack_pointer_update",
            name = "incsspd_advances_shadow_stack_pointer",
            role = "advances the shadow-stack pointer by a 32-bit count",
        },
    },

    -- incsspq
    {
        kind = "security_event",
        category = "shadow_stack",
        name = "incsspq",
        role = "advances the shadow-stack pointer by a 64-bit count",

        node_type = "instruction",
        mnemonic = "incsspq",

        operands = {
            { index = 1, role = "count" },
        },

        event = {
            name = "incsspq_advances_shadow_stack_pointer",
            display_name = "incsspq",
            role = "advances the shadow-stack pointer by a 64-bit count",
        },

        effect = {
            kind = "shadow_stack_pointer_update",
            name = "incsspq_advances_shadow_stack_pointer",
            role = "advances the shadow-stack pointer by a 64-bit count",
        },
    },

    -- rstorssp
    {
        kind = "security_event",
        category = "shadow_stack",
        name = "rstorssp",
        role = "restores shadow-stack pointer state",

        node_type = "instruction",
        mnemonic = "rstorssp",

        operands = {
            { index = 1, role = "source" },
        },

        event = {
            name = "rstorssp_restores_shadow_stack_pointer",
            display_name = "rstorssp",
            role = "restores shadow-stack pointer state",
        },

        effect = {
            kind = "shadow_stack_pointer_restore",
            name = "rstorssp_restores_shadow_stack_pointer",
            role = "restores shadow-stack pointer state",
        },
    },

    -- saveprevssp
    {
        kind = "security_event",
        category = "shadow_stack",
        name = "saveprevssp",
        role = "saves the previous shadow-stack pointer",

        node_type = "instruction",
        mnemonic = "saveprevssp",

        operands = {},

        event = {
            name = "saveprevssp_saves_previous_shadow_stack_pointer",
            display_name = "saveprevssp",
            role = "saves the previous shadow-stack pointer",
        },

        effect = {
            kind = "shadow_stack_pointer_save",
            name = "saveprevssp_saves_previous_shadow_stack_pointer",
            role = "saves the previous shadow-stack pointer",
        },
    },

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


    -- mpx bounds protection

    -- bndcl
    {
        kind = "security_event",
        category = "mpx_bounds",
        name = "bndcl",
        role = "checks an address against a lower bound",

        node_type = "instruction",
        mnemonic = "bndcl",

        operands = {
            { index = 1, role = "bounds" },
            { index = 2, role = "address" },
        },

        event = {
            name = "bndcl_checks_lower_bound",
            display_name = "bndcl",
            role = "checks an address against a lower bound",
        },

        effect = {
            kind = "bounds_check",
            name = "bndcl_checks_lower_bound",
            role = "checks an address against a lower bound",
        },
    },

    -- bndcu
    {
        kind = "security_event",
        category = "mpx_bounds",
        name = "bndcu",
        role = "checks an address against an upper bound",

        node_type = "instruction",
        mnemonic = "bndcu",

        operands = {
            { index = 1, role = "bounds" },
            { index = 2, role = "address" },
        },

        event = {
            name = "bndcu_checks_upper_bound",
            display_name = "bndcu",
            role = "checks an address against an upper bound",
        },

        effect = {
            kind = "bounds_check",
            name = "bndcu_checks_upper_bound",
            role = "checks an address against an upper bound",
        },
    },

    -- bndcn
    {
        kind = "security_event",
        category = "mpx_bounds",
        name = "bndcn",
        role = "checks an address against a complemented upper bound",

        node_type = "instruction",
        mnemonic = "bndcn",

        operands = {
            { index = 1, role = "bounds" },
            { index = 2, role = "address" },
        },

        event = {
            name = "bndcn_checks_complemented_upper_bound",
            display_name = "bndcn",
            role = "checks an address against a complemented upper bound",
        },

        effect = {
            kind = "bounds_check",
            name = "bndcn_checks_complemented_upper_bound",
            role = "checks an address against a complemented upper bound",
        },
    },

    -- bndstx
    {
        kind = "security_event",
        category = "mpx_bounds",
        name = "bndstx",
        role = "stores bounds state using address translation",

        node_type = "instruction",
        mnemonic = "bndstx",

        operands = {
            { index = 1, role = "address" },
            { index = 2, role = "bounds_source" },
        },

        event = {
            name = "bndstx_stores_bounds_state",
            display_name = "bndstx",
            role = "stores bounds state using address translation",
        },

        effect = {
            kind = "bounds_state_store",
            name = "bndstx_stores_bounds_state",
            role = "stores bounds state using address translation",
        },
    },


    -- reverse map table / platform state

    -- rmpadjust
    {
        kind = "security_event",
        category = "platform_memory_security",
        name = "rmpadjust",
        role = "adjusts reverse map table state",

        node_type = "instruction",
        mnemonic = "rmpadjust",

        operands = {},

        event = {
            name = "rmpadjust_adjusts_reverse_map_state",
            display_name = "rmpadjust",
            role = "adjusts reverse map table state",
        },

        effect = {
            kind = "platform_security_state_update",
            name = "rmpadjust_adjusts_reverse_map_state",
            role = "adjusts reverse map table state",
        },
    },

    -- rmpupdate
    {
        kind = "security_event",
        category = "platform_memory_security",
        name = "rmpupdate",
        role = "updates reverse map table state",

        node_type = "instruction",
        mnemonic = "rmpupdate",

        operands = {},

        event = {
            name = "rmpupdate_updates_reverse_map_state",
            display_name = "rmpupdate",
            role = "updates reverse map table state",
        },

        effect = {
            kind = "platform_security_state_update",
            name = "rmpupdate_updates_reverse_map_state",
            role = "updates reverse map table state",
        },
    },

}
