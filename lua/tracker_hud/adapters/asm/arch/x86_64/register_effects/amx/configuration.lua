-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/amx/configuration.lua
--
-- x86-64 register effects: amx / configuration.
--
-- Tree-sitter-first, mnemonic-indexed register-effect specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- Operand/effect data then describes the x86-64 semantic effect consumed by
-- Tracker_HUD.

return {
    ["ldtilecfg"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ldtilecfg",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "tile_config" },
            },
            effect = {
                kind = "register_write",
                name = "ldtilecfg_updates_tile_state",
                target_register = "rip",
                role = "loaded AMX tile configuration by ldtilecfg",
            },
        },
    },

    ["sttilecfg"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "sttilecfg",
                    },
                },
            },
    
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "sttilecfg_updates_tile_state",
                target_register = "rip",
                role = "stored AMX tile configuration by sttilecfg",
            },
        },
    },

    ["tilerelease"] = {
    {
            syntax = {
                node_type = "instruction",
    
                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tilerelease",
                    },
                },
            },
    
            operands = {},
            effect = {
                kind = "register_write",
                name = "tilerelease_updates_tile_state",
                target_register = "rip",
                role = "released AMX tile state by tilerelease",
            },
        },
    },

}
