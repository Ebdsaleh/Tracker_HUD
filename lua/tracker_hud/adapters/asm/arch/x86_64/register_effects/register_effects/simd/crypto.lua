-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/crypto.lua
--
-- x86-64 legacy SIMD extension effects formerly grouped under crypto register effects.
--
-- Temporary compatibility while the final non-vector leftovers are migrated.

return {
    {
                        node_type = "instruction",
                        mnemonic = "pvalidate",
                        operands = {},
                        effect = {
                            kind = "register_write",
                            name = "pvalidate_updates_rflags",
                            target_register = "rflags",
                            role = "updated by page validation pvalidate",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "psmash",
                        operands = {},
                        effect = {
                            kind = "register_write",
                            name = "psmash_updates_platform_state",
                            target_register = "rip",
                            role = "split secure nested paging mapping by psmash",
                        },
                    },

}
