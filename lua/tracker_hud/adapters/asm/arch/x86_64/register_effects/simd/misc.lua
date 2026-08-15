-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/misc.lua

-- x86-64 SIMD register effect specs: misc.

return {
    {
                    node_type = "instruction",
                    mnemonic = "verr",
                    operands = {
                        { index = 1, role = "selector" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "verr_updates_rflags",
                        target_register = "rflags",
                        role = "updated by readable-segment test verr",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "verw",
                    operands = {
                        { index = 1, role = "selector" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "verw_updates_rflags",
                        target_register = "rflags",
                        role = "updated by writable-segment test verw",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "prefetch",
                    operands = {
                        { index = 1, role = "memory_operand" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "prefetch_touches_memory",
                        target_register = "rip",
                        role = "prefetched memory by prefetch",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "prefetchw",
                    operands = {
                        { index = 1, role = "memory_operand" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "prefetchw_touches_memory",
                        target_register = "rip",
                        role = "prefetched memory for write by prefetchw",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "sqrtps",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "sqrtps_simd_arithmetic",
                        target_register = "rip",
                        role = "square-rooted packed single-precision values by sqrtps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "sqrtpd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "sqrtpd_simd_arithmetic",
                        target_register = "rip",
                        role = "square-rooted packed double-precision values by sqrtpd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "sqrtss",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "sqrtss_scalar_simd_arithmetic",
                        target_register = "rip",
                        role = "square-rooted scalar single-precision value by sqrtss",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "sqrtsd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "sqrtsd_scalar_simd_arithmetic",
                        target_register = "rip",
                        role = "square-rooted scalar double-precision value by sqrtsd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "maxps",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "maxps_simd_compare_select",
                        target_register = "rip",
                        role = "selected packed single-precision maximum values by maxps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "maxpd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "maxpd_simd_compare_select",
                        target_register = "rip",
                        role = "selected packed double-precision maximum values by maxpd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "maxss",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "maxss_scalar_simd_compare_select",
                        target_register = "rip",
                        role = "selected scalar single-precision maximum value by maxss",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "maxsd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "maxsd_scalar_simd_compare_select",
                        target_register = "rip",
                        role = "selected scalar double-precision maximum value by maxsd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "minps",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "minps_simd_compare_select",
                        target_register = "rip",
                        role = "selected packed single-precision minimum values by minps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "minpd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "minpd_simd_compare_select",
                        target_register = "rip",
                        role = "selected packed double-precision minimum values by minpd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "minss",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "minss_scalar_simd_compare_select",
                        target_register = "rip",
                        role = "selected scalar single-precision minimum value by minss",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "minsd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "minsd_scalar_simd_compare_select",
                        target_register = "rip",
                        role = "selected scalar double-precision minimum value by minsd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "shufps",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
                    effect = {
                        kind = "register_write",
                        name = "shufps_simd_shuffle",
                        target_register = "rip",
                        role = "shuffled packed single-precision values by shufps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "shufpd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
                    effect = {
                        kind = "register_write",
                        name = "shufpd_simd_shuffle",
                        target_register = "rip",
                        role = "shuffled packed double-precision values by shufpd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "unpckhps",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "unpckhps_simd_unpack",
                        target_register = "rip",
                        role = "unpacked high packed single-precision values by unpckhps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "unpcklps",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "unpcklps_simd_unpack",
                        target_register = "rip",
                        role = "unpacked low packed single-precision values by unpcklps",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "unpckhpd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "unpckhpd_simd_unpack",
                        target_register = "rip",
                        role = "unpacked high packed double-precision values by unpckhpd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "unpcklpd",
                    operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                    effect = {
                        kind = "register_write",
                        name = "unpcklpd_simd_unpack",
                        target_register = "rip",
                        role = "unpacked low packed double-precision values by unpcklpd",
                    },
                }
,

}
