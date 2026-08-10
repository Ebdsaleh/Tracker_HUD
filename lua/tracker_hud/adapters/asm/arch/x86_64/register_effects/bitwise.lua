-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/bitwise.lua
--
-- x86-64 bitwise register effect specs.

return {

    -- 'not reg' bitwise-inverts the destination register.
        {
            node_type = "instruction",
            mnemonic = "not",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "not_register",
                target_operand = 1,
                role = "bitwise inverted by not",
            },
        }
,

    -- 'shl reg, imm' shifts the destination register left.
        {
            node_type = "instruction",
            mnemonic = "shl",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "shift_count",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "shl_register_immediate",
                target_operand = 1,
                role = "shifted left by shl",
            },
        }
,

    -- 'sal reg, imm' arithmetically shifts the destination register left.
        {
            node_type = "instruction",
            mnemonic = "sal",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "shift_count",
                },
    
            },
    
    
            effect = {
                kind = "register_write",
                name = "sal_register_immediate",
                target_operand = 1,
                role = "arithmetically shifted left by sal",
            },
        }
,

    -- 'shr reg, imm' logically shifts the destination register right.
        {
            node_type = "instruction",
            mnemonic = "shr",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "shift_count",
                },
            },
    
            effect = {
                        kind = "register_write",
                        name = "shr_register_immediate",
                        target_operand = 1,
                        role = "logically shifted right by shr",
            },
        }
,

    -- 'sar reg, imm' arithmetically shifts the destination register right.
        {
            node_type = "instruction",
            mnemonic = "sar",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "shift_count",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "sar_register_immediate",
                target_operand = 1,
                role = "arithmetically shifted right by sar",
            },
        }
,

    -- 'rol reg, imm' rotates the destination register left.
        {
            node_type = "instruction",
            mnemonic ="rol",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "rotate_count",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "rol_register_immediate",
                target_operand = 1,
                role = "rotated left by rol",
            },
        }
,

    -- 'ror reg, imm' rotates the destination register right.
        {
            node_type = "instruction",
            mnemonic = "ror",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "rotate_count",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "ror_register_immediate",
                target_operand = 1,
                role = "rotated right by ror",
            },
        }
,

    -- 'rcl reg, imm' rotates the destination register left through carry.
        {
            node_type = "instruction",
            mnemonic = "rcl",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "rotate_count",
                },
            },
    
    
            effect = {
                kind = "register_write",
                name = "rcl_register_immediate",
                target_operand = 1,
                role = "rotate left through carry by rcl",
            },
        }
,

    -- 'rcr reg, imm' rotates the destination register right through carry.
        {
            node_type = "instruction",
            mnemonic = "rcr",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "rotate_count",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "rcr_register_immediate",
                target_operand = 1,
                role = "rotated right through carry by rcr",
            },
        }
,

    -- 'and reg, reg' mutates the destination register with a bitwise AND.
    
        {
            node_type = "instruction",
            mnemonic = "and",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "register",
                    role = "mask_register",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "and_register_register",
                target_operand = 1,
                role = "bitwise-and mutated by register",
            },
        }
,

    -- 'and reg, imm' mutates the destination register with a bitwise AND mask.
        {
            node_type = "instruction",
            mnemonic = "and",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "mask",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "and_register_immediate",
                target_operand = 1,
                role = "bitwise-and mutated by immediate",
            },
        }
,

    -- 'or reg, reg' mutates the destination register with a bitwise OR.
        {
            node_type = "instruction",
            mnemonic = "or",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "register",
                    role = "source_register",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "or_register_register",
                target_operand = 1,
                role = "bitwise-or mutated by register",
            },
        }
,

    -- 'or reg, imm' mutates the destination register with a bitwise OR immediate.
        {
            node_type = "instruction",
            mnemonic = "or",
    
            operands =
            {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "source_value",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "or_register_immediate",
                target_operand = 1,
                role = "bitwise-or mutated by immediate",
            },
        }
,

    -- 'xor reg, reg' mutates the destination register with a bitwise XOR.
        -- The self-zeroing form 'xor reg, reg' is handled by an earlier, more specific rule.
    
        {
            node_type = "instruction",
            mnemonic = "xor",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "register",
                    role = "source_register",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "xor_register_register",
                target_operand = 1,
                role = "bitwise-xor mutated by register",
            },
        }
,

    -- 'xor reg, imm' mutates the destination register with a bitwise XOR immediate
    
        {
            node_type = "instruction",
            mnemonic = "xor",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "source_value",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "xor_register_immediate",
                target_operand = 1,
                role = "bitwise-xor mutated by immediate",
            },
        }
,

    -- 'and' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "and",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
    
            effect = {
                kind = "register_write",
                name = "and_updates_rflags",
                target_register = "rflags",
                role = "updated by and",
            },
        }
,

    -- 'or' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "or",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
    
            effect = {
                kind = "register_write",
                name = "or_updates_rflags",
                target_register = "rflags",
                role = "updated by or",
            },
        }
,

    -- 'xor' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "xor",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
    
            effect = {
                kind = "register_write",
                name = "xor_updates_rflags",
                target_register = "rflags",
                role = "updated by xor",
            },
        }
,

    -- 'bswap reg' byte-swaps a register.
        {
            node_type = "instruction",
            mnemonic = "bswap",
    
            operands = {
                { index = 1, kind = "register", role = "target" },
            },
    
            effect = {
                kind = "register_write",
                name = "bswap_register",
                target_operand = 1,
                role = "byte-swapped by bswap",
            },
        }
,

    -- 'shl' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "shl",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "shift_count" },
            },
    
            effect = {
                kind = "register_write",
                name = "shl_updates_rflags",
                target_register = "rflags",
                role = "updated by shl",
            },
        }
,

    -- 'sal' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "sal",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "shift_count" },
            },
    
            effect = {
                kind = "register_write",
                name = "sal_updates_rflags",
                target_register = "rflags",
                role = "updated by sal",
            },
        }
,

    -- 'shr' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "shr",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "shift_count" },
            },
    
            effect = {
                kind = "register_write",
                name = "shr_updates_rflags",
                target_register = "rflags",
                role = "updated by shr",
            },
        }
,

    -- 'sar' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "sar",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "shift_count" },
            },
    
            effect = {
                kind = "register_write",
                name = "sar_updates_rflags",
                target_register = "rflags",
                role = "updated by sar",
            },
        }
,

    -- 'rol' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "rol",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "rotate_count" },
            },
    
            effect = {
                kind = "register_write",
                name = "rol_updates_rflags",
                target_register = "rflags",
                role = "updated by rol",
            },
        }
,

    -- 'ror' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "ror",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "rotate_count" },
            },
    
            effect = {
                kind = "register_write",
                name = "ror_updates_rflags",
                target_register = "rflags",
                role = "updated by ror",
            },
        }
,

    -- 'rcl' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "rcl",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "rotate_count" },
            },
    
            effect = {
                kind = "register_write",
                name = "rcl_updates_rflags",
                target_register = "rflags",
                role = "updated by rcl",
            },
        }
,

    -- 'rcr' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "rcr",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "rotate_count" },
            },
    
            effect = {
                kind = "register_write",
                name = "rcr_updates_rflags",
                target_register = "rflags",
                role = "updated by rcr",
            },
        }
,

    -- 'bsf reg, value' writes the bit-scan-forward result to the destination register.
        {
            node_type = "instruction",
            mnemonic = "bsf",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "bsf_writes_destination",
                target_operand = 1,
                role = "written with bit scan forward result by bsf",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bsf",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "bsf_updates_rflags",
                target_register = "rflags",
                role = "updated by bsf",
            },
        }
,

    -- 'bsr reg, value' writes the bit-scan-reverse result to the destination register.
        {
            node_type = "instruction",
            mnemonic = "bsr",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "bsr_writes_destination",
                target_operand = 1,
                role = "written with bit scan reverse result by bsr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bsr",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "bsr_updates_rflags",
                target_register = "rflags",
                role = "updated by bsr",
            },
        }
,

    -- 'tzcnt reg, value' writes the trailing-zero count to the destination register.
        {
            node_type = "instruction",
            mnemonic = "tzcnt",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "tzcnt_writes_destination",
                target_operand = 1,
                role = "written with trailing-zero count by tzcnt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tzcnt",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "tzcnt_updates_rflags",
                target_register = "rflags",
                role = "updated by tzcnt",
            },
        }
,

    -- 'lzcnt reg, value' writes the leading-zero count to the destination register.
        {
            node_type = "instruction",
            mnemonic = "lzcnt",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "lzcnt_writes_destination",
                target_operand = 1,
                role = "written with leading-zero count by lzcnt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lzcnt",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "lzcnt_updates_rflags",
                target_register = "rflags",
                role = "updated by lzcnt",
            },
        }
,

    -- 'shld reg, source, count' shifts the destination left through another source.
        {
            node_type = "instruction",
            mnemonic = "shld",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "shift_count" },
            },
            effect = {
                kind = "register_write",
                name = "shld_writes_destination",
                target_operand = 1,
                role = "double-precision shifted left by shld",
            },
        }
,

    -- 'shld' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "shld",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "shift_count" },
            },
            effect = {
                kind = "register_write",
                name = "shld_updates_rflags",
                target_register = "rflags",
                role = "updated by shld",
            },
        }
,

    -- 'shrd reg, source, count' shifts the destination right through another source.
        {
            node_type = "instruction",
            mnemonic = "shrd",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "shift_count" },
            },
            effect = {
                kind = "register_write",
                name = "shrd_writes_destination",
                target_operand = 1,
                role = "double-precision shifted right by shrd",
            },
        }
,

    -- 'shrd' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "shrd",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "shift_count" },
            },
            effect = {
                kind = "register_write",
                name = "shrd_updates_rflags",
                target_register = "rflags",
                role = "updated by shrd",
            },
        }
,

    -- 'bt target, bit' tests a bit and updates rflags.
        {
            node_type = "instruction",
            mnemonic = "bt",
            operands = {
                { index = 1, role = "target" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "bt_updates_rflags",
                target_register = "rflags",
                role = "updated by bit test",
            },
        }
,

    -- 'bts target, bit' tests and sets a bit in the destination.
        {
            node_type = "instruction",
            mnemonic = "bts",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "bts_writes_destination",
                target_operand = 1,
                role = "bit tested and set by bts",
            },
        }
,

    -- 'bts' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "bts",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "bts_updates_rflags",
                target_register = "rflags",
                role = "updated by bts",
            },
        }
,

    -- 'btr target, bit' tests and resets a bit in the destination.
        {
            node_type = "instruction",
            mnemonic = "btr",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btr_writes_destination",
                target_operand = 1,
                role = "bit tested and reset by btr",
            },
        }
,

    -- 'btr' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "btr",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btr_updates_rflags",
                target_register = "rflags",
                role = "updated by btr",
            },
        }
,

    -- 'btc target, bit' tests and complements a bit in the destination.
        {
            node_type = "instruction",
            mnemonic = "btc",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btc_writes_destination",
                target_operand = 1,
                role = "bit tested and complemented by btc",
            },
        }
,

    -- 'btc' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "btc",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btc_updates_rflags",
                target_register = "rflags",
                role = "updated by btc",
            },
        }
,

    -- 'pdep reg, source, mask' writes a parallel bit deposit result.
        {
            node_type = "instruction",
            mnemonic = "pdep",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "pdep_writes_destination",
                target_operand = 1,
                role = "written with parallel bit deposit result by pdep",
            },
        }
,

    -- 'pext reg, source, mask' writes a parallel bit extract result.
        {
            node_type = "instruction",
            mnemonic = "pext",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "pext_writes_destination",
                target_operand = 1,
                role = "written with parallel bit extract result by pext",
            },
        }
,

    -- 'andn reg, source, mask' writes inverted-source AND result.
        {
            node_type = "instruction",
            mnemonic = "andn",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "andn_writes_destination",
                target_operand = 1,
                role = "written with inverted-source and result by andn",
            },
        }
,

    -- 'andn' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "andn",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "andn_updates_rflags",
                target_register = "rflags",
                role = "updated by andn",
            },
        }
,

    -- 'bextr reg, source, control' writes extracted bit-field result.
        {
            node_type = "instruction",
            mnemonic = "bextr",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "bextr_writes_destination",
                target_operand = 1,
                role = "written with bit-field extract result by bextr",
            },
        }
,

    -- 'bextr' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "bextr",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "bextr_updates_rflags",
                target_register = "rflags",
                role = "updated by bextr",
            },
        }
,

    -- 'bzhi reg, source, index' writes zero-high-bits result.
        {
            node_type = "instruction",
            mnemonic = "bzhi",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "bzhi_writes_destination",
                target_operand = 1,
                role = "written with zero-high-bits result by bzhi",
            },
        }
,

    -- 'bzhi' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "bzhi",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "bzhi_updates_rflags",
                target_register = "rflags",
                role = "updated by bzhi",
            },
        }
,

    -- 'blsi reg, source' writes isolated lowest set bit.
        {
            node_type = "instruction",
            mnemonic = "blsi",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blsi_writes_destination",
                target_operand = 1,
                role = "written with isolated lowest set bit by blsi",
            },
        }
,

    -- 'blsi' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "blsi",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blsi_updates_rflags",
                target_register = "rflags",
                role = "updated by blsi",
            },
        }
,

    -- 'blsmsk reg, source' writes mask from lowest set bit.
        {
            node_type = "instruction",
            mnemonic = "blsmsk",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blsmsk_writes_destination",
                target_operand = 1,
                role = "written with lowest-set-bit mask by blsmsk",
            },
        }
,

    -- 'blsmsk' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "blsmsk",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blsmsk_updates_rflags",
                target_register = "rflags",
                role = "updated by blsmsk",
            },
        }
,

    -- 'blsr reg, source' writes source with lowest set bit reset.
        {
            node_type = "instruction",
            mnemonic = "blsr",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blsr_writes_destination",
                target_operand = 1,
                role = "written with lowest set bit reset by blsr",
            },
        }
,

    -- 'blsr' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "blsr",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blsr_updates_rflags",
                target_register = "rflags",
                role = "updated by blsr",
            },
        }
,

    -- 'crc32 reg, source' writes a CRC32 accumulation result.
        {
            node_type = "instruction",
            mnemonic = "crc32",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "crc32_writes_destination",
                target_operand = 1,
                role = "written with crc32 accumulation result by crc32",
            },
        }
,

    -- 'rorx reg, source, imm' writes a rotate-right result without flags.
        {
            node_type = "instruction",
            mnemonic = "rorx",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "rotate_count" },
            },
            effect = {
                kind = "register_write",
                name = "rorx_writes_destination",
                target_operand = 1,
                role = "written with rotate-right result by rorx",
            },
        }
,

    -- 'shlx reg, source, count' writes a variable shift-left result.
        {
            node_type = "instruction",
            mnemonic = "shlx",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "shift_count" },
            },
            effect = {
                kind = "register_write",
                name = "shlx_writes_destination",
                target_operand = 1,
                role = "written with variable shift-left result by shlx",
            },
        }
,

    -- 'shrx reg, source, count' writes a variable logical shift-right result.
        {
            node_type = "instruction",
            mnemonic = "shrx",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "shift_count" },
            },
            effect = {
                kind = "register_write",
                name = "shrx_writes_destination",
                target_operand = 1,
                role = "written with variable logical shift-right result by shrx",
            },
        }
,

    -- 'sarx reg, source, count' writes a variable arithmetic shift-right result.
        {
            node_type = "instruction",
            mnemonic = "sarx",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "shift_count" },
            },
            effect = {
                kind = "register_write",
                name = "sarx_writes_destination",
                target_operand = 1,
                role = "written with variable arithmetic shift-right result by sarx",
            },
        }
,

    -- 'salc' sets al from carry flag.
        {
            node_type = "instruction",
            mnemonic = "salc",
            operands = {},
            effect = {
                kind = "register_write",
                name = "salc_writes_rax",
                target_register = "rax",
                written_alias = "al",
                role = "set al from carry flag by salc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "andps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "andps_simd_logic",
                target_register = "rip",
                role = "bitwise-and packed single-precision lanes by andps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "andpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "andpd_simd_logic",
                target_register = "rip",
                role = "bitwise-and packed double-precision lanes by andpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "andnps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "andnps_simd_logic",
                target_register = "rip",
                role = "bitwise-and-not packed single-precision lanes by andnps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "andnpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "andnpd_simd_logic",
                target_register = "rip",
                role = "bitwise-and-not packed double-precision lanes by andnpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "orps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "orps_simd_logic",
                target_register = "rip",
                role = "bitwise-or packed single-precision lanes by orps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "orpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "orpd_simd_logic",
                target_register = "rip",
                role = "bitwise-or packed double-precision lanes by orpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xorps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "xorps_simd_logic",
                target_register = "rip",
                role = "bitwise-xor packed single-precision lanes by xorps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xorpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "xorpd_simd_logic",
                target_register = "rip",
                role = "bitwise-xor packed double-precision lanes by xorpd",
            },
        }
,

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
            mnemonic = "blsfill",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blsfill_writes_destination",
                target_operand = 1,
                role = "written with lowest set bit filled by blsfill",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "blsic",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "blsic_writes_destination",
                target_operand = 1,
                role = "written with inverted lowest set bit isolated by blsic",
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

    -- AND suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "andb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "andb_writes_destination",
                target_operand = 1,
                role = "bitwise-and byte source by andb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "andb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "andb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte bitwise-and andb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "andw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "andw_writes_destination",
                target_operand = 1,
                role = "bitwise-and word source by andw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "andw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "andw_updates_rflags",
                target_register = "rflags",
                role = "updated by word bitwise-and andw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "andl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "andl_writes_destination",
                target_operand = 1,
                role = "bitwise-and long source by andl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "andl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "andl_updates_rflags",
                target_register = "rflags",
                role = "updated by long bitwise-and andl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "andq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "andq_writes_destination",
                target_operand = 1,
                role = "bitwise-and quadword source by andq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "andq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "andq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword bitwise-and andq",
            },
        }
,

    -- OR suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "orb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "orb_writes_destination",
                target_operand = 1,
                role = "bitwise-or byte source by orb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "orb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "orb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte bitwise-or orb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "orw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "orw_writes_destination",
                target_operand = 1,
                role = "bitwise-or word source by orw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "orw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "orw_updates_rflags",
                target_register = "rflags",
                role = "updated by word bitwise-or orw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "orl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "orl_writes_destination",
                target_operand = 1,
                role = "bitwise-or long source by orl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "orl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "orl_updates_rflags",
                target_register = "rflags",
                role = "updated by long bitwise-or orl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "orq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "orq_writes_destination",
                target_operand = 1,
                role = "bitwise-or quadword source by orq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "orq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "orq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword bitwise-or orq",
            },
        }
,

    -- XOR suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "xorb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xorb_writes_destination",
                target_operand = 1,
                role = "bitwise-xor byte source by xorb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xorb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xorb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte bitwise-xor xorb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xorw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xorw_writes_destination",
                target_operand = 1,
                role = "bitwise-xor word source by xorw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xorw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xorw_updates_rflags",
                target_register = "rflags",
                role = "updated by word bitwise-xor xorw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xorl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xorl_writes_destination",
                target_operand = 1,
                role = "bitwise-xor long source by xorl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xorl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xorl_updates_rflags",
                target_register = "rflags",
                role = "updated by long bitwise-xor xorl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xorq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xorq_writes_destination",
                target_operand = 1,
                role = "bitwise-xor quadword source by xorq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xorq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xorq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword bitwise-xor xorq",
            },
        }
,

    -- NOT suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "notb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "notb_writes_destination",
                target_operand = 1,
                role = "bitwise inverted byte by notb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "notw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "notw_writes_destination",
                target_operand = 1,
                role = "bitwise inverted word by notw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "notl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "notl_writes_destination",
                target_operand = 1,
                role = "bitwise inverted long by notl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "notq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "notq_writes_destination",
                target_operand = 1,
                role = "bitwise inverted quadword by notq",
            },
        }
,

    -- SHL / SAL suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "shlb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shlb_writes_destination",
                target_operand = 1,
                role = "shifted byte left by shlb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shlb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shlb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte shift left shlb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shlw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shlw_writes_destination",
                target_operand = 1,
                role = "shifted word left by shlw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shll",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shll_writes_destination",
                target_operand = 1,
                role = "shifted long left by shll",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shlq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shlq_writes_destination",
                target_operand = 1,
                role = "shifted quadword left by shlq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shlq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shlq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword shift left shlq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "salb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "salb_writes_destination",
                target_operand = 1,
                role = "arithmetically shifted byte left by salb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "salq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "salq_writes_destination",
                target_operand = 1,
                role = "arithmetically shifted quadword left by salq",
            },
        }
,

    -- SHR / SAR suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "shrb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shrb_writes_destination",
                target_operand = 1,
                role = "logically shifted byte right by shrb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shrw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shrw_writes_destination",
                target_operand = 1,
                role = "logically shifted word right by shrw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shrl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shrl_writes_destination",
                target_operand = 1,
                role = "logically shifted long right by shrl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shrq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shrq_writes_destination",
                target_operand = 1,
                role = "logically shifted quadword right by shrq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sarq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "sarq_writes_destination",
                target_operand = 1,
                role = "arithmetically shifted quadword right by sarq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sarq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "sarq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword arithmetic shift right sarq",
            },
        }
,

    -- ROL / ROR suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "rolb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rolb_writes_destination",
                target_operand = 1,
                role = "rotated byte left by rolb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rolq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rolq_writes_destination",
                target_operand = 1,
                role = "rotated quadword left by rolq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rorb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rorb_writes_destination",
                target_operand = 1,
                role = "rotated byte right by rorb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rorq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rorq_writes_destination",
                target_operand = 1,
                role = "rotated quadword right by rorq",
            },
        }
,

    -- Bit-test / bit-scan / multiply-divide / atomic suffix aliases.
        -- These improve recognition of GAS/objdump-style width-explicit mnemonics.
    
        -- RCL / RCR suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "rclb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rclb_writes_destination",
                target_operand = 1,
                role = "rotated byte left through carry by rclb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rclb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rclb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte rotate left through carry rclb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rclw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rclw_writes_destination",
                target_operand = 1,
                role = "rotated word left through carry by rclw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rcll",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rcll_writes_destination",
                target_operand = 1,
                role = "rotated long left through carry by rcll",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rclq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rclq_writes_destination",
                target_operand = 1,
                role = "rotated quadword left through carry by rclq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rclq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rclq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword rotate left through carry rclq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rcrb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rcrb_writes_destination",
                target_operand = 1,
                role = "rotated byte right through carry by rcrb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rcrb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rcrb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte rotate right through carry rcrb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rcrw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rcrw_writes_destination",
                target_operand = 1,
                role = "rotated word right through carry by rcrw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rcrl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rcrl_writes_destination",
                target_operand = 1,
                role = "rotated long right through carry by rcrl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rcrq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rcrq_writes_destination",
                target_operand = 1,
                role = "rotated quadword right through carry by rcrq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rcrq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rcrq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword rotate right through carry rcrq",
            },
        }
,

    -- BT / BTS / BTR / BTC suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "btb",
            operands = {
                { index = 1, role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte bit test btb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btw",
            operands = {
                { index = 1, role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btw_updates_rflags",
                target_register = "rflags",
                role = "updated by word bit test btw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btl",
            operands = {
                { index = 1, role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btl_updates_rflags",
                target_register = "rflags",
                role = "updated by long bit test btl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btq",
            operands = {
                { index = 1, role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword bit test btq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btsb",
            operands = {
                { index = 1, kind = "register", role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btsb_writes_base",
                target_operand = 1,
                role = "bit set in byte base by btsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btsb",
            operands = {
                { index = 1, role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btsb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte bit test and set btsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btsw",
            operands = {
                { index = 1, kind = "register", role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btsw_writes_base",
                target_operand = 1,
                role = "bit set in word base by btsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btsl",
            operands = {
                { index = 1, kind = "register", role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btsl_writes_base",
                target_operand = 1,
                role = "bit set in long base by btsl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btsq",
            operands = {
                { index = 1, kind = "register", role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btsq_writes_base",
                target_operand = 1,
                role = "bit set in quadword base by btsq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btsq",
            operands = {
                { index = 1, role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btsq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword bit test and set btsq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btrb",
            operands = {
                { index = 1, kind = "register", role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btrb_writes_base",
                target_operand = 1,
                role = "bit reset in byte base by btrb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btrq",
            operands = {
                { index = 1, kind = "register", role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btrq_writes_base",
                target_operand = 1,
                role = "bit reset in quadword base by btrq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btrq",
            operands = {
                { index = 1, role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btrq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword bit test and reset btrq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btcb",
            operands = {
                { index = 1, kind = "register", role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btcb_writes_base",
                target_operand = 1,
                role = "bit complemented in byte base by btcb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btcq",
            operands = {
                { index = 1, kind = "register", role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btcq_writes_base",
                target_operand = 1,
                role = "bit complemented in quadword base by btcq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btcq",
            operands = {
                { index = 1, role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btcq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword bit test and complement btcq",
            },
        }
,

    -- BSF / BSR suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "bsfw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "bsfw_writes_destination",
                target_operand = 1,
                role = "written with word bit scan forward index by bsfw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bsfw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "bsfw_updates_rflags",
                target_register = "rflags",
                role = "updated by word bit scan forward bsfw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bsfl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "bsfl_writes_destination",
                target_operand = 1,
                role = "written with long bit scan forward index by bsfl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bsfq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "bsfq_writes_destination",
                target_operand = 1,
                role = "written with quadword bit scan forward index by bsfq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bsfq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "bsfq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword bit scan forward bsfq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bsrw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "bsrw_writes_destination",
                target_operand = 1,
                role = "written with word bit scan reverse index by bsrw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bsrl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "bsrl_writes_destination",
                target_operand = 1,
                role = "written with long bit scan reverse index by bsrl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bsrq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "bsrq_writes_destination",
                target_operand = 1,
                role = "written with quadword bit scan reverse index by bsrq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bsrq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "bsrq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword bit scan reverse bsrq",
            },
        }
,

    -- SAL / SHL suffix flags completion.
    
        {
            node_type = "instruction",
            mnemonic = "salb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "salb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte arithmetic shift left salb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "salw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "salw_writes_destination",
                target_operand = 1,
                role = "arithmetically shifted word left by salw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "salw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "salw_updates_rflags",
                target_register = "rflags",
                role = "updated by word arithmetic shift left salw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sall",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "sall_writes_destination",
                target_operand = 1,
                role = "arithmetically shifted long left by sall",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sall",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "sall_updates_rflags",
                target_register = "rflags",
                role = "updated by long arithmetic shift left sall",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "salq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "salq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword arithmetic shift left salq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shlw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shlw_updates_rflags",
                target_register = "rflags",
                role = "updated by word shift left shlw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shll",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shll_updates_rflags",
                target_register = "rflags",
                role = "updated by long shift left shll",
            },
        }
,

    -- SHR suffix flags completion.
    
        {
            node_type = "instruction",
            mnemonic = "shrb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shrb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte logical shift right shrb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shrw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shrw_updates_rflags",
                target_register = "rflags",
                role = "updated by word logical shift right shrw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shrl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shrl_updates_rflags",
                target_register = "rflags",
                role = "updated by long logical shift right shrl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shrq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shrq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword logical shift right shrq",
            },
        }
,

    -- SAR missing lower-width suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "sarb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "sarb_writes_destination",
                target_operand = 1,
                role = "arithmetically shifted byte right by sarb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sarb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "sarb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte arithmetic shift right sarb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sarw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "sarw_writes_destination",
                target_operand = 1,
                role = "arithmetically shifted word right by sarw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sarw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "sarw_updates_rflags",
                target_register = "rflags",
                role = "updated by word arithmetic shift right sarw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sarl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "sarl_writes_destination",
                target_operand = 1,
                role = "arithmetically shifted long right by sarl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sarl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "sarl_updates_rflags",
                target_register = "rflags",
                role = "updated by long arithmetic shift right sarl",
            },
        }
,

    -- ROL / ROR missing widths and flags.
    
        {
            node_type = "instruction",
            mnemonic = "rolb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rolb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte rotate left rolb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rolw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rolw_writes_destination",
                target_operand = 1,
                role = "rotated word left by rolw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "roll",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "roll_writes_destination",
                target_operand = 1,
                role = "rotated long left by roll",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rolq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rolq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword rotate left rolq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rorb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rorb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte rotate right rorb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rorw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rorw_writes_destination",
                target_operand = 1,
                role = "rotated word right by rorw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rorl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rorl_writes_destination",
                target_operand = 1,
                role = "rotated long right by rorl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rorq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rorq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword rotate right rorq",
            },
        }
,

    -- Bit-test word/long completion for mutating forms.
    
        {
            node_type = "instruction",
            mnemonic = "btsw",
            operands = {
                { index = 1, role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btsw_updates_rflags",
                target_register = "rflags",
                role = "updated by word bit test and set btsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btsl",
            operands = {
                { index = 1, role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btsl_updates_rflags",
                target_register = "rflags",
                role = "updated by long bit test and set btsl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btrw",
            operands = {
                { index = 1, kind = "register", role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btrw_writes_base",
                target_operand = 1,
                role = "bit reset in word base by btrw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btrw",
            operands = {
                { index = 1, role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btrw_updates_rflags",
                target_register = "rflags",
                role = "updated by word bit test and reset btrw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btrl",
            operands = {
                { index = 1, kind = "register", role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btrl_writes_base",
                target_operand = 1,
                role = "bit reset in long base by btrl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btrl",
            operands = {
                { index = 1, role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btrl_updates_rflags",
                target_register = "rflags",
                role = "updated by long bit test and reset btrl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btcw",
            operands = {
                { index = 1, kind = "register", role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btcw_writes_base",
                target_operand = 1,
                role = "bit complemented in word base by btcw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btcw",
            operands = {
                { index = 1, role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btcw_updates_rflags",
                target_register = "rflags",
                role = "updated by word bit test and complement btcw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btcl",
            operands = {
                { index = 1, kind = "register", role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btcl_writes_base",
                target_operand = 1,
                role = "bit complemented in long base by btcl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "btcl",
            operands = {
                { index = 1, role = "base" },
                { index = 2, role = "bit_index" },
            },
            effect = {
                kind = "register_write",
                name = "btcl_updates_rflags",
                target_register = "rflags",
                role = "updated by long bit test and complement btcl",
            },
        }
,

    -- BMI / bit-count / CRC suffix alias completion.
        -- These improve recognition of GAS/objdump-style width-explicit spellings.
    
        -- BSWAP suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "bswapl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "bswapl_writes_destination",
                target_operand = 1,
                role = "byte-swapped long register by bswapl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bswapq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "bswapq_writes_destination",
                target_operand = 1,
                role = "byte-swapped quadword register by bswapq",
            },
        }
,

    -- LZCNT suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "lzcntw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "lzcntw_writes_destination",
                target_operand = 1,
                role = "written with word leading-zero count by lzcntw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lzcntw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "lzcntw_updates_rflags",
                target_register = "rflags",
                role = "updated by word leading-zero count lzcntw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lzcntl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "lzcntl_writes_destination",
                target_operand = 1,
                role = "written with long leading-zero count by lzcntl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lzcntl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "lzcntl_updates_rflags",
                target_register = "rflags",
                role = "updated by long leading-zero count lzcntl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lzcntq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "lzcntq_writes_destination",
                target_operand = 1,
                role = "written with quadword leading-zero count by lzcntq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lzcntq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "lzcntq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword leading-zero count lzcntq",
            },
        }
,

    -- TZCNT suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "tzcntw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "tzcntw_writes_destination",
                target_operand = 1,
                role = "written with word trailing-zero count by tzcntw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tzcntw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "tzcntw_updates_rflags",
                target_register = "rflags",
                role = "updated by word trailing-zero count tzcntw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tzcntl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "tzcntl_writes_destination",
                target_operand = 1,
                role = "written with long trailing-zero count by tzcntl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tzcntl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "tzcntl_updates_rflags",
                target_register = "rflags",
                role = "updated by long trailing-zero count tzcntl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tzcntq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "tzcntq_writes_destination",
                target_operand = 1,
                role = "written with quadword trailing-zero count by tzcntq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tzcntq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "tzcntq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword trailing-zero count tzcntq",
            },
        }
,

    -- CRC32 suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "crc32b",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "crc32b_writes_destination",
                target_operand = 1,
                role = "written with byte CRC32 accumulation by crc32b",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "crc32w",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "crc32w_writes_destination",
                target_operand = 1,
                role = "written with word CRC32 accumulation by crc32w",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "crc32l",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "crc32l_writes_destination",
                target_operand = 1,
                role = "written with long CRC32 accumulation by crc32l",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "crc32q",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "crc32q_writes_destination",
                target_operand = 1,
                role = "written with quadword CRC32 accumulation by crc32q",
            },
        }
,

    -- BMI1/BMI2 suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "andnl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "andnl_writes_destination",
                target_operand = 1,
                role = "written with long bitwise and-not by andnl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "andnq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "andnq_writes_destination",
                target_operand = 1,
                role = "written with quadword bitwise and-not by andnq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "andnq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "andnq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword bitwise and-not andnq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bextrl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "bextrl_writes_destination",
                target_operand = 1,
                role = "written with long bit-field extract by bextrl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bextrq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "bextrq_writes_destination",
                target_operand = 1,
                role = "written with quadword bit-field extract by bextrq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bextrq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "bextrq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword bit-field extract bextrq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bzhil",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "bzhil_writes_destination",
                target_operand = 1,
                role = "written with long zero-high-bits result by bzhil",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "bzhiq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "index" },
            },
            effect = {
                kind = "register_write",
                name = "bzhiq_writes_destination",
                target_operand = 1,
                role = "written with quadword zero-high-bits result by bzhiq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pdepl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "pdepl_writes_destination",
                target_operand = 1,
                role = "written with long parallel bit deposit by pdepl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pdepq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "pdepq_writes_destination",
                target_operand = 1,
                role = "written with quadword parallel bit deposit by pdepq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pextl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "pextl_writes_destination",
                target_operand = 1,
                role = "written with long parallel bit extract by pextl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pextq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "mask" },
            },
            effect = {
                kind = "register_write",
                name = "pextq_writes_destination",
                target_operand = 1,
                role = "written with quadword parallel bit extract by pextq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shlxl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shlxl_writes_destination",
                target_operand = 1,
                role = "written with long variable shift-left result by shlxl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shlxq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shlxq_writes_destination",
                target_operand = 1,
                role = "written with quadword variable shift-left result by shlxq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shrxl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shrxl_writes_destination",
                target_operand = 1,
                role = "written with long variable logical shift-right result by shrxl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "shrxq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "shrxq_writes_destination",
                target_operand = 1,
                role = "written with quadword variable logical shift-right result by shrxq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sarxl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "sarxl_writes_destination",
                target_operand = 1,
                role = "written with long variable arithmetic shift-right result by sarxl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sarxq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "sarxq_writes_destination",
                target_operand = 1,
                role = "written with quadword variable arithmetic shift-right result by sarxq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rorxl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rorxl_writes_destination",
                target_operand = 1,
                role = "written with long rotate-right result by rorxl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rorxq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "count" },
            },
            effect = {
                kind = "register_write",
                name = "rorxq_writes_destination",
                target_operand = 1,
                role = "written with quadword rotate-right result by rorxq",
            },
        }
,

    -- 'xor'
        {
            node_type = "instruction",
            mnemonic = "xor",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "register",
                    role = "source",
                },
            },
    
            condition = {
                operands_equal = { 1, 2 },
            },
    
            effect = {
                kind = "register_write",
                name = "xor_register_self_zero",
                target_operand = 1,
                value = "0",
                role = "zeroed by xor",
            },
        }
,

    -- 'and reg, 0' zeroes the destination register.
        {
            node_type = "instruction",
            mnemonic = "and",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
    
                {
                    index = 2,
                    kind = "integer",
                    role = "mask",
                    value = "0",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "and_register_zero",
                target_operand = 1,
                value = "0",
                role = "zeroed by and",
            },
        }
,
}
