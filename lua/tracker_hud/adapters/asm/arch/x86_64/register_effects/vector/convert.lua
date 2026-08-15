
-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/vector/convert.lua
--
-- x86-64 register effects: vector / convert.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies instruction syntax first; operand/effect data
-- describes the x86-64 semantic effects consumed by Tracker_HUD.

return {
    ["vcvtps2qq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtps2qq",
                    },
                },
            },

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
        },
    },

    ["vcvtps2uqq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtps2uqq",
                    },
                },
            },

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
        },
    },

    ["vcvtpd2qq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtpd2qq",
                    },
                },
            },

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
        },
    },

    ["vcvtpd2uqq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtpd2uqq",
                    },
                },
            },

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
        },
    },

    ["vcvtqq2ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtqq2ps",
                    },
                },
            },

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
        },
    },

    ["vcvtuqq2ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtuqq2ps",
                    },
                },
            },

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
        },
    },

    ["vcvtqq2pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtqq2pd",
                    },
                },
            },

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
        },
    },

    ["vcvtuqq2pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtuqq2pd",
                    },
                },
            },

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
        },
    },

    ["vcvttps2qq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttps2qq",
                    },
                },
            },

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
        },
    },

    ["vcvttps2uqq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttps2uqq",
                    },
                },
            },

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
        },
    },

    ["vcvttpd2qq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttpd2qq",
                    },
                },
            },

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
        },
    },

    ["vcvttpd2uqq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttpd2uqq",
                    },
                },
            },

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
        },
    },

    ["vcvtudq2ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtudq2ps",
                    },
                },
            },

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
        },
    },

    ["vcvtudq2pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtudq2pd",
                    },
                },
            },

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
        },
    },

    ["vcvtps2udq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtps2udq",
                    },
                },
            },

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
        },
    },

    ["vcvtpd2udq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtpd2udq",
                    },
                },
            },

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
        },
    },

    ["vcvttps2udq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttps2udq",
                    },
                },
            },

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
        },
    },

    ["vcvttpd2udq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttpd2udq",
                    },
                },
            },

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
        },
    },

    ["vpmovdb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovdb",
                    },
                },
            },

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
        },
    },

    ["vpmovdw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovdw",
                    },
                },
            },

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
        },
    },

    ["vpmovqb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovqb",
                    },
                },
            },

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
        },
    },

    ["vpmovqw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovqw",
                    },
                },
            },

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
        },
    },

    ["vpmovqd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovqd",
                    },
                },
            },

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
        },
    },

    ["vpmovsdb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovsdb",
                    },
                },
            },

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
        },
    },

    ["vpmovsdw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovsdw",
                    },
                },
            },

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
        },
    },

    ["vpmovsqb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovsqb",
                    },
                },
            },

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
        },
    },

    ["vpmovsqw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovsqw",
                    },
                },
            },

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
        },
    },

    ["vpmovsqd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovsqd",
                    },
                },
            },

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
        },
    },

    ["vpmovusdb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovusdb",
                    },
                },
            },

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
        },
    },

    ["vpmovusdw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovusdw",
                    },
                },
            },

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
        },
    },

    ["vpmovusqb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovusqb",
                    },
                },
            },

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
        },
    },

    ["vpmovusqw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovusqw",
                    },
                },
            },

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
        },
    },

    ["vpmovusqd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovusqd",
                    },
                },
            },

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
        },
    },

    ["vpmovb2m"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovb2m",
                    },
                },
            },

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
        },
    },

    ["vpmovw2m"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovw2m",
                    },
                },
            },

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
        },
    },

    ["vpmovd2m"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovd2m",
                    },
                },
            },

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
        },
    },

    ["vpmovq2m"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovq2m",
                    },
                },
            },

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
        },
    },

    ["vpmovm2b"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovm2b",
                    },
                },
            },

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
        },
    },

    ["vpmovm2w"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovm2w",
                    },
                },
            },

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
        },
    },

    ["vpmovm2d"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovm2d",
                    },
                },
            },

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
        },
    },

    ["vpmovm2q"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovm2q",
                    },
                },
            },

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
        },
    },

    ["vcvtneps2bf16"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtneps2bf16",
                    },
                },
            },

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
        },
    },

    ["vcvtne2ps2bf16"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtne2ps2bf16",
                    },
                },
            },

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
        },
    },

    ["vcvtph2psx"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtph2psx",
                    },
                },
            },

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
        },
    },

    ["vcvtps2phx"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtps2phx",
                    },
                },
            },

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
        },
    },

    ["vcvtsh2ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtsh2ss",
                    },
                },
            },

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
        },
    },

    ["vcvtss2sh"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtss2sh",
                    },
                },
            },

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
        },
    },

    ["vcvtph2dq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtph2dq",
                    },
                },
            },

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
        },
    },

    ["vcvtph2qq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtph2qq",
                    },
                },
            },

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
        },
    },

    ["vcvtph2udq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtph2udq",
                    },
                },
            },

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
        },
    },

    ["vcvtph2uqq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtph2uqq",
                    },
                },
            },

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
        },
    },

    ["vcvtdq2ph"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtdq2ph",
                    },
                },
            },

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
        },
    },

    ["vcvtqq2ph"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtqq2ph",
                    },
                },
            },

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
        },
    },

    ["vcvtudq2ph"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtudq2ph",
                    },
                },
            },

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
        },
    },

    ["vcvtuqq2ph"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtuqq2ph",
                    },
                },
            },

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
        },
    },

    ["vcvttph2dq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttph2dq",
                    },
                },
            },

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
        },
    },

    ["vcvttph2qq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttph2qq",
                    },
                },
            },

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
        },
    },

    ["vcvttph2udq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttph2udq",
                    },
                },
            },

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
        },
    },

    ["vcvttph2uqq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttph2uqq",
                    },
                },
            },

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
        },
    },

    ["pmovsxbw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovsxbw",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovsxbw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pmovsxbw_simd_extend",
                            target_register = "rip",
                            role = "sign-extended packed bytes to words by pmovsxbw",
                        },
        },
    },

    ["pmovsxbd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovsxbd",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovsxbd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pmovsxbd_simd_extend",
                            target_register = "rip",
                            role = "sign-extended packed bytes to doublewords by pmovsxbd",
                        },
        },
    },

    ["pmovsxbq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovsxbq",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovsxbq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pmovsxbq_simd_extend",
                            target_register = "rip",
                            role = "sign-extended packed bytes to quadwords by pmovsxbq",
                        },
        },
    },

    ["pmovsxwd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovsxwd",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovsxwd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pmovsxwd_simd_extend",
                            target_register = "rip",
                            role = "sign-extended packed words to doublewords by pmovsxwd",
                        },
        },
    },

    ["pmovsxwq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovsxwq",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovsxwq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pmovsxwq_simd_extend",
                            target_register = "rip",
                            role = "sign-extended packed words to quadwords by pmovsxwq",
                        },
        },
    },

    ["pmovsxdq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovsxdq",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovsxdq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pmovsxdq_simd_extend",
                            target_register = "rip",
                            role = "sign-extended packed doublewords to quadwords by pmovsxdq",
                        },
        },
    },

    ["pmovzxbw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovzxbw",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovzxbw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pmovzxbw_simd_extend",
                            target_register = "rip",
                            role = "zero-extended packed bytes to words by pmovzxbw",
                        },
        },
    },

    ["pmovzxbd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovzxbd",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovzxbd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pmovzxbd_simd_extend",
                            target_register = "rip",
                            role = "zero-extended packed bytes to doublewords by pmovzxbd",
                        },
        },
    },

    ["pmovzxbq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovzxbq",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovzxbq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pmovzxbq_simd_extend",
                            target_register = "rip",
                            role = "zero-extended packed bytes to quadwords by pmovzxbq",
                        },
        },
    },

    ["pmovzxwd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovzxwd",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovzxwd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pmovzxwd_simd_extend",
                            target_register = "rip",
                            role = "zero-extended packed words to doublewords by pmovzxwd",
                        },
        },
    },

    ["pmovzxwq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovzxwq",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovzxwq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pmovzxwq_simd_extend",
                            target_register = "rip",
                            role = "zero-extended packed words to quadwords by pmovzxwq",
                        },
        },
    },

    ["pmovzxdq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovzxdq",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovzxdq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pmovzxdq_simd_extend",
                            target_register = "rip",
                            role = "zero-extended packed doublewords to quadwords by pmovzxdq",
                        },
        },
    },

    ["cvtss2sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtss2sd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvtss2sd_simd_convert",
                                target_register = "rip",
                                role = "converted scalar single to scalar double by cvtss2sd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtss2sd",
                    },
                },
            },

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
        },
    },

    ["cvtsd2ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtsd2ss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvtsd2ss_simd_convert",
                                target_register = "rip",
                                role = "converted scalar double to scalar single by cvtsd2ss",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtsd2ss",
                    },
                },
            },

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
        },
    },

    ["cvttps2dq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvttps2dq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvttps2dq_simd_convert",
                                target_register = "rip",
                                role = "converted packed single to integers with truncation by cvttps2dq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvttps2dq",
                    },
                },
            },

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
        },
    },

    ["cvtps2dq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtps2dq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvtps2dq_simd_convert",
                                target_register = "rip",
                                role = "converted packed single to integers by cvtps2dq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtps2dq",
                    },
                },
            },

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
        },
    },

    ["cvtdq2ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtdq2ps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvtdq2ps_simd_convert",
                                target_register = "rip",
                                role = "converted packed integers to single-precision by cvtdq2ps",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtdq2ps",
                    },
                },
            },

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
        },
    },

    ["cvtpd2ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtpd2ps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvtpd2ps_simd_convert",
                                target_register = "rip",
                                role = "converted packed double to packed single by cvtpd2ps",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtpd2ps",
                    },
                },
            },

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
        },
    },

    ["cvtps2pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtps2pd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvtps2pd_simd_convert",
                                target_register = "rip",
                                role = "converted packed single to packed double by cvtps2pd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtps2pd",
                    },
                },
            },

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
        },
    },

    ["cvttpd2dq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvttpd2dq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvttpd2dq_simd_convert",
                                target_register = "rip",
                                role = "converted packed double to integers with truncation by cvttpd2dq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvttpd2dq",
                    },
                },
            },

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
        },
    },

    ["cvtpd2dq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtpd2dq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvtpd2dq_simd_convert",
                                target_register = "rip",
                                role = "converted packed double to integers by cvtpd2dq",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtpd2dq",
                    },
                },
            },

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
        },
    },

    ["cvtdq2pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtdq2pd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvtdq2pd_simd_convert",
                                target_register = "rip",
                                role = "converted packed integers to double-precision by cvtdq2pd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtdq2pd",
                    },
                },
            },

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
        },
    },

    ["cvtsi2ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtsi2ss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvtsi2ss_simd_convert",
                                target_register = "rip",
                                role = "converted integer to scalar single by cvtsi2ss",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtsi2ss",
                    },
                },
            },

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
        },
    },

    ["cvtsi2sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtsi2sd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvtsi2sd_simd_convert",
                                target_register = "rip",
                                role = "converted integer to scalar double by cvtsi2sd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtsi2sd",
                    },
                },
            },

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
        },
    },

    ["cvtss2si"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtss2si",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvtss2si_writes_gpr",
                                target_operand = 1,
                                role = "written with converted scalar single integer by cvtss2si",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtss2si",
                    },
                },
            },

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
        },
    },

    ["cvtsd2si"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtsd2si",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvtsd2si_writes_gpr",
                                target_operand = 1,
                                role = "written with converted scalar double integer by cvtsd2si",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvtsd2si",
                    },
                },
            },

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
        },
    },

    ["cvttss2si"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvttss2si",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvttss2si_writes_gpr",
                                target_operand = 1,
                                role = "written with truncated scalar single integer by cvttss2si",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvttss2si",
                    },
                },
            },

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
        },
    },

    ["cvttsd2si"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvttsd2si",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "cvttsd2si_writes_gpr",
                                target_operand = 1,
                                role = "written with truncated scalar double integer by cvttsd2si",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cvttsd2si",
                    },
                },
            },

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
        },
    },

    ["vcvtss2sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtss2sd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvtss2sd_vector_convert",
                            target_register = "rip",
                            role = "converted scalar single to scalar double by vcvtss2sd",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtss2sd",
                    },
                },
            },

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
        },
    },

    ["vcvtsd2ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtsd2ss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvtsd2ss_vector_convert",
                            target_register = "rip",
                            role = "converted scalar double to scalar single by vcvtsd2ss",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtsd2ss",
                    },
                },
            },

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
        },
    },

    ["vcvttps2dq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttps2dq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvttps2dq_vector_convert",
                            target_register = "rip",
                            role = "converted packed single to integers with truncation by vcvttps2dq",
                        },
        },
    },

    ["vcvtps2dq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtps2dq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvtps2dq_vector_convert",
                            target_register = "rip",
                            role = "converted packed single to integers by vcvtps2dq",
                        },
        },
    },

    ["vcvtdq2ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtdq2ps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvtdq2ps_vector_convert",
                            target_register = "rip",
                            role = "converted packed integers to single-precision by vcvtdq2ps",
                        },
        },
    },

    ["vcvtpd2ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtpd2ps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvtpd2ps_vector_convert",
                            target_register = "rip",
                            role = "converted packed double to packed single by vcvtpd2ps",
                        },
        },
    },

    ["vcvtps2pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtps2pd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvtps2pd_vector_convert",
                            target_register = "rip",
                            role = "converted packed single to packed double by vcvtps2pd",
                        },
        },
    },

    ["vcvttpd2dq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttpd2dq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvttpd2dq_vector_convert",
                            target_register = "rip",
                            role = "converted packed double to integers with truncation by vcvttpd2dq",
                        },
        },
    },

    ["vcvtpd2dq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtpd2dq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvtpd2dq_vector_convert",
                            target_register = "rip",
                            role = "converted packed double to integers by vcvtpd2dq",
                        },
        },
    },

    ["vcvtdq2pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtdq2pd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvtdq2pd_vector_convert",
                            target_register = "rip",
                            role = "converted packed integers to double-precision by vcvtdq2pd",
                        },
        },
    },

    ["vcvtsi2ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtsi2ss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvtsi2ss_vector_convert",
                            target_register = "rip",
                            role = "converted integer to scalar single by vcvtsi2ss",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtsi2ss",
                    },
                },
            },

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
        },
    },

    ["vcvtsi2sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtsi2sd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvtsi2sd_vector_convert",
                            target_register = "rip",
                            role = "converted integer to scalar double by vcvtsi2sd",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtsi2sd",
                    },
                },
            },

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
        },
    },

    ["vcvtss2si"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtss2si",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvtss2si_writes_gpr",
                            target_operand = 1,
                            role = "written with converted scalar single integer by vcvtss2si",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtss2si",
                    },
                },
            },

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
        },
    },

    ["vcvtsd2si"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtsd2si",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvtsd2si_writes_gpr",
                            target_operand = 1,
                            role = "written with converted scalar double integer by vcvtsd2si",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtsd2si",
                    },
                },
            },

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
        },
    },

    ["vcvttss2si"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttss2si",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvttss2si_writes_gpr",
                            target_operand = 1,
                            role = "written with truncated scalar single integer by vcvttss2si",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttss2si",
                    },
                },
            },

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
        },
    },

    ["vcvttsd2si"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttsd2si",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vcvttsd2si_writes_gpr",
                            target_operand = 1,
                            role = "written with truncated scalar double integer by vcvttsd2si",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvttsd2si",
                    },
                },
            },

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
        },
    },

    ["vcvtph2ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtph2ps",
                    },
                },
            },

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
        },
    },

    ["vcvtps2ph"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcvtps2ph",
                    },
                },
            },

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
        },
    },

    ["pf2id"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pf2id",
                    },
                },
            },

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
        },
    },

    ["pf2iw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pf2iw",
                    },
                },
            },

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
        },
    },

    ["pi2fd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pi2fd",
                    },
                },
            },

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
        },
    },

    ["pi2fw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pi2fw",
                    },
                },
            },

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
        },
    },

    ["packsswb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "packsswb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "packsswb_simd_integer_pack",
                target_register = "rip",
                role = "packed signed words to signed bytes by packsswb",
            },
        },
    },

    ["packssdw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "packssdw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "packssdw_simd_integer_pack",
                target_register = "rip",
                role = "packed signed doublewords to signed words by packssdw",
            },
        },
    },

    ["packuswb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "packuswb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "packuswb_simd_integer_pack",
                target_register = "rip",
                role = "packed signed words to unsigned bytes by packuswb",
            },
        },
    },

    ["packusdw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "packusdw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "packusdw_simd_integer_pack",
                target_register = "rip",
                role = "packed signed doublewords to unsigned words by packusdw",
            },
        },
    },

    ["vpacksswb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpacksswb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpacksswb_vector_pack",
                target_register = "rip",
                role = "packed signed words to signed bytes by vpacksswb",
            },
        },
    },

    ["vpackssdw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpackssdw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpackssdw_vector_pack",
                target_register = "rip",
                role = "packed signed doublewords to signed words by vpackssdw",
            },
        },
    },

    ["vpackuswb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpackuswb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpackuswb_vector_pack",
                target_register = "rip",
                role = "packed signed words to unsigned bytes by vpackuswb",
            },
        },
    },

    ["vpackusdw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpackusdw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vpackusdw_vector_pack",
                target_register = "rip",
                role = "packed signed doublewords to unsigned words by vpackusdw",
            },
        },
    },

}
