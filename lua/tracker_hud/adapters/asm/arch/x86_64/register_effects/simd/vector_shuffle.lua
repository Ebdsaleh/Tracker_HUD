-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/vector_shuffle.lua

-- x86-64 SIMD register effect specs: vector shuffle.

return {
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

}

