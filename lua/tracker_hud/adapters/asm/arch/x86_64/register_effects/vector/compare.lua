-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/vector/compare.lua
--
-- x86-64 register effects: vector / compare.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies instruction syntax first; operand/effect data
-- describes the x86-64 semantic effects consumed by Tracker_HUD.

return {
    ["cmpss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
                                effect = {
                                    kind = "register_write",
                                    name = "cmpss_scalar_simd_compare",
                                    target_register = "rip",
                                    role = "compared scalar single-precision values by cmpss",
                                },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpss",
                    },
                },
            },

            operands = {
                                    { index = 1, role = "destination" },
                                    { index = 2, role = "source" },
                                    { index = 3, role = "predicate" },
                                },
                                effect = {
                                    kind = "register_write",
                                    name = "cmpss_scalar_fp_compare",
                                    target_register = "rip",
                                    role = "performed scalar single-precision compare by cmpss",
                                },
        },
    },

    ["cmpsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
                                effect = {
                                    kind = "register_write",
                                    name = "cmpsd_scalar_simd_compare",
                                    target_register = "rip",
                                    role = "compared scalar double-precision values by cmpsd",
                                },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpsd",
                    },
                },
            },

            operands = {
                                    { index = 1, role = "destination" },
                                    { index = 2, role = "source" },
                                    { index = 3, role = "predicate" },
                                },
                                effect = {
                                    kind = "register_write",
                                    name = "cmpsd_scalar_fp_compare",
                                    target_register = "rip",
                                    role = "performed scalar double-precision compare by cmpsd",
                                },
        },
    },

    ["cmpps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
                                    effect = {
                                        kind = "register_write",
                                        name = "cmpps_simd_compare",
                                        target_register = "rip",
                                        role = "compared packed single-precision values by cmpps",
                                    },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmpps",
                    },
                },
            },

            operands = {
                                        { index = 1, role = "destination" },
                                        { index = 2, role = "source" },
                                        { index = 3, role = "predicate" },
                                    },
                                    effect = {
                                        kind = "register_write",
                                        name = "cmpps_vector_fp_compare",
                                        target_register = "rip",
                                        role = "performed packed single-precision compare by cmpps",
                                    },
        },
    },

    ["cmppd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmppd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
                                    effect = {
                                        kind = "register_write",
                                        name = "cmppd_simd_compare",
                                        target_register = "rip",
                                        role = "compared packed double-precision values by cmppd",
                                    },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "cmppd",
                    },
                },
            },

            operands = {
                                        { index = 1, role = "destination" },
                                        { index = 2, role = "source" },
                                        { index = 3, role = "predicate" },
                                    },
                                    effect = {
                                        kind = "register_write",
                                        name = "cmppd_vector_fp_compare",
                                        target_register = "rip",
                                        role = "performed packed double-precision compare by cmppd",
                                    },
        },
    },

    ["vpcmpb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpb",
                    },
                },
            },

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
        },
    },

    ["vpcmpw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpw",
                    },
                },
            },

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
        },
    },

    ["vpcmpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpd",
                    },
                },
            },

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
        },
    },

    ["vpcmpq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpq",
                    },
                },
            },

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
        },
    },

    ["vpcmpub"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpub",
                    },
                },
            },

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
        },
    },

    ["vpcmpuw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpuw",
                    },
                },
            },

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
        },
    },

    ["vpcmpud"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpud",
                    },
                },
            },

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
        },
    },

    ["vpcmpuq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpuq",
                    },
                },
            },

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
        },
    },

    ["vfpclassps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfpclassps",
                    },
                },
            },

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
        },
    },

    ["vfpclasspd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfpclasspd",
                    },
                },
            },

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
        },
    },

    ["vfpclassss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfpclassss",
                    },
                },
            },

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
        },
    },

    ["vfpclasssd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfpclasssd",
                    },
                },
            },

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
        },
    },

    ["vptestmb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vptestmb",
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
                                    name = "vptestmb_vector_mask_test",
                                    target_register = "rip",
                                    role = "tested packed byte masks by vptestmb",
                                },
        },
    },

    ["vptestmw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vptestmw",
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
                                    name = "vptestmw_vector_mask_test",
                                    target_register = "rip",
                                    role = "tested packed word masks by vptestmw",
                                },
        },
    },

    ["vptestmd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vptestmd",
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
                                    name = "vptestmd_vector_mask_test",
                                    target_register = "rip",
                                    role = "tested packed doubleword masks by vptestmd",
                                },
        },
    },

    ["vptestmq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vptestmq",
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
                                    name = "vptestmq_vector_mask_test",
                                    target_register = "rip",
                                    role = "tested packed quadword masks by vptestmq",
                                },
        },
    },

    ["vptestnmb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vptestnmb",
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
                                    name = "vptestnmb_vector_mask_test",
                                    target_register = "rip",
                                    role = "tested packed byte inverted masks by vptestnmb",
                                },
        },
    },

    ["vptestnmw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vptestnmw",
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
                                    name = "vptestnmw_vector_mask_test",
                                    target_register = "rip",
                                    role = "tested packed word inverted masks by vptestnmw",
                                },
        },
    },

    ["vptestnmd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vptestnmd",
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
                                    name = "vptestnmd_vector_mask_test",
                                    target_register = "rip",
                                    role = "tested packed doubleword inverted masks by vptestnmd",
                                },
        },
    },

    ["vptestnmq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vptestnmq",
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
                                    name = "vptestnmq_vector_mask_test",
                                    target_register = "rip",
                                    role = "tested packed quadword inverted masks by vptestnmq",
                                },
        },
    },

    ["vcmpph"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcmpph",
                    },
                },
            },

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
        },
    },

    ["vcmpsh"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcmpsh",
                    },
                },
            },

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
        },
    },

    ["vcomish"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcomish",
                    },
                },
            },

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
        },
    },

    ["vucomish"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vucomish",
                    },
                },
            },

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
        },
    },

    ["vp2intersectd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vp2intersectd",
                    },
                },
            },

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
        },
    },

    ["vp2intersectq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vp2intersectq",
                    },
                },
            },

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
        },
    },

    ["ptest"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ptest",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ptest",
                    },
                },
            },

            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "ptest_updates_rflags",
                            target_register = "rflags",
                            role = "updated by packed integer test ptest",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ptest",
                    },
                },
            },

            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "ptest_simd_integer_test",
                            target_register = "rip",
                            role = "tested packed integer lanes by ptest",
                        },
        },
    },

    ["pcmpestri"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpestri",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpestri",
                    },
                },
            },

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
        },
    },

    ["pcmpestrm"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpestrm",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpestrm",
                    },
                },
            },

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
        },
    },

    ["pcmpistri"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpistri",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpistri",
                    },
                },
            },

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
        },
    },

    ["pcmpistrm"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpistrm",
                    },
                },
            },

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
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpistrm",
                    },
                },
            },

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
        },
    },

    ["comiss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "comiss",
                    },
                },
            },

            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "comiss_updates_rflags",
                                target_register = "rflags",
                                role = "updated by scalar single-precision compare comiss",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "comiss",
                    },
                },
            },

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
        },
    },

    ["ucomiss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ucomiss",
                    },
                },
            },

            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "ucomiss_updates_rflags",
                                target_register = "rflags",
                                role = "updated by unordered scalar single-precision compare ucomiss",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ucomiss",
                    },
                },
            },

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
        },
    },

    ["comisd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "comisd",
                    },
                },
            },

            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "comisd_updates_rflags",
                                target_register = "rflags",
                                role = "updated by scalar double-precision compare comisd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "comisd",
                    },
                },
            },

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
        },
    },

    ["ucomisd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ucomisd",
                    },
                },
            },

            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "ucomisd_updates_rflags",
                                target_register = "rflags",
                                role = "updated by unordered scalar double-precision compare ucomisd",
                            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ucomisd",
                    },
                },
            },

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
        },
    },

    ["pcmpeqb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpeqb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pcmpeqb_simd_integer_compare",
                            target_register = "rip",
                            role = "compared packed bytes for equality by pcmpeqb",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpeqb",
                    },
                },
            },

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
        },
    },

    ["pcmpeqw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpeqw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pcmpeqw_simd_integer_compare",
                            target_register = "rip",
                            role = "compared packed words for equality by pcmpeqw",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpeqw",
                    },
                },
            },

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
        },
    },

    ["pcmpeqd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpeqd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pcmpeqd_simd_integer_compare",
                            target_register = "rip",
                            role = "compared packed doublewords for equality by pcmpeqd",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpeqd",
                    },
                },
            },

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
        },
    },

    ["pcmpeqq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpeqq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pcmpeqq_simd_integer_compare",
                            target_register = "rip",
                            role = "compared packed quadwords for equality by pcmpeqq",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpeqq",
                    },
                },
            },

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
        },
    },

    ["pcmpgtb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpgtb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pcmpgtb_simd_integer_compare",
                            target_register = "rip",
                            role = "compared packed signed bytes greater-than by pcmpgtb",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpgtb",
                    },
                },
            },

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
        },
    },

    ["pcmpgtw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpgtw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pcmpgtw_simd_integer_compare",
                            target_register = "rip",
                            role = "compared packed signed words greater-than by pcmpgtw",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpgtw",
                    },
                },
            },

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
        },
    },

    ["pcmpgtd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpgtd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pcmpgtd_simd_integer_compare",
                            target_register = "rip",
                            role = "compared packed signed doublewords greater-than by pcmpgtd",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpgtd",
                    },
                },
            },

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
        },
    },

    ["pcmpgtq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpgtq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pcmpgtq_simd_integer_compare",
                            target_register = "rip",
                            role = "compared packed signed quadwords greater-than by pcmpgtq",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pcmpgtq",
                    },
                },
            },

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
        },
    },

    ["vcmpps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcmpps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
                        effect = {
                            kind = "register_write",
                            name = "vcmpps_vector_compare",
                            target_register = "rip",
                            role = "compared packed single-precision values by vcmpps",
                        },
        },
    },

    ["vcmppd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcmppd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
                        effect = {
                            kind = "register_write",
                            name = "vcmppd_vector_compare",
                            target_register = "rip",
                            role = "compared packed double-precision values by vcmppd",
                        },
        },
    },

    ["vcmpss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcmpss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
                        effect = {
                            kind = "register_write",
                            name = "vcmpss_scalar_vector_compare",
                            target_register = "rip",
                            role = "compared scalar single-precision values by vcmpss",
                        },
        },
    },

    ["vcmpsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcmpsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
                        effect = {
                            kind = "register_write",
                            name = "vcmpsd_scalar_vector_compare",
                            target_register = "rip",
                            role = "compared scalar double-precision values by vcmpsd",
                        },
        },
    },

    ["vcomiss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcomiss",
                    },
                },
            },

            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vcomiss_updates_rflags",
                            target_register = "rflags",
                            role = "updated by scalar single-precision compare vcomiss",
                        },
        },
    },

    ["vucomiss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vucomiss",
                    },
                },
            },

            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vucomiss_updates_rflags",
                            target_register = "rflags",
                            role = "updated by unordered scalar single-precision compare vucomiss",
                        },
        },
    },

    ["vcomisd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcomisd",
                    },
                },
            },

            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vcomisd_updates_rflags",
                            target_register = "rflags",
                            role = "updated by scalar double-precision compare vcomisd",
                        },
        },
    },

    ["vucomisd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vucomisd",
                    },
                },
            },

            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vucomisd_updates_rflags",
                            target_register = "rflags",
                            role = "updated by unordered scalar double-precision compare vucomisd",
                        },
        },
    },

    ["vpcmpeqb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpeqb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vpcmpeqb_vector_integer_compare",
                            target_register = "rip",
                            role = "compared packed bytes for equality by vpcmpeqb",
                        },
        },
    },

    ["vpcmpeqw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpeqw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vpcmpeqw_vector_integer_compare",
                            target_register = "rip",
                            role = "compared packed words for equality by vpcmpeqw",
                        },
        },
    },

    ["vpcmpeqd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpeqd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vpcmpeqd_vector_integer_compare",
                            target_register = "rip",
                            role = "compared packed doublewords for equality by vpcmpeqd",
                        },
        },
    },

    ["vpcmpeqq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpeqq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vpcmpeqq_vector_integer_compare",
                            target_register = "rip",
                            role = "compared packed quadwords for equality by vpcmpeqq",
                        },
        },
    },

    ["vpcmpgtb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpgtb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vpcmpgtb_vector_integer_compare",
                            target_register = "rip",
                            role = "compared packed signed bytes greater-than by vpcmpgtb",
                        },
        },
    },

    ["vpcmpgtw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpgtw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vpcmpgtw_vector_integer_compare",
                            target_register = "rip",
                            role = "compared packed signed words greater-than by vpcmpgtw",
                        },
        },
    },

    ["vpcmpgtd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpgtd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vpcmpgtd_vector_integer_compare",
                            target_register = "rip",
                            role = "compared packed signed doublewords greater-than by vpcmpgtd",
                        },
        },
    },

    ["vpcmpgtq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmpgtq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vpcmpgtq_vector_integer_compare",
                            target_register = "rip",
                            role = "compared packed signed quadwords greater-than by vpcmpgtq",
                        },
        },
    },

    ["vpcomb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcomb",
                    },
                },
            },

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
        },
    },

    ["vpcomw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcomw",
                    },
                },
            },

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
        },
    },

    ["vpcomd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcomd",
                    },
                },
            },

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
        },
    },

    ["vpcomq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcomq",
                    },
                },
            },

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
        },
    },

    ["vpcomub"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcomub",
                    },
                },
            },

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
        },
    },

    ["vpcomuw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcomuw",
                    },
                },
            },

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
        },
    },

    ["vpcomud"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcomud",
                    },
                },
            },

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
        },
    },

    ["vpcomuq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcomuq",
                    },
                },
            },

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
        },
    },

    ["pfcmpeq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfcmpeq",
                    },
                },
            },

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
        },
    },

    ["pfcmpge"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfcmpge",
                    },
                },
            },

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
        },
    },

    ["pfcmpgt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfcmpgt",
                    },
                },
            },

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
        },
    },

}
