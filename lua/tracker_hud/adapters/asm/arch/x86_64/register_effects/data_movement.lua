-- lua/tracker_hud/adapters/asm_arch/x86_64/register_effects/data_movement.lua
--
-- x86-64 data movement register effect specs.

return {

    -- 'mov'
        {
            node_type = "instruction",
            mnemonic = "mov",
    
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
                name = "mov_register_immediate",
                target_operand = 1,
                value_operand = 2,
                role = "written by mov",
            },
        }
,

    -- More 'mov'
        {
            node_type = "instruction",
            mnemonic = "mov",
    
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
                name = "mov_register_register",
                target_operand = 1,
                value_from_register_operand = 2,
                role = "copied from register",
            },
        }
,

    -- 'movzx reg, reg' writes a zero-extended source register value.
        {
            node_type = "instruction",
            mnemonic = "movzx",
    
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
                name = "movzx_register_register",
                target_operand = 1,
                role = "zero-extended from register by movzx",
            },
        }
,

    -- 'movsx reg, reg' writes a sign-extended source register value.
        {
            node_type = "instruction",
            mnemonic = "movsx",
    
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
                name = "movsx_register_register",
                target_operand = 1,
                role = "sign-extended from register by movsx",
            },
        }
,

    -- 'movsxd reg, reg' writes a sign-extended dword source register value.
        {
            node_type = "instruction",
            mnemonic = "movsxd",
    
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
                name = "movsxd_register_register",
                target_operand = 1,
                role = "sign-extended dword from register by movsxd",
            },
        }
,

    -- 'xchg reg, reg' writes the first register with the swapped value.
        {
            node_type = "instruction",
            mnemonic = "xchg",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "left",
                },
                {
                    index = 2,
                    kind = "register",
                    role = "right",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "xchg_register_register_left",
                target_operand = 1,
                role = "swapped with register by xchg",
            },
        }
,

    -- 'xchg reg, reg' writes the second register with the swapped value.
        {
            node_type = "instruction",
            mnemonic = "xchg",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "left",
                },
                {
                    index = 2,
                    kind = "register",
                    role = "right",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "xchg_register_register_right",
                target_operand = 2,
                role = "swapped with register by xchg",
            },
        }
,

    -- 'seto reg' writes a byte from overflow-flag condition.
        {
            node_type = "instruction",
            mnemonic = "seto",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "seto_register",
                target_operand = 1,
                role = "set byte from overflow condition",
            },
        }
,

    -- 'setno reg' writes a byte from not-overflow condition.
        {
            node_type = "instruction",
            mnemonic = "setno",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setno_register",
                target_operand = 1,
                role = "set byte from not-overflow condition",
            },
        }
,

    -- 'setb reg' writes a byte from below/carry condition.
        {
            node_type = "instruction",
            mnemonic = "setb",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setb_register",
                target_operand = 1,
                role = "set byte from below condition",
            },
        }
,

    -- 'setnae reg' writes a byte from not-above-or-equal condition.
        {
            node_type = "instruction",
            mnemonic = "setnae",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setnae_register",
                target_operand = 1,
                role = "set byte from not-above-or-equal condition",
            },
        }
,

    -- 'setc reg' writes a byte from carry condition.
        {
            node_type = "instruction",
            mnemonic = "setc",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setc_register",
                target_operand = 1,
                role = "set byte from carry condition",
            },
        }
,

    -- 'setae reg' writes a byte from above-or-equal condition.
        {
            node_type = "instruction",
            mnemonic = "setae",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setae_register",
                target_operand = 1,
                role = "set byte from above-or-equal condition",
            },
        }
,

    -- 'setnb reg' writes a byte from not-below condition.
        {
            node_type = "instruction",
            mnemonic = "setnb",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setnb_register",
                target_operand = 1,
                role = "set byte from not-below condition",
            },
        }
,

    -- 'setnc reg' writes a byte from not-carry condition.
        {
            node_type = "instruction",
            mnemonic = "setnc",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setnc_register",
                target_operand = 1,
                role = "set byte from not-carry condition",
            },
        }
,

    -- 'sete reg' writes a byte from equal/zero condition.
        {
            node_type = "instruction",
            mnemonic = "sete",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "sete_register",
                target_operand = 1,
                role = "set byte from equal condition",
            },
        }
,

    -- 'setz reg' writes a byte from zero condition.
        {
            node_type = "instruction",
            mnemonic = "setz",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setz_register",
                target_operand = 1,
                role = "set byte from zero condition",
            },
        }
,

    -- 'setne reg' writes a byte from not-equal condition.
        {
            node_type = "instruction",
            mnemonic = "setne",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setne_register",
                target_operand = 1,
                role = "set byte from not-equal condition",
            },
        }
,

    -- 'setnz reg' writes a byte from not-zero condition.
        {
            node_type = "instruction",
            mnemonic = "setnz",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setnz_register",
                target_operand = 1,
                role = "set byte from not-zero condition",
            },
        }
,

    -- 'setbe reg' writes a byte from below-or-equal condition.
        {
            node_type = "instruction",
            mnemonic = "setbe",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setbe_register",
                target_operand = 1,
                role = "set byte from below-or-equal condition",
            },
        }
,

    -- 'setna reg' writes a byte from not-above condition.
        {
            node_type = "instruction",
            mnemonic = "setna",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setna_register",
                target_operand = 1,
                role = "set byte from not-above condition",
            },
        }
,

    -- 'seta reg' writes a byte from above condition.
        {
            node_type = "instruction",
            mnemonic = "seta",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "seta_register",
                target_operand = 1,
                role = "set byte from above condition",
            },
        }
,

    -- 'setnbe reg' writes a byte from not-below-or-equal condition.
        {
            node_type = "instruction",
            mnemonic = "setnbe",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setnbe_register",
                target_operand = 1,
                role = "set byte from not-below-or-equal condition",
            },
        }
,

    -- 'sets reg' writes a byte from sign condition.
        {
            node_type = "instruction",
            mnemonic = "sets",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "sets_register",
                target_operand = 1,
                role = "set byte from sign condition",
            },
        }
,

    -- 'setns reg' writes a byte from not-sign condition.
        {
            node_type = "instruction",
            mnemonic = "setns",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setns_register",
                target_operand = 1,
                role = "set byte from not-sign condition",
            },
        }
,

    -- 'setp reg' writes a byte from parity condition.
        {
            node_type = "instruction",
            mnemonic = "setp",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setp_register",
                target_operand = 1,
                role = "set byte from parity condition",
            },
        }
,

    -- 'setpe reg' writes a byte from parity-even condition.
        {
            node_type = "instruction",
            mnemonic = "setpe",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setpe_register",
                target_operand = 1,
                role = "set byte from parity-even condition",
            },
        }
,

    -- 'setnp reg' writes a byte from not-parity condition.
        {
            node_type = "instruction",
            mnemonic = "setnp",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setnp_register",
                target_operand = 1,
                role = "set byte from not-parity condition",
            },
        }
,

    -- 'setpo reg' writes a byte from parity-odd condition.
        {
            node_type = "instruction",
            mnemonic = "setpo",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setpo_register",
                target_operand = 1,
                role = "set byte from parity-odd condition",
            },
        }
,

    -- 'setl reg' writes a byte from less-than condition.
        {
            node_type = "instruction",
            mnemonic = "setl",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setl_register",
                target_operand = 1,
                role = "set byte from less-than condition",
            },
        }
,

    -- 'setnge reg' writes a byte from not-greater-or-equal condition.
        {
            node_type = "instruction",
            mnemonic = "setnge",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setnge_register",
                target_operand = 1,
                role = "set byte from not-greater-or-equal condition",
            },
        }
,

    -- 'setge reg' writes a byte from greater-or-equal condition.
        {
            node_type = "instruction",
            mnemonic = "setge",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setge_register",
                target_operand = 1,
                role = "set byte from greater-or-equal condition",
            },
        }
,

    -- 'setnl reg' writes a byte from not-less-than condition.
        {
            node_type = "instruction",
            mnemonic = "setnl",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setnl_register",
                target_operand = 1,
                role = "set byte from not-less-than condition",
            },
        }
,

    -- 'setle reg' writes a byte from less-or-equal condition.
        {
            node_type = "instruction",
            mnemonic = "setle",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setle_register",
                target_operand = 1,
                role = "set byte from less-or-equal condition",
            },
        }
,

    -- 'setng reg' writes a byte from not-greater-than condition.
        {
            node_type = "instruction",
            mnemonic = "setng",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setng_register",
                target_operand = 1,
                role = "set byte from not-greater-than condition",
            },
        }
,

    -- 'setg reg' writes a byte from greater-than condition.
        {
            node_type = "instruction",
            mnemonic = "setg",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setg_register",
                target_operand = 1,
                role = "set byte from greater-than condition",
            },
        }
,

    -- 'setnle reg' writes a byte from not-less-or-equal condition.
        {
            node_type = "instruction",
            mnemonic = "setnle",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "setnle_register",
                target_operand = 1,
                role = "set byte from not-less-or-equal condition",
            },
        }
,

    -- 'cmovo reg, source' conditionally moves on overflow.
        {
            node_type = "instruction",
            mnemonic = "cmovo",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovo_register",
                target_operand = 1,
                role = "conditionally moved from overflow condition",
            },
        }
,

    -- 'cmovno reg, source' conditionally moves on not-overflow.
        {
            node_type = "instruction",
            mnemonic = "cmovno",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovno_register",
                target_operand = 1,
                role = "conditionally moved from not-overflow condition",
            },
        }
,

    -- 'cmovb reg, source' conditionally moves on below/carry.
        {
            node_type = "instruction",
            mnemonic = "cmovb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovb_register",
                target_operand = 1,
                role = "conditionally moved from below condition",
            },
        }
,

    -- 'cmovc reg, source' conditionally moves on carry.
        {
            node_type = "instruction",
            mnemonic = "cmovc",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovc_register",
                target_operand = 1,
                role = "conditionally moved from carry condition",
            },
        }
,

    -- 'cmovae reg, source' conditionally moves on above-or-equal.
        {
            node_type = "instruction",
            mnemonic = "cmovae",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovae_register",
                target_operand = 1,
                role = "conditionally moved from above-or-equal condition",
            },
        }
,

    -- 'cmovnc reg, source' conditionally moves on not-carry.
        {
            node_type = "instruction",
            mnemonic = "cmovnc",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnc_register",
                target_operand = 1,
                role = "conditionally moved from not-carry condition",
            },
        }
,

    -- 'cmove reg, source' conditionally moves on equal.
        {
            node_type = "instruction",
            mnemonic = "cmove",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmove_register",
                target_operand = 1,
                role = "conditionally moved from equal condition",
            },
        }
,

    -- 'cmovz reg, source' conditionally moves on zero.
        {
            node_type = "instruction",
            mnemonic = "cmovz",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovz_register",
                target_operand = 1,
                role = "conditionally moved from zero condition",
            },
        }
,

    -- 'cmovne reg, source' conditionally moves on not-equal.
        {
            node_type = "instruction",
            mnemonic = "cmovne",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovne_register",
                target_operand = 1,
                role = "conditionally moved from not-equal condition",
            },
        }
,

    -- 'cmovnz reg, source' conditionally moves on not-zero.
        {
            node_type = "instruction",
            mnemonic = "cmovnz",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnz_register",
                target_operand = 1,
                role = "conditionally moved from not-zero condition",
            },
        }
,

    -- 'cmovbe reg, source' conditionally moves on below-or-equal.
        {
            node_type = "instruction",
            mnemonic = "cmovbe",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovbe_register",
                target_operand = 1,
                role = "conditionally moved from below-or-equal condition",
            },
        }
,

    -- 'cmova reg, source' conditionally moves on above.
        {
            node_type = "instruction",
            mnemonic = "cmova",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmova_register",
                target_operand = 1,
                role = "conditionally moved from above condition",
            },
        }
,

    -- 'cmovs reg, source' conditionally moves on sign.
        {
            node_type = "instruction",
            mnemonic = "cmovs",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovs_register",
                target_operand = 1,
                role = "conditionally moved from sign condition",
            },
        }
,

    -- 'cmovns reg, source' conditionally moves on not-sign.
        {
            node_type = "instruction",
            mnemonic = "cmovns",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovns_register",
                target_operand = 1,
                role = "conditionally moved from not-sign condition",
            },
        }
,

    -- 'cmovp reg, source' conditionally moves on parity.
        {
            node_type = "instruction",
            mnemonic = "cmovp",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovp_register",
                target_operand = 1,
                role = "conditionally moved from parity condition",
            },
        }
,

    -- 'cmovnp reg, source' conditionally moves on not-parity.
        {
            node_type = "instruction",
            mnemonic = "cmovnp",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnp_register",
                target_operand = 1,
                role = "conditionally moved from not-parity condition",
            },
        }
,

    -- 'cmovl reg, source' conditionally moves on less-than.
        {
            node_type = "instruction",
            mnemonic = "cmovl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovl_register",
                target_operand = 1,
                role = "conditionally moved from less-than condition",
            },
        }
,

    -- 'cmovge reg, source' conditionally moves on greater-or-equal.
        {
            node_type = "instruction",
            mnemonic = "cmovge",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovge_register",
                target_operand = 1,
                role = "conditionally moved from greater-or-equal condition",
            },
        }
,

    -- 'cmovle reg, source' conditionally moves on less-or-equal.
        {
            node_type = "instruction",
            mnemonic = "cmovle",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovle_register",
                target_operand = 1,
                role = "conditionally moved from less-or-equal condition",
            },
        }
,

    -- 'cmovg reg, source' conditionally moves on greater-than.
        {
            node_type = "instruction",
            mnemonic = "cmovg",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovg_register",
                target_operand = 1,
                role = "conditionally moved from greater-than condition",
            },
        }
,

    -- 'xlatb' writes a translated table byte into al.
        {
            node_type = "instruction",
            mnemonic = "xlatb",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "xlatb_writes_rax",
                target_register = "rax",
                role = "loaded translated byte into al by xlatb",
            },
        }
,

    -- 'outsb' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "outsb",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "outsb_updates_rsi",
                target_register = "rsi",
                role = "advanced by outsb",
            },
        }
,

    -- 'outsw' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "outsw",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "outsw_updates_rsi",
                target_register = "rsi",
                role = "advanced by outsw",
            },
        }
,

    -- 'outsd' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "outsd",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "outsd_updates_rsi",
                target_register = "rsi",
                role = "advanced by outsd",
            },
        }
,

    -- 'insb' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "insb",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "insb_updates_rdi",
                target_register = "rdi",
                role = "advanced by insb",
            },
        }
,

    -- 'insw' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "insw",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "insw_updates_rdi",
                target_register = "rdi",
                role = "advanced by insw",
            },
        }
,

    -- 'insd' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "insd",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "insd_updates_rdi",
                target_register = "rdi",
                role = "advanced by insd",
            },
        }
,

    -- 'movsb' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "movsb",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "movsb_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by movsb",
            },
        }
,

    -- 'movsb' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "movsb",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "movsb_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by movsb",
            },
        }
,

    -- 'movsw' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "movsw",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "movsw_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by movsw",
            },
        }
,

    -- 'movsw' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "movsw",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "movsw_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by movsw",
            },
        }
,

    -- 'movsd' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "movsd",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "movsd_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by movsd",
            },
        }
,

    -- 'movsd' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "movsd",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "movsd_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by movsd",
            },
        }
,

    -- 'movsq' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "movsq",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "movsq_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by movsq",
            },
        }
,

    -- 'movsq' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "movsq",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "movsq_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by movsq",
            },
        }
,

    -- 'stosb' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "stosb",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "stosb_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by stosb",
            },
        }
,

    -- 'stosw' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "stosw",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "stosw_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by stosw",
            },
        }
,

    -- 'stosd' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "stosd",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "stosd_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by stosd",
            },
        }
,

    -- 'stosq' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "stosq",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "stosq_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by stosq",
            },
        }
,

    -- 'lodsb' loads a byte into al.
        {
            node_type = "instruction",
            mnemonic = "lodsb",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "lodsb_writes_rax",
                target_register = "rax",
                role = "loaded byte into al by lodsb",
            },
        }
,

    -- 'lodsb' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "lodsb",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "lodsb_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by lodsb",
            },
        }
,

    -- 'lodsw' loads a word into ax.
        {
            node_type = "instruction",
            mnemonic = "lodsw",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "lodsw_writes_rax",
                target_register = "rax",
                role = "loaded word into ax by lodsw",
            },
        }
,

    -- 'lodsw' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "lodsw",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "lodsw_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by lodsw",
            },
        }
,

    -- 'lodsd' loads a dword into eax.
        {
            node_type = "instruction",
            mnemonic = "lodsd",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "lodsd_writes_rax",
                target_register = "rax",
                role = "loaded dword into eax by lodsd",
            },
        }
,

    -- 'lodsd' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "lodsd",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "lodsd_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by lodsd",
            },
        }
,

    -- 'lodsq' loads a qword into rax.
        {
            node_type = "instruction",
            mnemonic = "lodsq",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "lodsq_writes_rax",
                target_register = "rax",
                role = "loaded qword into rax by lodsq",
            },
        }
,

    -- 'lodsq' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "lodsq",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "lodsq_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by lodsq",
            },
        }
,

    -- 'scasb' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "scasb",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "scasb_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by scasb",
            },
        }
,

    -- 'scasb' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "scasb",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "scasb_updates_rflags",
                target_register = "rflags",
                role = "updated by scasb",
            },
        }
,

    -- 'scasw' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "scasw",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "scasw_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by scasw",
            },
        }
,

    -- 'scasw' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "scasw",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "scasw_updates_rflags",
                target_register = "rflags",
                role = "updated by scasw",
            },
        }
,

    -- 'scasd' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "scasd",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "scasd_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by scasd",
            },
        }
,

    -- 'scasd' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "scasd",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "scasd_updates_rflags",
                target_register = "rflags",
                role = "updated by scasd",
            },
        }
,

    -- 'scasq' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "scasq",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "scasq_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by scasq",
            },
        }
,

    -- 'scasq' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "scasq",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "scasq_updates_rflags",
                target_register = "rflags",
                role = "updated by scasq",
            },
        }
,

    -- 'cmpsb' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "cmpsb",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cmpsb_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by cmpsb",
            },
        }
,

    -- 'cmpsb' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "cmpsb",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cmpsb_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by cmpsb",
            },
        }
,

    -- 'cmpsb' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "cmpsb",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cmpsb_updates_rflags",
                target_register = "rflags",
                role = "updated by cmpsb",
            },
        }
,

    -- 'cmpsw' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "cmpsw",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cmpsw_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by cmpsw",
            },
        }
,

    -- 'cmpsw' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "cmpsw",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cmpsw_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by cmpsw",
            },
        }
,

    -- 'cmpsw' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "cmpsw",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cmpsw_updates_rflags",
                target_register = "rflags",
                role = "updated by cmpsw",
            },
        }
,

    -- 'cmpsd' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "cmpsd",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cmpsd_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by cmpsd",
            },
        }
,

    -- 'cmpsd' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "cmpsd",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cmpsd_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by cmpsd",
            },
        }
,

    -- 'cmpsd' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "cmpsd",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cmpsd_updates_rflags",
                target_register = "rflags",
                role = "updated by cmpsd",
            },
        }
,

    -- 'cmpsq' advances rsi.
        {
            node_type = "instruction",
            mnemonic = "cmpsq",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cmpsq_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by cmpsq",
            },
        }
,

    -- 'cmpsq' advances rdi.
        {
            node_type = "instruction",
            mnemonic = "cmpsq",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cmpsq_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by cmpsq",
            },
        }
,

    -- 'cmpsq' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "cmpsq",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cmpsq_updates_rflags",
                target_register = "rflags",
                role = "updated by cmpsq",
            },
        }
,

    -- 'mov rbp, rsp' establishes a stack frame base.
        {
            node_type = "instruction",
            mnemonic = "mov",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "frame_pointer",
                    value = "rbp",
                },
                {
                    index = 2,
                    kind = "register",
                    role = "stack_pointer",
                    value = "rsp",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "mov_rbp_rsp_frame_base",
                target_operand = 1,
                value_from_register_operand = 2,
                role = "established frame base from rsp",
            },
        }
,

    -- 'movsw' advances the string source pointer.
        {
            node_type = "instruction",
            mnemonic = "movsw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "movsw_advances_rsi",
                target_register = "rsi",
                role = "advanced source pointer by movsw",
            },
        }
,

    -- 'movsw' advances the string destination pointer.
        {
            node_type = "instruction",
            mnemonic = "movsw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "movsw_advances_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by movsw",
            },
        }
,

    -- 'movsd' advances the string source pointer.
        {
            node_type = "instruction",
            mnemonic = "movsd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "movsd_advances_rsi",
                target_register = "rsi",
                role = "advanced source pointer by movsd",
            },
        }
,

    -- 'movsd' advances the string destination pointer.
        {
            node_type = "instruction",
            mnemonic = "movsd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "movsd_advances_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by movsd",
            },
        }
,

    -- 'lodsw' loads a word into ax.
        {
            node_type = "instruction",
            mnemonic = "lodsw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "lodsw_writes_rax",
                target_register = "rax",
                role = "loaded word into ax by lodsw",
                written_alias = "ax",
            },
        }
,

    -- 'lodsw' advances the string source pointer.
        {
            node_type = "instruction",
            mnemonic = "lodsw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "lodsw_advances_rsi",
                target_register = "rsi",
                role = "advanced source pointer by lodsw",
            },
        }
,

    -- 'lodsd' loads a doubleword into eax.
        {
            node_type = "instruction",
            mnemonic = "lodsd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "lodsd_writes_rax",
                target_register = "rax",
                role = "loaded doubleword into eax by lodsd",
                written_alias = "eax",
            },
        }
,

    -- 'lodsd' advances the string source pointer.
        {
            node_type = "instruction",
            mnemonic = "lodsd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "lodsd_advances_rsi",
                target_register = "rsi",
                role = "advanced source pointer by lodsd",
            },
        }
,

    -- 'stosw' stores ax and advances the string destination pointer.
        {
            node_type = "instruction",
            mnemonic = "stosw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "stosw_advances_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by stosw",
            },
        }
,

    -- 'stosd' stores eax and advances the string destination pointer.
        {
            node_type = "instruction",
            mnemonic = "stosd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "stosd_advances_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by stosd",
            },
        }
,

    -- 'scasw' compares ax with memory and advances the destination pointer.
        {
            node_type = "instruction",
            mnemonic = "scasw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "scasw_advances_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by scasw",
            },
        }
,

    -- 'scasw' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "scasw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "scasw_updates_rflags",
                target_register = "rflags",
                role = "updated by scasw",
            },
        }
,

    -- 'scasd' compares eax with memory and advances the destination pointer.
        {
            node_type = "instruction",
            mnemonic = "scasd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "scasd_advances_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by scasd",
            },
        }
,

    -- 'scasd' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "scasd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "scasd_updates_rflags",
                target_register = "rflags",
                role = "updated by scasd",
            },
        }
,

    -- 'cmpsw' compares words and advances the source pointer.
        {
            node_type = "instruction",
            mnemonic = "cmpsw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cmpsw_advances_rsi",
                target_register = "rsi",
                role = "advanced source pointer by cmpsw",
            },
        }
,

    -- 'cmpsw' compares words and advances the destination pointer.
        {
            node_type = "instruction",
            mnemonic = "cmpsw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cmpsw_advances_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by cmpsw",
            },
        }
,

    -- 'cmpsw' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "cmpsw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cmpsw_updates_rflags",
                target_register = "rflags",
                role = "updated by cmpsw",
            },
        }
,

    -- 'cmpsd' compares doublewords and advances the source pointer.
        {
            node_type = "instruction",
            mnemonic = "cmpsd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cmpsd_advances_rsi",
                target_register = "rsi",
                role = "advanced source pointer by cmpsd",
            },
        }
,

    -- 'cmpsd' compares doublewords and advances the destination pointer.
        {
            node_type = "instruction",
            mnemonic = "cmpsd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cmpsd_advances_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by cmpsd",
            },
        }
,

    -- 'cmpsd' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "cmpsd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cmpsd_updates_rflags",
                target_register = "rflags",
                role = "updated by cmpsd",
            },
        }
,

    -- Additional SETcc alias effects.
        {
            node_type = "instruction",
            mnemonic = "seta",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "seta_writes_destination",
                target_operand = 1,
                role = "set byte from above condition by seta",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setae",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setae_writes_destination",
                target_operand = 1,
                role = "set byte from above-or-equal condition by setae",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setb",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setb_writes_destination",
                target_operand = 1,
                role = "set byte from below condition by setb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setbe",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setbe_writes_destination",
                target_operand = 1,
                role = "set byte from below-or-equal condition by setbe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setz",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setz_writes_destination",
                target_operand = 1,
                role = "set byte from zero condition by setz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnz",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setnz_writes_destination",
                target_operand = 1,
                role = "set byte from not-zero condition by setnz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setge",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setge_writes_destination",
                target_operand = 1,
                role = "set byte from greater-or-equal condition by setge",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setle",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setle_writes_destination",
                target_operand = 1,
                role = "set byte from less-or-equal condition by setle",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sets",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "sets_writes_destination",
                target_operand = 1,
                role = "set byte from sign condition by sets",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setns",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setns_writes_destination",
                target_operand = 1,
                role = "set byte from not-sign condition by setns",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setp",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setp_writes_destination",
                target_operand = 1,
                role = "set byte from parity condition by setp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnp",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setnp_writes_destination",
                target_operand = 1,
                role = "set byte from not-parity condition by setnp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setpe",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setpe_writes_destination",
                target_operand = 1,
                role = "set byte from parity-even condition by setpe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setpo",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setpo_writes_destination",
                target_operand = 1,
                role = "set byte from parity-odd condition by setpo",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setna",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setna_writes_destination",
                target_operand = 1,
                role = "set byte from not-above condition by setna",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnbe",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setnbe_writes_destination",
                target_operand = 1,
                role = "set byte from not-below-or-equal condition by setnbe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnae",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setnae_writes_destination",
                target_operand = 1,
                role = "set byte from not-above-or-equal condition by setnae",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnb",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setnb_writes_destination",
                target_operand = 1,
                role = "set byte from not-below condition by setnb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnge",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setnge_writes_destination",
                target_operand = 1,
                role = "set byte from not-greater-or-equal condition by setnge",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setng",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setng_writes_destination",
                target_operand = 1,
                role = "set byte from not-greater condition by setng",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnl",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setnl_writes_destination",
                target_operand = 1,
                role = "set byte from not-less condition by setnl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnle",
            operands = { { index = 1, kind = "register", role = "destination" } },
            effect = {
                kind = "register_write",
                name = "setnle_writes_destination",
                target_operand = 1,
                role = "set byte from not-less-or-equal condition by setnle",
            },
        }
,

    -- Additional CMOVcc alias effects.
        {
            node_type = "instruction",
            mnemonic = "cmova",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmova_writes_destination",
                target_operand = 1,
                role = "conditionally moved from above condition by cmova",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovae",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovae_writes_destination",
                target_operand = 1,
                role = "conditionally moved from above-or-equal condition by cmovae",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovb_writes_destination",
                target_operand = 1,
                role = "conditionally moved from below condition by cmovb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovbe",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovbe_writes_destination",
                target_operand = 1,
                role = "conditionally moved from below-or-equal condition by cmovbe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovz",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovz_writes_destination",
                target_operand = 1,
                role = "conditionally moved from zero condition by cmovz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnz",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnz_writes_destination",
                target_operand = 1,
                role = "conditionally moved from not-zero condition by cmovnz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovge",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovge_writes_destination",
                target_operand = 1,
                role = "conditionally moved from greater-or-equal condition by cmovge",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovle",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovle_writes_destination",
                target_operand = 1,
                role = "conditionally moved from less-or-equal condition by cmovle",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovo",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovo_writes_destination",
                target_operand = 1,
                role = "conditionally moved from overflow condition by cmovo",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovno",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovno_writes_destination",
                target_operand = 1,
                role = "conditionally moved from not-overflow condition by cmovno",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovs",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovs_writes_destination",
                target_operand = 1,
                role = "conditionally moved from sign condition by cmovs",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovns",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovns_writes_destination",
                target_operand = 1,
                role = "conditionally moved from not-sign condition by cmovns",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovp",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovp_writes_destination",
                target_operand = 1,
                role = "conditionally moved from parity condition by cmovp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnp",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnp_writes_destination",
                target_operand = 1,
                role = "conditionally moved from not-parity condition by cmovnp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovpe",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovpe_writes_destination",
                target_operand = 1,
                role = "conditionally moved from parity-even condition by cmovpe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovpo",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovpo_writes_destination",
                target_operand = 1,
                role = "conditionally moved from parity-odd condition by cmovpo",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovna",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovna_writes_destination",
                target_operand = 1,
                role = "conditionally moved from not-above condition by cmovna",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnbe",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnbe_writes_destination",
                target_operand = 1,
                role = "conditionally moved from not-below-or-equal condition by cmovnbe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnae",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnae_writes_destination",
                target_operand = 1,
                role = "conditionally moved from not-above-or-equal condition by cmovnae",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnb_writes_destination",
                target_operand = 1,
                role = "conditionally moved from not-below condition by cmovnb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnge",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnge_writes_destination",
                target_operand = 1,
                role = "conditionally moved from not-greater-or-equal condition by cmovnge",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovng",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovng_writes_destination",
                target_operand = 1,
                role = "conditionally moved from not-greater condition by cmovng",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnl_writes_destination",
                target_operand = 1,
                role = "conditionally moved from not-less condition by cmovnl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnle",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnle_writes_destination",
                target_operand = 1,
                role = "conditionally moved from not-less-or-equal condition by cmovnle",
            },
        }
,

    -- 'xlat' loads a translated byte into al.
        {
            node_type = "instruction",
            mnemonic = "xlat",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xlat_writes_rax",
                target_register = "rax",
                written_alias = "al",
                role = "loaded translated byte into al by xlat",
            },
        }
,

    -- SIMD/MMX/SSE/AVX visibility effects.
        -- Phase-one model: no SIMD register file yet, so these are exposed as RIP-side activity.
    
        {
            node_type = "instruction",
            mnemonic = "movaps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movaps_simd_move",
                target_register = "rip",
                role = "moved aligned packed single-precision values by movaps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movups",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movups_simd_move",
                target_register = "rip",
                role = "moved unaligned packed single-precision values by movups",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movapd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movapd_simd_move",
                target_register = "rip",
                role = "moved aligned packed double-precision values by movapd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movupd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movupd_simd_move",
                target_register = "rip",
                role = "moved unaligned packed double-precision values by movupd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movdqa",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movdqa_simd_move",
                target_register = "rip",
                role = "moved aligned packed integer values by movdqa",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movdqu",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movdqu_simd_move",
                target_register = "rip",
                role = "moved unaligned packed integer values by movdqu",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movntdq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movntdq_simd_store",
                target_register = "rip",
                role = "stored packed integer values non-temporally by movntdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movntdqa",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movntdqa_simd_load",
                target_register = "rip",
                role = "loaded aligned packed integer values non-temporally by movntdqa",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movntps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movntps_simd_store",
                target_register = "rip",
                role = "stored packed single-precision values non-temporally by movntps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movntpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movntpd_simd_store",
                target_register = "rip",
                role = "stored packed double-precision values non-temporally by movntpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movss_scalar_simd_move",
                target_register = "rip",
                role = "moved scalar single-precision value by movss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movsd_scalar_simd_move",
                target_register = "rip",
                role = "moved scalar double-precision value by movsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmpss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
            effect = {
                kind = "register_write",
                name = "cmpss_scalar_simd_compare",
                target_register = "rip",
                role = "compared scalar single-precision values by cmpss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmpsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
            effect = {
                kind = "register_write",
                name = "cmpsd_scalar_simd_compare",
                target_register = "rip",
                role = "compared scalar double-precision values by cmpsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movhlps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movhlps_simd_shuffle",
                target_register = "rip",
                role = "moved high packed single-precision lanes by movhlps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movlhps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movlhps_simd_shuffle",
                target_register = "rip",
                role = "moved low packed single-precision lanes by movlhps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movhps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movhps_simd_move",
                target_register = "rip",
                role = "moved high packed single-precision lanes by movhps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movlps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movlps_simd_move",
                target_register = "rip",
                role = "moved low packed single-precision lanes by movlps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movhpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movhpd_simd_move",
                target_register = "rip",
                role = "moved high packed double-precision lane by movhpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movlpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movlpd_simd_move",
                target_register = "rip",
                role = "moved low packed double-precision lane by movlpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movmskps",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movmskps_writes_gpr",
                target_operand = 1,
                role = "written with packed single-precision sign mask by movmskps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movmskpd",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "movmskpd_writes_gpr",
                target_operand = 1,
                role = "written with packed double-precision sign mask by movmskpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setssbsy",
            operands = {},
            effect = {
                kind = "register_write",
                name = "setssbsy_updates_shadow_stack",
                target_register = "rip",
                role = "marked shadow stack busy by setssbsy",
            },
        }
,

    -- Direct store / enqueue / cache extension helpers.
    
        {
            node_type = "instruction",
            mnemonic = "movdiri",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movdiri_direct_store",
                target_register = "rip",
                role = "direct-stored integer value by movdiri",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movdir64b",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movdir64b_direct_store",
                target_register = "rip",
                role = "direct-stored 64-byte value by movdir64b",
            },
        }
,

    -- SSE3 duplication / unaligned load helpers.
    
        {
            node_type = "instruction",
            mnemonic = "movsldup",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movsldup_vector_duplicate",
                target_register = "rip",
                role = "duplicated low packed single-precision lanes by movsldup",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movshdup",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movshdup_vector_duplicate",
                target_register = "rip",
                role = "duplicated high packed single-precision lanes by movshdup",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movddup",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movddup_vector_duplicate",
                target_register = "rip",
                role = "duplicated low scalar double-precision lane by movddup",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "insertps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "insertps_vector_insert",
                target_register = "rip",
                role = "inserted single-precision lane by insertps",
            },
        }
,

    -- Legacy MMX/SSE state and move helpers that are common in older disassembly.
    
        {
            node_type = "instruction",
            mnemonic = "movd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movd_mmx_sse_move",
                target_register = "rip",
                role = "moved doubleword between integer and multimedia state by movd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movq_mmx_sse_move",
                target_register = "rip",
                role = "moved quadword between integer and multimedia state by movq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movdq2q",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movdq2q_sse_mmx_bridge",
                target_register = "rip",
                role = "moved low quadword from xmm state to mmx state by movdq2q",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movq2dq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movq2dq_mmx_sse_bridge",
                target_register = "rip",
                role = "moved quadword from mmx state to xmm state by movq2dq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movntq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movntq_nontemporal_store",
                target_register = "rip",
                role = "stored mmx quadword non-temporally by movntq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movntsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movntsd_nontemporal_store",
                target_register = "rip",
                role = "stored scalar double-precision value non-temporally by movntsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movntss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movntss_nontemporal_store",
                target_register = "rip",
                role = "stored scalar single-precision value non-temporally by movntss",
            },
        }
,

    -- Legacy scalar / alias / protected-mode visibility effects.
        -- Some of these are invalid in 64-bit long mode but useful for broad x86-family disassembly recognition.
    
        -- Unsuffixed string-operation aliases.
    
        {
            node_type = "instruction",
            mnemonic = "movs",
            operands = {},
            effect = {
                kind = "register_write",
                name = "movs_advances_rsi",
                target_register = "rsi",
                role = "advanced by unsuffixed string move movs",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movs",
            operands = {},
            effect = {
                kind = "register_write",
                name = "movs_advances_rdi",
                target_register = "rdi",
                role = "advanced by unsuffixed string move movs",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmps",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cmps_advances_rsi",
                target_register = "rsi",
                role = "advanced by unsuffixed string compare cmps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmps",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cmps_advances_rdi",
                target_register = "rdi",
                role = "advanced by unsuffixed string compare cmps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmps",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cmps_updates_rflags",
                target_register = "rflags",
                role = "updated by unsuffixed string compare cmps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "scas",
            operands = {},
            effect = {
                kind = "register_write",
                name = "scas_advances_rdi",
                target_register = "rdi",
                role = "advanced by unsuffixed string scan scas",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "scas",
            operands = {},
            effect = {
                kind = "register_write",
                name = "scas_updates_rflags",
                target_register = "rflags",
                role = "updated by unsuffixed string scan scas",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lods",
            operands = {},
            effect = {
                kind = "register_write",
                name = "lods_writes_rax",
                target_register = "rax",
                role = "loaded by unsuffixed string load lods",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lods",
            operands = {},
            effect = {
                kind = "register_write",
                name = "lods_advances_rsi",
                target_register = "rsi",
                role = "advanced by unsuffixed string load lods",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "stos",
            operands = {},
            effect = {
                kind = "register_write",
                name = "stos_advances_rdi",
                target_register = "rdi",
                role = "advanced by unsuffixed string store stos",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ins",
            operands = {},
            effect = {
                kind = "register_write",
                name = "ins_advances_rdi",
                target_register = "rdi",
                role = "advanced by unsuffixed port input string ins",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "outs",
            operands = {},
            effect = {
                kind = "register_write",
                name = "outs_advances_rsi",
                target_register = "rsi",
                role = "advanced by unsuffixed port output string outs",
            },
        }
,

    -- Explicit short aliases sometimes emitted by assemblers/disassemblers.
    
        {
            node_type = "instruction",
            mnemonic = "movsxw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movsxw_writes_destination",
                target_operand = 1,
                role = "written with sign-extended word by movsxw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movsxb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movsxb_writes_destination",
                target_operand = 1,
                role = "written with sign-extended byte by movsxb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movzxw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movzxw_writes_destination",
                target_operand = 1,
                role = "written with zero-extended word by movzxw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movzxb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movzxb_writes_destination",
                target_operand = 1,
                role = "written with zero-extended byte by movzxb",
            },
        }
,

    -- Move aliases.
    
        {
            node_type = "instruction",
            mnemonic = "movabs",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movabs_writes_destination",
                target_operand = 1,
                source_operand = 2,
                role = "written with absolute move by movabs",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movb_writes_destination",
                target_operand = 1,
                source_operand = 2,
                written_alias = "byte",
                role = "written by byte move movb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movw_writes_destination",
                target_operand = 1,
                source_operand = 2,
                written_alias = "word",
                role = "written by word move movw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movl_writes_destination",
                target_operand = 1,
                source_operand = 2,
                written_alias = "dword",
                role = "written by long move movl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movq_writes_destination",
                target_operand = 1,
                source_operand = 2,
                written_alias = "qword",
                role = "written by quadword move movq",
            },
        }
,

    -- MOVBE byte-swap move.
    
        {
            node_type = "instruction",
            mnemonic = "movbe",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movbe_writes_destination",
                target_operand = 1,
                role = "written with byte-swapped value by movbe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movbe",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movbe_stores_byteswapped_source",
                target_register = "rip",
                role = "stored byte-swapped register value by movbe",
            },
        }
,

    -- XCHG suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "xchgb",
            operands = {
                { index = 1, kind = "register", role = "left" },
                { index = 2, kind = "register", role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "xchgb_writes_left",
                target_operand = 1,
                role = "swapped byte value with register by xchgb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xchgb",
            operands = {
                { index = 1, kind = "register", role = "left" },
                { index = 2, kind = "register", role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "xchgb_writes_right",
                target_operand = 2,
                role = "swapped byte value with register by xchgb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xchgw",
            operands = {
                { index = 1, kind = "register", role = "left" },
                { index = 2, kind = "register", role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "xchgw_writes_left",
                target_operand = 1,
                role = "swapped word value with register by xchgw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xchgw",
            operands = {
                { index = 1, kind = "register", role = "left" },
                { index = 2, kind = "register", role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "xchgw_writes_right",
                target_operand = 2,
                role = "swapped word value with register by xchgw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xchgl",
            operands = {
                { index = 1, kind = "register", role = "left" },
                { index = 2, kind = "register", role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "xchgl_writes_left",
                target_operand = 1,
                role = "swapped long value with register by xchgl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xchgl",
            operands = {
                { index = 1, kind = "register", role = "left" },
                { index = 2, kind = "register", role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "xchgl_writes_right",
                target_operand = 2,
                role = "swapped long value with register by xchgl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xchgq",
            operands = {
                { index = 1, kind = "register", role = "left" },
                { index = 2, kind = "register", role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "xchgq_writes_left",
                target_operand = 1,
                role = "swapped quadword value with register by xchgq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xchgq",
            operands = {
                { index = 1, kind = "register", role = "left" },
                { index = 2, kind = "register", role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "xchgq_writes_right",
                target_operand = 2,
                role = "swapped quadword value with register by xchgq",
            },
        }
,

    -- Conditional move / SETcc alias completion.
        -- These improve recognition of GAS/objdump-style condition aliases and width-explicit CMOV spellings.
    
        -- CMOV equality / zero aliases.
    
        {
            node_type = "instruction",
            mnemonic = "cmoveq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmoveq_writes_destination",
                target_operand = 1,
                role = "conditionally written if equal by cmoveq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovel",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovel_writes_destination",
                target_operand = 1,
                role = "conditionally written if equal by cmovel",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovew",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovew_writes_destination",
                target_operand = 1,
                role = "conditionally written if equal by cmovew",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovzq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovzq_writes_destination",
                target_operand = 1,
                role = "conditionally written if zero by cmovzq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovzl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovzl_writes_destination",
                target_operand = 1,
                role = "conditionally written if zero by cmovzl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovzw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovzw_writes_destination",
                target_operand = 1,
                role = "conditionally written if zero by cmovzw",
            },
        }
,

    -- CMOV not-equal / not-zero aliases.
    
        {
            node_type = "instruction",
            mnemonic = "cmovneq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovneq_writes_destination",
                target_operand = 1,
                role = "conditionally written if not equal by cmovneq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnel",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnel_writes_destination",
                target_operand = 1,
                role = "conditionally written if not equal by cmovnel",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnew",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnew_writes_destination",
                target_operand = 1,
                role = "conditionally written if not equal by cmovnew",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnzq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnzq_writes_destination",
                target_operand = 1,
                role = "conditionally written if not zero by cmovnzq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnzl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnzl_writes_destination",
                target_operand = 1,
                role = "conditionally written if not zero by cmovnzl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnzw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnzw_writes_destination",
                target_operand = 1,
                role = "conditionally written if not zero by cmovnzw",
            },
        }
,

    -- CMOV signed greater / greater-or-equal / less / less-or-equal aliases.
    
        {
            node_type = "instruction",
            mnemonic = "cmovgq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovgq_writes_destination",
                target_operand = 1,
                role = "conditionally written if signed greater by cmovgq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovgl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovgl_writes_destination",
                target_operand = 1,
                role = "conditionally written if signed greater by cmovgl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovgew",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovgew_writes_destination",
                target_operand = 1,
                role = "conditionally written if signed greater-or-equal by cmovgew",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovgeq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovgeq_writes_destination",
                target_operand = 1,
                role = "conditionally written if signed greater-or-equal by cmovgeq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovgel",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovgel_writes_destination",
                target_operand = 1,
                role = "conditionally written if signed greater-or-equal by cmovgel",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovlq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovlq_writes_destination",
                target_operand = 1,
                role = "conditionally written if signed less by cmovlq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovll",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovll_writes_destination",
                target_operand = 1,
                role = "conditionally written if signed less by cmovll",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovlw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovlw_writes_destination",
                target_operand = 1,
                role = "conditionally written if signed less by cmovlw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovleq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovleq_writes_destination",
                target_operand = 1,
                role = "conditionally written if signed less-or-equal by cmovleq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovlel",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovlel_writes_destination",
                target_operand = 1,
                role = "conditionally written if signed less-or-equal by cmovlel",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovlew",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovlew_writes_destination",
                target_operand = 1,
                role = "conditionally written if signed less-or-equal by cmovlew",
            },
        }
,

    -- CMOV unsigned above / above-or-equal / below / below-or-equal aliases.
    
        {
            node_type = "instruction",
            mnemonic = "cmovaq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovaq_writes_destination",
                target_operand = 1,
                role = "conditionally written if unsigned above by cmovaq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovaeq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovaeq_writes_destination",
                target_operand = 1,
                role = "conditionally written if unsigned above-or-equal by cmovaeq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovbq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovbq_writes_destination",
                target_operand = 1,
                role = "conditionally written if unsigned below by cmovbq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovbeq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovbeq_writes_destination",
                target_operand = 1,
                role = "conditionally written if unsigned below-or-equal by cmovbeq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovcq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovcq_writes_destination",
                target_operand = 1,
                role = "conditionally written if carry by cmovcq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovncq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovncq_writes_destination",
                target_operand = 1,
                role = "conditionally written if not carry by cmovncq",
            },
        }
,

    -- CMOV sign / overflow / parity aliases.
    
        {
            node_type = "instruction",
            mnemonic = "cmovsq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovsq_writes_destination",
                target_operand = 1,
                role = "conditionally written if sign by cmovsq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnsq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnsq_writes_destination",
                target_operand = 1,
                role = "conditionally written if not sign by cmovnsq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovoq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovoq_writes_destination",
                target_operand = 1,
                role = "conditionally written if overflow by cmovoq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnoq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnoq_writes_destination",
                target_operand = 1,
                role = "conditionally written if not overflow by cmovnoq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovpq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovpq_writes_destination",
                target_operand = 1,
                role = "conditionally written if parity by cmovpq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnpq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnpq_writes_destination",
                target_operand = 1,
                role = "conditionally written if not parity by cmovnpq",
            },
        }
,

    -- SETcc aliases.
    
        {
            node_type = "instruction",
            mnemonic = "setz",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setz_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if zero by setz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnz",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setnz_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if not zero by setnz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sete",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "sete_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if equal by sete",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setne",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setne_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if not equal by setne",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setg",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setg_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if signed greater by setg",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setge",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setge_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if signed greater-or-equal by setge",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setl_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if signed less by setl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setle",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setle_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if signed less-or-equal by setle",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "seta",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "seta_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if unsigned above by seta",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setae",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setae_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if unsigned above-or-equal by setae",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setb_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if unsigned below by setb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setbe",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setbe_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if unsigned below-or-equal by setbe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sets",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "sets_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if sign by sets",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setns",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setns_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if not sign by setns",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "seto",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "seto_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if overflow by seto",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setno",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setno_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if not overflow by setno",
            },
        }
,

    -- SETcc / CMOVcc remaining condition alias completion.
        -- This fills carry/parity/negated-condition aliases not covered by the previous batch.
    
        -- SETcc carry / not-carry aliases.
    
        {
            node_type = "instruction",
            mnemonic = "setc",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setc_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if carry by setc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnc",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setnc_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if not carry by setnc",
            },
        }
,

    -- SETcc parity aliases.
    
        {
            node_type = "instruction",
            mnemonic = "setp",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setp_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if parity by setp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnp",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setnp_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if not parity by setnp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setpe",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setpe_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if parity even by setpe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setpo",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setpo_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if parity odd by setpo",
            },
        }
,

    -- SETcc negated unsigned aliases.
    
        {
            node_type = "instruction",
            mnemonic = "setna",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setna_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if not unsigned above by setna",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnae",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setnae_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if not unsigned above-or-equal by setnae",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setnb_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if not unsigned below by setnb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnbe",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setnbe_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if not unsigned below-or-equal by setnbe",
            },
        }
,

    -- SETcc negated signed aliases.
    
        {
            node_type = "instruction",
            mnemonic = "setng",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setng_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if not signed greater by setng",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnge",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setnge_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if not signed greater-or-equal by setnge",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setnl_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if not signed less by setnl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "setnle",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "setnle_writes_destination",
                target_operand = 1,
                written_alias = "byte",
                role = "set byte if not signed less-or-equal by setnle",
            },
        }
,

    -- CMOV negated unsigned aliases.
    
        {
            node_type = "instruction",
            mnemonic = "cmovnaq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnaq_writes_destination",
                target_operand = 1,
                role = "conditionally written if not unsigned above by cmovnaq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnaeq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnaeq_writes_destination",
                target_operand = 1,
                role = "conditionally written if not unsigned above-or-equal by cmovnaeq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnbq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnbq_writes_destination",
                target_operand = 1,
                role = "conditionally written if not unsigned below by cmovnbq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnbeq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnbeq_writes_destination",
                target_operand = 1,
                role = "conditionally written if not unsigned below-or-equal by cmovnbeq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnal",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnal_writes_destination",
                target_operand = 1,
                role = "conditionally written if not unsigned above by cmovnal",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnael",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnael_writes_destination",
                target_operand = 1,
                role = "conditionally written if not unsigned above-or-equal by cmovnael",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnbl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnbl_writes_destination",
                target_operand = 1,
                role = "conditionally written if not unsigned below by cmovnbl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnbel",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnbel_writes_destination",
                target_operand = 1,
                role = "conditionally written if not unsigned below-or-equal by cmovnbel",
            },
        }
,

    -- CMOV negated signed aliases.
    
        {
            node_type = "instruction",
            mnemonic = "cmovngq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovngq_writes_destination",
                target_operand = 1,
                role = "conditionally written if not signed greater by cmovngq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovngeq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovngeq_writes_destination",
                target_operand = 1,
                role = "conditionally written if not signed greater-or-equal by cmovngeq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnlq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnlq_writes_destination",
                target_operand = 1,
                role = "conditionally written if not signed less by cmovnlq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnleq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnleq_writes_destination",
                target_operand = 1,
                role = "conditionally written if not signed less-or-equal by cmovnleq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovngl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovngl_writes_destination",
                target_operand = 1,
                role = "conditionally written if not signed greater by cmovngl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovngel",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovngel_writes_destination",
                target_operand = 1,
                role = "conditionally written if not signed greater-or-equal by cmovngel",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnll",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnll_writes_destination",
                target_operand = 1,
                role = "conditionally written if not signed less by cmovnll",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovnlel",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovnlel_writes_destination",
                target_operand = 1,
                role = "conditionally written if not signed less-or-equal by cmovnlel",
            },
        }
,

    -- CMOV parity even / odd width aliases.
    
        {
            node_type = "instruction",
            mnemonic = "cmovpeq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovpeq_writes_destination",
                target_operand = 1,
                role = "conditionally written if parity even by cmovpeq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovpoq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovpoq_writes_destination",
                target_operand = 1,
                role = "conditionally written if parity odd by cmovpoq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovpel",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovpel_writes_destination",
                target_operand = 1,
                role = "conditionally written if parity even by cmovpel",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmovpol",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmovpol_writes_destination",
                target_operand = 1,
                role = "conditionally written if parity odd by cmovpol",
            },
        }
,

    -- Conversion / sign-extension / zero-extension suffix aliases.
        -- These improve recognition of GAS/objdump-style extension mnemonics.
    
        -- MOVSX-style sign-extension aliases.
    
        {
            node_type = "instruction",
            mnemonic = "movsbw",
            operands = {
                { index = 1, kind = "register", role = "source" },
                { index = 2, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "movsbw_writes_destination",
                target_operand = 2,
                source_operand = 1,
                role = "written with sign-extended byte to word by movsbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movsbl",
            operands = {
                { index = 1, kind = "register", role = "source" },
                { index = 2, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "movsbl_writes_destination",
                target_operand = 2,
                source_operand = 1,
                role = "written with sign-extended byte to long by movsbl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movsbq",
            operands = {
                { index = 1, kind = "register", role = "source" },
                { index = 2, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "movsbq_writes_destination",
                target_operand = 2,
                source_operand = 1,
                role = "written with sign-extended byte to quadword by movsbq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movswl",
            operands = {
                { index = 1, kind = "register", role = "source" },
                { index = 2, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "movswl_writes_destination",
                target_operand = 2,
                source_operand = 1,
                role = "written with sign-extended word to long by movswl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movswq",
            operands = {
                { index = 1, kind = "register", role = "source" },
                { index = 2, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "movswq_writes_destination",
                target_operand = 2,
                source_operand = 1,
                role = "written with sign-extended word to quadword by movswq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movslq",
            operands = {
                { index = 1, kind = "register", role = "source" },
                { index = 2, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "movslq_writes_destination",
                target_operand = 2,
                source_operand = 1,
                role = "written with sign-extended long to quadword by movslq",
            },
        }
,

    -- Intel-style aliases that some parsers/disassemblers may expose.
    
        {
            node_type = "instruction",
            mnemonic = "movsxw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movsxw_writes_destination",
                target_operand = 1,
                source_operand = 2,
                role = "written with sign-extended word by movsxw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movsxl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movsxl_writes_destination",
                target_operand = 1,
                source_operand = 2,
                role = "written with sign-extended long by movsxl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movsxq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movsxq_writes_destination",
                target_operand = 1,
                source_operand = 2,
                role = "written with sign-extended quadword by movsxq",
            },
        }
,

    -- MOVZX-style zero-extension aliases.
    
        {
            node_type = "instruction",
            mnemonic = "movzbw",
            operands = {
                { index = 1, kind = "register", role = "source" },
                { index = 2, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "movzbw_writes_destination",
                target_operand = 2,
                source_operand = 1,
                role = "written with zero-extended byte to word by movzbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movzbl",
            operands = {
                { index = 1, kind = "register", role = "source" },
                { index = 2, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "movzbl_writes_destination",
                target_operand = 2,
                source_operand = 1,
                role = "written with zero-extended byte to long by movzbl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movzbq",
            operands = {
                { index = 1, kind = "register", role = "source" },
                { index = 2, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "movzbq_writes_destination",
                target_operand = 2,
                source_operand = 1,
                role = "written with zero-extended byte to quadword by movzbq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movzwl",
            operands = {
                { index = 1, kind = "register", role = "source" },
                { index = 2, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "movzwl_writes_destination",
                target_operand = 2,
                source_operand = 1,
                role = "written with zero-extended word to long by movzwl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movzwq",
            operands = {
                { index = 1, kind = "register", role = "source" },
                { index = 2, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "movzwq_writes_destination",
                target_operand = 2,
                source_operand = 1,
                role = "written with zero-extended word to quadword by movzwq",
            },
        }
,

    -- Intel-style zero-extension aliases.
    
        {
            node_type = "instruction",
            mnemonic = "movzxw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movzxw_writes_destination",
                target_operand = 1,
                source_operand = 2,
                role = "written with zero-extended word by movzxw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movzxl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movzxl_writes_destination",
                target_operand = 1,
                source_operand = 2,
                role = "written with zero-extended long by movzxl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movzxq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movzxq_writes_destination",
                target_operand = 1,
                source_operand = 2,
                role = "written with zero-extended quadword by movzxq",
            },
        }
,

    -- IO string suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "insb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "insb_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by byte input string insb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "insw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "insw_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by word input string insw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "insl",
            operands = {},
            effect = {
                kind = "register_write",
                name = "insl_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by long input string insl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "insq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "insq_updates_rdi",
                target_register = "rdi",
                role = "advanced destination pointer by quadword input string insq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "outsb",
            operands = {},
            effect = {
                kind = "register_write",
                name = "outsb_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by byte output string outsb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "outsw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "outsw_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by word output string outsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "outsl",
            operands = {},
            effect = {
                kind = "register_write",
                name = "outsl_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by long output string outsl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "outsq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "outsq_updates_rsi",
                target_register = "rsi",
                role = "advanced source pointer by quadword output string outsq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmpss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "cmpss_scalar_fp_compare",
                target_register = "rip",
                role = "performed scalar single-precision compare by cmpss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmpsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "predicate" },
            },
            effect = {
                kind = "register_write",
                name = "cmpsd_scalar_fp_compare",
                target_register = "rip",
                role = "performed scalar double-precision compare by cmpsd",
            },
        }
,

    -- Checkpoint 4.64 — SIMD move / unpack / shuffle / blend leftover sweep.
        -- These are mostly vector-register effects, so phase-one records visible instruction activity through RIP.
    
        {
            node_type = "instruction",
            mnemonic = "movaps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movaps_vector_move",
                target_register = "rip",
                role = "moved aligned packed single-precision value by movaps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movups",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movups_vector_move",
                target_register = "rip",
                role = "moved unaligned packed single-precision value by movups",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movapd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movapd_vector_move",
                target_register = "rip",
                role = "moved aligned packed double-precision value by movapd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movupd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movupd_vector_move",
                target_register = "rip",
                role = "moved unaligned packed double-precision value by movupd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movdqa",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movdqa_vector_move",
                target_register = "rip",
                role = "moved aligned packed integer value by movdqa",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movdqu",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movdqu_vector_move",
                target_register = "rip",
                role = "moved unaligned packed integer value by movdqu",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movntps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movntps_streaming_store",
                target_register = "rip",
                role = "performed non-temporal packed single-precision store by movntps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movntpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movntpd_streaming_store",
                target_register = "rip",
                role = "performed non-temporal packed double-precision store by movntpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movntdq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movntdq_streaming_store",
                target_register = "rip",
                role = "performed non-temporal packed integer store by movntdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movhlps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movhlps_vector_lane_move",
                target_register = "rip",
                role = "moved high packed single-precision lanes to low lanes by movhlps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movlhps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movlhps_vector_lane_move",
                target_register = "rip",
                role = "moved low packed single-precision lanes to high lanes by movlhps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movlps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movlps_vector_low_move",
                target_register = "rip",
                role = "moved low packed single-precision lanes by movlps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movhps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movhps_vector_high_move",
                target_register = "rip",
                role = "moved high packed single-precision lanes by movhps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movlpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movlpd_vector_low_move",
                target_register = "rip",
                role = "moved low packed double-precision lane by movlpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movhpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movhpd_vector_high_move",
                target_register = "rip",
                role = "moved high packed double-precision lane by movhpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movmskps",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movmskps_writes_destination",
                target_operand = 1,
                role = "written with packed single-precision sign mask by movmskps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "movmskpd",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "movmskpd_writes_destination",
                target_operand = 1,
                role = "written with packed double-precision sign mask by movmskpd",
            },
        }
,

    -- 'mov rsp, rbp' restores the stack pointer from the frame base.
        {
            node_type = "instruction",
            mnemonic = "mov",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "stack_pointer",
                    value = "rsp",
                },
                {
                    index = 2,
                    kind = "register",
                    role = "frame_pointer",
                    value = "rbp",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "mov_rsp_rbp_restore_stack",
                target_operand = 1,
                value_from_register_operand = 2,
                role = "restored stack pointer from frame base",
            },
        }
,

    -- 'mov reg, symbol' tracks symbolic values.
        {
            node_type = "instruction",
            mnemonic = "mov",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
    
                {
                    index = 2,
                    kind = "symbol",
                    role = "source_symbol",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "mov_register_symbol",
                target_operand = 1,
                value_operand = 2,
                role = "loaded symbol by mov",
            },
        }
,

    -- 'lea reg, symbol' tracks symbolic addresses.
        {
            node_type = "instruction",
            mnemonic = "lea",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "symbol",
                    role = "source_address",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "lea_register_symbol",
                target_operand = 1,
                value_operand = 2,
                role = "loaded address by lea",
            },
        }
,
}
