-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/system_flags.lua
--
-- x86-64 system flags register effect specs.
--
-- Remaining legacy records not yet migrated into the categorized
-- Tree-sitter-first register-effect modules.

return {

    {
                node_type = "instruction",
                mnemonic = "clc",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "clc_updates_rflags",
                    target_register = "rflags",
                    role = "carry flag cleared by clc",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "stc",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "stc_updates_rflags",
                    target_register = "rflags",
                    role = "carry flag set by stc",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmc",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "cmc_updates_rflags",
                    target_register = "rflags",
                    role = "carry flag complemented by cmc",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lahf",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "lahf_writes_rax_family",
                    target_register = "rax",
                    role = "loaded status flags into ah by lahf",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "sahf",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "sahf_updates_rflags",
                    target_register = "rflags",
                    role = "loaded status flags from ah by sahf",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lar",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                    { index = 2, role = "selector" },
                },
                effect = {
                    kind = "register_write",
                    name = "lar_updates_rflags",
                    target_register = "rflags",
                    role = "updated by lar",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lsl",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                    { index = 2, role = "selector" },
                },
                effect = {
                    kind = "register_write",
                    name = "lsl_updates_rflags",
                    target_register = "rflags",
                    role = "updated by lsl",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "aaa",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "aaa_updates_rflags",
                    target_register = "rflags",
                    role = "updated by aaa",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "aas",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "aas_updates_rflags",
                    target_register = "rflags",
                    role = "updated by aas",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "aam",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "aam_updates_rflags",
                    target_register = "rflags",
                    role = "updated by aam",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "aad",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "aad_updates_rflags",
                    target_register = "rflags",
                    role = "updated by aad",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "daa",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "daa_updates_rflags",
                    target_register = "rflags",
                    role = "updated by daa",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "das",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "das_updates_rflags",
                    target_register = "rflags",
                    role = "updated by das",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "sahf",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "sahf_updates_rflags_alias",
                    target_register = "rflags",
                    role = "loaded status flags from ah by sahf",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lahf",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "lahf_writes_rax_alias",
                    target_register = "rax",
                    written_alias = "ah",
                    role = "loaded status flags into ah by lahf",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
                effect = {
                    kind = "register_write",
                    name = "cmpps_simd_compare",
                    target_register = "rip",
                    role = "compared packed single-precision values by cmpps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmppd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
                effect = {
                    kind = "register_write",
                    name = "cmppd_simd_compare",
                    target_register = "rip",
                    role = "compared packed double-precision values by cmppd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "clui",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "clui_updates_user_interrupt_state",
                    target_register = "rflags",
                    role = "cleared user interrupt flag by clui",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "stui",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "stui_updates_user_interrupt_state",
                    target_register = "rflags",
                    role = "set user interrupt flag by stui",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "testui",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "testui_updates_rflags",
                    target_register = "rflags",
                    role = "tested user interrupt flag by testui",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "enqcmd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "enqcmd_device_enqueue",
                    target_register = "rflags",
                    role = "updated by device enqueue command enqcmd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "enqcmds",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "enqcmds_device_enqueue",
                    target_register = "rflags",
                    role = "updated by supervisor device enqueue command enqcmds",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "arpl",
                operands = {
                    { index = 1, role = "selector" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "arpl_updates_rflags",
                    target_register = "rflags",
                    role = "updated by access-rights privilege adjustment arpl",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "repe_cmpsb",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "repe_cmpsb_updates_rflags",
                    target_register = "rflags",
                    role = "updated by repeated byte string compare while equal repe_cmpsb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "repz_cmpsb",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "repz_cmpsb_updates_rflags",
                    target_register = "rflags",
                    role = "updated by repeated byte string compare while zero repz_cmpsb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "repne_scasb",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "repne_scasb_updates_rflags",
                    target_register = "rflags",
                    role = "updated by repeated byte string scan while not equal repne_scasb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "repnz_scasb",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "repnz_scasb_updates_rflags",
                    target_register = "rflags",
                    role = "updated by repeated byte string scan while not zero repnz_scasb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "predicate" },
                },
                effect = {
                    kind = "register_write",
                    name = "cmpps_vector_fp_compare",
                    target_register = "rip",
                    role = "performed packed single-precision compare by cmpps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmppd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "predicate" },
                },
                effect = {
                    kind = "register_write",
                    name = "cmppd_vector_fp_compare",
                    target_register = "rip",
                    role = "performed packed double-precision compare by cmppd",
                },
            },

}

