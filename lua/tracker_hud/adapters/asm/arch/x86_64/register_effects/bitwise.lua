-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/bitwise.lua
--
-- x86-64 bitwise register effect specs.
--
-- Remaining legacy records not yet migrated into the categorized
-- Tree-sitter-first register-effect modules.

return {

    {
                node_type = "instruction",
                mnemonic = "andps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "andps_simd_logic",
                    target_register = "rip",
                    role = "bitwise-and packed single-precision lanes by andps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "andpd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "andpd_simd_logic",
                    target_register = "rip",
                    role = "bitwise-and packed double-precision lanes by andpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "andnps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "andnps_simd_logic",
                    target_register = "rip",
                    role = "bitwise-and-not packed single-precision lanes by andnps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "andnpd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "andnpd_simd_logic",
                    target_register = "rip",
                    role = "bitwise-and-not packed double-precision lanes by andnpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "orps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "orps_simd_logic",
                    target_register = "rip",
                    role = "bitwise-or packed single-precision lanes by orps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "orpd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "orpd_simd_logic",
                    target_register = "rip",
                    role = "bitwise-or packed double-precision lanes by orpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "xorps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "xorps_simd_logic",
                    target_register = "rip",
                    role = "bitwise-xor packed single-precision lanes by xorps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "xorpd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "xorpd_simd_logic",
                    target_register = "rip",
                    role = "bitwise-xor packed double-precision lanes by xorpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "pextrb",
                operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
                effect = {
                    kind = "register_write",
                    name = "pextrb_writes_gpr",
                    target_operand = 1,
                    role = "written with extracted byte by pextrb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "pextrw",
                operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
                effect = {
                    kind = "register_write",
                    name = "pextrw_writes_gpr",
                    target_operand = 1,
                    role = "written with extracted word by pextrw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "pextrd",
                operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
                effect = {
                    kind = "register_write",
                    name = "pextrd_writes_gpr",
                    target_operand = 1,
                    role = "written with extracted doubleword by pextrd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "pextrq",
                operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
                effect = {
                    kind = "register_write",
                    name = "pextrq_writes_gpr",
                    target_operand = 1,
                    role = "written with extracted quadword by pextrq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "pextrb",
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

    {
                node_type = "instruction",
                mnemonic = "pextrd",
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

    {
                node_type = "instruction",
                mnemonic = "pextrq",
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

}

