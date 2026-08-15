-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/crypto.lua

-- x86-64 SIMD register effect specs: crypto.

return {
    {
                node_type = "instruction",
                mnemonic = "vpmadd52luq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmadd52luq_vector_ifma",
                    target_register = "rip",
                    role = "multiply-added low unsigned 52-bit integers by vpmadd52luq",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpmadd52huq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmadd52huq_vector_ifma",
                    target_register = "rip",
                    role = "multiply-added high unsigned 52-bit integers by vpmadd52huq",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpopcntb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpopcntb_vector_count",
                    target_register = "rip",
                    role = "counted set bits in packed bytes by vpopcntb",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpopcntw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpopcntw_vector_count",
                    target_register = "rip",
                    role = "counted set bits in packed words by vpopcntw",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpopcntd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpopcntd_vector_count",
                    target_register = "rip",
                    role = "counted set bits in packed doublewords by vpopcntd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpopcntq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpopcntq_vector_count",
                    target_register = "rip",
                    role = "counted set bits in packed quadwords by vpopcntq",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpshufbitqmb",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpshufbitqmb_vector_bit_shuffle",
                    target_register = "rip",
                    role = "shuffled bits from packed quadwords into mask by vpshufbitqmb",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpmultishiftqb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "indices" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmultishiftqb_vector_multishift",
                    target_register = "rip",
                    role = "multi-shifted packed quadword bytes by vpmultishiftqb",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pvalidate",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "pvalidate_updates_rflags",
                    target_register = "rflags",
                    role = "updated by page validation pvalidate",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "psmash",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "psmash_updates_platform_state",
                    target_register = "rip",
                    role = "split secure nested paging mapping by psmash",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrangeps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrangeps_vector_range",
                    target_register = "rip",
                    role = "computed packed single-precision range values by vrangeps",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrangepd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrangepd_vector_range",
                    target_register = "rip",
                    role = "computed packed double-precision range values by vrangepd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrangess",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrangess_scalar_range",
                    target_register = "rip",
                    role = "computed scalar single-precision range value by vrangess",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrangesd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrangesd_scalar_range",
                    target_register = "rip",
                    role = "computed scalar double-precision range value by vrangesd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vreduceps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vreduceps_vector_reduce",
                    target_register = "rip",
                    role = "reduced packed single-precision values by vreduceps",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vreducepd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vreducepd_vector_reduce",
                    target_register = "rip",
                    role = "reduced packed double-precision values by vreducepd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vreducess",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                    { index = 4, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vreducess_scalar_reduce",
                    target_register = "rip",
                    role = "reduced scalar single-precision value by vreducess",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vreducesd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                    { index = 4, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vreducesd_scalar_reduce",
                    target_register = "rip",
                    role = "reduced scalar double-precision value by vreducesd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vgetexpps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vgetexpps_vector_extract_exponent",
                    target_register = "rip",
                    role = "extracted packed single-precision exponents by vgetexpps",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vgetexppd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vgetexppd_vector_extract_exponent",
                    target_register = "rip",
                    role = "extracted packed double-precision exponents by vgetexppd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vgetexpss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vgetexpss_scalar_extract_exponent",
                    target_register = "rip",
                    role = "extracted scalar single-precision exponent by vgetexpss",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vgetexpsd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vgetexpsd_scalar_extract_exponent",
                    target_register = "rip",
                    role = "extracted scalar double-precision exponent by vgetexpsd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vgetmantps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vgetmantps_vector_extract_mantissa",
                    target_register = "rip",
                    role = "extracted packed single-precision mantissas by vgetmantps",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vgetmantpd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vgetmantpd_vector_extract_mantissa",
                    target_register = "rip",
                    role = "extracted packed double-precision mantissas by vgetmantpd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vgetmantss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                    { index = 4, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vgetmantss_scalar_extract_mantissa",
                    target_register = "rip",
                    role = "extracted scalar single-precision mantissa by vgetmantss",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vgetmantsd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                    { index = 4, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vgetmantsd_scalar_extract_mantissa",
                    target_register = "rip",
                    role = "extracted scalar double-precision mantissa by vgetmantsd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vfixupimmps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vfixupimmps_vector_fixup",
                    target_register = "rip",
                    role = "fixed up packed single-precision special values by vfixupimmps",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vfixupimmpd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vfixupimmpd_vector_fixup",
                    target_register = "rip",
                    role = "fixed up packed double-precision special values by vfixupimmpd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vfixupimmss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vfixupimmss_scalar_fixup",
                    target_register = "rip",
                    role = "fixed up scalar single-precision special value by vfixupimmss",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vfixupimmsd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "vfixupimmsd_scalar_fixup",
                    target_register = "rip",
                    role = "fixed up scalar double-precision special value by vfixupimmsd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrcp14ps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrcp14ps_vector_reciprocal",
                    target_register = "rip",
                    role = "computed approximate packed single-precision reciprocals by vrcp14ps",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrcp14pd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrcp14pd_vector_reciprocal",
                    target_register = "rip",
                    role = "computed approximate packed double-precision reciprocals by vrcp14pd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrcp14ss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrcp14ss_scalar_reciprocal",
                    target_register = "rip",
                    role = "computed approximate scalar single-precision reciprocal by vrcp14ss",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrcp14sd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrcp14sd_scalar_reciprocal",
                    target_register = "rip",
                    role = "computed approximate scalar double-precision reciprocal by vrcp14sd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrsqrt14ps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrsqrt14ps_vector_reciprocal_sqrt",
                    target_register = "rip",
                    role = "computed approximate packed single-precision reciprocal square roots by vrsqrt14ps",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrsqrt14pd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrsqrt14pd_vector_reciprocal_sqrt",
                    target_register = "rip",
                    role = "computed approximate packed double-precision reciprocal square roots by vrsqrt14pd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrsqrt14ss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrsqrt14ss_scalar_reciprocal_sqrt",
                    target_register = "rip",
                    role = "computed approximate scalar single-precision reciprocal square root by vrsqrt14ss",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrsqrt14sd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrsqrt14sd_scalar_reciprocal_sqrt",
                    target_register = "rip",
                    role = "computed approximate scalar double-precision reciprocal square root by vrsqrt14sd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrcp28ps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrcp28ps_vector_reciprocal",
                    target_register = "rip",
                    role = "computed high-precision approximate packed single-precision reciprocals by vrcp28ps",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrcp28pd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrcp28pd_vector_reciprocal",
                    target_register = "rip",
                    role = "computed high-precision approximate packed double-precision reciprocals by vrcp28pd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrcp28ss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrcp28ss_scalar_reciprocal",
                    target_register = "rip",
                    role = "computed high-precision approximate scalar single-precision reciprocal by vrcp28ss",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrcp28sd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrcp28sd_scalar_reciprocal",
                    target_register = "rip",
                    role = "computed high-precision approximate scalar double-precision reciprocal by vrcp28sd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrsqrt28ps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrsqrt28ps_vector_reciprocal_sqrt",
                    target_register = "rip",
                    role = "computed high-precision approximate packed single-precision reciprocal square roots by vrsqrt28ps",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrsqrt28pd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrsqrt28pd_vector_reciprocal_sqrt",
                    target_register = "rip",
                    role = "computed high-precision approximate packed double-precision reciprocal square roots by vrsqrt28pd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrsqrt28ss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrsqrt28ss_scalar_reciprocal_sqrt",
                    target_register = "rip",
                    role = "computed high-precision approximate scalar single-precision reciprocal square root by vrsqrt28ss",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vrsqrt28sd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vrsqrt28sd_scalar_reciprocal_sqrt",
                    target_register = "rip",
                    role = "computed high-precision approximate scalar double-precision reciprocal square root by vrsqrt28sd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vexp2ps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vexp2ps_vector_exponential",
                    target_register = "rip",
                    role = "computed approximate packed single-precision powers of two by vexp2ps",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vexp2pd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vexp2pd_vector_exponential",
                    target_register = "rip",
                    role = "computed approximate packed double-precision powers of two by vexp2pd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vscalefps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "scale" },
                },
                effect = {
                    kind = "register_write",
                    name = "vscalefps_vector_scale",
                    target_register = "rip",
                    role = "scaled packed single-precision values by powers of two by vscalefps",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vscalefpd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "scale" },
                },
                effect = {
                    kind = "register_write",
                    name = "vscalefpd_vector_scale",
                    target_register = "rip",
                    role = "scaled packed double-precision values by powers of two by vscalefpd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vscalefss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "scale" },
                },
                effect = {
                    kind = "register_write",
                    name = "vscalefss_scalar_scale",
                    target_register = "rip",
                    role = "scaled scalar single-precision value by power of two by vscalefss",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vscalefsd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "scale" },
                },
                effect = {
                    kind = "register_write",
                    name = "vscalefsd_scalar_scale",
                    target_register = "rip",
                    role = "scaled scalar double-precision value by power of two by vscalefsd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vprold",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "count" },
                },
                effect = {
                    kind = "register_write",
                    name = "vprold_vector_rotate",
                    target_register = "rip",
                    role = "rotated packed doublewords left by vprold",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vprolq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "count" },
                },
                effect = {
                    kind = "register_write",
                    name = "vprolq_vector_rotate",
                    target_register = "rip",
                    role = "rotated packed quadwords left by vprolq",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vprord",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "count" },
                },
                effect = {
                    kind = "register_write",
                    name = "vprord_vector_rotate",
                    target_register = "rip",
                    role = "rotated packed doublewords right by vprord",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vprorq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "count" },
                },
                effect = {
                    kind = "register_write",
                    name = "vprorq_vector_rotate",
                    target_register = "rip",
                    role = "rotated packed quadwords right by vprorq",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vprolvd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "counts" },
                },
                effect = {
                    kind = "register_write",
                    name = "vprolvd_vector_variable_rotate",
                    target_register = "rip",
                    role = "rotated packed doublewords left by variable counts by vprolvd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vprolvq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "counts" },
                },
                effect = {
                    kind = "register_write",
                    name = "vprolvq_vector_variable_rotate",
                    target_register = "rip",
                    role = "rotated packed quadwords left by variable counts by vprolvq",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vprorvd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "counts" },
                },
                effect = {
                    kind = "register_write",
                    name = "vprorvd_vector_variable_rotate",
                    target_register = "rip",
                    role = "rotated packed doublewords right by variable counts by vprorvd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vprorvq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "counts" },
                },
                effect = {
                    kind = "register_write",
                    name = "vprorvq_vector_variable_rotate",
                    target_register = "rip",
                    role = "rotated packed quadwords right by variable counts by vprorvq",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpsllvw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "counts" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpsllvw_vector_variable_shift",
                    target_register = "rip",
                    role = "shifted packed words left by variable counts by vpsllvw",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpsllvd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "counts" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpsllvd_vector_variable_shift",
                    target_register = "rip",
                    role = "shifted packed doublewords left by variable counts by vpsllvd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpsllvq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "counts" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpsllvq_vector_variable_shift",
                    target_register = "rip",
                    role = "shifted packed quadwords left by variable counts by vpsllvq",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpsrlvw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "counts" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpsrlvw_vector_variable_shift",
                    target_register = "rip",
                    role = "logically shifted packed words right by variable counts by vpsrlvw",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpsrlvd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "counts" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpsrlvd_vector_variable_shift",
                    target_register = "rip",
                    role = "logically shifted packed doublewords right by variable counts by vpsrlvd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpsrlvq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "counts" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpsrlvq_vector_variable_shift",
                    target_register = "rip",
                    role = "logically shifted packed quadwords right by variable counts by vpsrlvq",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpsravw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "counts" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpsravw_vector_variable_shift",
                    target_register = "rip",
                    role = "arithmetically shifted packed words right by variable counts by vpsravw",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpsravd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "counts" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpsravd_vector_variable_shift",
                    target_register = "rip",
                    role = "arithmetically shifted packed doublewords right by variable counts by vpsravd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vpsravq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "counts" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpsravq_vector_variable_shift",
                    target_register = "rip",
                    role = "arithmetically shifted packed quadwords right by variable counts by vpsravq",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "v4fmaddps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source_group" },
                    { index = 3, role = "memory" },
                },
                effect = {
                    kind = "register_write",
                    name = "v4fmaddps_vector_accelerator",
                    target_register = "rip",
                    role = "performed four packed single-precision fused multiply-adds by v4fmaddps",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "v4fnmaddps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source_group" },
                    { index = 3, role = "memory" },
                },
                effect = {
                    kind = "register_write",
                    name = "v4fnmaddps_vector_accelerator",
                    target_register = "rip",
                    role = "performed four negative packed single-precision fused multiply-adds by v4fnmaddps",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vp4dpwssd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source_group" },
                    { index = 3, role = "memory" },
                },
                effect = {
                    kind = "register_write",
                    name = "vp4dpwssd_vector_accelerator",
                    target_register = "rip",
                    role = "performed four signed word dot-products into doublewords by vp4dpwssd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vp4dpwssds",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source_group" },
                    { index = 3, role = "memory" },
                },
                effect = {
                    kind = "register_write",
                    name = "vp4dpwssds_vector_accelerator",
                    target_register = "rip",
                    role = "performed four saturating signed word dot-products into doublewords by vp4dpwssds",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pblendw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "pblendw_vector_blend",
                    target_register = "rip",
                    role = "blended packed words by pblendw",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pblendvb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "pblendvb_vector_blend",
                    target_register = "rip",
                    role = "variable-blended packed bytes by pblendvb",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pinsrb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "pinsrb_vector_insert",
                    target_register = "rip",
                    role = "inserted byte into packed integer vector by pinsrb",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pinsrd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "pinsrd_vector_insert",
                    target_register = "rip",
                    role = "inserted doubleword into packed integer vector by pinsrd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pinsrq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "pinsrq_vector_insert",
                    target_register = "rip",
                    role = "inserted quadword into packed integer vector by pinsrq",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pminsb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "pminsb_vector_minmax",
                    target_register = "rip",
                    role = "selected packed signed byte minimums by pminsb",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pminsd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "pminsd_vector_minmax",
                    target_register = "rip",
                    role = "selected packed signed doubleword minimums by pminsd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pminuw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "pminuw_vector_minmax",
                    target_register = "rip",
                    role = "selected packed unsigned word minimums by pminuw",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pminud",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "pminud_vector_minmax",
                    target_register = "rip",
                    role = "selected packed unsigned doubleword minimums by pminud",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pmaxsb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "pmaxsb_vector_minmax",
                    target_register = "rip",
                    role = "selected packed signed byte maximums by pmaxsb",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pmaxsd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "pmaxsd_vector_minmax",
                    target_register = "rip",
                    role = "selected packed signed doubleword maximums by pmaxsd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pmaxuw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "pmaxuw_vector_minmax",
                    target_register = "rip",
                    role = "selected packed unsigned word maximums by pmaxuw",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pmaxud",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "pmaxud_vector_minmax",
                    target_register = "rip",
                    role = "selected packed unsigned doubleword maximums by pmaxud",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pmuldq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "pmuldq_vector_multiply",
                    target_register = "rip",
                    role = "multiplied packed signed doublewords to quadwords by pmuldq",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "pmulld",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "pmulld_vector_multiply",
                    target_register = "rip",
                    role = "multiplied packed signed doublewords low by pmulld",
                },
            }
,

}
