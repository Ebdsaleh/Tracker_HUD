-- lua/tracker_hud/adapters/asm/arch/x86_64/memory_accesses.lua
--
-- x86-64 source memory access-intent declarations.
--
-- These rules describe what an instruction intends to do with a memory
-- operand. They do not imply that the instruction executed or that memory
-- contents/effective addresses are known.

return {
    mov = {
        {
            operand_index = 1,
            operand_kind = "memory",
            access = "write",
        },
        {
            operand_index = 2,
            operand_kind = "memory",
            access = "read",
        },
    },

    lea = {
        {
            operand_index = 2,
            operand_kind = "memory",
            access = "address_only",
        },
    },
}
