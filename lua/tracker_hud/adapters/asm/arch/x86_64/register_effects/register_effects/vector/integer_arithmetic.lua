-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/vector/integer_arithmetic.lua
--
-- x86-64 register effects: vector / integer arithmetic.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies instruction syntax first; operand/effect data
-- describes the x86-64 semantic effects consumed by Tracker_HUD.

return {
    ["mpsadbw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "mpsadbw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "mpsadbw_simd_integer_sad",
                target_register = "rip",
                role = "computed multiple packed byte sums of absolute differences by mpsadbw",
            },
        },
    },

    ["vpconflictd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpconflictd",
                    },
                },
            },

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
        },
    },

    ["vpconflictq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpconflictq",
                    },
                },
            },

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
        },
    },

    ["vplzcntd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vplzcntd",
                    },
                },
            },

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
        },
    },

    ["vplzcntq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vplzcntq",
                    },
                },
            },

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
        },
    },

    ["vpdpbusd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpdpbusd",
                    },
                },
            },

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
        },
    },

    ["vpdpbusds"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpdpbusds",
                    },
                },
            },

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
        },
    },

    ["vpdpwssd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpdpwssd",
                    },
                },
            },

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
        },
    },

    ["vpdpwssds"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpdpwssds",
                    },
                },
            },

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
        },
    },

    ["vpmadd52luq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmadd52luq",
                    },
                },
            },

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
        },
    },

    ["vpmadd52huq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmadd52huq",
                    },
                },
            },

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
        },
    },

    ["vpopcntb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpopcntb",
                    },
                },
            },

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
        },
    },

    ["vpopcntw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpopcntw",
                    },
                },
            },

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
        },
    },

    ["vpopcntd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpopcntd",
                    },
                },
            },

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
        },
    },

    ["vpopcntq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpopcntq",
                    },
                },
            },

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
        },
    },

    ["vpmultishiftqb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmultishiftqb",
                    },
                },
            },

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
        },
    },

    ["vprold"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprold",
                    },
                },
            },

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
        },
    },

    ["vprolq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprolq",
                    },
                },
            },

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
        },
    },

    ["vprord"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprord",
                    },
                },
            },

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
        },
    },

    ["vprorq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprorq",
                    },
                },
            },

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
        },
    },

    ["vprolvd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprolvd",
                    },
                },
            },

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
        },
    },

    ["vprolvq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprolvq",
                    },
                },
            },

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
        },
    },

    ["vprorvd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprorvd",
                    },
                },
            },

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
        },
    },

    ["vprorvq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprorvq",
                    },
                },
            },

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
        },
    },

    ["vpsllvw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsllvw",
                    },
                },
            },

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
        },
    },

    ["vpsllvd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsllvd",
                    },
                },
            },

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
        },
    },

    ["vpsllvq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsllvq",
                    },
                },
            },

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
        },
    },

    ["vpsrlvw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsrlvw",
                    },
                },
            },

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
        },
    },

    ["vpsrlvd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsrlvd",
                    },
                },
            },

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
        },
    },

    ["vpsrlvq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsrlvq",
                    },
                },
            },

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
        },
    },

    ["vpsravw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsravw",
                    },
                },
            },

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
        },
    },

    ["vpsravd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsravd",
                    },
                },
            },

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
        },
    },

    ["vpsravq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsravq",
                    },
                },
            },

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
        },
    },

    ["vp4dpwssd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vp4dpwssd",
                    },
                },
            },

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
        },
    },

    ["vp4dpwssds"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vp4dpwssds",
                    },
                },
            },

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
        },
    },

    ["pminsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pminsb",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pminsb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pminsb_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed signed byte minimums by pminsb",
            },
        },
    },

    ["pminsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pminsd",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pminsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pminsd_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed signed doubleword minimums by pminsd",
            },
        },
    },

    ["pminuw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pminuw",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pminuw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pminuw_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned word minimums by pminuw",
            },
        },
    },

    ["pminud"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pminud",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pminud",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pminud_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned doubleword minimums by pminud",
            },
        },
    },

    ["pmaxsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmaxsb",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmaxsb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaxsb_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed signed byte maximums by pmaxsb",
            },
        },
    },

    ["pmaxsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmaxsd",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmaxsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaxsd_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed signed doubleword maximums by pmaxsd",
            },
        },
    },

    ["pmaxuw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmaxuw",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmaxuw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaxuw_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned word maximums by pmaxuw",
            },
        },
    },

    ["pmaxud"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmaxud",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmaxud",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaxud_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned doubleword maximums by pmaxud",
            },
        },
    },

    ["pmuldq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmuldq",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmuldq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmuldq_simd_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed doublewords to quadwords by pmuldq",
            },
        },
    },

    ["pmulld"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmulld",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmulld",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmulld_simd_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed doublewords low by pmulld",
            },
        },
    },

    ["paddb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddb_simd_integer_add",
                target_register = "rip",
                role = "added packed byte integers by paddb",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddb",
                    },
                },
            },

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
        },
    },

    ["paddw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddw_simd_integer_add",
                target_register = "rip",
                role = "added packed word integers by paddw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddw",
                    },
                },
            },

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
        },
    },

    ["paddd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddd_simd_integer_add",
                target_register = "rip",
                role = "added packed doubleword integers by paddd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddd",
                    },
                },
            },

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
        },
    },

    ["paddq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddq_simd_integer_add",
                target_register = "rip",
                role = "added packed quadword integers by paddq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddq",
                    },
                },
            },

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
        },
    },

    ["paddsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddsb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddsb_simd_integer_add",
                target_register = "rip",
                role = "saturating-added packed signed bytes by paddsb",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddsb",
                    },
                },
            },

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
        },
    },

    ["paddsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddsw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddsw_simd_integer_add",
                target_register = "rip",
                role = "saturating-added packed signed words by paddsw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddsw",
                    },
                },
            },

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
        },
    },

    ["paddusb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddusb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddusb_simd_integer_add",
                target_register = "rip",
                role = "saturating-added packed unsigned bytes by paddusb",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddusb",
                    },
                },
            },

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
        },
    },

    ["paddusw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddusw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "paddusw_simd_integer_add",
                target_register = "rip",
                role = "saturating-added packed unsigned words by paddusw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "paddusw",
                    },
                },
            },

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
        },
    },

    ["psubb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubb_simd_integer_subtract",
                target_register = "rip",
                role = "subtracted packed byte integers by psubb",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubb",
                    },
                },
            },

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
        },
    },

    ["psubw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubw_simd_integer_subtract",
                target_register = "rip",
                role = "subtracted packed word integers by psubw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubw",
                    },
                },
            },

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
        },
    },

    ["psubd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubd_simd_integer_subtract",
                target_register = "rip",
                role = "subtracted packed doubleword integers by psubd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubd",
                    },
                },
            },

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
        },
    },

    ["psubq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubq_simd_integer_subtract",
                target_register = "rip",
                role = "subtracted packed quadword integers by psubq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubq",
                    },
                },
            },

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
        },
    },

    ["psubsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubsb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubsb_simd_integer_subtract",
                target_register = "rip",
                role = "saturating-subtracted packed signed bytes by psubsb",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubsb",
                    },
                },
            },

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
        },
    },

    ["psubsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubsw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubsw_simd_integer_subtract",
                target_register = "rip",
                role = "saturating-subtracted packed signed words by psubsw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubsw",
                    },
                },
            },

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
        },
    },

    ["psubusb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubusb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubusb_simd_integer_subtract",
                target_register = "rip",
                role = "saturating-subtracted packed unsigned bytes by psubusb",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubusb",
                    },
                },
            },

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
        },
    },

    ["psubusw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubusw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psubusw_simd_integer_subtract",
                target_register = "rip",
                role = "saturating-subtracted packed unsigned words by psubusw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psubusw",
                    },
                },
            },

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
        },
    },

    ["pmullw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmullw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmullw_simd_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed words low by pmullw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmullw",
                    },
                },
            },

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
        },
    },

    ["pmulhw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmulhw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmulhw_simd_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed words high by pmulhw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmulhw",
                    },
                },
            },

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
        },
    },

    ["pmulhuw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmulhuw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmulhuw_simd_integer_multiply",
                target_register = "rip",
                role = "multiplied packed unsigned words high by pmulhuw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmulhuw",
                    },
                },
            },

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
        },
    },

    ["pmuludq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmuludq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmuludq_simd_integer_multiply",
                target_register = "rip",
                role = "multiplied packed unsigned doublewords to quadwords by pmuludq",
            },
        },
    },

    ["pmaddwd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmaddwd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaddwd_simd_integer_multiply_add",
                target_register = "rip",
                role = "multiply-added packed words to doublewords by pmaddwd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmaddwd",
                    },
                },
            },

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
        },
    },

    ["pmaddubsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmaddubsw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaddubsw_simd_integer_multiply_add",
                target_register = "rip",
                role = "multiply-added packed unsigned bytes and signed bytes by pmaddubsw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmaddubsw",
                    },
                },
            },

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
        },
    },

    ["pavgb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pavgb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pavgb_simd_integer_average",
                target_register = "rip",
                role = "averaged packed unsigned bytes by pavgb",
            },
        },
    },

    ["pavgw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pavgw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pavgw_simd_integer_average",
                target_register = "rip",
                role = "averaged packed unsigned words by pavgw",
            },
        },
    },

    ["pabsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pabsb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pabsb_simd_integer_absolute",
                target_register = "rip",
                role = "absolute-valued packed signed bytes by pabsb",
            },
        },
    },

    ["pabsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pabsw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pabsw_simd_integer_absolute",
                target_register = "rip",
                role = "absolute-valued packed signed words by pabsw",
            },
        },
    },

    ["pabsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pabsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pabsd_simd_integer_absolute",
                target_register = "rip",
                role = "absolute-valued packed signed doublewords by pabsd",
            },
        },
    },

    ["psignb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psignb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psignb_simd_integer_sign",
                target_register = "rip",
                role = "applied packed byte signs by psignb",
            },
        },
    },

    ["psignw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psignw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psignw_simd_integer_sign",
                target_register = "rip",
                role = "applied packed word signs by psignw",
            },
        },
    },

    ["psignd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psignd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psignd_simd_integer_sign",
                target_register = "rip",
                role = "applied packed doubleword signs by psignd",
            },
        },
    },

    ["pminub"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pminub",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pminub_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned byte minimums by pminub",
            },
        },
    },

    ["pminsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pminsw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pminsw_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed signed word minimums by pminsw",
            },
        },
    },

    ["pmaxub"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmaxub",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaxub_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned byte maximums by pmaxub",
            },
        },
    },

    ["pmaxsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmaxsw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmaxsw_simd_integer_minmax",
                target_register = "rip",
                role = "selected packed signed word maximums by pmaxsw",
            },
        },
    },

    ["psllw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psllw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psllw_simd_integer_shift",
                target_register = "rip",
                role = "shifted packed words left by psllw",
            },
        },
    },

    ["pslld"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pslld",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "pslld_simd_integer_shift",
                target_register = "rip",
                role = "shifted packed doublewords left by pslld",
            },
        },
    },

    ["psllq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psllq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psllq_simd_integer_shift",
                target_register = "rip",
                role = "shifted packed quadwords left by psllq",
            },
        },
    },

    ["psrlw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psrlw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psrlw_simd_integer_shift",
                target_register = "rip",
                role = "logically shifted packed words right by psrlw",
            },
        },
    },

    ["psrld"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psrld",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psrld_simd_integer_shift",
                target_register = "rip",
                role = "logically shifted packed doublewords right by psrld",
            },
        },
    },

    ["psrlq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psrlq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psrlq_simd_integer_shift",
                target_register = "rip",
                role = "logically shifted packed quadwords right by psrlq",
            },
        },
    },

    ["psraw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psraw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psraw_simd_integer_shift",
                target_register = "rip",
                role = "arithmetically shifted packed words right by psraw",
            },
        },
    },

    ["psrad"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psrad",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psrad_simd_integer_shift",
                target_register = "rip",
                role = "arithmetically shifted packed doublewords right by psrad",
            },
        },
    },

    ["pslldq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pslldq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "pslldq_simd_integer_shift",
                target_register = "rip",
                role = "shifted packed double-quadword left by pslldq",
            },
        },
    },

    ["psrldq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psrldq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
            effect = {
                kind = "register_write",
                name = "psrldq_simd_integer_shift",
                target_register = "rip",
                role = "shifted packed double-quadword right by psrldq",
            },
        },
    },

    ["psadbw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "psadbw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "psadbw_simd_integer_sad",
                target_register = "rip",
                role = "computed packed byte sum of absolute differences by psadbw",
            },
        },
    },

    ["phaddw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "phaddw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "phaddw_simd_integer_horizontal",
                target_register = "rip",
                role = "horizontally added packed words by phaddw",
            },
        },
    },

    ["phaddd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "phaddd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "phaddd_simd_integer_horizontal",
                target_register = "rip",
                role = "horizontally added packed doublewords by phaddd",
            },
        },
    },

    ["phaddsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "phaddsw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "phaddsw_simd_integer_horizontal",
                target_register = "rip",
                role = "horizontally saturating-added packed signed words by phaddsw",
            },
        },
    },

    ["phsubw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "phsubw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "phsubw_simd_integer_horizontal",
                target_register = "rip",
                role = "horizontally subtracted packed words by phsubw",
            },
        },
    },

    ["phsubd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "phsubd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "phsubd_simd_integer_horizontal",
                target_register = "rip",
                role = "horizontally subtracted packed doublewords by phsubd",
            },
        },
    },

    ["phsubsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "phsubsw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "phsubsw_simd_integer_horizontal",
                target_register = "rip",
                role = "horizontally saturating-subtracted packed signed words by phsubsw",
            },
        },
    },

    ["vpaddb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpaddb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpaddb_vector_integer_add",
                target_register = "rip",
                role = "added packed byte integers by vpaddb",
            },
        },
    },

    ["vpaddw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpaddw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpaddw_vector_integer_add",
                target_register = "rip",
                role = "added packed word integers by vpaddw",
            },
        },
    },

    ["vpaddd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpaddd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpaddd_vector_integer_add",
                target_register = "rip",
                role = "added packed doubleword integers by vpaddd",
            },
        },
    },

    ["vpaddq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpaddq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpaddq_vector_integer_add",
                target_register = "rip",
                role = "added packed quadword integers by vpaddq",
            },
        },
    },

    ["vpsubb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsubb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpsubb_vector_integer_subtract",
                target_register = "rip",
                role = "subtracted packed byte integers by vpsubb",
            },
        },
    },

    ["vpsubw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsubw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpsubw_vector_integer_subtract",
                target_register = "rip",
                role = "subtracted packed word integers by vpsubw",
            },
        },
    },

    ["vpsubd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsubd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpsubd_vector_integer_subtract",
                target_register = "rip",
                role = "subtracted packed doubleword integers by vpsubd",
            },
        },
    },

    ["vpsubq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsubq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpsubq_vector_integer_subtract",
                target_register = "rip",
                role = "subtracted packed quadword integers by vpsubq",
            },
        },
    },

    ["vpmullw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmullw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmullw_vector_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed words low by vpmullw",
            },
        },
    },

    ["vpmulhw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmulhw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmulhw_vector_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed words high by vpmulhw",
            },
        },
    },

    ["vpmulhuw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmulhuw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmulhuw_vector_integer_multiply",
                target_register = "rip",
                role = "multiplied packed unsigned words high by vpmulhuw",
            },
        },
    },

    ["vpmulld"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmulld",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmulld_vector_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed doublewords low by vpmulld",
            },
        },
    },

    ["vpmuldq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmuldq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmuldq_vector_integer_multiply",
                target_register = "rip",
                role = "multiplied packed signed doublewords to quadwords by vpmuldq",
            },
        },
    },

    ["vpmuludq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmuludq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmuludq_vector_integer_multiply",
                target_register = "rip",
                role = "multiplied packed unsigned doublewords to quadwords by vpmuludq",
            },
        },
    },

    ["vpmaddwd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmaddwd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaddwd_vector_integer_multiply_add",
                target_register = "rip",
                role = "multiply-added packed words to doublewords by vpmaddwd",
            },
        },
    },

    ["vpmaddubsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmaddubsw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaddubsw_vector_integer_multiply_add",
                target_register = "rip",
                role = "multiply-added packed unsigned bytes and signed bytes by vpmaddubsw",
            },
        },
    },

    ["vpminub"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpminub",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpminub_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned byte minimums by vpminub",
            },
        },
    },

    ["vpminuw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpminuw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpminuw_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned word minimums by vpminuw",
            },
        },
    },

    ["vpminud"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpminud",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpminud_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned doubleword minimums by vpminud",
            },
        },
    },

    ["vpminsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpminsb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpminsb_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed signed byte minimums by vpminsb",
            },
        },
    },

    ["vpminsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpminsw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpminsw_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed signed word minimums by vpminsw",
            },
        },
    },

    ["vpminsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpminsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpminsd_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed signed doubleword minimums by vpminsd",
            },
        },
    },

    ["vpmaxub"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmaxub",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaxub_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned byte maximums by vpmaxub",
            },
        },
    },

    ["vpmaxuw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmaxuw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaxuw_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned word maximums by vpmaxuw",
            },
        },
    },

    ["vpmaxud"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmaxud",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaxud_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed unsigned doubleword maximums by vpmaxud",
            },
        },
    },

    ["vpmaxsb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmaxsb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaxsb_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed signed byte maximums by vpmaxsb",
            },
        },
    },

    ["vpmaxsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmaxsw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaxsw_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed signed word maximums by vpmaxsw",
            },
        },
    },

    ["vpmaxsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmaxsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpmaxsd_vector_integer_minmax",
                target_register = "rip",
                role = "selected packed signed doubleword maximums by vpmaxsd",
            },
        },
    },

    ["vpsllw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsllw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsllw_vector_integer_shift",
                target_register = "rip",
                role = "shifted packed words left by vpsllw",
            },
        },
    },

    ["vpslld"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpslld",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpslld_vector_integer_shift",
                target_register = "rip",
                role = "shifted packed doublewords left by vpslld",
            },
        },
    },

    ["vpsllq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsllq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsllq_vector_integer_shift",
                target_register = "rip",
                role = "shifted packed quadwords left by vpsllq",
            },
        },
    },

    ["vpsrlw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsrlw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsrlw_vector_integer_shift",
                target_register = "rip",
                role = "logically shifted packed words right by vpsrlw",
            },
        },
    },

    ["vpsrld"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsrld",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsrld_vector_integer_shift",
                target_register = "rip",
                role = "logically shifted packed doublewords right by vpsrld",
            },
        },
    },

    ["vpsrlq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsrlq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsrlq_vector_integer_shift",
                target_register = "rip",
                role = "logically shifted packed quadwords right by vpsrlq",
            },
        },
    },

    ["vpsraw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsraw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsraw_vector_integer_shift",
                target_register = "rip",
                role = "arithmetically shifted packed words right by vpsraw",
            },
        },
    },

    ["vpsrad"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsrad",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsrad_vector_integer_shift",
                target_register = "rip",
                role = "arithmetically shifted packed doublewords right by vpsrad",
            },
        },
    },

    ["vpslldq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpslldq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpslldq_vector_integer_shift",
                target_register = "rip",
                role = "shifted packed double-quadword left by vpslldq",
            },
        },
    },

    ["vpsrldq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpsrldq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpsrldq_vector_integer_shift",
                target_register = "rip",
                role = "shifted packed double-quadword right by vpsrldq",
            },
        },
    },

    ["vpmacsdd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmacsdd",
                    },
                },
            },

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
        },
    },

    ["vpmacsdqh"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmacsdqh",
                    },
                },
            },

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
        },
    },

    ["vpmacsdql"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmacsdql",
                    },
                },
            },

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
        },
    },

    ["vpmacssdd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmacssdd",
                    },
                },
            },

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
        },
    },

    ["vpmacsswd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmacsswd",
                    },
                },
            },

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
        },
    },

    ["vpmacssww"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmacssww",
                    },
                },
            },

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
        },
    },

    ["vpmacswd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmacswd",
                    },
                },
            },

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
        },
    },

    ["vpmacsww"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmacsww",
                    },
                },
            },

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
        },
    },

    ["vpmadcsswd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmadcsswd",
                    },
                },
            },

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
        },
    },

    ["vpmadcswd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmadcswd",
                    },
                },
            },

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
        },
    },

    ["vphaddbd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphaddbd",
                    },
                },
            },

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
        },
    },

    ["vphaddbq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphaddbq",
                    },
                },
            },

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
        },
    },

    ["vphaddbw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphaddbw",
                    },
                },
            },

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
        },
    },

    ["vphadddq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphadddq",
                    },
                },
            },

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
        },
    },

    ["vphaddubd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphaddubd",
                    },
                },
            },

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
        },
    },

    ["vphaddubq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphaddubq",
                    },
                },
            },

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
        },
    },

    ["vphaddubw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphaddubw",
                    },
                },
            },

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
        },
    },

    ["vphaddudq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphaddudq",
                    },
                },
            },

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
        },
    },

    ["vphadduwd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphadduwd",
                    },
                },
            },

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
        },
    },

    ["vphadduwq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphadduwq",
                    },
                },
            },

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
        },
    },

    ["vphaddwd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphaddwd",
                    },
                },
            },

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
        },
    },

    ["vphaddwq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphaddwq",
                    },
                },
            },

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
        },
    },

    ["vphsubbw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphsubbw",
                    },
                },
            },

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
        },
    },

    ["vphsubdq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphsubdq",
                    },
                },
            },

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
        },
    },

    ["vphsubwd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vphsubwd",
                    },
                },
            },

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
        },
    },

    ["vprotbi"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprotbi",
                    },
                },
            },

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
        },
    },

    ["vprotdi"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprotdi",
                    },
                },
            },

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
        },
    },

    ["vprotqi"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprotqi",
                    },
                },
            },

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
        },
    },

    ["vprotwi"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprotwi",
                    },
                },
            },

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
        },
    },

    ["vprotb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprotb",
                    },
                },
            },

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
        },
    },

    ["vprotd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprotd",
                    },
                },
            },

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
        },
    },

    ["vprotq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprotq",
                    },
                },
            },

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
        },
    },

    ["vprotw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vprotw",
                    },
                },
            },

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
        },
    },

    ["pavgusb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pavgusb",
                    },
                },
            },

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
        },
    },

    ["pmulhrw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmulhrw",
                    },
                },
            },

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
        },
    },

    ["vpshldw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshldw",
                    },
                },
            },

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
        },
    },

    ["vpshldd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshldd",
                    },
                },
            },

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
        },
    },

    ["vpshldq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshldq",
                    },
                },
            },

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
        },
    },

    ["vpshrdw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshrdw",
                    },
                },
            },

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
        },
    },

    ["vpshrdd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshrdd",
                    },
                },
            },

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
        },
    },

    ["vpshrdq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshrdq",
                    },
                },
            },

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
        },
    },

    ["vpshldvw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshldvw",
                    },
                },
            },

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
        },
    },

    ["vpshldvd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshldvd",
                    },
                },
            },

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
        },
    },

    ["vpshldvq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshldvq",
                    },
                },
            },

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
        },
    },

    ["vpshrdvw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshrdvw",
                    },
                },
            },

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
        },
    },

    ["vpshrdvd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshrdvd",
                    },
                },
            },

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
        },
    },

    ["vpshrdvq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshrdvq",
                    },
                },
            },

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
        },
    },

}
