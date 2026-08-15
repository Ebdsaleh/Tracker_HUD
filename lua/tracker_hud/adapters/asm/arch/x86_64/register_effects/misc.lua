-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/misc.lua
--
-- x86-64 misc register effect specs.
--
-- Remaining legacy records not yet migrated into the categorized
-- Tree-sitter-first register-effect modules.

--
-- REP/REPE/REPZ/REPNE/REPNZ and combined repeated-string effects were migrated to register_effects/string/repeat_prefix.lua.
--

return {
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

}
