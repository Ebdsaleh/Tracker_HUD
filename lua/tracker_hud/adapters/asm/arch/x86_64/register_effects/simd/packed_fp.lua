-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/packed_fp.lua

-- x86-64 SIMD register effect specs: packed fp.

return {
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

}
