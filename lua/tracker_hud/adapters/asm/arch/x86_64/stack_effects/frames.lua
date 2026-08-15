-- lua/tracker_hud/adapters/asm/arch/x86_64/stack_effects/frames.lua
--
-- x86-64 stack-frame lifecycle effects.
--
-- Tree-sitter-first, mnemonic-indexed stack-effect specs.

return {
    ["leave"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "leave",
                    },
                },
            },

            operands = {},

            effect = {
                kind = "stack_frame_restore",
                name = "leave",
                role = "restored previous stack frame",
            },
        },
    },
}
