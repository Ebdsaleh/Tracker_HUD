-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/misc.lua
--
-- x86-64 legacy miscellaneous register effects.
--
-- Temporary legacy compatibility during the Tree-sitter-first migration.
-- Only records not yet moved into categorized modules remain here.

return {

    {
                                node_type = "instruction",
                                mnemonic = "mpsadbw",
                                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
                                effect = {
                                    kind = "register_write",
                                    name = "mpsadbw_simd_integer_sad",
                                    target_register = "rip",
                                    role = "computed multiple packed byte sums of absolute differences by mpsadbw",
                                },
                            }
    ,

    {
                                node_type = "instruction",
                                mnemonic = "dpps",
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
                            }
    ,

    {
                                node_type = "instruction",
                                mnemonic = "dppd",
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
                            }
    ,

    {
                                node_type = "instruction",
                                mnemonic = "haddps",
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
                            }
    ,

    {
                                node_type = "instruction",
                                mnemonic = "haddpd",
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
                            }
    ,

    {
                                node_type = "instruction",
                                mnemonic = "hsubps",
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
                            }
    ,

    {
                                node_type = "instruction",
                                mnemonic = "hsubpd",
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
                            }
    ,

    {
                                node_type = "instruction",
                                mnemonic = "sysretl",
                                operands = {},
                                effect = {
                                    kind = "register_write",
                                    name = "sysretl_updates_rip",
                                    target_register = "rip",
                                    role = "returned from system call in compatibility form by sysretl",
                                },
                            }
    ,

    {
                                node_type = "instruction",
                                mnemonic = "sysretl",
                                operands = {},
                                effect = {
                                    kind = "register_write",
                                    name = "sysretl_clobbers_rcx",
                                    target_register = "rcx",
                                    role = "clobbered by system call return sysretl",
                                },
                            }
    ,

    {
                                node_type = "instruction",
                                mnemonic = "sysretl",
                                operands = {},
                                effect = {
                                    kind = "register_write",
                                    name = "sysretl_clobbers_r11",
                                    target_register = "r11",
                                    role = "clobbered by system call return sysretl",
                                },
                            }
    ,

    {
                                node_type = "instruction",
                                mnemonic = "sysexitl",
                                operands = {},
                                effect = {
                                    kind = "register_write",
                                    name = "sysexitl_updates_rip",
                                    target_register = "rip",
                                    role = "returned from fast system call in compatibility form by sysexitl",
                                },
                            }
    ,

}
