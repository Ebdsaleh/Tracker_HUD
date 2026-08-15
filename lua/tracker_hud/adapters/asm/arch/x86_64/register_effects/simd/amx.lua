-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/amx.lua
--
-- Remaining legacy SIMD/AVX-512 register-effect specs formerly grouped under amx.
--
-- Mask-register K* rules have migrated to register_effects/mask/.
-- Genuine AMX tile rules migrated previously to register_effects/amx/.
-- The remaining entries are retained here until the vector migration.

return {
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
