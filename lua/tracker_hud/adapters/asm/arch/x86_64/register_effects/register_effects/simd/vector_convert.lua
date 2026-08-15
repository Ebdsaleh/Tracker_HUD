-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/vector_convert.lua
--
-- x86-64 legacy vector register effects formerly grouped under convert.
--
-- Temporary legacy compatibility during the Tree-sitter-first migration.
-- Only records not yet moved into categorized modules remain here.

return {

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

}
