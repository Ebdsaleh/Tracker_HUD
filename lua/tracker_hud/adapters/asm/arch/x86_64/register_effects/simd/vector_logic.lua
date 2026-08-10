-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/vector_logic.lua

-- x86-64 SIMD register effect specs: vector logic.

return {
    -- AVX logical.
        {
            node_type = "instruction",
            mnemonic = "vandps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vandps_vector_logic",
                target_register = "rip",
                role = "bitwise-and packed single-precision lanes by vandps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vandpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vandpd_vector_logic",
                target_register = "rip",
                role = "bitwise-and packed double-precision lanes by vandpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vandnps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vandnps_vector_logic",
                target_register = "rip",
                role = "bitwise-and-not packed single-precision lanes by vandnps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vandnpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vandnpd_vector_logic",
                target_register = "rip",
                role = "bitwise-and-not packed double-precision lanes by vandnpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vorps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vorps_vector_logic",
                target_register = "rip",
                role = "bitwise-or packed single-precision lanes by vorps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vorpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vorpd_vector_logic",
                target_register = "rip",
                role = "bitwise-or packed double-precision lanes by vorpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vxorps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vxorps_vector_logic",
                target_register = "rip",
                role = "bitwise-xor packed single-precision lanes by vxorps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vxorpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vxorpd_vector_logic",
                target_register = "rip",
                role = "bitwise-xor packed double-precision lanes by vxorpd",
            },
        }
,

}

