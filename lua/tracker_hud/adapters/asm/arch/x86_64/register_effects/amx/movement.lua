-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/amx/movement.lua
--
-- x86-64 register effects: amx / movement.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["tileloadd"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tileloadd",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "memory" },
            },
            effect = {
                kind = "register_write",
                name = "tileloadd_updates_tile_state",
                target_register = "rip",
                role = "loaded AMX tile rows by tileloadd",
            },
        },
    },

    ["tileloaddt1"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tileloaddt1",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "memory" },
            },
            effect = {
                kind = "register_write",
                name = "tileloaddt1_updates_tile_state",
                target_register = "rip",
                role = "loaded AMX tile rows with temporal hint by tileloaddt1",
            },
        },
    },

    ["tilestored"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tilestored",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "memory" },
                { index = 2, role = "tile_source" },
            },
            effect = {
                kind = "register_write",
                name = "tilestored_updates_tile_state",
                target_register = "rip",
                role = "stored AMX tile rows by tilestored",
            },
        },
    },

    ["tileloadd64"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tileloadd64",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "tile_destination" },
                { index = 2, role = "memory" },
            },
            effect = {
                kind = "register_write",
                name = "tileloadd64_updates_tile_state",
                target_register = "rip",
                role = "loaded AMX tile rows in 64-bit form by tileloadd64",
            },
        },
    },

    ["tilestored64"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tilestored64",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "memory" },
                { index = 2, role = "tile_source" },
            },
            effect = {
                kind = "register_write",
                name = "tilestored64_updates_tile_state",
                target_register = "rip",
                role = "stored AMX tile rows in 64-bit form by tilestored64",
            },
        },
    },

}
