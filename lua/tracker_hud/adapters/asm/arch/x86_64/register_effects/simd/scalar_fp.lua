-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/scalar_fp.lua

-- x86-64 SIMD register effect specs: scalar fp.

return {
    -- AVX state helpers.
        {
            node_type = "instruction",
            mnemonic = "vzeroupper",
            operands = {},
            effect = {
                kind = "register_write",
                name = "vzeroupper_updates_vector_state",
                target_register = "rip",
                role = "zeroed upper vector register state by vzeroupper",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vzeroall",
            operands = {},
            effect = {
                kind = "register_write",
                name = "vzeroall_updates_vector_state",
                target_register = "rip",
                role = "zeroed all vector register state by vzeroall",
            },
        }
,

    -- FMA / FMA3 vector fused arithmetic visibility.
        -- Phase-one model: no vector register file yet, so vector-only effects are exposed as RIP-side activity.
    
        {
            node_type = "instruction",
            mnemonic = "vfmadd132ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd132ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed single-precision values by vfmadd132ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd213ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd213ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed single-precision values by vfmadd213ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd231ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd231ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed single-precision values by vfmadd231ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd132pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd132pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed double-precision values by vfmadd132pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd213pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd213pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed double-precision values by vfmadd213pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd231pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd231pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-added packed double-precision values by vfmadd231pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd132ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd132ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar single-precision value by vfmadd132ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd213ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd213ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar single-precision value by vfmadd213ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd231ss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd231ss_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar single-precision value by vfmadd231ss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd132sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd132sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar double-precision value by vfmadd132sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd213sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd213sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar double-precision value by vfmadd213sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmadd231sd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmadd231sd_scalar_fma",
                target_register = "rip",
                role = "fused multiply-added scalar double-precision value by vfmadd231sd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub132ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub132ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed single-precision values by vfmsub132ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub213ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub213ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed single-precision values by vfmsub213ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub231ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub231ps_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed single-precision values by vfmsub231ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub132pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub132pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed double-precision values by vfmsub132pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub213pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub213pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed double-precision values by vfmsub213pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsub231pd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsub231pd_vector_fma",
                target_register = "rip",
                role = "fused multiply-subtracted packed double-precision values by vfmsub231pd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmadd132ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd132ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed single-precision values by vfnmadd132ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmadd213ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd213ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed single-precision values by vfnmadd213ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmadd231ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmadd231ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-added packed single-precision values by vfnmadd231ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsub132ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub132ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed single-precision values by vfnmsub132ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsub213ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub213ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed single-precision values by vfnmsub213ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfnmsub231ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfnmsub231ps_vector_fma",
                target_register = "rip",
                role = "negative fused multiply-subtracted packed single-precision values by vfnmsub231ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmaddsub132ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddsub132ps_vector_fma",
                target_register = "rip",
                role = "fused alternating add-sub packed single-precision values by vfmaddsub132ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmaddsub213ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddsub213ps_vector_fma",
                target_register = "rip",
                role = "fused alternating add-sub packed single-precision values by vfmaddsub213ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmaddsub231ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmaddsub231ps_vector_fma",
                target_register = "rip",
                role = "fused alternating add-sub packed single-precision values by vfmaddsub231ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsubadd132ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubadd132ps_vector_fma",
                target_register = "rip",
                role = "fused alternating sub-add packed single-precision values by vfmsubadd132ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsubadd213ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubadd213ps_vector_fma",
                target_register = "rip",
                role = "fused alternating sub-add packed single-precision values by vfmsubadd213ps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vfmsubadd231ps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vfmsubadd231ps_vector_fma",
                target_register = "rip",
                role = "fused alternating sub-add packed single-precision values by vfmsubadd231ps",
            },
        }
,

    -- Rounding / dot product / horizontal operations.
    
        {
            node_type = "instruction",
            mnemonic = "roundps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "roundps_vector_round",
                target_register = "rip",
                role = "rounded packed single-precision values by roundps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "roundpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "roundpd_vector_round",
                target_register = "rip",
                role = "rounded packed double-precision values by roundpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "roundss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "roundss_scalar_round",
                target_register = "rip",
                role = "rounded scalar single-precision value by roundss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "roundsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "roundsd_scalar_round",
                target_register = "rip",
                role = "rounded scalar double-precision value by roundsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vroundps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "vroundps_vector_round",
                target_register = "rip",
                role = "rounded packed single-precision values by vroundps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vroundpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "vroundpd_vector_round",
                target_register = "rip",
                role = "rounded packed double-precision values by vroundpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vroundss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "vroundss_scalar_round",
                target_register = "rip",
                role = "rounded scalar single-precision value by vroundss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vroundsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "mode" },
            },
            effect = {
                kind = "register_write",
                name = "vroundsd_scalar_round",
                target_register = "rip",
                role = "rounded scalar double-precision value by vroundsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vdpps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vdpps_vector_dot_product",
                target_register = "rip",
                role = "computed packed single-precision dot product by vdpps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vdppd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vdppd_vector_dot_product",
                target_register = "rip",
                role = "computed packed double-precision dot product by vdppd",
            },
        }
,

    -- Broadcast / gather / mask-load-store / vector insert-extract.
    
        {
            node_type = "instruction",
            mnemonic = "vbroadcastss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastss_vector_broadcast",
                target_register = "rip",
                role = "broadcast scalar single-precision value by vbroadcastss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcastsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastsd_vector_broadcast",
                target_register = "rip",
                role = "broadcast scalar double-precision value by vbroadcastsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcastf128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcastf128_vector_broadcast",
                target_register = "rip",
                role = "broadcast 128-bit floating vector by vbroadcastf128",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vbroadcasti128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vbroadcasti128_vector_broadcast",
                target_register = "rip",
                role = "broadcast 128-bit integer vector by vbroadcasti128",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vgatherdps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vgatherdps_vector_gather",
                target_register = "rip",
                role = "gathered packed single-precision values by vgatherdps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vgatherdpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vgatherdpd_vector_gather",
                target_register = "rip",
                role = "gathered packed double-precision values by vgatherdpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vgatherqps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vgatherqps_vector_gather",
                target_register = "rip",
                role = "gathered packed single-precision values with quadword indices by vgatherqps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vgatherqpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vgatherqpd_vector_gather",
                target_register = "rip",
                role = "gathered packed double-precision values with quadword indices by vgatherqpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpgatherdd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vpgatherdd_vector_gather",
                target_register = "rip",
                role = "gathered packed doubleword integers by vpgatherdd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpgatherdq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vpgatherdq_vector_gather",
                target_register = "rip",
                role = "gathered packed quadword integers with doubleword indices by vpgatherdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpgatherqd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vpgatherqd_vector_gather",
                target_register = "rip",
                role = "gathered packed doubleword integers with quadword indices by vpgatherqd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpgatherqq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "memory" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "vpgatherqq_vector_gather",
                target_register = "rip",
                role = "gathered packed quadword integers by vpgatherqq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmaskmovd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmaskmovd_vector_mask_move",
                target_register = "rip",
                role = "masked moved packed doubleword integers by vpmaskmovd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpmaskmovq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vpmaskmovq_vector_mask_move",
                target_register = "rip",
                role = "masked moved packed quadword integers by vpmaskmovq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vextractf128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vextractf128_vector_extract",
                target_register = "rip",
                role = "extracted 128-bit floating lane by vextractf128",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vinsertf128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vinsertf128_vector_insert",
                target_register = "rip",
                role = "inserted 128-bit floating lane by vinsertf128",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vextracti128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vextracti128_vector_extract",
                target_register = "rip",
                role = "extracted 128-bit integer lane by vextracti128",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vinserti128",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "source" },
                { index = 4, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "vinserti128_vector_insert",
                target_register = "rip",
                role = "inserted 128-bit integer lane by vinserti128",
            },
        }
,

}

