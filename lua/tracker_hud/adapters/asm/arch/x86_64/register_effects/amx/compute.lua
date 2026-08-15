-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/amx/compute.lua
--
-- x86-64 register effects: amx / compute.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["tdpbssd"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tdpbssd",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "left_tile" },
                { index = 3, role = "right_tile" },
            },
            effect = {
                kind = "register_write",
                name = "tdpbssd_updates_tile_state",
                target_register = "rip",
                role = "dot-product accumulated signed bytes into AMX tile doublewords by tdpbssd",
            },
        },
    },

    ["tdpbsud"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tdpbsud",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "left_tile" },
                { index = 3, role = "right_tile" },
            },
            effect = {
                kind = "register_write",
                name = "tdpbsud_updates_tile_state",
                target_register = "rip",
                role = "dot-product accumulated signed bytes with unsigned bytes into AMX tile doublewords by tdpbsud",
            },
        },
    },

    ["tdpbusd"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tdpbusd",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "left_tile" },
                { index = 3, role = "right_tile" },
            },
            effect = {
                kind = "register_write",
                name = "tdpbusd_updates_tile_state",
                target_register = "rip",
                role = "dot-product accumulated unsigned bytes with signed bytes into AMX tile doublewords by tdpbusd",
            },
        },
    },

    ["tdpbuud"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tdpbuud",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "left_tile" },
                { index = 3, role = "right_tile" },
            },
            effect = {
                kind = "register_write",
                name = "tdpbuud_updates_tile_state",
                target_register = "rip",
                role = "dot-product accumulated unsigned bytes into AMX tile doublewords by tdpbuud",
            },
        },
    },

    ["tdpbf16ps"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tdpbf16ps",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "left_tile" },
                { index = 3, role = "right_tile" },
            },
            effect = {
                kind = "register_write",
                name = "tdpbf16ps_updates_tile_state",
                target_register = "rip",
                role = "dot-product accumulated bfloat16 values into AMX tile single-precision values by tdpbf16ps",
            },
        },
    },

    ["tdpfp16ps"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tdpfp16ps",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "left_tile" },
                { index = 3, role = "right_tile" },
            },
            effect = {
                kind = "register_write",
                name = "tdpfp16ps_updates_tile_state",
                target_register = "rip",
                role = "dot-product accumulated fp16 values into AMX tile single-precision values by tdpfp16ps",
            },
        },
    },

    ["tilezero"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tilezero",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "tile_destination" },
            },
            effect = {
                kind = "register_write",
                name = "tilezero_updates_tile_state",
                target_register = "rip",
                role = "zeroed AMX tile by tilezero",
            },
        },
    },

}
