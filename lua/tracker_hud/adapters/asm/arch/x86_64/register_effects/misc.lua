-- lua/tracker_hud/adapters/asm_arch/x86_64/register_effects/misc.lua
--
-- x86-64 misc register effect specs.

return {

    -- 'cbw' sign-extends al into ax.
        {
            node_type = "instruction",
            mnemonic = "cbw",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cbw_writes_rax_family",
                target_register = "rax",
                role = "sign-extended al into ax by cbw",
            },
        }
,

    -- 'cwde' sign-extends ax into eax.
        {
            node_type = "instruction",
            mnemonic = "cwde",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cwde_writes_rax_family",
                target_register = "rax",
                role = "sign-extended ax into eax by cwde",
            },
        }
,

    -- 'cdqe' sign-extends eax into rax.
        {
            node_type = "instruction",
            mnemonic = "cdqe",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cdqe_writes_rax",
                target_register = "rax",
                role = "sign-extended eax into rax by cdqe",
            },
        }
,

    -- 'cwd' sign-extends ax into dx:ax.
        {
            node_type = "instruction",
            mnemonic = "cwd",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cwd_writes_rdx_family",
                target_register = "rdx",
                role = "sign-extended ax into dx by cwd",
            },
        }
,

    -- 'cdq' sign-extends eax into edx:eax.
        {
            node_type = "instruction",
            mnemonic = "cdq",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cdq_writes_rdx_family",
                target_register = "rdx",
                role = "sign-extended eax into edx by cdq",
            },
        }
,

    -- 'cqo' sign-extends rax into rdx:rax.
        {
            node_type = "instruction",
            mnemonic = "cqo",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cqo_writes_rdx",
                target_register = "rdx",
                role = "sign-extended rax into rdx by cqo",
            },
        }
,

    -- 'in dest, port' writes input-port data to the destination register.
        {
            node_type = "instruction",
            mnemonic = "in",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "port" },
            },
    
            effect = {
                kind = "register_write",
                name = "in_writes_register",
                target_operand = 1,
                role = "written from input port by in",
            },
        }
,

    -- REP-family prefixes. These are modeled as rcx-consuming repeat controls.
        {
            node_type = "instruction",
            mnemonic = "rep",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_consumes_rcx",
                target_register = "rcx",
                role = "used as repeat count by rep",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "repe",
            operands = {},
            effect = {
                kind = "register_write",
                name = "repe_consumes_rcx",
                target_register = "rcx",
                role = "used as repeat count by repe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "repz",
            operands = {},
            effect = {
                kind = "register_write",
                name = "repz_consumes_rcx",
                target_register = "rcx",
                role = "used as repeat count by repz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "repne",
            operands = {},
            effect = {
                kind = "register_write",
                name = "repne_consumes_rcx",
                target_register = "rcx",
                role = "used as repeat count by repne",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "repnz",
            operands = {},
            effect = {
                kind = "register_write",
                name = "repnz_consumes_rcx",
                target_register = "rcx",
                role = "used as repeat count by repnz",
            },
        }
,

    -- Descriptor / protection helper instructions.
        {
            node_type = "instruction",
            mnemonic = "lar",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "lar_writes_destination",
                target_operand = 1,
                role = "written with access rights by lar",
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
                name = "lsl_writes_destination",
                target_operand = 1,
                role = "written with segment limit by lsl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lret",
            operands = {},
            effect = {
                kind = "register_write",
                name = "lret_updates_rip",
                target_register = "rip",
                role = "far return changed instruction pointer by lret",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lret",
            operands = {},
            effect = {
                kind = "register_write",
                name = "lret_updates_rsp",
                target_register = "rsp",
                role = "far return adjusted stack pointer by lret",
            },
        }
,

    -- ASCII/decimal adjust instructions. Legacy, but useful to recognize.
        {
            node_type = "instruction",
            mnemonic = "aaa",
            operands = {},
            effect = {
                kind = "register_write",
                name = "aaa_updates_rax",
                target_register = "rax",
                written_alias = "ax",
                role = "adjusted ascii addition result by aaa",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aas",
            operands = {},
            effect = {
                kind = "register_write",
                name = "aas_updates_rax",
                target_register = "rax",
                written_alias = "ax",
                role = "adjusted ascii subtraction result by aas",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aam",
            operands = {},
            effect = {
                kind = "register_write",
                name = "aam_updates_rax",
                target_register = "rax",
                written_alias = "ax",
                role = "adjusted ascii multiply result by aam",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aad",
            operands = {},
            effect = {
                kind = "register_write",
                name = "aad_updates_rax",
                target_register = "rax",
                written_alias = "ax",
                role = "adjusted ascii division result by aad",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "daa",
            operands = {},
            effect = {
                kind = "register_write",
                name = "daa_updates_rax",
                target_register = "rax",
                written_alias = "al",
                role = "decimal-adjusted al after addition by daa",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "das",
            operands = {},
            effect = {
                kind = "register_write",
                name = "das_updates_rax",
                target_register = "rax",
                written_alias = "al",
                role = "decimal-adjusted al after subtraction by das",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ljmp",
            operands = {
                { index = 1, role = "far_target" },
            },
            effect = {
                kind = "register_write",
                name = "ljmp_updates_rip",
                target_register = "rip",
                role = "far jump changed instruction pointer by ljmp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rsm",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rsm_updates_rip",
                target_register = "rip",
                role = "resumed from system management mode by rsm",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mpsadbw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "mpsadbw_simd_integer_sad",
                target_register = "rip",
                role = "computed multiple packed byte sums of absolute differences by mpsadbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "dpps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "dpps_vector_dot_product",
                target_register = "rip",
                role = "computed packed single-precision dot product by dpps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "dppd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "dppd_vector_dot_product",
                target_register = "rip",
                role = "computed packed double-precision dot product by dppd",
            },
        }
,

    -- AMX tile configuration / release.
    
        {
            node_type = "instruction",
            mnemonic = "ldtilecfg",
            operands = {
                { index = 1, role = "tile_config" },
            },
            effect = {
                kind = "register_write",
                name = "ldtilecfg_updates_tile_state",
                target_register = "rip",
                role = "loaded AMX tile configuration by ldtilecfg",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sttilecfg",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "sttilecfg_updates_tile_state",
                target_register = "rip",
                role = "stored AMX tile configuration by sttilecfg",
            },
        }
,

    -- AMX tile compute.
    
        {
            node_type = "instruction",
            mnemonic = "tdpbssd",
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "left_tile" },
                { index = 3, role = "right_tile" },
            },
            effect = {
                kind = "register_write",
                name = "tdpbssd_updates_tile_state",
                target_register = "rip",
                role = "dot-product accumulated signed bytes into AMX tile doublewords by tdpbssd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tdpbsud",
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "left_tile" },
                { index = 3, role = "right_tile" },
            },
            effect = {
                kind = "register_write",
                name = "tdpbsud_updates_tile_state",
                target_register = "rip",
                role = "dot-product accumulated signed bytes with unsigned bytes into AMX tile doublewords by tdpbsud",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tdpbusd",
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "left_tile" },
                { index = 3, role = "right_tile" },
            },
            effect = {
                kind = "register_write",
                name = "tdpbusd_updates_tile_state",
                target_register = "rip",
                role = "dot-product accumulated unsigned bytes with signed bytes into AMX tile doublewords by tdpbusd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tdpbuud",
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "left_tile" },
                { index = 3, role = "right_tile" },
            },
            effect = {
                kind = "register_write",
                name = "tdpbuud_updates_tile_state",
                target_register = "rip",
                role = "dot-product accumulated unsigned bytes into AMX tile doublewords by tdpbuud",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tdpbf16ps",
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "left_tile" },
                { index = 3, role = "right_tile" },
            },
            effect = {
                kind = "register_write",
                name = "tdpbf16ps_updates_tile_state",
                target_register = "rip",
                role = "dot-product accumulated bfloat16 values into AMX tile single-precision values by tdpbf16ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tdpfp16ps",
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "left_tile" },
                { index = 3, role = "right_tile" },
            },
            effect = {
                kind = "register_write",
                name = "tdpfp16ps_updates_tile_state",
                target_register = "rip",
                role = "dot-product accumulated fp16 values into AMX tile single-precision values by tdpfp16ps",
            },
        }
,

    -- x86_64 security / crypto / bit / vendor-extension visibility effects.
        -- Phase-one model: most feature-specific state is exposed as RIP-side activity.
    
        -- CET / indirect branch tracking.
    
        {
            node_type = "instruction",
            mnemonic = "endbr32",
            operands = {},
            effect = {
                kind = "register_write",
                name = "endbr32_cet_branch_target",
                target_register = "rip",
                role = "marked valid 32-bit indirect branch target by endbr32",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "endbr64",
            operands = {},
            effect = {
                kind = "register_write",
                name = "endbr64_cet_branch_target",
                target_register = "rip",
                role = "marked valid 64-bit indirect branch target by endbr64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "incsspd",
            operands = {
                { index = 1, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "incsspd_updates_shadow_stack",
                target_register = "rip",
                role = "incremented 32-bit shadow stack pointer by incsspd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "incsspq",
            operands = {
                { index = 1, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "incsspq_updates_shadow_stack",
                target_register = "rip",
                role = "incremented 64-bit shadow stack pointer by incsspq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rstorssp",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "rstorssp_updates_shadow_stack",
                target_register = "rip",
                role = "restored shadow stack pointer by rstorssp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "saveprevssp",
            operands = {},
            effect = {
                kind = "register_write",
                name = "saveprevssp_updates_shadow_stack",
                target_register = "rip",
                role = "saved previous shadow stack pointer by saveprevssp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "clrssbsy",
            operands = {
                { index = 1, role = "token" },
            },
            effect = {
                kind = "register_write",
                name = "clrssbsy_updates_shadow_stack",
                target_register = "rip",
                role = "cleared shadow stack busy token by clrssbsy",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "wbnoinvd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "wbnoinvd_cache_writeback",
                target_register = "rip",
                role = "wrote back caches without invalidation by wbnoinvd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "clzero",
            operands = {},
            effect = {
                kind = "register_write",
                name = "clzero_cache_zero",
                target_register = "rip",
                role = "zeroed cache line by clzero",
            },
        }
,

    -- Key Locker.
    
        {
            node_type = "instruction",
            mnemonic = "loadiwkey",
            operands = {
                { index = 1, role = "control" },
                { index = 2, role = "key_source" },
            },
            effect = {
                kind = "register_write",
                name = "loadiwkey_updates_key_locker_state",
                target_register = "rip",
                role = "loaded internal wrapping key by loadiwkey",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "encodekey128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "encodekey128_key_locker",
                target_register = "rip",
                role = "encoded 128-bit aes key handle by encodekey128",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "encodekey256",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "encodekey256_key_locker",
                target_register = "rip",
                role = "encoded 256-bit aes key handle by encodekey256",
            },
        }
,

    -- MPX bounds instructions.
    
        {
            node_type = "instruction",
            mnemonic = "bndmk",
            operands = {
                { index = 1, role = "bounds_destination" },
                { index = 2, role = "address" },
            },
            effect = {
                kind = "register_write",
                name = "bndmk_updates_bounds_state",
                target_register = "rip",
                role = "made bounds register from address by bndmk",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bndcl",
            operands = {
                { index = 1, role = "bounds" },
                { index = 2, role = "address" },
            },
            effect = {
                kind = "register_write",
                name = "bndcl_checks_bounds",
                target_register = "rip",
                role = "checked lower bound by bndcl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bndcu",
            operands = {
                { index = 1, role = "bounds" },
                { index = 2, role = "address" },
            },
            effect = {
                kind = "register_write",
                name = "bndcu_checks_bounds",
                target_register = "rip",
                role = "checked upper bound by bndcu",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bndcn",
            operands = {
                { index = 1, role = "bounds" },
                { index = 2, role = "address" },
            },
            effect = {
                kind = "register_write",
                name = "bndcn_checks_bounds",
                target_register = "rip",
                role = "checked upper bound with complement by bndcn",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bndmov",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "bndmov_updates_bounds_state",
                target_register = "rip",
                role = "moved bounds register state by bndmov",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bndldx",
            operands = {
                { index = 1, role = "bounds_destination" },
                { index = 2, role = "address" },
            },
            effect = {
                kind = "register_write",
                name = "bndldx_updates_bounds_state",
                target_register = "rip",
                role = "loaded bounds using address translation by bndldx",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bndstx",
            operands = {
                { index = 1, role = "address" },
                { index = 2, role = "bounds_source" },
            },
            effect = {
                kind = "register_write",
                name = "bndstx_updates_bounds_state",
                target_register = "rip",
                role = "stored bounds using address translation by bndstx",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "blci",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blci_writes_destination",
                target_operand = 1,
                role = "written with lowest clear bit isolated by blci",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "blcic",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blcic_writes_destination",
                target_operand = 1,
                role = "written with inverted lowest clear bit isolated by blcic",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "blcmsk",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blcmsk_writes_destination",
                target_operand = 1,
                role = "written with mask from lowest clear bit by blcmsk",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "blcs",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blcs_writes_destination",
                target_operand = 1,
                role = "written with lowest clear bit set by blcs",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "t1mskc",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "t1mskc_writes_destination",
                target_operand = 1,
                role = "written with trailing-one mask complement by t1mskc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tzmsk",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "tzmsk_writes_destination",
                target_operand = 1,
                role = "written with trailing-zero mask by tzmsk",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rmpadjust",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rmpadjust_updates_platform_state",
                target_register = "rip",
                role = "adjusted reverse map table state by rmpadjust",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rmpupdate",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rmpupdate_updates_platform_state",
                target_register = "rip",
                role = "updated reverse map table state by rmpupdate",
            },
        }
,

    -- TDX / SEAM-style platform transition helpers.
    
        {
            node_type = "instruction",
            mnemonic = "tdcall",
            operands = {},
            effect = {
                kind = "register_write",
                name = "tdcall_updates_rip",
                target_register = "rip",
                role = "called trusted domain module by tdcall",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "haddps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "haddps_vector_horizontal",
                target_register = "rip",
                role = "horizontally added packed single-precision values by haddps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "haddpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "haddpd_vector_horizontal",
                target_register = "rip",
                role = "horizontally added packed double-precision values by haddpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "hsubps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "hsubps_vector_horizontal",
                target_register = "rip",
                role = "horizontally subtracted packed single-precision values by hsubps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "hsubpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "hsubpd_vector_horizontal",
                target_register = "rip",
                role = "horizontally subtracted packed double-precision values by hsubpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lddqu",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "lddqu_vector_load",
                target_register = "rip",
                role = "loaded unaligned double-quadword integer data by lddqu",
            },
        }
,

    -- SSE4 blend helpers.
    
        {
            node_type = "instruction",
            mnemonic = "blendps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "blendps_vector_blend",
                target_register = "rip",
                role = "blended packed single-precision values by blendps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "blendpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "blendpd_vector_blend",
                target_register = "rip",
                role = "blended packed double-precision values by blendpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "blendvps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blendvps_vector_blend",
                target_register = "rip",
                role = "variable-blended packed single-precision values by blendvps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "blendvpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blendvpd_vector_blend",
                target_register = "rip",
                role = "variable-blended packed double-precision values by blendvpd",
            },
        }
,

    -- SSE4 insert / extract helpers.
    
        {
            node_type = "instruction",
            mnemonic = "extractps",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "extractps_writes_gpr",
                target_operand = 1,
                role = "written with extracted single-precision lane by extractps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "maskmovq",
            operands = {
                { index = 1, role = "source" },
                { index = 2, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "maskmovq_masked_store",
                target_register = "rip",
                role = "masked-stored bytes from mmx state by maskmovq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "maskmovdqu",
            operands = {
                { index = 1, role = "source" },
                { index = 2, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "maskmovdqu_masked_store",
                target_register = "rip",
                role = "masked-stored bytes from xmm state by maskmovdqu",
            },
        }
,

    -- Legacy segment-load helpers.
    
        {
            node_type = "instruction",
            mnemonic = "lds",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "far_pointer" },
            },
            effect = {
                kind = "register_write",
                name = "lds_writes_destination",
                target_operand = 1,
                role = "written from far pointer by lds",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lds",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "far_pointer" },
            },
            effect = {
                kind = "register_write",
                name = "lds_updates_segment_state",
                target_register = "rip",
                role = "loaded ds segment state by lds",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "les",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "far_pointer" },
            },
            effect = {
                kind = "register_write",
                name = "les_writes_destination",
                target_operand = 1,
                role = "written from far pointer by les",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "les",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "far_pointer" },
            },
            effect = {
                kind = "register_write",
                name = "les_updates_segment_state",
                target_register = "rip",
                role = "loaded es segment state by les",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lfs",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "far_pointer" },
            },
            effect = {
                kind = "register_write",
                name = "lfs_writes_destination",
                target_operand = 1,
                role = "written from far pointer by lfs",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lfs",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "far_pointer" },
            },
            effect = {
                kind = "register_write",
                name = "lfs_updates_segment_state",
                target_register = "rip",
                role = "loaded fs segment state by lfs",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lgs",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "far_pointer" },
            },
            effect = {
                kind = "register_write",
                name = "lgs_writes_destination",
                target_operand = 1,
                role = "written from far pointer by lgs",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lgs",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "far_pointer" },
            },
            effect = {
                kind = "register_write",
                name = "lgs_updates_segment_state",
                target_register = "rip",
                role = "loaded gs segment state by lgs",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lss",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "far_pointer" },
            },
            effect = {
                kind = "register_write",
                name = "lss_writes_destination",
                target_operand = 1,
                role = "written from far pointer by lss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "far_pointer" },
            },
            effect = {
                kind = "register_write",
                name = "lss_updates_segment_state",
                target_register = "rip",
                role = "loaded ss segment state by lss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bound",
            operands = {
                { index = 1, role = "index" },
                { index = 2, role = "bounds" },
            },
            effect = {
                kind = "register_write",
                name = "bound_checks_bounds",
                target_register = "rip",
                role = "checked array bounds by bound",
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
                name = "lsl_writes_destination",
                target_operand = 1,
                role = "written with segment limit by lsl",
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
                name = "lar_writes_destination",
                target_operand = 1,
                role = "written with access rights by lar",
            },
        }
,

    -- Miscellaneous legacy control / undefined / invalid aliases.
    
        {
            node_type = "instruction",
            mnemonic = "icebp",
            operands = {},
            effect = {
                kind = "register_write",
                name = "icebp_updates_rip",
                target_register = "rip",
                role = "entered one-byte debug interrupt by icebp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "int1",
            operands = {},
            effect = {
                kind = "register_write",
                name = "int1_updates_rip",
                target_register = "rip",
                role = "entered debug interrupt by int1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ud0",
            operands = {},
            effect = {
                kind = "register_write",
                name = "ud0_invalid_instruction",
                target_register = "rip",
                role = "entered invalid-instruction path by ud0",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ud1",
            operands = {},
            effect = {
                kind = "register_write",
                name = "ud1_invalid_instruction",
                target_register = "rip",
                role = "entered invalid-instruction path by ud1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ud2a",
            operands = {},
            effect = {
                kind = "register_write",
                name = "ud2a_invalid_instruction",
                target_register = "rip",
                role = "entered invalid-instruction path by ud2a",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "eaccept",
            operands = {},
            effect = {
                kind = "register_write",
                name = "eaccept_updates_enclave_state",
                target_register = "rip",
                role = "accepted sgx enclave page by eaccept",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "eacceptcopy",
            operands = {},
            effect = {
                kind = "register_write",
                name = "eacceptcopy_updates_enclave_state",
                target_register = "rip",
                role = "accepted copied sgx enclave page by eacceptcopy",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "eaug",
            operands = {},
            effect = {
                kind = "register_write",
                name = "eaug_updates_enclave_state",
                target_register = "rip",
                role = "augmented sgx enclave page by eaug",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "eblock",
            operands = {},
            effect = {
                kind = "register_write",
                name = "eblock_updates_enclave_state",
                target_register = "rip",
                role = "blocked sgx enclave page by eblock",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ecreate",
            operands = {},
            effect = {
                kind = "register_write",
                name = "ecreate_updates_enclave_state",
                target_register = "rip",
                role = "created sgx enclave control structure by ecreate",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "edbgrd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "edbgrd_updates_enclave_state",
                target_register = "rip",
                role = "debug-read sgx enclave memory by edbgrd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "edbgwr",
            operands = {},
            effect = {
                kind = "register_write",
                name = "edbgwr_updates_enclave_state",
                target_register = "rip",
                role = "debug-wrote sgx enclave memory by edbgwr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "eenter",
            operands = {},
            effect = {
                kind = "register_write",
                name = "eenter_updates_rip",
                target_register = "rip",
                role = "entered sgx enclave by eenter",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "eexit",
            operands = {},
            effect = {
                kind = "register_write",
                name = "eexit_updates_rip",
                target_register = "rip",
                role = "exited sgx enclave by eexit",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "egetkey",
            operands = {},
            effect = {
                kind = "register_write",
                name = "egetkey_updates_enclave_state",
                target_register = "rip",
                role = "derived sgx enclave key by egetkey",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "einit",
            operands = {},
            effect = {
                kind = "register_write",
                name = "einit_updates_enclave_state",
                target_register = "rip",
                role = "initialized sgx enclave by einit",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "eldb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "eldb_updates_enclave_state",
                target_register = "rip",
                role = "loaded blocked sgx enclave page by eldb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "eldu",
            operands = {},
            effect = {
                kind = "register_write",
                name = "eldu_updates_enclave_state",
                target_register = "rip",
                role = "loaded unblocked sgx enclave page by eldu",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "emodpe",
            operands = {},
            effect = {
                kind = "register_write",
                name = "emodpe_updates_enclave_state",
                target_register = "rip",
                role = "modified sgx enclave page permissions by emodpe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "emodpr",
            operands = {},
            effect = {
                kind = "register_write",
                name = "emodpr_updates_enclave_state",
                target_register = "rip",
                role = "restricted sgx enclave page permissions by emodpr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "emodt",
            operands = {},
            effect = {
                kind = "register_write",
                name = "emodt_updates_enclave_state",
                target_register = "rip",
                role = "modified sgx enclave page type by emodt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "epa",
            operands = {},
            effect = {
                kind = "register_write",
                name = "epa_updates_enclave_state",
                target_register = "rip",
                role = "created sgx version array page by epa",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "erdinfo",
            operands = {},
            effect = {
                kind = "register_write",
                name = "erdinfo_updates_enclave_state",
                target_register = "rip",
                role = "read sgx enclave report information by erdinfo",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "eremove",
            operands = {},
            effect = {
                kind = "register_write",
                name = "eremove_updates_enclave_state",
                target_register = "rip",
                role = "removed sgx enclave page by eremove",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "eresume",
            operands = {},
            effect = {
                kind = "register_write",
                name = "eresume_updates_rip",
                target_register = "rip",
                role = "resumed sgx enclave by eresume",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "etrack",
            operands = {},
            effect = {
                kind = "register_write",
                name = "etrack_updates_enclave_state",
                target_register = "rip",
                role = "tracked sgx enclave page invalidation by etrack",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "eextend",
            operands = {},
            effect = {
                kind = "register_write",
                name = "eextend_updates_enclave_state",
                target_register = "rip",
                role = "extended sgx enclave measurement by eextend",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "egetsec",
            operands = {},
            effect = {
                kind = "register_write",
                name = "egetsec_updates_security_state",
                target_register = "rip",
                role = "entered measured security operation by egetsec",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "senter",
            operands = {},
            effect = {
                kind = "register_write",
                name = "senter_updates_security_state",
                target_register = "rip",
                role = "entered measured launch environment by senter",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sexit",
            operands = {},
            effect = {
                kind = "register_write",
                name = "sexit_updates_security_state",
                target_register = "rip",
                role = "exited measured launch environment by sexit",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cldemote",
            operands = {
                { index = 1, role = "address" },
            },
            effect = {
                kind = "register_write",
                name = "cldemote_updates_cache_state",
                target_register = "rip",
                role = "demoted cache line by cldemote",
            },
        }
,

    -- Lightweight profiling / monitoring helpers.
    
        {
            node_type = "instruction",
            mnemonic = "llwpcb",
            operands = {
                { index = 1, role = "address" },
            },
            effect = {
                kind = "register_write",
                name = "llwpcb_updates_profiling_state",
                target_register = "rip",
                role = "loaded lightweight profiling control block by llwpcb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "slwpcb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "slwpcb_writes_destination",
                target_operand = 1,
                role = "written with lightweight profiling control block address by slwpcb",
            },
        }
,

    -- VIA PadLock / old x86 crypto helpers.
    
        {
            node_type = "instruction",
            mnemonic = "xstore",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xstore_updates_crypto_state",
                target_register = "rip",
                role = "stored hardware random bytes by xstore",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xcryptecb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xcryptecb_updates_crypto_state",
                target_register = "rip",
                role = "performed hardware aes ecb operation by xcryptecb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xcryptcbc",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xcryptcbc_updates_crypto_state",
                target_register = "rip",
                role = "performed hardware aes cbc operation by xcryptcbc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xcryptcfb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xcryptcfb_updates_crypto_state",
                target_register = "rip",
                role = "performed hardware aes cfb operation by xcryptcfb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xcryptofb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xcryptofb_updates_crypto_state",
                target_register = "rip",
                role = "performed hardware aes ofb operation by xcryptofb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xcryptctr",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xcryptctr_updates_crypto_state",
                target_register = "rip",
                role = "performed hardware aes ctr operation by xcryptctr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "montmul",
            operands = {},
            effect = {
                kind = "register_write",
                name = "montmul_updates_crypto_state",
                target_register = "rip",
                role = "performed hardware montgomery multiply by montmul",
            },
        }
,

    -- System-call aliases / compatibility spellings.
    
        {
            node_type = "instruction",
            mnemonic = "sysretl",
            operands = {},
            effect = {
                kind = "register_write",
                name = "sysretl_updates_rip",
                target_register = "rip",
                role = "returned from system call in compatibility form by sysretl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sysretl",
            operands = {},
            effect = {
                kind = "register_write",
                name = "sysretl_clobbers_rcx",
                target_register = "rcx",
                role = "clobbered by system call return sysretl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sysretl",
            operands = {},
            effect = {
                kind = "register_write",
                name = "sysretl_clobbers_r11",
                target_register = "r11",
                role = "clobbered by system call return sysretl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sysexitl",
            operands = {},
            effect = {
                kind = "register_write",
                name = "sysexitl_updates_rip",
                target_register = "rip",
                role = "returned from fast system call in compatibility form by sysexitl",
            },
        }
,

    -- Real-mode / system-management-ish compatibility spellings.
    
        {
            node_type = "instruction",
            mnemonic = "rsm",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rsm_updates_rip",
                target_register = "rip",
                role = "resumed from system management mode by rsm",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "smi",
            operands = {},
            effect = {
                kind = "register_write",
                name = "smi_updates_rip",
                target_register = "rip",
                role = "entered system management interrupt path by smi",
            },
        }
,

    -- INC / DEC suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "incb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "incb_writes_destination",
                target_operand = 1,
                role = "incremented byte by incb",
                value_delta = 1,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "incw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "incw_writes_destination",
                target_operand = 1,
                role = "incremented word by incw",
                value_delta = 1,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "incl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "incl_writes_destination",
                target_operand = 1,
                role = "incremented long by incl",
                value_delta = 1,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "incq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "incq_writes_destination",
                target_operand = 1,
                role = "incremented quadword by incq",
                value_delta = 1,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "decb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "decb_writes_destination",
                target_operand = 1,
                role = "decremented byte by decb",
                value_delta = -1,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "decq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "decq_writes_destination",
                target_operand = 1,
                role = "decremented quadword by decq",
                value_delta = -1,
            },
        }
,

    -- NEG suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "negb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "negb_writes_destination",
                target_operand = 1,
                role = "arithmetically negated byte by negb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "negw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "negw_writes_destination",
                target_operand = 1,
                role = "arithmetically negated word by negw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "negl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "negl_writes_destination",
                target_operand = 1,
                role = "arithmetically negated long by negl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "negq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "negq_writes_destination",
                target_operand = 1,
                role = "arithmetically negated quadword by negq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "decw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "decw_writes_destination",
                target_operand = 1,
                role = "decremented word by decw",
                value_delta = -1,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "decl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "decl_writes_destination",
                target_operand = 1,
                role = "decremented long by decl",
                value_delta = -1,
            },
        }
,

    -- Classic accumulator sign-extension aliases.
    
        {
            node_type = "instruction",
            mnemonic = "cbtw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cbtw_writes_rax",
                target_register = "rax",
                role = "sign-extended byte accumulator to word by cbtw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cwtl",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cwtl_writes_rax",
                target_register = "rax",
                role = "sign-extended word accumulator to long by cwtl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cltq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cltq_writes_rax",
                target_register = "rax",
                role = "sign-extended long accumulator to quadword by cltq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cwtd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cwtd_writes_rdx",
                target_register = "rdx",
                role = "sign-extended word accumulator into dx by cwtd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cltd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cltd_writes_rdx",
                target_register = "rdx",
                role = "sign-extended long accumulator into edx by cltd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cqto",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cqto_writes_rdx",
                target_register = "rdx",
                role = "sign-extended quadword accumulator into rdx by cqto",
            },
        }
,

    -- Intel spellings, kept for parser/disassembler compatibility.
    
        {
            node_type = "instruction",
            mnemonic = "cbw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cbw_writes_rax",
                target_register = "rax",
                role = "sign-extended byte accumulator to word by cbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cwde",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cwde_writes_rax",
                target_register = "rax",
                role = "sign-extended word accumulator to doubleword by cwde",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cdqe",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cdqe_writes_rax",
                target_register = "rax",
                role = "sign-extended doubleword accumulator to quadword by cdqe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cwd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cwd_writes_rdx",
                target_register = "rdx",
                role = "sign-extended word accumulator into dx by cwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cdq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cdq_writes_rdx",
                target_register = "rdx",
                role = "sign-extended doubleword accumulator into edx by cdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cqo",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cqo_writes_rdx",
                target_register = "rdx",
                role = "sign-extended quadword accumulator into rdx by cqo",
            },
        }
,

    -- String / IO / REP-prefixed alias completion.
        -- These improve recognition of parser/disassembler spellings where prefixes are folded into mnemonics.
    
        -- REP MOVS aliases.
    
        {
            node_type = "instruction",
            mnemonic = "rep_movsb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_movsb_updates_rsi",
                target_register = "rsi",
                role = "advanced by repeated byte string move source rep_movsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_movsb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_movsb_updates_rdi",
                target_register = "rdi",
                role = "advanced by repeated byte string move destination rep_movsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_movsb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_movsb_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by rep_movsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_movsw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_movsw_updates_rsi",
                target_register = "rsi",
                role = "advanced by repeated word string move source rep_movsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_movsw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_movsw_updates_rdi",
                target_register = "rdi",
                role = "advanced by repeated word string move destination rep_movsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_movsw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_movsw_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by rep_movsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_movsd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_movsd_updates_rsi",
                target_register = "rsi",
                role = "advanced by repeated doubleword string move source rep_movsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_movsd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_movsd_updates_rdi",
                target_register = "rdi",
                role = "advanced by repeated doubleword string move destination rep_movsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_movsd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_movsd_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by rep_movsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_movsq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_movsq_updates_rsi",
                target_register = "rsi",
                role = "advanced by repeated quadword string move source rep_movsq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_movsq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_movsq_updates_rdi",
                target_register = "rdi",
                role = "advanced by repeated quadword string move destination rep_movsq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_movsq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_movsq_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by rep_movsq",
            },
        }
,

    -- REP STOS aliases.
    
        {
            node_type = "instruction",
            mnemonic = "rep_stosb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_stosb_updates_rdi",
                target_register = "rdi",
                role = "advanced by repeated byte string store destination rep_stosb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_stosb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_stosb_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by rep_stosb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_stosw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_stosw_updates_rdi",
                target_register = "rdi",
                role = "advanced by repeated word string store destination rep_stosw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_stosw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_stosw_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by rep_stosw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_stosd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_stosd_updates_rdi",
                target_register = "rdi",
                role = "advanced by repeated doubleword string store destination rep_stosd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_stosd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_stosd_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by rep_stosd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_stosq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_stosq_updates_rdi",
                target_register = "rdi",
                role = "advanced by repeated quadword string store destination rep_stosq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_stosq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_stosq_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by rep_stosq",
            },
        }
,

    -- REP LODS aliases.
    
        {
            node_type = "instruction",
            mnemonic = "rep_lodsb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_lodsb_updates_rax",
                target_register = "rax",
                role = "loaded repeated byte string value into accumulator by rep_lodsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_lodsb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_lodsb_updates_rsi",
                target_register = "rsi",
                role = "advanced by repeated byte string load source rep_lodsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_lodsb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_lodsb_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by rep_lodsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_lodsq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_lodsq_updates_rax",
                target_register = "rax",
                role = "loaded repeated quadword string value into accumulator by rep_lodsq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_lodsq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_lodsq_updates_rsi",
                target_register = "rsi",
                role = "advanced by repeated quadword string load source rep_lodsq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_lodsq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_lodsq_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by rep_lodsq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "repe_cmpsb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "repe_cmpsb_updates_rsi",
                target_register = "rsi",
                role = "advanced by repeated byte compare source repe_cmpsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "repe_cmpsb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "repe_cmpsb_updates_rdi",
                target_register = "rdi",
                role = "advanced by repeated byte compare destination repe_cmpsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "repe_cmpsb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "repe_cmpsb_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by repe_cmpsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "repz_cmpsb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "repz_cmpsb_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by repz_cmpsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "repne_scasb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "repne_scasb_updates_rdi",
                target_register = "rdi",
                role = "advanced by repeated byte string scan destination repne_scasb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "repne_scasb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "repne_scasb_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by repne_scasb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "repnz_scasb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "repnz_scasb_updates_rdi",
                target_register = "rdi",
                role = "advanced by repeated byte string scan destination repnz_scasb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "repnz_scasb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "repnz_scasb_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by repnz_scasb",
            },
        }
,

    -- REP IO string aliases.
    
        {
            node_type = "instruction",
            mnemonic = "rep_insb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_insb_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by repeated byte input string rep_insb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_insb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_insb_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by rep_insb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_insq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_insq_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by repeated quadword input string rep_insq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_insq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_insq_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by rep_insq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_outsb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_outsb_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by repeated byte output string rep_outsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_outsb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_outsb_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by rep_outsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_outsq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_outsq_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by repeated quadword output string rep_outsq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rep_outsq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rep_outsq_updates_rcx",
                target_register = "rcx",
                role = "consumed repeat count by rep_outsq",
            },
        }
,
}
