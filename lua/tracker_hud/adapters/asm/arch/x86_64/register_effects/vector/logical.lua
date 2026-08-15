-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/vector/logical.lua
--
-- x86-64 register effects: vector / logical.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies instruction syntax first; operand/effect data
-- describes the x86-64 semantic effects consumed by Tracker_HUD.

return {
    ["andps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "andps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "andps_simd_logic",
                                target_register = "rip",
                                role = "bitwise-and packed single-precision lanes by andps",
                            },
        },
    },

    ["andpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "andpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "andpd_simd_logic",
                                target_register = "rip",
                                role = "bitwise-and packed double-precision lanes by andpd",
                            },
        },
    },

    ["andnps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "andnps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "andnps_simd_logic",
                                target_register = "rip",
                                role = "bitwise-and-not packed single-precision lanes by andnps",
                            },
        },
    },

    ["andnpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "andnpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "andnpd_simd_logic",
                                target_register = "rip",
                                role = "bitwise-and-not packed double-precision lanes by andnpd",
                            },
        },
    },

    ["orps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "orps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "orps_simd_logic",
                                target_register = "rip",
                                role = "bitwise-or packed single-precision lanes by orps",
                            },
        },
    },

    ["orpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "orpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "orpd_simd_logic",
                                target_register = "rip",
                                role = "bitwise-or packed double-precision lanes by orpd",
                            },
        },
    },

    ["xorps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xorps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "xorps_simd_logic",
                                target_register = "rip",
                                role = "bitwise-xor packed single-precision lanes by xorps",
                            },
        },
    },

    ["xorpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "xorpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                            effect = {
                                kind = "register_write",
                                name = "xorpd_simd_logic",
                                target_register = "rip",
                                role = "bitwise-xor packed double-precision lanes by xorpd",
                            },
        },
    },

    ["vpternlogd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpternlogd",
                    },
                },
            },

            operands = {
                                    { index = 1, role = "destination" },
                                    { index = 2, role = "left" },
                                    { index = 3, role = "right" },
                                    { index = 4, role = "truth_table" },
                                },
                                effect = {
                                    kind = "register_write",
                                    name = "vpternlogd_vector_logic",
                                    target_register = "rip",
                                    role = "applied ternary logic to packed doublewords by vpternlogd",
                                },
        },
    },

    ["vpternlogq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpternlogq",
                    },
                },
            },

            operands = {
                                    { index = 1, role = "destination" },
                                    { index = 2, role = "left" },
                                    { index = 3, role = "right" },
                                    { index = 4, role = "truth_table" },
                                },
                                effect = {
                                    kind = "register_write",
                                    name = "vpternlogq_vector_logic",
                                    target_register = "rip",
                                    role = "applied ternary logic to packed quadwords by vpternlogq",
                                },
        },
    },

    ["pand"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pand",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pand_simd_integer_logic",
                            target_register = "rip",
                            role = "bitwise-and packed integer lanes by pand",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pand",
                    },
                },
            },

            operands = {
                            { index = 1, role = "destination" },
                            { index = 2, role = "source" },
                        },
                        effect = {
                            kind = "register_write",
                            name = "pand_packed_integer_and",
                            target_register = "rip",
                            role = "performed packed integer bitwise-and by pand",
                        },
        },
    },

    ["pandn"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pandn",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pandn_simd_integer_logic",
                            target_register = "rip",
                            role = "bitwise-and-not packed integer lanes by pandn",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pandn",
                    },
                },
            },

            operands = {
                            { index = 1, role = "destination" },
                            { index = 2, role = "source" },
                        },
                        effect = {
                            kind = "register_write",
                            name = "pandn_packed_integer_and_not",
                            target_register = "rip",
                            role = "performed packed integer bitwise-and-not by pandn",
                        },
        },
    },

    ["por"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "por",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "por_simd_integer_logic",
                            target_register = "rip",
                            role = "bitwise-or packed integer lanes by por",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "por",
                    },
                },
            },

            operands = {
                            { index = 1, role = "destination" },
                            { index = 2, role = "source" },
                        },
                        effect = {
                            kind = "register_write",
                            name = "por_packed_integer_or",
                            target_register = "rip",
                            role = "performed packed integer bitwise-or by por",
                        },
        },
    },

    ["pxor"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pxor",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "pxor_simd_integer_logic",
                            target_register = "rip",
                            role = "bitwise-xor packed integer lanes by pxor",
                        },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pxor",
                    },
                },
            },

            operands = {
                            { index = 1, role = "destination" },
                            { index = 2, role = "source" },
                        },
                        effect = {
                            kind = "register_write",
                            name = "pxor_packed_integer_xor",
                            target_register = "rip",
                            role = "performed packed integer bitwise-xor by pxor",
                        },
        },
    },

    ["vpand"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpand",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vpand_vector_integer_logic",
                            target_register = "rip",
                            role = "bitwise-and packed integer lanes by vpand",
                        },
        },
    },

    ["vpandn"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpandn",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vpandn_vector_integer_logic",
                            target_register = "rip",
                            role = "bitwise-and-not packed integer lanes by vpandn",
                        },
        },
    },

    ["vpor"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpor",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vpor_vector_integer_logic",
                            target_register = "rip",
                            role = "bitwise-or packed integer lanes by vpor",
                        },
        },
    },

    ["vpxor"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpxor",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vpxor_vector_integer_logic",
                            target_register = "rip",
                            role = "bitwise-xor packed integer lanes by vpxor",
                        },
        },
    },

    ["vandps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vandps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vandps_vector_logic",
                            target_register = "rip",
                            role = "bitwise-and packed single-precision lanes by vandps",
                        },
        },
    },

    ["vandpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vandpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vandpd_vector_logic",
                            target_register = "rip",
                            role = "bitwise-and packed double-precision lanes by vandpd",
                        },
        },
    },

    ["vandnps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vandnps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vandnps_vector_logic",
                            target_register = "rip",
                            role = "bitwise-and-not packed single-precision lanes by vandnps",
                        },
        },
    },

    ["vandnpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vandnpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vandnpd_vector_logic",
                            target_register = "rip",
                            role = "bitwise-and-not packed double-precision lanes by vandnpd",
                        },
        },
    },

    ["vorps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vorps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vorps_vector_logic",
                            target_register = "rip",
                            role = "bitwise-or packed single-precision lanes by vorps",
                        },
        },
    },

    ["vorpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vorpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vorpd_vector_logic",
                            target_register = "rip",
                            role = "bitwise-or packed double-precision lanes by vorpd",
                        },
        },
    },

    ["vxorps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vxorps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vxorps_vector_logic",
                            target_register = "rip",
                            role = "bitwise-xor packed single-precision lanes by vxorps",
                        },
        },
    },

    ["vxorpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vxorpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                        effect = {
                            kind = "register_write",
                            name = "vxorpd_vector_logic",
                            target_register = "rip",
                            role = "bitwise-xor packed double-precision lanes by vxorpd",
                        },
        },
    },

}
