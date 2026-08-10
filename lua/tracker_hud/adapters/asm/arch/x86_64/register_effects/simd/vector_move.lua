-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/vector_move.lua

-- x86-64 SIMD register effect specs: vector move.

return {
    -- F16C / legacy FMA / AMD XOP / 3DNow! / legacy multimedia visibility effects.
        -- Phase-one model: no vector/MMX/3DNow register file yet, so vector-only effects are exposed as RIP-side activity.
    
        -- F16C half-precision conversion helpers.
    
        {
            node_type = "instruction",
            mnemonic = "vcvtph2ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtph2ps_vector_f16c_convert",
                target_register = "rip",
                role = "converted packed half-precision values to single-precision values by vcvtph2ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtps2ph",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "rounding" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtps2ph_vector_f16c_convert",
                target_register = "rip",
                role = "converted packed single-precision values to half-precision values by vcvtps2ph",
            },
        }
,

    -- Legacy FMA4-style AMD fused multiply-add helpers.
        -- These are vendor-specific / older extension forms, useful for recognition in disassembly.
    
        {
            node_type = "instruction",
            mnemonic = "vfmaddps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "addend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddps_vector_fma4",
                target_register = "rip",
                role = "fused multiply-added packed single-precision values by vfmaddps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmaddpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "addend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddpd_vector_fma4",
                target_register = "rip",
                role = "fused multiply-added packed double-precision values by vfmaddpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmaddss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "addend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddss_scalar_fma4",
                target_register = "rip",
                role = "fused multiply-added scalar single-precision value by vfmaddss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmaddsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "addend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddsd_scalar_fma4",
                target_register = "rip",
                role = "fused multiply-added scalar double-precision value by vfmaddsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsubps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "subtrahend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubps_vector_fma4",
                target_register = "rip",
                role = "fused multiply-subtracted packed single-precision values by vfmsubps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsubpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "subtrahend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubpd_vector_fma4",
                target_register = "rip",
                role = "fused multiply-subtracted packed double-precision values by vfmsubpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsubss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "subtrahend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubss_scalar_fma4",
                target_register = "rip",
                role = "fused multiply-subtracted scalar single-precision value by vfmsubss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsubsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "subtrahend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubsd_scalar_fma4",
                target_register = "rip",
                role = "fused multiply-subtracted scalar double-precision value by vfmsubsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmaddps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "addend" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmaddps_vector_fma4",
                target_register = "rip",
                role = "negative fused multiply-added packed single-precision values by vfnmaddps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmaddpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "addend" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmaddpd_vector_fma4",
                target_register = "rip",
                role = "negative fused multiply-added packed double-precision values by vfnmaddpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsubps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "subtrahend" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsubps_vector_fma4",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed single-precision values by vfnmsubps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsubpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "subtrahend" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsubpd_vector_fma4",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed double-precision values by vfnmsubpd",
            },
        }
,

    -- AMD XOP integer compare / conditional move / permutation helpers.
    
        {
            node_type = "instruction",
            mnemonic = "vpcomb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcomb_vector_xop_compare",
                target_register = "rip",
                role = "compared packed signed bytes by vpcomb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcomw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcomw_vector_xop_compare",
                target_register = "rip",
                role = "compared packed signed words by vpcomw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcomd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcomd_vector_xop_compare",
                target_register = "rip",
                role = "compared packed signed doublewords by vpcomd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcomq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcomq_vector_xop_compare",
                target_register = "rip",
                role = "compared packed signed quadwords by vpcomq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcomub",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcomub_vector_xop_compare",
                target_register = "rip",
                role = "compared packed unsigned bytes by vpcomub",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcomuw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcomuw_vector_xop_compare",
                target_register = "rip",
                role = "compared packed unsigned words by vpcomuw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcomud",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcomud_vector_xop_compare",
                target_register = "rip",
                role = "compared packed unsigned doublewords by vpcomud",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcomuq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcomuq_vector_xop_compare",
                target_register = "rip",
                role = "compared packed unsigned quadwords by vpcomuq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmov",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "true_source" },
                { index = 3, role = "false_source" },
                { index = 4, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vpcmov_vector_xop_select",
                target_register = "rip",
                role = "conditionally selected packed values by vpcmov",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpperm",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "vpperm_vector_xop_permute",
                target_register = "rip",
                role = "permuted packed bytes by vpperm",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermil2ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "selector" },
                { index = 5, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "vpermil2ps_vector_xop_permute",
                target_register = "rip",
                role = "permuted two packed single-precision sources by vpermil2ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermil2pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "selector" },
                { index = 5, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "vpermil2pd_vector_xop_permute",
                target_register = "rip",
                role = "permuted two packed double-precision sources by vpermil2pd",
            },
        }
,

    -- AMD XOP multiply / accumulate helpers.
    
        {
            node_type = "instruction",
            mnemonic = "vpmacsdd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "accumulator" },
            },
            effect = {
                kind = "register_write",
                name = "vpmacsdd_vector_xop_multiply_accumulate",
                target_register = "rip",
                role = "multiply-accumulated signed doublewords by vpmacsdd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmacsdqh",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "accumulator" },
            },
            effect = {
                kind = "register_write",
                name = "vpmacsdqh_vector_xop_multiply_accumulate",
                target_register = "rip",
                role = "multiply-accumulated signed doublewords to high quadwords by vpmacsdqh",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmacsdql",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "accumulator" },
            },
            effect = {
                kind = "register_write",
                name = "vpmacsdql_vector_xop_multiply_accumulate",
                target_register = "rip",
                role = "multiply-accumulated signed doublewords to low quadwords by vpmacsdql",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmacssdd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "accumulator" },
            },
            effect = {
                kind = "register_write",
                name = "vpmacssdd_vector_xop_multiply_accumulate",
                target_register = "rip",
                role = "saturating multiply-accumulated signed doublewords by vpmacssdd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmacsswd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "accumulator" },
            },
            effect = {
                kind = "register_write",
                name = "vpmacsswd_vector_xop_multiply_accumulate",
                target_register = "rip",
                role = "saturating multiply-accumulated signed words to doublewords by vpmacsswd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmacssww",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "accumulator" },
            },
            effect = {
                kind = "register_write",
                name = "vpmacssww_vector_xop_multiply_accumulate",
                target_register = "rip",
                role = "saturating multiply-accumulated signed words by vpmacssww",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmacswd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "accumulator" },
            },
            effect = {
                kind = "register_write",
                name = "vpmacswd_vector_xop_multiply_accumulate",
                target_register = "rip",
                role = "multiply-accumulated signed words to doublewords by vpmacswd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmacsww",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "accumulator" },
            },
            effect = {
                kind = "register_write",
                name = "vpmacsww_vector_xop_multiply_accumulate",
                target_register = "rip",
                role = "multiply-accumulated signed words by vpmacsww",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmadcsswd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "accumulator" },
            },
            effect = {
                kind = "register_write",
                name = "vpmadcsswd_vector_xop_multiply_accumulate",
                target_register = "rip",
                role = "saturating multiply-add accumulated signed words to doublewords by vpmadcsswd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmadcswd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "accumulator" },
            },
            effect = {
                kind = "register_write",
                name = "vpmadcswd_vector_xop_multiply_accumulate",
                target_register = "rip",
                role = "multiply-add accumulated signed words to doublewords by vpmadcswd",
            },
        }
,

    -- AMD XOP integer horizontal add/subtract and rotate helpers.
    
        {
            node_type = "instruction",
            mnemonic = "vphaddbd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphaddbd_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally added signed bytes to doublewords by vphaddbd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vphaddbq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphaddbq_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally added signed bytes to quadwords by vphaddbq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vphaddbw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphaddbw_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally added signed bytes to words by vphaddbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vphadddq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphadddq_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally added signed doublewords to quadwords by vphadddq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vphaddubd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphaddubd_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally added unsigned bytes to doublewords by vphaddubd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vphaddubq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphaddubq_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally added unsigned bytes to quadwords by vphaddubq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vphaddubw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphaddubw_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally added unsigned bytes to words by vphaddubw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vphaddudq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphaddudq_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally added unsigned doublewords to quadwords by vphaddudq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vphadduwd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphadduwd_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally added unsigned words to doublewords by vphadduwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vphadduwq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphadduwq_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally added unsigned words to quadwords by vphadduwq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vphaddwd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphaddwd_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally added signed words to doublewords by vphaddwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vphaddwq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphaddwq_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally added signed words to quadwords by vphaddwq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vphsubbw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphsubbw_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally subtracted signed bytes to words by vphsubbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vphsubdq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphsubdq_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally subtracted signed doublewords to quadwords by vphsubdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vphsubwd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vphsubwd_vector_xop_horizontal",
                target_register = "rip",
                role = "horizontally subtracted signed words to doublewords by vphsubwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vprotbi",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "vprotbi_vector_xop_rotate",
                target_register = "rip",
                role = "rotated packed bytes by immediate count by vprotbi",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vprotdi",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "vprotdi_vector_xop_rotate",
                target_register = "rip",
                role = "rotated packed doublewords by immediate count by vprotdi",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vprotqi",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "vprotqi_vector_xop_rotate",
                target_register = "rip",
                role = "rotated packed quadwords by immediate count by vprotqi",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vprotwi",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "vprotwi_vector_xop_rotate",
                target_register = "rip",
                role = "rotated packed words by immediate count by vprotwi",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vprotb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "counts" },
            },
            effect = {
                kind = "register_write",
                name = "vprotb_vector_xop_rotate",
                target_register = "rip",
                role = "rotated packed bytes by variable counts by vprotb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vprotd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "counts" },
            },
            effect = {
                kind = "register_write",
                name = "vprotd_vector_xop_rotate",
                target_register = "rip",
                role = "rotated packed doublewords by variable counts by vprotd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vprotq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "counts" },
            },
            effect = {
                kind = "register_write",
                name = "vprotq_vector_xop_rotate",
                target_register = "rip",
                role = "rotated packed quadwords by variable counts by vprotq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vprotw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "counts" },
            },
            effect = {
                kind = "register_write",
                name = "vprotw_vector_xop_rotate",
                target_register = "rip",
                role = "rotated packed words by variable counts by vprotw",
            },
        }
,

    -- 3DNow! / Enhanced 3DNow! visibility.
        -- These are old AMD multimedia instructions, but useful for broad disassembly recognition.
    
        {
            node_type = "instruction",
            mnemonic = "pavgusb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pavgusb_3dnow_average",
                target_register = "rip",
                role = "averaged packed unsigned bytes by pavgusb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pf2id",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pf2id_3dnow_convert",
                target_register = "rip",
                role = "converted packed single-precision values to doubleword integers by pf2id",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pf2iw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pf2iw_3dnow_convert",
                target_register = "rip",
                role = "converted packed single-precision values to word integers by pf2iw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfacc",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfacc_3dnow_accumulate",
                target_register = "rip",
                role = "accumulated packed single-precision values by pfacc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfadd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfadd_3dnow_arithmetic",
                target_register = "rip",
                role = "added packed single-precision values by pfadd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfcmpeq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfcmpeq_3dnow_compare",
                target_register = "rip",
                role = "compared packed single-precision values for equality by pfcmpeq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfcmpge",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfcmpge_3dnow_compare",
                target_register = "rip",
                role = "compared packed single-precision values greater-or-equal by pfcmpge",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfcmpgt",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfcmpgt_3dnow_compare",
                target_register = "rip",
                role = "compared packed single-precision values greater-than by pfcmpgt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfmax",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfmax_3dnow_select",
                target_register = "rip",
                role = "selected packed single-precision maximum values by pfmax",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfmin",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfmin_3dnow_select",
                target_register = "rip",
                role = "selected packed single-precision minimum values by pfmin",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfmul",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfmul_3dnow_arithmetic",
                target_register = "rip",
                role = "multiplied packed single-precision values by pfmul",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfrcp",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfrcp_3dnow_reciprocal",
                target_register = "rip",
                role = "computed approximate packed reciprocal by pfrcp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfrcpit1",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfrcpit1_3dnow_reciprocal",
                target_register = "rip",
                role = "refined approximate packed reciprocal step one by pfrcpit1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfrcpit2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfrcpit2_3dnow_reciprocal",
                target_register = "rip",
                role = "refined approximate packed reciprocal step two by pfrcpit2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfrsqit1",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfrsqit1_3dnow_reciprocal_sqrt",
                target_register = "rip",
                role = "refined approximate packed reciprocal square root by pfrsqit1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfrsqrt",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfrsqrt_3dnow_reciprocal_sqrt",
                target_register = "rip",
                role = "computed approximate packed reciprocal square root by pfrsqrt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfsub",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfsub_3dnow_arithmetic",
                target_register = "rip",
                role = "subtracted packed single-precision values by pfsub",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pfsubr",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfsubr_3dnow_arithmetic",
                target_register = "rip",
                role = "reverse-subtracted packed single-precision values by pfsubr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pi2fd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pi2fd_3dnow_convert",
                target_register = "rip",
                role = "converted packed doubleword integers to single-precision values by pi2fd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pi2fw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pi2fw_3dnow_convert",
                target_register = "rip",
                role = "converted packed word integers to single-precision values by pi2fw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmulhrw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmulhrw_3dnow_multiply",
                target_register = "rip",
                role = "multiplied packed words with rounding high result by pmulhrw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pswapd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pswapd_3dnow_shuffle",
                target_register = "rip",
                role = "swapped packed doublewords by pswapd",
            },
        }
,

    -- Older prefetch aliases / hints.
    
        {
            node_type = "instruction",
            mnemonic = "prefetch0",
            operands = {
                { index = 1, role = "address" },
            },
            effect = {
                kind = "register_write",
                name = "prefetch0_cache_hint",
                target_register = "rip",
                role = "prefetched data with level-zero locality hint by prefetch0",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "prefetch1",
            operands = {
                { index = 1, role = "address" },
            },
            effect = {
                kind = "register_write",
                name = "prefetch1_cache_hint",
                target_register = "rip",
                role = "prefetched data with level-one locality hint by prefetch1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "prefetch2",
            operands = {
                { index = 1, role = "address" },
            },
            effect = {
                kind = "register_write",
                name = "prefetch2_cache_hint",
                target_register = "rip",
                role = "prefetched data with level-two locality hint by prefetch2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "prefetchit0",
            operands = {
                { index = 1, role = "address" },
            },
            effect = {
                kind = "register_write",
                name = "prefetchit0_code_prefetch_hint",
                target_register = "rip",
                role = "prefetched code with level-zero locality hint by prefetchit0",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "prefetchit1",
            operands = {
                { index = 1, role = "address" },
            },
            effect = {
                kind = "register_write",
                name = "prefetchit1_code_prefetch_hint",
                target_register = "rip",
                role = "prefetched code with level-one locality hint by prefetchit1",
            },
        }
,

    -- Processor trace / identity / invalidation helpers.
    
        {
            node_type = "instruction",
            mnemonic = "ptwrite",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "ptwrite_updates_trace_state",
                target_register = "rip",
                role = "wrote value to processor trace stream by ptwrite",
            },
        }
,

    -- FMA3 completion pass.
        -- Phase-one model: no vector register file yet, so vector-only effects are exposed as RIP-side activity.
    
        -- VFMSUB scalar forms.
    
        {
            node_type = "instruction",
            mnemonic = "vfmsub132ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub132ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-subtracted scalar single-precision value by vfmsub132ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub213ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub213ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-subtracted scalar single-precision value by vfmsub213ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub231ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub231ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-subtracted scalar single-precision value by vfmsub231ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub132sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub132sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-subtracted scalar double-precision value by vfmsub132sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub213sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub213sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-subtracted scalar double-precision value by vfmsub213sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub231sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub231sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-subtracted scalar double-precision value by vfmsub231sd",
            },
        }
,

    -- VFNMADD packed/scalar completion.
    
        {
            node_type = "instruction",
            mnemonic = "vfnmadd132pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd132pd_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed double-precision values by vfnmadd132pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmadd213pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd213pd_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed double-precision values by vfnmadd213pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmadd231pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd231pd_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed double-precision values by vfnmadd231pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmadd132ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd132ss_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-added scalar single-precision value by vfnmadd132ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmadd213ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd213ss_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-added scalar single-precision value by vfnmadd213ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmadd231ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd231ss_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-added scalar single-precision value by vfnmadd231ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmadd132sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd132sd_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-added scalar double-precision value by vfnmadd132sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmadd213sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd213sd_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-added scalar double-precision value by vfnmadd213sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmadd231sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd231sd_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-added scalar double-precision value by vfnmadd231sd",
            },
        }
,

    -- VFNMSUB packed/scalar completion.
    
        {
            node_type = "instruction",
            mnemonic = "vfnmsub132pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub132pd_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed double-precision values by vfnmsub132pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsub213pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub213pd_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed double-precision values by vfnmsub213pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsub231pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub231pd_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed double-precision values by vfnmsub231pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsub132ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub132ss_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted scalar single-precision value by vfnmsub132ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsub213ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub213ss_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted scalar single-precision value by vfnmsub213ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsub231ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub231ss_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted scalar single-precision value by vfnmsub231ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsub132sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub132sd_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted scalar double-precision value by vfnmsub132sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsub213sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub213sd_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted scalar double-precision value by vfnmsub213sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsub231sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub231sd_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted scalar double-precision value by vfnmsub231sd",
            },
        }
,

    -- VFMADDSUB / VFMSUBADD packed double completion.
    
        {
            node_type = "instruction",
            mnemonic = "vfmaddsub132pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddsub132pd_vector_fma",
                target_register = "rip",
                role = "fused multiply add-subtracted packed double-precision values by vfmaddsub132pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmaddsub213pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddsub213pd_vector_fma",
                target_register = "rip",
                role = "fused multiply add-subtracted packed double-precision values by vfmaddsub213pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmaddsub231pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddsub231pd_vector_fma",
                target_register = "rip",
                role = "fused multiply add-subtracted packed double-precision values by vfmaddsub231pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsubadd132pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubadd132pd_vector_fma",
                target_register = "rip",
                role = "fused multiply sub-added packed double-precision values by vfmsubadd132pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsubadd213pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubadd213pd_vector_fma",
                target_register = "rip",
                role = "fused multiply sub-added packed double-precision values by vfmsubadd213pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsubadd231pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubadd231pd_vector_fma",
                target_register = "rip",
                role = "fused multiply sub-added packed double-precision values by vfmsubadd231pd",
            },
        }
,

    -- VBMI / VBMI2 shift-double helpers.
    
        {
            node_type = "instruction",
            mnemonic = "vpshldw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vpshldw_vector_shift_double",
                target_register = "rip",
                role = "performed vector word shift-left-double by vpshldw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshldd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vpshldd_vector_shift_double",
                target_register = "rip",
                role = "performed vector doubleword shift-left-double by vpshldd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshldq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vpshldq_vector_shift_double",
                target_register = "rip",
                role = "performed vector quadword shift-left-double by vpshldq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshrdw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vpshrdw_vector_shift_double",
                target_register = "rip",
                role = "performed vector word shift-right-double by vpshrdw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshrdd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vpshrdd_vector_shift_double",
                target_register = "rip",
                role = "performed vector doubleword shift-right-double by vpshrdd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshrdq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vpshrdq_vector_shift_double",
                target_register = "rip",
                role = "performed vector quadword shift-right-double by vpshrdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshldvw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vpshldvw_vector_variable_shift_double",
                target_register = "rip",
                role = "performed vector variable word shift-left-double by vpshldvw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshldvd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vpshldvd_vector_variable_shift_double",
                target_register = "rip",
                role = "performed vector variable doubleword shift-left-double by vpshldvd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshldvq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vpshldvq_vector_variable_shift_double",
                target_register = "rip",
                role = "performed vector variable quadword shift-left-double by vpshldvq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshrdvw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vpshrdvw_vector_variable_shift_double",
                target_register = "rip",
                role = "performed vector variable word shift-right-double by vpshrdvw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshrdvd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vpshrdvd_vector_variable_shift_double",
                target_register = "rip",
                role = "performed vector variable doubleword shift-right-double by vpshrdvd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshrdvq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vpshrdvq_vector_variable_shift_double",
                target_register = "rip",
                role = "performed vector variable quadword shift-right-double by vpshrdvq",
            },
        }
,

    -- Remaining common vector permute aliases.
    
        {
            node_type = "instruction",
            mnemonic = "vpermi2ps",
            operands = {
                { index = 1, role = "destination_index" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vpermi2ps_vector_permute",
                target_register = "rip",
                role = "performed packed single-precision indexed permute by vpermi2ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermi2pd",
            operands = {
                { index = 1, role = "destination_index" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vpermi2pd_vector_permute",
                target_register = "rip",
                role = "performed packed double-precision indexed permute by vpermi2pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermt2ps",
            operands = {
                { index = 1, role = "destination_index" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vpermt2ps_vector_permute",
                target_register = "rip",
                role = "performed packed single-precision table permute by vpermt2ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermt2pd",
            operands = {
                { index = 1, role = "destination_index" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vpermt2pd_vector_permute",
                target_register = "rip",
                role = "performed packed double-precision table permute by vpermt2pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermilps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "vpermilps_vector_permute",
                target_register = "rip",
                role = "performed packed single-precision lane permute by vpermilps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermilpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "vpermilpd_vector_permute",
                target_register = "rip",
                role = "performed packed double-precision lane permute by vpermilpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "index" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpermps_vector_permute",
                target_register = "rip",
                role = "performed packed single-precision variable permute by vpermps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "vpermpd_vector_permute",
                target_register = "rip",
                role = "performed packed double-precision permute by vpermpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vperm2f128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vperm2f128_vector_permute",
                target_register = "rip",
                role = "performed 128-bit floating lane permute by vperm2f128",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vperm2i128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vperm2i128_vector_permute",
                target_register = "rip",
                role = "performed 128-bit integer lane permute by vperm2i128",
            },
        }
,

    -- Min/max and sqrt/reciprocal helpers.
    
        {
            node_type = "instruction",
            mnemonic = "minss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "minss_scalar_fp_minimum",
                target_register = "rip",
                role = "selected scalar single-precision minimum by minss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "minsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "minsd_scalar_fp_minimum",
                target_register = "rip",
                role = "selected scalar double-precision minimum by minsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "maxss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "maxss_scalar_fp_maximum",
                target_register = "rip",
                role = "selected scalar single-precision maximum by maxss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "maxsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "maxsd_scalar_fp_maximum",
                target_register = "rip",
                role = "selected scalar double-precision maximum by maxsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sqrtss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sqrtss_scalar_fp_sqrt",
                target_register = "rip",
                role = "computed scalar single-precision square root by sqrtss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sqrtsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sqrtsd_scalar_fp_sqrt",
                target_register = "rip",
                role = "computed scalar double-precision square root by sqrtsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sqrtps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sqrtps_packed_fp_sqrt",
                target_register = "rip",
                role = "computed packed single-precision square root by sqrtps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sqrtpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sqrtpd_packed_fp_sqrt",
                target_register = "rip",
                role = "computed packed double-precision square root by sqrtpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rcpss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "rcpss_scalar_fp_reciprocal",
                target_register = "rip",
                role = "computed scalar single-precision reciprocal approximation by rcpss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rcpps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "rcpps_packed_fp_reciprocal",
                target_register = "rip",
                role = "computed packed single-precision reciprocal approximation by rcpps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rsqrtss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "rsqrtss_scalar_fp_rsqrt",
                target_register = "rip",
                role = "computed scalar single-precision reciprocal square-root approximation by rsqrtss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rsqrtps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "rsqrtps_packed_fp_rsqrt",
                target_register = "rip",
                role = "computed packed single-precision reciprocal square-root approximation by rsqrtps",
            },
        }
,

    -- Scalar ordered/unordered comparisons update flags.
    
        {
            node_type = "instruction",
            mnemonic = "comiss",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "comiss_updates_rflags",
                target_register = "rflags",
                role = "updated by ordered scalar single-precision compare comiss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "comisd",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "comisd_updates_rflags",
                target_register = "rflags",
                role = "updated by ordered scalar double-precision compare comisd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ucomiss",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "ucomiss_updates_rflags",
                target_register = "rflags",
                role = "updated by unordered scalar single-precision compare ucomiss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ucomisd",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "ucomisd_updates_rflags",
                target_register = "rflags",
                role = "updated by unordered scalar double-precision compare ucomisd",
            },
        }
,

    -- Rounding.
    
        {
            node_type = "instruction",
            mnemonic = "roundss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "rounding" },
            },
            effect = {
                kind = "register_write",
                name = "roundss_scalar_fp_round",
                target_register = "rip",
                role = "rounded scalar single-precision value by roundss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "roundsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "rounding" },
            },
            effect = {
                kind = "register_write",
                name = "roundsd_scalar_fp_round",
                target_register = "rip",
                role = "rounded scalar double-precision value by roundsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "roundps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "rounding" },
            },
            effect = {
                kind = "register_write",
                name = "roundps_packed_fp_round",
                target_register = "rip",
                role = "rounded packed single-precision values by roundps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "roundpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "rounding" },
            },
            effect = {
                kind = "register_write",
                name = "roundpd_packed_fp_round",
                target_register = "rip",
                role = "rounded packed double-precision values by roundpd",
            },
        }
,

    -- Checkpoint 4.63 — Scalar/SSE conversion leftover sweep.
        -- Phase-one model: XMM/YMM/ZMM writes are exposed through RIP until vector register state is modeled.
        -- GPR destination conversions write the actual destination operand.
    
        {
            node_type = "instruction",
            mnemonic = "cvtsi2ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvtsi2ss_scalar_int_to_single",
                target_register = "rip",
                role = "converted integer to scalar single-precision by cvtsi2ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtsi2sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvtsi2sd_scalar_int_to_double",
                target_register = "rip",
                role = "converted integer to scalar double-precision by cvtsi2sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtsi2ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "merge_source" },
                { index = 3, role = "integer_source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtsi2ss_scalar_int_to_single",
                target_register = "rip",
                role = "converted integer to scalar single-precision by vcvtsi2ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtsi2sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "merge_source" },
                { index = 3, role = "integer_source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtsi2sd_scalar_int_to_double",
                target_register = "rip",
                role = "converted integer to scalar double-precision by vcvtsi2sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtss2si",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvtss2si_writes_destination",
                target_operand = 1,
                role = "written with rounded scalar single-precision to integer conversion by cvtss2si",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtsd2si",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvtsd2si_writes_destination",
                target_operand = 1,
                role = "written with rounded scalar double-precision to integer conversion by cvtsd2si",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvttss2si",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvttss2si_writes_destination",
                target_operand = 1,
                role = "written with truncated scalar single-precision to integer conversion by cvttss2si",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvttsd2si",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvttsd2si_writes_destination",
                target_operand = 1,
                role = "written with truncated scalar double-precision to integer conversion by cvttsd2si",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtss2si",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtss2si_writes_destination",
                target_operand = 1,
                role = "written with rounded scalar single-precision to integer conversion by vcvtss2si",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtsd2si",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtsd2si_writes_destination",
                target_operand = 1,
                role = "written with rounded scalar double-precision to integer conversion by vcvtsd2si",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttss2si",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvttss2si_writes_destination",
                target_operand = 1,
                role = "written with truncated scalar single-precision to integer conversion by vcvttss2si",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttsd2si",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvttsd2si_writes_destination",
                target_operand = 1,
                role = "written with truncated scalar double-precision to integer conversion by vcvttsd2si",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtss2sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvtss2sd_scalar_single_to_double",
                target_register = "rip",
                role = "converted scalar single-precision to scalar double-precision by cvtss2sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtsd2ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvtsd2ss_scalar_double_to_single",
                target_register = "rip",
                role = "converted scalar double-precision to scalar single-precision by cvtsd2ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtss2sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "merge_source" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtss2sd_scalar_single_to_double",
                target_register = "rip",
                role = "converted scalar single-precision to scalar double-precision by vcvtss2sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtsd2ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "merge_source" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtsd2ss_scalar_double_to_single",
                target_register = "rip",
                role = "converted scalar double-precision to scalar single-precision by vcvtsd2ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtps2pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvtps2pd_packed_single_to_double",
                target_register = "rip",
                role = "converted packed single-precision values to double-precision by cvtps2pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtpd2ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvtpd2ps_packed_double_to_single",
                target_register = "rip",
                role = "converted packed double-precision values to single-precision by cvtpd2ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtdq2ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvtdq2ps_packed_int_to_single",
                target_register = "rip",
                role = "converted packed signed doubleword integers to single-precision by cvtdq2ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtdq2pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvtdq2pd_packed_int_to_double",
                target_register = "rip",
                role = "converted packed signed doubleword integers to double-precision by cvtdq2pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtps2dq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvtps2dq_packed_single_to_int",
                target_register = "rip",
                role = "converted packed single-precision values to signed doubleword integers by cvtps2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtpd2dq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvtpd2dq_packed_double_to_int",
                target_register = "rip",
                role = "converted packed double-precision values to signed doubleword integers by cvtpd2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvttps2dq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvttps2dq_packed_single_to_int_truncated",
                target_register = "rip",
                role = "converted packed single-precision values to signed doubleword integers with truncation by cvttps2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvttpd2dq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cvttpd2dq_packed_double_to_int_truncated",
                target_register = "rip",
                role = "converted packed double-precision values to signed doubleword integers with truncation by cvttpd2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "unpcklps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "unpcklps_vector_unpack",
                target_register = "rip",
                role = "unpacked low packed single-precision lanes by unpcklps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "unpckhps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "unpckhps_vector_unpack",
                target_register = "rip",
                role = "unpacked high packed single-precision lanes by unpckhps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "unpcklpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "unpcklpd_vector_unpack",
                target_register = "rip",
                role = "unpacked low packed double-precision lanes by unpcklpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "unpckhpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "unpckhpd_vector_unpack",
                target_register = "rip",
                role = "unpacked high packed double-precision lanes by unpckhpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpcklbw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "punpcklbw_vector_unpack",
                target_register = "rip",
                role = "unpacked low packed bytes by punpcklbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpcklwd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "punpcklwd_vector_unpack",
                target_register = "rip",
                role = "unpacked low packed words by punpcklwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpckldq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "punpckldq_vector_unpack",
                target_register = "rip",
                role = "unpacked low packed doublewords by punpckldq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpcklqdq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "punpcklqdq_vector_unpack",
                target_register = "rip",
                role = "unpacked low packed quadwords by punpcklqdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpckhbw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "punpckhbw_vector_unpack",
                target_register = "rip",
                role = "unpacked high packed bytes by punpckhbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpckhwd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "punpckhwd_vector_unpack",
                target_register = "rip",
                role = "unpacked high packed words by punpckhwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpckhdq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "punpckhdq_vector_unpack",
                target_register = "rip",
                role = "unpacked high packed doublewords by punpckhdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpckhqdq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "punpckhqdq_vector_unpack",
                target_register = "rip",
                role = "unpacked high packed quadwords by punpckhqdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shufps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "shufps_vector_shuffle",
                target_register = "rip",
                role = "shuffled packed single-precision lanes by shufps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shufpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "shufpd_vector_shuffle",
                target_register = "rip",
                role = "shuffled packed double-precision lanes by shufpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pshufb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "pshufb_vector_shuffle",
                target_register = "rip",
                role = "shuffled packed bytes by pshufb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pshufw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "pshufw_vector_shuffle",
                target_register = "rip",
                role = "shuffled packed words by pshufw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pshufd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "pshufd_vector_shuffle",
                target_register = "rip",
                role = "shuffled packed doublewords by pshufd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pshuflw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "pshuflw_vector_shuffle",
                target_register = "rip",
                role = "shuffled low packed words by pshuflw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pshufhw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "pshufhw_vector_shuffle",
                target_register = "rip",
                role = "shuffled high packed words by pshufhw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "palignr",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "palignr_vector_align",
                target_register = "rip",
                role = "aligned packed bytes from concatenated operands by palignr",
            },
        }
,

    -- Checkpoint 4.65 — Packed integer arithmetic / compare / logical leftover sweep.
        -- Phase-one model: vector/MMX/XMM/YMM/ZMM effects are exposed through RIP until vector register state is modeled.
    
        {
            node_type = "instruction",
            mnemonic = "paddb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "paddb_packed_integer_add",
                target_register = "rip",
                role = "performed packed byte integer add by paddb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "paddw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "paddw_packed_integer_add",
                target_register = "rip",
                role = "performed packed word integer add by paddw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "paddd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "paddd_packed_integer_add",
                target_register = "rip",
                role = "performed packed doubleword integer add by paddd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "paddq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "paddq_packed_integer_add",
                target_register = "rip",
                role = "performed packed quadword integer add by paddq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "paddsb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "paddsb_packed_integer_saturating_add",
                target_register = "rip",
                role = "performed signed saturating packed byte add by paddsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "paddsw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "paddsw_packed_integer_saturating_add",
                target_register = "rip",
                role = "performed signed saturating packed word add by paddsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "paddusb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "paddusb_packed_integer_saturating_add",
                target_register = "rip",
                role = "performed unsigned saturating packed byte add by paddusb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "paddusw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "paddusw_packed_integer_saturating_add",
                target_register = "rip",
                role = "performed unsigned saturating packed word add by paddusw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "psubb_packed_integer_subtract",
                target_register = "rip",
                role = "performed packed byte integer subtract by psubb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "psubw_packed_integer_subtract",
                target_register = "rip",
                role = "performed packed word integer subtract by psubw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "psubd_packed_integer_subtract",
                target_register = "rip",
                role = "performed packed doubleword integer subtract by psubd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "psubq_packed_integer_subtract",
                target_register = "rip",
                role = "performed packed quadword integer subtract by psubq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubsb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "psubsb_packed_integer_saturating_subtract",
                target_register = "rip",
                role = "performed signed saturating packed byte subtract by psubsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubsw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "psubsw_packed_integer_saturating_subtract",
                target_register = "rip",
                role = "performed signed saturating packed word subtract by psubsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubusb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "psubusb_packed_integer_saturating_subtract",
                target_register = "rip",
                role = "performed unsigned saturating packed byte subtract by psubusb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubusw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "psubusw_packed_integer_saturating_subtract",
                target_register = "rip",
                role = "performed unsigned saturating packed word subtract by psubusw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmullw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmullw_packed_integer_multiply",
                target_register = "rip",
                role = "performed packed word low multiply by pmullw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmulhw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmulhw_packed_integer_multiply",
                target_register = "rip",
                role = "performed signed packed word high multiply by pmulhw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmulhuw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmulhuw_packed_integer_multiply",
                target_register = "rip",
                role = "performed unsigned packed word high multiply by pmulhuw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmaddwd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmaddwd_packed_integer_multiply_add",
                target_register = "rip",
                role = "performed packed word multiply-add into doublewords by pmaddwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmaddubsw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmaddubsw_packed_integer_multiply_add",
                target_register = "rip",
                role = "performed packed unsigned-byte signed-byte multiply-add with saturation by pmaddubsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pand",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pand_packed_integer_and",
                target_register = "rip",
                role = "performed packed integer bitwise-and by pand",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pandn",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pandn_packed_integer_and_not",
                target_register = "rip",
                role = "performed packed integer bitwise-and-not by pandn",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "por",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "por_packed_integer_or",
                target_register = "rip",
                role = "performed packed integer bitwise-or by por",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pxor",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pxor_packed_integer_xor",
                target_register = "rip",
                role = "performed packed integer bitwise-xor by pxor",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpeqb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpeqb_packed_integer_compare",
                target_register = "rip",
                role = "performed packed byte equality compare by pcmpeqb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpeqw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpeqw_packed_integer_compare",
                target_register = "rip",
                role = "performed packed word equality compare by pcmpeqw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpeqd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpeqd_packed_integer_compare",
                target_register = "rip",
                role = "performed packed doubleword equality compare by pcmpeqd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpeqq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpeqq_packed_integer_compare",
                target_register = "rip",
                role = "performed packed quadword equality compare by pcmpeqq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpgtb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpgtb_packed_integer_compare",
                target_register = "rip",
                role = "performed signed packed byte greater-than compare by pcmpgtb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpgtw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpgtw_packed_integer_compare",
                target_register = "rip",
                role = "performed signed packed word greater-than compare by pcmpgtw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpgtd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpgtd_packed_integer_compare",
                target_register = "rip",
                role = "performed signed packed doubleword greater-than compare by pcmpgtd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpgtq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpgtq_packed_integer_compare",
                target_register = "rip",
                role = "performed signed packed quadword greater-than compare by pcmpgtq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovmskb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmovmskb_writes_destination",
                target_operand = 1,
                role = "written with packed byte sign mask by pmovmskb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcastss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastss_vector_broadcast",
                target_register = "rip",
                role = "broadcast scalar single-precision value by vbroadcastss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcastsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastsd_vector_broadcast",
                target_register = "rip",
                role = "broadcast scalar double-precision value by vbroadcastsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcasti128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcasti128_vector_broadcast",
                target_register = "rip",
                role = "broadcast 128-bit integer value by vbroadcasti128",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vinsertf128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vinsertf128_vector_insert",
                target_register = "rip",
                role = "inserted 128-bit floating lane by vinsertf128",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vinserti128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vinserti128_vector_insert",
                target_register = "rip",
                role = "inserted 128-bit integer lane by vinserti128",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vextractf128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vextractf128_vector_extract",
                target_register = "rip",
                role = "extracted 128-bit floating lane by vextractf128",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vextracti128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vextracti128_vector_extract",
                target_register = "rip",
                role = "extracted 128-bit integer lane by vextracti128",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vzeroall",
            operands = {},
            effect = {
                kind = "register_write",
                name = "vzeroall_clears_vector_state",
                target_register = "rip",
                role = "cleared all vector register state by vzeroall",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vzeroupper",
            operands = {},
            effect = {
                kind = "register_write",
                name = "vzeroupper_clears_upper_vector_state",
                target_register = "rip",
                role = "cleared upper vector register state by vzeroupper",
            },
        }
,
}

