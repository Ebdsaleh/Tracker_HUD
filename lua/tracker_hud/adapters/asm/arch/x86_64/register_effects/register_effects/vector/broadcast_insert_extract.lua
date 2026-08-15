-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/vector/broadcast_insert_extract.lua
--
-- x86-64 register effects: vector / broadcast insert extract.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies instruction syntax first; operand/effect data
-- describes the x86-64 semantic effects consumed by Tracker_HUD.

return {
    ["pextrb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pextrb",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "pextrb_writes_gpr",
                target_operand = 1,
                role = "written with extracted byte by pextrb",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pextrb",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "pextrb_writes_gpr",
                target_operand = 1,
                role = "written with extracted byte by pextrb",
            },
        },
    },

    ["pextrw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pextrw",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "pextrw_writes_gpr",
                target_operand = 1,
                role = "written with extracted word by pextrw",
            },
        },
    },

    ["pextrd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pextrd",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "pextrd_writes_gpr",
                target_operand = 1,
                role = "written with extracted doubleword by pextrd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pextrd",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "pextrd_writes_gpr",
                target_operand = 1,
                role = "written with extracted doubleword by pextrd",
            },
        },
    },

    ["pextrq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pextrq",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "pextrq_writes_gpr",
                target_operand = 1,
                role = "written with extracted quadword by pextrq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pextrq",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "pextrq_writes_gpr",
                target_operand = 1,
                role = "written with extracted quadword by pextrq",
            },
        },
    },

    ["movmskps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movmskps",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movmskps_writes_gpr",
                target_operand = 1,
                role = "written with packed single-precision sign mask by movmskps",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movmskps",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movmskps_writes_destination",
                target_operand = 1,
                role = "written with packed single-precision sign mask by movmskps",
            },
        },
    },

    ["movmskpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movmskpd",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movmskpd_writes_gpr",
                target_operand = 1,
                role = "written with packed double-precision sign mask by movmskpd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "movmskpd",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movmskpd_writes_destination",
                target_operand = 1,
                role = "written with packed double-precision sign mask by movmskpd",
            },
        },
    },

    ["insertps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "insertps",
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
                name = "insertps_vector_insert",
                target_register = "rip",
                role = "inserted single-precision lane by insertps",
            },
        },
    },

    ["extractps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "extractps",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "extractps_writes_gpr",
                target_operand = 1,
                role = "written with extracted single-precision lane by extractps",
            },
        },
    },

    ["vmovmskps"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovmskps",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovmskps_writes_gpr",
                target_operand = 1,
                role = "written with packed single-precision sign mask by vmovmskps",
            },
        },
    },

    ["vmovmskpd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmovmskpd",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovmskpd_writes_gpr",
                target_operand = 1,
                role = "written with packed double-precision sign mask by vmovmskpd",
            },
        },
    },

    ["vpbroadcastb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpbroadcastb",
                    },
                },
            },

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
        },
    },

    ["vpbroadcastw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpbroadcastw",
                    },
                },
            },

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
        },
    },

    ["vpbroadcastd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpbroadcastd",
                    },
                },
            },

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
        },
    },

    ["vpbroadcastq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpbroadcastq",
                    },
                },
            },

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
        },
    },

    ["vbroadcastf32x2"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcastf32x2",
                    },
                },
            },

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
        },
    },

    ["vbroadcastf32x4"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcastf32x4",
                    },
                },
            },

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
        },
    },

    ["vbroadcastf32x8"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcastf32x8",
                    },
                },
            },

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
        },
    },

    ["vbroadcastf64x2"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcastf64x2",
                    },
                },
            },

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
        },
    },

    ["vbroadcastf64x4"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcastf64x4",
                    },
                },
            },

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
        },
    },

    ["vbroadcasti32x2"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcasti32x2",
                    },
                },
            },

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
        },
    },

    ["vbroadcasti32x4"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcasti32x4",
                    },
                },
            },

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
        },
    },

    ["vbroadcasti32x8"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcasti32x8",
                    },
                },
            },

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
        },
    },

    ["vbroadcasti64x2"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcasti64x2",
                    },
                },
            },

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
        },
    },

    ["vbroadcasti64x4"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcasti64x4",
                    },
                },
            },

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
        },
    },

    ["vextractf32x4"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vextractf32x4",
                    },
                },
            },

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
        },
    },

    ["vextractf32x8"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vextractf32x8",
                    },
                },
            },

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
        },
    },

    ["vextractf64x2"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vextractf64x2",
                    },
                },
            },

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
        },
    },

    ["vextractf64x4"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vextractf64x4",
                    },
                },
            },

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
        },
    },

    ["vextracti32x4"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vextracti32x4",
                    },
                },
            },

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
        },
    },

    ["vextracti32x8"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vextracti32x8",
                    },
                },
            },

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
        },
    },

    ["vextracti64x2"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vextracti64x2",
                    },
                },
            },

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
        },
    },

    ["vextracti64x4"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vextracti64x4",
                    },
                },
            },

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
        },
    },

    ["vinsertf32x4"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vinsertf32x4",
                    },
                },
            },

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
        },
    },

    ["vinsertf32x8"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vinsertf32x8",
                    },
                },
            },

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
        },
    },

    ["vinsertf64x2"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vinsertf64x2",
                    },
                },
            },

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
        },
    },

    ["vinsertf64x4"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vinsertf64x4",
                    },
                },
            },

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
        },
    },

    ["vinserti32x4"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vinserti32x4",
                    },
                },
            },

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
        },
    },

    ["vinserti32x8"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vinserti32x8",
                    },
                },
            },

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
        },
    },

    ["vinserti64x2"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vinserti64x2",
                    },
                },
            },

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
        },
    },

    ["vinserti64x4"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vinserti64x4",
                    },
                },
            },

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
        },
    },

    ["pinsrb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pinsrb",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "pinsrb_vector_insert",
                target_register = "rip",
                role = "inserted byte into packed integer vector by pinsrb",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pinsrb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "pinsrb_simd_insert",
                target_register = "rip",
                role = "inserted byte into packed integer vector by pinsrb",
            },
        },
    },

    ["pinsrd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pinsrd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "pinsrd_vector_insert",
                target_register = "rip",
                role = "inserted doubleword into packed integer vector by pinsrd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pinsrd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "pinsrd_simd_insert",
                target_register = "rip",
                role = "inserted doubleword into packed integer vector by pinsrd",
            },
        },
    },

    ["pinsrq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pinsrq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "pinsrq_vector_insert",
                target_register = "rip",
                role = "inserted quadword into packed integer vector by pinsrq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pinsrq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "pinsrq_simd_insert",
                target_register = "rip",
                role = "inserted quadword into packed integer vector by pinsrq",
            },
        },
    },

    ["pmovmskb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovmskb",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "pmovmskb_writes_gpr",
                target_operand = 1,
                role = "written with packed byte sign mask by pmovmskb",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pmovmskb",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pmovmskb_writes_destination",
                target_operand = 1,
                role = "written with packed byte sign mask by pmovmskb",
            },
        },
    },

    ["pinsrw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "pinsrw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "pinsrw_simd_insert",
                target_register = "rip",
                role = "inserted word into packed integer vector by pinsrw",
            },
        },
    },

    ["vbroadcastss"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcastss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastss_vector_broadcast",
                target_register = "rip",
                role = "broadcast scalar single-precision value by vbroadcastss",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcastss",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastss_vector_broadcast",
                target_register = "rip",
                role = "broadcast scalar single-precision value by vbroadcastss",
            },
        },
    },

    ["vbroadcastsd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcastsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastsd_vector_broadcast",
                target_register = "rip",
                role = "broadcast scalar double-precision value by vbroadcastsd",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcastsd",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastsd_vector_broadcast",
                target_register = "rip",
                role = "broadcast scalar double-precision value by vbroadcastsd",
            },
        },
    },

    ["vbroadcastf128"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcastf128",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastf128_vector_broadcast",
                target_register = "rip",
                role = "broadcast 128-bit floating vector by vbroadcastf128",
            },
        },
    },

    ["vbroadcasti128"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcasti128",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcasti128_vector_broadcast",
                target_register = "rip",
                role = "broadcast 128-bit integer vector by vbroadcasti128",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vbroadcasti128",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcasti128_vector_broadcast",
                target_register = "rip",
                role = "broadcast 128-bit integer value by vbroadcasti128",
            },
        },
    },

    ["vextractf128"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vextractf128",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vextractf128_vector_extract",
                target_register = "rip",
                role = "extracted 128-bit floating lane by vextractf128",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vextractf128",
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
                name = "vextractf128_vector_extract",
                target_register = "rip",
                role = "extracted 128-bit floating lane by vextractf128",
            },
        },
    },

    ["vinsertf128"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vinsertf128",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vinsertf128_vector_insert",
                target_register = "rip",
                role = "inserted 128-bit floating lane by vinsertf128",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vinsertf128",
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
                name = "vinsertf128_vector_insert",
                target_register = "rip",
                role = "inserted 128-bit floating lane by vinsertf128",
            },
        },
    },

    ["vextracti128"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vextracti128",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vextracti128_vector_extract",
                target_register = "rip",
                role = "extracted 128-bit integer lane by vextracti128",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vextracti128",
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
                name = "vextracti128_vector_extract",
                target_register = "rip",
                role = "extracted 128-bit integer lane by vextracti128",
            },
        },
    },

    ["vinserti128"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vinserti128",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vinserti128_vector_insert",
                target_register = "rip",
                role = "inserted 128-bit integer lane by vinserti128",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vinserti128",
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
                name = "vinserti128_vector_insert",
                target_register = "rip",
                role = "inserted 128-bit integer lane by vinserti128",
            },
        },
    },

    ["vpmovmskb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpmovmskb",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vpmovmskb_writes_gpr",
                target_operand = 1,
                role = "written with packed byte sign mask by vpmovmskb",
            },
        },
    },

    ["vpextrb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpextrb",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpextrb_writes_gpr",
                target_operand = 1,
                role = "written with extracted byte by vpextrb",
            },
        },
    },

    ["vpextrw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpextrw",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpextrw_writes_gpr",
                target_operand = 1,
                role = "written with extracted word by vpextrw",
            },
        },
    },

    ["vpextrd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpextrd",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpextrd_writes_gpr",
                target_operand = 1,
                role = "written with extracted doubleword by vpextrd",
            },
        },
    },

    ["vpextrq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpextrq",
                    },
                },
            },

            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpextrq_writes_gpr",
                target_operand = 1,
                role = "written with extracted quadword by vpextrq",
            },
        },
    },

    ["vpinsrb"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpinsrb",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" }, { index = 4, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpinsrb_vector_insert",
                target_register = "rip",
                role = "inserted byte into packed integer vector by vpinsrb",
            },
        },
    },

    ["vpinsrw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpinsrw",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" }, { index = 4, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpinsrw_vector_insert",
                target_register = "rip",
                role = "inserted word into packed integer vector by vpinsrw",
            },
        },
    },

    ["vpinsrd"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpinsrd",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" }, { index = 4, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpinsrd_vector_insert",
                target_register = "rip",
                role = "inserted doubleword into packed integer vector by vpinsrd",
            },
        },
    },

    ["vpinsrq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vpinsrq",
                    },
                },
            },

            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" }, { index = 4, role = "index" } },
            effect = {
                kind = "register_write",
                name = "vpinsrq_vector_insert",
                target_register = "rip",
                role = "inserted quadword into packed integer vector by vpinsrq",
            },
        },
    },

}
