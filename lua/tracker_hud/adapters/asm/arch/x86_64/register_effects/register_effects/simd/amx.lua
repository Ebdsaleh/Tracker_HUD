-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/amx.lua
--
-- x86-64 legacy SIMD/AVX-512 register effects formerly grouped under AMX.
--
-- Temporary legacy compatibility during the Tree-sitter-first migration.
-- Only records not yet moved into categorized modules remain here.

return {

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

}
