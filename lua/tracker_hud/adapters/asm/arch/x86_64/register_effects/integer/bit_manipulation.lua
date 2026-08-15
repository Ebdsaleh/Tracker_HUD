-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/integer/bit_manipulation.lua
--
-- x86-64 register effects: integer / bit manipulation.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
["popcnt"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcnt",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcnt_writes_destination",
                target_operand = 1,
                role = "written with population count by popcnt",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcnt",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcnt_updates_rflags",
                target_register = "rflags",
                role = "updated by popcnt",
            },
        },
    },

    ["popcntw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcntw",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntw_writes_destination",
                target_operand = 1,
                role = "written with word population count by popcntw",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcntw",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntw_updates_rflags",
                target_register = "rflags",
                role = "updated by word population count popcntw",
            },
        },
    },

    ["popcntl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcntl",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntl_writes_destination",
                target_operand = 1,
                role = "written with long population count by popcntl",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcntl",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntl_updates_rflags",
                target_register = "rflags",
                role = "updated by long population count popcntl",
            },
        },
    },

    ["popcntq"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcntq",
                    },
                },
            },

            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntq_writes_destination",
                target_operand = 1,
                role = "written with quadword population count by popcntq",
            },
        },
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "popcntq",
                    },
                },
            },

            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword population count popcntq",
            },
        },
    },

    ["bswap"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bswap",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "target" },
                    },
            
                    effect = {
                        kind = "register_write",
                        name = "bswap_register",
                        target_operand = 1,
                        role = "byte-swapped by bswap",
                    },
    },
    },

    ["bsf"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bsf",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bsf_writes_destination",
                        target_operand = 1,
                        role = "written with bit scan forward result by bsf",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bsf",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bsf_updates_rflags",
                        target_register = "rflags",
                        role = "updated by bsf",
                    },
    },
    },

    ["bsr"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bsr",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bsr_writes_destination",
                        target_operand = 1,
                        role = "written with bit scan reverse result by bsr",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bsr",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bsr_updates_rflags",
                        target_register = "rflags",
                        role = "updated by bsr",
                    },
    },
    },

    ["tzcnt"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "tzcnt",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "tzcnt_writes_destination",
                        target_operand = 1,
                        role = "written with trailing-zero count by tzcnt",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "tzcnt",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "tzcnt_updates_rflags",
                        target_register = "rflags",
                        role = "updated by tzcnt",
                    },
    },
    },

    ["lzcnt"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "lzcnt",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "lzcnt_writes_destination",
                        target_operand = 1,
                        role = "written with leading-zero count by lzcnt",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "lzcnt",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "lzcnt_updates_rflags",
                        target_register = "rflags",
                        role = "updated by lzcnt",
                    },
    },
    },

    ["bt"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bt",
                },
            },
        },

        operands = {
                        { index = 1, role = "target" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bt_updates_rflags",
                        target_register = "rflags",
                        role = "updated by bit test",
                    },
    },
    },

    ["bts"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bts",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bts_writes_destination",
                        target_operand = 1,
                        role = "bit tested and set by bts",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bts",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bts_updates_rflags",
                        target_register = "rflags",
                        role = "updated by bts",
                    },
    },
    },

    ["btr"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btr",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btr_writes_destination",
                        target_operand = 1,
                        role = "bit tested and reset by btr",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btr",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btr_updates_rflags",
                        target_register = "rflags",
                        role = "updated by btr",
                    },
    },
    },

    ["btc"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btc",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btc_writes_destination",
                        target_operand = 1,
                        role = "bit tested and complemented by btc",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btc",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btc_updates_rflags",
                        target_register = "rflags",
                        role = "updated by btc",
                    },
    },
    },

    ["pdep"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "pdep",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "mask" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "pdep_writes_destination",
                        target_operand = 1,
                        role = "written with parallel bit deposit result by pdep",
                    },
    },
    },

    ["pext"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "pext",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "mask" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "pext_writes_destination",
                        target_operand = 1,
                        role = "written with parallel bit extract result by pext",
                    },
    },
    },

    ["andn"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "andn",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "mask" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "andn_writes_destination",
                        target_operand = 1,
                        role = "written with inverted-source and result by andn",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "andn",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "mask" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "andn_updates_rflags",
                        target_register = "rflags",
                        role = "updated by andn",
                    },
    },
    },

    ["bextr"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bextr",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "control" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bextr_writes_destination",
                        target_operand = 1,
                        role = "written with bit-field extract result by bextr",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bextr",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "control" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bextr_updates_rflags",
                        target_register = "rflags",
                        role = "updated by bextr",
                    },
    },
    },

    ["bzhi"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bzhi",
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
                        name = "bzhi_writes_destination",
                        target_operand = 1,
                        role = "written with zero-high-bits result by bzhi",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bzhi",
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
                        name = "bzhi_updates_rflags",
                        target_register = "rflags",
                        role = "updated by bzhi",
                    },
    },
    },

    ["blsi"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blsi",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blsi_writes_destination",
                        target_operand = 1,
                        role = "written with isolated lowest set bit by blsi",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blsi",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blsi_updates_rflags",
                        target_register = "rflags",
                        role = "updated by blsi",
                    },
    },
    },

    ["blsmsk"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blsmsk",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blsmsk_writes_destination",
                        target_operand = 1,
                        role = "written with lowest-set-bit mask by blsmsk",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blsmsk",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blsmsk_updates_rflags",
                        target_register = "rflags",
                        role = "updated by blsmsk",
                    },
    },
    },

    ["blsr"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blsr",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blsr_writes_destination",
                        target_operand = 1,
                        role = "written with lowest set bit reset by blsr",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blsr",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blsr_updates_rflags",
                        target_register = "rflags",
                        role = "updated by blsr",
                    },
    },
    },

    ["crc32"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "crc32",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "crc32_writes_destination",
                        target_operand = 1,
                        role = "written with crc32 accumulation result by crc32",
                    },
    },
    },

    ["blsfill"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blsfill",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blsfill_writes_destination",
                        target_operand = 1,
                        role = "written with lowest set bit filled by blsfill",
                    },
    },
    },

    ["blsic"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blsic",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blsic_writes_destination",
                        target_operand = 1,
                        role = "written with inverted lowest set bit isolated by blsic",
                    },
    },
    },

    ["btb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btb",
                },
            },
        },

        operands = {
                        { index = 1, role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte bit test btb",
                    },
    },
    },

    ["btw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btw",
                },
            },
        },

        operands = {
                        { index = 1, role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word bit test btw",
                    },
    },
    },

    ["btl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btl",
                },
            },
        },

        operands = {
                        { index = 1, role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long bit test btl",
                    },
    },
    },

    ["btq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btq",
                },
            },
        },

        operands = {
                        { index = 1, role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword bit test btq",
                    },
    },
    },

    ["btsb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btsb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btsb_writes_base",
                        target_operand = 1,
                        role = "bit set in byte base by btsb",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btsb",
                },
            },
        },

        operands = {
                        { index = 1, role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btsb_updates_rflags",
                        target_register = "rflags",
                        role = "updated by byte bit test and set btsb",
                    },
    },
    },

    ["btsw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btsw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btsw_writes_base",
                        target_operand = 1,
                        role = "bit set in word base by btsw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btsw",
                },
            },
        },

        operands = {
                        { index = 1, role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btsw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word bit test and set btsw",
                    },
    },
    },

    ["btsl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btsl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btsl_writes_base",
                        target_operand = 1,
                        role = "bit set in long base by btsl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btsl",
                },
            },
        },

        operands = {
                        { index = 1, role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btsl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long bit test and set btsl",
                    },
    },
    },

    ["btsq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btsq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btsq_writes_base",
                        target_operand = 1,
                        role = "bit set in quadword base by btsq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btsq",
                },
            },
        },

        operands = {
                        { index = 1, role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btsq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword bit test and set btsq",
                    },
    },
    },

    ["btrb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btrb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btrb_writes_base",
                        target_operand = 1,
                        role = "bit reset in byte base by btrb",
                    },
    },
    },

    ["btrq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btrq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btrq_writes_base",
                        target_operand = 1,
                        role = "bit reset in quadword base by btrq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btrq",
                },
            },
        },

        operands = {
                        { index = 1, role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btrq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword bit test and reset btrq",
                    },
    },
    },

    ["btcb"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btcb",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btcb_writes_base",
                        target_operand = 1,
                        role = "bit complemented in byte base by btcb",
                    },
    },
    },

    ["btcq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btcq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btcq_writes_base",
                        target_operand = 1,
                        role = "bit complemented in quadword base by btcq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btcq",
                },
            },
        },

        operands = {
                        { index = 1, role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btcq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword bit test and complement btcq",
                    },
    },
    },

    ["bsfw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bsfw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bsfw_writes_destination",
                        target_operand = 1,
                        role = "written with word bit scan forward index by bsfw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bsfw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bsfw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word bit scan forward bsfw",
                    },
    },
    },

    ["bsfl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bsfl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bsfl_writes_destination",
                        target_operand = 1,
                        role = "written with long bit scan forward index by bsfl",
                    },
    },
    },

    ["bsfq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bsfq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bsfq_writes_destination",
                        target_operand = 1,
                        role = "written with quadword bit scan forward index by bsfq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bsfq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bsfq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword bit scan forward bsfq",
                    },
    },
    },

    ["bsrw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bsrw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bsrw_writes_destination",
                        target_operand = 1,
                        role = "written with word bit scan reverse index by bsrw",
                    },
    },
    },

    ["bsrl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bsrl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bsrl_writes_destination",
                        target_operand = 1,
                        role = "written with long bit scan reverse index by bsrl",
                    },
    },
    },

    ["bsrq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bsrq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bsrq_writes_destination",
                        target_operand = 1,
                        role = "written with quadword bit scan reverse index by bsrq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bsrq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bsrq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword bit scan reverse bsrq",
                    },
    },
    },

    ["btrw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btrw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btrw_writes_base",
                        target_operand = 1,
                        role = "bit reset in word base by btrw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btrw",
                },
            },
        },

        operands = {
                        { index = 1, role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btrw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word bit test and reset btrw",
                    },
    },
    },

    ["btrl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btrl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btrl_writes_base",
                        target_operand = 1,
                        role = "bit reset in long base by btrl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btrl",
                },
            },
        },

        operands = {
                        { index = 1, role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btrl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long bit test and reset btrl",
                    },
    },
    },

    ["btcw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btcw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btcw_writes_base",
                        target_operand = 1,
                        role = "bit complemented in word base by btcw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btcw",
                },
            },
        },

        operands = {
                        { index = 1, role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btcw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word bit test and complement btcw",
                    },
    },
    },

    ["btcl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btcl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btcl_writes_base",
                        target_operand = 1,
                        role = "bit complemented in long base by btcl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "btcl",
                },
            },
        },

        operands = {
                        { index = 1, role = "base" },
                        { index = 2, role = "bit_index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "btcl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long bit test and complement btcl",
                    },
    },
    },

    ["bswapl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bswapl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bswapl_writes_destination",
                        target_operand = 1,
                        role = "byte-swapped long register by bswapl",
                    },
    },
    },

    ["bswapq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bswapq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bswapq_writes_destination",
                        target_operand = 1,
                        role = "byte-swapped quadword register by bswapq",
                    },
    },
    },

    ["lzcntw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "lzcntw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "lzcntw_writes_destination",
                        target_operand = 1,
                        role = "written with word leading-zero count by lzcntw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "lzcntw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "lzcntw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word leading-zero count lzcntw",
                    },
    },
    },

    ["lzcntl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "lzcntl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "lzcntl_writes_destination",
                        target_operand = 1,
                        role = "written with long leading-zero count by lzcntl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "lzcntl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "lzcntl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long leading-zero count lzcntl",
                    },
    },
    },

    ["lzcntq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "lzcntq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "lzcntq_writes_destination",
                        target_operand = 1,
                        role = "written with quadword leading-zero count by lzcntq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "lzcntq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "lzcntq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword leading-zero count lzcntq",
                    },
    },
    },

    ["tzcntw"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "tzcntw",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "tzcntw_writes_destination",
                        target_operand = 1,
                        role = "written with word trailing-zero count by tzcntw",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "tzcntw",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "tzcntw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by word trailing-zero count tzcntw",
                    },
    },
    },

    ["tzcntl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "tzcntl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "tzcntl_writes_destination",
                        target_operand = 1,
                        role = "written with long trailing-zero count by tzcntl",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "tzcntl",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "tzcntl_updates_rflags",
                        target_register = "rflags",
                        role = "updated by long trailing-zero count tzcntl",
                    },
    },
    },

    ["tzcntq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "tzcntq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "tzcntq_writes_destination",
                        target_operand = 1,
                        role = "written with quadword trailing-zero count by tzcntq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "tzcntq",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "tzcntq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword trailing-zero count tzcntq",
                    },
    },
    },

    ["crc32b"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "crc32b",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "crc32b_writes_destination",
                        target_operand = 1,
                        role = "written with byte CRC32 accumulation by crc32b",
                    },
    },
    },

    ["crc32w"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "crc32w",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "crc32w_writes_destination",
                        target_operand = 1,
                        role = "written with word CRC32 accumulation by crc32w",
                    },
    },
    },

    ["crc32l"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "crc32l",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "crc32l_writes_destination",
                        target_operand = 1,
                        role = "written with long CRC32 accumulation by crc32l",
                    },
    },
    },

    ["crc32q"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "crc32q",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "crc32q_writes_destination",
                        target_operand = 1,
                        role = "written with quadword CRC32 accumulation by crc32q",
                    },
    },
    },

    ["andnl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "andnl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "left" },
                        { index = 3, role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "andnl_writes_destination",
                        target_operand = 1,
                        role = "written with long bitwise and-not by andnl",
                    },
    },
    },

    ["andnq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "andnq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "left" },
                        { index = 3, role = "right" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "andnq_writes_destination",
                        target_operand = 1,
                        role = "written with quadword bitwise and-not by andnq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "andnq",
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
                        name = "andnq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword bitwise and-not andnq",
                    },
    },
    },

    ["bextrl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bextrl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "control" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bextrl_writes_destination",
                        target_operand = 1,
                        role = "written with long bit-field extract by bextrl",
                    },
    },
    },

    ["bextrq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bextrq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "control" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "bextrq_writes_destination",
                        target_operand = 1,
                        role = "written with quadword bit-field extract by bextrq",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bextrq",
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
                        name = "bextrq_updates_rflags",
                        target_register = "rflags",
                        role = "updated by quadword bit-field extract bextrq",
                    },
    },
    },

    ["bzhil"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bzhil",
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
                        name = "bzhil_writes_destination",
                        target_operand = 1,
                        role = "written with long zero-high-bits result by bzhil",
                    },
    },
    },

    ["bzhiq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "bzhiq",
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
                        name = "bzhiq_writes_destination",
                        target_operand = 1,
                        role = "written with quadword zero-high-bits result by bzhiq",
                    },
    },
    },

    ["pdepl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "pdepl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "mask" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "pdepl_writes_destination",
                        target_operand = 1,
                        role = "written with long parallel bit deposit by pdepl",
                    },
    },
    },

    ["pdepq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "pdepq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "mask" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "pdepq_writes_destination",
                        target_operand = 1,
                        role = "written with quadword parallel bit deposit by pdepq",
                    },
    },
    },

    ["pextl"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "pextl",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "mask" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "pextl_writes_destination",
                        target_operand = 1,
                        role = "written with long parallel bit extract by pextl",
                    },
    },
    },

    ["pextq"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "pextq",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "mask" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "pextq_writes_destination",
                        target_operand = 1,
                        role = "written with quadword parallel bit extract by pextq",
                    },
    },
    },

    ["blcfill"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blcfill",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blcfill_writes_destination",
                        target_operand = 1,
                        role = "written with lowest clear bit filled by blcfill",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blcfill",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blcfill_updates_rflags",
                        target_register = "rflags",
                        role = "updated by blcfill",
                    },
    },
    },

    ["blci"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blci",
                },
            },
        },

        operands = {
                        { index = 1, role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blci_updates_rflags",
                        target_register = "rflags",
                        role = "updated by blci",
                    },
    },
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blci",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blci_writes_destination",
                        target_operand = 1,
                        role = "written with lowest clear bit isolated by blci",
                    },
    },
    },

    ["blcic"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blcic",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blcic_writes_destination",
                        target_operand = 1,
                        role = "written with inverted lowest clear bit isolated by blcic",
                    },
    },
    },

    ["blcmsk"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blcmsk",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blcmsk_writes_destination",
                        target_operand = 1,
                        role = "written with mask from lowest clear bit by blcmsk",
                    },
    },
    },

    ["blcs"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "blcs",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "blcs_writes_destination",
                        target_operand = 1,
                        role = "written with lowest clear bit set by blcs",
                    },
    },
    },

    ["t1mskc"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "t1mskc",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "t1mskc_writes_destination",
                        target_operand = 1,
                        role = "written with trailing-one mask complement by t1mskc",
                    },
    },
    },

    ["tzmsk"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "tzmsk",
                },
            },
        },

        operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "tzmsk_writes_destination",
                        target_operand = 1,
                        role = "written with trailing-zero mask by tzmsk",
                    },
    },
    },

}

