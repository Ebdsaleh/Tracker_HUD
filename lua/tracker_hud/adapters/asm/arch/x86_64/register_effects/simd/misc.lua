-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/misc.lua

-- x86-64 SIMD register effect specs: misc.

return {

    {
            node_type = "instruction",
            mnemonic = "verr",
            operands = {
                { index = 1, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "verr_updates_rflags",
                target_register = "rflags",
                role = "updated by readable-segment test verr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "verw",
            operands = {
                { index = 1, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "verw_updates_rflags",
                target_register = "rflags",
                role = "updated by writable-segment test verw",
            },
        }
,

    -- Prefetch hints.
        {
            node_type = "instruction",
            mnemonic = "prefetch",
            operands = {
                { index = 1, role = "memory_operand" },
            },
            effect = {
                kind = "register_write",
                name = "prefetch_touches_memory",
                target_register = "rip",
                role = "prefetched memory by prefetch",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "prefetchw",
            operands = {
                { index = 1, role = "memory_operand" },
            },
            effect = {
                kind = "register_write",
                name = "prefetchw_touches_memory",
                target_register = "rip",
                role = "prefetched memory for write by prefetchw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fstcw",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fstcw_stores_control_word",
                target_register = "rip",
                role = "stored x87 control word by fstcw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fnstcw",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fnstcw_stores_control_word",
                target_register = "rip",
                role = "stored x87 control word by fnstcw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fldcw",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fldcw_loads_control_word",
                target_register = "rip",
                role = "loaded x87 control word by fldcw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fsave",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fsave_stores_fpu_state",
                target_register = "rip",
                role = "saved x87 fpu state by fsave",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fnsave",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fnsave_stores_fpu_state",
                target_register = "rip",
                role = "saved x87 fpu state by fnsave",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "frstor",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "frstor_restores_fpu_state",
                target_register = "rip",
                role = "restored x87 fpu state by frstor",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fstenv",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fstenv_stores_fpu_environment",
                target_register = "rip",
                role = "stored x87 environment by fstenv",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fnstenv",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fnstenv_stores_fpu_environment",
                target_register = "rip",
                role = "stored x87 environment by fnstenv",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fldenv",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fldenv_loads_fpu_environment",
                target_register = "rip",
                role = "loaded x87 environment by fldenv",
            },
        }
,

    -- x87 stack/math visibility. No x87 register model yet, so expose as RIP-side FPU activity.
        {
            node_type = "instruction",
            mnemonic = "fld",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fld_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 value by fld",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fst",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fst_updates_fpu_stack",
                target_register = "rip",
                role = "stored x87 value by fst",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fstp",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fstp_updates_fpu_stack",
                target_register = "rip",
                role = "stored and popped x87 value by fstp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fild",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fild_updates_fpu_stack",
                target_register = "rip",
                role = "loaded integer into x87 stack by fild",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fist",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fist_updates_fpu_stack",
                target_register = "rip",
                role = "stored integer from x87 stack by fist",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fistp",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fistp_updates_fpu_stack",
                target_register = "rip",
                role = "stored integer and popped x87 stack by fistp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fisttp",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fisttp_updates_fpu_stack",
                target_register = "rip",
                role = "stored truncated integer and popped x87 stack by fisttp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fbld",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fbld_updates_fpu_stack",
                target_register = "rip",
                role = "loaded bcd value into x87 stack by fbld",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fbstp",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fbstp_updates_fpu_stack",
                target_register = "rip",
                role = "stored bcd value and popped x87 stack by fbstp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fadd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fadd_updates_fpu_stack",
                target_register = "rip",
                role = "updated x87 stack by fadd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "faddp",
            operands = {},
            effect = {
                kind = "register_write",
                name = "faddp_updates_fpu_stack",
                target_register = "rip",
                role = "updated and popped x87 stack by faddp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fiadd",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fiadd_updates_fpu_stack",
                target_register = "rip",
                role = "added integer to x87 stack by fiadd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fsub",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fsub_updates_fpu_stack",
                target_register = "rip",
                role = "updated x87 stack by fsub",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fsubp",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fsubp_updates_fpu_stack",
                target_register = "rip",
                role = "updated and popped x87 stack by fsubp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fisub",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fisub_updates_fpu_stack",
                target_register = "rip",
                role = "subtracted integer from x87 stack by fisub",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fisubr",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fisubr_updates_fpu_stack",
                target_register = "rip",
                role = "reverse-subtracted integer with x87 stack by fisubr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fmul",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fmul_updates_fpu_stack",
                target_register = "rip",
                role = "updated x87 stack by fmul",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fmulp",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fmulp_updates_fpu_stack",
                target_register = "rip",
                role = "updated and popped x87 stack by fmulp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fimul",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fimul_updates_fpu_stack",
                target_register = "rip",
                role = "multiplied integer with x87 stack by fimul",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fdiv",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fdiv_updates_fpu_stack",
                target_register = "rip",
                role = "updated x87 stack by fdiv",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fdivp",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fdivp_updates_fpu_stack",
                target_register = "rip",
                role = "updated and popped x87 stack by fdivp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fidiv",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fidiv_updates_fpu_stack",
                target_register = "rip",
                role = "divided x87 stack by integer with fidiv",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fidivr",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fidivr_updates_fpu_stack",
                target_register = "rip",
                role = "reverse-divided integer with x87 stack by fidivr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fcom",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fcom_updates_fpu_status",
                target_register = "rip",
                role = "compared x87 values by fcom",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fcomp",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fcomp_updates_fpu_status",
                target_register = "rip",
                role = "compared and popped x87 value by fcomp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fcompp",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fcompp_updates_fpu_status",
                target_register = "rip",
                role = "compared and popped two x87 values by fcompp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fucom",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fucom_updates_fpu_status",
                target_register = "rip",
                role = "unordered-compared x87 values by fucom",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fucomp",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fucomp_updates_fpu_status",
                target_register = "rip",
                role = "unordered-compared and popped x87 value by fucomp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fucompp",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fucompp_updates_fpu_status",
                target_register = "rip",
                role = "unordered-compared and popped two x87 values by fucompp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fcomi",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fcomi_updates_rflags",
                target_register = "rflags",
                role = "updated by x87 compare fcomi",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fcomip",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fcomip_updates_rflags",
                target_register = "rflags",
                role = "updated by x87 compare-and-pop fcomip",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fucomi",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fucomi_updates_rflags",
                target_register = "rflags",
                role = "updated by unordered x87 compare fucomi",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fucomip",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fucomip_updates_rflags",
                target_register = "rflags",
                role = "updated by unordered x87 compare-and-pop fucomip",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ftst",
            operands = {},
            effect = {
                kind = "register_write",
                name = "ftst_updates_fpu_status",
                target_register = "rip",
                role = "tested x87 value against zero by ftst",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fxam",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fxam_updates_fpu_status",
                target_register = "rip",
                role = "examined x87 value by fxam",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fxch",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fxch_updates_fpu_stack",
                target_register = "rip",
                role = "exchanged x87 stack registers by fxch",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fabs",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fabs_updates_fpu_stack",
                target_register = "rip",
                role = "absolute-valued x87 top by fabs",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fchs",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fchs_updates_fpu_stack",
                target_register = "rip",
                role = "changed sign of x87 top by fchs",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "frndint",
            operands = {},
            effect = {
                kind = "register_write",
                name = "frndint_updates_fpu_stack",
                target_register = "rip",
                role = "rounded x87 top to integer by frndint",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fsqrt",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fsqrt_updates_fpu_stack",
                target_register = "rip",
                role = "square-rooted x87 top by fsqrt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fscale",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fscale_updates_fpu_stack",
                target_register = "rip",
                role = "scaled x87 value by fscale",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fprem",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fprem_updates_fpu_stack",
                target_register = "rip",
                role = "computed x87 partial remainder by fprem",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fprem1",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fprem1_updates_fpu_stack",
                target_register = "rip",
                role = "computed ieee x87 partial remainder by fprem1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fyl2x",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fyl2x_updates_fpu_stack",
                target_register = "rip",
                role = "computed y times log2 x by fyl2x",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fyl2xp1",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fyl2xp1_updates_fpu_stack",
                target_register = "rip",
                role = "computed y times log2 x-plus-one by fyl2xp1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "f2xm1",
            operands = {},
            effect = {
                kind = "register_write",
                name = "f2xm1_updates_fpu_stack",
                target_register = "rip",
                role = "computed two-power-x-minus-one by f2xm1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fsin",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fsin_updates_fpu_stack",
                target_register = "rip",
                role = "computed sine by fsin",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fcos",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fcos_updates_fpu_stack",
                target_register = "rip",
                role = "computed cosine by fcos",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fsincos",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fsincos_updates_fpu_stack",
                target_register = "rip",
                role = "computed sine and cosine by fsincos",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fptan",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fptan_updates_fpu_stack",
                target_register = "rip",
                role = "computed partial tangent by fptan",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fpatan",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fpatan_updates_fpu_stack",
                target_register = "rip",
                role = "computed partial arctangent by fpatan",
            },
        }
,

    -- x87 constants.
        {
            node_type = "instruction",
            mnemonic = "fld1",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fld1_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 constant one by fld1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fldz",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fldz_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 constant zero by fldz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fldpi",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fldpi_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 constant pi by fldpi",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fldl2e",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fldl2e_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 constant log2 e by fldl2e",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fldl2t",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fldl2t_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 constant log2 ten by fldl2t",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fldlg2",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fldlg2_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 constant log10 two by fldlg2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fldln2",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fldln2_updates_fpu_stack",
                target_register = "rip",
                role = "loaded x87 constant ln two by fldln2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sqrtps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "sqrtps_simd_arithmetic",
                target_register = "rip",
                role = "square-rooted packed single-precision values by sqrtps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sqrtpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "sqrtpd_simd_arithmetic",
                target_register = "rip",
                role = "square-rooted packed double-precision values by sqrtpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sqrtss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "sqrtss_scalar_simd_arithmetic",
                target_register = "rip",
                role = "square-rooted scalar single-precision value by sqrtss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sqrtsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "sqrtsd_scalar_simd_arithmetic",
                target_register = "rip",
                role = "square-rooted scalar double-precision value by sqrtsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "maxps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "maxps_simd_compare_select",
                target_register = "rip",
                role = "selected packed single-precision maximum values by maxps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "maxpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "maxpd_simd_compare_select",
                target_register = "rip",
                role = "selected packed double-precision maximum values by maxpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "maxss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "maxss_scalar_simd_compare_select",
                target_register = "rip",
                role = "selected scalar single-precision maximum value by maxss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "maxsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "maxsd_scalar_simd_compare_select",
                target_register = "rip",
                role = "selected scalar double-precision maximum value by maxsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "minps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "minps_simd_compare_select",
                target_register = "rip",
                role = "selected packed single-precision minimum values by minps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "minpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "minpd_simd_compare_select",
                target_register = "rip",
                role = "selected packed double-precision minimum values by minpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "minss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "minss_scalar_simd_compare_select",
                target_register = "rip",
                role = "selected scalar single-precision minimum value by minss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "minsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "minsd_scalar_simd_compare_select",
                target_register = "rip",
                role = "selected scalar double-precision minimum value by minsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "comiss",
            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
            effect = {
                kind = "register_write",
                name = "comiss_updates_rflags",
                target_register = "rflags",
                role = "updated by scalar single-precision compare comiss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ucomiss",
            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
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
            mnemonic = "comisd",
            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
            effect = {
                kind = "register_write",
                name = "comisd_updates_rflags",
                target_register = "rflags",
                role = "updated by scalar double-precision compare comisd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ucomisd",
            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
            effect = {
                kind = "register_write",
                name = "ucomisd_updates_rflags",
                target_register = "rflags",
                role = "updated by unordered scalar double-precision compare ucomisd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shufps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "shufps_simd_shuffle",
                target_register = "rip",
                role = "shuffled packed single-precision values by shufps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shufpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "shufpd_simd_shuffle",
                target_register = "rip",
                role = "shuffled packed double-precision values by shufpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "unpckhps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "unpckhps_simd_unpack",
                target_register = "rip",
                role = "unpacked high packed single-precision values by unpckhps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "unpcklps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "unpcklps_simd_unpack",
                target_register = "rip",
                role = "unpacked low packed single-precision values by unpcklps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "unpckhpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "unpckhpd_simd_unpack",
                target_register = "rip",
                role = "unpacked high packed double-precision values by unpckhpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "unpcklpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "unpcklpd_simd_unpack",
                target_register = "rip",
                role = "unpacked low packed double-precision values by unpcklpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtss2sd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvtss2sd_simd_convert",
                target_register = "rip",
                role = "converted scalar single to scalar double by cvtss2sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtsd2ss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvtsd2ss_simd_convert",
                target_register = "rip",
                role = "converted scalar double to scalar single by cvtsd2ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvttps2dq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvttps2dq_simd_convert",
                target_register = "rip",
                role = "converted packed single to integers with truncation by cvttps2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtps2dq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvtps2dq_simd_convert",
                target_register = "rip",
                role = "converted packed single to integers by cvtps2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtdq2ps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvtdq2ps_simd_convert",
                target_register = "rip",
                role = "converted packed integers to single-precision by cvtdq2ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtpd2ps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvtpd2ps_simd_convert",
                target_register = "rip",
                role = "converted packed double to packed single by cvtpd2ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtps2pd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvtps2pd_simd_convert",
                target_register = "rip",
                role = "converted packed single to packed double by cvtps2pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvttpd2dq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvttpd2dq_simd_convert",
                target_register = "rip",
                role = "converted packed double to integers with truncation by cvttpd2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtpd2dq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvtpd2dq_simd_convert",
                target_register = "rip",
                role = "converted packed double to integers by cvtpd2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtdq2pd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvtdq2pd_simd_convert",
                target_register = "rip",
                role = "converted packed integers to double-precision by cvtdq2pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtsi2ss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvtsi2ss_simd_convert",
                target_register = "rip",
                role = "converted integer to scalar single by cvtsi2ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtsi2sd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvtsi2sd_simd_convert",
                target_register = "rip",
                role = "converted integer to scalar double by cvtsi2sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtss2si",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvtss2si_writes_gpr",
                target_operand = 1,
                role = "written with converted scalar single integer by cvtss2si",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvtsd2si",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvtsd2si_writes_gpr",
                target_operand = 1,
                role = "written with converted scalar double integer by cvtsd2si",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvttss2si",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvttss2si_writes_gpr",
                target_operand = 1,
                role = "written with truncated scalar single integer by cvttss2si",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cvttsd2si",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "cvttsd2si_writes_gpr",
                target_operand = 1,
                role = "written with truncated scalar double integer by cvttsd2si",
            },
        }
,

}

