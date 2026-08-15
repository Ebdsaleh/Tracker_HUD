-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/system.lua
--
-- x86-64 legacy system register effects.
--
-- Temporary legacy compatibility during the Tree-sitter-first migration.
-- Only records not yet moved into categorized modules remain here.

return {

    {
                            node_type = "instruction",
                            mnemonic = "iretw",
                            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "iretw_updates_rip",
                                target_register = "rip",
                                role = "returned from interrupt by iretw",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "iretd",
                            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "iretd_updates_rip",
                                target_register = "rip",
                                role = "returned from interrupt by iretd",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vmulps",
                            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "vmulps_vector_arithmetic",
                                target_register = "rip",
                                role = "multiplied packed single-precision values by vmulps",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vmulpd",
                            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "vmulpd_vector_arithmetic",
                                target_register = "rip",
                                role = "multiplied packed double-precision values by vmulpd",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vmulss",
                            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "vmulss_scalar_vector_arithmetic",
                                target_register = "rip",
                                role = "multiplied scalar single-precision values by vmulss",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vmulsd",
                            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "vmulsd_scalar_vector_arithmetic",
                                target_register = "rip",
                                role = "multiplied scalar double-precision values by vmulsd",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vmaxps",
                            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "vmaxps_vector_select",
                                target_register = "rip",
                                role = "selected packed single-precision maximum values by vmaxps",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vmaxpd",
                            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "vmaxpd_vector_select",
                                target_register = "rip",
                                role = "selected packed double-precision maximum values by vmaxpd",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vmaxss",
                            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "vmaxss_scalar_vector_select",
                                target_register = "rip",
                                role = "selected scalar single-precision maximum value by vmaxss",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vmaxsd",
                            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "vmaxsd_scalar_vector_select",
                                target_register = "rip",
                                role = "selected scalar double-precision maximum value by vmaxsd",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vminps",
                            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "vminps_vector_select",
                                target_register = "rip",
                                role = "selected packed single-precision minimum values by vminps",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vminpd",
                            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "vminpd_vector_select",
                                target_register = "rip",
                                role = "selected packed double-precision minimum values by vminpd",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vminss",
                            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "vminss_scalar_vector_select",
                                target_register = "rip",
                                role = "selected scalar single-precision minimum value by vminss",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vminsd",
                            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
                            effect = {
                                kind = "register_write",
                                name = "vminsd_scalar_vector_select",
                                target_register = "rip",
                                role = "selected scalar double-precision minimum value by vminsd",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vmulph",
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
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vmulsh",
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
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vmaxph",
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
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vmaxsh",
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
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vminph",
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
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "vminsh",
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
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "iretw",
                            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "iretw_updates_rip",
                                target_register = "rip",
                                role = "returned from word interrupt by iretw",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "iretd",
                            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "iretd_updates_rip",
                                target_register = "rip",
                                role = "returned from doubleword interrupt by iretd",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "iretq",
                            operands = {},
                            effect = {
                                kind = "register_write",
                                name = "iretq_updates_rip",
                                target_register = "rip",
                                role = "returned from quadword interrupt by iretq",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "syscall",
        
                            operands = {},
        
                            effect = {
                                kind = "register_write",
                                name = "syscall_clobber_rcx",
                                target_register = "rcx",
                                role = "clobbered by Linux syscall",
                                platform = "linux",
                                abi = "linux_syscall",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "syscall",
        
                            operands = {},
        
                            effect = {
                                kind = "register_write",
                                name = "syscall_clobber_r11",
                                target_register = "r11",
                                role = "clobbered by Linux syscall",
                                platform = "linux",
                                abi = "linux_syscall",
                            },
                        }
    ,

    {
                            node_type = "instruction",
                            mnemonic = "syscall",
        
                            operands = {},
        
                            effect = {
                                kind = "register_write",
                                name = "syscall_return_rax",
                                target_register = "rax",
                                role = "receives Linux syscall return value",
                                platform = "linux",
                                abi = "linux_syscall",
                            },
                        }
    ,

}
