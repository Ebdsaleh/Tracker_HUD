-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/system_flags.lua
--
-- x86-64 system flags register effect specs.
--
-- Remaining legacy records not yet migrated into the categorized
-- Tree-sitter-first register-effect modules.

return {

    {
                        node_type = "instruction",
                        mnemonic = "cmpps",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
                        effect = {
                            kind = "register_write",
                            name = "cmpps_simd_compare",
                            target_register = "rip",
                            role = "compared packed single-precision values by cmpps",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "cmppd",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
                        effect = {
                            kind = "register_write",
                            name = "cmppd_simd_compare",
                            target_register = "rip",
                            role = "compared packed double-precision values by cmppd",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "cmpps",
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

    {
                        node_type = "instruction",
                        mnemonic = "cmppd",
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

}
