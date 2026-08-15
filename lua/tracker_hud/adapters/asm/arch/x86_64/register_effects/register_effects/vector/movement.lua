-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/vector/movement.lua
--
-- x86-64 register effects: vector / movement.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies instruction syntax first; operand/effect data
-- describes the x86-64 semantic effects consumed by Tracker_HUD.

return {
    ["movaps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movaps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movaps_simd_move",
                target_register = "rip",
                role = "moved aligned packed single-precision values by movaps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movaps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movaps_vector_move",
                target_register = "rip",
                role = "moved aligned packed single-precision value by movaps",
            },
        },
    },

    ["movups"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movups",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movups_simd_move",
                target_register = "rip",
                role = "moved unaligned packed single-precision values by movups",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movups",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movups_vector_move",
                target_register = "rip",
                role = "moved unaligned packed single-precision value by movups",
            },
        },
    },

    ["movapd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movapd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movapd_simd_move",
                target_register = "rip",
                role = "moved aligned packed double-precision values by movapd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movapd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movapd_vector_move",
                target_register = "rip",
                role = "moved aligned packed double-precision value by movapd",
            },
        },
    },

    ["movupd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movupd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movupd_simd_move",
                target_register = "rip",
                role = "moved unaligned packed double-precision values by movupd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movupd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movupd_vector_move",
                target_register = "rip",
                role = "moved unaligned packed double-precision value by movupd",
            },
        },
    },

    ["movdqa"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movdqa",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movdqa_simd_move",
                target_register = "rip",
                role = "moved aligned packed integer values by movdqa",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movdqa",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movdqa_vector_move",
                target_register = "rip",
                role = "moved aligned packed integer value by movdqa",
            },
        },
    },

    ["movdqu"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movdqu",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movdqu_simd_move",
                target_register = "rip",
                role = "moved unaligned packed integer values by movdqu",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movdqu",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movdqu_vector_move",
                target_register = "rip",
                role = "moved unaligned packed integer value by movdqu",
            },
        },
    },

    ["movntdq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movntdq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movntdq_simd_store",
                target_register = "rip",
                role = "stored packed integer values non-temporally by movntdq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movntdq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movntdq_streaming_store",
                target_register = "rip",
                role = "performed non-temporal packed integer store by movntdq",
            },
        },
    },

    ["movntdqa"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movntdqa",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movntdqa_simd_load",
                target_register = "rip",
                role = "loaded aligned packed integer values non-temporally by movntdqa",
            },
        },
    },

    ["movntps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movntps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movntps_simd_store",
                target_register = "rip",
                role = "stored packed single-precision values non-temporally by movntps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movntps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movntps_streaming_store",
                target_register = "rip",
                role = "performed non-temporal packed single-precision store by movntps",
            },
        },
    },

    ["movntpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movntpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movntpd_simd_store",
                target_register = "rip",
                role = "stored packed double-precision values non-temporally by movntpd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movntpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movntpd_streaming_store",
                target_register = "rip",
                role = "performed non-temporal packed double-precision store by movntpd",
            },
        },
    },

    ["movss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movss_scalar_simd_move",
                target_register = "rip",
                role = "moved scalar single-precision value by movss",
            },
        },
    },

    ["movsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movsd_scalar_simd_move",
                target_register = "rip",
                role = "moved scalar double-precision value by movsd",
            },
        },
    },

    ["movhlps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movhlps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movhlps_simd_shuffle",
                target_register = "rip",
                role = "moved high packed single-precision lanes by movhlps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movhlps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movhlps_vector_lane_move",
                target_register = "rip",
                role = "moved high packed single-precision lanes to low lanes by movhlps",
            },
        },
    },

    ["movlhps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movlhps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movlhps_simd_shuffle",
                target_register = "rip",
                role = "moved low packed single-precision lanes by movlhps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movlhps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movlhps_vector_lane_move",
                target_register = "rip",
                role = "moved low packed single-precision lanes to high lanes by movlhps",
            },
        },
    },

    ["movhps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movhps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movhps_simd_move",
                target_register = "rip",
                role = "moved high packed single-precision lanes by movhps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movhps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movhps_vector_high_move",
                target_register = "rip",
                role = "moved high packed single-precision lanes by movhps",
            },
        },
    },

    ["movlps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movlps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movlps_simd_move",
                target_register = "rip",
                role = "moved low packed single-precision lanes by movlps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movlps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movlps_vector_low_move",
                target_register = "rip",
                role = "moved low packed single-precision lanes by movlps",
            },
        },
    },

    ["movhpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movhpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movhpd_simd_move",
                target_register = "rip",
                role = "moved high packed double-precision lane by movhpd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movhpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movhpd_vector_high_move",
                target_register = "rip",
                role = "moved high packed double-precision lane by movhpd",
            },
        },
    },

    ["movlpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movlpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movlpd_simd_move",
                target_register = "rip",
                role = "moved low packed double-precision lane by movlpd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movlpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movlpd_vector_low_move",
                target_register = "rip",
                role = "moved low packed double-precision lane by movlpd",
            },
        },
    },

    ["movsldup"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movsldup",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movsldup_vector_duplicate",
                target_register = "rip",
                role = "duplicated low packed single-precision lanes by movsldup",
            },
        },
    },

    ["movshdup"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movshdup",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movshdup_vector_duplicate",
                target_register = "rip",
                role = "duplicated high packed single-precision lanes by movshdup",
            },
        },
    },

    ["movddup"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movddup",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movddup_vector_duplicate",
                target_register = "rip",
                role = "duplicated low scalar double-precision lane by movddup",
            },
        },
    },

    ["movd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movd_mmx_sse_move",
                target_register = "rip",
                role = "moved doubleword between integer and multimedia state by movd",
            },
        },
    },

    ["movq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movq_mmx_sse_move",
                target_register = "rip",
                role = "moved quadword between integer and multimedia state by movq",
            },
        },
    },

    ["movdq2q"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movdq2q",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movdq2q_sse_mmx_bridge",
                target_register = "rip",
                role = "moved low quadword from xmm state to mmx state by movdq2q",
            },
        },
    },

    ["movq2dq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movq2dq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movq2dq_mmx_sse_bridge",
                target_register = "rip",
                role = "moved quadword from mmx state to xmm state by movq2dq",
            },
        },
    },

    ["movntq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movntq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movntq_nontemporal_store",
                target_register = "rip",
                role = "stored mmx quadword non-temporally by movntq",
            },
        },
    },

    ["movntsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movntsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movntsd_nontemporal_store",
                target_register = "rip",
                role = "stored scalar double-precision value non-temporally by movntsd",
            },
        },
    },

    ["movntss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movntss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movntss_nontemporal_store",
                target_register = "rip",
                role = "stored scalar single-precision value non-temporally by movntss",
            },
        },
    },

    ["lddqu"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lddqu",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "lddqu_vector_load",
                target_register = "rip",
                role = "loaded unaligned double-quadword integer data by lddqu",
            },
        },
    },

    ["maskmovq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "maskmovq",
                    },
                },
            },

            operands = {
                { index = 1, role = "source" },
                { index = 2, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "maskmovq_masked_store",
                target_register = "rip",
                role = "masked-stored bytes from mmx state by maskmovq",
            },
        },
    },

    ["maskmovdqu"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "maskmovdqu",
                    },
                },
            },

            operands = {
                { index = 1, role = "source" },
                { index = 2, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "maskmovdqu_masked_store",
                target_register = "rip",
                role = "masked-stored bytes from xmm state by maskmovdqu",
            },
        },
    },

    ["vmovaps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovaps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovaps_vector_move",
                target_register = "rip",
                role = "moved aligned packed single-precision values by vmovaps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovaps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovaps_vector_move",
                target_register = "rip",
                role = "moved aligned packed single-precision value by vmovaps",
            },
        },
    },

    ["vmovups"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovups",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovups_vector_move",
                target_register = "rip",
                role = "moved unaligned packed single-precision values by vmovups",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovups",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovups_vector_move",
                target_register = "rip",
                role = "moved unaligned packed single-precision value by vmovups",
            },
        },
    },

    ["vmovapd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovapd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovapd_vector_move",
                target_register = "rip",
                role = "moved aligned packed double-precision values by vmovapd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovapd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovapd_vector_move",
                target_register = "rip",
                role = "moved aligned packed double-precision value by vmovapd",
            },
        },
    },

    ["vmovupd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovupd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovupd_vector_move",
                target_register = "rip",
                role = "moved unaligned packed double-precision values by vmovupd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovupd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovupd_vector_move",
                target_register = "rip",
                role = "moved unaligned packed double-precision value by vmovupd",
            },
        },
    },

    ["vmovdqa"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqa",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqa_vector_move",
                target_register = "rip",
                role = "moved aligned packed integer values by vmovdqa",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqa",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqa_vector_move",
                target_register = "rip",
                role = "moved aligned packed integer value by vmovdqa",
            },
        },
    },

    ["vmovdqu"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqu",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqu_vector_move",
                target_register = "rip",
                role = "moved unaligned packed integer values by vmovdqu",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqu",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqu_vector_move",
                target_register = "rip",
                role = "moved unaligned packed integer value by vmovdqu",
            },
        },
    },

    ["vmovdqa32"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqa32",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqa32_vector_move",
                target_register = "rip",
                role = "moved aligned packed doubleword integers by vmovdqa32",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqa32",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqa32_vector_move",
                target_register = "rip",
                role = "moved aligned packed doubleword integer value by vmovdqa32",
            },
        },
    },

    ["vmovdqa64"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqa64",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqa64_vector_move",
                target_register = "rip",
                role = "moved aligned packed quadword integers by vmovdqa64",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqa64",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqa64_vector_move",
                target_register = "rip",
                role = "moved aligned packed quadword integer value by vmovdqa64",
            },
        },
    },

    ["vmovdqu8"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqu8",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqu8_vector_move",
                target_register = "rip",
                role = "moved unaligned packed byte integers by vmovdqu8",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqu8",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqu8_vector_move",
                target_register = "rip",
                role = "moved unaligned packed byte integer value by vmovdqu8",
            },
        },
    },

    ["vmovdqu16"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqu16",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqu16_vector_move",
                target_register = "rip",
                role = "moved unaligned packed word integers by vmovdqu16",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqu16",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqu16_vector_move",
                target_register = "rip",
                role = "moved unaligned packed word integer value by vmovdqu16",
            },
        },
    },

    ["vmovdqu32"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqu32",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqu32_vector_move",
                target_register = "rip",
                role = "moved unaligned packed doubleword integers by vmovdqu32",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqu32",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqu32_vector_move",
                target_register = "rip",
                role = "moved unaligned packed doubleword integer value by vmovdqu32",
            },
        },
    },

    ["vmovdqu64"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqu64",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqu64_vector_move",
                target_register = "rip",
                role = "moved unaligned packed quadword integers by vmovdqu64",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovdqu64",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqu64_vector_move",
                target_register = "rip",
                role = "moved unaligned packed quadword integer value by vmovdqu64",
            },
        },
    },

    ["vmovss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovss",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovss_scalar_vector_move",
                target_register = "rip",
                role = "moved scalar single-precision value by vmovss",
            },
        },
    },

    ["vmovsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovsd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovsd_scalar_vector_move",
                target_register = "rip",
                role = "moved scalar double-precision value by vmovsd",
            },
        },
    },

    ["vmovntdq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovntdq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovntdq_vector_store",
                target_register = "rip",
                role = "stored packed integer values non-temporally by vmovntdq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovntdq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovntdq_streaming_store",
                target_register = "rip",
                role = "performed non-temporal packed integer store by vmovntdq",
            },
        },
    },

    ["vmovntdqa"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovntdqa",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovntdqa_vector_load",
                target_register = "rip",
                role = "loaded aligned packed integer values non-temporally by vmovntdqa",
            },
        },
    },

    ["vmovntps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovntps",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovntps_vector_store",
                target_register = "rip",
                role = "stored packed single-precision values non-temporally by vmovntps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovntps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovntps_streaming_store",
                target_register = "rip",
                role = "performed non-temporal packed single-precision store by vmovntps",
            },
        },
    },

    ["vmovntpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovntpd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovntpd_vector_store",
                target_register = "rip",
                role = "stored packed double-precision values non-temporally by vmovntpd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovntpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovntpd_streaming_store",
                target_register = "rip",
                role = "performed non-temporal packed double-precision store by vmovntpd",
            },
        },
    },

    ["vmaskmovps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmaskmovps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmaskmovps_vector_mask_move",
                target_register = "rip",
                role = "masked moved packed single-precision values by vmaskmovps",
            },
        },
    },

    ["vmaskmovpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmaskmovpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmaskmovpd_vector_mask_move",
                target_register = "rip",
                role = "masked moved packed double-precision values by vmaskmovpd",
            },
        },
    },

    ["vcompressps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcompressps",
                    },
                },
            },

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
        },
    },

    ["vcompresspd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vcompresspd",
                    },
                },
            },

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
        },
    },

    ["vpcompressd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcompressd",
                    },
                },
            },

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
        },
    },

    ["vpcompressq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcompressq",
                    },
                },
            },

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
        },
    },

    ["vexpandps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vexpandps",
                    },
                },
            },

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
        },
    },

    ["vexpandpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vexpandpd",
                    },
                },
            },

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
        },
    },

    ["vpexpandd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpexpandd",
                    },
                },
            },

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
        },
    },

    ["vpexpandq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpexpandq",
                    },
                },
            },

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
        },
    },

    ["vscatterdps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vscatterdps",
                    },
                },
            },

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
        },
    },

    ["vscatterdpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vscatterdpd",
                    },
                },
            },

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
        },
    },

    ["vscatterqps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vscatterqps",
                    },
                },
            },

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
        },
    },

    ["vscatterqpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vscatterqpd",
                    },
                },
            },

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
        },
    },

    ["vpscatterdd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpscatterdd",
                    },
                },
            },

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
        },
    },

    ["vpscatterdq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpscatterdq",
                    },
                },
            },

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
        },
    },

    ["vpscatterqd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpscatterqd",
                    },
                },
            },

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
        },
    },

    ["vpscatterqq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpscatterqq",
                    },
                },
            },

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
        },
    },

    ["vzeroupper"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vzeroupper",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "vzeroupper_updates_vector_state",
                target_register = "rip",
                role = "zeroed upper vector register state by vzeroupper",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vzeroupper",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "vzeroupper_clears_upper_vector_state",
                target_register = "rip",
                role = "cleared upper vector register state by vzeroupper",
            },
        },
    },

    ["vzeroall"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vzeroall",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "vzeroall_updates_vector_state",
                target_register = "rip",
                role = "zeroed all vector register state by vzeroall",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vzeroall",
                    },
                },
            },

            operands = {},
            effect = {
                kind = "register_write",
                name = "vzeroall_clears_vector_state",
                target_register = "rip",
                role = "cleared all vector register state by vzeroall",
            },
        },
    },

    ["vgatherdps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgatherdps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vgatherdps_vector_gather",
                target_register = "rip",
                role = "gathered packed single-precision values by vgatherdps",
            },
        },
    },

    ["vgatherdpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgatherdpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vgatherdpd_vector_gather",
                target_register = "rip",
                role = "gathered packed double-precision values by vgatherdpd",
            },
        },
    },

    ["vgatherqps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgatherqps",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vgatherqps_vector_gather",
                target_register = "rip",
                role = "gathered packed single-precision values with quadword indices by vgatherqps",
            },
        },
    },

    ["vgatherqpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vgatherqpd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vgatherqpd_vector_gather",
                target_register = "rip",
                role = "gathered packed double-precision values with quadword indices by vgatherqpd",
            },
        },
    },

    ["vpgatherdd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpgatherdd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vpgatherdd_vector_gather",
                target_register = "rip",
                role = "gathered packed doubleword integers by vpgatherdd",
            },
        },
    },

    ["vpgatherdq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpgatherdq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vpgatherdq_vector_gather",
                target_register = "rip",
                role = "gathered packed quadword integers with doubleword indices by vpgatherdq",
            },
        },
    },

    ["vpgatherqd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpgatherqd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vpgatherqd_vector_gather",
                target_register = "rip",
                role = "gathered packed doubleword integers with quadword indices by vpgatherqd",
            },
        },
    },

    ["vpgatherqq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpgatherqq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vpgatherqq_vector_gather",
                target_register = "rip",
                role = "gathered packed quadword integers by vpgatherqq",
            },
        },
    },

    ["vpmaskmovd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmaskmovd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmaskmovd_vector_mask_move",
                target_register = "rip",
                role = "masked moved packed doubleword integers by vpmaskmovd",
            },
        },
    },

    ["vpmaskmovq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmaskmovq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmaskmovq_vector_mask_move",
                target_register = "rip",
                role = "masked moved packed quadword integers by vpmaskmovq",
            },
        },
    },

    ["vpcmov"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpcmov",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "true_source" },
                { index = 3, role = "false_source" },
                { index = 4, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vpcmov_vector_xop_select",
                target_register = "rip",
                role = "conditionally selected packed values by vpcmov",
            },
        },
    },

}
