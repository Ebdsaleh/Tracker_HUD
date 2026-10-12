-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/integer/address_generation.lua
--
-- x86-64 register effects: integer / address generation.
--
-- LEA computes an effective address and writes that address value into the
-- destination register. It does not load from memory and does not emulate the
-- addressed memory contents.

return {
    ["lea"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "lea",
                    },
                },
            },

            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "memory",
                    role = "source_address",
                },
            },

            effect = {
                kind = "register_write",
                name = "lea_register_memory_address",
                target_operand = 1,
                value_operand = 2,
                role = "loaded effective address by lea",
            },
        },
    },
}
