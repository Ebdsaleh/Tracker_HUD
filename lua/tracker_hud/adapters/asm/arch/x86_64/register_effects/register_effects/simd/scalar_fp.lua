-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/scalar_fp.lua
--
-- x86-64 legacy scalar/vector FP register effects.
--
-- Temporary legacy compatibility during the Tree-sitter-first migration.
-- Only records not yet moved into categorized modules remain here.

return {

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

}
