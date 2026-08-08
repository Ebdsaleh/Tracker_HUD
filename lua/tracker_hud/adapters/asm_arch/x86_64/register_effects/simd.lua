-- lua/tracker_hud/adapters/asm_arch/x86_64/register_effects/simd.lua
--
-- x86-64 simd register effect specs.

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

    -- Packed integer SIMD/MMX/SSE visibility effects.
        -- Phase-one model: no SIMD/MMX register file yet, so most vector effects are exposed as RIP-side activity.
    
        {
            node_type = "instruction",
            mnemonic = "paddb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddb_simd_integer_add",
                target_register = "rip",
                role = "added packed byte integers by paddb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "paddw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddw_simd_integer_add",
                target_register = "rip",
                role = "added packed word integers by paddw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "paddd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddd_simd_integer_add",
                target_register = "rip",
                role = "added packed doubleword integers by paddd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "paddq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddq_simd_integer_add",
                target_register = "rip",
                role = "added packed quadword integers by paddq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "paddsb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddsb_simd_integer_add",
                target_register = "rip",
                role = "saturating-added packed signed bytes by paddsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "paddsw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddsw_simd_integer_add",
                target_register = "rip",
                role = "saturating-added packed signed words by paddsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "paddusb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddusb_simd_integer_add",
                target_register = "rip",
                role = "saturating-added packed unsigned bytes by paddusb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "paddusw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddusw_simd_integer_add",
                target_register = "rip",
                role = "saturating-added packed unsigned words by paddusw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubb_simd_integer_subtract",
                target_register = "rip",
                role = "subtracted packed byte integers by psubb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubw_simd_integer_subtract",
                target_register = "rip",
                role = "subtracted packed word integers by psubw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubd_simd_integer_subtract",
                target_register = "rip",
                role = "subtracted packed doubleword integers by psubd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubq_simd_integer_subtract",
                target_register = "rip",
                role = "subtracted packed quadword integers by psubq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubsb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubsb_simd_integer_subtract",
                target_register = "rip",
                role = "saturating-subtracted packed signed bytes by psubsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubsw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubsw_simd_integer_subtract",
                target_register = "rip",
                role = "saturating-subtracted packed signed words by psubsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubusb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubusb_simd_integer_subtract",
                target_register = "rip",
                role = "saturating-subtracted packed unsigned bytes by psubusb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psubusw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubusw_simd_integer_subtract",
                target_register = "rip",
                role = "saturating-subtracted packed unsigned words by psubusw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmullw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmullw_simd_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed words low by pmullw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmulhw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmulhw_simd_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed words high by pmulhw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmulhuw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmulhuw_simd_integer_multiply",
                target_register = "rip",
                role = "multiplied packed unsigned words high by pmulhuw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmulld",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmulld_simd_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed doublewords low by pmulld",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmuldq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmuldq_simd_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed doublewords to quadwords by pmuldq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmuludq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmuludq_simd_integer_multiply",
                target_register = "rip",
                role = "multiplied packed unsigned doublewords to quadwords by pmuludq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmaddwd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaddwd_simd_integer_multiply_add",
                target_register = "rip",
                role = "multiply-added packed words to doublewords by pmaddwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmaddubsw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaddubsw_simd_integer_multiply_add",
                target_register = "rip",
                role = "multiply-added packed unsigned bytes and signed bytes by pmaddubsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pavgb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pavgb_simd_integer_average",
                target_register = "rip",
                role = "averaged packed unsigned bytes by pavgb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pavgw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pavgw_simd_integer_average",
                target_register = "rip",
                role = "averaged packed unsigned words by pavgw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pabsb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pabsb_simd_integer_absolute",
                target_register = "rip",
                role = "absolute-valued packed signed bytes by pabsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pabsw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pabsw_simd_integer_absolute",
                target_register = "rip",
                role = "absolute-valued packed signed words by pabsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pabsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pabsd_simd_integer_absolute",
                target_register = "rip",
                role = "absolute-valued packed signed doublewords by pabsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psignb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psignb_simd_integer_sign",
                target_register = "rip",
                role = "applied packed byte signs by psignb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psignw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psignw_simd_integer_sign",
                target_register = "rip",
                role = "applied packed word signs by psignw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psignd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psignd_simd_integer_sign",
                target_register = "rip",
                role = "applied packed doubleword signs by psignd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pand",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pand_simd_integer_logic",
                target_register = "rip",
                role = "bitwise-and packed integer lanes by pand",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pandn",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pandn_simd_integer_logic",
                target_register = "rip",
                role = "bitwise-and-not packed integer lanes by pandn",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "por",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "por_simd_integer_logic",
                target_register = "rip",
                role = "bitwise-or packed integer lanes by por",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pxor",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pxor_simd_integer_logic",
                target_register = "rip",
                role = "bitwise-xor packed integer lanes by pxor",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpeqb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pcmpeqb_simd_integer_compare",
                target_register = "rip",
                role = "compared packed bytes for equality by pcmpeqb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpeqw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pcmpeqw_simd_integer_compare",
                target_register = "rip",
                role = "compared packed words for equality by pcmpeqw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpeqd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pcmpeqd_simd_integer_compare",
                target_register = "rip",
                role = "compared packed doublewords for equality by pcmpeqd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpeqq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pcmpeqq_simd_integer_compare",
                target_register = "rip",
                role = "compared packed quadwords for equality by pcmpeqq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpgtb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pcmpgtb_simd_integer_compare",
                target_register = "rip",
                role = "compared packed signed bytes greater-than by pcmpgtb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpgtw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pcmpgtw_simd_integer_compare",
                target_register = "rip",
                role = "compared packed signed words greater-than by pcmpgtw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpgtd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pcmpgtd_simd_integer_compare",
                target_register = "rip",
                role = "compared packed signed doublewords greater-than by pcmpgtd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpgtq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pcmpgtq_simd_integer_compare",
                target_register = "rip",
                role = "compared packed signed quadwords greater-than by pcmpgtq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pminub",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pminub_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned byte minimums by pminub",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pminuw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pminuw_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned word minimums by pminuw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pminud",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pminud_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned doubleword minimums by pminud",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pminsb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pminsb_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed signed byte minimums by pminsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pminsw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pminsw_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed signed word minimums by pminsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pminsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pminsd_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed signed doubleword minimums by pminsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmaxub",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaxub_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned byte maximums by pmaxub",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmaxuw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaxuw_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned word maximums by pmaxuw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmaxud",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaxud_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned doubleword maximums by pmaxud",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmaxsb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaxsb_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed signed byte maximums by pmaxsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmaxsw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaxsw_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed signed word maximums by pmaxsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmaxsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaxsd_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed signed doubleword maximums by pmaxsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psllw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psllw_simd_integer_shift",
                target_register = "rip",
                role = "shifted packed words left by psllw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pslld",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "pslld_simd_integer_shift",
                target_register = "rip",
                role = "shifted packed doublewords left by pslld",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psllq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psllq_simd_integer_shift",
                target_register = "rip",
                role = "shifted packed quadwords left by psllq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psrlw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psrlw_simd_integer_shift",
                target_register = "rip",
                role = "logically shifted packed words right by psrlw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psrld",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psrld_simd_integer_shift",
                target_register = "rip",
                role = "logically shifted packed doublewords right by psrld",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psrlq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psrlq_simd_integer_shift",
                target_register = "rip",
                role = "logically shifted packed quadwords right by psrlq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psraw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psraw_simd_integer_shift",
                target_register = "rip",
                role = "arithmetically shifted packed words right by psraw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psrad",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psrad_simd_integer_shift",
                target_register = "rip",
                role = "arithmetically shifted packed doublewords right by psrad",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pslldq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "pslldq_simd_integer_shift",
                target_register = "rip",
                role = "shifted packed double-quadword left by pslldq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psrldq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psrldq_simd_integer_shift",
                target_register = "rip",
                role = "shifted packed double-quadword right by psrldq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "packsswb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "packsswb_simd_integer_pack",
                target_register = "rip",
                role = "packed signed words to signed bytes by packsswb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "packssdw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "packssdw_simd_integer_pack",
                target_register = "rip",
                role = "packed signed doublewords to signed words by packssdw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "packuswb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "packuswb_simd_integer_pack",
                target_register = "rip",
                role = "packed signed words to unsigned bytes by packuswb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "packusdw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "packusdw_simd_integer_pack",
                target_register = "rip",
                role = "packed signed doublewords to unsigned words by packusdw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpcklbw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpcklbw_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked low packed bytes by punpcklbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpcklwd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpcklwd_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked low packed words by punpcklwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpckldq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpckldq_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked low packed doublewords by punpckldq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpcklqdq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpcklqdq_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked low packed quadwords by punpcklqdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpckhbw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpckhbw_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked high packed bytes by punpckhbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpckhwd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpckhwd_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked high packed words by punpckhwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpckhdq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpckhdq_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked high packed doublewords by punpckhdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "punpckhqdq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpckhqdq_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked high packed quadwords by punpckhqdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pshufd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "pshufd_simd_integer_shuffle",
                target_register = "rip",
                role = "shuffled packed doublewords by pshufd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pshufhw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "pshufhw_simd_integer_shuffle",
                target_register = "rip",
                role = "shuffled high packed words by pshufhw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pshuflw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "pshuflw_simd_integer_shuffle",
                target_register = "rip",
                role = "shuffled low packed words by pshuflw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pshufb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pshufb_simd_integer_shuffle",
                target_register = "rip",
                role = "byte-shuffled packed integer lanes by pshufb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "palignr",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "palignr_simd_integer_align",
                target_register = "rip",
                role = "aligned packed bytes by palignr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "psadbw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psadbw_simd_integer_sad",
                target_register = "rip",
                role = "computed packed byte sum of absolute differences by psadbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "phaddw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "phaddw_simd_integer_horizontal",
                target_register = "rip",
                role = "horizontally added packed words by phaddw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "phaddd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "phaddd_simd_integer_horizontal",
                target_register = "rip",
                role = "horizontally added packed doublewords by phaddd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "phaddsw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "phaddsw_simd_integer_horizontal",
                target_register = "rip",
                role = "horizontally saturating-added packed signed words by phaddsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "phsubw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "phsubw_simd_integer_horizontal",
                target_register = "rip",
                role = "horizontally subtracted packed words by phsubw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "phsubd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "phsubd_simd_integer_horizontal",
                target_register = "rip",
                role = "horizontally subtracted packed doublewords by phsubd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "phsubsw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "phsubsw_simd_integer_horizontal",
                target_register = "rip",
                role = "horizontally saturating-subtracted packed signed words by phsubsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovmskb",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmovmskb_writes_gpr",
                target_operand = 1,
                role = "written with packed byte sign mask by pmovmskb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pinsrb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "pinsrb_simd_insert",
                target_register = "rip",
                role = "inserted byte into packed integer vector by pinsrb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pinsrw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "pinsrw_simd_insert",
                target_register = "rip",
                role = "inserted word into packed integer vector by pinsrw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pinsrd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "pinsrd_simd_insert",
                target_register = "rip",
                role = "inserted doubleword into packed integer vector by pinsrd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pinsrq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "pinsrq_simd_insert",
                target_register = "rip",
                role = "inserted quadword into packed integer vector by pinsrq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovsxbd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmovsxbd_simd_extend",
                target_register = "rip",
                role = "sign-extended packed bytes to doublewords by pmovsxbd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovsxbq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmovsxbq_simd_extend",
                target_register = "rip",
                role = "sign-extended packed bytes to quadwords by pmovsxbq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovsxbw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmovsxbw_simd_extend",
                target_register = "rip",
                role = "sign-extended packed bytes to words by pmovsxbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovsxdq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmovsxdq_simd_extend",
                target_register = "rip",
                role = "sign-extended packed doublewords to quadwords by pmovsxdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovsxwd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmovsxwd_simd_extend",
                target_register = "rip",
                role = "sign-extended packed words to doublewords by pmovsxwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovsxwq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmovsxwq_simd_extend",
                target_register = "rip",
                role = "sign-extended packed words to quadwords by pmovsxwq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovzxbd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmovzxbd_simd_extend",
                target_register = "rip",
                role = "zero-extended packed bytes to doublewords by pmovzxbd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovzxbq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmovzxbq_simd_extend",
                target_register = "rip",
                role = "zero-extended packed bytes to quadwords by pmovzxbq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovzxbw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmovzxbw_simd_extend",
                target_register = "rip",
                role = "zero-extended packed bytes to words by pmovzxbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovzxdq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmovzxdq_simd_extend",
                target_register = "rip",
                role = "zero-extended packed doublewords to quadwords by pmovzxdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovzxwd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmovzxwd_simd_extend",
                target_register = "rip",
                role = "zero-extended packed words to doublewords by pmovzxwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovzxwq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmovzxwq_simd_extend",
                target_register = "rip",
                role = "zero-extended packed words to quadwords by pmovzxwq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ptest",
            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
            effect = {
                kind = "register_write",
                name = "ptest_updates_rflags",
                target_register = "rflags",
                role = "updated by packed integer test ptest",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ptest",
            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
            effect = {
                kind = "register_write",
                name = "ptest_simd_integer_test",
                target_register = "rip",
                role = "tested packed integer lanes by ptest",
            },
        }
,

    -- AVX packed/scalar floating arithmetic.
        {
            node_type = "instruction",
            mnemonic = "vaddps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vaddps_vector_arithmetic",
                target_register = "rip",
                role = "added packed single-precision values by vaddps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vaddpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vaddpd_vector_arithmetic",
                target_register = "rip",
                role = "added packed double-precision values by vaddpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vaddss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vaddss_scalar_vector_arithmetic",
                target_register = "rip",
                role = "added scalar single-precision values by vaddss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vaddsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vaddsd_scalar_vector_arithmetic",
                target_register = "rip",
                role = "added scalar double-precision values by vaddsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsubps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vsubps_vector_arithmetic",
                target_register = "rip",
                role = "subtracted packed single-precision values by vsubps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsubpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vsubpd_vector_arithmetic",
                target_register = "rip",
                role = "subtracted packed double-precision values by vsubpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsubss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vsubss_scalar_vector_arithmetic",
                target_register = "rip",
                role = "subtracted scalar single-precision values by vsubss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsubsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vsubsd_scalar_vector_arithmetic",
                target_register = "rip",
                role = "subtracted scalar double-precision values by vsubsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vdivps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vdivps_vector_arithmetic",
                target_register = "rip",
                role = "divided packed single-precision values by vdivps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vdivpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vdivpd_vector_arithmetic",
                target_register = "rip",
                role = "divided packed double-precision values by vdivpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vdivss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vdivss_scalar_vector_arithmetic",
                target_register = "rip",
                role = "divided scalar single-precision values by vdivss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vdivsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vdivsd_scalar_vector_arithmetic",
                target_register = "rip",
                role = "divided scalar double-precision values by vdivsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsqrtps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vsqrtps_vector_arithmetic",
                target_register = "rip",
                role = "square-rooted packed single-precision values by vsqrtps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsqrtpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vsqrtpd_vector_arithmetic",
                target_register = "rip",
                role = "square-rooted packed double-precision values by vsqrtpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsqrtss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vsqrtss_scalar_vector_arithmetic",
                target_register = "rip",
                role = "square-rooted scalar single-precision value by vsqrtss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsqrtsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vsqrtsd_scalar_vector_arithmetic",
                target_register = "rip",
                role = "square-rooted scalar double-precision value by vsqrtsd",
            },
        }
,

    -- AVX logical.
        {
            node_type = "instruction",
            mnemonic = "vandps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vandps_vector_logic",
                target_register = "rip",
                role = "bitwise-and packed single-precision lanes by vandps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vandpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vandpd_vector_logic",
                target_register = "rip",
                role = "bitwise-and packed double-precision lanes by vandpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vandnps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vandnps_vector_logic",
                target_register = "rip",
                role = "bitwise-and-not packed single-precision lanes by vandnps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vandnpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vandnpd_vector_logic",
                target_register = "rip",
                role = "bitwise-and-not packed double-precision lanes by vandnpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vorps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vorps_vector_logic",
                target_register = "rip",
                role = "bitwise-or packed single-precision lanes by vorps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vorpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vorpd_vector_logic",
                target_register = "rip",
                role = "bitwise-or packed double-precision lanes by vorpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vxorps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vxorps_vector_logic",
                target_register = "rip",
                role = "bitwise-xor packed single-precision lanes by vxorps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vxorpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vxorpd_vector_logic",
                target_register = "rip",
                role = "bitwise-xor packed double-precision lanes by vxorpd",
            },
        }
,

    -- AVX compares and flag compares.
        {
            node_type = "instruction",
            mnemonic = "vcmpps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
            effect = {
                kind = "register_write",
                name = "vcmpps_vector_compare",
                target_register = "rip",
                role = "compared packed single-precision values by vcmpps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcmppd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
            effect = {
                kind = "register_write",
                name = "vcmppd_vector_compare",
                target_register = "rip",
                role = "compared packed double-precision values by vcmppd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcmpss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
            effect = {
                kind = "register_write",
                name = "vcmpss_scalar_vector_compare",
                target_register = "rip",
                role = "compared scalar single-precision values by vcmpss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcmpsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
            effect = {
                kind = "register_write",
                name = "vcmpsd_scalar_vector_compare",
                target_register = "rip",
                role = "compared scalar double-precision values by vcmpsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcomiss",
            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vcomiss_updates_rflags",
                target_register = "rflags",
                role = "updated by scalar single-precision compare vcomiss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vucomiss",
            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vucomiss_updates_rflags",
                target_register = "rflags",
                role = "updated by unordered scalar single-precision compare vucomiss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcomisd",
            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vcomisd_updates_rflags",
                target_register = "rflags",
                role = "updated by scalar double-precision compare vcomisd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vucomisd",
            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vucomisd_updates_rflags",
                target_register = "rflags",
                role = "updated by unordered scalar double-precision compare vucomisd",
            },
        }
,

    -- AVX shuffle/unpack/blend/permute.
        {
            node_type = "instruction",
            mnemonic = "vshufps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vshufps_vector_shuffle",
                target_register = "rip",
                role = "shuffled packed single-precision values by vshufps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vshufpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vshufpd_vector_shuffle",
                target_register = "rip",
                role = "shuffled packed double-precision values by vshufpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vunpckhps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vunpckhps_vector_unpack",
                target_register = "rip",
                role = "unpacked high packed single-precision values by vunpckhps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vunpcklps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vunpcklps_vector_unpack",
                target_register = "rip",
                role = "unpacked low packed single-precision values by vunpcklps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vunpckhpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vunpckhpd_vector_unpack",
                target_register = "rip",
                role = "unpacked high packed double-precision values by vunpckhpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vunpcklpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vunpcklpd_vector_unpack",
                target_register = "rip",
                role = "unpacked low packed double-precision values by vunpcklpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vblendps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vblendps_vector_blend",
                target_register = "rip",
                role = "blended packed single-precision values by vblendps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vblendpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vblendpd_vector_blend",
                target_register = "rip",
                role = "blended packed double-precision values by vblendpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vblendvps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "mask" } },
            effect = {
                kind = "register_write",
                name = "vblendvps_vector_blend",
                target_register = "rip",
                role = "variable-blended packed single-precision values by vblendvps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vblendvpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "mask" } },
            effect = {
                kind = "register_write",
                name = "vblendvpd_vector_blend",
                target_register = "rip",
                role = "variable-blended packed double-precision values by vblendvpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermilps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vpermilps_vector_permute",
                target_register = "rip",
                role = "permuted packed single-precision lanes by vpermilps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermilpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vpermilpd_vector_permute",
                target_register = "rip",
                role = "permuted packed double-precision lanes by vpermilpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vperm2f128",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vperm2f128_vector_permute",
                target_register = "rip",
                role = "permuted 128-bit floating lanes by vperm2f128",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vperm2i128",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vperm2i128_vector_permute",
                target_register = "rip",
                role = "permuted 128-bit integer lanes by vperm2i128",
            },
        }
,

    -- AVX conversion.
        {
            node_type = "instruction",
            mnemonic = "vcvtss2sd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvtss2sd_vector_convert",
                target_register = "rip",
                role = "converted scalar single to scalar double by vcvtss2sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtsd2ss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvtsd2ss_vector_convert",
                target_register = "rip",
                role = "converted scalar double to scalar single by vcvtsd2ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttps2dq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvttps2dq_vector_convert",
                target_register = "rip",
                role = "converted packed single to integers with truncation by vcvttps2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtps2dq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvtps2dq_vector_convert",
                target_register = "rip",
                role = "converted packed single to integers by vcvtps2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtdq2ps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvtdq2ps_vector_convert",
                target_register = "rip",
                role = "converted packed integers to single-precision by vcvtdq2ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtpd2ps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvtpd2ps_vector_convert",
                target_register = "rip",
                role = "converted packed double to packed single by vcvtpd2ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtps2pd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvtps2pd_vector_convert",
                target_register = "rip",
                role = "converted packed single to packed double by vcvtps2pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttpd2dq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvttpd2dq_vector_convert",
                target_register = "rip",
                role = "converted packed double to integers with truncation by vcvttpd2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtpd2dq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvtpd2dq_vector_convert",
                target_register = "rip",
                role = "converted packed double to integers by vcvtpd2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtdq2pd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvtdq2pd_vector_convert",
                target_register = "rip",
                role = "converted packed integers to double-precision by vcvtdq2pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtsi2ss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvtsi2ss_vector_convert",
                target_register = "rip",
                role = "converted integer to scalar single by vcvtsi2ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtsi2sd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvtsi2sd_vector_convert",
                target_register = "rip",
                role = "converted integer to scalar double by vcvtsi2sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtss2si",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvtss2si_writes_gpr",
                target_operand = 1,
                role = "written with converted scalar single integer by vcvtss2si",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtsd2si",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvtsd2si_writes_gpr",
                target_operand = 1,
                role = "written with converted scalar double integer by vcvtsd2si",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttss2si",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvttss2si_writes_gpr",
                target_operand = 1,
                role = "written with truncated scalar single integer by vcvttss2si",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttsd2si",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vcvttsd2si_writes_gpr",
                target_operand = 1,
                role = "written with truncated scalar double integer by vcvttsd2si",
            },
        }
,

    -- AVX packed integer arithmetic.
        {
            node_type = "instruction",
            mnemonic = "vpaddb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpaddb_vector_integer_add",
                target_register = "rip",
                role = "added packed byte integers by vpaddb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpaddw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpaddw_vector_integer_add",
                target_register = "rip",
                role = "added packed word integers by vpaddw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpaddd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpaddd_vector_integer_add",
                target_register = "rip",
                role = "added packed doubleword integers by vpaddd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpaddq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpaddq_vector_integer_add",
                target_register = "rip",
                role = "added packed quadword integers by vpaddq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpsubb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpsubb_vector_integer_subtract",
                target_register = "rip",
                role = "subtracted packed byte integers by vpsubb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpsubw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpsubw_vector_integer_subtract",
                target_register = "rip",
                role = "subtracted packed word integers by vpsubw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpsubd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpsubd_vector_integer_subtract",
                target_register = "rip",
                role = "subtracted packed doubleword integers by vpsubd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpsubq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpsubq_vector_integer_subtract",
                target_register = "rip",
                role = "subtracted packed quadword integers by vpsubq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmullw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmullw_vector_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed words low by vpmullw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmulhw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmulhw_vector_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed words high by vpmulhw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmulhuw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmulhuw_vector_integer_multiply",
                target_register = "rip",
                role = "multiplied packed unsigned words high by vpmulhuw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmulld",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmulld_vector_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed doublewords low by vpmulld",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmuldq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmuldq_vector_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed doublewords to quadwords by vpmuldq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmuludq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmuludq_vector_integer_multiply",
                target_register = "rip",
                role = "multiplied packed unsigned doublewords to quadwords by vpmuludq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmaddwd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaddwd_vector_integer_multiply_add",
                target_register = "rip",
                role = "multiply-added packed words to doublewords by vpmaddwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmaddubsw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaddubsw_vector_integer_multiply_add",
                target_register = "rip",
                role = "multiply-added packed unsigned bytes and signed bytes by vpmaddubsw",
            },
        }
,

    -- AVX packed integer logic.
        {
            node_type = "instruction",
            mnemonic = "vpand",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpand_vector_integer_logic",
                target_register = "rip",
                role = "bitwise-and packed integer lanes by vpand",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpandn",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpandn_vector_integer_logic",
                target_register = "rip",
                role = "bitwise-and-not packed integer lanes by vpandn",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpor",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpor_vector_integer_logic",
                target_register = "rip",
                role = "bitwise-or packed integer lanes by vpor",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpxor",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpxor_vector_integer_logic",
                target_register = "rip",
                role = "bitwise-xor packed integer lanes by vpxor",
            },
        }
,

    -- AVX packed integer compare/min/max.
        {
            node_type = "instruction",
            mnemonic = "vpcmpeqb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpcmpeqb_vector_integer_compare",
                target_register = "rip",
                role = "compared packed bytes for equality by vpcmpeqb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmpeqw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpcmpeqw_vector_integer_compare",
                target_register = "rip",
                role = "compared packed words for equality by vpcmpeqw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmpeqd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpcmpeqd_vector_integer_compare",
                target_register = "rip",
                role = "compared packed doublewords for equality by vpcmpeqd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmpeqq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpcmpeqq_vector_integer_compare",
                target_register = "rip",
                role = "compared packed quadwords for equality by vpcmpeqq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmpgtb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpcmpgtb_vector_integer_compare",
                target_register = "rip",
                role = "compared packed signed bytes greater-than by vpcmpgtb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmpgtw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpcmpgtw_vector_integer_compare",
                target_register = "rip",
                role = "compared packed signed words greater-than by vpcmpgtw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmpgtd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpcmpgtd_vector_integer_compare",
                target_register = "rip",
                role = "compared packed signed doublewords greater-than by vpcmpgtd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmpgtq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpcmpgtq_vector_integer_compare",
                target_register = "rip",
                role = "compared packed signed quadwords greater-than by vpcmpgtq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpminub",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpminub_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned byte minimums by vpminub",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpminuw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpminuw_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned word minimums by vpminuw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpminud",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpminud_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned doubleword minimums by vpminud",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpminsb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpminsb_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed signed byte minimums by vpminsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpminsw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpminsw_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed signed word minimums by vpminsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpminsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpminsd_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed signed doubleword minimums by vpminsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmaxub",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaxub_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned byte maximums by vpmaxub",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmaxuw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaxuw_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned word maximums by vpmaxuw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmaxud",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaxud_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned doubleword maximums by vpmaxud",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmaxsb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaxsb_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed signed byte maximums by vpmaxsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmaxsw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaxsw_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed signed word maximums by vpmaxsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmaxsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaxsd_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed signed doubleword maximums by vpmaxsd",
            },
        }
,

    -- AVX packed integer shifts.
        {
            node_type = "instruction",
            mnemonic = "vpsllw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsllw_vector_integer_shift",
                target_register = "rip",
                role = "shifted packed words left by vpsllw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpslld",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpslld_vector_integer_shift",
                target_register = "rip",
                role = "shifted packed doublewords left by vpslld",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpsllq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsllq_vector_integer_shift",
                target_register = "rip",
                role = "shifted packed quadwords left by vpsllq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpsrlw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsrlw_vector_integer_shift",
                target_register = "rip",
                role = "logically shifted packed words right by vpsrlw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpsrld",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsrld_vector_integer_shift",
                target_register = "rip",
                role = "logically shifted packed doublewords right by vpsrld",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpsrlq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsrlq_vector_integer_shift",
                target_register = "rip",
                role = "logically shifted packed quadwords right by vpsrlq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpsraw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsraw_vector_integer_shift",
                target_register = "rip",
                role = "arithmetically shifted packed words right by vpsraw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpsrad",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsrad_vector_integer_shift",
                target_register = "rip",
                role = "arithmetically shifted packed doublewords right by vpsrad",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpslldq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpslldq_vector_integer_shift",
                target_register = "rip",
                role = "shifted packed double-quadword left by vpslldq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpsrldq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsrldq_vector_integer_shift",
                target_register = "rip",
                role = "shifted packed double-quadword right by vpsrldq",
            },
        }
,

    -- AVX extract/mask to GPR.
        {
            node_type = "instruction",
            mnemonic = "vpmovmskb",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vpmovmskb_writes_gpr",
                target_operand = 1,
                role = "written with packed byte sign mask by vpmovmskb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpextrb",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpextrb_writes_gpr",
                target_operand = 1,
                role = "written with extracted byte by vpextrb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpextrw",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpextrw_writes_gpr",
                target_operand = 1,
                role = "written with extracted word by vpextrw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpextrd",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpextrd_writes_gpr",
                target_operand = 1,
                role = "written with extracted doubleword by vpextrd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpextrq",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpextrq_writes_gpr",
                target_operand = 1,
                role = "written with extracted quadword by vpextrq",
            },
        }
,

    -- AVX insert/pack/unpack/shuffle.
        {
            node_type = "instruction",
            mnemonic = "vpinsrb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" }, { index = 4, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpinsrb_vector_insert",
                target_register = "rip",
                role = "inserted byte into packed integer vector by vpinsrb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpinsrw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" }, { index = 4, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpinsrw_vector_insert",
                target_register = "rip",
                role = "inserted word into packed integer vector by vpinsrw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpinsrd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" }, { index = 4, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpinsrd_vector_insert",
                target_register = "rip",
                role = "inserted doubleword into packed integer vector by vpinsrd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpinsrq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" }, { index = 4, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpinsrq_vector_insert",
                target_register = "rip",
                role = "inserted quadword into packed integer vector by vpinsrq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpacksswb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpacksswb_vector_pack",
                target_register = "rip",
                role = "packed signed words to signed bytes by vpacksswb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpackssdw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpackssdw_vector_pack",
                target_register = "rip",
                role = "packed signed doublewords to signed words by vpackssdw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpackuswb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpackuswb_vector_pack",
                target_register = "rip",
                role = "packed signed words to unsigned bytes by vpackuswb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpackusdw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpackusdw_vector_pack",
                target_register = "rip",
                role = "packed signed doublewords to unsigned words by vpackusdw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshufd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vpshufd_vector_shuffle",
                target_register = "rip",
                role = "shuffled packed doublewords by vpshufd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshufhw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vpshufhw_vector_shuffle",
                target_register = "rip",
                role = "shuffled high packed words by vpshufhw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshuflw",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vpshuflw_vector_shuffle",
                target_register = "rip",
                role = "shuffled low packed words by vpshuflw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpshufb",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpshufb_vector_shuffle",
                target_register = "rip",
                role = "byte-shuffled packed integer lanes by vpshufb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpalignr",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpalignr_vector_align",
                target_register = "rip",
                role = "aligned packed bytes by vpalignr",
            },
        }
,

    -- AVX state helpers.
        {
            node_type = "instruction",
            mnemonic = "vzeroupper",
            operands = {},
            effect = {
                kind = "register_write",
                name = "vzeroupper_updates_vector_state",
                target_register = "rip",
                role = "zeroed upper vector register state by vzeroupper",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vzeroall",
            operands = {},
            effect = {
                kind = "register_write",
                name = "vzeroall_updates_vector_state",
                target_register = "rip",
                role = "zeroed all vector register state by vzeroall",
            },
        }
,

    -- FMA / FMA3 vector fused arithmetic visibility.
        -- Phase-one model: no vector register file yet, so vector-only effects are exposed as RIP-side activity.
    
        {
            node_type = "instruction",
            mnemonic = "vfmadd132ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd132ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed single-precision values by vfmadd132ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd213ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd213ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed single-precision values by vfmadd213ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd231ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd231ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed single-precision values by vfmadd231ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd132pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd132pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed double-precision values by vfmadd132pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd213pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd213pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed double-precision values by vfmadd213pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd231pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd231pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed double-precision values by vfmadd231pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd132ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd132ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar single-precision value by vfmadd132ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd213ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd213ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar single-precision value by vfmadd213ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd231ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd231ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar single-precision value by vfmadd231ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd132sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd132sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar double-precision value by vfmadd132sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd213sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd213sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar double-precision value by vfmadd213sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd231sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd231sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar double-precision value by vfmadd231sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub132ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub132ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed single-precision values by vfmsub132ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub213ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub213ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed single-precision values by vfmsub213ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub231ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub231ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed single-precision values by vfmsub231ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub132pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub132pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed double-precision values by vfmsub132pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub213pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub213pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed double-precision values by vfmsub213pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub231pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub231pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed double-precision values by vfmsub231pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmadd132ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd132ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed single-precision values by vfnmadd132ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmadd213ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd213ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed single-precision values by vfnmadd213ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmadd231ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd231ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed single-precision values by vfnmadd231ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsub132ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub132ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed single-precision values by vfnmsub132ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsub213ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub213ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed single-precision values by vfnmsub213ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsub231ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub231ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed single-precision values by vfnmsub231ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmaddsub132ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddsub132ps_vector_fma",
                target_register = "rip",
                role = "fused alternating add-sub packed single-precision values by vfmaddsub132ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmaddsub213ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddsub213ps_vector_fma",
                target_register = "rip",
                role = "fused alternating add-sub packed single-precision values by vfmaddsub213ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmaddsub231ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddsub231ps_vector_fma",
                target_register = "rip",
                role = "fused alternating add-sub packed single-precision values by vfmaddsub231ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsubadd132ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubadd132ps_vector_fma",
                target_register = "rip",
                role = "fused alternating sub-add packed single-precision values by vfmsubadd132ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsubadd213ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubadd213ps_vector_fma",
                target_register = "rip",
                role = "fused alternating sub-add packed single-precision values by vfmsubadd213ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsubadd231ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubadd231ps_vector_fma",
                target_register = "rip",
                role = "fused alternating sub-add packed single-precision values by vfmsubadd231ps",
            },
        }
,

    -- Rounding / dot product / horizontal operations.
    
        {
            node_type = "instruction",
            mnemonic = "roundps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "roundps_vector_round",
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
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "roundpd_vector_round",
                target_register = "rip",
                role = "rounded packed double-precision values by roundpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "roundss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "roundss_scalar_round",
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
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "roundsd_scalar_round",
                target_register = "rip",
                role = "rounded scalar double-precision value by roundsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vroundps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "vroundps_vector_round",
                target_register = "rip",
                role = "rounded packed single-precision values by vroundps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vroundpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "vroundpd_vector_round",
                target_register = "rip",
                role = "rounded packed double-precision values by vroundpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vroundss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "vroundss_scalar_round",
                target_register = "rip",
                role = "rounded scalar single-precision value by vroundss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vroundsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "vroundsd_scalar_round",
                target_register = "rip",
                role = "rounded scalar double-precision value by vroundsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vdpps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vdpps_vector_dot_product",
                target_register = "rip",
                role = "computed packed single-precision dot product by vdpps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vdppd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vdppd_vector_dot_product",
                target_register = "rip",
                role = "computed packed double-precision dot product by vdppd",
            },
        }
,

    -- Broadcast / gather / mask-load-store / vector insert-extract.
    
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
            mnemonic = "vbroadcastf128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastf128_vector_broadcast",
                target_register = "rip",
                role = "broadcast 128-bit floating vector by vbroadcastf128",
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
                role = "broadcast 128-bit integer vector by vbroadcasti128",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vgatherdps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vgatherdps_vector_gather",
                target_register = "rip",
                role = "gathered packed single-precision values by vgatherdps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vgatherdpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vgatherdpd_vector_gather",
                target_register = "rip",
                role = "gathered packed double-precision values by vgatherdpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vgatherqps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vgatherqps_vector_gather",
                target_register = "rip",
                role = "gathered packed single-precision values with quadword indices by vgatherqps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vgatherqpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vgatherqpd_vector_gather",
                target_register = "rip",
                role = "gathered packed double-precision values with quadword indices by vgatherqpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpgatherdd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vpgatherdd_vector_gather",
                target_register = "rip",
                role = "gathered packed doubleword integers by vpgatherdd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpgatherdq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vpgatherdq_vector_gather",
                target_register = "rip",
                role = "gathered packed quadword integers with doubleword indices by vpgatherdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpgatherqd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vpgatherqd_vector_gather",
                target_register = "rip",
                role = "gathered packed doubleword integers with quadword indices by vpgatherqd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpgatherqq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vpgatherqq_vector_gather",
                target_register = "rip",
                role = "gathered packed quadword integers by vpgatherqq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmaskmovd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmaskmovd_vector_mask_move",
                target_register = "rip",
                role = "masked moved packed doubleword integers by vpmaskmovd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmaskmovq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmaskmovq_vector_mask_move",
                target_register = "rip",
                role = "masked moved packed quadword integers by vpmaskmovq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vextractf128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
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
            mnemonic = "vinsertf128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "index" },
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
            mnemonic = "vextracti128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
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
            mnemonic = "vinserti128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vinserti128_vector_insert",
                target_register = "rip",
                role = "inserted 128-bit integer lane by vinserti128",
            },
        }
,

    -- AVX-512 / EVEX / mask-register visibility effects.
        -- Phase-one model: no k-register or zmm-register file yet, so most effects are exposed as RIP-side activity.
    
        -- Mask register moves and logic.
    
        {
            node_type = "instruction",
            mnemonic = "kmovb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "kmovb_mask_move",
                target_register = "rip",
                role = "moved byte mask register state by kmovb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kmovw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "kmovw_mask_move",
                target_register = "rip",
                role = "moved word mask register state by kmovw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kmovd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "kmovd_mask_move",
                target_register = "rip",
                role = "moved doubleword mask register state by kmovd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kmovq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "kmovq_mask_move",
                target_register = "rip",
                role = "moved quadword mask register state by kmovq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kandb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandb_mask_logic",
                target_register = "rip",
                role = "bitwise-and byte mask state by kandb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kandw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandw_mask_logic",
                target_register = "rip",
                role = "bitwise-and word mask state by kandw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kandd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandd_mask_logic",
                target_register = "rip",
                role = "bitwise-and doubleword mask state by kandd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kandq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandq_mask_logic",
                target_register = "rip",
                role = "bitwise-and quadword mask state by kandq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kandnb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandnb_mask_logic",
                target_register = "rip",
                role = "bitwise-and-not byte mask state by kandnb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kandnw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandnw_mask_logic",
                target_register = "rip",
                role = "bitwise-and-not word mask state by kandnw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kandnd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandnd_mask_logic",
                target_register = "rip",
                role = "bitwise-and-not doubleword mask state by kandnd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kandnq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kandnq_mask_logic",
                target_register = "rip",
                role = "bitwise-and-not quadword mask state by kandnq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "korb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "korb_mask_logic",
                target_register = "rip",
                role = "bitwise-or byte mask state by korb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "korw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "korw_mask_logic",
                target_register = "rip",
                role = "bitwise-or word mask state by korw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kord",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kord_mask_logic",
                target_register = "rip",
                role = "bitwise-or doubleword mask state by kord",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "korq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "korq_mask_logic",
                target_register = "rip",
                role = "bitwise-or quadword mask state by korq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kxorb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kxorb_mask_logic",
                target_register = "rip",
                role = "bitwise-xor byte mask state by kxorb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kxorw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kxorw_mask_logic",
                target_register = "rip",
                role = "bitwise-xor word mask state by kxorw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kxord",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kxord_mask_logic",
                target_register = "rip",
                role = "bitwise-xor doubleword mask state by kxord",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kxorq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kxorq_mask_logic",
                target_register = "rip",
                role = "bitwise-xor quadword mask state by kxorq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "knotb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "knotb_mask_logic",
                target_register = "rip",
                role = "bitwise-inverted byte mask state by knotb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "knotw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "knotw_mask_logic",
                target_register = "rip",
                role = "bitwise-inverted word mask state by knotw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "knotd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "knotd_mask_logic",
                target_register = "rip",
                role = "bitwise-inverted doubleword mask state by knotd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "knotq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "knotq_mask_logic",
                target_register = "rip",
                role = "bitwise-inverted quadword mask state by knotq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kaddb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kaddb_mask_add",
                target_register = "rip",
                role = "added byte mask state by kaddb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kaddw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kaddw_mask_add",
                target_register = "rip",
                role = "added word mask state by kaddw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kaddd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kaddd_mask_add",
                target_register = "rip",
                role = "added doubleword mask state by kaddd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kaddq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kaddq_mask_add",
                target_register = "rip",
                role = "added quadword mask state by kaddq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kshiftlb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftlb_mask_shift",
                target_register = "rip",
                role = "shifted byte mask state left by kshiftlb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kshiftlw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftlw_mask_shift",
                target_register = "rip",
                role = "shifted word mask state left by kshiftlw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kshiftld",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftld_mask_shift",
                target_register = "rip",
                role = "shifted doubleword mask state left by kshiftld",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kshiftlq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftlq_mask_shift",
                target_register = "rip",
                role = "shifted quadword mask state left by kshiftlq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kshiftrb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftrb_mask_shift",
                target_register = "rip",
                role = "shifted byte mask state right by kshiftrb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kshiftrw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftrw_mask_shift",
                target_register = "rip",
                role = "shifted word mask state right by kshiftrw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kshiftrd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftrd_mask_shift",
                target_register = "rip",
                role = "shifted doubleword mask state right by kshiftrd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kshiftrq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "kshiftrq_mask_shift",
                target_register = "rip",
                role = "shifted quadword mask state right by kshiftrq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kortestb",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kortestb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte mask or-test kortestb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kortestw",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kortestw_updates_rflags",
                target_register = "rflags",
                role = "updated by word mask or-test kortestw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kortestd",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kortestd_updates_rflags",
                target_register = "rflags",
                role = "updated by doubleword mask or-test kortestd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "kortestq",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "kortestq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword mask or-test kortestq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ktestb",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "ktestb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte mask test ktestb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ktestw",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "ktestw_updates_rflags",
                target_register = "rflags",
                role = "updated by word mask test ktestw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ktestd",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "ktestd_updates_rflags",
                target_register = "rflags",
                role = "updated by doubleword mask test ktestd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ktestq",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "ktestq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword mask test ktestq",
            },
        }
,

    -- AVX-512 compress / expand.
    
        {
            node_type = "instruction",
            mnemonic = "vcompressps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcompressps_vector_compress",
                target_register = "rip",
                role = "compressed packed single-precision values by vcompressps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcompresspd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcompresspd_vector_compress",
                target_register = "rip",
                role = "compressed packed double-precision values by vcompresspd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcompressd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpcompressd_vector_compress",
                target_register = "rip",
                role = "compressed packed doubleword integers by vpcompressd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcompressq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpcompressq_vector_compress",
                target_register = "rip",
                role = "compressed packed quadword integers by vpcompressq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vexpandps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vexpandps_vector_expand",
                target_register = "rip",
                role = "expanded packed single-precision values by vexpandps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vexpandpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vexpandpd_vector_expand",
                target_register = "rip",
                role = "expanded packed double-precision values by vexpandpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpexpandd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpexpandd_vector_expand",
                target_register = "rip",
                role = "expanded packed doubleword integers by vpexpandd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpexpandq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpexpandq_vector_expand",
                target_register = "rip",
                role = "expanded packed quadword integers by vpexpandq",
            },
        }
,

    -- AVX-512 scatter.
    
        {
            node_type = "instruction",
            mnemonic = "vscatterdps",
            operands = {
                { index = 1, role = "memory" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vscatterdps_vector_scatter",
                target_register = "rip",
                role = "scattered packed single-precision values by vscatterdps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vscatterdpd",
            operands = {
                { index = 1, role = "memory" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vscatterdpd_vector_scatter",
                target_register = "rip",
                role = "scattered packed double-precision values by vscatterdpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vscatterqps",
            operands = {
                { index = 1, role = "memory" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vscatterqps_vector_scatter",
                target_register = "rip",
                role = "scattered packed single-precision values with quadword indices by vscatterqps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vscatterqpd",
            operands = {
                { index = 1, role = "memory" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vscatterqpd_vector_scatter",
                target_register = "rip",
                role = "scattered packed double-precision values with quadword indices by vscatterqpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpscatterdd",
            operands = {
                { index = 1, role = "memory" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpscatterdd_vector_scatter",
                target_register = "rip",
                role = "scattered packed doubleword integers by vpscatterdd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpscatterdq",
            operands = {
                { index = 1, role = "memory" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpscatterdq_vector_scatter",
                target_register = "rip",
                role = "scattered packed quadword integers with doubleword indices by vpscatterdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpscatterqd",
            operands = {
                { index = 1, role = "memory" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpscatterqd_vector_scatter",
                target_register = "rip",
                role = "scattered packed doubleword integers with quadword indices by vpscatterqd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpscatterqq",
            operands = {
                { index = 1, role = "memory" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpscatterqq_vector_scatter",
                target_register = "rip",
                role = "scattered packed quadword integers by vpscatterqq",
            },
        }
,

    -- AVX-512 conflict / ternary logic / leading-zero helpers.
    
        {
            node_type = "instruction",
            mnemonic = "vpconflictd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpconflictd_vector_conflict",
                target_register = "rip",
                role = "detected packed doubleword conflicts by vpconflictd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpconflictq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpconflictq_vector_conflict",
                target_register = "rip",
                role = "detected packed quadword conflicts by vpconflictq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpternlogd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "truth_table" },
            },
            effect = {
                kind = "register_write",
                name = "vpternlogd_vector_logic",
                target_register = "rip",
                role = "applied ternary logic to packed doublewords by vpternlogd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpternlogq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "truth_table" },
            },
            effect = {
                kind = "register_write",
                name = "vpternlogq_vector_logic",
                target_register = "rip",
                role = "applied ternary logic to packed quadwords by vpternlogq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vplzcntd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vplzcntd_vector_count",
                target_register = "rip",
                role = "counted leading zero bits in packed doublewords by vplzcntd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vplzcntq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vplzcntq_vector_count",
                target_register = "rip",
                role = "counted leading zero bits in packed quadwords by vplzcntq",
            },
        }
,

    -- AVX-512 broadcast extensions.
    
        {
            node_type = "instruction",
            mnemonic = "vpbroadcastb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpbroadcastb_vector_broadcast",
                target_register = "rip",
                role = "broadcast byte integer by vpbroadcastb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpbroadcastw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpbroadcastw_vector_broadcast",
                target_register = "rip",
                role = "broadcast word integer by vpbroadcastw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpbroadcastd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpbroadcastd_vector_broadcast",
                target_register = "rip",
                role = "broadcast doubleword integer by vpbroadcastd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpbroadcastq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpbroadcastq_vector_broadcast",
                target_register = "rip",
                role = "broadcast quadword integer by vpbroadcastq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcastf32x2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastf32x2_vector_broadcast",
                target_register = "rip",
                role = "broadcast two packed single-precision values by vbroadcastf32x2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcastf32x4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastf32x4_vector_broadcast",
                target_register = "rip",
                role = "broadcast four packed single-precision values by vbroadcastf32x4",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcastf32x8",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastf32x8_vector_broadcast",
                target_register = "rip",
                role = "broadcast eight packed single-precision values by vbroadcastf32x8",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcastf64x2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastf64x2_vector_broadcast",
                target_register = "rip",
                role = "broadcast two packed double-precision values by vbroadcastf64x2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcastf64x4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastf64x4_vector_broadcast",
                target_register = "rip",
                role = "broadcast four packed double-precision values by vbroadcastf64x4",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcasti32x2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcasti32x2_vector_broadcast",
                target_register = "rip",
                role = "broadcast two packed doubleword integers by vbroadcasti32x2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcasti32x4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcasti32x4_vector_broadcast",
                target_register = "rip",
                role = "broadcast four packed doubleword integers by vbroadcasti32x4",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcasti32x8",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcasti32x8_vector_broadcast",
                target_register = "rip",
                role = "broadcast eight packed doubleword integers by vbroadcasti32x8",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcasti64x2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcasti64x2_vector_broadcast",
                target_register = "rip",
                role = "broadcast two packed quadword integers by vbroadcasti64x2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcasti64x4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcasti64x4_vector_broadcast",
                target_register = "rip",
                role = "broadcast four packed quadword integers by vbroadcasti64x4",
            },
        }
,

    -- AVX-512 insert/extract wider lanes.
    
        {
            node_type = "instruction",
            mnemonic = "vextractf32x4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vextractf32x4_vector_extract",
                target_register = "rip",
                role = "extracted 128-bit single-precision lane by vextractf32x4",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vextractf32x8",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vextractf32x8_vector_extract",
                target_register = "rip",
                role = "extracted 256-bit single-precision lane by vextractf32x8",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vextractf64x2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vextractf64x2_vector_extract",
                target_register = "rip",
                role = "extracted 128-bit double-precision lane by vextractf64x2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vextractf64x4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vextractf64x4_vector_extract",
                target_register = "rip",
                role = "extracted 256-bit double-precision lane by vextractf64x4",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vextracti32x4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vextracti32x4_vector_extract",
                target_register = "rip",
                role = "extracted 128-bit doubleword integer lane by vextracti32x4",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vextracti32x8",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vextracti32x8_vector_extract",
                target_register = "rip",
                role = "extracted 256-bit doubleword integer lane by vextracti32x8",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vextracti64x2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vextracti64x2_vector_extract",
                target_register = "rip",
                role = "extracted 128-bit quadword integer lane by vextracti64x2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vextracti64x4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vextracti64x4_vector_extract",
                target_register = "rip",
                role = "extracted 256-bit quadword integer lane by vextracti64x4",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vinsertf32x4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vinsertf32x4_vector_insert",
                target_register = "rip",
                role = "inserted 128-bit single-precision lane by vinsertf32x4",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vinsertf32x8",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vinsertf32x8_vector_insert",
                target_register = "rip",
                role = "inserted 256-bit single-precision lane by vinsertf32x8",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vinsertf64x2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vinsertf64x2_vector_insert",
                target_register = "rip",
                role = "inserted 128-bit double-precision lane by vinsertf64x2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vinsertf64x4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vinsertf64x4_vector_insert",
                target_register = "rip",
                role = "inserted 256-bit double-precision lane by vinsertf64x4",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vinserti32x4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vinserti32x4_vector_insert",
                target_register = "rip",
                role = "inserted 128-bit doubleword integer lane by vinserti32x4",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vinserti32x8",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vinserti32x8_vector_insert",
                target_register = "rip",
                role = "inserted 256-bit doubleword integer lane by vinserti32x8",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vinserti64x2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vinserti64x2_vector_insert",
                target_register = "rip",
                role = "inserted 128-bit quadword integer lane by vinserti64x2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vinserti64x4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vinserti64x4_vector_insert",
                target_register = "rip",
                role = "inserted 256-bit quadword integer lane by vinserti64x4",
            },
        }
,

    -- AVX-512 compare / class / mask-test / convert / narrow / widen / permute visibility effects.
        -- Phase-one model: no k-register or zmm-register file yet, so most vector/mask effects are exposed as RIP-side activity.
    
        -- AVX-512 packed integer compare-to-mask.
    
        {
            node_type = "instruction",
            mnemonic = "vpcmpb",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcmpb_vector_compare_mask",
                target_register = "rip",
                role = "compared packed signed bytes into mask by vpcmpb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmpw",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcmpw_vector_compare_mask",
                target_register = "rip",
                role = "compared packed signed words into mask by vpcmpw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmpd",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcmpd_vector_compare_mask",
                target_register = "rip",
                role = "compared packed signed doublewords into mask by vpcmpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmpq",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcmpq_vector_compare_mask",
                target_register = "rip",
                role = "compared packed signed quadwords into mask by vpcmpq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmpub",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcmpub_vector_compare_mask",
                target_register = "rip",
                role = "compared packed unsigned bytes into mask by vpcmpub",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmpuw",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcmpuw_vector_compare_mask",
                target_register = "rip",
                role = "compared packed unsigned words into mask by vpcmpuw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmpud",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcmpud_vector_compare_mask",
                target_register = "rip",
                role = "compared packed unsigned doublewords into mask by vpcmpud",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpcmpuq",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vpcmpuq_vector_compare_mask",
                target_register = "rip",
                role = "compared packed unsigned quadwords into mask by vpcmpuq",
            },
        }
,

    -- AVX-512 floating-point class tests.
    
        {
            node_type = "instruction",
            mnemonic = "vfpclassps",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "source" },
                { index = 3, role = "class_mask" },
            },
            effect = {
                kind = "register_write",
                name = "vfpclassps_vector_class_mask",
                target_register = "rip",
                role = "classified packed single-precision values into mask by vfpclassps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfpclasspd",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "source" },
                { index = 3, role = "class_mask" },
            },
            effect = {
                kind = "register_write",
                name = "vfpclasspd_vector_class_mask",
                target_register = "rip",
                role = "classified packed double-precision values into mask by vfpclasspd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfpclassss",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "source" },
                { index = 3, role = "class_mask" },
            },
            effect = {
                kind = "register_write",
                name = "vfpclassss_scalar_class_mask",
                target_register = "rip",
                role = "classified scalar single-precision value into mask by vfpclassss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfpclasssd",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "source" },
                { index = 3, role = "class_mask" },
            },
            effect = {
                kind = "register_write",
                name = "vfpclasssd_scalar_class_mask",
                target_register = "rip",
                role = "classified scalar double-precision value into mask by vfpclasssd",
            },
        }
,

    -- AVX-512 packed integer mask tests.
    
        {
            node_type = "instruction",
            mnemonic = "vptestmb",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vptestmb_vector_mask_test",
                target_register = "rip",
                role = "tested packed byte masks by vptestmb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vptestmw",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vptestmw_vector_mask_test",
                target_register = "rip",
                role = "tested packed word masks by vptestmw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vptestmd",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vptestmd_vector_mask_test",
                target_register = "rip",
                role = "tested packed doubleword masks by vptestmd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vptestmq",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vptestmq_vector_mask_test",
                target_register = "rip",
                role = "tested packed quadword masks by vptestmq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vptestnmb",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vptestnmb_vector_mask_test",
                target_register = "rip",
                role = "tested packed byte inverted masks by vptestnmb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vptestnmw",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vptestnmw_vector_mask_test",
                target_register = "rip",
                role = "tested packed word inverted masks by vptestnmw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vptestnmd",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vptestnmd_vector_mask_test",
                target_register = "rip",
                role = "tested packed doubleword inverted masks by vptestnmd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vptestnmq",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vptestnmq_vector_mask_test",
                target_register = "rip",
                role = "tested packed quadword inverted masks by vptestnmq",
            },
        }
,

    -- AVX-512 floating/integer conversion visibility.
    
        {
            node_type = "instruction",
            mnemonic = "vcvtps2qq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtps2qq_vector_convert",
                target_register = "rip",
                role = "converted packed single-precision values to signed quadword integers by vcvtps2qq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtps2uqq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtps2uqq_vector_convert",
                target_register = "rip",
                role = "converted packed single-precision values to unsigned quadword integers by vcvtps2uqq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtpd2qq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtpd2qq_vector_convert",
                target_register = "rip",
                role = "converted packed double-precision values to signed quadword integers by vcvtpd2qq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtpd2uqq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtpd2uqq_vector_convert",
                target_register = "rip",
                role = "converted packed double-precision values to unsigned quadword integers by vcvtpd2uqq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtqq2ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtqq2ps_vector_convert",
                target_register = "rip",
                role = "converted packed signed quadword integers to single-precision values by vcvtqq2ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtuqq2ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtuqq2ps_vector_convert",
                target_register = "rip",
                role = "converted packed unsigned quadword integers to single-precision values by vcvtuqq2ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtqq2pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtqq2pd_vector_convert",
                target_register = "rip",
                role = "converted packed signed quadword integers to double-precision values by vcvtqq2pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtuqq2pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtuqq2pd_vector_convert",
                target_register = "rip",
                role = "converted packed unsigned quadword integers to double-precision values by vcvtuqq2pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttps2qq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvttps2qq_vector_convert",
                target_register = "rip",
                role = "converted packed single-precision values to signed quadword integers with truncation by vcvttps2qq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttps2uqq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvttps2uqq_vector_convert",
                target_register = "rip",
                role = "converted packed single-precision values to unsigned quadword integers with truncation by vcvttps2uqq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttpd2qq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvttpd2qq_vector_convert",
                target_register = "rip",
                role = "converted packed double-precision values to signed quadword integers with truncation by vcvttpd2qq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttpd2uqq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvttpd2uqq_vector_convert",
                target_register = "rip",
                role = "converted packed double-precision values to unsigned quadword integers with truncation by vcvttpd2uqq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtudq2ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtudq2ps_vector_convert",
                target_register = "rip",
                role = "converted packed unsigned doubleword integers to single-precision values by vcvtudq2ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtudq2pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtudq2pd_vector_convert",
                target_register = "rip",
                role = "converted packed unsigned doubleword integers to double-precision values by vcvtudq2pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtps2udq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtps2udq_vector_convert",
                target_register = "rip",
                role = "converted packed single-precision values to unsigned doubleword integers by vcvtps2udq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtpd2udq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtpd2udq_vector_convert",
                target_register = "rip",
                role = "converted packed double-precision values to unsigned doubleword integers by vcvtpd2udq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttps2udq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvttps2udq_vector_convert",
                target_register = "rip",
                role = "converted packed single-precision values to unsigned doubleword integers with truncation by vcvttps2udq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttpd2udq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvttpd2udq_vector_convert",
                target_register = "rip",
                role = "converted packed double-precision values to unsigned doubleword integers with truncation by vcvttpd2udq",
            },
        }
,

    -- AVX-512 integer narrowing / widening move visibility.
    
        {
            node_type = "instruction",
            mnemonic = "vpmovdb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovdb_vector_narrow",
                target_register = "rip",
                role = "narrowed packed doubleword integers to bytes by vpmovdb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovdw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovdw_vector_narrow",
                target_register = "rip",
                role = "narrowed packed doubleword integers to words by vpmovdw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovqb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovqb_vector_narrow",
                target_register = "rip",
                role = "narrowed packed quadword integers to bytes by vpmovqb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovqw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovqw_vector_narrow",
                target_register = "rip",
                role = "narrowed packed quadword integers to words by vpmovqw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovqd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovqd_vector_narrow",
                target_register = "rip",
                role = "narrowed packed quadword integers to doublewords by vpmovqd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovsdb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovsdb_vector_signed_saturating_narrow",
                target_register = "rip",
                role = "signed-saturating narrowed packed doubleword integers to bytes by vpmovsdb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovsdw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovsdw_vector_signed_saturating_narrow",
                target_register = "rip",
                role = "signed-saturating narrowed packed doubleword integers to words by vpmovsdw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovsqb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovsqb_vector_signed_saturating_narrow",
                target_register = "rip",
                role = "signed-saturating narrowed packed quadword integers to bytes by vpmovsqb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovsqw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovsqw_vector_signed_saturating_narrow",
                target_register = "rip",
                role = "signed-saturating narrowed packed quadword integers to words by vpmovsqw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovsqd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovsqd_vector_signed_saturating_narrow",
                target_register = "rip",
                role = "signed-saturating narrowed packed quadword integers to doublewords by vpmovsqd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovusdb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovusdb_vector_unsigned_saturating_narrow",
                target_register = "rip",
                role = "unsigned-saturating narrowed packed doubleword integers to bytes by vpmovusdb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovusdw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovusdw_vector_unsigned_saturating_narrow",
                target_register = "rip",
                role = "unsigned-saturating narrowed packed doubleword integers to words by vpmovusdw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovusqb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovusqb_vector_unsigned_saturating_narrow",
                target_register = "rip",
                role = "unsigned-saturating narrowed packed quadword integers to bytes by vpmovusqb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovusqw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovusqw_vector_unsigned_saturating_narrow",
                target_register = "rip",
                role = "unsigned-saturating narrowed packed quadword integers to words by vpmovusqw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovusqd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovusqd_vector_unsigned_saturating_narrow",
                target_register = "rip",
                role = "unsigned-saturating narrowed packed quadword integers to doublewords by vpmovusqd",
            },
        }
,

    -- AVX-512 mask extraction from vector lanes.
    
        {
            node_type = "instruction",
            mnemonic = "vpmovb2m",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovb2m_vector_to_mask",
                target_register = "rip",
                role = "moved packed byte sign bits into mask by vpmovb2m",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovw2m",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovw2m_vector_to_mask",
                target_register = "rip",
                role = "moved packed word sign bits into mask by vpmovw2m",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovd2m",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovd2m_vector_to_mask",
                target_register = "rip",
                role = "moved packed doubleword sign bits into mask by vpmovd2m",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovq2m",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovq2m_vector_to_mask",
                target_register = "rip",
                role = "moved packed quadword sign bits into mask by vpmovq2m",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovm2b",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask_source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovm2b_mask_to_vector",
                target_register = "rip",
                role = "expanded mask bits into packed bytes by vpmovm2b",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovm2w",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask_source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovm2w_mask_to_vector",
                target_register = "rip",
                role = "expanded mask bits into packed words by vpmovm2w",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovm2d",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask_source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovm2d_mask_to_vector",
                target_register = "rip",
                role = "expanded mask bits into packed doublewords by vpmovm2d",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmovm2q",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask_source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmovm2q_mask_to_vector",
                target_register = "rip",
                role = "expanded mask bits into packed quadwords by vpmovm2q",
            },
        }
,

    -- AVX-512 permutation.
    
        {
            node_type = "instruction",
            mnemonic = "vpermb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "indices" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpermb_vector_permute",
                target_register = "rip",
                role = "permuted packed bytes by vpermb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "indices" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpermw_vector_permute",
                target_register = "rip",
                role = "permuted packed words by vpermw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "indices" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpermd_vector_permute",
                target_register = "rip",
                role = "permuted packed doublewords by vpermd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "indices" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpermq_vector_permute",
                target_register = "rip",
                role = "permuted packed quadwords by vpermq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermi2b",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "indices" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpermi2b_vector_permute",
                target_register = "rip",
                role = "permuted packed bytes using two sources by vpermi2b",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermi2w",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "indices" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpermi2w_vector_permute",
                target_register = "rip",
                role = "permuted packed words using two sources by vpermi2w",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermi2d",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "indices" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpermi2d_vector_permute",
                target_register = "rip",
                role = "permuted packed doublewords using two sources by vpermi2d",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermi2q",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "indices" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpermi2q_vector_permute",
                target_register = "rip",
                role = "permuted packed quadwords using two sources by vpermi2q",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermt2b",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "indices" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpermt2b_vector_permute",
                target_register = "rip",
                role = "permuted packed bytes into second table by vpermt2b",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermt2w",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "indices" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpermt2w_vector_permute",
                target_register = "rip",
                role = "permuted packed words into second table by vpermt2w",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermt2d",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "indices" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpermt2d_vector_permute",
                target_register = "rip",
                role = "permuted packed doublewords into second table by vpermt2d",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpermt2q",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "indices" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpermt2q_vector_permute",
                target_register = "rip",
                role = "permuted packed quadwords into second table by vpermt2q",
            },
        }
,

    -- AVX-512 VNNI / BF16 / FP16 / AMX visibility effects.
        -- Phase-one model: no vector, mask, or tile register file yet, so most effects are exposed as RIP-side activity.
    
        -- AVX-512 VNNI dot-product / neural-network integer operations.
    
        {
            node_type = "instruction",
            mnemonic = "vpdpbusd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "unsigned_bytes" },
                { index = 3, role = "signed_bytes" },
            },
            effect = {
                kind = "register_write",
                name = "vpdpbusd_vector_vnni",
                target_register = "rip",
                role = "dot-product accumulated unsigned bytes with signed bytes into doublewords by vpdpbusd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpdpbusds",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "unsigned_bytes" },
                { index = 3, role = "signed_bytes" },
            },
            effect = {
                kind = "register_write",
                name = "vpdpbusds_vector_vnni",
                target_register = "rip",
                role = "saturating dot-product accumulated unsigned bytes with signed bytes into doublewords by vpdpbusds",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpdpwssd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left_words" },
                { index = 3, role = "right_words" },
            },
            effect = {
                kind = "register_write",
                name = "vpdpwssd_vector_vnni",
                target_register = "rip",
                role = "dot-product accumulated signed words into doublewords by vpdpwssd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpdpwssds",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left_words" },
                { index = 3, role = "right_words" },
            },
            effect = {
                kind = "register_write",
                name = "vpdpwssds_vector_vnni",
                target_register = "rip",
                role = "saturating dot-product accumulated signed words into doublewords by vpdpwssds",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vdpbf16ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left_bfloat16" },
                { index = 3, role = "right_bfloat16" },
            },
            effect = {
                kind = "register_write",
                name = "vdpbf16ps_vector_bf16",
                target_register = "rip",
                role = "dot-product accumulated bfloat16 pairs into single-precision values by vdpbf16ps",
            },
        }
,

    -- AVX-512 BF16 conversion.
    
        {
            node_type = "instruction",
            mnemonic = "vcvtneps2bf16",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtneps2bf16_vector_bf16_convert",
                target_register = "rip",
                role = "converted packed single-precision values to nearest-even bfloat16 by vcvtneps2bf16",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtne2ps2bf16",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left_source" },
                { index = 3, role = "right_source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtne2ps2bf16_vector_bf16_convert",
                target_register = "rip",
                role = "converted two packed single-precision sources to nearest-even bfloat16 by vcvtne2ps2bf16",
            },
        }
,

    -- AVX-512 FP16 / half-precision arithmetic.
    
        {
            node_type = "instruction",
            mnemonic = "vaddph",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vaddph_vector_fp16_arithmetic",
                target_register = "rip",
                role = "added packed half-precision values by vaddph",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vaddsh",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vaddsh_scalar_fp16_arithmetic",
                target_register = "rip",
                role = "added scalar half-precision values by vaddsh",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsubph",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vsubph_vector_fp16_arithmetic",
                target_register = "rip",
                role = "subtracted packed half-precision values by vsubph",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsubsh",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vsubsh_scalar_fp16_arithmetic",
                target_register = "rip",
                role = "subtracted scalar half-precision values by vsubsh",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vdivph",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vdivph_vector_fp16_arithmetic",
                target_register = "rip",
                role = "divided packed half-precision values by vdivph",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vdivsh",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vdivsh_scalar_fp16_arithmetic",
                target_register = "rip",
                role = "divided scalar half-precision values by vdivsh",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsqrtph",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vsqrtph_vector_fp16_arithmetic",
                target_register = "rip",
                role = "square-rooted packed half-precision values by vsqrtph",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsqrtsh",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vsqrtsh_scalar_fp16_arithmetic",
                target_register = "rip",
                role = "square-rooted scalar half-precision value by vsqrtsh",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcmpph",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vcmpph_vector_fp16_compare",
                target_register = "rip",
                role = "compared packed half-precision values into mask by vcmpph",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcmpsh",
            operands = {
                { index = 1, role = "mask_destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "vcmpsh_scalar_fp16_compare",
                target_register = "rip",
                role = "compared scalar half-precision values into mask by vcmpsh",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcomish",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vcomish_updates_rflags",
                target_register = "rflags",
                role = "updated by scalar half-precision compare vcomish",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vucomish",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vucomish_updates_rflags",
                target_register = "rflags",
                role = "updated by unordered scalar half-precision compare vucomish",
            },
        }
,

    -- AVX-512 FP16 conversion.
    
        {
            node_type = "instruction",
            mnemonic = "vcvtph2psx",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtph2psx_vector_fp16_convert",
                target_register = "rip",
                role = "converted packed half-precision values to single-precision values by vcvtph2psx",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtps2phx",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtps2phx_vector_fp16_convert",
                target_register = "rip",
                role = "converted packed single-precision values to half-precision values by vcvtps2phx",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtsh2ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtsh2ss_scalar_fp16_convert",
                target_register = "rip",
                role = "converted scalar half-precision value to single-precision value by vcvtsh2ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtss2sh",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtss2sh_scalar_fp16_convert",
                target_register = "rip",
                role = "converted scalar single-precision value to half-precision value by vcvtss2sh",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtph2dq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtph2dq_vector_fp16_convert",
                target_register = "rip",
                role = "converted packed half-precision values to signed doubleword integers by vcvtph2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtph2qq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtph2qq_vector_fp16_convert",
                target_register = "rip",
                role = "converted packed half-precision values to signed quadword integers by vcvtph2qq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtph2udq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtph2udq_vector_fp16_convert",
                target_register = "rip",
                role = "converted packed half-precision values to unsigned doubleword integers by vcvtph2udq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtph2uqq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtph2uqq_vector_fp16_convert",
                target_register = "rip",
                role = "converted packed half-precision values to unsigned quadword integers by vcvtph2uqq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtdq2ph",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtdq2ph_vector_fp16_convert",
                target_register = "rip",
                role = "converted packed signed doubleword integers to half-precision values by vcvtdq2ph",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtqq2ph",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtqq2ph_vector_fp16_convert",
                target_register = "rip",
                role = "converted packed signed quadword integers to half-precision values by vcvtqq2ph",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtudq2ph",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtudq2ph_vector_fp16_convert",
                target_register = "rip",
                role = "converted packed unsigned doubleword integers to half-precision values by vcvtudq2ph",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvtuqq2ph",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvtuqq2ph_vector_fp16_convert",
                target_register = "rip",
                role = "converted packed unsigned quadword integers to half-precision values by vcvtuqq2ph",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttph2dq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvttph2dq_vector_fp16_convert",
                target_register = "rip",
                role = "converted packed half-precision values to signed doubleword integers with truncation by vcvttph2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttph2qq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvttph2qq_vector_fp16_convert",
                target_register = "rip",
                role = "converted packed half-precision values to signed quadword integers with truncation by vcvttph2qq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttph2udq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvttph2udq_vector_fp16_convert",
                target_register = "rip",
                role = "converted packed half-precision values to unsigned doubleword integers with truncation by vcvttph2udq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcvttph2uqq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vcvttph2uqq_vector_fp16_convert",
                target_register = "rip",
                role = "converted packed half-precision values to unsigned quadword integers with truncation by vcvttph2uqq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tilerelease",
            operands = {},
            effect = {
                kind = "register_write",
                name = "tilerelease_updates_tile_state",
                target_register = "rip",
                role = "released AMX tile state by tilerelease",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tilezero",
            operands = {
                { index = 1, role = "tile_destination" },
            },
            effect = {
                kind = "register_write",
                name = "tilezero_updates_tile_state",
                target_register = "rip",
                role = "zeroed AMX tile by tilezero",
            },
        }
,

    -- AMX tile load/store.
    
        {
            node_type = "instruction",
            mnemonic = "tileloadd",
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "memory" },
            },
            effect = {
                kind = "register_write",
                name = "tileloadd_updates_tile_state",
                target_register = "rip",
                role = "loaded AMX tile rows by tileloadd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tileloaddt1",
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "memory" },
            },
            effect = {
                kind = "register_write",
                name = "tileloaddt1_updates_tile_state",
                target_register = "rip",
                role = "loaded AMX tile rows with temporal hint by tileloaddt1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tilestored",
            operands = {
                { index = 1, role = "memory" },
                { index = 2, role = "tile_source" },
            },
            effect = {
                kind = "register_write",
                name = "tilestored_updates_tile_state",
                target_register = "rip",
                role = "stored AMX tile rows by tilestored",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tileloadd64",
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "memory" },
            },
            effect = {
                kind = "register_write",
                name = "tileloadd64_updates_tile_state",
                target_register = "rip",
                role = "loaded AMX tile rows in 64-bit form by tileloadd64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tilestored64",
            operands = {
                { index = 1, role = "memory" },
                { index = 2, role = "tile_source" },
            },
            effect = {
                kind = "register_write",
                name = "tilestored64_updates_tile_state",
                target_register = "rip",
                role = "stored AMX tile rows in 64-bit form by tilestored64",
            },
        }
,

    -- AVX-512 IFMA / integer fused multiply-add.
    
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

    -- AVX-512 BITALG / VPOPCNT / VP2INTERSECT.
    
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
            mnemonic = "vp2intersectd",
            operands = {
                { index = 1, role = "mask_destination_a" },
                { index = 2, role = "mask_destination_b" },
                { index = 3, role = "left" },
                { index = 4, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vp2intersectd_vector_intersect",
                target_register = "rip",
                role = "computed packed doubleword intersection masks by vp2intersectd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vp2intersectq",
            operands = {
                { index = 1, role = "mask_destination_a" },
                { index = 2, role = "mask_destination_b" },
                { index = 3, role = "left" },
                { index = 4, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vp2intersectq_vector_intersect",
                target_register = "rip",
                role = "computed packed quadword intersection masks by vp2intersectq",
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

    -- AVX-512 special floating-point math / rotate / variable-shift / accelerator visibility effects.
        -- Phase-one model: no vector register file yet, so vector-only effects are exposed as RIP-side activity.
    
        -- AVX-512 range / reduction helpers.
    
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

    -- AVX-512 exponent / mantissa helpers.
    
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

    -- AVX-512 fixup immediate helpers.
    
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

    -- AVX-512 reciprocal / reciprocal-square-root approximation helpers.
    
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

    -- AVX-512ER approximate math helpers.
    
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

    -- AVX-512 scale floating-point values.
    
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

    -- AVX-512 integer rotates.
    
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

    -- AVX-512 variable vector shifts.
    
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

    -- Rare AVX-512 accelerator helpers.
    
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

    -- SSE4 packed min/max extended forms.
    
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

    -- SSE4 packed sign/zero extension helpers.
    
        {
            node_type = "instruction",
            mnemonic = "pmovsxbw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmovsxbw_vector_extend",
                target_register = "rip",
                role = "sign-extended packed bytes to words by pmovsxbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovsxbd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmovsxbd_vector_extend",
                target_register = "rip",
                role = "sign-extended packed bytes to doublewords by pmovsxbd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovsxbq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmovsxbq_vector_extend",
                target_register = "rip",
                role = "sign-extended packed bytes to quadwords by pmovsxbq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovsxwd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmovsxwd_vector_extend",
                target_register = "rip",
                role = "sign-extended packed words to doublewords by pmovsxwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovsxwq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmovsxwq_vector_extend",
                target_register = "rip",
                role = "sign-extended packed words to quadwords by pmovsxwq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovsxdq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmovsxdq_vector_extend",
                target_register = "rip",
                role = "sign-extended packed doublewords to quadwords by pmovsxdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovzxbw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmovzxbw_vector_extend",
                target_register = "rip",
                role = "zero-extended packed bytes to words by pmovzxbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovzxbd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmovzxbd_vector_extend",
                target_register = "rip",
                role = "zero-extended packed bytes to doublewords by pmovzxbd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovzxbq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmovzxbq_vector_extend",
                target_register = "rip",
                role = "zero-extended packed bytes to quadwords by pmovzxbq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovzxwd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmovzxwd_vector_extend",
                target_register = "rip",
                role = "zero-extended packed words to doublewords by pmovzxwd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovzxwq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmovzxwq_vector_extend",
                target_register = "rip",
                role = "zero-extended packed words to quadwords by pmovzxwq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pmovzxdq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmovzxdq_vector_extend",
                target_register = "rip",
                role = "zero-extended packed doublewords to quadwords by pmovzxdq",
            },
        }
,

    -- SSE4 packed multiply / test helpers.
    
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

    {
            node_type = "instruction",
            mnemonic = "ptest",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "ptest_updates_rflags",
                target_register = "rflags",
                role = "updated by packed integer test ptest",
            },
        }
,

    -- SSE4 string / text comparison helpers.
        -- These affect implicit integer/vector state, flags, and string-comparison result state.
    
        {
            node_type = "instruction",
            mnemonic = "pcmpestri",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "left_length" },
                { index = 3, role = "right" },
                { index = 4, role = "right_length" },
                { index = 5, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpestri_updates_rcx",
                target_register = "rcx",
                role = "written with explicit-length string comparison index by pcmpestri",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpestri",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "left_length" },
                { index = 3, role = "right" },
                { index = 4, role = "right_length" },
                { index = 5, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpestri_updates_rflags",
                target_register = "rflags",
                role = "updated by explicit-length string comparison pcmpestri",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpestrm",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "left_length" },
                { index = 3, role = "right" },
                { index = 4, role = "right_length" },
                { index = 5, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpestrm_updates_mask_state",
                target_register = "rip",
                role = "produced explicit-length string comparison mask by pcmpestrm",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpestrm",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "left_length" },
                { index = 3, role = "right" },
                { index = 4, role = "right_length" },
                { index = 5, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpestrm_updates_rflags",
                target_register = "rflags",
                role = "updated by explicit-length string comparison mask pcmpestrm",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpistri",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
                { index = 3, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpistri_updates_rcx",
                target_register = "rcx",
                role = "written with implicit-length string comparison index by pcmpistri",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpistri",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
                { index = 3, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpistri_updates_rflags",
                target_register = "rflags",
                role = "updated by implicit-length string comparison pcmpistri",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpistrm",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
                { index = 3, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpistrm_updates_mask_state",
                target_register = "rip",
                role = "produced implicit-length string comparison mask by pcmpistrm",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pcmpistrm",
            operands = {
                { index = 1, role = "left" },
                { index = 2, role = "right" },
                { index = 3, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "pcmpistrm_updates_rflags",
                target_register = "rflags",
                role = "updated by implicit-length string comparison mask pcmpistrm",
            },
        }
,

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
