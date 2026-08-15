-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/vector/shuffle_permute.lua
--
-- x86-64 register effects: vector / shuffle permute.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies instruction syntax first; operand/effect data
-- describes the x86-64 semantic effects consumed by Tracker_HUD.

return {
    ["blendps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "blendps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "blendps_vector_blend",
                target_register = "rip",
                role = "blended packed single-precision values by blendps",
            },
        },
    },

    ["blendpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "blendpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "blendpd_vector_blend",
                target_register = "rip",
                role = "blended packed double-precision values by blendpd",
            },
        },
    },

    ["blendvps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "blendvps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blendvps_vector_blend",
                target_register = "rip",
                role = "variable-blended packed single-precision values by blendvps",
            },
        },
    },

    ["blendvpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "blendvpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blendvpd_vector_blend",
                target_register = "rip",
                role = "variable-blended packed double-precision values by blendvpd",
            },
        },
    },

    ["vpermb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermb",
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
                name = "vpermb_vector_permute",
                target_register = "rip",
                role = "permuted packed bytes by vpermb",
            },
        },
    },

    ["vpermw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermw",
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
                name = "vpermw_vector_permute",
                target_register = "rip",
                role = "permuted packed words by vpermw",
            },
        },
    },

    ["vpermd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermd",
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
                name = "vpermd_vector_permute",
                target_register = "rip",
                role = "permuted packed doublewords by vpermd",
            },
        },
    },

    ["vpermq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermq",
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
                name = "vpermq_vector_permute",
                target_register = "rip",
                role = "permuted packed quadwords by vpermq",
            },
        },
    },

    ["vpermi2b"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermi2b",
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
                name = "vpermi2b_vector_permute",
                target_register = "rip",
                role = "permuted packed bytes using two sources by vpermi2b",
            },
        },
    },

    ["vpermi2w"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermi2w",
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
                name = "vpermi2w_vector_permute",
                target_register = "rip",
                role = "permuted packed words using two sources by vpermi2w",
            },
        },
    },

    ["vpermi2d"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermi2d",
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
                name = "vpermi2d_vector_permute",
                target_register = "rip",
                role = "permuted packed doublewords using two sources by vpermi2d",
            },
        },
    },

    ["vpermi2q"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermi2q",
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
                name = "vpermi2q_vector_permute",
                target_register = "rip",
                role = "permuted packed quadwords using two sources by vpermi2q",
            },
        },
    },

    ["vpermt2b"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermt2b",
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
                name = "vpermt2b_vector_permute",
                target_register = "rip",
                role = "permuted packed bytes into second table by vpermt2b",
            },
        },
    },

    ["vpermt2w"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermt2w",
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
                name = "vpermt2w_vector_permute",
                target_register = "rip",
                role = "permuted packed words into second table by vpermt2w",
            },
        },
    },

    ["vpermt2d"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermt2d",
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
                name = "vpermt2d_vector_permute",
                target_register = "rip",
                role = "permuted packed doublewords into second table by vpermt2d",
            },
        },
    },

    ["vpermt2q"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermt2q",
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
                name = "vpermt2q_vector_permute",
                target_register = "rip",
                role = "permuted packed quadwords into second table by vpermt2q",
            },
        },
    },

    ["vpshufbitqmb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshufbitqmb",
                    },
                },
            },

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
        },
    },

    ["pblendw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pblendw",
                    },
                },
            },

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
        },
    },

    ["pblendvb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pblendvb",
                    },
                },
            },

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
        },
    },

    ["shufps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "shufps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "shufps_simd_shuffle",
                target_register = "rip",
                role = "shuffled packed single-precision values by shufps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "shufps",
                    },
                },
            },

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
        },
    },

    ["shufpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "shufpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "shufpd_simd_shuffle",
                target_register = "rip",
                role = "shuffled packed double-precision values by shufpd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "shufpd",
                    },
                },
            },

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
        },
    },

    ["unpckhps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "unpckhps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "unpckhps_simd_unpack",
                target_register = "rip",
                role = "unpacked high packed single-precision values by unpckhps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "unpckhps",
                    },
                },
            },

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
        },
    },

    ["unpcklps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "unpcklps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "unpcklps_simd_unpack",
                target_register = "rip",
                role = "unpacked low packed single-precision values by unpcklps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "unpcklps",
                    },
                },
            },

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
        },
    },

    ["unpckhpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "unpckhpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "unpckhpd_simd_unpack",
                target_register = "rip",
                role = "unpacked high packed double-precision values by unpckhpd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "unpckhpd",
                    },
                },
            },

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
        },
    },

    ["unpcklpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "unpcklpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "unpcklpd_simd_unpack",
                target_register = "rip",
                role = "unpacked low packed double-precision values by unpcklpd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "unpcklpd",
                    },
                },
            },

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
        },
    },

    ["punpcklbw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpcklbw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpcklbw_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked low packed bytes by punpcklbw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpcklbw",
                    },
                },
            },

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
        },
    },

    ["punpcklwd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpcklwd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpcklwd_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked low packed words by punpcklwd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpcklwd",
                    },
                },
            },

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
        },
    },

    ["punpckldq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpckldq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpckldq_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked low packed doublewords by punpckldq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpckldq",
                    },
                },
            },

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
        },
    },

    ["punpcklqdq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpcklqdq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpcklqdq_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked low packed quadwords by punpcklqdq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpcklqdq",
                    },
                },
            },

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
        },
    },

    ["punpckhbw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpckhbw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpckhbw_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked high packed bytes by punpckhbw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpckhbw",
                    },
                },
            },

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
        },
    },

    ["punpckhwd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpckhwd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpckhwd_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked high packed words by punpckhwd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpckhwd",
                    },
                },
            },

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
        },
    },

    ["punpckhdq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpckhdq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpckhdq_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked high packed doublewords by punpckhdq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpckhdq",
                    },
                },
            },

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
        },
    },

    ["punpckhqdq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpckhqdq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "punpckhqdq_simd_integer_unpack",
                target_register = "rip",
                role = "unpacked high packed quadwords by punpckhqdq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "punpckhqdq",
                    },
                },
            },

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
        },
    },

    ["pshufd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pshufd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "pshufd_simd_integer_shuffle",
                target_register = "rip",
                role = "shuffled packed doublewords by pshufd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pshufd",
                    },
                },
            },

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
        },
    },

    ["pshufhw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pshufhw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "pshufhw_simd_integer_shuffle",
                target_register = "rip",
                role = "shuffled high packed words by pshufhw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pshufhw",
                    },
                },
            },

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
        },
    },

    ["pshuflw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pshuflw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "pshuflw_simd_integer_shuffle",
                target_register = "rip",
                role = "shuffled low packed words by pshuflw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pshuflw",
                    },
                },
            },

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
        },
    },

    ["pshufb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pshufb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pshufb_simd_integer_shuffle",
                target_register = "rip",
                role = "byte-shuffled packed integer lanes by pshufb",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pshufb",
                    },
                },
            },

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
        },
    },

    ["palignr"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "palignr",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
            effect = {
                kind = "register_write",
                name = "palignr_simd_integer_align",
                target_register = "rip",
                role = "aligned packed bytes by palignr",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "palignr",
                    },
                },
            },

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
        },
    },

    ["vpshufd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshufd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vpshufd_vector_shuffle",
                target_register = "rip",
                role = "shuffled packed doublewords by vpshufd",
            },
        },
    },

    ["vpshufhw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshufhw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vpshufhw_vector_shuffle",
                target_register = "rip",
                role = "shuffled high packed words by vpshufhw",
            },
        },
    },

    ["vpshuflw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshuflw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vpshuflw_vector_shuffle",
                target_register = "rip",
                role = "shuffled low packed words by vpshuflw",
            },
        },
    },

    ["vpshufb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpshufb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpshufb_vector_shuffle",
                target_register = "rip",
                role = "byte-shuffled packed integer lanes by vpshufb",
            },
        },
    },

    ["vpalignr"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpalignr",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "count" } },
            effect = {
                kind = "register_write",
                name = "vpalignr_vector_align",
                target_register = "rip",
                role = "aligned packed bytes by vpalignr",
            },
        },
    },

    ["vpperm"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpperm",
                    },
                },
            },

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
        },
    },

    ["vpermil2ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermil2ps",
                    },
                },
            },

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
        },
    },

    ["vpermil2pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermil2pd",
                    },
                },
            },

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
        },
    },

    ["pswapd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pswapd",
                    },
                },
            },

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
        },
    },

    ["vpermi2ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermi2ps",
                    },
                },
            },

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
        },
    },

    ["vpermi2pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermi2pd",
                    },
                },
            },

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
        },
    },

    ["vpermt2ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermt2ps",
                    },
                },
            },

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
        },
    },

    ["vpermt2pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermt2pd",
                    },
                },
            },

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
        },
    },

    ["vpermilps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermilps",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermilps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vpermilps_vector_permute",
                target_register = "rip",
                role = "permuted packed single-precision lanes by vpermilps",
            },
        },
    },

    ["vpermilpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermilpd",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermilpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vpermilpd_vector_permute",
                target_register = "rip",
                role = "permuted packed double-precision lanes by vpermilpd",
            },
        },
    },

    ["vpermps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermps",
                    },
                },
            },

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
        },
    },

    ["vpermpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpermpd",
                    },
                },
            },

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
        },
    },

    ["vperm2f128"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vperm2f128",
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
                name = "vperm2f128_vector_permute",
                target_register = "rip",
                role = "performed 128-bit floating lane permute by vperm2f128",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vperm2f128",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vperm2f128_vector_permute",
                target_register = "rip",
                role = "permuted 128-bit floating lanes by vperm2f128",
            },
        },
    },

    ["vperm2i128"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vperm2i128",
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
                name = "vperm2i128_vector_permute",
                target_register = "rip",
                role = "performed 128-bit integer lane permute by vperm2i128",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vperm2i128",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vperm2i128_vector_permute",
                target_register = "rip",
                role = "permuted 128-bit integer lanes by vperm2i128",
            },
        },
    },

    ["pshufw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pshufw",
                    },
                },
            },

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
        },
    },

    ["vshufps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vshufps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vshufps_vector_shuffle",
                target_register = "rip",
                role = "shuffled packed single-precision values by vshufps",
            },
        },
    },

    ["vshufpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vshufpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vshufpd_vector_shuffle",
                target_register = "rip",
                role = "shuffled packed double-precision values by vshufpd",
            },
        },
    },

    ["vunpckhps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vunpckhps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vunpckhps_vector_unpack",
                target_register = "rip",
                role = "unpacked high packed single-precision values by vunpckhps",
            },
        },
    },

    ["vunpcklps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vunpcklps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vunpcklps_vector_unpack",
                target_register = "rip",
                role = "unpacked low packed single-precision values by vunpcklps",
            },
        },
    },

    ["vunpckhpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vunpckhpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vunpckhpd_vector_unpack",
                target_register = "rip",
                role = "unpacked high packed double-precision values by vunpckhpd",
            },
        },
    },

    ["vunpcklpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vunpcklpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vunpcklpd_vector_unpack",
                target_register = "rip",
                role = "unpacked low packed double-precision values by vunpcklpd",
            },
        },
    },

    ["vblendps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vblendps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vblendps_vector_blend",
                target_register = "rip",
                role = "blended packed single-precision values by vblendps",
            },
        },
    },

    ["vblendpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vblendpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
            effect = {
                kind = "register_write",
                name = "vblendpd_vector_blend",
                target_register = "rip",
                role = "blended packed double-precision values by vblendpd",
            },
        },
    },

    ["vblendvps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vblendvps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "mask" } },
            effect = {
                kind = "register_write",
                name = "vblendvps_vector_blend",
                target_register = "rip",
                role = "variable-blended packed single-precision values by vblendvps",
            },
        },
    },

    ["vblendvpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vblendvpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "mask" } },
            effect = {
                kind = "register_write",
                name = "vblendvpd_vector_blend",
                target_register = "rip",
                role = "variable-blended packed double-precision values by vblendvpd",
            },
        },
    },

}
