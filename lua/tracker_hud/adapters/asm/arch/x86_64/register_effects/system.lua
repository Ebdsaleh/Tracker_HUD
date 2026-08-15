-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/system.lua
--
-- x86-64 system register effect specs.
--
-- Remaining legacy records not yet migrated into the categorized
-- Tree-sitter-first register-effect modules.

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
                    },

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
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovaps",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovaps_vector_move",
                            target_register = "rip",
                            role = "moved aligned packed single-precision values by vmovaps",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovups",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovups_vector_move",
                            target_register = "rip",
                            role = "moved unaligned packed single-precision values by vmovups",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovapd",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovapd_vector_move",
                            target_register = "rip",
                            role = "moved aligned packed double-precision values by vmovapd",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovupd",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovupd_vector_move",
                            target_register = "rip",
                            role = "moved unaligned packed double-precision values by vmovupd",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqa",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovdqa_vector_move",
                            target_register = "rip",
                            role = "moved aligned packed integer values by vmovdqa",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqu",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovdqu_vector_move",
                            target_register = "rip",
                            role = "moved unaligned packed integer values by vmovdqu",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqa32",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovdqa32_vector_move",
                            target_register = "rip",
                            role = "moved aligned packed doubleword integers by vmovdqa32",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqa64",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovdqa64_vector_move",
                            target_register = "rip",
                            role = "moved aligned packed quadword integers by vmovdqa64",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqu8",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovdqu8_vector_move",
                            target_register = "rip",
                            role = "moved unaligned packed byte integers by vmovdqu8",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqu16",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovdqu16_vector_move",
                            target_register = "rip",
                            role = "moved unaligned packed word integers by vmovdqu16",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqu32",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovdqu32_vector_move",
                            target_register = "rip",
                            role = "moved unaligned packed doubleword integers by vmovdqu32",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqu64",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovdqu64_vector_move",
                            target_register = "rip",
                            role = "moved unaligned packed quadword integers by vmovdqu64",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovss",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovss_scalar_vector_move",
                            target_register = "rip",
                            role = "moved scalar single-precision value by vmovss",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovsd",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovsd_scalar_vector_move",
                            target_register = "rip",
                            role = "moved scalar double-precision value by vmovsd",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovntdq",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovntdq_vector_store",
                            target_register = "rip",
                            role = "stored packed integer values non-temporally by vmovntdq",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovntdqa",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovntdqa_vector_load",
                            target_register = "rip",
                            role = "loaded aligned packed integer values non-temporally by vmovntdqa",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovntps",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovntps_vector_store",
                            target_register = "rip",
                            role = "stored packed single-precision values non-temporally by vmovntps",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovntpd",
                        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovntpd_vector_store",
                            target_register = "rip",
                            role = "stored packed double-precision values non-temporally by vmovntpd",
                        },
                    },

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
                    },

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
                    },

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
                    },

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
                    },

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
                    },

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
                    },

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
                    },

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
                    },

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
                    },

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
                    },

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
                    },

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
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovmskps",
                        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovmskps_writes_gpr",
                            target_operand = 1,
                            role = "written with packed single-precision sign mask by vmovmskps",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovmskpd",
                        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                        effect = {
                            kind = "register_write",
                            name = "vmovmskpd_writes_gpr",
                            target_operand = 1,
                            role = "written with packed double-precision sign mask by vmovmskpd",
                        },
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmaskmovps",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmaskmovpd",
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
                    },

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
                    },

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
                    },

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
                    },

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
                    },

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
                    },

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
                    },

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
                    },

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
                    },

    {
                        node_type = "instruction",
                        mnemonic = "vmovaps",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmovups",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmovapd",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmovupd",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqa",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqu",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqa32",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqa64",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqu8",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqu16",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqu32",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmovdqu64",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmovntps",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmovntpd",
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

    {
                        node_type = "instruction",
                        mnemonic = "vmovntdq",
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
                    },

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
                    },

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
                    },

}
