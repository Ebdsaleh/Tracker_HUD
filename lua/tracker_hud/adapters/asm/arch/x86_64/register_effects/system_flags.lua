-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/system_flags.lua
--
-- x86-64 system flags register effect specs.

return {

    -- 'clc' clears the carry flag.
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
        }
,

    -- 'stc' sets the carry flag.
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
        }
,

    -- 'cmc' complements the carry flag.
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
        }
,

    -- 'lahf' loads status flags into AH.
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
        }
,

    -- 'sahf' stores AH into status flags.
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
        }
,

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
        }
,

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
        }
,

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
        }
,

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
        }
,

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
        }
,

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
        }
,

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
        }
,

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
        }
,

    -- BCD / flag stack helpers.
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
        }
,

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
        }
,

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
        }
,

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
        }
,

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
        }
,

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
        }
,

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
        }
,

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
        }
,

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
        }
,

    -- AMD TBM-style bit manipulation leftovers.
        -- These write a GPR destination and usually update flags.
    
        {
            node_type = "instruction",
            mnemonic = "blcfill",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blcfill_writes_destination",
                target_operand = 1,
                role = "written with lowest clear bit filled by blcfill",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "blcfill",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blcfill_updates_rflags",
                target_register = "rflags",
                role = "updated by blcfill",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "blci",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blci_updates_rflags",
                target_register = "rflags",
                role = "updated by blci",
            },
        }
,

    -- Protected-mode / descriptor helpers.
    
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
        }
,

    -- CMP suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "cmpb",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "cmpb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte compare cmpb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmpw",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "cmpw_updates_rflags",
                target_register = "rflags",
                role = "updated by word compare cmpw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmpl",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "cmpl_updates_rflags",
                target_register = "rflags",
                role = "updated by long compare cmpl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmpq",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "cmpq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword compare cmpq",
            },
        }
,

    -- TEST suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "testb",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "testb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte test testb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "testw",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "testw_updates_rflags",
                target_register = "rflags",
                role = "updated by word test testw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "testl",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "testl_updates_rflags",
                target_register = "rflags",
                role = "updated by long test testl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "testq",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "testq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword test testq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "incb",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "incb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte increment incb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "incw",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "incw_updates_rflags",
                target_register = "rflags",
                role = "updated by word increment incw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "incl",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "incl_updates_rflags",
                target_register = "rflags",
                role = "updated by long increment incl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "incq",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "incq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword increment incq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "decq",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "decq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword decrement decq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "negb",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "negb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte negate negb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "negw",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "negw_updates_rflags",
                target_register = "rflags",
                role = "updated by word negate negw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "negl",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "negl_updates_rflags",
                target_register = "rflags",
                role = "updated by long negate negl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "negq",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "negq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword negate negq",
            },
        }
,

    -- Remaining scalar suffix alias completion.
        -- This fills gaps left from the previous GAS/objdump-style suffix batches.
    
        -- DEC suffix aliases completion.
    
        {
            node_type = "instruction",
            mnemonic = "decb",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "decb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte decrement decb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "decw",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "decw_updates_rflags",
                target_register = "rflags",
                role = "updated by word decrement decw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "decl",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "decl_updates_rflags",
                target_register = "rflags",
                role = "updated by long decrement decl",
            },
        }
,

    -- REPE / REPZ CMPS aliases.
    
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
        }
,

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
        }
,

    -- REPNE / REPNZ SCAS aliases.
    
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
        }
,

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
        }
,

    -- CMP packed/scalar vector comparisons.
    
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
        }
,

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
        }
,

    -- 'test' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "test",
    
            operands = {
                {
                    index = 1,
                    role = "left",
                },
                {
                    index = 2,
                    role = "right",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "test_updates_rflags",
                target_register = "rflags",
                role = "updated by test",
            },
        }
,
}
