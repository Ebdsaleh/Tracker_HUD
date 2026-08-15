-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/arithmetic.lua
--
-- x86-64 arithmetic register effect specs.
--
-- Remaining legacy records not yet migrated into the categorized
-- Tree-sitter-first register-effect modules.

return {

    {
                node_type = "instruction",
                mnemonic = "addps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "addps_simd_arithmetic",
                    target_register = "rip",
                    role = "added packed single-precision values by addps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "addpd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "addpd_simd_arithmetic",
                    target_register = "rip",
                    role = "added packed double-precision values by addpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "addss",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "addss_scalar_simd_arithmetic",
                    target_register = "rip",
                    role = "added scalar single-precision values by addss",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "addsd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "addsd_scalar_simd_arithmetic",
                    target_register = "rip",
                    role = "added scalar double-precision values by addsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "subps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "subps_simd_arithmetic",
                    target_register = "rip",
                    role = "subtracted packed single-precision values by subps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "subpd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "subpd_simd_arithmetic",
                    target_register = "rip",
                    role = "subtracted packed double-precision values by subpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "subss",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "subss_scalar_simd_arithmetic",
                    target_register = "rip",
                    role = "subtracted scalar single-precision values by subss",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "subsd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "subsd_scalar_simd_arithmetic",
                    target_register = "rip",
                    role = "subtracted scalar double-precision values by subsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "mulps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "mulps_simd_arithmetic",
                    target_register = "rip",
                    role = "multiplied packed single-precision values by mulps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "mulpd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "mulpd_simd_arithmetic",
                    target_register = "rip",
                    role = "multiplied packed double-precision values by mulpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "mulss",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "mulss_scalar_simd_arithmetic",
                    target_register = "rip",
                    role = "multiplied scalar single-precision values by mulss",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "mulsd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "mulsd_scalar_simd_arithmetic",
                    target_register = "rip",
                    role = "multiplied scalar double-precision values by mulsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "divps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "divps_simd_arithmetic",
                    target_register = "rip",
                    role = "divided packed single-precision values by divps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "divpd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "divpd_simd_arithmetic",
                    target_register = "rip",
                    role = "divided packed double-precision values by divpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "divss",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "divss_scalar_simd_arithmetic",
                    target_register = "rip",
                    role = "divided scalar single-precision values by divss",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "divsd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "divsd_scalar_simd_arithmetic",
                    target_register = "rip",
                    role = "divided scalar double-precision values by divsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "addsubps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "addsubps_vector_arithmetic",
                    target_register = "rip",
                    role = "alternating added and subtracted packed single-precision values by addsubps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "addsubpd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "addsubpd_vector_arithmetic",
                    target_register = "rip",
                    role = "alternating added and subtracted packed double-precision values by addsubpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "addss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "addss_scalar_fp_add",
                    target_register = "rip",
                    role = "performed scalar single-precision add by addss",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "addsd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "addsd_scalar_fp_add",
                    target_register = "rip",
                    role = "performed scalar double-precision add by addsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "subss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "subss_scalar_fp_subtract",
                    target_register = "rip",
                    role = "performed scalar single-precision subtract by subss",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "subsd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "subsd_scalar_fp_subtract",
                    target_register = "rip",
                    role = "performed scalar double-precision subtract by subsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "mulss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "mulss_scalar_fp_multiply",
                    target_register = "rip",
                    role = "performed scalar single-precision multiply by mulss",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "mulsd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "mulsd_scalar_fp_multiply",
                    target_register = "rip",
                    role = "performed scalar double-precision multiply by mulsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "divss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "divss_scalar_fp_divide",
                    target_register = "rip",
                    role = "performed scalar single-precision divide by divss",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "divsd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "divsd_scalar_fp_divide",
                    target_register = "rip",
                    role = "performed scalar double-precision divide by divsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "addps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "addps_packed_fp_add",
                    target_register = "rip",
                    role = "performed packed single-precision add by addps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "addpd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "addpd_packed_fp_add",
                    target_register = "rip",
                    role = "performed packed double-precision add by addpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "subps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "subps_packed_fp_subtract",
                    target_register = "rip",
                    role = "performed packed single-precision subtract by subps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "subpd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "subpd_packed_fp_subtract",
                    target_register = "rip",
                    role = "performed packed double-precision subtract by subpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "mulps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "mulps_packed_fp_multiply",
                    target_register = "rip",
                    role = "performed packed single-precision multiply by mulps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "mulpd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "mulpd_packed_fp_multiply",
                    target_register = "rip",
                    role = "performed packed double-precision multiply by mulpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "divps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "divps_packed_fp_divide",
                    target_register = "rip",
                    role = "performed packed single-precision divide by divps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "divpd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "divpd_packed_fp_divide",
                    target_register = "rip",
                    role = "performed packed double-precision divide by divpd",
                },
            },

}

