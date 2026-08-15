-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/security/sgx.lua
--
-- x86-64 instruction events: security / sgx.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["encls"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "encls",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "encls",
            role = "executes a privileged SGX enclave operation",

            operands = {
            },

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
    },

    ["enclu"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "enclu",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "enclu",
            role = "executes an unprivileged SGX enclave operation",

            operands = {
            },

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
    },

    ["enclv"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "enclv",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "enclv",
            role = "executes a virtualization SGX enclave operation",

            operands = {
            },

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
    },

    ["eaccept"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "eaccept",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "eaccept",
            role = "accepts an SGX enclave page",

            operands = {
            },

            event = {
                name = "eaccept_accepts_enclave_page",
                display_name = "eaccept",
                role = "accepts an SGX enclave page",
            },

            effect = {
                kind = "enclave_page_operation",
                name = "eaccept_accepts_enclave_page",
                role = "accepts an SGX enclave page",
            },
        },
    },

    ["eacceptcopy"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "eacceptcopy",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "eacceptcopy",
            role = "accepts a copied SGX enclave page",

            operands = {
            },

            event = {
                name = "eacceptcopy_accepts_copied_enclave_page",
                display_name = "eacceptcopy",
                role = "accepts a copied SGX enclave page",
            },

            effect = {
                kind = "enclave_page_operation",
                name = "eacceptcopy_accepts_copied_enclave_page",
                role = "accepts a copied SGX enclave page",
            },
        },
    },

    ["eaug"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "eaug",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "eaug",
            role = "augments an SGX enclave with a page",

            operands = {
            },

            event = {
                name = "eaug_augments_enclave_page",
                display_name = "eaug",
                role = "augments an SGX enclave with a page",
            },

            effect = {
                kind = "enclave_page_operation",
                name = "eaug_augments_enclave_page",
                role = "augments an SGX enclave with a page",
            },
        },
    },

    ["eblock"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "eblock",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "eblock",
            role = "blocks an SGX enclave page",

            operands = {
            },

            event = {
                name = "eblock_blocks_enclave_page",
                display_name = "eblock",
                role = "blocks an SGX enclave page",
            },

            effect = {
                kind = "enclave_page_operation",
                name = "eblock_blocks_enclave_page",
                role = "blocks an SGX enclave page",
            },
        },
    },

    ["ecreate"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ecreate",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "ecreate",
            role = "creates an SGX enclave control structure",

            operands = {
            },

            event = {
                name = "ecreate_creates_enclave_control_structure",
                display_name = "ecreate",
                role = "creates an SGX enclave control structure",
            },

            effect = {
                kind = "enclave_creation",
                name = "ecreate_creates_enclave_control_structure",
                role = "creates an SGX enclave control structure",
            },
        },
    },

    ["edbgrd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "edbgrd",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "edbgrd",
            role = "debug-reads SGX enclave memory",

            operands = {
            },

            event = {
                name = "edbgrd_debug_reads_enclave_memory",
                display_name = "edbgrd",
                role = "debug-reads SGX enclave memory",
            },

            effect = {
                kind = "enclave_debug_read",
                name = "edbgrd_debug_reads_enclave_memory",
                role = "debug-reads SGX enclave memory",
            },
        },
    },

    ["edbgwr"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "edbgwr",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "edbgwr",
            role = "debug-writes SGX enclave memory",

            operands = {
            },

            event = {
                name = "edbgwr_debug_writes_enclave_memory",
                display_name = "edbgwr",
                role = "debug-writes SGX enclave memory",
            },

            effect = {
                kind = "enclave_debug_write",
                name = "edbgwr_debug_writes_enclave_memory",
                role = "debug-writes SGX enclave memory",
            },
        },
    },

    ["egetkey"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "egetkey",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "egetkey",
            role = "derives an SGX enclave key",

            operands = {
            },

            event = {
                name = "egetkey_derives_enclave_key",
                display_name = "egetkey",
                role = "derives an SGX enclave key",
            },

            effect = {
                kind = "enclave_key_derivation",
                name = "egetkey_derives_enclave_key",
                role = "derives an SGX enclave key",
            },
        },
    },

    ["einit"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "einit",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "einit",
            role = "initializes an SGX enclave",

            operands = {
            },

            event = {
                name = "einit_initializes_enclave",
                display_name = "einit",
                role = "initializes an SGX enclave",
            },

            effect = {
                kind = "enclave_initialization",
                name = "einit_initializes_enclave",
                role = "initializes an SGX enclave",
            },
        },
    },

    ["eldb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "eldb",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "eldb",
            role = "loads a blocked SGX enclave page",

            operands = {
            },

            event = {
                name = "eldb_loads_blocked_enclave_page",
                display_name = "eldb",
                role = "loads a blocked SGX enclave page",
            },

            effect = {
                kind = "enclave_page_load",
                name = "eldb_loads_blocked_enclave_page",
                role = "loads a blocked SGX enclave page",
            },
        },
    },

    ["eldu"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "eldu",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "eldu",
            role = "loads an unblocked SGX enclave page",

            operands = {
            },

            event = {
                name = "eldu_loads_unblocked_enclave_page",
                display_name = "eldu",
                role = "loads an unblocked SGX enclave page",
            },

            effect = {
                kind = "enclave_page_load",
                name = "eldu_loads_unblocked_enclave_page",
                role = "loads an unblocked SGX enclave page",
            },
        },
    },

    ["emodpe"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "emodpe",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "emodpe",
            role = "modifies SGX enclave page permissions",

            operands = {
            },

            event = {
                name = "emodpe_modifies_enclave_page_permissions",
                display_name = "emodpe",
                role = "modifies SGX enclave page permissions",
            },

            effect = {
                kind = "enclave_page_permission_update",
                name = "emodpe_modifies_enclave_page_permissions",
                role = "modifies SGX enclave page permissions",
            },
        },
    },

    ["emodpr"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "emodpr",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "emodpr",
            role = "restricts SGX enclave page permissions",

            operands = {
            },

            event = {
                name = "emodpr_restricts_enclave_page_permissions",
                display_name = "emodpr",
                role = "restricts SGX enclave page permissions",
            },

            effect = {
                kind = "enclave_page_permission_update",
                name = "emodpr_restricts_enclave_page_permissions",
                role = "restricts SGX enclave page permissions",
            },
        },
    },

    ["emodt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "emodt",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "emodt",
            role = "modifies the type of an SGX enclave page",

            operands = {
            },

            event = {
                name = "emodt_modifies_enclave_page_type",
                display_name = "emodt",
                role = "modifies the type of an SGX enclave page",
            },

            effect = {
                kind = "enclave_page_type_update",
                name = "emodt_modifies_enclave_page_type",
                role = "modifies the type of an SGX enclave page",
            },
        },
    },

    ["epa"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "epa",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "epa",
            role = "creates an SGX version-array page",

            operands = {
            },

            event = {
                name = "epa_creates_version_array_page",
                display_name = "epa",
                role = "creates an SGX version-array page",
            },

            effect = {
                kind = "enclave_page_creation",
                name = "epa_creates_version_array_page",
                role = "creates an SGX version-array page",
            },
        },
    },

    ["erdinfo"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "erdinfo",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "erdinfo",
            role = "reads SGX enclave report information",

            operands = {
            },

            event = {
                name = "erdinfo_reads_enclave_report_information",
                display_name = "erdinfo",
                role = "reads SGX enclave report information",
            },

            effect = {
                kind = "enclave_report_read",
                name = "erdinfo_reads_enclave_report_information",
                role = "reads SGX enclave report information",
            },
        },
    },

    ["eremove"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "eremove",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "eremove",
            role = "removes an SGX enclave page",

            operands = {
            },

            event = {
                name = "eremove_removes_enclave_page",
                display_name = "eremove",
                role = "removes an SGX enclave page",
            },

            effect = {
                kind = "enclave_page_removal",
                name = "eremove_removes_enclave_page",
                role = "removes an SGX enclave page",
            },
        },
    },

    ["etrack"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "etrack",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "etrack",
            role = "tracks SGX enclave page invalidation",

            operands = {
            },

            event = {
                name = "etrack_tracks_enclave_page_invalidation",
                display_name = "etrack",
                role = "tracks SGX enclave page invalidation",
            },

            effect = {
                kind = "enclave_page_invalidation",
                name = "etrack_tracks_enclave_page_invalidation",
                role = "tracks SGX enclave page invalidation",
            },
        },
    },

    ["eextend"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "eextend",
                    },
                },
            },

            kind = "security_event",
            category = "sgx_enclave",
            name = "eextend",
            role = "extends the SGX enclave measurement",

            operands = {
            },

            event = {
                name = "eextend_extends_enclave_measurement",
                display_name = "eextend",
                role = "extends the SGX enclave measurement",
            },

            effect = {
                kind = "enclave_measurement_update",
                name = "eextend_extends_enclave_measurement",
                role = "extends the SGX enclave measurement",
            },
        },
    },
}

