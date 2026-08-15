-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/vector/floating_arithmetic.lua
--
-- x86-64 register effects: vector / floating arithmetic.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies instruction syntax first; operand/effect data
-- describes the x86-64 semantic effects consumed by Tracker_HUD.

return {
    ["addps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "addps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "addps_simd_arithmetic",
                target_register = "rip",
                role = "added packed single-precision values by addps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "addps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addps_packed_fp_add",
                target_register = "rip",
                role = "performed packed single-precision add by addps",
            },
        },
    },

    ["addpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "addpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "addpd_simd_arithmetic",
                target_register = "rip",
                role = "added packed double-precision values by addpd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "addpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addpd_packed_fp_add",
                target_register = "rip",
                role = "performed packed double-precision add by addpd",
            },
        },
    },

    ["addss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "addss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "addss_scalar_simd_arithmetic",
                target_register = "rip",
                role = "added scalar single-precision values by addss",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "addss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addss_scalar_fp_add",
                target_register = "rip",
                role = "performed scalar single-precision add by addss",
            },
        },
    },

    ["addsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "addsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "addsd_scalar_simd_arithmetic",
                target_register = "rip",
                role = "added scalar double-precision values by addsd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "addsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addsd_scalar_fp_add",
                target_register = "rip",
                role = "performed scalar double-precision add by addsd",
            },
        },
    },

    ["subps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "subps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "subps_simd_arithmetic",
                target_register = "rip",
                role = "subtracted packed single-precision values by subps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "subps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subps_packed_fp_subtract",
                target_register = "rip",
                role = "performed packed single-precision subtract by subps",
            },
        },
    },

    ["subpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "subpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "subpd_simd_arithmetic",
                target_register = "rip",
                role = "subtracted packed double-precision values by subpd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "subpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subpd_packed_fp_subtract",
                target_register = "rip",
                role = "performed packed double-precision subtract by subpd",
            },
        },
    },

    ["subss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "subss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "subss_scalar_simd_arithmetic",
                target_register = "rip",
                role = "subtracted scalar single-precision values by subss",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "subss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subss_scalar_fp_subtract",
                target_register = "rip",
                role = "performed scalar single-precision subtract by subss",
            },
        },
    },

    ["subsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "subsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "subsd_scalar_simd_arithmetic",
                target_register = "rip",
                role = "subtracted scalar double-precision values by subsd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "subsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subsd_scalar_fp_subtract",
                target_register = "rip",
                role = "performed scalar double-precision subtract by subsd",
            },
        },
    },

    ["mulps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "mulps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "mulps_simd_arithmetic",
                target_register = "rip",
                role = "multiplied packed single-precision values by mulps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "mulps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulps_packed_fp_multiply",
                target_register = "rip",
                role = "performed packed single-precision multiply by mulps",
            },
        },
    },

    ["mulpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "mulpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "mulpd_simd_arithmetic",
                target_register = "rip",
                role = "multiplied packed double-precision values by mulpd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "mulpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulpd_packed_fp_multiply",
                target_register = "rip",
                role = "performed packed double-precision multiply by mulpd",
            },
        },
    },

    ["mulss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "mulss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "mulss_scalar_simd_arithmetic",
                target_register = "rip",
                role = "multiplied scalar single-precision values by mulss",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "mulss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulss_scalar_fp_multiply",
                target_register = "rip",
                role = "performed scalar single-precision multiply by mulss",
            },
        },
    },

    ["mulsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "mulsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "mulsd_scalar_simd_arithmetic",
                target_register = "rip",
                role = "multiplied scalar double-precision values by mulsd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "mulsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulsd_scalar_fp_multiply",
                target_register = "rip",
                role = "performed scalar double-precision multiply by mulsd",
            },
        },
    },

    ["divps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "divps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "divps_simd_arithmetic",
                target_register = "rip",
                role = "divided packed single-precision values by divps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "divps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "divps_packed_fp_divide",
                target_register = "rip",
                role = "performed packed single-precision divide by divps",
            },
        },
    },

    ["divpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "divpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "divpd_simd_arithmetic",
                target_register = "rip",
                role = "divided packed double-precision values by divpd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "divpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "divpd_packed_fp_divide",
                target_register = "rip",
                role = "performed packed double-precision divide by divpd",
            },
        },
    },

    ["divss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "divss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "divss_scalar_simd_arithmetic",
                target_register = "rip",
                role = "divided scalar single-precision values by divss",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "divss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "divss_scalar_fp_divide",
                target_register = "rip",
                role = "performed scalar single-precision divide by divss",
            },
        },
    },

    ["divsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "divsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "divsd_scalar_simd_arithmetic",
                target_register = "rip",
                role = "divided scalar double-precision values by divsd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "divsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "divsd_scalar_fp_divide",
                target_register = "rip",
                role = "performed scalar double-precision divide by divsd",
            },
        },
    },

    ["addsubps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "addsubps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addsubps_vector_arithmetic",
                target_register = "rip",
                role = "alternating added and subtracted packed single-precision values by addsubps",
            },
        },
    },

    ["addsubpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "addsubpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addsubpd_vector_arithmetic",
                target_register = "rip",
                role = "alternating added and subtracted packed double-precision values by addsubpd",
            },
        },
    },

    ["dpps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "dpps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "dpps_vector_dot_product",
                target_register = "rip",
                role = "computed packed single-precision dot product by dpps",
            },
        },
    },

    ["dppd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "dppd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "dppd_vector_dot_product",
                target_register = "rip",
                role = "computed packed double-precision dot product by dppd",
            },
        },
    },

    ["haddps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "haddps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "haddps_vector_horizontal",
                target_register = "rip",
                role = "horizontally added packed single-precision values by haddps",
            },
        },
    },

    ["haddpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "haddpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "haddpd_vector_horizontal",
                target_register = "rip",
                role = "horizontally added packed double-precision values by haddpd",
            },
        },
    },

    ["hsubps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "hsubps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "hsubps_vector_horizontal",
                target_register = "rip",
                role = "horizontally subtracted packed single-precision values by hsubps",
            },
        },
    },

    ["hsubpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "hsubpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "hsubpd_vector_horizontal",
                target_register = "rip",
                role = "horizontally subtracted packed double-precision values by hsubpd",
            },
        },
    },

    ["vmulps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmulps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmulps_vector_arithmetic",
                target_register = "rip",
                role = "multiplied packed single-precision values by vmulps",
            },
        },
    },

    ["vmulpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmulpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmulpd_vector_arithmetic",
                target_register = "rip",
                role = "multiplied packed double-precision values by vmulpd",
            },
        },
    },

    ["vmulss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmulss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmulss_scalar_vector_arithmetic",
                target_register = "rip",
                role = "multiplied scalar single-precision values by vmulss",
            },
        },
    },

    ["vmulsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmulsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmulsd_scalar_vector_arithmetic",
                target_register = "rip",
                role = "multiplied scalar double-precision values by vmulsd",
            },
        },
    },

    ["vmaxps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmaxps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmaxps_vector_select",
                target_register = "rip",
                role = "selected packed single-precision maximum values by vmaxps",
            },
        },
    },

    ["vmaxpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmaxpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmaxpd_vector_select",
                target_register = "rip",
                role = "selected packed double-precision maximum values by vmaxpd",
            },
        },
    },

    ["vmaxss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmaxss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmaxss_scalar_vector_select",
                target_register = "rip",
                role = "selected scalar single-precision maximum value by vmaxss",
            },
        },
    },

    ["vmaxsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmaxsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmaxsd_scalar_vector_select",
                target_register = "rip",
                role = "selected scalar double-precision maximum value by vmaxsd",
            },
        },
    },

    ["vminps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vminps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vminps_vector_select",
                target_register = "rip",
                role = "selected packed single-precision minimum values by vminps",
            },
        },
    },

    ["vminpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vminpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vminpd_vector_select",
                target_register = "rip",
                role = "selected packed double-precision minimum values by vminpd",
            },
        },
    },

    ["vminss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vminss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vminss_scalar_vector_select",
                target_register = "rip",
                role = "selected scalar single-precision minimum value by vminss",
            },
        },
    },

    ["vminsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vminsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vminsd_scalar_vector_select",
                target_register = "rip",
                role = "selected scalar double-precision minimum value by vminsd",
            },
        },
    },

    ["vmulph"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmulph",
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
                name = "vmulph_vector_fp16_arithmetic",
                target_register = "rip",
                role = "multiplied packed half-precision values by vmulph",
            },
        },
    },

    ["vmulsh"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmulsh",
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
                name = "vmulsh_scalar_fp16_arithmetic",
                target_register = "rip",
                role = "multiplied scalar half-precision values by vmulsh",
            },
        },
    },

    ["vmaxph"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmaxph",
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
                name = "vmaxph_vector_fp16_select",
                target_register = "rip",
                role = "selected packed half-precision maximum values by vmaxph",
            },
        },
    },

    ["vmaxsh"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmaxsh",
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
                name = "vmaxsh_scalar_fp16_select",
                target_register = "rip",
                role = "selected scalar half-precision maximum value by vmaxsh",
            },
        },
    },

    ["vminph"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vminph",
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
                name = "vminph_vector_fp16_select",
                target_register = "rip",
                role = "selected packed half-precision minimum values by vminph",
            },
        },
    },

    ["vminsh"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vminsh",
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
                name = "vminsh_scalar_fp16_select",
                target_register = "rip",
                role = "selected scalar half-precision minimum value by vminsh",
            },
        },
    },

    ["vdpbf16ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vdpbf16ps",
                    },
                },
            },

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
        },
    },

    ["vaddph"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vaddph",
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
                name = "vaddph_vector_fp16_arithmetic",
                target_register = "rip",
                role = "added packed half-precision values by vaddph",
            },
        },
    },

    ["vaddsh"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vaddsh",
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
                name = "vaddsh_scalar_fp16_arithmetic",
                target_register = "rip",
                role = "added scalar half-precision values by vaddsh",
            },
        },
    },

    ["vsubph"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsubph",
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
                name = "vsubph_vector_fp16_arithmetic",
                target_register = "rip",
                role = "subtracted packed half-precision values by vsubph",
            },
        },
    },

    ["vsubsh"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsubsh",
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
                name = "vsubsh_scalar_fp16_arithmetic",
                target_register = "rip",
                role = "subtracted scalar half-precision values by vsubsh",
            },
        },
    },

    ["vdivph"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vdivph",
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
                name = "vdivph_vector_fp16_arithmetic",
                target_register = "rip",
                role = "divided packed half-precision values by vdivph",
            },
        },
    },

    ["vdivsh"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vdivsh",
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
                name = "vdivsh_scalar_fp16_arithmetic",
                target_register = "rip",
                role = "divided scalar half-precision values by vdivsh",
            },
        },
    },

    ["vsqrtph"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsqrtph",
                    },
                },
            },

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
        },
    },

    ["vsqrtsh"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsqrtsh",
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
                name = "vsqrtsh_scalar_fp16_arithmetic",
                target_register = "rip",
                role = "square-rooted scalar half-precision value by vsqrtsh",
            },
        },
    },

    ["vrangeps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrangeps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "vrangeps_vector_range",
                target_register = "rip",
                role = "computed packed single-precision range values by vrangeps",
            },
        },
    },

    ["vrangepd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrangepd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "vrangepd_vector_range",
                target_register = "rip",
                role = "computed packed double-precision range values by vrangepd",
            },
        },
    },

    ["vrangess"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrangess",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "vrangess_scalar_range",
                target_register = "rip",
                role = "computed scalar single-precision range value by vrangess",
            },
        },
    },

    ["vrangesd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrangesd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "vrangesd_scalar_range",
                target_register = "rip",
                role = "computed scalar double-precision range value by vrangesd",
            },
        },
    },

    ["vreduceps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vreduceps",
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
                name = "vreduceps_vector_reduce",
                target_register = "rip",
                role = "reduced packed single-precision values by vreduceps",
            },
        },
    },

    ["vreducepd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vreducepd",
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
                name = "vreducepd_vector_reduce",
                target_register = "rip",
                role = "reduced packed double-precision values by vreducepd",
            },
        },
    },

    ["vreducess"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vreducess",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "vreducess_scalar_reduce",
                target_register = "rip",
                role = "reduced scalar single-precision value by vreducess",
            },
        },
    },

    ["vreducesd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vreducesd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "vreducesd_scalar_reduce",
                target_register = "rip",
                role = "reduced scalar double-precision value by vreducesd",
            },
        },
    },

    ["vgetexpps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgetexpps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vgetexpps_vector_extract_exponent",
                target_register = "rip",
                role = "extracted packed single-precision exponents by vgetexpps",
            },
        },
    },

    ["vgetexppd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgetexppd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vgetexppd_vector_extract_exponent",
                target_register = "rip",
                role = "extracted packed double-precision exponents by vgetexppd",
            },
        },
    },

    ["vgetexpss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgetexpss",
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
                name = "vgetexpss_scalar_extract_exponent",
                target_register = "rip",
                role = "extracted scalar single-precision exponent by vgetexpss",
            },
        },
    },

    ["vgetexpsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgetexpsd",
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
                name = "vgetexpsd_scalar_extract_exponent",
                target_register = "rip",
                role = "extracted scalar double-precision exponent by vgetexpsd",
            },
        },
    },

    ["vgetmantps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgetmantps",
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
                name = "vgetmantps_vector_extract_mantissa",
                target_register = "rip",
                role = "extracted packed single-precision mantissas by vgetmantps",
            },
        },
    },

    ["vgetmantpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgetmantpd",
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
                name = "vgetmantpd_vector_extract_mantissa",
                target_register = "rip",
                role = "extracted packed double-precision mantissas by vgetmantpd",
            },
        },
    },

    ["vgetmantss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgetmantss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "vgetmantss_scalar_extract_mantissa",
                target_register = "rip",
                role = "extracted scalar single-precision mantissa by vgetmantss",
            },
        },
    },

    ["vgetmantsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgetmantsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "vgetmantsd_scalar_extract_mantissa",
                target_register = "rip",
                role = "extracted scalar double-precision mantissa by vgetmantsd",
            },
        },
    },

    ["vfixupimmps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfixupimmps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "vfixupimmps_vector_fixup",
                target_register = "rip",
                role = "fixed up packed single-precision special values by vfixupimmps",
            },
        },
    },

    ["vfixupimmpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfixupimmpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "vfixupimmpd_vector_fixup",
                target_register = "rip",
                role = "fixed up packed double-precision special values by vfixupimmpd",
            },
        },
    },

    ["vfixupimmss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfixupimmss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "vfixupimmss_scalar_fixup",
                target_register = "rip",
                role = "fixed up scalar single-precision special value by vfixupimmss",
            },
        },
    },

    ["vfixupimmsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfixupimmsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "vfixupimmsd_scalar_fixup",
                target_register = "rip",
                role = "fixed up scalar double-precision special value by vfixupimmsd",
            },
        },
    },

    ["vrcp14ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrcp14ps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vrcp14ps_vector_reciprocal",
                target_register = "rip",
                role = "computed approximate packed single-precision reciprocals by vrcp14ps",
            },
        },
    },

    ["vrcp14pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrcp14pd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vrcp14pd_vector_reciprocal",
                target_register = "rip",
                role = "computed approximate packed double-precision reciprocals by vrcp14pd",
            },
        },
    },

    ["vrcp14ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrcp14ss",
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
                name = "vrcp14ss_scalar_reciprocal",
                target_register = "rip",
                role = "computed approximate scalar single-precision reciprocal by vrcp14ss",
            },
        },
    },

    ["vrcp14sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrcp14sd",
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
                name = "vrcp14sd_scalar_reciprocal",
                target_register = "rip",
                role = "computed approximate scalar double-precision reciprocal by vrcp14sd",
            },
        },
    },

    ["vrsqrt14ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrsqrt14ps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vrsqrt14ps_vector_reciprocal_sqrt",
                target_register = "rip",
                role = "computed approximate packed single-precision reciprocal square roots by vrsqrt14ps",
            },
        },
    },

    ["vrsqrt14pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrsqrt14pd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vrsqrt14pd_vector_reciprocal_sqrt",
                target_register = "rip",
                role = "computed approximate packed double-precision reciprocal square roots by vrsqrt14pd",
            },
        },
    },

    ["vrsqrt14ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrsqrt14ss",
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
                name = "vrsqrt14ss_scalar_reciprocal_sqrt",
                target_register = "rip",
                role = "computed approximate scalar single-precision reciprocal square root by vrsqrt14ss",
            },
        },
    },

    ["vrsqrt14sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrsqrt14sd",
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
                name = "vrsqrt14sd_scalar_reciprocal_sqrt",
                target_register = "rip",
                role = "computed approximate scalar double-precision reciprocal square root by vrsqrt14sd",
            },
        },
    },

    ["vrcp28ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrcp28ps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vrcp28ps_vector_reciprocal",
                target_register = "rip",
                role = "computed high-precision approximate packed single-precision reciprocals by vrcp28ps",
            },
        },
    },

    ["vrcp28pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrcp28pd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vrcp28pd_vector_reciprocal",
                target_register = "rip",
                role = "computed high-precision approximate packed double-precision reciprocals by vrcp28pd",
            },
        },
    },

    ["vrcp28ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrcp28ss",
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
                name = "vrcp28ss_scalar_reciprocal",
                target_register = "rip",
                role = "computed high-precision approximate scalar single-precision reciprocal by vrcp28ss",
            },
        },
    },

    ["vrcp28sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrcp28sd",
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
                name = "vrcp28sd_scalar_reciprocal",
                target_register = "rip",
                role = "computed high-precision approximate scalar double-precision reciprocal by vrcp28sd",
            },
        },
    },

    ["vrsqrt28ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrsqrt28ps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vrsqrt28ps_vector_reciprocal_sqrt",
                target_register = "rip",
                role = "computed high-precision approximate packed single-precision reciprocal square roots by vrsqrt28ps",
            },
        },
    },

    ["vrsqrt28pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrsqrt28pd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vrsqrt28pd_vector_reciprocal_sqrt",
                target_register = "rip",
                role = "computed high-precision approximate packed double-precision reciprocal square roots by vrsqrt28pd",
            },
        },
    },

    ["vrsqrt28ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrsqrt28ss",
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
                name = "vrsqrt28ss_scalar_reciprocal_sqrt",
                target_register = "rip",
                role = "computed high-precision approximate scalar single-precision reciprocal square root by vrsqrt28ss",
            },
        },
    },

    ["vrsqrt28sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vrsqrt28sd",
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
                name = "vrsqrt28sd_scalar_reciprocal_sqrt",
                target_register = "rip",
                role = "computed high-precision approximate scalar double-precision reciprocal square root by vrsqrt28sd",
            },
        },
    },

    ["vexp2ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vexp2ps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vexp2ps_vector_exponential",
                target_register = "rip",
                role = "computed approximate packed single-precision powers of two by vexp2ps",
            },
        },
    },

    ["vexp2pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vexp2pd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vexp2pd_vector_exponential",
                target_register = "rip",
                role = "computed approximate packed double-precision powers of two by vexp2pd",
            },
        },
    },

    ["vscalefps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vscalefps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "scale" },
            },
            effect = {
                kind = "register_write",
                name = "vscalefps_vector_scale",
                target_register = "rip",
                role = "scaled packed single-precision values by powers of two by vscalefps",
            },
        },
    },

    ["vscalefpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vscalefpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "scale" },
            },
            effect = {
                kind = "register_write",
                name = "vscalefpd_vector_scale",
                target_register = "rip",
                role = "scaled packed double-precision values by powers of two by vscalefpd",
            },
        },
    },

    ["vscalefss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vscalefss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "scale" },
            },
            effect = {
                kind = "register_write",
                name = "vscalefss_scalar_scale",
                target_register = "rip",
                role = "scaled scalar single-precision value by power of two by vscalefss",
            },
        },
    },

    ["vscalefsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vscalefsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "scale" },
            },
            effect = {
                kind = "register_write",
                name = "vscalefsd_scalar_scale",
                target_register = "rip",
                role = "scaled scalar double-precision value by power of two by vscalefsd",
            },
        },
    },

    ["v4fmaddps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "v4fmaddps",
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
                name = "v4fmaddps_vector_accelerator",
                target_register = "rip",
                role = "performed four packed single-precision fused multiply-adds by v4fmaddps",
            },
        },
    },

    ["v4fnmaddps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "v4fnmaddps",
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
                name = "v4fnmaddps_vector_accelerator",
                target_register = "rip",
                role = "performed four negative packed single-precision fused multiply-adds by v4fnmaddps",
            },
        },
    },

    ["sqrtps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sqrtps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "sqrtps_simd_arithmetic",
                target_register = "rip",
                role = "square-rooted packed single-precision values by sqrtps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sqrtps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sqrtps_packed_fp_sqrt",
                target_register = "rip",
                role = "computed packed single-precision square root by sqrtps",
            },
        },
    },

    ["sqrtpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sqrtpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "sqrtpd_simd_arithmetic",
                target_register = "rip",
                role = "square-rooted packed double-precision values by sqrtpd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sqrtpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sqrtpd_packed_fp_sqrt",
                target_register = "rip",
                role = "computed packed double-precision square root by sqrtpd",
            },
        },
    },

    ["sqrtss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sqrtss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "sqrtss_scalar_simd_arithmetic",
                target_register = "rip",
                role = "square-rooted scalar single-precision value by sqrtss",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sqrtss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sqrtss_scalar_fp_sqrt",
                target_register = "rip",
                role = "computed scalar single-precision square root by sqrtss",
            },
        },
    },

    ["sqrtsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sqrtsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "sqrtsd_scalar_simd_arithmetic",
                target_register = "rip",
                role = "square-rooted scalar double-precision value by sqrtsd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sqrtsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sqrtsd_scalar_fp_sqrt",
                target_register = "rip",
                role = "computed scalar double-precision square root by sqrtsd",
            },
        },
    },

    ["maxps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "maxps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "maxps_simd_compare_select",
                target_register = "rip",
                role = "selected packed single-precision maximum values by maxps",
            },
        },
    },

    ["maxpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "maxpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "maxpd_simd_compare_select",
                target_register = "rip",
                role = "selected packed double-precision maximum values by maxpd",
            },
        },
    },

    ["maxss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "maxss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "maxss_scalar_simd_compare_select",
                target_register = "rip",
                role = "selected scalar single-precision maximum value by maxss",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "maxss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "maxss_scalar_fp_maximum",
                target_register = "rip",
                role = "selected scalar single-precision maximum by maxss",
            },
        },
    },

    ["maxsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "maxsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "maxsd_scalar_simd_compare_select",
                target_register = "rip",
                role = "selected scalar double-precision maximum value by maxsd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "maxsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "maxsd_scalar_fp_maximum",
                target_register = "rip",
                role = "selected scalar double-precision maximum by maxsd",
            },
        },
    },

    ["minps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "minps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "minps_simd_compare_select",
                target_register = "rip",
                role = "selected packed single-precision minimum values by minps",
            },
        },
    },

    ["minpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "minpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "minpd_simd_compare_select",
                target_register = "rip",
                role = "selected packed double-precision minimum values by minpd",
            },
        },
    },

    ["minss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "minss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "minss_scalar_simd_compare_select",
                target_register = "rip",
                role = "selected scalar single-precision minimum value by minss",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "minss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "minss_scalar_fp_minimum",
                target_register = "rip",
                role = "selected scalar single-precision minimum by minss",
            },
        },
    },

    ["minsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "minsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "minsd_scalar_simd_compare_select",
                target_register = "rip",
                role = "selected scalar double-precision minimum value by minsd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "minsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "minsd_scalar_fp_minimum",
                target_register = "rip",
                role = "selected scalar double-precision minimum by minsd",
            },
        },
    },

    ["vaddps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vaddps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vaddps_vector_arithmetic",
                target_register = "rip",
                role = "added packed single-precision values by vaddps",
            },
        },
    },

    ["vaddpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vaddpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vaddpd_vector_arithmetic",
                target_register = "rip",
                role = "added packed double-precision values by vaddpd",
            },
        },
    },

    ["vaddss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vaddss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vaddss_scalar_vector_arithmetic",
                target_register = "rip",
                role = "added scalar single-precision values by vaddss",
            },
        },
    },

    ["vaddsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vaddsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vaddsd_scalar_vector_arithmetic",
                target_register = "rip",
                role = "added scalar double-precision values by vaddsd",
            },
        },
    },

    ["vsubps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsubps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vsubps_vector_arithmetic",
                target_register = "rip",
                role = "subtracted packed single-precision values by vsubps",
            },
        },
    },

    ["vsubpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsubpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vsubpd_vector_arithmetic",
                target_register = "rip",
                role = "subtracted packed double-precision values by vsubpd",
            },
        },
    },

    ["vsubss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsubss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vsubss_scalar_vector_arithmetic",
                target_register = "rip",
                role = "subtracted scalar single-precision values by vsubss",
            },
        },
    },

    ["vsubsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsubsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vsubsd_scalar_vector_arithmetic",
                target_register = "rip",
                role = "subtracted scalar double-precision values by vsubsd",
            },
        },
    },

    ["vdivps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vdivps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vdivps_vector_arithmetic",
                target_register = "rip",
                role = "divided packed single-precision values by vdivps",
            },
        },
    },

    ["vdivpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vdivpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vdivpd_vector_arithmetic",
                target_register = "rip",
                role = "divided packed double-precision values by vdivpd",
            },
        },
    },

    ["vdivss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vdivss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vdivss_scalar_vector_arithmetic",
                target_register = "rip",
                role = "divided scalar single-precision values by vdivss",
            },
        },
    },

    ["vdivsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vdivsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vdivsd_scalar_vector_arithmetic",
                target_register = "rip",
                role = "divided scalar double-precision values by vdivsd",
            },
        },
    },

    ["vsqrtps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsqrtps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vsqrtps_vector_arithmetic",
                target_register = "rip",
                role = "square-rooted packed single-precision values by vsqrtps",
            },
        },
    },

    ["vsqrtpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsqrtpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vsqrtpd_vector_arithmetic",
                target_register = "rip",
                role = "square-rooted packed double-precision values by vsqrtpd",
            },
        },
    },

    ["vsqrtss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsqrtss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vsqrtss_scalar_vector_arithmetic",
                target_register = "rip",
                role = "square-rooted scalar single-precision value by vsqrtss",
            },
        },
    },

    ["vsqrtsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vsqrtsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vsqrtsd_scalar_vector_arithmetic",
                target_register = "rip",
                role = "square-rooted scalar double-precision value by vsqrtsd",
            },
        },
    },

    ["vfmadd132ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmadd132ps",
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
                name = "vfmadd132ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed single-precision values by vfmadd132ps",
            },
        },
    },

    ["vfmadd213ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmadd213ps",
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
                name = "vfmadd213ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed single-precision values by vfmadd213ps",
            },
        },
    },

    ["vfmadd231ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmadd231ps",
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
                name = "vfmadd231ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed single-precision values by vfmadd231ps",
            },
        },
    },

    ["vfmadd132pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmadd132pd",
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
                name = "vfmadd132pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed double-precision values by vfmadd132pd",
            },
        },
    },

    ["vfmadd213pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmadd213pd",
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
                name = "vfmadd213pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed double-precision values by vfmadd213pd",
            },
        },
    },

    ["vfmadd231pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmadd231pd",
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
                name = "vfmadd231pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed double-precision values by vfmadd231pd",
            },
        },
    },

    ["vfmadd132ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmadd132ss",
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
                name = "vfmadd132ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar single-precision value by vfmadd132ss",
            },
        },
    },

    ["vfmadd213ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmadd213ss",
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
                name = "vfmadd213ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar single-precision value by vfmadd213ss",
            },
        },
    },

    ["vfmadd231ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmadd231ss",
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
                name = "vfmadd231ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar single-precision value by vfmadd231ss",
            },
        },
    },

    ["vfmadd132sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmadd132sd",
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
                name = "vfmadd132sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar double-precision value by vfmadd132sd",
            },
        },
    },

    ["vfmadd213sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmadd213sd",
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
                name = "vfmadd213sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar double-precision value by vfmadd213sd",
            },
        },
    },

    ["vfmadd231sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmadd231sd",
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
                name = "vfmadd231sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar double-precision value by vfmadd231sd",
            },
        },
    },

    ["vfmsub132ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsub132ps",
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
                name = "vfmsub132ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed single-precision values by vfmsub132ps",
            },
        },
    },

    ["vfmsub213ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsub213ps",
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
                name = "vfmsub213ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed single-precision values by vfmsub213ps",
            },
        },
    },

    ["vfmsub231ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsub231ps",
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
                name = "vfmsub231ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed single-precision values by vfmsub231ps",
            },
        },
    },

    ["vfmsub132pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsub132pd",
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
                name = "vfmsub132pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed double-precision values by vfmsub132pd",
            },
        },
    },

    ["vfmsub213pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsub213pd",
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
                name = "vfmsub213pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed double-precision values by vfmsub213pd",
            },
        },
    },

    ["vfmsub231pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsub231pd",
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
                name = "vfmsub231pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed double-precision values by vfmsub231pd",
            },
        },
    },

    ["vfnmadd132ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmadd132ps",
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
                name = "vfnmadd132ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed single-precision values by vfnmadd132ps",
            },
        },
    },

    ["vfnmadd213ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmadd213ps",
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
                name = "vfnmadd213ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed single-precision values by vfnmadd213ps",
            },
        },
    },

    ["vfnmadd231ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmadd231ps",
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
                name = "vfnmadd231ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed single-precision values by vfnmadd231ps",
            },
        },
    },

    ["vfnmsub132ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmsub132ps",
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
                name = "vfnmsub132ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed single-precision values by vfnmsub132ps",
            },
        },
    },

    ["vfnmsub213ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmsub213ps",
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
                name = "vfnmsub213ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed single-precision values by vfnmsub213ps",
            },
        },
    },

    ["vfnmsub231ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmsub231ps",
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
                name = "vfnmsub231ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed single-precision values by vfnmsub231ps",
            },
        },
    },

    ["vfmaddsub132ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmaddsub132ps",
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
                name = "vfmaddsub132ps_vector_fma",
                target_register = "rip",
                role = "fused alternating add-sub packed single-precision values by vfmaddsub132ps",
            },
        },
    },

    ["vfmaddsub213ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmaddsub213ps",
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
                name = "vfmaddsub213ps_vector_fma",
                target_register = "rip",
                role = "fused alternating add-sub packed single-precision values by vfmaddsub213ps",
            },
        },
    },

    ["vfmaddsub231ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmaddsub231ps",
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
                name = "vfmaddsub231ps_vector_fma",
                target_register = "rip",
                role = "fused alternating add-sub packed single-precision values by vfmaddsub231ps",
            },
        },
    },

    ["vfmsubadd132ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsubadd132ps",
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
                name = "vfmsubadd132ps_vector_fma",
                target_register = "rip",
                role = "fused alternating sub-add packed single-precision values by vfmsubadd132ps",
            },
        },
    },

    ["vfmsubadd213ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsubadd213ps",
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
                name = "vfmsubadd213ps_vector_fma",
                target_register = "rip",
                role = "fused alternating sub-add packed single-precision values by vfmsubadd213ps",
            },
        },
    },

    ["vfmsubadd231ps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsubadd231ps",
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
                name = "vfmsubadd231ps_vector_fma",
                target_register = "rip",
                role = "fused alternating sub-add packed single-precision values by vfmsubadd231ps",
            },
        },
    },

    ["roundps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "roundps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "roundps_vector_round",
                target_register = "rip",
                role = "rounded packed single-precision values by roundps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "roundps",
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
                name = "roundps_packed_fp_round",
                target_register = "rip",
                role = "rounded packed single-precision values by roundps",
            },
        },
    },

    ["roundpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "roundpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "roundpd_vector_round",
                target_register = "rip",
                role = "rounded packed double-precision values by roundpd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "roundpd",
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
                name = "roundpd_packed_fp_round",
                target_register = "rip",
                role = "rounded packed double-precision values by roundpd",
            },
        },
    },

    ["roundss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "roundss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "roundss_scalar_round",
                target_register = "rip",
                role = "rounded scalar single-precision value by roundss",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "roundss",
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
                name = "roundss_scalar_fp_round",
                target_register = "rip",
                role = "rounded scalar single-precision value by roundss",
            },
        },
    },

    ["roundsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "roundsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "roundsd_scalar_round",
                target_register = "rip",
                role = "rounded scalar double-precision value by roundsd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "roundsd",
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
                name = "roundsd_scalar_fp_round",
                target_register = "rip",
                role = "rounded scalar double-precision value by roundsd",
            },
        },
    },

    ["vroundps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vroundps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "vroundps_vector_round",
                target_register = "rip",
                role = "rounded packed single-precision values by vroundps",
            },
        },
    },

    ["vroundpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vroundpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "vroundpd_vector_round",
                target_register = "rip",
                role = "rounded packed double-precision values by vroundpd",
            },
        },
    },

    ["vroundss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vroundss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "vroundss_scalar_round",
                target_register = "rip",
                role = "rounded scalar single-precision value by vroundss",
            },
        },
    },

    ["vroundsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vroundsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "vroundsd_scalar_round",
                target_register = "rip",
                role = "rounded scalar double-precision value by vroundsd",
            },
        },
    },

    ["vdpps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vdpps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vdpps_vector_dot_product",
                target_register = "rip",
                role = "computed packed single-precision dot product by vdpps",
            },
        },
    },

    ["vdppd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vdppd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vdppd_vector_dot_product",
                target_register = "rip",
                role = "computed packed double-precision dot product by vdppd",
            },
        },
    },

    ["vfmaddps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmaddps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "addend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddps_vector_fma4",
                target_register = "rip",
                role = "fused multiply-added packed single-precision values by vfmaddps",
            },
        },
    },

    ["vfmaddpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmaddpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "addend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddpd_vector_fma4",
                target_register = "rip",
                role = "fused multiply-added packed double-precision values by vfmaddpd",
            },
        },
    },

    ["vfmaddss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmaddss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "addend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddss_scalar_fma4",
                target_register = "rip",
                role = "fused multiply-added scalar single-precision value by vfmaddss",
            },
        },
    },

    ["vfmaddsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmaddsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "addend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddsd_scalar_fma4",
                target_register = "rip",
                role = "fused multiply-added scalar double-precision value by vfmaddsd",
            },
        },
    },

    ["vfmsubps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsubps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "subtrahend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubps_vector_fma4",
                target_register = "rip",
                role = "fused multiply-subtracted packed single-precision values by vfmsubps",
            },
        },
    },

    ["vfmsubpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsubpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "subtrahend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubpd_vector_fma4",
                target_register = "rip",
                role = "fused multiply-subtracted packed double-precision values by vfmsubpd",
            },
        },
    },

    ["vfmsubss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsubss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "subtrahend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubss_scalar_fma4",
                target_register = "rip",
                role = "fused multiply-subtracted scalar single-precision value by vfmsubss",
            },
        },
    },

    ["vfmsubsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsubsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "subtrahend" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubsd_scalar_fma4",
                target_register = "rip",
                role = "fused multiply-subtracted scalar double-precision value by vfmsubsd",
            },
        },
    },

    ["vfnmaddps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmaddps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "addend" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmaddps_vector_fma4",
                target_register = "rip",
                role = "negative fused multiply-added packed single-precision values by vfnmaddps",
            },
        },
    },

    ["vfnmaddpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmaddpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "addend" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmaddpd_vector_fma4",
                target_register = "rip",
                role = "negative fused multiply-added packed double-precision values by vfnmaddpd",
            },
        },
    },

    ["vfnmsubps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmsubps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "subtrahend" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsubps_vector_fma4",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed single-precision values by vfnmsubps",
            },
        },
    },

    ["vfnmsubpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmsubpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "subtrahend" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsubpd_vector_fma4",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed double-precision values by vfnmsubpd",
            },
        },
    },

    ["pfacc"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfacc",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfacc_3dnow_accumulate",
                target_register = "rip",
                role = "accumulated packed single-precision values by pfacc",
            },
        },
    },

    ["pfadd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfadd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfadd_3dnow_arithmetic",
                target_register = "rip",
                role = "added packed single-precision values by pfadd",
            },
        },
    },

    ["pfmax"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfmax",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfmax_3dnow_select",
                target_register = "rip",
                role = "selected packed single-precision maximum values by pfmax",
            },
        },
    },

    ["pfmin"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfmin",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfmin_3dnow_select",
                target_register = "rip",
                role = "selected packed single-precision minimum values by pfmin",
            },
        },
    },

    ["pfmul"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfmul",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfmul_3dnow_arithmetic",
                target_register = "rip",
                role = "multiplied packed single-precision values by pfmul",
            },
        },
    },

    ["pfrcp"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfrcp",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfrcp_3dnow_reciprocal",
                target_register = "rip",
                role = "computed approximate packed reciprocal by pfrcp",
            },
        },
    },

    ["pfrcpit1"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfrcpit1",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfrcpit1_3dnow_reciprocal",
                target_register = "rip",
                role = "refined approximate packed reciprocal step one by pfrcpit1",
            },
        },
    },

    ["pfrcpit2"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfrcpit2",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfrcpit2_3dnow_reciprocal",
                target_register = "rip",
                role = "refined approximate packed reciprocal step two by pfrcpit2",
            },
        },
    },

    ["pfrsqit1"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfrsqit1",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfrsqit1_3dnow_reciprocal_sqrt",
                target_register = "rip",
                role = "refined approximate packed reciprocal square root by pfrsqit1",
            },
        },
    },

    ["pfrsqrt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfrsqrt",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfrsqrt_3dnow_reciprocal_sqrt",
                target_register = "rip",
                role = "computed approximate packed reciprocal square root by pfrsqrt",
            },
        },
    },

    ["pfsub"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfsub",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfsub_3dnow_arithmetic",
                target_register = "rip",
                role = "subtracted packed single-precision values by pfsub",
            },
        },
    },

    ["pfsubr"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pfsubr",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pfsubr_3dnow_arithmetic",
                target_register = "rip",
                role = "reverse-subtracted packed single-precision values by pfsubr",
            },
        },
    },

    ["vfmsub132ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsub132ss",
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
                name = "vfmsub132ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-subtracted scalar single-precision value by vfmsub132ss",
            },
        },
    },

    ["vfmsub213ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsub213ss",
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
                name = "vfmsub213ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-subtracted scalar single-precision value by vfmsub213ss",
            },
        },
    },

    ["vfmsub231ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsub231ss",
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
                name = "vfmsub231ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-subtracted scalar single-precision value by vfmsub231ss",
            },
        },
    },

    ["vfmsub132sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsub132sd",
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
                name = "vfmsub132sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-subtracted scalar double-precision value by vfmsub132sd",
            },
        },
    },

    ["vfmsub213sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsub213sd",
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
                name = "vfmsub213sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-subtracted scalar double-precision value by vfmsub213sd",
            },
        },
    },

    ["vfmsub231sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsub231sd",
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
                name = "vfmsub231sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-subtracted scalar double-precision value by vfmsub231sd",
            },
        },
    },

    ["vfnmadd132pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmadd132pd",
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
                name = "vfnmadd132pd_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed double-precision values by vfnmadd132pd",
            },
        },
    },

    ["vfnmadd213pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmadd213pd",
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
                name = "vfnmadd213pd_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed double-precision values by vfnmadd213pd",
            },
        },
    },

    ["vfnmadd231pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmadd231pd",
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
                name = "vfnmadd231pd_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed double-precision values by vfnmadd231pd",
            },
        },
    },

    ["vfnmadd132ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmadd132ss",
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
                name = "vfnmadd132ss_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-added scalar single-precision value by vfnmadd132ss",
            },
        },
    },

    ["vfnmadd213ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmadd213ss",
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
                name = "vfnmadd213ss_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-added scalar single-precision value by vfnmadd213ss",
            },
        },
    },

    ["vfnmadd231ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmadd231ss",
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
                name = "vfnmadd231ss_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-added scalar single-precision value by vfnmadd231ss",
            },
        },
    },

    ["vfnmadd132sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmadd132sd",
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
                name = "vfnmadd132sd_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-added scalar double-precision value by vfnmadd132sd",
            },
        },
    },

    ["vfnmadd213sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmadd213sd",
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
                name = "vfnmadd213sd_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-added scalar double-precision value by vfnmadd213sd",
            },
        },
    },

    ["vfnmadd231sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmadd231sd",
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
                name = "vfnmadd231sd_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-added scalar double-precision value by vfnmadd231sd",
            },
        },
    },

    ["vfnmsub132pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmsub132pd",
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
                name = "vfnmsub132pd_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed double-precision values by vfnmsub132pd",
            },
        },
    },

    ["vfnmsub213pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmsub213pd",
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
                name = "vfnmsub213pd_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed double-precision values by vfnmsub213pd",
            },
        },
    },

    ["vfnmsub231pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmsub231pd",
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
                name = "vfnmsub231pd_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed double-precision values by vfnmsub231pd",
            },
        },
    },

    ["vfnmsub132ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmsub132ss",
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
                name = "vfnmsub132ss_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted scalar single-precision value by vfnmsub132ss",
            },
        },
    },

    ["vfnmsub213ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmsub213ss",
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
                name = "vfnmsub213ss_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted scalar single-precision value by vfnmsub213ss",
            },
        },
    },

    ["vfnmsub231ss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmsub231ss",
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
                name = "vfnmsub231ss_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted scalar single-precision value by vfnmsub231ss",
            },
        },
    },

    ["vfnmsub132sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmsub132sd",
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
                name = "vfnmsub132sd_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted scalar double-precision value by vfnmsub132sd",
            },
        },
    },

    ["vfnmsub213sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmsub213sd",
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
                name = "vfnmsub213sd_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted scalar double-precision value by vfnmsub213sd",
            },
        },
    },

    ["vfnmsub231sd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfnmsub231sd",
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
                name = "vfnmsub231sd_scalar_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted scalar double-precision value by vfnmsub231sd",
            },
        },
    },

    ["vfmaddsub132pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmaddsub132pd",
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
                name = "vfmaddsub132pd_vector_fma",
                target_register = "rip",
                role = "fused multiply add-subtracted packed double-precision values by vfmaddsub132pd",
            },
        },
    },

    ["vfmaddsub213pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmaddsub213pd",
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
                name = "vfmaddsub213pd_vector_fma",
                target_register = "rip",
                role = "fused multiply add-subtracted packed double-precision values by vfmaddsub213pd",
            },
        },
    },

    ["vfmaddsub231pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmaddsub231pd",
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
                name = "vfmaddsub231pd_vector_fma",
                target_register = "rip",
                role = "fused multiply add-subtracted packed double-precision values by vfmaddsub231pd",
            },
        },
    },

    ["vfmsubadd132pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsubadd132pd",
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
                name = "vfmsubadd132pd_vector_fma",
                target_register = "rip",
                role = "fused multiply sub-added packed double-precision values by vfmsubadd132pd",
            },
        },
    },

    ["vfmsubadd213pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsubadd213pd",
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
                name = "vfmsubadd213pd_vector_fma",
                target_register = "rip",
                role = "fused multiply sub-added packed double-precision values by vfmsubadd213pd",
            },
        },
    },

    ["vfmsubadd231pd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vfmsubadd231pd",
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
                name = "vfmsubadd231pd_vector_fma",
                target_register = "rip",
                role = "fused multiply sub-added packed double-precision values by vfmsubadd231pd",
            },
        },
    },

    ["rcpss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rcpss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "rcpss_scalar_fp_reciprocal",
                target_register = "rip",
                role = "computed scalar single-precision reciprocal approximation by rcpss",
            },
        },
    },

    ["rcpps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rcpps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "rcpps_packed_fp_reciprocal",
                target_register = "rip",
                role = "computed packed single-precision reciprocal approximation by rcpps",
            },
        },
    },

    ["rsqrtss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rsqrtss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "rsqrtss_scalar_fp_rsqrt",
                target_register = "rip",
                role = "computed scalar single-precision reciprocal square-root approximation by rsqrtss",
            },
        },
    },

    ["rsqrtps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "rsqrtps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "rsqrtps_packed_fp_rsqrt",
                target_register = "rip",
                role = "computed packed single-precision reciprocal square-root approximation by rsqrtps",
            },
        },
    },

}
