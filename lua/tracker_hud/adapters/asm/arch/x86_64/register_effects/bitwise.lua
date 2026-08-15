-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/bitwise.lua
--
-- x86-64 bitwise register effect specs.
--
-- Remaining legacy records not yet migrated into the categorized
-- Tree-sitter-first register-effect modules.

return {
    {
                    node_type = "instruction",
                    mnemonic = "pextrb",
                    operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
                    effect = {
                        kind = "register_write",
                        name = "pextrb_writes_gpr",
                        target_operand = 1,
                        role = "written with extracted byte by pextrb",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "pextrw",
                    operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
                    effect = {
                        kind = "register_write",
                        name = "pextrw_writes_gpr",
                        target_operand = 1,
                        role = "written with extracted word by pextrw",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "pextrd",
                    operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
                    effect = {
                        kind = "register_write",
                        name = "pextrd_writes_gpr",
                        target_operand = 1,
                        role = "written with extracted doubleword by pextrd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "pextrq",
                    operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
                    effect = {
                        kind = "register_write",
                        name = "pextrq_writes_gpr",
                        target_operand = 1,
                        role = "written with extracted quadword by pextrq",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "pextrb",
                    operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "pextrb_writes_gpr",
                        target_operand = 1,
                        role = "written with extracted byte by pextrb",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "pextrd",
                    operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "pextrd_writes_gpr",
                        target_operand = 1,
                        role = "written with extracted doubleword by pextrd",
                    },
                }
,

    {
                    node_type = "instruction",
                    mnemonic = "pextrq",
                    operands = {
                        { index = 1, kind = "register", role = "destination" },
                        { index = 2, role = "source" },
                        { index = 3, role = "index" },
                    },
                    effect = {
                        kind = "register_write",
                        name = "pextrq_writes_gpr",
                        target_operand = 1,
                        role = "written with extracted quadword by pextrq",
                    },
                }
,

}
