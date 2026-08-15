-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/system.lua
--
-- x86-64 system register effect specs.

--
-- Direct architectural flag-control effects were migrated to register_effects/flags/direct.lua.
--

return {
    {
                node_type = "instruction",
                mnemonic = "cpuid",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cpuid_writes_rax",
                    target_register = "rax",
                    role = "written by cpuid",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "cpuid",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cpuid_writes_rbx",
                    target_register = "rbx",
                    role = "written by cpuid",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "cpuid",

                operands = {},

                effect = {
                    kind = "register_write",
                    name = "cpuid_writes_rcx",
                    target_register = "rcx",
                    role = "written by cpuid",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "cpuid",

                operands = {},

                effect = {
                    kind = "register_write",
                    name = "cpuid_writes_rdx",
                    target_register = "rdx",
                    role = "written by cpuid",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdtsc",

                operands = {},

                effect = {
                    kind = "register_write",
                    name = "rdtsc_writes_rax",
                    target_register = "rax",
                    role = "written with timestamp low result by rdtsc",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdtsc",

                operands = {},

                effect = {
                    kind = "register_write",
                    name = "rdtsc_writes_rdx",
                    target_register = "rdx",
                    role = "written with timestamp high result by rdtsc",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdtscp",

                operands = {},

                effect = {
                    kind = "register_write",
                    name = "rdtscp_writes_rax",
                    target_register = "rax",
                    role = "written with timestamp low result by rdtscp",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdtscp",

                operands = {},

                effect = {
                    kind = "register_write",
                    name = "rdtscp_writes_rdx",
                    target_register = "rdx",
                    role = "written with timestamp high result by rdtscp",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdtscp",

                operands = {},

                effect = {
                    kind = "register_write",
                    name = "rdtscp_writes_rcx",
                    target_register = "rcx",
                    role = "written with processor id by rdtscp",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdrand",

                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },

                effect = {
                    kind = "register_write",
                    name = "rdrand_register",
                    target_operand = 1,
                    role = "written with hardware random value by rdrand",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdrand",

                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },

                effect = {
                    kind = "register_write",
                    name = "rdrand_updates_rflags",
                    target_register = "rflags",
                    role = "updated by rdrand",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdseed",

                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },

                effect = {
                    kind = "register_write",
                    name = "rdseed_register",
                    target_operand = 1,
                    role = "written with hardware seed value by rdseed",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdseed",

                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },

                effect = {
                    kind = "register_write",
                    name = "rdseed_updates_rflags",
                    target_register = "rflags",
                    role = "updated by rdseed",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdmsr",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdmsr_writes_rax",
                    target_register = "rax",
                    role = "written with model-specific register low bits by rdmsr",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdmsr",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdmsr_writes_rdx",
                    target_register = "rdx",
                    role = "written with model-specific register high bits by rdmsr",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdpmc",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdpmc_writes_rax",
                    target_register = "rax",
                    role = "written with performance counter low bits by rdpmc",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdpmc",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdpmc_writes_rdx",
                    target_register = "rdx",
                    role = "written with performance counter high bits by rdpmc",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "xgetbv",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "xgetbv_writes_rax",
                    target_register = "rax",
                    role = "written with extended control register low bits by xgetbv",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "xgetbv",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "xgetbv_writes_rdx",
                    target_register = "rdx",
                    role = "written with extended control register high bits by xgetbv",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdpkru",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdpkru_writes_rax",
                    target_register = "rax",
                    role = "written with protection-key rights by rdpkru",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdpkru",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdpkru_writes_rdx",
                    target_register = "rdx",
                    role = "cleared high result by rdpkru",
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
                mnemonic = "xbegin",
                operands = {
                    { index = 1, role = "abort_target" },
                },
                effect = {
                    kind = "register_write",
                    name = "xbegin_may_write_rax",
                    target_register = "rax",
                    written_alias = "eax",
                    role = "may receive transaction abort status by xbegin",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "xtest",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "xtest_updates_rflags",
                    target_register = "rflags",
                    role = "updated by transactional state test xtest",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "sldt",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "sldt_writes_destination",
                    target_operand = 1,
                    role = "written with local descriptor table selector by sldt",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "str",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "str_writes_destination",
                    target_operand = 1,
                    role = "written with task register selector by str",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "smsw",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "smsw_writes_destination",
                    target_operand = 1,
                    role = "written with machine status word by smsw",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdfsbase",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "rdfsbase_writes_destination",
                    target_operand = 1,
                    role = "written with fs base by rdfsbase",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdgsbase",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "rdgsbase_writes_destination",
                    target_operand = 1,
                    role = "written with gs base by rdgsbase",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vmclear",
                operands = {
                    { index = 1, role = "vmcs_region" },
                },
                effect = {
                    kind = "register_write",
                    name = "vmclear_updates_rflags",
                    target_register = "rflags",
                    role = "updated by vmclear",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vmptrld",
                operands = {
                    { index = 1, role = "vmcs_region" },
                },
                effect = {
                    kind = "register_write",
                    name = "vmptrld_updates_rflags",
                    target_register = "rflags",
                    role = "updated by vmptrld",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vmread",
                operands = {
                    { index = 1, role = "field" },
                    { index = 2, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "vmread_writes_destination",
                    target_operand = 2,
                    role = "written with vmcs field by vmread",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vmread",
                operands = {
                    { index = 1, role = "field" },
                    { index = 2, role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "vmread_updates_rflags",
                    target_register = "rflags",
                    role = "updated by vmread",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "vmwrite",
                operands = {
                    { index = 1, role = "source" },
                    { index = 2, role = "field" },
                },
                effect = {
                    kind = "register_write",
                    name = "vmwrite_updates_rflags",
                    target_register = "rflags",
                    role = "updated by vmwrite",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "invept",
                operands = {
                    { index = 1, role = "type" },
                    { index = 2, role = "descriptor" },
                },
                effect = {
                    kind = "register_write",
                    name = "invept_updates_rflags",
                    target_register = "rflags",
                    role = "updated by invept",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "invvpid",
                operands = {
                    { index = 1, role = "type" },
                    { index = 2, role = "descriptor" },
                },
                effect = {
                    kind = "register_write",
                    name = "invvpid_updates_rflags",
                    target_register = "rflags",
                    role = "updated by invvpid",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "stgi",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "stgi_updates_system_state",
                    target_register = "rflags",
                    role = "global interrupt flag set by stgi",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "clgi",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "clgi_updates_system_state",
                    target_register = "rflags",
                    role = "global interrupt flag cleared by clgi",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "fstsw",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "fstsw_writes_register",
                    target_operand = 1,
                    role = "written with x87 status word by fstsw",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "fnstsw",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "fnstsw_writes_register",
                    target_operand = 1,
                    role = "written with x87 status word by fnstsw",
                },
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
                mnemonic = "vmovmskps",
                operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "vmovmskps_writes_gpr",
                    target_operand = 1,
                    role = "written with packed single-precision sign mask by vmovmskps",
                },
            }
,

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
            }
,

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
            }
,

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
                mnemonic = "rdsspd",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "rdsspd_writes_gpr",
                    target_operand = 1,
                    role = "written with 32-bit shadow stack pointer by rdsspd",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdsspq",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "rdsspq_writes_gpr",
                    target_operand = 1,
                    role = "written with 64-bit shadow stack pointer by rdsspq",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdpru",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdpru_writes_rax",
                    target_register = "rax",
                    role = "written with processor register value low by rdpru",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdpru",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdpru_writes_rdx",
                    target_register = "rdx",
                    role = "written with processor register value high by rdpru",
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
                mnemonic = "rdpid",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "rdpid_writes_destination",
                    target_operand = 1,
                    role = "written with processor id by rdpid",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdrand",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "rdrand_updates_rflags",
                    target_register = "rflags",
                    role = "updated by hardware random value generation rdrand",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdseed",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "rdseed_updates_rflags",
                    target_register = "rflags",
                    role = "updated by hardware seed generation rdseed",
                },
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

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
            }
,

    {
                node_type = "instruction",
                mnemonic = "cpuid",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cpuid_writes_rax",
                    target_register = "rax",
                    role = "written with processor identification leaf result by cpuid",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "cpuid",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cpuid_writes_rbx",
                    target_register = "rbx",
                    role = "written with processor identification leaf result by cpuid",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "cpuid",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cpuid_writes_rcx",
                    target_register = "rcx",
                    role = "written with processor identification leaf result by cpuid",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "cpuid",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cpuid_writes_rdx",
                    target_register = "rdx",
                    role = "written with processor identification leaf result by cpuid",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdmsr",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdmsr_writes_rax",
                    target_register = "rax",
                    role = "written with model-specific register low value by rdmsr",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdmsr",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdmsr_writes_rdx",
                    target_register = "rdx",
                    role = "written with model-specific register high value by rdmsr",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdpmc",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdpmc_writes_rax",
                    target_register = "rax",
                    role = "written with performance counter low value by rdpmc",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdpmc",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdpmc_writes_rdx",
                    target_register = "rdx",
                    role = "written with performance counter high value by rdpmc",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdtsc",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdtsc_writes_rax",
                    target_register = "rax",
                    role = "written with timestamp counter low value by rdtsc",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdtsc",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdtsc_writes_rdx",
                    target_register = "rdx",
                    role = "written with timestamp counter high value by rdtsc",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdtscp",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdtscp_writes_rax",
                    target_register = "rax",
                    role = "written with timestamp counter low value by rdtscp",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdtscp",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdtscp_writes_rdx",
                    target_register = "rdx",
                    role = "written with timestamp counter high value by rdtscp",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdtscp",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "rdtscp_writes_rcx",
                    target_register = "rcx",
                    role = "written with auxiliary timestamp value by rdtscp",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdrand",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "rdrand_writes_destination",
                    target_operand = 1,
                    role = "written with random value by rdrand",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdrand",
                operands = {
                    { index = 1, role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "rdrand_updates_rflags",
                    target_register = "rflags",
                    role = "updated with random-value availability status by rdrand",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdseed",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "rdseed_writes_destination",
                    target_operand = 1,
                    role = "written with random seed value by rdseed",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "rdseed",
                operands = {
                    { index = 1, role = "destination" },
                },
                effect = {
                    kind = "register_write",
                    name = "rdseed_updates_rflags",
                    target_register = "rflags",
                    role = "updated with random-seed availability status by rdseed",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "xgetbv",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "xgetbv_writes_rax",
                    target_register = "rax",
                    role = "written with extended control register low value by xgetbv",
                },
            }
,

    {
                node_type = "instruction",
                mnemonic = "xgetbv",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "xgetbv_writes_rdx",
                    target_register = "rdx",
                    role = "written with extended control register high value by xgetbv",
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
