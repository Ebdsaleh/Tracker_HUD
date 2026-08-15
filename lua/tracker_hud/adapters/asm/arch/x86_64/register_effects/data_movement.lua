-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/data_movement.lua
--
-- x86-64 data movement register effect specs.
--
-- Remaining legacy records not yet migrated into the categorized
-- Tree-sitter-first register-effect modules.

--
-- String MOVS/LODS/STOS/CMPS/SCAS/INS/OUTS effects were migrated to register_effects/string/.
--

return {
    {
                    node_type = "instruction",
                    mnemonic = "xlatb",

                    operands = {},

                    effect = {
                        kind = "register_write",
                        name = "xlatb_writes_rax",
                        target_register = "rax",
                        role = "loaded translated byte into al by xlatb",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "xlat",
                    operands = {},
                    effect = {
                        kind = "register_write",
                        name = "xlat_writes_rax",
                        target_register = "rax",
                        written_alias = "al",
                        role = "loaded translated byte into al by xlat",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movaps",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movaps_simd_move",
                        target_register = "rip",
                        role = "moved aligned packed single-precision values by movaps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movups",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movups_simd_move",
                        target_register = "rip",
                        role = "moved unaligned packed single-precision values by movups",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movapd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movapd_simd_move",
                        target_register = "rip",
                        role = "moved aligned packed double-precision values by movapd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movupd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movupd_simd_move",
                        target_register = "rip",
                        role = "moved unaligned packed double-precision values by movupd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movdqa",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movdqa_simd_move",
                        target_register = "rip",
                        role = "moved aligned packed integer values by movdqa",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movdqu",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movdqu_simd_move",
                        target_register = "rip",
                        role = "moved unaligned packed integer values by movdqu",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movntdq",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movntdq_simd_store",
                        target_register = "rip",
                        role = "stored packed integer values non-temporally by movntdq",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movntdqa",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movntdqa_simd_load",
                        target_register = "rip",
                        role = "loaded aligned packed integer values non-temporally by movntdqa",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movntps",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movntps_simd_store",
                        target_register = "rip",
                        role = "stored packed single-precision values non-temporally by movntps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movntpd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movntpd_simd_store",
                        target_register = "rip",
                        role = "stored packed double-precision values non-temporally by movntpd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movss",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movss_scalar_simd_move",
                        target_register = "rip",
                        role = "moved scalar single-precision value by movss",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movsd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movsd_scalar_simd_move",
                        target_register = "rip",
                        role = "moved scalar double-precision value by movsd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "cmpss",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
                    effect = {
                        kind = "register_write",
                        name = "cmpss_scalar_simd_compare",
                        target_register = "rip",
                        role = "compared scalar single-precision values by cmpss",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "cmpsd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
                    effect = {
                        kind = "register_write",
                        name = "cmpsd_scalar_simd_compare",
                        target_register = "rip",
                        role = "compared scalar double-precision values by cmpsd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movhlps",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movhlps_simd_shuffle",
                        target_register = "rip",
                        role = "moved high packed single-precision lanes by movhlps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movlhps",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movlhps_simd_shuffle",
                        target_register = "rip",
                        role = "moved low packed single-precision lanes by movlhps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movhps",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movhps_simd_move",
                        target_register = "rip",
                        role = "moved high packed single-precision lanes by movhps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movlps",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movlps_simd_move",
                        target_register = "rip",
                        role = "moved low packed single-precision lanes by movlps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movhpd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movhpd_simd_move",
                        target_register = "rip",
                        role = "moved high packed double-precision lane by movhpd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movlpd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movlpd_simd_move",
                        target_register = "rip",
                        role = "moved low packed double-precision lane by movlpd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movmskps",
                    operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movmskps_writes_gpr",
                        target_operand = 1,
                        role = "written with packed single-precision sign mask by movmskps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movmskpd",
                    operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "movmskpd_writes_gpr",
                        target_operand = 1,
                        role = "written with packed double-precision sign mask by movmskpd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movsldup",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movsldup_vector_duplicate",
                        target_register = "rip",
                        role = "duplicated low packed single-precision lanes by movsldup",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movshdup",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movshdup_vector_duplicate",
                        target_register = "rip",
                        role = "duplicated high packed single-precision lanes by movshdup",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movddup",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movddup_vector_duplicate",
                        target_register = "rip",
                        role = "duplicated low scalar double-precision lane by movddup",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "insertps",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "control" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "insertps_vector_insert",
                        target_register = "rip",
                        role = "inserted single-precision lane by insertps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movd",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movd_mmx_sse_move",
                        target_register = "rip",
                        role = "moved doubleword between integer and multimedia state by movd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movq",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movq_mmx_sse_move",
                        target_register = "rip",
                        role = "moved quadword between integer and multimedia state by movq",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movdq2q",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movdq2q_sse_mmx_bridge",
                        target_register = "rip",
                        role = "moved low quadword from xmm state to mmx state by movdq2q",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movq2dq",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movq2dq_mmx_sse_bridge",
                        target_register = "rip",
                        role = "moved quadword from mmx state to xmm state by movq2dq",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movntq",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movntq_nontemporal_store",
                        target_register = "rip",
                        role = "stored mmx quadword non-temporally by movntq",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movntsd",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movntsd_nontemporal_store",
                        target_register = "rip",
                        role = "stored scalar double-precision value non-temporally by movntsd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movntss",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movntss_nontemporal_store",
                        target_register = "rip",
                        role = "stored scalar single-precision value non-temporally by movntss",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "cmpss",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "predicate" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmpss_scalar_fp_compare",
                        target_register = "rip",
                        role = "performed scalar single-precision compare by cmpss",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "cmpsd",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "predicate" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "cmpsd_scalar_fp_compare",
                        target_register = "rip",
                        role = "performed scalar double-precision compare by cmpsd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movaps",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movaps_vector_move",
                        target_register = "rip",
                        role = "moved aligned packed single-precision value by movaps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movups",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movups_vector_move",
                        target_register = "rip",
                        role = "moved unaligned packed single-precision value by movups",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movapd",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movapd_vector_move",
                        target_register = "rip",
                        role = "moved aligned packed double-precision value by movapd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movupd",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movupd_vector_move",
                        target_register = "rip",
                        role = "moved unaligned packed double-precision value by movupd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movdqa",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movdqa_vector_move",
                        target_register = "rip",
                        role = "moved aligned packed integer value by movdqa",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movdqu",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movdqu_vector_move",
                        target_register = "rip",
                        role = "moved unaligned packed integer value by movdqu",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movntps",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movntps_streaming_store",
                        target_register = "rip",
                        role = "performed non-temporal packed single-precision store by movntps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movntpd",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movntpd_streaming_store",
                        target_register = "rip",
                        role = "performed non-temporal packed double-precision store by movntpd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movntdq",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movntdq_streaming_store",
                        target_register = "rip",
                        role = "performed non-temporal packed integer store by movntdq",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movhlps",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movhlps_vector_lane_move",
                        target_register = "rip",
                        role = "moved high packed single-precision lanes to low lanes by movhlps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movlhps",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movlhps_vector_lane_move",
                        target_register = "rip",
                        role = "moved low packed single-precision lanes to high lanes by movlhps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movlps",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movlps_vector_low_move",
                        target_register = "rip",
                        role = "moved low packed single-precision lanes by movlps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movhps",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movhps_vector_high_move",
                        target_register = "rip",
                        role = "moved high packed single-precision lanes by movhps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movlpd",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movlpd_vector_low_move",
                        target_register = "rip",
                        role = "moved low packed double-precision lane by movlpd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movhpd",
                    operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movhpd_vector_high_move",
                        target_register = "rip",
                        role = "moved high packed double-precision lane by movhpd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movmskps",
                    operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movmskps_writes_destination",
                        target_operand = 1,
                        role = "written with packed single-precision sign mask by movmskps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "movmskpd",
                    operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "movmskpd_writes_destination",
                        target_operand = 1,
                        role = "written with packed double-precision sign mask by movmskpd",
                    },
                }
,

}
