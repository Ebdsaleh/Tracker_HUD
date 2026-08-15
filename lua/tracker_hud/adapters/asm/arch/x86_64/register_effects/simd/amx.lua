-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/simd/amx.lua

-- x86-64 SIMD register effect specs: amx.

return {
    {
                node_type = "instruction",
                mnemonic = "kmovb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "kmovb_mask_move",
                    target_register = "rip",
                    role = "moved byte mask register state by kmovb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kmovw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "kmovw_mask_move",
                    target_register = "rip",
                    role = "moved word mask register state by kmovw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kmovd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "kmovd_mask_move",
                    target_register = "rip",
                    role = "moved doubleword mask register state by kmovd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kmovq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "kmovq_mask_move",
                    target_register = "rip",
                    role = "moved quadword mask register state by kmovq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kandb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kandb_mask_logic",
                    target_register = "rip",
                    role = "bitwise-and byte mask state by kandb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kandw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kandw_mask_logic",
                    target_register = "rip",
                    role = "bitwise-and word mask state by kandw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kandd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kandd_mask_logic",
                    target_register = "rip",
                    role = "bitwise-and doubleword mask state by kandd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kandq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kandq_mask_logic",
                    target_register = "rip",
                    role = "bitwise-and quadword mask state by kandq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kandnb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kandnb_mask_logic",
                    target_register = "rip",
                    role = "bitwise-and-not byte mask state by kandnb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kandnw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kandnw_mask_logic",
                    target_register = "rip",
                    role = "bitwise-and-not word mask state by kandnw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kandnd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kandnd_mask_logic",
                    target_register = "rip",
                    role = "bitwise-and-not doubleword mask state by kandnd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kandnq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kandnq_mask_logic",
                    target_register = "rip",
                    role = "bitwise-and-not quadword mask state by kandnq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "korb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "korb_mask_logic",
                    target_register = "rip",
                    role = "bitwise-or byte mask state by korb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "korw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "korw_mask_logic",
                    target_register = "rip",
                    role = "bitwise-or word mask state by korw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kord",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kord_mask_logic",
                    target_register = "rip",
                    role = "bitwise-or doubleword mask state by kord",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "korq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "korq_mask_logic",
                    target_register = "rip",
                    role = "bitwise-or quadword mask state by korq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kxorb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kxorb_mask_logic",
                    target_register = "rip",
                    role = "bitwise-xor byte mask state by kxorb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kxorw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kxorw_mask_logic",
                    target_register = "rip",
                    role = "bitwise-xor word mask state by kxorw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kxord",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kxord_mask_logic",
                    target_register = "rip",
                    role = "bitwise-xor doubleword mask state by kxord",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kxorq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kxorq_mask_logic",
                    target_register = "rip",
                    role = "bitwise-xor quadword mask state by kxorq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "knotb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "knotb_mask_logic",
                    target_register = "rip",
                    role = "bitwise-inverted byte mask state by knotb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "knotw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "knotw_mask_logic",
                    target_register = "rip",
                    role = "bitwise-inverted word mask state by knotw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "knotd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "knotd_mask_logic",
                    target_register = "rip",
                    role = "bitwise-inverted doubleword mask state by knotd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "knotq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "knotq_mask_logic",
                    target_register = "rip",
                    role = "bitwise-inverted quadword mask state by knotq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kaddb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kaddb_mask_add",
                    target_register = "rip",
                    role = "added byte mask state by kaddb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kaddw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kaddw_mask_add",
                    target_register = "rip",
                    role = "added word mask state by kaddw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kaddd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kaddd_mask_add",
                    target_register = "rip",
                    role = "added doubleword mask state by kaddd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kaddq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kaddq_mask_add",
                    target_register = "rip",
                    role = "added quadword mask state by kaddq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kshiftlb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "count" },
                },
                effect = {
                    kind = "register_write",
                    name = "kshiftlb_mask_shift",
                    target_register = "rip",
                    role = "shifted byte mask state left by kshiftlb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kshiftlw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "count" },
                },
                effect = {
                    kind = "register_write",
                    name = "kshiftlw_mask_shift",
                    target_register = "rip",
                    role = "shifted word mask state left by kshiftlw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kshiftld",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "count" },
                },
                effect = {
                    kind = "register_write",
                    name = "kshiftld_mask_shift",
                    target_register = "rip",
                    role = "shifted doubleword mask state left by kshiftld",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kshiftlq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "count" },
                },
                effect = {
                    kind = "register_write",
                    name = "kshiftlq_mask_shift",
                    target_register = "rip",
                    role = "shifted quadword mask state left by kshiftlq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kshiftrb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "count" },
                },
                effect = {
                    kind = "register_write",
                    name = "kshiftrb_mask_shift",
                    target_register = "rip",
                    role = "shifted byte mask state right by kshiftrb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kshiftrw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "count" },
                },
                effect = {
                    kind = "register_write",
                    name = "kshiftrw_mask_shift",
                    target_register = "rip",
                    role = "shifted word mask state right by kshiftrw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kshiftrd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "count" },
                },
                effect = {
                    kind = "register_write",
                    name = "kshiftrd_mask_shift",
                    target_register = "rip",
                    role = "shifted doubleword mask state right by kshiftrd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kshiftrq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "count" },
                },
                effect = {
                    kind = "register_write",
                    name = "kshiftrq_mask_shift",
                    target_register = "rip",
                    role = "shifted quadword mask state right by kshiftrq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kortestb",
                operands = {
                    { index = 1, role = "left" },
                    { index = 2, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kortestb_updates_rflags",
                    target_register = "rflags",
                    role = "updated by byte mask or-test kortestb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kortestw",
                operands = {
                    { index = 1, role = "left" },
                    { index = 2, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kortestw_updates_rflags",
                    target_register = "rflags",
                    role = "updated by word mask or-test kortestw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kortestd",
                operands = {
                    { index = 1, role = "left" },
                    { index = 2, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kortestd_updates_rflags",
                    target_register = "rflags",
                    role = "updated by doubleword mask or-test kortestd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "kortestq",
                operands = {
                    { index = 1, role = "left" },
                    { index = 2, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "kortestq_updates_rflags",
                    target_register = "rflags",
                    role = "updated by quadword mask or-test kortestq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "ktestb",
                operands = {
                    { index = 1, role = "left" },
                    { index = 2, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "ktestb_updates_rflags",
                    target_register = "rflags",
                    role = "updated by byte mask test ktestb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "ktestw",
                operands = {
                    { index = 1, role = "left" },
                    { index = 2, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "ktestw_updates_rflags",
                    target_register = "rflags",
                    role = "updated by word mask test ktestw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "ktestd",
                operands = {
                    { index = 1, role = "left" },
                    { index = 2, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "ktestd_updates_rflags",
                    target_register = "rflags",
                    role = "updated by doubleword mask test ktestd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "ktestq",
                operands = {
                    { index = 1, role = "left" },
                    { index = 2, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "ktestq_updates_rflags",
                    target_register = "rflags",
                    role = "updated by quadword mask test ktestq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcompressps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcompressps_vector_compress",
                    target_register = "rip",
                    role = "compressed packed single-precision values by vcompressps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcompresspd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcompresspd_vector_compress",
                    target_register = "rip",
                    role = "compressed packed double-precision values by vcompresspd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpcompressd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpcompressd_vector_compress",
                    target_register = "rip",
                    role = "compressed packed doubleword integers by vpcompressd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpcompressq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpcompressq_vector_compress",
                    target_register = "rip",
                    role = "compressed packed quadword integers by vpcompressq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vexpandps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vexpandps_vector_expand",
                    target_register = "rip",
                    role = "expanded packed single-precision values by vexpandps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vexpandpd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vexpandpd_vector_expand",
                    target_register = "rip",
                    role = "expanded packed double-precision values by vexpandpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpexpandd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpexpandd_vector_expand",
                    target_register = "rip",
                    role = "expanded packed doubleword integers by vpexpandd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpexpandq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpexpandq_vector_expand",
                    target_register = "rip",
                    role = "expanded packed quadword integers by vpexpandq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vscatterdps",
                operands = {
                    { index = 1, role = "memory" },
                    { index = 2, role = "mask" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vscatterdps_vector_scatter",
                    target_register = "rip",
                    role = "scattered packed single-precision values by vscatterdps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vscatterdpd",
                operands = {
                    { index = 1, role = "memory" },
                    { index = 2, role = "mask" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vscatterdpd_vector_scatter",
                    target_register = "rip",
                    role = "scattered packed double-precision values by vscatterdpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vscatterqps",
                operands = {
                    { index = 1, role = "memory" },
                    { index = 2, role = "mask" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vscatterqps_vector_scatter",
                    target_register = "rip",
                    role = "scattered packed single-precision values with quadword indices by vscatterqps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vscatterqpd",
                operands = {
                    { index = 1, role = "memory" },
                    { index = 2, role = "mask" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vscatterqpd_vector_scatter",
                    target_register = "rip",
                    role = "scattered packed double-precision values with quadword indices by vscatterqpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpscatterdd",
                operands = {
                    { index = 1, role = "memory" },
                    { index = 2, role = "mask" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpscatterdd_vector_scatter",
                    target_register = "rip",
                    role = "scattered packed doubleword integers by vpscatterdd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpscatterdq",
                operands = {
                    { index = 1, role = "memory" },
                    { index = 2, role = "mask" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpscatterdq_vector_scatter",
                    target_register = "rip",
                    role = "scattered packed quadword integers with doubleword indices by vpscatterdq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpscatterqd",
                operands = {
                    { index = 1, role = "memory" },
                    { index = 2, role = "mask" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpscatterqd_vector_scatter",
                    target_register = "rip",
                    role = "scattered packed doubleword integers with quadword indices by vpscatterqd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpscatterqq",
                operands = {
                    { index = 1, role = "memory" },
                    { index = 2, role = "mask" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpscatterqq_vector_scatter",
                    target_register = "rip",
                    role = "scattered packed quadword integers by vpscatterqq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpconflictd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpconflictd_vector_conflict",
                    target_register = "rip",
                    role = "detected packed doubleword conflicts by vpconflictd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpconflictq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpconflictq_vector_conflict",
                    target_register = "rip",
                    role = "detected packed quadword conflicts by vpconflictq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpternlogd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "truth_table" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpternlogd_vector_logic",
                    target_register = "rip",
                    role = "applied ternary logic to packed doublewords by vpternlogd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpternlogq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "truth_table" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpternlogq_vector_logic",
                    target_register = "rip",
                    role = "applied ternary logic to packed quadwords by vpternlogq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vplzcntd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vplzcntd_vector_count",
                    target_register = "rip",
                    role = "counted leading zero bits in packed doublewords by vplzcntd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vplzcntq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vplzcntq_vector_count",
                    target_register = "rip",
                    role = "counted leading zero bits in packed quadwords by vplzcntq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpbroadcastb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpbroadcastb_vector_broadcast",
                    target_register = "rip",
                    role = "broadcast byte integer by vpbroadcastb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpbroadcastw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpbroadcastw_vector_broadcast",
                    target_register = "rip",
                    role = "broadcast word integer by vpbroadcastw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpbroadcastd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpbroadcastd_vector_broadcast",
                    target_register = "rip",
                    role = "broadcast doubleword integer by vpbroadcastd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpbroadcastq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpbroadcastq_vector_broadcast",
                    target_register = "rip",
                    role = "broadcast quadword integer by vpbroadcastq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vbroadcastf32x2",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vbroadcastf32x2_vector_broadcast",
                    target_register = "rip",
                    role = "broadcast two packed single-precision values by vbroadcastf32x2",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vbroadcastf32x4",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vbroadcastf32x4_vector_broadcast",
                    target_register = "rip",
                    role = "broadcast four packed single-precision values by vbroadcastf32x4",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vbroadcastf32x8",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vbroadcastf32x8_vector_broadcast",
                    target_register = "rip",
                    role = "broadcast eight packed single-precision values by vbroadcastf32x8",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vbroadcastf64x2",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vbroadcastf64x2_vector_broadcast",
                    target_register = "rip",
                    role = "broadcast two packed double-precision values by vbroadcastf64x2",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vbroadcastf64x4",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vbroadcastf64x4_vector_broadcast",
                    target_register = "rip",
                    role = "broadcast four packed double-precision values by vbroadcastf64x4",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vbroadcasti32x2",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vbroadcasti32x2_vector_broadcast",
                    target_register = "rip",
                    role = "broadcast two packed doubleword integers by vbroadcasti32x2",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vbroadcasti32x4",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vbroadcasti32x4_vector_broadcast",
                    target_register = "rip",
                    role = "broadcast four packed doubleword integers by vbroadcasti32x4",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vbroadcasti32x8",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vbroadcasti32x8_vector_broadcast",
                    target_register = "rip",
                    role = "broadcast eight packed doubleword integers by vbroadcasti32x8",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vbroadcasti64x2",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vbroadcasti64x2_vector_broadcast",
                    target_register = "rip",
                    role = "broadcast two packed quadword integers by vbroadcasti64x2",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vbroadcasti64x4",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vbroadcasti64x4_vector_broadcast",
                    target_register = "rip",
                    role = "broadcast four packed quadword integers by vbroadcasti64x4",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vextractf32x4",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vextractf32x4_vector_extract",
                    target_register = "rip",
                    role = "extracted 128-bit single-precision lane by vextractf32x4",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vextractf32x8",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vextractf32x8_vector_extract",
                    target_register = "rip",
                    role = "extracted 256-bit single-precision lane by vextractf32x8",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vextractf64x2",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vextractf64x2_vector_extract",
                    target_register = "rip",
                    role = "extracted 128-bit double-precision lane by vextractf64x2",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vextractf64x4",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vextractf64x4_vector_extract",
                    target_register = "rip",
                    role = "extracted 256-bit double-precision lane by vextractf64x4",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vextracti32x4",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vextracti32x4_vector_extract",
                    target_register = "rip",
                    role = "extracted 128-bit doubleword integer lane by vextracti32x4",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vextracti32x8",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vextracti32x8_vector_extract",
                    target_register = "rip",
                    role = "extracted 256-bit doubleword integer lane by vextracti32x8",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vextracti64x2",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vextracti64x2_vector_extract",
                    target_register = "rip",
                    role = "extracted 128-bit quadword integer lane by vextracti64x2",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vextracti64x4",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vextracti64x4_vector_extract",
                    target_register = "rip",
                    role = "extracted 256-bit quadword integer lane by vextracti64x4",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vinsertf32x4",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                    { index = 4, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vinsertf32x4_vector_insert",
                    target_register = "rip",
                    role = "inserted 128-bit single-precision lane by vinsertf32x4",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vinsertf32x8",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                    { index = 4, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vinsertf32x8_vector_insert",
                    target_register = "rip",
                    role = "inserted 256-bit single-precision lane by vinsertf32x8",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vinsertf64x2",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                    { index = 4, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vinsertf64x2_vector_insert",
                    target_register = "rip",
                    role = "inserted 128-bit double-precision lane by vinsertf64x2",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vinsertf64x4",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                    { index = 4, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vinsertf64x4_vector_insert",
                    target_register = "rip",
                    role = "inserted 256-bit double-precision lane by vinsertf64x4",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vinserti32x4",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                    { index = 4, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vinserti32x4_vector_insert",
                    target_register = "rip",
                    role = "inserted 128-bit doubleword integer lane by vinserti32x4",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vinserti32x8",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                    { index = 4, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vinserti32x8_vector_insert",
                    target_register = "rip",
                    role = "inserted 256-bit doubleword integer lane by vinserti32x8",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vinserti64x2",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                    { index = 4, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vinserti64x2_vector_insert",
                    target_register = "rip",
                    role = "inserted 128-bit quadword integer lane by vinserti64x2",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vinserti64x4",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                    { index = 4, role = "index" },
                },
                effect = {
                    kind = "register_write",
                    name = "vinserti64x4_vector_insert",
                    target_register = "rip",
                    role = "inserted 256-bit quadword integer lane by vinserti64x4",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpcmpb",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "predicate" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpcmpb_vector_compare_mask",
                    target_register = "rip",
                    role = "compared packed signed bytes into mask by vpcmpb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpcmpw",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "predicate" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpcmpw_vector_compare_mask",
                    target_register = "rip",
                    role = "compared packed signed words into mask by vpcmpw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpcmpd",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "predicate" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpcmpd_vector_compare_mask",
                    target_register = "rip",
                    role = "compared packed signed doublewords into mask by vpcmpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpcmpq",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "predicate" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpcmpq_vector_compare_mask",
                    target_register = "rip",
                    role = "compared packed signed quadwords into mask by vpcmpq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpcmpub",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "predicate" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpcmpub_vector_compare_mask",
                    target_register = "rip",
                    role = "compared packed unsigned bytes into mask by vpcmpub",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpcmpuw",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "predicate" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpcmpuw_vector_compare_mask",
                    target_register = "rip",
                    role = "compared packed unsigned words into mask by vpcmpuw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpcmpud",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "predicate" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpcmpud_vector_compare_mask",
                    target_register = "rip",
                    role = "compared packed unsigned doublewords into mask by vpcmpud",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpcmpuq",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "predicate" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpcmpuq_vector_compare_mask",
                    target_register = "rip",
                    role = "compared packed unsigned quadwords into mask by vpcmpuq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vfpclassps",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "class_mask" },
                },
                effect = {
                    kind = "register_write",
                    name = "vfpclassps_vector_class_mask",
                    target_register = "rip",
                    role = "classified packed single-precision values into mask by vfpclassps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vfpclasspd",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "class_mask" },
                },
                effect = {
                    kind = "register_write",
                    name = "vfpclasspd_vector_class_mask",
                    target_register = "rip",
                    role = "classified packed double-precision values into mask by vfpclasspd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vfpclassss",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "class_mask" },
                },
                effect = {
                    kind = "register_write",
                    name = "vfpclassss_scalar_class_mask",
                    target_register = "rip",
                    role = "classified scalar single-precision value into mask by vfpclassss",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vfpclasssd",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "class_mask" },
                },
                effect = {
                    kind = "register_write",
                    name = "vfpclasssd_scalar_class_mask",
                    target_register = "rip",
                    role = "classified scalar double-precision value into mask by vfpclasssd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vptestmb",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vptestmb_vector_mask_test",
                    target_register = "rip",
                    role = "tested packed byte masks by vptestmb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vptestmw",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vptestmw_vector_mask_test",
                    target_register = "rip",
                    role = "tested packed word masks by vptestmw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vptestmd",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vptestmd_vector_mask_test",
                    target_register = "rip",
                    role = "tested packed doubleword masks by vptestmd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vptestmq",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vptestmq_vector_mask_test",
                    target_register = "rip",
                    role = "tested packed quadword masks by vptestmq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vptestnmb",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vptestnmb_vector_mask_test",
                    target_register = "rip",
                    role = "tested packed byte inverted masks by vptestnmb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vptestnmw",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vptestnmw_vector_mask_test",
                    target_register = "rip",
                    role = "tested packed word inverted masks by vptestnmw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vptestnmd",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vptestnmd_vector_mask_test",
                    target_register = "rip",
                    role = "tested packed doubleword inverted masks by vptestnmd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vptestnmq",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vptestnmq_vector_mask_test",
                    target_register = "rip",
                    role = "tested packed quadword inverted masks by vptestnmq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtps2qq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtps2qq_vector_convert",
                    target_register = "rip",
                    role = "converted packed single-precision values to signed quadword integers by vcvtps2qq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtps2uqq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtps2uqq_vector_convert",
                    target_register = "rip",
                    role = "converted packed single-precision values to unsigned quadword integers by vcvtps2uqq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtpd2qq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtpd2qq_vector_convert",
                    target_register = "rip",
                    role = "converted packed double-precision values to signed quadword integers by vcvtpd2qq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtpd2uqq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtpd2uqq_vector_convert",
                    target_register = "rip",
                    role = "converted packed double-precision values to unsigned quadword integers by vcvtpd2uqq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtqq2ps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtqq2ps_vector_convert",
                    target_register = "rip",
                    role = "converted packed signed quadword integers to single-precision values by vcvtqq2ps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtuqq2ps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtuqq2ps_vector_convert",
                    target_register = "rip",
                    role = "converted packed unsigned quadword integers to single-precision values by vcvtuqq2ps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtqq2pd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtqq2pd_vector_convert",
                    target_register = "rip",
                    role = "converted packed signed quadword integers to double-precision values by vcvtqq2pd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtuqq2pd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtuqq2pd_vector_convert",
                    target_register = "rip",
                    role = "converted packed unsigned quadword integers to double-precision values by vcvtuqq2pd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvttps2qq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvttps2qq_vector_convert",
                    target_register = "rip",
                    role = "converted packed single-precision values to signed quadword integers with truncation by vcvttps2qq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvttps2uqq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvttps2uqq_vector_convert",
                    target_register = "rip",
                    role = "converted packed single-precision values to unsigned quadword integers with truncation by vcvttps2uqq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvttpd2qq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvttpd2qq_vector_convert",
                    target_register = "rip",
                    role = "converted packed double-precision values to signed quadword integers with truncation by vcvttpd2qq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvttpd2uqq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvttpd2uqq_vector_convert",
                    target_register = "rip",
                    role = "converted packed double-precision values to unsigned quadword integers with truncation by vcvttpd2uqq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtudq2ps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtudq2ps_vector_convert",
                    target_register = "rip",
                    role = "converted packed unsigned doubleword integers to single-precision values by vcvtudq2ps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtudq2pd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtudq2pd_vector_convert",
                    target_register = "rip",
                    role = "converted packed unsigned doubleword integers to double-precision values by vcvtudq2pd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtps2udq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtps2udq_vector_convert",
                    target_register = "rip",
                    role = "converted packed single-precision values to unsigned doubleword integers by vcvtps2udq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtpd2udq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtpd2udq_vector_convert",
                    target_register = "rip",
                    role = "converted packed double-precision values to unsigned doubleword integers by vcvtpd2udq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvttps2udq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvttps2udq_vector_convert",
                    target_register = "rip",
                    role = "converted packed single-precision values to unsigned doubleword integers with truncation by vcvttps2udq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvttpd2udq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvttpd2udq_vector_convert",
                    target_register = "rip",
                    role = "converted packed double-precision values to unsigned doubleword integers with truncation by vcvttpd2udq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovdb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovdb_vector_narrow",
                    target_register = "rip",
                    role = "narrowed packed doubleword integers to bytes by vpmovdb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovdw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovdw_vector_narrow",
                    target_register = "rip",
                    role = "narrowed packed doubleword integers to words by vpmovdw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovqb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovqb_vector_narrow",
                    target_register = "rip",
                    role = "narrowed packed quadword integers to bytes by vpmovqb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovqw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovqw_vector_narrow",
                    target_register = "rip",
                    role = "narrowed packed quadword integers to words by vpmovqw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovqd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovqd_vector_narrow",
                    target_register = "rip",
                    role = "narrowed packed quadword integers to doublewords by vpmovqd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovsdb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovsdb_vector_signed_saturating_narrow",
                    target_register = "rip",
                    role = "signed-saturating narrowed packed doubleword integers to bytes by vpmovsdb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovsdw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovsdw_vector_signed_saturating_narrow",
                    target_register = "rip",
                    role = "signed-saturating narrowed packed doubleword integers to words by vpmovsdw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovsqb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovsqb_vector_signed_saturating_narrow",
                    target_register = "rip",
                    role = "signed-saturating narrowed packed quadword integers to bytes by vpmovsqb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovsqw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovsqw_vector_signed_saturating_narrow",
                    target_register = "rip",
                    role = "signed-saturating narrowed packed quadword integers to words by vpmovsqw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovsqd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovsqd_vector_signed_saturating_narrow",
                    target_register = "rip",
                    role = "signed-saturating narrowed packed quadword integers to doublewords by vpmovsqd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovusdb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovusdb_vector_unsigned_saturating_narrow",
                    target_register = "rip",
                    role = "unsigned-saturating narrowed packed doubleword integers to bytes by vpmovusdb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovusdw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovusdw_vector_unsigned_saturating_narrow",
                    target_register = "rip",
                    role = "unsigned-saturating narrowed packed doubleword integers to words by vpmovusdw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovusqb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovusqb_vector_unsigned_saturating_narrow",
                    target_register = "rip",
                    role = "unsigned-saturating narrowed packed quadword integers to bytes by vpmovusqb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovusqw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovusqw_vector_unsigned_saturating_narrow",
                    target_register = "rip",
                    role = "unsigned-saturating narrowed packed quadword integers to words by vpmovusqw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovusqd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovusqd_vector_unsigned_saturating_narrow",
                    target_register = "rip",
                    role = "unsigned-saturating narrowed packed quadword integers to doublewords by vpmovusqd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovb2m",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovb2m_vector_to_mask",
                    target_register = "rip",
                    role = "moved packed byte sign bits into mask by vpmovb2m",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovw2m",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovw2m_vector_to_mask",
                    target_register = "rip",
                    role = "moved packed word sign bits into mask by vpmovw2m",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovd2m",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovd2m_vector_to_mask",
                    target_register = "rip",
                    role = "moved packed doubleword sign bits into mask by vpmovd2m",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovq2m",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovq2m_vector_to_mask",
                    target_register = "rip",
                    role = "moved packed quadword sign bits into mask by vpmovq2m",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovm2b",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "mask_source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovm2b_mask_to_vector",
                    target_register = "rip",
                    role = "expanded mask bits into packed bytes by vpmovm2b",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovm2w",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "mask_source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovm2w_mask_to_vector",
                    target_register = "rip",
                    role = "expanded mask bits into packed words by vpmovm2w",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovm2d",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "mask_source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovm2d_mask_to_vector",
                    target_register = "rip",
                    role = "expanded mask bits into packed doublewords by vpmovm2d",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpmovm2q",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "mask_source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpmovm2q_mask_to_vector",
                    target_register = "rip",
                    role = "expanded mask bits into packed quadwords by vpmovm2q",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpermb",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "indices" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpermb_vector_permute",
                    target_register = "rip",
                    role = "permuted packed bytes by vpermb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpermw",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "indices" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpermw_vector_permute",
                    target_register = "rip",
                    role = "permuted packed words by vpermw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpermd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "indices" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpermd_vector_permute",
                    target_register = "rip",
                    role = "permuted packed doublewords by vpermd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpermq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "indices" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpermq_vector_permute",
                    target_register = "rip",
                    role = "permuted packed quadwords by vpermq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpermi2b",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "indices" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpermi2b_vector_permute",
                    target_register = "rip",
                    role = "permuted packed bytes using two sources by vpermi2b",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpermi2w",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "indices" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpermi2w_vector_permute",
                    target_register = "rip",
                    role = "permuted packed words using two sources by vpermi2w",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpermi2d",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "indices" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpermi2d_vector_permute",
                    target_register = "rip",
                    role = "permuted packed doublewords using two sources by vpermi2d",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpermi2q",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "indices" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpermi2q_vector_permute",
                    target_register = "rip",
                    role = "permuted packed quadwords using two sources by vpermi2q",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpermt2b",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "indices" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpermt2b_vector_permute",
                    target_register = "rip",
                    role = "permuted packed bytes into second table by vpermt2b",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpermt2w",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "indices" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpermt2w_vector_permute",
                    target_register = "rip",
                    role = "permuted packed words into second table by vpermt2w",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpermt2d",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "indices" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpermt2d_vector_permute",
                    target_register = "rip",
                    role = "permuted packed doublewords into second table by vpermt2d",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpermt2q",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "indices" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpermt2q_vector_permute",
                    target_register = "rip",
                    role = "permuted packed quadwords into second table by vpermt2q",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpdpbusd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "unsigned_bytes" },
                    { index = 3, role = "signed_bytes" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpdpbusd_vector_vnni",
                    target_register = "rip",
                    role = "dot-product accumulated unsigned bytes with signed bytes into doublewords by vpdpbusd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpdpbusds",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "unsigned_bytes" },
                    { index = 3, role = "signed_bytes" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpdpbusds_vector_vnni",
                    target_register = "rip",
                    role = "saturating dot-product accumulated unsigned bytes with signed bytes into doublewords by vpdpbusds",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpdpwssd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left_words" },
                    { index = 3, role = "right_words" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpdpwssd_vector_vnni",
                    target_register = "rip",
                    role = "dot-product accumulated signed words into doublewords by vpdpwssd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vpdpwssds",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left_words" },
                    { index = 3, role = "right_words" },
                },
                effect = {
                    kind = "register_write",
                    name = "vpdpwssds_vector_vnni",
                    target_register = "rip",
                    role = "saturating dot-product accumulated signed words into doublewords by vpdpwssds",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vdpbf16ps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left_bfloat16" },
                    { index = 3, role = "right_bfloat16" },
                },
                effect = {
                    kind = "register_write",
                    name = "vdpbf16ps_vector_bf16",
                    target_register = "rip",
                    role = "dot-product accumulated bfloat16 pairs into single-precision values by vdpbf16ps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtneps2bf16",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtneps2bf16_vector_bf16_convert",
                    target_register = "rip",
                    role = "converted packed single-precision values to nearest-even bfloat16 by vcvtneps2bf16",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtne2ps2bf16",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left_source" },
                    { index = 3, role = "right_source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtne2ps2bf16_vector_bf16_convert",
                    target_register = "rip",
                    role = "converted two packed single-precision sources to nearest-even bfloat16 by vcvtne2ps2bf16",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vaddph",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vaddph_vector_fp16_arithmetic",
                    target_register = "rip",
                    role = "added packed half-precision values by vaddph",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vaddsh",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vaddsh_scalar_fp16_arithmetic",
                    target_register = "rip",
                    role = "added scalar half-precision values by vaddsh",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vsubph",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vsubph_vector_fp16_arithmetic",
                    target_register = "rip",
                    role = "subtracted packed half-precision values by vsubph",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vsubsh",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vsubsh_scalar_fp16_arithmetic",
                    target_register = "rip",
                    role = "subtracted scalar half-precision values by vsubsh",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vdivph",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vdivph_vector_fp16_arithmetic",
                    target_register = "rip",
                    role = "divided packed half-precision values by vdivph",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vdivsh",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vdivsh_scalar_fp16_arithmetic",
                    target_register = "rip",
                    role = "divided scalar half-precision values by vdivsh",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vsqrtph",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vsqrtph_vector_fp16_arithmetic",
                    target_register = "rip",
                    role = "square-rooted packed half-precision values by vsqrtph",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vsqrtsh",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vsqrtsh_scalar_fp16_arithmetic",
                    target_register = "rip",
                    role = "square-rooted scalar half-precision value by vsqrtsh",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcmpph",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "predicate" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcmpph_vector_fp16_compare",
                    target_register = "rip",
                    role = "compared packed half-precision values into mask by vcmpph",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcmpsh",
                operands = {
                    { index = 1, role = "mask_destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "right" },
                    { index = 4, role = "predicate" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcmpsh_scalar_fp16_compare",
                    target_register = "rip",
                    role = "compared scalar half-precision values into mask by vcmpsh",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcomish",
                operands = {
                    { index = 1, role = "left" },
                    { index = 2, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcomish_updates_rflags",
                    target_register = "rflags",
                    role = "updated by scalar half-precision compare vcomish",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vucomish",
                operands = {
                    { index = 1, role = "left" },
                    { index = 2, role = "right" },
                },
                effect = {
                    kind = "register_write",
                    name = "vucomish_updates_rflags",
                    target_register = "rflags",
                    role = "updated by unordered scalar half-precision compare vucomish",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtph2psx",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtph2psx_vector_fp16_convert",
                    target_register = "rip",
                    role = "converted packed half-precision values to single-precision values by vcvtph2psx",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtps2phx",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtps2phx_vector_fp16_convert",
                    target_register = "rip",
                    role = "converted packed single-precision values to half-precision values by vcvtps2phx",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtsh2ss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtsh2ss_scalar_fp16_convert",
                    target_register = "rip",
                    role = "converted scalar half-precision value to single-precision value by vcvtsh2ss",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtss2sh",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "left" },
                    { index = 3, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtss2sh_scalar_fp16_convert",
                    target_register = "rip",
                    role = "converted scalar single-precision value to half-precision value by vcvtss2sh",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtph2dq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtph2dq_vector_fp16_convert",
                    target_register = "rip",
                    role = "converted packed half-precision values to signed doubleword integers by vcvtph2dq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtph2qq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtph2qq_vector_fp16_convert",
                    target_register = "rip",
                    role = "converted packed half-precision values to signed quadword integers by vcvtph2qq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtph2udq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtph2udq_vector_fp16_convert",
                    target_register = "rip",
                    role = "converted packed half-precision values to unsigned doubleword integers by vcvtph2udq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtph2uqq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtph2uqq_vector_fp16_convert",
                    target_register = "rip",
                    role = "converted packed half-precision values to unsigned quadword integers by vcvtph2uqq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtdq2ph",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtdq2ph_vector_fp16_convert",
                    target_register = "rip",
                    role = "converted packed signed doubleword integers to half-precision values by vcvtdq2ph",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtqq2ph",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtqq2ph_vector_fp16_convert",
                    target_register = "rip",
                    role = "converted packed signed quadword integers to half-precision values by vcvtqq2ph",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtudq2ph",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtudq2ph_vector_fp16_convert",
                    target_register = "rip",
                    role = "converted packed unsigned doubleword integers to half-precision values by vcvtudq2ph",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvtuqq2ph",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvtuqq2ph_vector_fp16_convert",
                    target_register = "rip",
                    role = "converted packed unsigned quadword integers to half-precision values by vcvtuqq2ph",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvttph2dq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvttph2dq_vector_fp16_convert",
                    target_register = "rip",
                    role = "converted packed half-precision values to signed doubleword integers with truncation by vcvttph2dq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvttph2qq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvttph2qq_vector_fp16_convert",
                    target_register = "rip",
                    role = "converted packed half-precision values to signed quadword integers with truncation by vcvttph2qq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvttph2udq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvttph2udq_vector_fp16_convert",
                    target_register = "rip",
                    role = "converted packed half-precision values to unsigned doubleword integers with truncation by vcvttph2udq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "vcvttph2uqq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "vcvttph2uqq_vector_fp16_convert",
                    target_register = "rip",
                    role = "converted packed half-precision values to unsigned quadword integers with truncation by vcvttph2uqq",
                },
            },

}
