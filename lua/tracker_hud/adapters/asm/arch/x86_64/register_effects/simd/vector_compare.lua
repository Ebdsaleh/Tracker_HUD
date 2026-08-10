-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/vector_compare.lua

-- x86-64 SIMD register effect specs: vector compare.

return {
    -- AVX compares and flag compares.
        {
            node_type = "instruction",
            mnemonic = "vcmpps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
            effect = {
                kind = "register_write",
                name = "vcmpps_vector_compare",
                target_register = "rip",
                role = "compared packed single-precision values by vcmpps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcmppd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
            effect = {
                kind = "register_write",
                name = "vcmppd_vector_compare",
                target_register = "rip",
                role = "compared packed double-precision values by vcmppd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcmpss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
            effect = {
                kind = "register_write",
                name = "vcmpss_scalar_vector_compare",
                target_register = "rip",
                role = "compared scalar single-precision values by vcmpss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcmpsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
            effect = {
                kind = "register_write",
                name = "vcmpsd_scalar_vector_compare",
                target_register = "rip",
                role = "compared scalar double-precision values by vcmpsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcomiss",
            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vcomiss_updates_rflags",
                target_register = "rflags",
                role = "updated by scalar single-precision compare vcomiss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vucomiss",
            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vucomiss_updates_rflags",
                target_register = "rflags",
                role = "updated by unordered scalar single-precision compare vucomiss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vcomisd",
            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vcomisd_updates_rflags",
                target_register = "rflags",
                role = "updated by scalar double-precision compare vcomisd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vucomisd",
            operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vucomisd_updates_rflags",
                target_register = "rflags",
                role = "updated by unordered scalar double-precision compare vucomisd",
            },
        }
,

}

