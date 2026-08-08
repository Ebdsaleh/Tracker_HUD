-- lua/tracker_hud/adapters/asm_arch/x86_64.lua
--
-- x86-64 architecture facts for the ASM adapter.
--
-- This file is spec-only.
--
-- It describes:
--   - public architecture name
--   - aliases
--   - register families / register aliases
--   - registers
--   - stack concepts
--   - scope member declarations
--   - instruction effects
--
-- Behaviour belongs in:
--   - asm_adapter.lua
--   - context_engine.lua
--   - registers.lua
--   - register_model.lua
--   - register_tree.lua
--   - stack.lua
--   - asm_instruction_utils.lua

local M = {}

M.name = "x86-64"

M.aliases = {
    "x86-64",
    "x86_64",
    "amd64",
    "x64",
}


M.comments = {
    line = {
        {
            prefix = ";",
            role = "line comment",
        },
    },
}


M.range_scopes = {
    {
        node_type = "label",
        name_node_type = "ident",
        label = "Label",
        range_strategy = "until_next_peer",

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
    },
}


M.construct_specs = {
    ["label"] = {
        construct = {
            kind = "label",
            label = "Label",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        value = {
            kind = "reference",
            type_label = "label",
        },
    },

    ["instruction"] = {
        construct = {
            kind = "instruction",
            label = "Instruction",
        },

        scope = {
            kind = "structural",
            affects_visibility = false,
            owns_members = false,
        },
        
        value = {
            kind = "unknown",
            type_label = "instruction",
        },
    },

    ["reg"] = {
        construct = {
            kind = "register",
            label = "Register",
        },

        value = {
            kind = "reference",
            type_label = "register",
        },
    },

    ["int"] = {
        construct = {
            kind = "immediate",
            label = "Immediate",
        },

        value = {
            kind = "scalar",
            type_label = "integer",
        },
    },

    ["ident"] = {
        construct = {
            kind = "symbol",
            label = "Symbol",
        },

        value = {
            kind = "reference",
            type_label = "symbol",
        },
    },

    ["word"] = {
        construct = {
            kind = "mnemonic",
            label = "Mnemonic",
        },

        value = {
            kind = "symbol",
            type_label = "instruction",
        },
    },
}


M.scope_members = {
    symbols = {
        {
            node_type = "label",
            name_node_type = "ident",

            member = {
                kind = "label",
                owner_scope = "lexical",
            },

            value = {
                kind = "symbol",
                type_label = "label",
            },
        },
        {
            node_type = "instruction",
            mnemonic = "global",
            operand_index = 1,

            member = {
                kind = "global",
                owner_scope = "lexical",
            },

            value = {
                kind = "symbol",
                type_label = "global",
            },
        },
    },
    declarations = {
        {
            node_type = "instruction",
            member = {
                kind = "instruction",
                owner_scope = "lexical",
            },
        },
    },
}


M.register_effects = {
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
    },
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
    },

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
    },

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
    },


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
    },


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
    },

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
    },

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
    },

    -- 'neg reg' arithmetically negates the destination register.
    {
        node_type = "instruction",
        mnemonic = "neg",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "destination",
            },
        },

        effect = {
            kind = "register_write",
            name = "neg_register",
            target_operand = 1,
            role = "arithmetically negated by neg",
        },
    },

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
    },

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
    },

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
    },


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
    },

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
    },


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
    },

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
    },

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
    },


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
    },

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
    },


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
    },

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
    },


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
    },


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
    },


    -- 'mul reg' implicitly writes rax.
    {
        node_type = "instruction",
        mnemonic = "mul",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "multiplier",
            },
        },

        effect = {
            kind = "register_write",
            name = "mul_writes_rax",
            target_register = "rax",
            role = "written by unsigned multiply",
        },
    },

    -- 'mul reg' implicitly writes rdx.
    {
        node_type = "instruction",
        mnemonic = "mul",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "multiplier",
            },
        },

        effect = {
            kind = "register_write",
            name = "mul_writes_rdx",
            target_register = "rdx",
            role = "written by unsigned multiply high result",
        },
    },

    -- 'imul reg' implicitly writes rax.
    {
        node_type = "instruction",
        mnemonic = "imul",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "multiplier",
            },
        },

        effect = {
            kind = "register_write",
            name = "imul_writes_rax",
            target_register = "rax",
            role = "written by signed multiply",
        },
    },

    -- 'imul reg' implicitly writes rdx.
    {
        node_type = "instruction",
        mnemonic = "imul",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "multiplier",
            },
        },

        effect = {
            kind = "register_write",
            name = "imul_writes_rdx",
            target_register = "rdx",
            role = "written by signed multiply high result",
        },
    },

    -- 'div reg' implicitly writes quotient to rax.
    {
        node_type = "instruction",
        mnemonic = "div",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "divisor",
            },
        },

        effect = {
            kind = "register_write",
            name = "div_writes_rax",
            target_register = "rax",
            role = "written with unsigned division quotient",
        },
    },

    -- 'div reg' implicitly writes remainder to rdx.
    {
        node_type = "instruction",
        mnemonic = "div",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "divisor",
            },
        },

        effect = {
            kind = "register_write",
            name = "div_writes_rdx",
            target_register = "rdx",
            role = "written with unsigned division remainder",
        },
    },

    -- 'idiv reg' implicitly writes quotient to rax.
    {
        node_type = "instruction",
        mnemonic = "idiv",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "divisor",
            },
        },

        effect = {
            kind = "register_write",
            name = "idiv_writes_rax",
            target_register = "rax",
            role = "written with signed division quotient",
        },
    },

    -- 'idiv reg' implicitly writes remainder to rdx.
    {
        node_type = "instruction",
        mnemonic = "idiv",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "divisor",
            },
        },

        effect = {
            kind = "register_write",
            name = "idiv_writes_rdx",
            target_register = "rdx",
            role = "written with signed division remainder",
        },
    },


        -- 'cpuid' writes processor information into rax.
    {
        node_type = "instruction",
        mnemonic = "cpuid",

        operands = {},

        effect = {
            kind = "register_write",
            name = "cpuid_writes_rax",
            target_register = "rax",
            role = "written by cpuid",
        },
    },

    -- 'cpuid' writes processor information into rbx.
    {
        node_type = "instruction",
        mnemonic = "cpuid",

        operands = {},

        effect = {
            kind = "register_write",
            name = "cpuid_writes_rbx",
            target_register = "rbx",
            role = "written by cpuid",
        },
    },

    -- 'cpuid' writes processor information into rcx.
    {
        node_type = "instruction",
        mnemonic = "cpuid",

        operands = {},

        effect = {
            kind = "register_write",
            name = "cpuid_writes_rcx",
            target_register = "rcx",
            role = "written by cpuid",
        },
    },

    -- 'cpuid' writes processor information into rdx.
    {
        node_type = "instruction",
        mnemonic = "cpuid",

        operands = {},

        effect = {
            kind = "register_write",
            name = "cpuid_writes_rdx",
            target_register = "rdx",
            role = "written by cpuid",
        },
    },

    -- 'add' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "add",

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },

        effect = {
            kind = "register_write",
            name = "add_updates_rflags",
            target_register = "rflags",
            role = "updated by add",
        },
    },

    -- 'sub' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "sub",

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },

        effect = {
            kind = "register_write",
            name = "sub_updates_rflags",
            target_register = "rflags",
            role = "updated by sub",
        },
    },

    -- 'inc' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "inc",

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },

        effect = {
            kind = "register_write",
            name = "inc_updates_rflags",
            target_register = "rflags",
            role = "updated by inc",
        },
    },

    -- 'dec' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "dec",

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },

        effect = {
            kind = "register_write",
            name = "dec_updates_rflags",
            target_register = "rflags",
            role = "updated by dec",
        },
    },

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
    },

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
    },

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
    },

    -- 'neg' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "neg",

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },

        effect = {
            kind = "register_write",
            name = "neg_updates_rflags",
            target_register = "rflags",
            role = "updated by neg",
        },
    },


    -- 'adc reg, reg' adds with carry into the destination register.
    {
        node_type = "instruction",
        mnemonic = "adc",

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source_register" },
        },

        effect = {
            kind = "register_write",
            name = "adc_register_register",
            target_operand = 1,
            role = "added with carry from register",
        },
    },

    -- 'adc reg, imm' adds an immediate with carry into the destination register.
    {
        node_type = "instruction",
        mnemonic = "adc",

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "integer", role = "source_value" },
        },

        effect = {
            kind = "register_write",
            name = "adc_register_immediate",
            target_operand = 1,
            role = "added with carry from immediate",
        },
    },

    -- 'adc' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "adc",

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },

        effect = {
            kind = "register_write",
            name = "adc_updates_rflags",
            target_register = "rflags",
            role = "updated by adc",
        },
    },

    -- 'sbb reg, reg' subtracts with borrow from the destination register.
    {
        node_type = "instruction",
        mnemonic = "sbb",

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source_register" },
        },

        effect = {
            kind = "register_write",
            name = "sbb_register_register",
            target_operand = 1,
            role = "subtracted with borrow from register",
        },
    },

    -- 'sbb reg, imm' subtracts an immediate with borrow from the destination register.
    {
        node_type = "instruction",
        mnemonic = "sbb",

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "integer", role = "source_value" },
        },

        effect = {
            kind = "register_write",
            name = "sbb_register_immediate",
            target_operand = 1,
            role = "subtracted with borrow from immediate",
        },
    },

    -- 'sbb' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "sbb",

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },

        effect = {
            kind = "register_write",
            name = "sbb_updates_rflags",
            target_register = "rflags",
            role = "updated by sbb",
        },
    },


    -- 'cbw' sign-extends al into ax.
    {
        node_type = "instruction",
        mnemonic = "cbw",

        operands = {},

        effect = {
            kind = "register_write",
            name = "cbw_writes_rax_family",
            target_register = "rax",
            role = "sign-extended al into ax by cbw",
        },
    },

    -- 'cwde' sign-extends ax into eax.
    {
        node_type = "instruction",
        mnemonic = "cwde",

        operands = {},

        effect = {
            kind = "register_write",
            name = "cwde_writes_rax_family",
            target_register = "rax",
            role = "sign-extended ax into eax by cwde",
        },
    },

    -- 'cdqe' sign-extends eax into rax.
    {
        node_type = "instruction",
        mnemonic = "cdqe",

        operands = {},

        effect = {
            kind = "register_write",
            name = "cdqe_writes_rax",
            target_register = "rax",
            role = "sign-extended eax into rax by cdqe",
        },
    },

    -- 'cwd' sign-extends ax into dx:ax.
    {
        node_type = "instruction",
        mnemonic = "cwd",

        operands = {},

        effect = {
            kind = "register_write",
            name = "cwd_writes_rdx_family",
            target_register = "rdx",
            role = "sign-extended ax into dx by cwd",
        },
    },

    -- 'cdq' sign-extends eax into edx:eax.
    {
        node_type = "instruction",
        mnemonic = "cdq",

        operands = {},

        effect = {
            kind = "register_write",
            name = "cdq_writes_rdx_family",
            target_register = "rdx",
            role = "sign-extended eax into edx by cdq",
        },
    },

    -- 'cqo' sign-extends rax into rdx:rax.
    {
        node_type = "instruction",
        mnemonic = "cqo",

        operands = {},

        effect = {
            kind = "register_write",
            name = "cqo_writes_rdx",
            target_register = "rdx",
            role = "sign-extended rax into rdx by cqo",
        },
    },


     -- 'clc' clears the carry flag.
    {
        node_type = "instruction",
        mnemonic = "clc",

        operands = {},

        effect = {
            kind = "register_write",
            name = "clc_updates_rflags",
            target_register = "rflags",
            role = "carry flag cleared by clc",
        },
    },

    -- 'stc' sets the carry flag.
    {
        node_type = "instruction",
        mnemonic = "stc",

        operands = {},

        effect = {
            kind = "register_write",
            name = "stc_updates_rflags",
            target_register = "rflags",
            role = "carry flag set by stc",
        },
    },

    -- 'cmc' complements the carry flag.
    {
        node_type = "instruction",
        mnemonic = "cmc",

        operands = {},

        effect = {
            kind = "register_write",
            name = "cmc_updates_rflags",
            target_register = "rflags",
            role = "carry flag complemented by cmc",
        },
    },

    -- 'cld' clears the direction flag.
    {
        node_type = "instruction",
        mnemonic = "cld",

        operands = {},

        effect = {
            kind = "register_write",
            name = "cld_updates_rflags",
            target_register = "rflags",
            role = "direction flag cleared by cld",
        },
    },

    -- 'std' sets the direction flag.
    {
        node_type = "instruction",
        mnemonic = "std",

        operands = {},

        effect = {
            kind = "register_write",
            name = "std_updates_rflags",
            target_register = "rflags",
            role = "direction flag set by std",
        },
    },

    -- 'lahf' loads status flags into AH.
    {
        node_type = "instruction",
        mnemonic = "lahf",

        operands = {},

        effect = {
            kind = "register_write",
            name = "lahf_writes_rax_family",
            target_register = "rax",
            role = "loaded status flags into ah by lahf",
        },
    },

    -- 'sahf' stores AH into status flags.
    {
        node_type = "instruction",
        mnemonic = "sahf",

        operands = {},

        effect = {
            kind = "register_write",
            name = "sahf_updates_rflags",
            target_register = "rflags",
            role = "loaded status flags from ah by sahf",
        },
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    -- 'pushfq' pushes rflags onto the stack and decreases rsp.
    {
        node_type = "instruction",
        mnemonic = "pushfq",

        operands = {},

        effect = {
            kind = "register_write",
            name = "pushfq_updates_rsp",
            target_register = "rsp",
            value_delta = -8,
            role = "decreased by pushfq",
        },
    },

    -- 'popfq' pops rflags from the stack and increases rsp.
    {
        node_type = "instruction",
        mnemonic = "popfq",

        operands = {},

        effect = {
            kind = "register_write",
            name = "popfq_updates_rsp",
            target_register = "rsp",
            value_delta = 8,
            role = "increased by popfq",
        },
    },

    -- 'popfq' restores rflags from the stack.
    {
        node_type = "instruction",
        mnemonic = "popfq",

        operands = {},

        effect = {
            kind = "register_write",
            name = "popfq_updates_rflags",
            target_register = "rflags",
            role = "restored from stack by popfq",
        },
    },

    -- 'pushf' pushes flags onto the stack and decreases rsp.
    {
        node_type = "instruction",
        mnemonic = "pushf",

        operands = {},

        effect = {
            kind = "register_write",
            name = "pushf_updates_rsp",
            target_register = "rsp",
            value_delta = -8,
            role = "decreased by pushf",
        },
    },

    -- 'popf' pops flags from the stack and increases rsp.
    {
        node_type = "instruction",
        mnemonic = "popf",

        operands = {},

        effect = {
            kind = "register_write",
            name = "popf_updates_rsp",
            target_register = "rsp",
            value_delta = 8,
            role = "increased by popf",
        },
    },

    -- 'popf' restores rflags from the stack.
    {
        node_type = "instruction",
        mnemonic = "popf",

        operands = {},

        effect = {
            kind = "register_write",
            name = "popf_updates_rflags",
            target_register = "rflags",
            role = "restored from stack by popf",
        },
    },


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
    },

    -- 'xadd dest, src' exchanges and adds, mutating the destination.
    {
        node_type = "instruction",
        mnemonic = "xadd",

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },

        effect = {
            kind = "register_write",
            name = "xadd_mutates_destination",
            target_operand = 1,
            role = "exchanged and added by xadd",
        },
    },

    -- 'xadd dest, src' exchanges and adds, also writing the source register.
    {
        node_type = "instruction",
        mnemonic = "xadd",

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },

        effect = {
            kind = "register_write",
            name = "xadd_writes_source",
            target_operand = 2,
            role = "received original destination by xadd",
        },
    },

    -- 'cmpxchg dest, src' conditionally writes the destination.
    {
        node_type = "instruction",
        mnemonic = "cmpxchg",

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },

        effect = {
            kind = "register_write",
            name = "cmpxchg_conditional_destination",
            target_operand = 1,
            role = "conditionally exchanged by cmpxchg",
        },
    },

    -- 'cmpxchg dest, src' can update rax/eax/ax/al on comparison failure.
    {
        node_type = "instruction",
        mnemonic = "cmpxchg",

        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },

        effect = {
            kind = "register_write",
            name = "cmpxchg_updates_accumulator",
            target_register = "rax",
            role = "conditionally updated by cmpxchg comparison",
        },
    },

    -- 'cmpxchg' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "cmpxchg",

        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },

        effect = {
            kind = "register_write",
            name = "cmpxchg_updates_rflags",
            target_register = "rflags",
            role = "updated by cmpxchg",
        },
    },

    -- 'cmpxchg8b' uses eax/edx as comparison input/output.
    {
        node_type = "instruction",
        mnemonic = "cmpxchg8b",

        operands = {
            { index = 1, role = "memory" },
        },

        effect = {
            kind = "register_write",
            name = "cmpxchg8b_updates_rax",
            target_register = "rax",
            role = "updated by cmpxchg8b comparison",
        },
    },

    -- 'cmpxchg8b' uses edx as comparison input/output.
    {
        node_type = "instruction",
        mnemonic = "cmpxchg8b",

        operands = {
            { index = 1, role = "memory" },
        },

        effect = {
            kind = "register_write",
            name = "cmpxchg8b_updates_rdx",
            target_register = "rdx",
            role = "updated by cmpxchg8b comparison",
        },
    },

    -- 'cmpxchg8b' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "cmpxchg8b",

        operands = {
            { index = 1, role = "memory" },
        },

        effect = {
            kind = "register_write",
            name = "cmpxchg8b_updates_rflags",
            target_register = "rflags",
            role = "updated by cmpxchg8b",
        },
    },

    -- 'cmpxchg16b' uses rax as comparison input/output.
    {
        node_type = "instruction",
        mnemonic = "cmpxchg16b",

        operands = {
            { index = 1, role = "memory" },
        },

        effect = {
            kind = "register_write",
            name = "cmpxchg16b_updates_rax",
            target_register = "rax",
            role = "updated by cmpxchg16b comparison",
        },
    },

    -- 'cmpxchg16b' uses rdx as comparison input/output.
    {
        node_type = "instruction",
        mnemonic = "cmpxchg16b",

        operands = {
            { index = 1, role = "memory" },
        },

        effect = {
            kind = "register_write",
            name = "cmpxchg16b_updates_rdx",
            target_register = "rdx",
            role = "updated by cmpxchg16b comparison",
        },
    },

    -- 'cmpxchg16b' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "cmpxchg16b",

        operands = {
            { index = 1, role = "memory" },
        },

        effect = {
            kind = "register_write",
            name = "cmpxchg16b_updates_rflags",
            target_register = "rflags",
            role = "updated by cmpxchg16b",
        },
    },

    -- 'rdtsc' writes the low timestamp bits to eax/rax.
    {
        node_type = "instruction",
        mnemonic = "rdtsc",

        operands = {},

        effect = {
            kind = "register_write",
            name = "rdtsc_writes_rax",
            target_register = "rax",
            role = "written with timestamp low result by rdtsc",
        },
    },

    -- 'rdtsc' writes the high timestamp bits to edx/rdx.
    {
        node_type = "instruction",
        mnemonic = "rdtsc",

        operands = {},

        effect = {
            kind = "register_write",
            name = "rdtsc_writes_rdx",
            target_register = "rdx",
            role = "written with timestamp high result by rdtsc",
        },
    },

    -- 'rdtscp' writes the low timestamp bits to eax/rax.
    {
        node_type = "instruction",
        mnemonic = "rdtscp",

        operands = {},

        effect = {
            kind = "register_write",
            name = "rdtscp_writes_rax",
            target_register = "rax",
            role = "written with timestamp low result by rdtscp",
        },
    },

    -- 'rdtscp' writes the high timestamp bits to edx/rdx.
    {
        node_type = "instruction",
        mnemonic = "rdtscp",

        operands = {},

        effect = {
            kind = "register_write",
            name = "rdtscp_writes_rdx",
            target_register = "rdx",
            role = "written with timestamp high result by rdtscp",
        },
    },

    -- 'rdtscp' writes the processor id/result metadata to ecx/rcx.
    {
        node_type = "instruction",
        mnemonic = "rdtscp",

        operands = {},

        effect = {
            kind = "register_write",
            name = "rdtscp_writes_rcx",
            target_register = "rcx",
            role = "written with processor id by rdtscp",
        },
    },

    -- 'rdrand reg' writes a hardware random value to the destination.
    {
        node_type = "instruction",
        mnemonic = "rdrand",

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },

        effect = {
            kind = "register_write",
            name = "rdrand_register",
            target_operand = 1,
            role = "written with hardware random value by rdrand",
        },
    },

    -- 'rdrand' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "rdrand",

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },

        effect = {
            kind = "register_write",
            name = "rdrand_updates_rflags",
            target_register = "rflags",
            role = "updated by rdrand",
        },
    },

    -- 'rdseed reg' writes a hardware seed value to the destination.
    {
        node_type = "instruction",
        mnemonic = "rdseed",

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },

        effect = {
            kind = "register_write",
            name = "rdseed_register",
            target_operand = 1,
            role = "written with hardware seed value by rdseed",
        },
    },

    -- 'rdseed' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "rdseed",

        operands = {
            { index = 1, kind = "register", role = "destination" },
        },

        effect = {
            kind = "register_write",
            name = "rdseed_updates_rflags",
            target_register = "rflags",
            role = "updated by rdseed",
        },
    },

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
    },

    -- 'in dest, port' writes input-port data to the destination register.
    {
        node_type = "instruction",
        mnemonic = "in",

        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "port" },
        },

        effect = {
            kind = "register_write",
            name = "in_writes_register",
            target_operand = 1,
            role = "written from input port by in",
        },
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    -- 'loop' decrements rcx.
    {
        node_type = "instruction",
        mnemonic = "loop",

        operands = {
            { index = 1, role = "target" },
        },

        effect = {
            kind = "register_write",
            name = "loop_decrements_rcx",
            target_register = "rcx",
            value_delta = -1,
            role = "decremented by loop",
        },
    },

    -- 'loope' decrements rcx.
    {
        node_type = "instruction",
        mnemonic = "loope",

        operands = {
            { index = 1, role = "target" },
        },

        effect = {
            kind = "register_write",
            name = "loope_decrements_rcx",
            target_register = "rcx",
            value_delta = -1,
            role = "decremented by loope",
        },
    },

    -- 'loopz' decrements rcx.
    {
        node_type = "instruction",
        mnemonic = "loopz",

        operands = {
            { index = 1, role = "target" },
        },

        effect = {
            kind = "register_write",
            name = "loopz_decrements_rcx",
            target_register = "rcx",
            value_delta = -1,
            role = "decremented by loopz",
        },
    },

    -- 'loopne' decrements rcx.
    {
        node_type = "instruction",
        mnemonic = "loopne",

        operands = {
            { index = 1, role = "target" },
        },

        effect = {
            kind = "register_write",
            name = "loopne_decrements_rcx",
            target_register = "rcx",
            value_delta = -1,
            role = "decremented by loopne",
        },
    },

    -- 'loopnz' decrements rcx.
    {
        node_type = "instruction",
        mnemonic = "loopnz",

        operands = {
            { index = 1, role = "target" },
        },

        effect = {
            kind = "register_write",
            name = "loopnz_decrements_rcx",
            target_register = "rcx",
            value_delta = -1,
            role = "decremented by loopnz",
        },
    },

    -- 'call target' changes rip.
    {
        node_type = "instruction",
        mnemonic = "call",

        operands = {
            { index = 1, role = "target" },
        },

        effect = {
            kind = "register_write",
            name = "call_updates_rip",
            target_register = "rip",
            role = "changed by call",
        },
    },

    -- 'ret' changes rip.
    {
        node_type = "instruction",
        mnemonic = "ret",

        operands = {},

        effect = {
            kind = "register_write",
            name = "ret_updates_rip",
            target_register = "rip",
            role = "restored from return address by ret",
        },
    },

    -- 'jmp target' changes rip.
    {
        node_type = "instruction",
        mnemonic = "jmp",

        operands = {
            { index = 1, role = "target" },
        },

        effect = {
            kind = "register_write",
            name = "jmp_updates_rip",
            target_register = "rip",
            role = "changed by jmp",
        },
    },


    -- 'nop' intentionally performs no operation.
    {
        node_type = "instruction",
        mnemonic = "nop",
        operands = {},

        effect = {
            kind = "register_write",
            name = "nop_no_operation",
            target_register = "rip",
            role = "advanced by nop",
        },
    },

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
    },


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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },


    -- 'int imm' transfers control to a software interrupt handler.
    {
        node_type = "instruction",
        mnemonic = "int",

        operands = {
            {
                index = 1,
                role = "interrupt_vector",
            },
        },

        effect = {
            kind = "register_write",
            name = "int_updates_rip",
            target_register = "rip",
            role = "software interrupt transfer by int",
        },
    },

    -- 'int3' transfers control to the breakpoint interrupt handler.
    {
        node_type = "instruction",
        mnemonic = "int3",
        operands = {},

        effect = {
            kind = "register_write",
            name = "int3_updates_rip",
            target_register = "rip",
            role = "breakpoint interrupt by int3",
        },
    },

    -- 'into' transfers control on overflow.
    {
        node_type = "instruction",
        mnemonic = "into",
        operands = {},

        effect = {
            kind = "register_write",
            name = "into_updates_rip",
            target_register = "rip",
            role = "overflow interrupt by into",
        },
    },

    -- 'iret' returns from an interrupt.
    {
        node_type = "instruction",
        mnemonic = "iret",
        operands = {},

        effect = {
            kind = "register_write",
            name = "iret_updates_rip",
            target_register = "rip",
            role = "returned from interrupt by iret",
        },
    },

    -- 'iretq' returns from a 64-bit interrupt.
    {
        node_type = "instruction",
        mnemonic = "iretq",
        operands = {},

        effect = {
            kind = "register_write",
            name = "iretq_updates_rip",
            target_register = "rip",
            role = "returned from interrupt by iretq",
        },
    },

    -- 'sysenter' enters a fast system-call handler.
    {
        node_type = "instruction",
        mnemonic = "sysenter",
        operands = {},

        effect = {
            kind = "register_write",
            name = "sysenter_updates_rip",
            target_register = "rip",
            role = "entered system call by sysenter",
        },
    },

    -- 'sysexit' returns from a fast system-call handler.
    {
        node_type = "instruction",
        mnemonic = "sysexit",
        operands = {},

        effect = {
            kind = "register_write",
            name = "sysexit_updates_rip",
            target_register = "rip",
            role = "returned from system call by sysexit",
        },
    },

    -- 'sysret' returns from a system call.
    {
        node_type = "instruction",
        mnemonic = "sysret",
        operands = {},

        effect = {
            kind = "register_write",
            name = "sysret_updates_rip",
            target_register = "rip",
            role = "returned from system call by sysret",
        },
    },

    -- 'sysretq' returns from a 64-bit system call.
    {
        node_type = "instruction",
        mnemonic = "sysretq",
        operands = {},

        effect = {
            kind = "register_write",
            name = "sysretq_updates_rip",
            target_register = "rip",
            role = "returned from system call by sysretq",
        },
    },

    -- 'ud2' raises an invalid-instruction exception.
    {
        node_type = "instruction",
        mnemonic = "ud2",
        operands = {},

        effect = {
            kind = "register_write",
            name = "ud2_updates_rip",
            target_register = "rip",
            role = "invalid instruction trap by ud2",
        },
    },

    -- 'hlt' halts the processor until an external event.
    {
        node_type = "instruction",
        mnemonic = "hlt",
        operands = {},

        effect = {
            kind = "register_write",
            name = "hlt_updates_rip",
            target_register = "rip",
            role = "halted by hlt",
        },
    },

    -- 'pause' is a spin-wait hint.
    {
        node_type = "instruction",
        mnemonic = "pause",
        operands = {},

        effect = {
            kind = "register_write",
            name = "pause_updates_rip",
            target_register = "rip",
            role = "spin-wait hint by pause",
        },
    },

    -- 'wait' waits for the floating-point unit.
    {
        node_type = "instruction",
        mnemonic = "wait",
        operands = {},

        effect = {
            kind = "register_write",
            name = "wait_updates_rip",
            target_register = "rip",
            role = "waited for floating-point unit by wait",
        },
    },

    -- 'fwait' waits for the floating-point unit.
    {
        node_type = "instruction",
        mnemonic = "fwait",
        operands = {},

        effect = {
            kind = "register_write",
            name = "fwait_updates_rip",
            target_register = "rip",
            role = "waited for floating-point unit by fwait",
        },
    },

    -- 'cli' clears the interrupt flag.
    {
        node_type = "instruction",
        mnemonic = "cli",
        operands = {},

        effect = {
            kind = "register_write",
            name = "cli_updates_rflags",
            target_register = "rflags",
            role = "interrupt flag cleared by cli",
        },
    },

    -- 'sti' sets the interrupt flag.
    {
        node_type = "instruction",
        mnemonic = "sti",
        operands = {},

        effect = {
            kind = "register_write",
            name = "sti_updates_rflags",
            target_register = "rflags",
            role = "interrupt flag set by sti",
        },
    },

    -- 'cld' clears the direction flag.
    {
        node_type = "instruction",
        mnemonic = "cld",
        operands = {},

        effect = {
            kind = "register_write",
            name = "cld_updates_rflags",
            target_register = "rflags",
            role = "direction flag cleared by cld",
        },
    },

    -- 'std' sets the direction flag.
    {
        node_type = "instruction",
        mnemonic = "std",
        operands = {},

        effect = {
            kind = "register_write",
            name = "std_updates_rflags",
            target_register = "rflags",
            role = "direction flag set by std",
        },
    },

    -- 'clac' clears the alignment-check/access-control flag.
    {
        node_type = "instruction",
        mnemonic = "clac",
        operands = {},

        effect = {
            kind = "register_write",
            name = "clac_updates_rflags",
            target_register = "rflags",
            role = "access-control flag cleared by clac",
        },
    },

    -- 'stac' sets the alignment-check/access-control flag.
    {
        node_type = "instruction",
        mnemonic = "stac",
        operands = {},

        effect = {
            kind = "register_write",
            name = "stac_updates_rflags",
            target_register = "rflags",
            role = "access-control flag set by stac",
        },
    },


    -- Conditional jump effects.
    {
        node_type = "instruction",
        mnemonic = "ja",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "ja_updates_rip",
            target_register = "rip",
            role = "conditional jump above by ja",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jae",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jae_updates_rip",
            target_register = "rip",
            role = "conditional jump above-or-equal by jae",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jb",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jb_updates_rip",
            target_register = "rip",
            role = "conditional jump below by jb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jbe",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jbe_updates_rip",
            target_register = "rip",
            role = "conditional jump below-or-equal by jbe",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jc",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jc_updates_rip",
            target_register = "rip",
            role = "conditional jump on carry by jc",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnc",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jnc_updates_rip",
            target_register = "rip",
            role = "conditional jump on not-carry by jnc",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "je",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "je_updates_rip",
            target_register = "rip",
            role = "conditional jump equal by je",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jne",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jne_updates_rip",
            target_register = "rip",
            role = "conditional jump not-equal by jne",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jz",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jz_updates_rip",
            target_register = "rip",
            role = "conditional jump zero by jz",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnz",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jnz_updates_rip",
            target_register = "rip",
            role = "conditional jump not-zero by jnz",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jg",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jg_updates_rip",
            target_register = "rip",
            role = "conditional jump greater-than by jg",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jge",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jge_updates_rip",
            target_register = "rip",
            role = "conditional jump greater-or-equal by jge",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jl",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jl_updates_rip",
            target_register = "rip",
            role = "conditional jump less-than by jl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jle",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jle_updates_rip",
            target_register = "rip",
            role = "conditional jump less-or-equal by jle",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jo",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jo_updates_rip",
            target_register = "rip",
            role = "conditional jump on overflow by jo",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jno",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jno_updates_rip",
            target_register = "rip",
            role = "conditional jump on not-overflow by jno",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "js",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "js_updates_rip",
            target_register = "rip",
            role = "conditional jump on sign by js",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jns",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jns_updates_rip",
            target_register = "rip",
            role = "conditional jump on not-sign by jns",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jp",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jp_updates_rip",
            target_register = "rip",
            role = "conditional jump on parity by jp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnp",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jnp_updates_rip",
            target_register = "rip",
            role = "conditional jump on not-parity by jnp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jcxz",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jcxz_updates_rip",
            target_register = "rip",
            role = "conditional jump if cx is zero by jcxz",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jecxz",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jecxz_updates_rip",
            target_register = "rip",
            role = "conditional jump if ecx is zero by jecxz",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jrcxz",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jrcxz_updates_rip",
            target_register = "rip",
            role = "conditional jump if rcx is zero by jrcxz",
        },
    },


    -- Conditional jump alias effects.
    {
        node_type = "instruction",
        mnemonic = "jna",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jna_updates_rip",
            target_register = "rip",
            role = "conditional jump not-above by jna",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnae",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jnae_updates_rip",
            target_register = "rip",
            role = "conditional jump not-above-or-equal by jnae",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnb",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jnb_updates_rip",
            target_register = "rip",
            role = "conditional jump not-below by jnb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnbe",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jnbe_updates_rip",
            target_register = "rip",
            role = "conditional jump not-below-or-equal by jnbe",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnge",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jnge_updates_rip",
            target_register = "rip",
            role = "conditional jump not-greater-or-equal by jnge",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jng",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jng_updates_rip",
            target_register = "rip",
            role = "conditional jump not-greater by jng",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnl",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jnl_updates_rip",
            target_register = "rip",
            role = "conditional jump not-less by jnl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnle",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jnle_updates_rip",
            target_register = "rip",
            role = "conditional jump not-less-or-equal by jnle",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jpe",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jpe_updates_rip",
            target_register = "rip",
            role = "conditional jump parity-even by jpe",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jpo",
        operands = { { index = 1, role = "jump_target" } },
        effect = {
            kind = "register_write",
            name = "jpo_updates_rip",
            target_register = "rip",
            role = "conditional jump parity-odd by jpo",
        },
    },

    -- 'loope target' decrements rcx and conditionally branches.
    {
        node_type = "instruction",
        mnemonic = "loope",
        operands = {
            { index = 1, role = "jump_target" },
        },
        effect = {
            kind = "register_write",
            name = "loope_decrements_rcx",
            target_register = "rcx",
            value_delta = -1,
            role = "decremented by loope",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "loope",
        operands = {
            { index = 1, role = "jump_target" },
        },
        effect = {
            kind = "register_write",
            name = "loope_updates_rip",
            target_register = "rip",
            role = "conditional loop branch by loope",
        },
    },

    -- 'loopz target' is an alias form of loope.
    {
        node_type = "instruction",
        mnemonic = "loopz",
        operands = {
            { index = 1, role = "jump_target" },
        },
        effect = {
            kind = "register_write",
            name = "loopz_decrements_rcx",
            target_register = "rcx",
            value_delta = -1,
            role = "decremented by loopz",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "loopz",
        operands = {
            { index = 1, role = "jump_target" },
        },
        effect = {
            kind = "register_write",
            name = "loopz_updates_rip",
            target_register = "rip",
            role = "conditional loop branch by loopz",
        },
    },

    -- 'loopne target' decrements rcx and conditionally branches.
    {
        node_type = "instruction",
        mnemonic = "loopne",
        operands = {
            { index = 1, role = "jump_target" },
        },
        effect = {
            kind = "register_write",
            name = "loopne_decrements_rcx",
            target_register = "rcx",
            value_delta = -1,
            role = "decremented by loopne",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "loopne",
        operands = {
            { index = 1, role = "jump_target" },
        },
        effect = {
            kind = "register_write",
            name = "loopne_updates_rip",
            target_register = "rip",
            role = "conditional loop branch by loopne",
        },
    },

    -- 'loopnz target' is an alias form of loopne.
    {
        node_type = "instruction",
        mnemonic = "loopnz",
        operands = {
            { index = 1, role = "jump_target" },
        },
        effect = {
            kind = "register_write",
            name = "loopnz_decrements_rcx",
            target_register = "rcx",
            value_delta = -1,
            role = "decremented by loopnz",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "loopnz",
        operands = {
            { index = 1, role = "jump_target" },
        },
        effect = {
            kind = "register_write",
            name = "loopnz_updates_rip",
            target_register = "rip",
            role = "conditional loop branch by loopnz",
        },
    },

    -- 'jrcxz target' conditionally branches when rcx is zero.
    {
        node_type = "instruction",
        mnemonic = "jrcxz",
        operands = {
            { index = 1, role = "jump_target" },
        },
        effect = {
            kind = "register_write",
            name = "jrcxz_updates_rip",
            target_register = "rip",
            role = "conditional jump if rcx zero by jrcxz",
        },
    },

    -- 'jecxz target' conditionally branches when ecx is zero.
    {
        node_type = "instruction",
        mnemonic = "jecxz",
        operands = {
            { index = 1, role = "jump_target" },
        },
        effect = {
            kind = "register_write",
            name = "jecxz_updates_rip",
            target_register = "rip",
            role = "conditional jump if ecx zero by jecxz",
        },
    },

    -- 'jcxz target' conditionally branches when cx is zero.
    {
        node_type = "instruction",
        mnemonic = "jcxz",
        operands = {
            { index = 1, role = "jump_target" },
        },
        effect = {
            kind = "register_write",
            name = "jcxz_updates_rip",
            target_register = "rip",
            role = "conditional jump if cx zero by jcxz",
        },
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    -- 'popcnt reg, value' writes the population count to the destination register.
    {
        node_type = "instruction",
        mnemonic = "popcnt",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "popcnt_writes_destination",
            target_operand = 1,
            role = "written with population count by popcnt",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "popcnt",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "popcnt_updates_rflags",
            target_register = "rflags",
            role = "updated by popcnt",
        },
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    -- 'imul reg, source' writes the signed multiply result to the destination register.
    {
        node_type = "instruction",
        mnemonic = "imul",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "imul_two_operand_writes_destination",
            target_operand = 1,
            role = "written with signed multiply result by imul",
        },
    },

    -- 'imul reg, source, imm' writes the signed multiply result to the destination register.
    {
        node_type = "instruction",
        mnemonic = "imul",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "multiplier" },
        },
        effect = {
            kind = "register_write",
            name = "imul_three_operand_writes_destination",
            target_operand = 1,
            role = "written with signed multiply result by imul",
        },
    },

    -- 'imul' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "imul",
        operands = {
            { index = 1, role = "destination_or_source" },
        },
        effect = {
            kind = "register_write",
            name = "imul_updates_rflags",
            target_register = "rflags",
            role = "updated by imul",
        },
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    -- REP-family prefixes. These are modeled as rcx-consuming repeat controls.
    {
        node_type = "instruction",
        mnemonic = "rep",
        operands = {},
        effect = {
            kind = "register_write",
            name = "rep_consumes_rcx",
            target_register = "rcx",
            role = "used as repeat count by rep",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "repe",
        operands = {},
        effect = {
            kind = "register_write",
            name = "repe_consumes_rcx",
            target_register = "rcx",
            role = "used as repeat count by repe",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "repz",
        operands = {},
        effect = {
            kind = "register_write",
            name = "repz_consumes_rcx",
            target_register = "rcx",
            role = "used as repeat count by repz",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "repne",
        operands = {},
        effect = {
            kind = "register_write",
            name = "repne_consumes_rcx",
            target_register = "rcx",
            role = "used as repeat count by repne",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "repnz",
        operands = {},
        effect = {
            kind = "register_write",
            name = "repnz_consumes_rcx",
            target_register = "rcx",
            role = "used as repeat count by repnz",
        },
    },

    -- Descriptor / protection helper instructions.
    {
        node_type = "instruction",
        mnemonic = "lar",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "lar_writes_destination",
            target_operand = 1,
            role = "written with access rights by lar",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lar",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "lar_updates_rflags",
            target_register = "rflags",
            role = "updated by lar",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lsl",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "lsl_writes_destination",
            target_operand = 1,
            role = "written with segment limit by lsl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lsl",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "lsl_updates_rflags",
            target_register = "rflags",
            role = "updated by lsl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "verr",
        operands = {
            { index = 1, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "verr_updates_rflags",
            target_register = "rflags",
            role = "updated by readable-segment test verr",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "verw",
        operands = {
            { index = 1, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "verw_updates_rflags",
            target_register = "rflags",
            role = "updated by writable-segment test verw",
        },
    },

    -- Model/control read instructions that write general-purpose result registers.
    {
        node_type = "instruction",
        mnemonic = "rdmsr",
        operands = {},
        effect = {
            kind = "register_write",
            name = "rdmsr_writes_rax",
            target_register = "rax",
            role = "written with model-specific register low bits by rdmsr",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rdmsr",
        operands = {},
        effect = {
            kind = "register_write",
            name = "rdmsr_writes_rdx",
            target_register = "rdx",
            role = "written with model-specific register high bits by rdmsr",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rdpmc",
        operands = {},
        effect = {
            kind = "register_write",
            name = "rdpmc_writes_rax",
            target_register = "rax",
            role = "written with performance counter low bits by rdpmc",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rdpmc",
        operands = {},
        effect = {
            kind = "register_write",
            name = "rdpmc_writes_rdx",
            target_register = "rdx",
            role = "written with performance counter high bits by rdpmc",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xgetbv",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xgetbv_writes_rax",
            target_register = "rax",
            role = "written with extended control register low bits by xgetbv",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xgetbv",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xgetbv_writes_rdx",
            target_register = "rdx",
            role = "written with extended control register high bits by xgetbv",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rdpkru",
        operands = {},
        effect = {
            kind = "register_write",
            name = "rdpkru_writes_rax",
            target_register = "rax",
            role = "written with protection-key rights by rdpkru",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rdpkru",
        operands = {},
        effect = {
            kind = "register_write",
            name = "rdpkru_writes_rdx",
            target_register = "rdx",
            role = "cleared high result by rdpkru",
        },
    },

    -- Frame/control-transfer helpers.
    {
        node_type = "instruction",
        mnemonic = "enter",
        operands = {
            { index = 1, role = "frame_size" },
            { index = 2, role = "nesting_level" },
        },
        effect = {
            kind = "register_write",
            name = "enter_updates_rsp",
            target_register = "rsp",
            role = "changed by stack frame entry enter",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "enter",
        operands = {
            { index = 1, role = "frame_size" },
            { index = 2, role = "nesting_level" },
        },
        effect = {
            kind = "register_write",
            name = "enter_updates_rbp",
            target_register = "rbp",
            role = "established frame base by enter",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "leave",
        operands = {},
        effect = {
            kind = "register_write",
            name = "leave_updates_rsp",
            target_register = "rsp",
            role = "restored stack pointer by leave",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "leave",
        operands = {},
        effect = {
            kind = "register_write",
            name = "leave_updates_rbp",
            target_register = "rbp",
            role = "restored frame base by leave",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "retf",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retf_updates_rip",
            target_register = "rip",
            role = "far return changed instruction pointer by retf",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "retf",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retf_updates_rsp",
            target_register = "rsp",
            role = "far return adjusted stack pointer by retf",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lret",
        operands = {},
        effect = {
            kind = "register_write",
            name = "lret_updates_rip",
            target_register = "rip",
            role = "far return changed instruction pointer by lret",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lret",
        operands = {},
        effect = {
            kind = "register_write",
            name = "lret_updates_rsp",
            target_register = "rsp",
            role = "far return adjusted stack pointer by lret",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "iretw",
        operands = {},
        effect = {
            kind = "register_write",
            name = "iretw_updates_rip",
            target_register = "rip",
            role = "returned from interrupt by iretw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "iretd",
        operands = {},
        effect = {
            kind = "register_write",
            name = "iretd_updates_rip",
            target_register = "rip",
            role = "returned from interrupt by iretd",
        },
    },

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
    },

    -- 'adcx reg, source' adds with carry and writes destination.
    {
        node_type = "instruction",
        mnemonic = "adcx",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "adcx_writes_destination",
            target_operand = 1,
            role = "added with carry by adcx",
        },
    },

    -- 'adcx' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "adcx",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "adcx_updates_rflags",
            target_register = "rflags",
            role = "updated by adcx",
        },
    },

    -- 'adox reg, source' adds with overflow and writes destination.
    {
        node_type = "instruction",
        mnemonic = "adox",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "adox_writes_destination",
            target_operand = 1,
            role = "added with overflow by adox",
        },
    },

    -- 'adox' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "adox",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "adox_updates_rflags",
            target_register = "rflags",
            role = "updated by adox",
        },
    },

    -- 'mulx reg, reg, source' writes low-result destination.
    {
        node_type = "instruction",
        mnemonic = "mulx",
        operands = {
            { index = 1, kind = "register", role = "low_destination" },
            { index = 2, kind = "register", role = "high_destination" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "mulx_writes_low_destination",
            target_operand = 1,
            role = "written with unsigned multiply low result by mulx",
        },
    },

    -- 'mulx reg, reg, source' writes high-result destination.
    {
        node_type = "instruction",
        mnemonic = "mulx",
        operands = {
            { index = 1, kind = "register", role = "low_destination" },
            { index = 2, kind = "register", role = "high_destination" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "mulx_writes_high_destination",
            target_operand = 2,
            role = "written with unsigned multiply high result by mulx",
        },
    },

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
    },

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
    },

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
    },

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
    },

    -- 'xbegin target' conditionally transfers control and may write rax on abort.
    {
        node_type = "instruction",
        mnemonic = "xbegin",
        operands = {
            { index = 1, role = "abort_target" },
        },
        effect = {
            kind = "register_write",
            name = "xbegin_updates_rip",
            target_register = "rip",
            role = "transactional branch started by xbegin",
        },
    },

    -- 'xbegin' may write abort status to eax/rax.
    {
        node_type = "instruction",
        mnemonic = "xbegin",
        operands = {
            { index = 1, role = "abort_target" },
        },
        effect = {
            kind = "register_write",
            name = "xbegin_may_write_rax",
            target_register = "rax",
            written_alias = "eax",
            role = "may receive transaction abort status by xbegin",
        },
    },

    -- 'xend' ends a transactional region.
    {
        node_type = "instruction",
        mnemonic = "xend",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xend_updates_rip",
            target_register = "rip",
            role = "ended transactional region by xend",
        },
    },

    -- 'xtest' updates flags according to transactional state.
    {
        node_type = "instruction",
        mnemonic = "xtest",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xtest_updates_rflags",
            target_register = "rflags",
            role = "updated by transactional state test xtest",
        },
    },

    -- 'xabort imm' aborts a transactional region and transfers control.
    {
        node_type = "instruction",
        mnemonic = "xabort",
        operands = {
            { index = 1, role = "abort_code" },
        },
        effect = {
            kind = "register_write",
            name = "xabort_updates_rip",
            target_register = "rip",
            role = "transaction aborted by xabort",
        },
    },

    -- Memory ordering fences.
    {
        node_type = "instruction",
        mnemonic = "lfence",
        operands = {},
        effect = {
            kind = "register_write",
            name = "lfence_orders_memory",
            target_register = "rip",
            role = "passed load fence by lfence",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sfence",
        operands = {},
        effect = {
            kind = "register_write",
            name = "sfence_orders_memory",
            target_register = "rip",
            role = "passed store fence by sfence",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "mfence",
        operands = {},
        effect = {
            kind = "register_write",
            name = "mfence_orders_memory",
            target_register = "rip",
            role = "passed memory fence by mfence",
        },
    },

    -- Cache-line maintenance instructions.
    {
        node_type = "instruction",
        mnemonic = "clflush",
        operands = {
            { index = 1, role = "memory_operand" },
        },
        effect = {
            kind = "register_write",
            name = "clflush_touches_cache",
            target_register = "rip",
            role = "flushed cache line by clflush",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "clflushopt",
        operands = {
            { index = 1, role = "memory_operand" },
        },
        effect = {
            kind = "register_write",
            name = "clflushopt_touches_cache",
            target_register = "rip",
            role = "flushed cache line by clflushopt",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "clwb",
        operands = {
            { index = 1, role = "memory_operand" },
        },
        effect = {
            kind = "register_write",
            name = "clwb_touches_cache",
            target_register = "rip",
            role = "wrote back cache line by clwb",
        },
    },

    -- Prefetch hints.
    {
        node_type = "instruction",
        mnemonic = "prefetch",
        operands = {
            { index = 1, role = "memory_operand" },
        },
        effect = {
            kind = "register_write",
            name = "prefetch_touches_memory",
            target_register = "rip",
            role = "prefetched memory by prefetch",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "prefetcht0",
        operands = {
            { index = 1, role = "memory_operand" },
        },
        effect = {
            kind = "register_write",
            name = "prefetcht0_touches_memory",
            target_register = "rip",
            role = "prefetched memory into t0 cache by prefetcht0",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "prefetcht1",
        operands = {
            { index = 1, role = "memory_operand" },
        },
        effect = {
            kind = "register_write",
            name = "prefetcht1_touches_memory",
            target_register = "rip",
            role = "prefetched memory into t1 cache by prefetcht1",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "prefetcht2",
        operands = {
            { index = 1, role = "memory_operand" },
        },
        effect = {
            kind = "register_write",
            name = "prefetcht2_touches_memory",
            target_register = "rip",
            role = "prefetched memory into t2 cache by prefetcht2",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "prefetchnta",
        operands = {
            { index = 1, role = "memory_operand" },
        },
        effect = {
            kind = "register_write",
            name = "prefetchnta_touches_memory",
            target_register = "rip",
            role = "prefetched non-temporal memory by prefetchnta",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "prefetchw",
        operands = {
            { index = 1, role = "memory_operand" },
        },
        effect = {
            kind = "register_write",
            name = "prefetchw_touches_memory",
            target_register = "rip",
            role = "prefetched memory for write by prefetchw",
        },
    },

    -- Monitor / wait hints.
    {
        node_type = "instruction",
        mnemonic = "monitor",
        operands = {},
        effect = {
            kind = "register_write",
            name = "monitor_uses_address_registers",
            target_register = "rip",
            role = "armed monitored address by monitor",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "mwait",
        operands = {},
        effect = {
            kind = "register_write",
            name = "mwait_waits_for_monitor",
            target_register = "rip",
            role = "waited for monitored event by mwait",
        },
    },

    -- TLB/cache/system-memory maintenance.
    {
        node_type = "instruction",
        mnemonic = "invlpg",
        operands = {
            { index = 1, role = "memory_operand" },
        },
        effect = {
            kind = "register_write",
            name = "invlpg_invalidates_translation",
            target_register = "rip",
            role = "invalidated page translation by invlpg",
        },
    },

    -- Descriptor table reads / selector reads.
    {
        node_type = "instruction",
        mnemonic = "sldt",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "sldt_writes_destination",
            target_operand = 1,
            role = "written with local descriptor table selector by sldt",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "str",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "str_writes_destination",
            target_operand = 1,
            role = "written with task register selector by str",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "smsw",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "smsw_writes_destination",
            target_operand = 1,
            role = "written with machine status word by smsw",
        },
    },

    -- Memory destination forms are represented as visible RIP-side effects for now.
    {
        node_type = "instruction",
        mnemonic = "sgdt",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "sgdt_stores_descriptor_table",
            target_register = "rip",
            role = "stored global descriptor table register by sgdt",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sidt",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "sidt_stores_descriptor_table",
            target_register = "rip",
            role = "stored interrupt descriptor table register by sidt",
        },
    },

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
    },

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
    },

    -- ASCII/decimal adjust instructions. Legacy, but useful to recognize.
    {
        node_type = "instruction",
        mnemonic = "aaa",
        operands = {},
        effect = {
            kind = "register_write",
            name = "aaa_updates_rax",
            target_register = "rax",
            written_alias = "ax",
            role = "adjusted ascii addition result by aaa",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aaa",
        operands = {},
        effect = {
            kind = "register_write",
            name = "aaa_updates_rflags",
            target_register = "rflags",
            role = "updated by aaa",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aas",
        operands = {},
        effect = {
            kind = "register_write",
            name = "aas_updates_rax",
            target_register = "rax",
            written_alias = "ax",
            role = "adjusted ascii subtraction result by aas",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aas",
        operands = {},
        effect = {
            kind = "register_write",
            name = "aas_updates_rflags",
            target_register = "rflags",
            role = "updated by aas",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aam",
        operands = {},
        effect = {
            kind = "register_write",
            name = "aam_updates_rax",
            target_register = "rax",
            written_alias = "ax",
            role = "adjusted ascii multiply result by aam",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aam",
        operands = {},
        effect = {
            kind = "register_write",
            name = "aam_updates_rflags",
            target_register = "rflags",
            role = "updated by aam",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aad",
        operands = {},
        effect = {
            kind = "register_write",
            name = "aad_updates_rax",
            target_register = "rax",
            written_alias = "ax",
            role = "adjusted ascii division result by aad",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aad",
        operands = {},
        effect = {
            kind = "register_write",
            name = "aad_updates_rflags",
            target_register = "rflags",
            role = "updated by aad",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "daa",
        operands = {},
        effect = {
            kind = "register_write",
            name = "daa_updates_rax",
            target_register = "rax",
            written_alias = "al",
            role = "decimal-adjusted al after addition by daa",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "daa",
        operands = {},
        effect = {
            kind = "register_write",
            name = "daa_updates_rflags",
            target_register = "rflags",
            role = "updated by daa",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "das",
        operands = {},
        effect = {
            kind = "register_write",
            name = "das_updates_rax",
            target_register = "rax",
            written_alias = "al",
            role = "decimal-adjusted al after subtraction by das",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "das",
        operands = {},
        effect = {
            kind = "register_write",
            name = "das_updates_rflags",
            target_register = "rflags",
            role = "updated by das",
        },
    },

    -- BCD / flag stack helpers.
    {
        node_type = "instruction",
        mnemonic = "sahf",
        operands = {},
        effect = {
            kind = "register_write",
            name = "sahf_updates_rflags_alias",
            target_register = "rflags",
            role = "loaded status flags from ah by sahf",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lahf",
        operands = {},
        effect = {
            kind = "register_write",
            name = "lahf_writes_rax_alias",
            target_register = "rax",
            written_alias = "ah",
            role = "loaded status flags into ah by lahf",
        },
    },

    -- Far calls/jumps. Modeled as RIP-visible control transfers.
    {
        node_type = "instruction",
        mnemonic = "callf",
        operands = {
            { index = 1, role = "far_target" },
        },
        effect = {
            kind = "register_write",
            name = "callf_updates_rip",
            target_register = "rip",
            role = "far call changed instruction pointer by callf",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "callf",
        operands = {
            { index = 1, role = "far_target" },
        },
        effect = {
            kind = "register_write",
            name = "callf_updates_rsp",
            target_register = "rsp",
            role = "far call adjusted stack pointer by callf",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "ljmp",
        operands = {
            { index = 1, role = "far_target" },
        },
        effect = {
            kind = "register_write",
            name = "ljmp_updates_rip",
            target_register = "rip",
            role = "far jump changed instruction pointer by ljmp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jmpf",
        operands = {
            { index = 1, role = "far_target" },
        },
        effect = {
            kind = "register_write",
            name = "jmpf_updates_rip",
            target_register = "rip",
            role = "far jump changed instruction pointer by jmpf",
        },
    },

    -- Segment/base helpers.
    {
        node_type = "instruction",
        mnemonic = "rdfsbase",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdfsbase_writes_destination",
            target_operand = 1,
            role = "written with fs base by rdfsbase",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rdgsbase",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdgsbase_writes_destination",
            target_operand = 1,
            role = "written with gs base by rdgsbase",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "wrfsbase",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "wrfsbase_updates_system_state",
            target_register = "rip",
            role = "wrote fs base by wrfsbase",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "wrgsbase",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "wrgsbase_updates_system_state",
            target_register = "rip",
            role = "wrote gs base by wrgsbase",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "swapgs",
        operands = {},
        effect = {
            kind = "register_write",
            name = "swapgs_updates_system_state",
            target_register = "rip",
            role = "swapped gs base by swapgs",
        },
    },

    -- Model/control writes.
    {
        node_type = "instruction",
        mnemonic = "wrmsr",
        operands = {},
        effect = {
            kind = "register_write",
            name = "wrmsr_updates_system_state",
            target_register = "rip",
            role = "wrote model-specific register by wrmsr",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xsetbv",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xsetbv_updates_system_state",
            target_register = "rip",
            role = "wrote extended control register by xsetbv",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "wrpkru",
        operands = {},
        effect = {
            kind = "register_write",
            name = "wrpkru_updates_system_state",
            target_register = "rip",
            role = "wrote protection-key rights by wrpkru",
        },
    },

    -- Descriptor / control table writers.
    {
        node_type = "instruction",
        mnemonic = "lgdt",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "lgdt_updates_system_state",
            target_register = "rip",
            role = "loaded global descriptor table register by lgdt",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lidt",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "lidt_updates_system_state",
            target_register = "rip",
            role = "loaded interrupt descriptor table register by lidt",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lldt",
        operands = {
            { index = 1, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "lldt_updates_system_state",
            target_register = "rip",
            role = "loaded local descriptor table register by lldt",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "ltr",
        operands = {
            { index = 1, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "ltr_updates_system_state",
            target_register = "rip",
            role = "loaded task register by ltr",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lmsw",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "lmsw_updates_system_state",
            target_register = "rip",
            role = "loaded machine status word by lmsw",
        },
    },

    -- Invalidation / serialization / privilege-state helpers.
    {
        node_type = "instruction",
        mnemonic = "invd",
        operands = {},
        effect = {
            kind = "register_write",
            name = "invd_invalidates_cache",
            target_register = "rip",
            role = "invalidated internal caches by invd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "wbinvd",
        operands = {},
        effect = {
            kind = "register_write",
            name = "wbinvd_writes_back_cache",
            target_register = "rip",
            role = "wrote back and invalidated caches by wbinvd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "serialize",
        operands = {},
        effect = {
            kind = "register_write",
            name = "serialize_serializes_execution",
            target_register = "rip",
            role = "serialized instruction execution by serialize",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cpuid",
        operands = {},
        effect = {
            kind = "register_write",
            name = "cpuid_serializes_execution",
            target_register = "rip",
            role = "serialized instruction execution by cpuid",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rsm",
        operands = {},
        effect = {
            kind = "register_write",
            name = "rsm_updates_rip",
            target_register = "rip",
            role = "resumed from system management mode by rsm",
        },
    },

    -- VMX/SVM virtualization instructions. Modeled as system-state/RFLAGS visibility.
    {
        node_type = "instruction",
        mnemonic = "vmcall",
        operands = {},
        effect = {
            kind = "register_write",
            name = "vmcall_updates_rip",
            target_register = "rip",
            role = "virtual machine call by vmcall",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmlaunch",
        operands = {},
        effect = {
            kind = "register_write",
            name = "vmlaunch_updates_rip",
            target_register = "rip",
            role = "launched virtual machine by vmlaunch",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmresume",
        operands = {},
        effect = {
            kind = "register_write",
            name = "vmresume_updates_rip",
            target_register = "rip",
            role = "resumed virtual machine by vmresume",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmxoff",
        operands = {},
        effect = {
            kind = "register_write",
            name = "vmxoff_updates_system_state",
            target_register = "rip",
            role = "left vmx operation by vmxoff",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmxon",
        operands = {
            { index = 1, role = "vmxon_region" },
        },
        effect = {
            kind = "register_write",
            name = "vmxon_updates_system_state",
            target_register = "rip",
            role = "entered vmx operation by vmxon",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmclear",
        operands = {
            { index = 1, role = "vmcs_region" },
        },
        effect = {
            kind = "register_write",
            name = "vmclear_updates_rflags",
            target_register = "rflags",
            role = "updated by vmclear",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmptrld",
        operands = {
            { index = 1, role = "vmcs_region" },
        },
        effect = {
            kind = "register_write",
            name = "vmptrld_updates_rflags",
            target_register = "rflags",
            role = "updated by vmptrld",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmptrst",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "vmptrst_updates_system_state",
            target_register = "rip",
            role = "stored current vmcs pointer by vmptrst",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmread",
        operands = {
            { index = 1, role = "field" },
            { index = 2, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "vmread_writes_destination",
            target_operand = 2,
            role = "written with vmcs field by vmread",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmread",
        operands = {
            { index = 1, role = "field" },
            { index = 2, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "vmread_updates_rflags",
            target_register = "rflags",
            role = "updated by vmread",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmwrite",
        operands = {
            { index = 1, role = "source" },
            { index = 2, role = "field" },
        },
        effect = {
            kind = "register_write",
            name = "vmwrite_updates_rflags",
            target_register = "rflags",
            role = "updated by vmwrite",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "invept",
        operands = {
            { index = 1, role = "type" },
            { index = 2, role = "descriptor" },
        },
        effect = {
            kind = "register_write",
            name = "invept_updates_rflags",
            target_register = "rflags",
            role = "updated by invept",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "invvpid",
        operands = {
            { index = 1, role = "type" },
            { index = 2, role = "descriptor" },
        },
        effect = {
            kind = "register_write",
            name = "invvpid_updates_rflags",
            target_register = "rflags",
            role = "updated by invvpid",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "skinit",
        operands = {},
        effect = {
            kind = "register_write",
            name = "skinit_updates_system_state",
            target_register = "rip",
            role = "secure initialization by skinit",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "stgi",
        operands = {},
        effect = {
            kind = "register_write",
            name = "stgi_updates_system_state",
            target_register = "rflags",
            role = "global interrupt flag set by stgi",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "clgi",
        operands = {},
        effect = {
            kind = "register_write",
            name = "clgi_updates_system_state",
            target_register = "rflags",
            role = "global interrupt flag cleared by clgi",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmload",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vmload_updates_system_state",
            target_register = "rip",
            role = "loaded virtual machine control state by vmload",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmsave",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "vmsave_updates_system_state",
            target_register = "rip",
            role = "saved virtual machine control state by vmsave",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmmcall",
        operands = {},
        effect = {
            kind = "register_write",
            name = "vmmcall_updates_rip",
            target_register = "rip",
            role = "virtual machine monitor call by vmmcall",
        },
    },

    -- XSAVE / XRSTOR / FPU/SIMD state management.
    {
        node_type = "instruction",
        mnemonic = "fxsave",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fxsave_stores_processor_state",
            target_register = "rip",
            role = "saved fpu and simd state by fxsave",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fxsave64",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fxsave64_stores_processor_state",
            target_register = "rip",
            role = "saved 64-bit fpu and simd state by fxsave64",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fxrstor",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "fxrstor_restores_processor_state",
            target_register = "rip",
            role = "restored fpu and simd state by fxrstor",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fxrstor64",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "fxrstor64_restores_processor_state",
            target_register = "rip",
            role = "restored 64-bit fpu and simd state by fxrstor64",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xsave",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "xsave_stores_processor_state",
            target_register = "rip",
            role = "saved extended processor state by xsave",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xsave64",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "xsave64_stores_processor_state",
            target_register = "rip",
            role = "saved 64-bit extended processor state by xsave64",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xsaveopt",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "xsaveopt_stores_processor_state",
            target_register = "rip",
            role = "optimally saved extended processor state by xsaveopt",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xsaveopt64",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "xsaveopt64_stores_processor_state",
            target_register = "rip",
            role = "optimally saved 64-bit extended processor state by xsaveopt64",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xsavec",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "xsavec_stores_processor_state",
            target_register = "rip",
            role = "compacted saved extended processor state by xsavec",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xsavec64",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "xsavec64_stores_processor_state",
            target_register = "rip",
            role = "compacted saved 64-bit extended processor state by xsavec64",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xsaves",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "xsaves_stores_processor_state",
            target_register = "rip",
            role = "supervisor saved extended processor state by xsaves",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xsaves64",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "xsaves64_stores_processor_state",
            target_register = "rip",
            role = "supervisor saved 64-bit extended processor state by xsaves64",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xrstor",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xrstor_restores_processor_state",
            target_register = "rip",
            role = "restored extended processor state by xrstor",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xrstor64",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xrstor64_restores_processor_state",
            target_register = "rip",
            role = "restored 64-bit extended processor state by xrstor64",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xrstors",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xrstors_restores_processor_state",
            target_register = "rip",
            role = "restored supervisor extended processor state by xrstors",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xrstors64",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xrstors64_restores_processor_state",
            target_register = "rip",
            role = "restored supervisor 64-bit extended processor state by xrstors64",
        },
    },

    -- MXCSR / x87 control-state helpers.
    {
        node_type = "instruction",
        mnemonic = "stmxcsr",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "stmxcsr_stores_control_state",
            target_register = "rip",
            role = "stored mxcsr by stmxcsr",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "ldmxcsr",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "ldmxcsr_loads_control_state",
            target_register = "rip",
            role = "loaded mxcsr by ldmxcsr",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fstcw",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fstcw_stores_control_word",
            target_register = "rip",
            role = "stored x87 control word by fstcw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fnstcw",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fnstcw_stores_control_word",
            target_register = "rip",
            role = "stored x87 control word by fnstcw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fldcw",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "fldcw_loads_control_word",
            target_register = "rip",
            role = "loaded x87 control word by fldcw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fstsw",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fstsw_stores_status_word",
            target_register = "rip",
            role = "stored x87 status word by fstsw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fnstsw",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fnstsw_stores_status_word",
            target_register = "rip",
            role = "stored x87 status word by fnstsw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fstsw",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fstsw_writes_register",
            target_operand = 1,
            role = "written with x87 status word by fstsw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fnstsw",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fnstsw_writes_register",
            target_operand = 1,
            role = "written with x87 status word by fnstsw",
        },
    },

    -- x87 environment save/restore/init/clear.
    {
        node_type = "instruction",
        mnemonic = "finit",
        operands = {},
        effect = {
            kind = "register_write",
            name = "finit_initializes_fpu",
            target_register = "rip",
            role = "initialized x87 fpu by finit",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fninit",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fninit_initializes_fpu",
            target_register = "rip",
            role = "initialized x87 fpu by fninit",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fclex",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fclex_clears_exceptions",
            target_register = "rip",
            role = "cleared x87 exceptions by fclex",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fnclex",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fnclex_clears_exceptions",
            target_register = "rip",
            role = "cleared x87 exceptions by fnclex",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fsave",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fsave_stores_fpu_state",
            target_register = "rip",
            role = "saved x87 fpu state by fsave",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fnsave",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fnsave_stores_fpu_state",
            target_register = "rip",
            role = "saved x87 fpu state by fnsave",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "frstor",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "frstor_restores_fpu_state",
            target_register = "rip",
            role = "restored x87 fpu state by frstor",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fstenv",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fstenv_stores_fpu_environment",
            target_register = "rip",
            role = "stored x87 environment by fstenv",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fnstenv",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fnstenv_stores_fpu_environment",
            target_register = "rip",
            role = "stored x87 environment by fnstenv",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fldenv",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "fldenv_loads_fpu_environment",
            target_register = "rip",
            role = "loaded x87 environment by fldenv",
        },
    },

    -- x87 stack/math visibility. No x87 register model yet, so expose as RIP-side FPU activity.
    {
        node_type = "instruction",
        mnemonic = "fld",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "fld_updates_fpu_stack",
            target_register = "rip",
            role = "loaded x87 value by fld",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fst",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fst_updates_fpu_stack",
            target_register = "rip",
            role = "stored x87 value by fst",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fstp",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fstp_updates_fpu_stack",
            target_register = "rip",
            role = "stored and popped x87 value by fstp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fild",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "fild_updates_fpu_stack",
            target_register = "rip",
            role = "loaded integer into x87 stack by fild",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fist",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fist_updates_fpu_stack",
            target_register = "rip",
            role = "stored integer from x87 stack by fist",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fistp",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fistp_updates_fpu_stack",
            target_register = "rip",
            role = "stored integer and popped x87 stack by fistp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fisttp",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fisttp_updates_fpu_stack",
            target_register = "rip",
            role = "stored truncated integer and popped x87 stack by fisttp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fbld",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "fbld_updates_fpu_stack",
            target_register = "rip",
            role = "loaded bcd value into x87 stack by fbld",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fbstp",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "fbstp_updates_fpu_stack",
            target_register = "rip",
            role = "stored bcd value and popped x87 stack by fbstp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fadd",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fadd_updates_fpu_stack",
            target_register = "rip",
            role = "updated x87 stack by fadd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "faddp",
        operands = {},
        effect = {
            kind = "register_write",
            name = "faddp_updates_fpu_stack",
            target_register = "rip",
            role = "updated and popped x87 stack by faddp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fiadd",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "fiadd_updates_fpu_stack",
            target_register = "rip",
            role = "added integer to x87 stack by fiadd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fsub",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fsub_updates_fpu_stack",
            target_register = "rip",
            role = "updated x87 stack by fsub",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fsubp",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fsubp_updates_fpu_stack",
            target_register = "rip",
            role = "updated and popped x87 stack by fsubp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fisub",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "fisub_updates_fpu_stack",
            target_register = "rip",
            role = "subtracted integer from x87 stack by fisub",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fisubr",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "fisubr_updates_fpu_stack",
            target_register = "rip",
            role = "reverse-subtracted integer with x87 stack by fisubr",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fmul",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fmul_updates_fpu_stack",
            target_register = "rip",
            role = "updated x87 stack by fmul",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fmulp",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fmulp_updates_fpu_stack",
            target_register = "rip",
            role = "updated and popped x87 stack by fmulp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fimul",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "fimul_updates_fpu_stack",
            target_register = "rip",
            role = "multiplied integer with x87 stack by fimul",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fdiv",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fdiv_updates_fpu_stack",
            target_register = "rip",
            role = "updated x87 stack by fdiv",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fdivp",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fdivp_updates_fpu_stack",
            target_register = "rip",
            role = "updated and popped x87 stack by fdivp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fidiv",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "fidiv_updates_fpu_stack",
            target_register = "rip",
            role = "divided x87 stack by integer with fidiv",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fidivr",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "fidivr_updates_fpu_stack",
            target_register = "rip",
            role = "reverse-divided integer with x87 stack by fidivr",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fcom",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fcom_updates_fpu_status",
            target_register = "rip",
            role = "compared x87 values by fcom",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fcomp",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fcomp_updates_fpu_status",
            target_register = "rip",
            role = "compared and popped x87 value by fcomp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fcompp",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fcompp_updates_fpu_status",
            target_register = "rip",
            role = "compared and popped two x87 values by fcompp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fucom",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fucom_updates_fpu_status",
            target_register = "rip",
            role = "unordered-compared x87 values by fucom",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fucomp",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fucomp_updates_fpu_status",
            target_register = "rip",
            role = "unordered-compared and popped x87 value by fucomp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fucompp",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fucompp_updates_fpu_status",
            target_register = "rip",
            role = "unordered-compared and popped two x87 values by fucompp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fcomi",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fcomi_updates_rflags",
            target_register = "rflags",
            role = "updated by x87 compare fcomi",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fcomip",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fcomip_updates_rflags",
            target_register = "rflags",
            role = "updated by x87 compare-and-pop fcomip",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fucomi",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fucomi_updates_rflags",
            target_register = "rflags",
            role = "updated by unordered x87 compare fucomi",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fucomip",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fucomip_updates_rflags",
            target_register = "rflags",
            role = "updated by unordered x87 compare-and-pop fucomip",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "ftst",
        operands = {},
        effect = {
            kind = "register_write",
            name = "ftst_updates_fpu_status",
            target_register = "rip",
            role = "tested x87 value against zero by ftst",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fxam",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fxam_updates_fpu_status",
            target_register = "rip",
            role = "examined x87 value by fxam",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fxch",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fxch_updates_fpu_stack",
            target_register = "rip",
            role = "exchanged x87 stack registers by fxch",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fabs",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fabs_updates_fpu_stack",
            target_register = "rip",
            role = "absolute-valued x87 top by fabs",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fchs",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fchs_updates_fpu_stack",
            target_register = "rip",
            role = "changed sign of x87 top by fchs",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "frndint",
        operands = {},
        effect = {
            kind = "register_write",
            name = "frndint_updates_fpu_stack",
            target_register = "rip",
            role = "rounded x87 top to integer by frndint",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fsqrt",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fsqrt_updates_fpu_stack",
            target_register = "rip",
            role = "square-rooted x87 top by fsqrt",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fscale",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fscale_updates_fpu_stack",
            target_register = "rip",
            role = "scaled x87 value by fscale",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fprem",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fprem_updates_fpu_stack",
            target_register = "rip",
            role = "computed x87 partial remainder by fprem",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fprem1",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fprem1_updates_fpu_stack",
            target_register = "rip",
            role = "computed ieee x87 partial remainder by fprem1",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fyl2x",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fyl2x_updates_fpu_stack",
            target_register = "rip",
            role = "computed y times log2 x by fyl2x",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fyl2xp1",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fyl2xp1_updates_fpu_stack",
            target_register = "rip",
            role = "computed y times log2 x-plus-one by fyl2xp1",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "f2xm1",
        operands = {},
        effect = {
            kind = "register_write",
            name = "f2xm1_updates_fpu_stack",
            target_register = "rip",
            role = "computed two-power-x-minus-one by f2xm1",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fsin",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fsin_updates_fpu_stack",
            target_register = "rip",
            role = "computed sine by fsin",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fcos",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fcos_updates_fpu_stack",
            target_register = "rip",
            role = "computed cosine by fcos",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fsincos",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fsincos_updates_fpu_stack",
            target_register = "rip",
            role = "computed sine and cosine by fsincos",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fptan",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fptan_updates_fpu_stack",
            target_register = "rip",
            role = "computed partial tangent by fptan",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fpatan",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fpatan_updates_fpu_stack",
            target_register = "rip",
            role = "computed partial arctangent by fpatan",
        },
    },

    -- x87 constants.
    {
        node_type = "instruction",
        mnemonic = "fld1",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fld1_updates_fpu_stack",
            target_register = "rip",
            role = "loaded x87 constant one by fld1",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fldz",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fldz_updates_fpu_stack",
            target_register = "rip",
            role = "loaded x87 constant zero by fldz",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fldpi",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fldpi_updates_fpu_stack",
            target_register = "rip",
            role = "loaded x87 constant pi by fldpi",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fldl2e",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fldl2e_updates_fpu_stack",
            target_register = "rip",
            role = "loaded x87 constant log2 e by fldl2e",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fldl2t",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fldl2t_updates_fpu_stack",
            target_register = "rip",
            role = "loaded x87 constant log2 ten by fldl2t",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fldlg2",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fldlg2_updates_fpu_stack",
            target_register = "rip",
            role = "loaded x87 constant log10 two by fldlg2",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "fldln2",
        operands = {},
        effect = {
            kind = "register_write",
            name = "fldln2_updates_fpu_stack",
            target_register = "rip",
            role = "loaded x87 constant ln two by fldln2",
        },
    },

    -- MMX state bridge.
    {
        node_type = "instruction",
        mnemonic = "emms",
        operands = {},
        effect = {
            kind = "register_write",
            name = "emms_updates_mmx_state",
            target_register = "rip",
            role = "emptied mmx state by emms",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "femms",
        operands = {},
        effect = {
            kind = "register_write",
            name = "femms_updates_mmx_state",
            target_register = "rip",
            role = "fast-emptied mmx state by femms",
        },
    },


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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    {
        node_type = "instruction",
        mnemonic = "addps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "addps_simd_arithmetic",
            target_register = "rip",
            role = "added packed single-precision values by addps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "addpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "addpd_simd_arithmetic",
            target_register = "rip",
            role = "added packed double-precision values by addpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "addss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "addss_scalar_simd_arithmetic",
            target_register = "rip",
            role = "added scalar single-precision values by addss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "addsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "addsd_scalar_simd_arithmetic",
            target_register = "rip",
            role = "added scalar double-precision values by addsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "subps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "subps_simd_arithmetic",
            target_register = "rip",
            role = "subtracted packed single-precision values by subps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "subpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "subpd_simd_arithmetic",
            target_register = "rip",
            role = "subtracted packed double-precision values by subpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "subss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "subss_scalar_simd_arithmetic",
            target_register = "rip",
            role = "subtracted scalar single-precision values by subss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "subsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "subsd_scalar_simd_arithmetic",
            target_register = "rip",
            role = "subtracted scalar double-precision values by subsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "mulps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "mulps_simd_arithmetic",
            target_register = "rip",
            role = "multiplied packed single-precision values by mulps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "mulpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "mulpd_simd_arithmetic",
            target_register = "rip",
            role = "multiplied packed double-precision values by mulpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "mulss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "mulss_scalar_simd_arithmetic",
            target_register = "rip",
            role = "multiplied scalar single-precision values by mulss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "mulsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "mulsd_scalar_simd_arithmetic",
            target_register = "rip",
            role = "multiplied scalar double-precision values by mulsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "divps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "divps_simd_arithmetic",
            target_register = "rip",
            role = "divided packed single-precision values by divps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "divpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "divpd_simd_arithmetic",
            target_register = "rip",
            role = "divided packed double-precision values by divpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "divss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "divss_scalar_simd_arithmetic",
            target_register = "rip",
            role = "divided scalar single-precision values by divss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "divsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "divsd_scalar_simd_arithmetic",
            target_register = "rip",
            role = "divided scalar double-precision values by divsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sqrtps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "sqrtps_simd_arithmetic",
            target_register = "rip",
            role = "square-rooted packed single-precision values by sqrtps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sqrtpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "sqrtpd_simd_arithmetic",
            target_register = "rip",
            role = "square-rooted packed double-precision values by sqrtpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sqrtss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "sqrtss_scalar_simd_arithmetic",
            target_register = "rip",
            role = "square-rooted scalar single-precision value by sqrtss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sqrtsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "sqrtsd_scalar_simd_arithmetic",
            target_register = "rip",
            role = "square-rooted scalar double-precision value by sqrtsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "maxps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "maxps_simd_compare_select",
            target_register = "rip",
            role = "selected packed single-precision maximum values by maxps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "maxpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "maxpd_simd_compare_select",
            target_register = "rip",
            role = "selected packed double-precision maximum values by maxpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "maxss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "maxss_scalar_simd_compare_select",
            target_register = "rip",
            role = "selected scalar single-precision maximum value by maxss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "maxsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "maxsd_scalar_simd_compare_select",
            target_register = "rip",
            role = "selected scalar double-precision maximum value by maxsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "minps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "minps_simd_compare_select",
            target_register = "rip",
            role = "selected packed single-precision minimum values by minps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "minpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "minpd_simd_compare_select",
            target_register = "rip",
            role = "selected packed double-precision minimum values by minpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "minss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "minss_scalar_simd_compare_select",
            target_register = "rip",
            role = "selected scalar single-precision minimum value by minss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "minsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "minsd_scalar_simd_compare_select",
            target_register = "rip",
            role = "selected scalar double-precision minimum value by minsd",
        },
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    {
        node_type = "instruction",
        mnemonic = "cmpps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
        effect = {
            kind = "register_write",
            name = "cmpps_simd_compare",
            target_register = "rip",
            role = "compared packed single-precision values by cmpps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cmppd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
        effect = {
            kind = "register_write",
            name = "cmppd_simd_compare",
            target_register = "rip",
            role = "compared packed double-precision values by cmppd",
        },
    },

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
    },

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
    },

    {
        node_type = "instruction",
        mnemonic = "comiss",
        operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
        effect = {
            kind = "register_write",
            name = "comiss_updates_rflags",
            target_register = "rflags",
            role = "updated by scalar single-precision compare comiss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "ucomiss",
        operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
        effect = {
            kind = "register_write",
            name = "ucomiss_updates_rflags",
            target_register = "rflags",
            role = "updated by unordered scalar single-precision compare ucomiss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "comisd",
        operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
        effect = {
            kind = "register_write",
            name = "comisd_updates_rflags",
            target_register = "rflags",
            role = "updated by scalar double-precision compare comisd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "ucomisd",
        operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
        effect = {
            kind = "register_write",
            name = "ucomisd_updates_rflags",
            target_register = "rflags",
            role = "updated by unordered scalar double-precision compare ucomisd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "shufps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
        effect = {
            kind = "register_write",
            name = "shufps_simd_shuffle",
            target_register = "rip",
            role = "shuffled packed single-precision values by shufps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "shufpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
        effect = {
            kind = "register_write",
            name = "shufpd_simd_shuffle",
            target_register = "rip",
            role = "shuffled packed double-precision values by shufpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "unpckhps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "unpckhps_simd_unpack",
            target_register = "rip",
            role = "unpacked high packed single-precision values by unpckhps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "unpcklps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "unpcklps_simd_unpack",
            target_register = "rip",
            role = "unpacked low packed single-precision values by unpcklps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "unpckhpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "unpckhpd_simd_unpack",
            target_register = "rip",
            role = "unpacked high packed double-precision values by unpckhpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "unpcklpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "unpcklpd_simd_unpack",
            target_register = "rip",
            role = "unpacked low packed double-precision values by unpcklpd",
        },
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    {
        node_type = "instruction",
        mnemonic = "cvtss2sd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvtss2sd_simd_convert",
            target_register = "rip",
            role = "converted scalar single to scalar double by cvtss2sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvtsd2ss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvtsd2ss_simd_convert",
            target_register = "rip",
            role = "converted scalar double to scalar single by cvtsd2ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvttps2dq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvttps2dq_simd_convert",
            target_register = "rip",
            role = "converted packed single to integers with truncation by cvttps2dq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvtps2dq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvtps2dq_simd_convert",
            target_register = "rip",
            role = "converted packed single to integers by cvtps2dq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvtdq2ps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvtdq2ps_simd_convert",
            target_register = "rip",
            role = "converted packed integers to single-precision by cvtdq2ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvtpd2ps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvtpd2ps_simd_convert",
            target_register = "rip",
            role = "converted packed double to packed single by cvtpd2ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvtps2pd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvtps2pd_simd_convert",
            target_register = "rip",
            role = "converted packed single to packed double by cvtps2pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvttpd2dq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvttpd2dq_simd_convert",
            target_register = "rip",
            role = "converted packed double to integers with truncation by cvttpd2dq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvtpd2dq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvtpd2dq_simd_convert",
            target_register = "rip",
            role = "converted packed double to integers by cvtpd2dq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvtdq2pd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvtdq2pd_simd_convert",
            target_register = "rip",
            role = "converted packed integers to double-precision by cvtdq2pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvtsi2ss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvtsi2ss_simd_convert",
            target_register = "rip",
            role = "converted integer to scalar single by cvtsi2ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvtsi2sd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvtsi2sd_simd_convert",
            target_register = "rip",
            role = "converted integer to scalar double by cvtsi2sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvtss2si",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvtss2si_writes_gpr",
            target_operand = 1,
            role = "written with converted scalar single integer by cvtss2si",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvtsd2si",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvtsd2si_writes_gpr",
            target_operand = 1,
            role = "written with converted scalar double integer by cvtsd2si",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvttss2si",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvttss2si_writes_gpr",
            target_operand = 1,
            role = "written with truncated scalar single integer by cvttss2si",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cvttsd2si",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "cvttsd2si_writes_gpr",
            target_operand = 1,
            role = "written with truncated scalar double integer by cvttsd2si",
        },
    },

    -- Packed integer SIMD/MMX/SSE visibility effects.
    -- Phase-one model: no SIMD/MMX register file yet, so most vector effects are exposed as RIP-side activity.

    {
        node_type = "instruction",
        mnemonic = "paddb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "paddb_simd_integer_add",
            target_register = "rip",
            role = "added packed byte integers by paddb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "paddw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "paddw_simd_integer_add",
            target_register = "rip",
            role = "added packed word integers by paddw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "paddd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "paddd_simd_integer_add",
            target_register = "rip",
            role = "added packed doubleword integers by paddd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "paddq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "paddq_simd_integer_add",
            target_register = "rip",
            role = "added packed quadword integers by paddq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "paddsb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "paddsb_simd_integer_add",
            target_register = "rip",
            role = "saturating-added packed signed bytes by paddsb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "paddsw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "paddsw_simd_integer_add",
            target_register = "rip",
            role = "saturating-added packed signed words by paddsw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "paddusb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "paddusb_simd_integer_add",
            target_register = "rip",
            role = "saturating-added packed unsigned bytes by paddusb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "paddusw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "paddusw_simd_integer_add",
            target_register = "rip",
            role = "saturating-added packed unsigned words by paddusw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psubb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "psubb_simd_integer_subtract",
            target_register = "rip",
            role = "subtracted packed byte integers by psubb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psubw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "psubw_simd_integer_subtract",
            target_register = "rip",
            role = "subtracted packed word integers by psubw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psubd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "psubd_simd_integer_subtract",
            target_register = "rip",
            role = "subtracted packed doubleword integers by psubd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psubq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "psubq_simd_integer_subtract",
            target_register = "rip",
            role = "subtracted packed quadword integers by psubq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psubsb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "psubsb_simd_integer_subtract",
            target_register = "rip",
            role = "saturating-subtracted packed signed bytes by psubsb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psubsw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "psubsw_simd_integer_subtract",
            target_register = "rip",
            role = "saturating-subtracted packed signed words by psubsw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psubusb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "psubusb_simd_integer_subtract",
            target_register = "rip",
            role = "saturating-subtracted packed unsigned bytes by psubusb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psubusw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "psubusw_simd_integer_subtract",
            target_register = "rip",
            role = "saturating-subtracted packed unsigned words by psubusw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmullw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmullw_simd_integer_multiply",
            target_register = "rip",
            role = "multiplied packed signed words low by pmullw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmulhw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmulhw_simd_integer_multiply",
            target_register = "rip",
            role = "multiplied packed signed words high by pmulhw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmulhuw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmulhuw_simd_integer_multiply",
            target_register = "rip",
            role = "multiplied packed unsigned words high by pmulhuw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmulld",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmulld_simd_integer_multiply",
            target_register = "rip",
            role = "multiplied packed signed doublewords low by pmulld",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmuldq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmuldq_simd_integer_multiply",
            target_register = "rip",
            role = "multiplied packed signed doublewords to quadwords by pmuldq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmuludq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmuludq_simd_integer_multiply",
            target_register = "rip",
            role = "multiplied packed unsigned doublewords to quadwords by pmuludq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmaddwd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmaddwd_simd_integer_multiply_add",
            target_register = "rip",
            role = "multiply-added packed words to doublewords by pmaddwd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmaddubsw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmaddubsw_simd_integer_multiply_add",
            target_register = "rip",
            role = "multiply-added packed unsigned bytes and signed bytes by pmaddubsw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pavgb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pavgb_simd_integer_average",
            target_register = "rip",
            role = "averaged packed unsigned bytes by pavgb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pavgw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pavgw_simd_integer_average",
            target_register = "rip",
            role = "averaged packed unsigned words by pavgw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pabsb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pabsb_simd_integer_absolute",
            target_register = "rip",
            role = "absolute-valued packed signed bytes by pabsb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pabsw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pabsw_simd_integer_absolute",
            target_register = "rip",
            role = "absolute-valued packed signed words by pabsw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pabsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pabsd_simd_integer_absolute",
            target_register = "rip",
            role = "absolute-valued packed signed doublewords by pabsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psignb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "psignb_simd_integer_sign",
            target_register = "rip",
            role = "applied packed byte signs by psignb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psignw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "psignw_simd_integer_sign",
            target_register = "rip",
            role = "applied packed word signs by psignw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psignd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "psignd_simd_integer_sign",
            target_register = "rip",
            role = "applied packed doubleword signs by psignd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pand",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pand_simd_integer_logic",
            target_register = "rip",
            role = "bitwise-and packed integer lanes by pand",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pandn",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pandn_simd_integer_logic",
            target_register = "rip",
            role = "bitwise-and-not packed integer lanes by pandn",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "por",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "por_simd_integer_logic",
            target_register = "rip",
            role = "bitwise-or packed integer lanes by por",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pxor",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pxor_simd_integer_logic",
            target_register = "rip",
            role = "bitwise-xor packed integer lanes by pxor",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpeqb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pcmpeqb_simd_integer_compare",
            target_register = "rip",
            role = "compared packed bytes for equality by pcmpeqb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpeqw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pcmpeqw_simd_integer_compare",
            target_register = "rip",
            role = "compared packed words for equality by pcmpeqw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpeqd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pcmpeqd_simd_integer_compare",
            target_register = "rip",
            role = "compared packed doublewords for equality by pcmpeqd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpeqq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pcmpeqq_simd_integer_compare",
            target_register = "rip",
            role = "compared packed quadwords for equality by pcmpeqq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpgtb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pcmpgtb_simd_integer_compare",
            target_register = "rip",
            role = "compared packed signed bytes greater-than by pcmpgtb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpgtw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pcmpgtw_simd_integer_compare",
            target_register = "rip",
            role = "compared packed signed words greater-than by pcmpgtw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpgtd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pcmpgtd_simd_integer_compare",
            target_register = "rip",
            role = "compared packed signed doublewords greater-than by pcmpgtd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpgtq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pcmpgtq_simd_integer_compare",
            target_register = "rip",
            role = "compared packed signed quadwords greater-than by pcmpgtq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pminub",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pminub_simd_integer_minmax",
            target_register = "rip",
            role = "selected packed unsigned byte minimums by pminub",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pminuw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pminuw_simd_integer_minmax",
            target_register = "rip",
            role = "selected packed unsigned word minimums by pminuw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pminud",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pminud_simd_integer_minmax",
            target_register = "rip",
            role = "selected packed unsigned doubleword minimums by pminud",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pminsb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pminsb_simd_integer_minmax",
            target_register = "rip",
            role = "selected packed signed byte minimums by pminsb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pminsw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pminsw_simd_integer_minmax",
            target_register = "rip",
            role = "selected packed signed word minimums by pminsw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pminsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pminsd_simd_integer_minmax",
            target_register = "rip",
            role = "selected packed signed doubleword minimums by pminsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmaxub",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmaxub_simd_integer_minmax",
            target_register = "rip",
            role = "selected packed unsigned byte maximums by pmaxub",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmaxuw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmaxuw_simd_integer_minmax",
            target_register = "rip",
            role = "selected packed unsigned word maximums by pmaxuw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmaxud",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmaxud_simd_integer_minmax",
            target_register = "rip",
            role = "selected packed unsigned doubleword maximums by pmaxud",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmaxsb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmaxsb_simd_integer_minmax",
            target_register = "rip",
            role = "selected packed signed byte maximums by pmaxsb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmaxsw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmaxsw_simd_integer_minmax",
            target_register = "rip",
            role = "selected packed signed word maximums by pmaxsw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmaxsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmaxsd_simd_integer_minmax",
            target_register = "rip",
            role = "selected packed signed doubleword maximums by pmaxsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psllw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
        effect = {
            kind = "register_write",
            name = "psllw_simd_integer_shift",
            target_register = "rip",
            role = "shifted packed words left by psllw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pslld",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
        effect = {
            kind = "register_write",
            name = "pslld_simd_integer_shift",
            target_register = "rip",
            role = "shifted packed doublewords left by pslld",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psllq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
        effect = {
            kind = "register_write",
            name = "psllq_simd_integer_shift",
            target_register = "rip",
            role = "shifted packed quadwords left by psllq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psrlw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
        effect = {
            kind = "register_write",
            name = "psrlw_simd_integer_shift",
            target_register = "rip",
            role = "logically shifted packed words right by psrlw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psrld",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
        effect = {
            kind = "register_write",
            name = "psrld_simd_integer_shift",
            target_register = "rip",
            role = "logically shifted packed doublewords right by psrld",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psrlq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
        effect = {
            kind = "register_write",
            name = "psrlq_simd_integer_shift",
            target_register = "rip",
            role = "logically shifted packed quadwords right by psrlq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psraw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
        effect = {
            kind = "register_write",
            name = "psraw_simd_integer_shift",
            target_register = "rip",
            role = "arithmetically shifted packed words right by psraw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psrad",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
        effect = {
            kind = "register_write",
            name = "psrad_simd_integer_shift",
            target_register = "rip",
            role = "arithmetically shifted packed doublewords right by psrad",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pslldq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
        effect = {
            kind = "register_write",
            name = "pslldq_simd_integer_shift",
            target_register = "rip",
            role = "shifted packed double-quadword left by pslldq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psrldq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "count" } },
        effect = {
            kind = "register_write",
            name = "psrldq_simd_integer_shift",
            target_register = "rip",
            role = "shifted packed double-quadword right by psrldq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "packsswb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "packsswb_simd_integer_pack",
            target_register = "rip",
            role = "packed signed words to signed bytes by packsswb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "packssdw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "packssdw_simd_integer_pack",
            target_register = "rip",
            role = "packed signed doublewords to signed words by packssdw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "packuswb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "packuswb_simd_integer_pack",
            target_register = "rip",
            role = "packed signed words to unsigned bytes by packuswb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "packusdw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "packusdw_simd_integer_pack",
            target_register = "rip",
            role = "packed signed doublewords to unsigned words by packusdw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "punpcklbw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "punpcklbw_simd_integer_unpack",
            target_register = "rip",
            role = "unpacked low packed bytes by punpcklbw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "punpcklwd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "punpcklwd_simd_integer_unpack",
            target_register = "rip",
            role = "unpacked low packed words by punpcklwd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "punpckldq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "punpckldq_simd_integer_unpack",
            target_register = "rip",
            role = "unpacked low packed doublewords by punpckldq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "punpcklqdq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "punpcklqdq_simd_integer_unpack",
            target_register = "rip",
            role = "unpacked low packed quadwords by punpcklqdq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "punpckhbw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "punpckhbw_simd_integer_unpack",
            target_register = "rip",
            role = "unpacked high packed bytes by punpckhbw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "punpckhwd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "punpckhwd_simd_integer_unpack",
            target_register = "rip",
            role = "unpacked high packed words by punpckhwd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "punpckhdq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "punpckhdq_simd_integer_unpack",
            target_register = "rip",
            role = "unpacked high packed doublewords by punpckhdq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "punpckhqdq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "punpckhqdq_simd_integer_unpack",
            target_register = "rip",
            role = "unpacked high packed quadwords by punpckhqdq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pshufd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
        effect = {
            kind = "register_write",
            name = "pshufd_simd_integer_shuffle",
            target_register = "rip",
            role = "shuffled packed doublewords by pshufd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pshufhw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
        effect = {
            kind = "register_write",
            name = "pshufhw_simd_integer_shuffle",
            target_register = "rip",
            role = "shuffled high packed words by pshufhw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pshuflw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
        effect = {
            kind = "register_write",
            name = "pshuflw_simd_integer_shuffle",
            target_register = "rip",
            role = "shuffled low packed words by pshuflw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pshufb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pshufb_simd_integer_shuffle",
            target_register = "rip",
            role = "byte-shuffled packed integer lanes by pshufb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "palignr",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
        effect = {
            kind = "register_write",
            name = "palignr_simd_integer_align",
            target_register = "rip",
            role = "aligned packed bytes by palignr",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psadbw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "psadbw_simd_integer_sad",
            target_register = "rip",
            role = "computed packed byte sum of absolute differences by psadbw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "mpsadbw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
        effect = {
            kind = "register_write",
            name = "mpsadbw_simd_integer_sad",
            target_register = "rip",
            role = "computed multiple packed byte sums of absolute differences by mpsadbw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "phaddw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "phaddw_simd_integer_horizontal",
            target_register = "rip",
            role = "horizontally added packed words by phaddw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "phaddd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "phaddd_simd_integer_horizontal",
            target_register = "rip",
            role = "horizontally added packed doublewords by phaddd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "phaddsw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "phaddsw_simd_integer_horizontal",
            target_register = "rip",
            role = "horizontally saturating-added packed signed words by phaddsw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "phsubw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "phsubw_simd_integer_horizontal",
            target_register = "rip",
            role = "horizontally subtracted packed words by phsubw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "phsubd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "phsubd_simd_integer_horizontal",
            target_register = "rip",
            role = "horizontally subtracted packed doublewords by phsubd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "phsubsw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "phsubsw_simd_integer_horizontal",
            target_register = "rip",
            role = "horizontally saturating-subtracted packed signed words by phsubsw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovmskb",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmovmskb_writes_gpr",
            target_operand = 1,
            role = "written with packed byte sign mask by pmovmskb",
        },
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    {
        node_type = "instruction",
        mnemonic = "pinsrb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
        effect = {
            kind = "register_write",
            name = "pinsrb_simd_insert",
            target_register = "rip",
            role = "inserted byte into packed integer vector by pinsrb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pinsrw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
        effect = {
            kind = "register_write",
            name = "pinsrw_simd_insert",
            target_register = "rip",
            role = "inserted word into packed integer vector by pinsrw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pinsrd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
        effect = {
            kind = "register_write",
            name = "pinsrd_simd_insert",
            target_register = "rip",
            role = "inserted doubleword into packed integer vector by pinsrd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pinsrq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
        effect = {
            kind = "register_write",
            name = "pinsrq_simd_insert",
            target_register = "rip",
            role = "inserted quadword into packed integer vector by pinsrq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovsxbd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmovsxbd_simd_extend",
            target_register = "rip",
            role = "sign-extended packed bytes to doublewords by pmovsxbd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovsxbq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmovsxbq_simd_extend",
            target_register = "rip",
            role = "sign-extended packed bytes to quadwords by pmovsxbq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovsxbw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmovsxbw_simd_extend",
            target_register = "rip",
            role = "sign-extended packed bytes to words by pmovsxbw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovsxdq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmovsxdq_simd_extend",
            target_register = "rip",
            role = "sign-extended packed doublewords to quadwords by pmovsxdq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovsxwd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmovsxwd_simd_extend",
            target_register = "rip",
            role = "sign-extended packed words to doublewords by pmovsxwd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovsxwq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmovsxwq_simd_extend",
            target_register = "rip",
            role = "sign-extended packed words to quadwords by pmovsxwq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovzxbd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmovzxbd_simd_extend",
            target_register = "rip",
            role = "zero-extended packed bytes to doublewords by pmovzxbd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovzxbq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmovzxbq_simd_extend",
            target_register = "rip",
            role = "zero-extended packed bytes to quadwords by pmovzxbq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovzxbw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmovzxbw_simd_extend",
            target_register = "rip",
            role = "zero-extended packed bytes to words by pmovzxbw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovzxdq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmovzxdq_simd_extend",
            target_register = "rip",
            role = "zero-extended packed doublewords to quadwords by pmovzxdq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovzxwd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmovzxwd_simd_extend",
            target_register = "rip",
            role = "zero-extended packed words to doublewords by pmovzxwd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovzxwq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "pmovzxwq_simd_extend",
            target_register = "rip",
            role = "zero-extended packed words to quadwords by pmovzxwq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "ptest",
        operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
        effect = {
            kind = "register_write",
            name = "ptest_updates_rflags",
            target_register = "rflags",
            role = "updated by packed integer test ptest",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "ptest",
        operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
        effect = {
            kind = "register_write",
            name = "ptest_simd_integer_test",
            target_register = "rip",
            role = "tested packed integer lanes by ptest",
        },
    },

    -- AVX / AVX2 visibility effects.
    -- Phase-one model: no vector register file yet, so most vector effects are exposed as RIP-side activity.

    {
        node_type = "instruction",
        mnemonic = "vmovaps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovaps_vector_move",
            target_register = "rip",
            role = "moved aligned packed single-precision values by vmovaps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovups",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovups_vector_move",
            target_register = "rip",
            role = "moved unaligned packed single-precision values by vmovups",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovapd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovapd_vector_move",
            target_register = "rip",
            role = "moved aligned packed double-precision values by vmovapd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovupd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovupd_vector_move",
            target_register = "rip",
            role = "moved unaligned packed double-precision values by vmovupd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovdqa",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovdqa_vector_move",
            target_register = "rip",
            role = "moved aligned packed integer values by vmovdqa",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovdqu",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovdqu_vector_move",
            target_register = "rip",
            role = "moved unaligned packed integer values by vmovdqu",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovdqa32",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovdqa32_vector_move",
            target_register = "rip",
            role = "moved aligned packed doubleword integers by vmovdqa32",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovdqa64",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovdqa64_vector_move",
            target_register = "rip",
            role = "moved aligned packed quadword integers by vmovdqa64",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovdqu8",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovdqu8_vector_move",
            target_register = "rip",
            role = "moved unaligned packed byte integers by vmovdqu8",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovdqu16",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovdqu16_vector_move",
            target_register = "rip",
            role = "moved unaligned packed word integers by vmovdqu16",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovdqu32",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovdqu32_vector_move",
            target_register = "rip",
            role = "moved unaligned packed doubleword integers by vmovdqu32",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovdqu64",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovdqu64_vector_move",
            target_register = "rip",
            role = "moved unaligned packed quadword integers by vmovdqu64",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovss_scalar_vector_move",
            target_register = "rip",
            role = "moved scalar single-precision value by vmovss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovsd_scalar_vector_move",
            target_register = "rip",
            role = "moved scalar double-precision value by vmovsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovntdq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovntdq_vector_store",
            target_register = "rip",
            role = "stored packed integer values non-temporally by vmovntdq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovntdqa",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovntdqa_vector_load",
            target_register = "rip",
            role = "loaded aligned packed integer values non-temporally by vmovntdqa",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovntps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovntps_vector_store",
            target_register = "rip",
            role = "stored packed single-precision values non-temporally by vmovntps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovntpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovntpd_vector_store",
            target_register = "rip",
            role = "stored packed double-precision values non-temporally by vmovntpd",
        },
    },

    -- AVX packed/scalar floating arithmetic.
    {
        node_type = "instruction",
        mnemonic = "vaddps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vaddps_vector_arithmetic",
            target_register = "rip",
            role = "added packed single-precision values by vaddps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vaddpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vaddpd_vector_arithmetic",
            target_register = "rip",
            role = "added packed double-precision values by vaddpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vaddss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vaddss_scalar_vector_arithmetic",
            target_register = "rip",
            role = "added scalar single-precision values by vaddss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vaddsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vaddsd_scalar_vector_arithmetic",
            target_register = "rip",
            role = "added scalar double-precision values by vaddsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vsubps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vsubps_vector_arithmetic",
            target_register = "rip",
            role = "subtracted packed single-precision values by vsubps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vsubpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vsubpd_vector_arithmetic",
            target_register = "rip",
            role = "subtracted packed double-precision values by vsubpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vsubss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vsubss_scalar_vector_arithmetic",
            target_register = "rip",
            role = "subtracted scalar single-precision values by vsubss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vsubsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vsubsd_scalar_vector_arithmetic",
            target_register = "rip",
            role = "subtracted scalar double-precision values by vsubsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmulps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vmulps_vector_arithmetic",
            target_register = "rip",
            role = "multiplied packed single-precision values by vmulps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmulpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vmulpd_vector_arithmetic",
            target_register = "rip",
            role = "multiplied packed double-precision values by vmulpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmulss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vmulss_scalar_vector_arithmetic",
            target_register = "rip",
            role = "multiplied scalar single-precision values by vmulss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmulsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vmulsd_scalar_vector_arithmetic",
            target_register = "rip",
            role = "multiplied scalar double-precision values by vmulsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vdivps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vdivps_vector_arithmetic",
            target_register = "rip",
            role = "divided packed single-precision values by vdivps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vdivpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vdivpd_vector_arithmetic",
            target_register = "rip",
            role = "divided packed double-precision values by vdivpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vdivss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vdivss_scalar_vector_arithmetic",
            target_register = "rip",
            role = "divided scalar single-precision values by vdivss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vdivsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vdivsd_scalar_vector_arithmetic",
            target_register = "rip",
            role = "divided scalar double-precision values by vdivsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vsqrtps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vsqrtps_vector_arithmetic",
            target_register = "rip",
            role = "square-rooted packed single-precision values by vsqrtps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vsqrtpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vsqrtpd_vector_arithmetic",
            target_register = "rip",
            role = "square-rooted packed double-precision values by vsqrtpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vsqrtss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vsqrtss_scalar_vector_arithmetic",
            target_register = "rip",
            role = "square-rooted scalar single-precision value by vsqrtss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vsqrtsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vsqrtsd_scalar_vector_arithmetic",
            target_register = "rip",
            role = "square-rooted scalar double-precision value by vsqrtsd",
        },
    },

    -- AVX min/max.
    {
        node_type = "instruction",
        mnemonic = "vmaxps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vmaxps_vector_select",
            target_register = "rip",
            role = "selected packed single-precision maximum values by vmaxps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmaxpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vmaxpd_vector_select",
            target_register = "rip",
            role = "selected packed double-precision maximum values by vmaxpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmaxss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vmaxss_scalar_vector_select",
            target_register = "rip",
            role = "selected scalar single-precision maximum value by vmaxss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmaxsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vmaxsd_scalar_vector_select",
            target_register = "rip",
            role = "selected scalar double-precision maximum value by vmaxsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vminps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vminps_vector_select",
            target_register = "rip",
            role = "selected packed single-precision minimum values by vminps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vminpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vminpd_vector_select",
            target_register = "rip",
            role = "selected packed double-precision minimum values by vminpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vminss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vminss_scalar_vector_select",
            target_register = "rip",
            role = "selected scalar single-precision minimum value by vminss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vminsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vminsd_scalar_vector_select",
            target_register = "rip",
            role = "selected scalar double-precision minimum value by vminsd",
        },
    },

    -- AVX logical.
    {
        node_type = "instruction",
        mnemonic = "vandps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vandps_vector_logic",
            target_register = "rip",
            role = "bitwise-and packed single-precision lanes by vandps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vandpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vandpd_vector_logic",
            target_register = "rip",
            role = "bitwise-and packed double-precision lanes by vandpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vandnps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vandnps_vector_logic",
            target_register = "rip",
            role = "bitwise-and-not packed single-precision lanes by vandnps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vandnpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vandnpd_vector_logic",
            target_register = "rip",
            role = "bitwise-and-not packed double-precision lanes by vandnpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vorps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vorps_vector_logic",
            target_register = "rip",
            role = "bitwise-or packed single-precision lanes by vorps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vorpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vorpd_vector_logic",
            target_register = "rip",
            role = "bitwise-or packed double-precision lanes by vorpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vxorps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vxorps_vector_logic",
            target_register = "rip",
            role = "bitwise-xor packed single-precision lanes by vxorps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vxorpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vxorpd_vector_logic",
            target_register = "rip",
            role = "bitwise-xor packed double-precision lanes by vxorpd",
        },
    },

    -- AVX compares and flag compares.
    {
        node_type = "instruction",
        mnemonic = "vcmpps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
        effect = {
            kind = "register_write",
            name = "vcmpps_vector_compare",
            target_register = "rip",
            role = "compared packed single-precision values by vcmpps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcmppd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
        effect = {
            kind = "register_write",
            name = "vcmppd_vector_compare",
            target_register = "rip",
            role = "compared packed double-precision values by vcmppd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcmpss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
        effect = {
            kind = "register_write",
            name = "vcmpss_scalar_vector_compare",
            target_register = "rip",
            role = "compared scalar single-precision values by vcmpss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcmpsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "predicate" } },
        effect = {
            kind = "register_write",
            name = "vcmpsd_scalar_vector_compare",
            target_register = "rip",
            role = "compared scalar double-precision values by vcmpsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcomiss",
        operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vcomiss_updates_rflags",
            target_register = "rflags",
            role = "updated by scalar single-precision compare vcomiss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vucomiss",
        operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vucomiss_updates_rflags",
            target_register = "rflags",
            role = "updated by unordered scalar single-precision compare vucomiss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcomisd",
        operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vcomisd_updates_rflags",
            target_register = "rflags",
            role = "updated by scalar double-precision compare vcomisd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vucomisd",
        operands = { { index = 1, role = "left" }, { index = 2, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vucomisd_updates_rflags",
            target_register = "rflags",
            role = "updated by unordered scalar double-precision compare vucomisd",
        },
    },

    -- AVX shuffle/unpack/blend/permute.
    {
        node_type = "instruction",
        mnemonic = "vshufps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
        effect = {
            kind = "register_write",
            name = "vshufps_vector_shuffle",
            target_register = "rip",
            role = "shuffled packed single-precision values by vshufps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vshufpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
        effect = {
            kind = "register_write",
            name = "vshufpd_vector_shuffle",
            target_register = "rip",
            role = "shuffled packed double-precision values by vshufpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vunpckhps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vunpckhps_vector_unpack",
            target_register = "rip",
            role = "unpacked high packed single-precision values by vunpckhps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vunpcklps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vunpcklps_vector_unpack",
            target_register = "rip",
            role = "unpacked low packed single-precision values by vunpcklps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vunpckhpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vunpckhpd_vector_unpack",
            target_register = "rip",
            role = "unpacked high packed double-precision values by vunpckhpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vunpcklpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vunpcklpd_vector_unpack",
            target_register = "rip",
            role = "unpacked low packed double-precision values by vunpcklpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vblendps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
        effect = {
            kind = "register_write",
            name = "vblendps_vector_blend",
            target_register = "rip",
            role = "blended packed single-precision values by vblendps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vblendpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
        effect = {
            kind = "register_write",
            name = "vblendpd_vector_blend",
            target_register = "rip",
            role = "blended packed double-precision values by vblendpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vblendvps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "mask" } },
        effect = {
            kind = "register_write",
            name = "vblendvps_vector_blend",
            target_register = "rip",
            role = "variable-blended packed single-precision values by vblendvps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vblendvpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "mask" } },
        effect = {
            kind = "register_write",
            name = "vblendvpd_vector_blend",
            target_register = "rip",
            role = "variable-blended packed double-precision values by vblendvpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpermilps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
        effect = {
            kind = "register_write",
            name = "vpermilps_vector_permute",
            target_register = "rip",
            role = "permuted packed single-precision lanes by vpermilps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpermilpd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
        effect = {
            kind = "register_write",
            name = "vpermilpd_vector_permute",
            target_register = "rip",
            role = "permuted packed double-precision lanes by vpermilpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vperm2f128",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
        effect = {
            kind = "register_write",
            name = "vperm2f128_vector_permute",
            target_register = "rip",
            role = "permuted 128-bit floating lanes by vperm2f128",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vperm2i128",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "control" } },
        effect = {
            kind = "register_write",
            name = "vperm2i128_vector_permute",
            target_register = "rip",
            role = "permuted 128-bit integer lanes by vperm2i128",
        },
    },

    -- AVX conversion.
    {
        node_type = "instruction",
        mnemonic = "vcvtss2sd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvtss2sd_vector_convert",
            target_register = "rip",
            role = "converted scalar single to scalar double by vcvtss2sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvtsd2ss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvtsd2ss_vector_convert",
            target_register = "rip",
            role = "converted scalar double to scalar single by vcvtsd2ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvttps2dq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvttps2dq_vector_convert",
            target_register = "rip",
            role = "converted packed single to integers with truncation by vcvttps2dq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvtps2dq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvtps2dq_vector_convert",
            target_register = "rip",
            role = "converted packed single to integers by vcvtps2dq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvtdq2ps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvtdq2ps_vector_convert",
            target_register = "rip",
            role = "converted packed integers to single-precision by vcvtdq2ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvtpd2ps",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvtpd2ps_vector_convert",
            target_register = "rip",
            role = "converted packed double to packed single by vcvtpd2ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvtps2pd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvtps2pd_vector_convert",
            target_register = "rip",
            role = "converted packed single to packed double by vcvtps2pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvttpd2dq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvttpd2dq_vector_convert",
            target_register = "rip",
            role = "converted packed double to integers with truncation by vcvttpd2dq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvtpd2dq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvtpd2dq_vector_convert",
            target_register = "rip",
            role = "converted packed double to integers by vcvtpd2dq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvtdq2pd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvtdq2pd_vector_convert",
            target_register = "rip",
            role = "converted packed integers to double-precision by vcvtdq2pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvtsi2ss",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvtsi2ss_vector_convert",
            target_register = "rip",
            role = "converted integer to scalar single by vcvtsi2ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvtsi2sd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvtsi2sd_vector_convert",
            target_register = "rip",
            role = "converted integer to scalar double by vcvtsi2sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvtss2si",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvtss2si_writes_gpr",
            target_operand = 1,
            role = "written with converted scalar single integer by vcvtss2si",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvtsd2si",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvtsd2si_writes_gpr",
            target_operand = 1,
            role = "written with converted scalar double integer by vcvtsd2si",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvttss2si",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvttss2si_writes_gpr",
            target_operand = 1,
            role = "written with truncated scalar single integer by vcvttss2si",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvttsd2si",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vcvttsd2si_writes_gpr",
            target_operand = 1,
            role = "written with truncated scalar double integer by vcvttsd2si",
        },
    },

    -- AVX packed integer arithmetic.
    {
        node_type = "instruction",
        mnemonic = "vpaddb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpaddb_vector_integer_add",
            target_register = "rip",
            role = "added packed byte integers by vpaddb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpaddw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpaddw_vector_integer_add",
            target_register = "rip",
            role = "added packed word integers by vpaddw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpaddd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpaddd_vector_integer_add",
            target_register = "rip",
            role = "added packed doubleword integers by vpaddd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpaddq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpaddq_vector_integer_add",
            target_register = "rip",
            role = "added packed quadword integers by vpaddq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsubb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpsubb_vector_integer_subtract",
            target_register = "rip",
            role = "subtracted packed byte integers by vpsubb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsubw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpsubw_vector_integer_subtract",
            target_register = "rip",
            role = "subtracted packed word integers by vpsubw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsubd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpsubd_vector_integer_subtract",
            target_register = "rip",
            role = "subtracted packed doubleword integers by vpsubd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsubq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpsubq_vector_integer_subtract",
            target_register = "rip",
            role = "subtracted packed quadword integers by vpsubq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmullw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpmullw_vector_integer_multiply",
            target_register = "rip",
            role = "multiplied packed signed words low by vpmullw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmulhw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpmulhw_vector_integer_multiply",
            target_register = "rip",
            role = "multiplied packed signed words high by vpmulhw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmulhuw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpmulhuw_vector_integer_multiply",
            target_register = "rip",
            role = "multiplied packed unsigned words high by vpmulhuw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmulld",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpmulld_vector_integer_multiply",
            target_register = "rip",
            role = "multiplied packed signed doublewords low by vpmulld",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmuldq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpmuldq_vector_integer_multiply",
            target_register = "rip",
            role = "multiplied packed signed doublewords to quadwords by vpmuldq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmuludq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpmuludq_vector_integer_multiply",
            target_register = "rip",
            role = "multiplied packed unsigned doublewords to quadwords by vpmuludq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmaddwd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpmaddwd_vector_integer_multiply_add",
            target_register = "rip",
            role = "multiply-added packed words to doublewords by vpmaddwd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmaddubsw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpmaddubsw_vector_integer_multiply_add",
            target_register = "rip",
            role = "multiply-added packed unsigned bytes and signed bytes by vpmaddubsw",
        },
    },

    -- AVX packed integer logic.
    {
        node_type = "instruction",
        mnemonic = "vpand",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpand_vector_integer_logic",
            target_register = "rip",
            role = "bitwise-and packed integer lanes by vpand",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpandn",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpandn_vector_integer_logic",
            target_register = "rip",
            role = "bitwise-and-not packed integer lanes by vpandn",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpor",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpor_vector_integer_logic",
            target_register = "rip",
            role = "bitwise-or packed integer lanes by vpor",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpxor",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpxor_vector_integer_logic",
            target_register = "rip",
            role = "bitwise-xor packed integer lanes by vpxor",
        },
    },

    -- AVX packed integer compare/min/max.
    {
        node_type = "instruction",
        mnemonic = "vpcmpeqb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpcmpeqb_vector_integer_compare",
            target_register = "rip",
            role = "compared packed bytes for equality by vpcmpeqb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcmpeqw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpcmpeqw_vector_integer_compare",
            target_register = "rip",
            role = "compared packed words for equality by vpcmpeqw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcmpeqd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpcmpeqd_vector_integer_compare",
            target_register = "rip",
            role = "compared packed doublewords for equality by vpcmpeqd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcmpeqq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpcmpeqq_vector_integer_compare",
            target_register = "rip",
            role = "compared packed quadwords for equality by vpcmpeqq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcmpgtb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpcmpgtb_vector_integer_compare",
            target_register = "rip",
            role = "compared packed signed bytes greater-than by vpcmpgtb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcmpgtw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpcmpgtw_vector_integer_compare",
            target_register = "rip",
            role = "compared packed signed words greater-than by vpcmpgtw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcmpgtd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpcmpgtd_vector_integer_compare",
            target_register = "rip",
            role = "compared packed signed doublewords greater-than by vpcmpgtd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcmpgtq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpcmpgtq_vector_integer_compare",
            target_register = "rip",
            role = "compared packed signed quadwords greater-than by vpcmpgtq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpminub",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpminub_vector_integer_minmax",
            target_register = "rip",
            role = "selected packed unsigned byte minimums by vpminub",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpminuw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpminuw_vector_integer_minmax",
            target_register = "rip",
            role = "selected packed unsigned word minimums by vpminuw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpminud",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpminud_vector_integer_minmax",
            target_register = "rip",
            role = "selected packed unsigned doubleword minimums by vpminud",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpminsb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpminsb_vector_integer_minmax",
            target_register = "rip",
            role = "selected packed signed byte minimums by vpminsb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpminsw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpminsw_vector_integer_minmax",
            target_register = "rip",
            role = "selected packed signed word minimums by vpminsw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpminsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpminsd_vector_integer_minmax",
            target_register = "rip",
            role = "selected packed signed doubleword minimums by vpminsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmaxub",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpmaxub_vector_integer_minmax",
            target_register = "rip",
            role = "selected packed unsigned byte maximums by vpmaxub",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmaxuw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpmaxuw_vector_integer_minmax",
            target_register = "rip",
            role = "selected packed unsigned word maximums by vpmaxuw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmaxud",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpmaxud_vector_integer_minmax",
            target_register = "rip",
            role = "selected packed unsigned doubleword maximums by vpmaxud",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmaxsb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpmaxsb_vector_integer_minmax",
            target_register = "rip",
            role = "selected packed signed byte maximums by vpmaxsb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmaxsw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpmaxsw_vector_integer_minmax",
            target_register = "rip",
            role = "selected packed signed word maximums by vpmaxsw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmaxsd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpmaxsd_vector_integer_minmax",
            target_register = "rip",
            role = "selected packed signed doubleword maximums by vpmaxsd",
        },
    },

    -- AVX packed integer shifts.
    {
        node_type = "instruction",
        mnemonic = "vpsllw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
        effect = {
            kind = "register_write",
            name = "vpsllw_vector_integer_shift",
            target_register = "rip",
            role = "shifted packed words left by vpsllw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpslld",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
        effect = {
            kind = "register_write",
            name = "vpslld_vector_integer_shift",
            target_register = "rip",
            role = "shifted packed doublewords left by vpslld",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsllq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
        effect = {
            kind = "register_write",
            name = "vpsllq_vector_integer_shift",
            target_register = "rip",
            role = "shifted packed quadwords left by vpsllq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsrlw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
        effect = {
            kind = "register_write",
            name = "vpsrlw_vector_integer_shift",
            target_register = "rip",
            role = "logically shifted packed words right by vpsrlw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsrld",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
        effect = {
            kind = "register_write",
            name = "vpsrld_vector_integer_shift",
            target_register = "rip",
            role = "logically shifted packed doublewords right by vpsrld",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsrlq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
        effect = {
            kind = "register_write",
            name = "vpsrlq_vector_integer_shift",
            target_register = "rip",
            role = "logically shifted packed quadwords right by vpsrlq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsraw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
        effect = {
            kind = "register_write",
            name = "vpsraw_vector_integer_shift",
            target_register = "rip",
            role = "arithmetically shifted packed words right by vpsraw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsrad",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
        effect = {
            kind = "register_write",
            name = "vpsrad_vector_integer_shift",
            target_register = "rip",
            role = "arithmetically shifted packed doublewords right by vpsrad",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpslldq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
        effect = {
            kind = "register_write",
            name = "vpslldq_vector_integer_shift",
            target_register = "rip",
            role = "shifted packed double-quadword left by vpslldq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsrldq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "count" } },
        effect = {
            kind = "register_write",
            name = "vpsrldq_vector_integer_shift",
            target_register = "rip",
            role = "shifted packed double-quadword right by vpsrldq",
        },
    },

    -- AVX extract/mask to GPR.
    {
        node_type = "instruction",
        mnemonic = "vpmovmskb",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vpmovmskb_writes_gpr",
            target_operand = 1,
            role = "written with packed byte sign mask by vpmovmskb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovmskps",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovmskps_writes_gpr",
            target_operand = 1,
            role = "written with packed single-precision sign mask by vmovmskps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmovmskpd",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
        effect = {
            kind = "register_write",
            name = "vmovmskpd_writes_gpr",
            target_operand = 1,
            role = "written with packed double-precision sign mask by vmovmskpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpextrb",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
        effect = {
            kind = "register_write",
            name = "vpextrb_writes_gpr",
            target_operand = 1,
            role = "written with extracted byte by vpextrb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpextrw",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
        effect = {
            kind = "register_write",
            name = "vpextrw_writes_gpr",
            target_operand = 1,
            role = "written with extracted word by vpextrw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpextrd",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
        effect = {
            kind = "register_write",
            name = "vpextrd_writes_gpr",
            target_operand = 1,
            role = "written with extracted doubleword by vpextrd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpextrq",
        operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "index" } },
        effect = {
            kind = "register_write",
            name = "vpextrq_writes_gpr",
            target_operand = 1,
            role = "written with extracted quadword by vpextrq",
        },
    },

    -- AVX insert/pack/unpack/shuffle.
    {
        node_type = "instruction",
        mnemonic = "vpinsrb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" }, { index = 4, role = "index" } },
        effect = {
            kind = "register_write",
            name = "vpinsrb_vector_insert",
            target_register = "rip",
            role = "inserted byte into packed integer vector by vpinsrb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpinsrw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" }, { index = 4, role = "index" } },
        effect = {
            kind = "register_write",
            name = "vpinsrw_vector_insert",
            target_register = "rip",
            role = "inserted word into packed integer vector by vpinsrw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpinsrd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" }, { index = 4, role = "index" } },
        effect = {
            kind = "register_write",
            name = "vpinsrd_vector_insert",
            target_register = "rip",
            role = "inserted doubleword into packed integer vector by vpinsrd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpinsrq",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "source" }, { index = 4, role = "index" } },
        effect = {
            kind = "register_write",
            name = "vpinsrq_vector_insert",
            target_register = "rip",
            role = "inserted quadword into packed integer vector by vpinsrq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpacksswb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpacksswb_vector_pack",
            target_register = "rip",
            role = "packed signed words to signed bytes by vpacksswb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpackssdw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpackssdw_vector_pack",
            target_register = "rip",
            role = "packed signed doublewords to signed words by vpackssdw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpackuswb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpackuswb_vector_pack",
            target_register = "rip",
            role = "packed signed words to unsigned bytes by vpackuswb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpackusdw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpackusdw_vector_pack",
            target_register = "rip",
            role = "packed signed doublewords to unsigned words by vpackusdw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpshufd",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
        effect = {
            kind = "register_write",
            name = "vpshufd_vector_shuffle",
            target_register = "rip",
            role = "shuffled packed doublewords by vpshufd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpshufhw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
        effect = {
            kind = "register_write",
            name = "vpshufhw_vector_shuffle",
            target_register = "rip",
            role = "shuffled high packed words by vpshufhw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpshuflw",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "control" } },
        effect = {
            kind = "register_write",
            name = "vpshuflw_vector_shuffle",
            target_register = "rip",
            role = "shuffled low packed words by vpshuflw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpshufb",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
        effect = {
            kind = "register_write",
            name = "vpshufb_vector_shuffle",
            target_register = "rip",
            role = "byte-shuffled packed integer lanes by vpshufb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpalignr",
        operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" }, { index = 4, role = "count" } },
        effect = {
            kind = "register_write",
            name = "vpalignr_vector_align",
            target_register = "rip",
            role = "aligned packed bytes by vpalignr",
        },
    },

    -- AVX state helpers.
    {
        node_type = "instruction",
        mnemonic = "vzeroupper",
        operands = {},
        effect = {
            kind = "register_write",
            name = "vzeroupper_updates_vector_state",
            target_register = "rip",
            role = "zeroed upper vector register state by vzeroupper",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vzeroall",
        operands = {},
        effect = {
            kind = "register_write",
            name = "vzeroall_updates_vector_state",
            target_register = "rip",
            role = "zeroed all vector register state by vzeroall",
        },
    },

    -- FMA / FMA3 vector fused arithmetic visibility.
    -- Phase-one model: no vector register file yet, so vector-only effects are exposed as RIP-side activity.

    {
        node_type = "instruction",
        mnemonic = "vfmadd132ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmadd132ps_vector_fma",
            target_register = "rip",
            role = "fused multiply-added packed single-precision values by vfmadd132ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmadd213ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmadd213ps_vector_fma",
            target_register = "rip",
            role = "fused multiply-added packed single-precision values by vfmadd213ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmadd231ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmadd231ps_vector_fma",
            target_register = "rip",
            role = "fused multiply-added packed single-precision values by vfmadd231ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmadd132pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmadd132pd_vector_fma",
            target_register = "rip",
            role = "fused multiply-added packed double-precision values by vfmadd132pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmadd213pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmadd213pd_vector_fma",
            target_register = "rip",
            role = "fused multiply-added packed double-precision values by vfmadd213pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmadd231pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmadd231pd_vector_fma",
            target_register = "rip",
            role = "fused multiply-added packed double-precision values by vfmadd231pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmadd132ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmadd132ss_scalar_fma",
            target_register = "rip",
            role = "fused multiply-added scalar single-precision value by vfmadd132ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmadd213ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmadd213ss_scalar_fma",
            target_register = "rip",
            role = "fused multiply-added scalar single-precision value by vfmadd213ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmadd231ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmadd231ss_scalar_fma",
            target_register = "rip",
            role = "fused multiply-added scalar single-precision value by vfmadd231ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmadd132sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmadd132sd_scalar_fma",
            target_register = "rip",
            role = "fused multiply-added scalar double-precision value by vfmadd132sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmadd213sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmadd213sd_scalar_fma",
            target_register = "rip",
            role = "fused multiply-added scalar double-precision value by vfmadd213sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmadd231sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmadd231sd_scalar_fma",
            target_register = "rip",
            role = "fused multiply-added scalar double-precision value by vfmadd231sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsub132ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsub132ps_vector_fma",
            target_register = "rip",
            role = "fused multiply-subtracted packed single-precision values by vfmsub132ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsub213ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsub213ps_vector_fma",
            target_register = "rip",
            role = "fused multiply-subtracted packed single-precision values by vfmsub213ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsub231ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsub231ps_vector_fma",
            target_register = "rip",
            role = "fused multiply-subtracted packed single-precision values by vfmsub231ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsub132pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsub132pd_vector_fma",
            target_register = "rip",
            role = "fused multiply-subtracted packed double-precision values by vfmsub132pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsub213pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsub213pd_vector_fma",
            target_register = "rip",
            role = "fused multiply-subtracted packed double-precision values by vfmsub213pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsub231pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsub231pd_vector_fma",
            target_register = "rip",
            role = "fused multiply-subtracted packed double-precision values by vfmsub231pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmadd132ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmadd132ps_vector_fma",
            target_register = "rip",
            role = "negative fused multiply-added packed single-precision values by vfnmadd132ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmadd213ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmadd213ps_vector_fma",
            target_register = "rip",
            role = "negative fused multiply-added packed single-precision values by vfnmadd213ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmadd231ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmadd231ps_vector_fma",
            target_register = "rip",
            role = "negative fused multiply-added packed single-precision values by vfnmadd231ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmsub132ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmsub132ps_vector_fma",
            target_register = "rip",
            role = "negative fused multiply-subtracted packed single-precision values by vfnmsub132ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmsub213ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmsub213ps_vector_fma",
            target_register = "rip",
            role = "negative fused multiply-subtracted packed single-precision values by vfnmsub213ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmsub231ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmsub231ps_vector_fma",
            target_register = "rip",
            role = "negative fused multiply-subtracted packed single-precision values by vfnmsub231ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmaddsub132ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmaddsub132ps_vector_fma",
            target_register = "rip",
            role = "fused alternating add-sub packed single-precision values by vfmaddsub132ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmaddsub213ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmaddsub213ps_vector_fma",
            target_register = "rip",
            role = "fused alternating add-sub packed single-precision values by vfmaddsub213ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmaddsub231ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmaddsub231ps_vector_fma",
            target_register = "rip",
            role = "fused alternating add-sub packed single-precision values by vfmaddsub231ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsubadd132ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsubadd132ps_vector_fma",
            target_register = "rip",
            role = "fused alternating sub-add packed single-precision values by vfmsubadd132ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsubadd213ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsubadd213ps_vector_fma",
            target_register = "rip",
            role = "fused alternating sub-add packed single-precision values by vfmsubadd213ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsubadd231ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsubadd231ps_vector_fma",
            target_register = "rip",
            role = "fused alternating sub-add packed single-precision values by vfmsubadd231ps",
        },
    },

    -- AES / VAES / carry-less multiply / SHA / GFNI.

    {
        node_type = "instruction",
        mnemonic = "aesenc",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "round_key" },
        },
        effect = {
            kind = "register_write",
            name = "aesenc_crypto",
            target_register = "rip",
            role = "performed aes encryption round by aesenc",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aesenclast",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "round_key" },
        },
        effect = {
            kind = "register_write",
            name = "aesenclast_crypto",
            target_register = "rip",
            role = "performed final aes encryption round by aesenclast",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aesdec",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "round_key" },
        },
        effect = {
            kind = "register_write",
            name = "aesdec_crypto",
            target_register = "rip",
            role = "performed aes decryption round by aesdec",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aesdeclast",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "round_key" },
        },
        effect = {
            kind = "register_write",
            name = "aesdeclast_crypto",
            target_register = "rip",
            role = "performed final aes decryption round by aesdeclast",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aesimc",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "aesimc_crypto",
            target_register = "rip",
            role = "generated inverse aes mix columns key by aesimc",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aeskeygenassist",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "round_constant" },
        },
        effect = {
            kind = "register_write",
            name = "aeskeygenassist_crypto",
            target_register = "rip",
            role = "assisted aes key generation by aeskeygenassist",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vaesenc",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "state" },
            { index = 3, role = "round_key" },
        },
        effect = {
            kind = "register_write",
            name = "vaesenc_crypto",
            target_register = "rip",
            role = "performed vector aes encryption round by vaesenc",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vaesenclast",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "state" },
            { index = 3, role = "round_key" },
        },
        effect = {
            kind = "register_write",
            name = "vaesenclast_crypto",
            target_register = "rip",
            role = "performed final vector aes encryption round by vaesenclast",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vaesdec",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "state" },
            { index = 3, role = "round_key" },
        },
        effect = {
            kind = "register_write",
            name = "vaesdec_crypto",
            target_register = "rip",
            role = "performed vector aes decryption round by vaesdec",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vaesdeclast",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "state" },
            { index = 3, role = "round_key" },
        },
        effect = {
            kind = "register_write",
            name = "vaesdeclast_crypto",
            target_register = "rip",
            role = "performed final vector aes decryption round by vaesdeclast",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pclmulqdq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "pclmulqdq_crypto",
            target_register = "rip",
            role = "performed carry-less quadword multiply by pclmulqdq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpclmulqdq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "vpclmulqdq_crypto",
            target_register = "rip",
            role = "performed vector carry-less quadword multiply by vpclmulqdq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sha1msg1",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "sha1msg1_crypto",
            target_register = "rip",
            role = "performed sha1 message schedule step by sha1msg1",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sha1msg2",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "sha1msg2_crypto",
            target_register = "rip",
            role = "performed sha1 message schedule step by sha1msg2",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sha1nexte",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "sha1nexte_crypto",
            target_register = "rip",
            role = "performed sha1 next-state step by sha1nexte",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sha1rnds4",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "function" },
        },
        effect = {
            kind = "register_write",
            name = "sha1rnds4_crypto",
            target_register = "rip",
            role = "performed four sha1 rounds by sha1rnds4",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sha256msg1",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "sha256msg1_crypto",
            target_register = "rip",
            role = "performed sha256 message schedule step by sha256msg1",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sha256msg2",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "sha256msg2_crypto",
            target_register = "rip",
            role = "performed sha256 message schedule step by sha256msg2",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sha256rnds2",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "sha256rnds2_crypto",
            target_register = "rip",
            role = "performed two sha256 rounds by sha256rnds2",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "gf2p8mulb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "gf2p8mulb_crypto",
            target_register = "rip",
            role = "multiplied packed bytes in gf2p8 by gf2p8mulb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "gf2p8affineqb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "matrix" },
            { index = 4, role = "immediate" },
        },
        effect = {
            kind = "register_write",
            name = "gf2p8affineqb_crypto",
            target_register = "rip",
            role = "applied gf2p8 affine transform by gf2p8affineqb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "gf2p8affineinvqb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "matrix" },
            { index = 4, role = "immediate" },
        },
        effect = {
            kind = "register_write",
            name = "gf2p8affineinvqb_crypto",
            target_register = "rip",
            role = "applied inverse gf2p8 affine transform by gf2p8affineinvqb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vgf2p8mulb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vgf2p8mulb_crypto",
            target_register = "rip",
            role = "multiplied packed bytes in gf2p8 by vgf2p8mulb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vgf2p8affineqb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "immediate" },
        },
        effect = {
            kind = "register_write",
            name = "vgf2p8affineqb_crypto",
            target_register = "rip",
            role = "applied vector gf2p8 affine transform by vgf2p8affineqb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vgf2p8affineinvqb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "immediate" },
        },
        effect = {
            kind = "register_write",
            name = "vgf2p8affineinvqb_crypto",
            target_register = "rip",
            role = "applied inverse vector gf2p8 affine transform by vgf2p8affineinvqb",
        },
    },

    -- Rounding / dot product / horizontal operations.

    {
        node_type = "instruction",
        mnemonic = "roundps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "mode" },
        },
        effect = {
            kind = "register_write",
            name = "roundps_vector_round",
            target_register = "rip",
            role = "rounded packed single-precision values by roundps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "roundpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "mode" },
        },
        effect = {
            kind = "register_write",
            name = "roundpd_vector_round",
            target_register = "rip",
            role = "rounded packed double-precision values by roundpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "roundss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "mode" },
        },
        effect = {
            kind = "register_write",
            name = "roundss_scalar_round",
            target_register = "rip",
            role = "rounded scalar single-precision value by roundss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "roundsd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "mode" },
        },
        effect = {
            kind = "register_write",
            name = "roundsd_scalar_round",
            target_register = "rip",
            role = "rounded scalar double-precision value by roundsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vroundps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "mode" },
        },
        effect = {
            kind = "register_write",
            name = "vroundps_vector_round",
            target_register = "rip",
            role = "rounded packed single-precision values by vroundps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vroundpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "mode" },
        },
        effect = {
            kind = "register_write",
            name = "vroundpd_vector_round",
            target_register = "rip",
            role = "rounded packed double-precision values by vroundpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vroundss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
            { index = 4, role = "mode" },
        },
        effect = {
            kind = "register_write",
            name = "vroundss_scalar_round",
            target_register = "rip",
            role = "rounded scalar single-precision value by vroundss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vroundsd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
            { index = 4, role = "mode" },
        },
        effect = {
            kind = "register_write",
            name = "vroundsd_scalar_round",
            target_register = "rip",
            role = "rounded scalar double-precision value by vroundsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "dpps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "dpps_vector_dot_product",
            target_register = "rip",
            role = "computed packed single-precision dot product by dpps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "dppd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "dppd_vector_dot_product",
            target_register = "rip",
            role = "computed packed double-precision dot product by dppd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vdpps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "vdpps_vector_dot_product",
            target_register = "rip",
            role = "computed packed single-precision dot product by vdpps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vdppd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "vdppd_vector_dot_product",
            target_register = "rip",
            role = "computed packed double-precision dot product by vdppd",
        },
    },

    -- Broadcast / gather / mask-load-store / vector insert-extract.

    {
        node_type = "instruction",
        mnemonic = "vbroadcastss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vbroadcastss_vector_broadcast",
            target_register = "rip",
            role = "broadcast scalar single-precision value by vbroadcastss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vbroadcastsd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vbroadcastsd_vector_broadcast",
            target_register = "rip",
            role = "broadcast scalar double-precision value by vbroadcastsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vbroadcastf128",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vbroadcastf128_vector_broadcast",
            target_register = "rip",
            role = "broadcast 128-bit floating vector by vbroadcastf128",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vbroadcasti128",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vbroadcasti128_vector_broadcast",
            target_register = "rip",
            role = "broadcast 128-bit integer vector by vbroadcasti128",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vgatherdps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "memory" },
            { index = 3, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "vgatherdps_vector_gather",
            target_register = "rip",
            role = "gathered packed single-precision values by vgatherdps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vgatherdpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "memory" },
            { index = 3, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "vgatherdpd_vector_gather",
            target_register = "rip",
            role = "gathered packed double-precision values by vgatherdpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vgatherqps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "memory" },
            { index = 3, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "vgatherqps_vector_gather",
            target_register = "rip",
            role = "gathered packed single-precision values with quadword indices by vgatherqps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vgatherqpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "memory" },
            { index = 3, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "vgatherqpd_vector_gather",
            target_register = "rip",
            role = "gathered packed double-precision values with quadword indices by vgatherqpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpgatherdd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "memory" },
            { index = 3, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "vpgatherdd_vector_gather",
            target_register = "rip",
            role = "gathered packed doubleword integers by vpgatherdd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpgatherdq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "memory" },
            { index = 3, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "vpgatherdq_vector_gather",
            target_register = "rip",
            role = "gathered packed quadword integers with doubleword indices by vpgatherdq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpgatherqd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "memory" },
            { index = 3, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "vpgatherqd_vector_gather",
            target_register = "rip",
            role = "gathered packed doubleword integers with quadword indices by vpgatherqd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpgatherqq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "memory" },
            { index = 3, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "vpgatherqq_vector_gather",
            target_register = "rip",
            role = "gathered packed quadword integers by vpgatherqq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmaskmovps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "mask" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vmaskmovps_vector_mask_move",
            target_register = "rip",
            role = "masked moved packed single-precision values by vmaskmovps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmaskmovpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "mask" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vmaskmovpd_vector_mask_move",
            target_register = "rip",
            role = "masked moved packed double-precision values by vmaskmovpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmaskmovd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "mask" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vpmaskmovd_vector_mask_move",
            target_register = "rip",
            role = "masked moved packed doubleword integers by vpmaskmovd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmaskmovq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "mask" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vpmaskmovq_vector_mask_move",
            target_register = "rip",
            role = "masked moved packed quadword integers by vpmaskmovq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vextractf128",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "index" },
        },
        effect = {
            kind = "register_write",
            name = "vextractf128_vector_extract",
            target_register = "rip",
            role = "extracted 128-bit floating lane by vextractf128",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vinsertf128",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
            { index = 4, role = "index" },
        },
        effect = {
            kind = "register_write",
            name = "vinsertf128_vector_insert",
            target_register = "rip",
            role = "inserted 128-bit floating lane by vinsertf128",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vextracti128",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "index" },
        },
        effect = {
            kind = "register_write",
            name = "vextracti128_vector_extract",
            target_register = "rip",
            role = "extracted 128-bit integer lane by vextracti128",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vinserti128",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
            { index = 4, role = "index" },
        },
        effect = {
            kind = "register_write",
            name = "vinserti128_vector_insert",
            target_register = "rip",
            role = "inserted 128-bit integer lane by vinserti128",
        },
    },


    -- AVX-512 / EVEX / mask-register visibility effects.
    -- Phase-one model: no k-register or zmm-register file yet, so most effects are exposed as RIP-side activity.

    -- Mask register moves and logic.

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

    -- AVX-512 compress / expand.

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

    -- AVX-512 scatter.

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

    -- AVX-512 conflict / ternary logic / leading-zero helpers.

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

    -- AVX-512 broadcast extensions.

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

    -- AVX-512 insert/extract wider lanes.

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

    -- AVX-512 compare / class / mask-test / convert / narrow / widen / permute visibility effects.
    -- Phase-one model: no k-register or zmm-register file yet, so most vector/mask effects are exposed as RIP-side activity.

    -- AVX-512 packed integer compare-to-mask.

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

    -- AVX-512 floating-point class tests.

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

    -- AVX-512 packed integer mask tests.

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

    -- AVX-512 floating/integer conversion visibility.

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

    -- AVX-512 integer narrowing / widening move visibility.

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

    -- AVX-512 mask extraction from vector lanes.

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

    -- AVX-512 permutation.

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


    -- AVX-512 VNNI / BF16 / FP16 / AMX visibility effects.
    -- Phase-one model: no vector, mask, or tile register file yet, so most effects are exposed as RIP-side activity.

    -- AVX-512 VNNI dot-product / neural-network integer operations.

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

    -- AVX-512 BF16 conversion.

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

    -- AVX-512 FP16 / half-precision arithmetic.

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
        mnemonic = "vmulph",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vmulph_vector_fp16_arithmetic",
            target_register = "rip",
            role = "multiplied packed half-precision values by vmulph",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmulsh",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vmulsh_scalar_fp16_arithmetic",
            target_register = "rip",
            role = "multiplied scalar half-precision values by vmulsh",
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
        mnemonic = "vmaxph",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vmaxph_vector_fp16_select",
            target_register = "rip",
            role = "selected packed half-precision maximum values by vmaxph",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vmaxsh",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vmaxsh_scalar_fp16_select",
            target_register = "rip",
            role = "selected scalar half-precision maximum value by vmaxsh",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vminph",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vminph_vector_fp16_select",
            target_register = "rip",
            role = "selected packed half-precision minimum values by vminph",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vminsh",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vminsh_scalar_fp16_select",
            target_register = "rip",
            role = "selected scalar half-precision minimum value by vminsh",
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

    -- AVX-512 FP16 conversion.

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

    -- AMX tile configuration / release.

    {
        node_type = "instruction",
        mnemonic = "ldtilecfg",
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

    {
        node_type = "instruction",
        mnemonic = "sttilecfg",
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

    {
        node_type = "instruction",
        mnemonic = "tilerelease",
        operands = {},
        effect = {
            kind = "register_write",
            name = "tilerelease_updates_tile_state",
            target_register = "rip",
            role = "released AMX tile state by tilerelease",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "tilezero",
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

    -- AMX tile load/store.

    {
        node_type = "instruction",
        mnemonic = "tileloadd",
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

    {
        node_type = "instruction",
        mnemonic = "tileloaddt1",
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

    {
        node_type = "instruction",
        mnemonic = "tilestored",
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

    {
        node_type = "instruction",
        mnemonic = "tileloadd64",
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

    {
        node_type = "instruction",
        mnemonic = "tilestored64",
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

    -- AMX tile compute.

    {
        node_type = "instruction",
        mnemonic = "tdpbssd",
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

    {
        node_type = "instruction",
        mnemonic = "tdpbsud",
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

    {
        node_type = "instruction",
        mnemonic = "tdpbusd",
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

    {
        node_type = "instruction",
        mnemonic = "tdpbuud",
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

    {
        node_type = "instruction",
        mnemonic = "tdpbf16ps",
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

    {
        node_type = "instruction",
        mnemonic = "tdpfp16ps",
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

    -- x86_64 security / crypto / bit / vendor-extension visibility effects.
    -- Phase-one model: most feature-specific state is exposed as RIP-side activity.

    -- CET / indirect branch tracking.

    {
        node_type = "instruction",
        mnemonic = "endbr32",
        operands = {},
        effect = {
            kind = "register_write",
            name = "endbr32_cet_branch_target",
            target_register = "rip",
            role = "marked valid 32-bit indirect branch target by endbr32",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "endbr64",
        operands = {},
        effect = {
            kind = "register_write",
            name = "endbr64_cet_branch_target",
            target_register = "rip",
            role = "marked valid 64-bit indirect branch target by endbr64",
        },
    },

    -- CET shadow-stack helpers.

    {
        node_type = "instruction",
        mnemonic = "rdsspd",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdsspd_writes_gpr",
            target_operand = 1,
            role = "written with 32-bit shadow stack pointer by rdsspd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rdsspq",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdsspq_writes_gpr",
            target_operand = 1,
            role = "written with 64-bit shadow stack pointer by rdsspq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "incsspd",
        operands = {
            { index = 1, role = "count" },
        },
        effect = {
            kind = "register_write",
            name = "incsspd_updates_shadow_stack",
            target_register = "rip",
            role = "incremented 32-bit shadow stack pointer by incsspd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "incsspq",
        operands = {
            { index = 1, role = "count" },
        },
        effect = {
            kind = "register_write",
            name = "incsspq_updates_shadow_stack",
            target_register = "rip",
            role = "incremented 64-bit shadow stack pointer by incsspq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rstorssp",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "rstorssp_updates_shadow_stack",
            target_register = "rip",
            role = "restored shadow stack pointer by rstorssp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "saveprevssp",
        operands = {},
        effect = {
            kind = "register_write",
            name = "saveprevssp_updates_shadow_stack",
            target_register = "rip",
            role = "saved previous shadow stack pointer by saveprevssp",
        },
    },

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
    },

    {
        node_type = "instruction",
        mnemonic = "clrssbsy",
        operands = {
            { index = 1, role = "token" },
        },
        effect = {
            kind = "register_write",
            name = "clrssbsy_updates_shadow_stack",
            target_register = "rip",
            role = "cleared shadow stack busy token by clrssbsy",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "wrssd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "wrssd_updates_shadow_stack",
            target_register = "rip",
            role = "wrote 32-bit shadow stack memory by wrssd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "wrssq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "wrssq_updates_shadow_stack",
            target_register = "rip",
            role = "wrote 64-bit shadow stack memory by wrssq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "wrussd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "wrussd_updates_shadow_stack",
            target_register = "rip",
            role = "wrote 32-bit user shadow stack memory by wrussd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "wrussq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "wrussq_updates_shadow_stack",
            target_register = "rip",
            role = "wrote 64-bit user shadow stack memory by wrussq",
        },
    },

    -- User interrupt / low-latency interrupt helpers.

    {
        node_type = "instruction",
        mnemonic = "senduipi",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "senduipi_updates_user_interrupt_state",
            target_register = "rip",
            role = "sent user interprocessor interrupt by senduipi",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "uiret",
        operands = {},
        effect = {
            kind = "register_write",
            name = "uiret_updates_rip",
            target_register = "rip",
            role = "returned from user interrupt by uiret",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "clui",
        operands = {},
        effect = {
            kind = "register_write",
            name = "clui_updates_user_interrupt_state",
            target_register = "rflags",
            role = "cleared user interrupt flag by clui",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "stui",
        operands = {},
        effect = {
            kind = "register_write",
            name = "stui_updates_user_interrupt_state",
            target_register = "rflags",
            role = "set user interrupt flag by stui",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "testui",
        operands = {},
        effect = {
            kind = "register_write",
            name = "testui_updates_rflags",
            target_register = "rflags",
            role = "tested user interrupt flag by testui",
        },
    },

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
    },

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
    },

    {
        node_type = "instruction",
        mnemonic = "enqcmd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "enqcmd_device_enqueue",
            target_register = "rflags",
            role = "updated by device enqueue command enqcmd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "enqcmds",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "enqcmds_device_enqueue",
            target_register = "rflags",
            role = "updated by supervisor device enqueue command enqcmds",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "wbnoinvd",
        operands = {},
        effect = {
            kind = "register_write",
            name = "wbnoinvd_cache_writeback",
            target_register = "rip",
            role = "wrote back caches without invalidation by wbnoinvd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "clzero",
        operands = {},
        effect = {
            kind = "register_write",
            name = "clzero_cache_zero",
            target_register = "rip",
            role = "zeroed cache line by clzero",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "monitorx",
        operands = {},
        effect = {
            kind = "register_write",
            name = "monitorx_updates_monitor_state",
            target_register = "rip",
            role = "armed extended monitor address by monitorx",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "mwaitx",
        operands = {},
        effect = {
            kind = "register_write",
            name = "mwaitx_updates_wait_state",
            target_register = "rip",
            role = "entered extended monitor wait state by mwaitx",
        },
    },

    -- TSX load tracking.

    {
        node_type = "instruction",
        mnemonic = "xsusldtrk",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xsusldtrk_updates_transaction_state",
            target_register = "rip",
            role = "suspended transactional load tracking by xsusldtrk",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xresldtrk",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xresldtrk_updates_transaction_state",
            target_register = "rip",
            role = "resumed transactional load tracking by xresldtrk",
        },
    },

    -- Key Locker.

    {
        node_type = "instruction",
        mnemonic = "loadiwkey",
        operands = {
            { index = 1, role = "control" },
            { index = 2, role = "key_source" },
        },
        effect = {
            kind = "register_write",
            name = "loadiwkey_updates_key_locker_state",
            target_register = "rip",
            role = "loaded internal wrapping key by loadiwkey",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "encodekey128",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "encodekey128_key_locker",
            target_register = "rip",
            role = "encoded 128-bit aes key handle by encodekey128",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "encodekey256",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "encodekey256_key_locker",
            target_register = "rip",
            role = "encoded 256-bit aes key handle by encodekey256",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aesenc128kl",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "key_handle" },
        },
        effect = {
            kind = "register_write",
            name = "aesenc128kl_key_locker",
            target_register = "rip",
            role = "encrypted block using 128-bit key locker handle by aesenc128kl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aesdec128kl",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "key_handle" },
        },
        effect = {
            kind = "register_write",
            name = "aesdec128kl_key_locker",
            target_register = "rip",
            role = "decrypted block using 128-bit key locker handle by aesdec128kl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aesenc256kl",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "key_handle" },
        },
        effect = {
            kind = "register_write",
            name = "aesenc256kl_key_locker",
            target_register = "rip",
            role = "encrypted block using 256-bit key locker handle by aesenc256kl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aesdec256kl",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "key_handle" },
        },
        effect = {
            kind = "register_write",
            name = "aesdec256kl_key_locker",
            target_register = "rip",
            role = "decrypted block using 256-bit key locker handle by aesdec256kl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aesencwide128kl",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "key_handle" },
        },
        effect = {
            kind = "register_write",
            name = "aesencwide128kl_key_locker",
            target_register = "rip",
            role = "encrypted wide block using 128-bit key locker handle by aesencwide128kl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aesdecwide128kl",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "key_handle" },
        },
        effect = {
            kind = "register_write",
            name = "aesdecwide128kl_key_locker",
            target_register = "rip",
            role = "decrypted wide block using 128-bit key locker handle by aesdecwide128kl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aesencwide256kl",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "key_handle" },
        },
        effect = {
            kind = "register_write",
            name = "aesencwide256kl_key_locker",
            target_register = "rip",
            role = "encrypted wide block using 256-bit key locker handle by aesencwide256kl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "aesdecwide256kl",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "key_handle" },
        },
        effect = {
            kind = "register_write",
            name = "aesdecwide256kl_key_locker",
            target_register = "rip",
            role = "decrypted wide block using 256-bit key locker handle by aesdecwide256kl",
        },
    },

    -- SM3 / SM4 crypto extensions.

    {
        node_type = "instruction",
        mnemonic = "vsm3msg1",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vsm3msg1_crypto",
            target_register = "rip",
            role = "performed sm3 message schedule step by vsm3msg1",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vsm3msg2",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vsm3msg2_crypto",
            target_register = "rip",
            role = "performed sm3 message schedule step by vsm3msg2",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vsm3rnds2",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "round_selector" },
        },
        effect = {
            kind = "register_write",
            name = "vsm3rnds2_crypto",
            target_register = "rip",
            role = "performed two sm3 rounds by vsm3rnds2",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vsm4key4",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vsm4key4_crypto",
            target_register = "rip",
            role = "performed four sm4 key schedule rounds by vsm4key4",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vsm4rnds4",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vsm4rnds4_crypto",
            target_register = "rip",
            role = "performed four sm4 encryption rounds by vsm4rnds4",
        },
    },

    -- AVX-512 IFMA / integer fused multiply-add.

    {
        node_type = "instruction",
        mnemonic = "vpmadd52luq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vpmadd52luq_vector_ifma",
            target_register = "rip",
            role = "multiply-added low unsigned 52-bit integers by vpmadd52luq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmadd52huq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vpmadd52huq_vector_ifma",
            target_register = "rip",
            role = "multiply-added high unsigned 52-bit integers by vpmadd52huq",
        },
    },

    -- AVX-512 BITALG / VPOPCNT / VP2INTERSECT.

    {
        node_type = "instruction",
        mnemonic = "vpopcntb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vpopcntb_vector_count",
            target_register = "rip",
            role = "counted set bits in packed bytes by vpopcntb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpopcntw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vpopcntw_vector_count",
            target_register = "rip",
            role = "counted set bits in packed words by vpopcntw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpopcntd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vpopcntd_vector_count",
            target_register = "rip",
            role = "counted set bits in packed doublewords by vpopcntd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpopcntq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vpopcntq_vector_count",
            target_register = "rip",
            role = "counted set bits in packed quadwords by vpopcntq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpshufbitqmb",
        operands = {
            { index = 1, role = "mask_destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vpshufbitqmb_vector_bit_shuffle",
            target_register = "rip",
            role = "shuffled bits from packed quadwords into mask by vpshufbitqmb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmultishiftqb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "indices" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vpmultishiftqb_vector_multishift",
            target_register = "rip",
            role = "multi-shifted packed quadword bytes by vpmultishiftqb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vp2intersectd",
        operands = {
            { index = 1, role = "mask_destination_a" },
            { index = 2, role = "mask_destination_b" },
            { index = 3, role = "left" },
            { index = 4, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vp2intersectd_vector_intersect",
            target_register = "rip",
            role = "computed packed doubleword intersection masks by vp2intersectd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vp2intersectq",
        operands = {
            { index = 1, role = "mask_destination_a" },
            { index = 2, role = "mask_destination_b" },
            { index = 3, role = "left" },
            { index = 4, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vp2intersectq_vector_intersect",
            target_register = "rip",
            role = "computed packed quadword intersection masks by vp2intersectq",
        },
    },

    -- MPX bounds instructions.

    {
        node_type = "instruction",
        mnemonic = "bndmk",
        operands = {
            { index = 1, role = "bounds_destination" },
            { index = 2, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "bndmk_updates_bounds_state",
            target_register = "rip",
            role = "made bounds register from address by bndmk",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "bndcl",
        operands = {
            { index = 1, role = "bounds" },
            { index = 2, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "bndcl_checks_bounds",
            target_register = "rip",
            role = "checked lower bound by bndcl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "bndcu",
        operands = {
            { index = 1, role = "bounds" },
            { index = 2, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "bndcu_checks_bounds",
            target_register = "rip",
            role = "checked upper bound by bndcu",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "bndcn",
        operands = {
            { index = 1, role = "bounds" },
            { index = 2, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "bndcn_checks_bounds",
            target_register = "rip",
            role = "checked upper bound with complement by bndcn",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "bndmov",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "bndmov_updates_bounds_state",
            target_register = "rip",
            role = "moved bounds register state by bndmov",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "bndldx",
        operands = {
            { index = 1, role = "bounds_destination" },
            { index = 2, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "bndldx_updates_bounds_state",
            target_register = "rip",
            role = "loaded bounds using address translation by bndldx",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "bndstx",
        operands = {
            { index = 1, role = "address" },
            { index = 2, role = "bounds_source" },
        },
        effect = {
            kind = "register_write",
            name = "bndstx_updates_bounds_state",
            target_register = "rip",
            role = "stored bounds using address translation by bndstx",
        },
    },

    -- AMD TBM-style bit manipulation leftovers.
    -- These write a GPR destination and usually update flags.

    {
        node_type = "instruction",
        mnemonic = "blcfill",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "blcfill_writes_destination",
            target_operand = 1,
            role = "written with lowest clear bit filled by blcfill",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "blcfill",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "blcfill_updates_rflags",
            target_register = "rflags",
            role = "updated by blcfill",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "blci",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "blci_writes_destination",
            target_operand = 1,
            role = "written with lowest clear bit isolated by blci",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "blci",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "blci_updates_rflags",
            target_register = "rflags",
            role = "updated by blci",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "blcic",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "blcic_writes_destination",
            target_operand = 1,
            role = "written with inverted lowest clear bit isolated by blcic",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "blcmsk",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "blcmsk_writes_destination",
            target_operand = 1,
            role = "written with mask from lowest clear bit by blcmsk",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "blcs",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "blcs_writes_destination",
            target_operand = 1,
            role = "written with lowest clear bit set by blcs",
        },
    },

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
    },

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
    },

    {
        node_type = "instruction",
        mnemonic = "t1mskc",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "t1mskc_writes_destination",
            target_operand = 1,
            role = "written with trailing-one mask complement by t1mskc",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "tzmsk",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "tzmsk_writes_destination",
            target_operand = 1,
            role = "written with trailing-zero mask by tzmsk",
        },
    },

    -- AMD / x86_64 virtualization and platform helpers.

    {
        node_type = "instruction",
        mnemonic = "vmrun",
        operands = {
            { index = 1, role = "vmcb_address" },
        },
        effect = {
            kind = "register_write",
            name = "vmrun_updates_rip",
            target_register = "rip",
            role = "entered virtual machine by vmrun",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "invlpga",
        operands = {
            { index = 1, role = "address" },
            { index = 2, role = "asid" },
        },
        effect = {
            kind = "register_write",
            name = "invlpga_updates_translation_state",
            target_register = "rip",
            role = "invalidated guest TLB entry by invlpga",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rdpru",
        operands = {},
        effect = {
            kind = "register_write",
            name = "rdpru_writes_rax",
            target_register = "rax",
            role = "written with processor register value low by rdpru",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rdpru",
        operands = {},
        effect = {
            kind = "register_write",
            name = "rdpru_writes_rdx",
            target_register = "rdx",
            role = "written with processor register value high by rdpru",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pvalidate",
        operands = {},
        effect = {
            kind = "register_write",
            name = "pvalidate_updates_rflags",
            target_register = "rflags",
            role = "updated by page validation pvalidate",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rmpadjust",
        operands = {},
        effect = {
            kind = "register_write",
            name = "rmpadjust_updates_platform_state",
            target_register = "rip",
            role = "adjusted reverse map table state by rmpadjust",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rmpupdate",
        operands = {},
        effect = {
            kind = "register_write",
            name = "rmpupdate_updates_platform_state",
            target_register = "rip",
            role = "updated reverse map table state by rmpupdate",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "psmash",
        operands = {},
        effect = {
            kind = "register_write",
            name = "psmash_updates_platform_state",
            target_register = "rip",
            role = "split secure nested paging mapping by psmash",
        },
    },

    -- TDX / SEAM-style platform transition helpers.

    {
        node_type = "instruction",
        mnemonic = "tdcall",
        operands = {},
        effect = {
            kind = "register_write",
            name = "tdcall_updates_rip",
            target_register = "rip",
            role = "called trusted domain module by tdcall",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "seamcall",
        operands = {},
        effect = {
            kind = "register_write",
            name = "seamcall_updates_rip",
            target_register = "rip",
            role = "called seam module by seamcall",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "seamret",
        operands = {},
        effect = {
            kind = "register_write",
            name = "seamret_updates_rip",
            target_register = "rip",
            role = "returned from seam module by seamret",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "seamops",
        operands = {},
        effect = {
            kind = "register_write",
            name = "seamops_updates_platform_state",
            target_register = "rip",
            role = "performed seam operation by seamops",
        },
    },


    -- AVX-512 special floating-point math / rotate / variable-shift / accelerator visibility effects.
    -- Phase-one model: no vector register file yet, so vector-only effects are exposed as RIP-side activity.

    -- AVX-512 range / reduction helpers.

    {
        node_type = "instruction",
        mnemonic = "vrangeps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vrangeps_vector_range",
            target_register = "rip",
            role = "computed packed single-precision range values by vrangeps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrangepd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vrangepd_vector_range",
            target_register = "rip",
            role = "computed packed double-precision range values by vrangepd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrangess",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vrangess_scalar_range",
            target_register = "rip",
            role = "computed scalar single-precision range value by vrangess",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrangesd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vrangesd_scalar_range",
            target_register = "rip",
            role = "computed scalar double-precision range value by vrangesd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vreduceps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vreduceps_vector_reduce",
            target_register = "rip",
            role = "reduced packed single-precision values by vreduceps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vreducepd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vreducepd_vector_reduce",
            target_register = "rip",
            role = "reduced packed double-precision values by vreducepd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vreducess",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
            { index = 4, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vreducess_scalar_reduce",
            target_register = "rip",
            role = "reduced scalar single-precision value by vreducess",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vreducesd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
            { index = 4, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vreducesd_scalar_reduce",
            target_register = "rip",
            role = "reduced scalar double-precision value by vreducesd",
        },
    },

    -- AVX-512 exponent / mantissa helpers.

    {
        node_type = "instruction",
        mnemonic = "vgetexpps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vgetexpps_vector_extract_exponent",
            target_register = "rip",
            role = "extracted packed single-precision exponents by vgetexpps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vgetexppd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vgetexppd_vector_extract_exponent",
            target_register = "rip",
            role = "extracted packed double-precision exponents by vgetexppd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vgetexpss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vgetexpss_scalar_extract_exponent",
            target_register = "rip",
            role = "extracted scalar single-precision exponent by vgetexpss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vgetexpsd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vgetexpsd_scalar_extract_exponent",
            target_register = "rip",
            role = "extracted scalar double-precision exponent by vgetexpsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vgetmantps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vgetmantps_vector_extract_mantissa",
            target_register = "rip",
            role = "extracted packed single-precision mantissas by vgetmantps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vgetmantpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vgetmantpd_vector_extract_mantissa",
            target_register = "rip",
            role = "extracted packed double-precision mantissas by vgetmantpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vgetmantss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
            { index = 4, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vgetmantss_scalar_extract_mantissa",
            target_register = "rip",
            role = "extracted scalar single-precision mantissa by vgetmantss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vgetmantsd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
            { index = 4, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vgetmantsd_scalar_extract_mantissa",
            target_register = "rip",
            role = "extracted scalar double-precision mantissa by vgetmantsd",
        },
    },

    -- AVX-512 fixup immediate helpers.

    {
        node_type = "instruction",
        mnemonic = "vfixupimmps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vfixupimmps_vector_fixup",
            target_register = "rip",
            role = "fixed up packed single-precision special values by vfixupimmps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfixupimmpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vfixupimmpd_vector_fixup",
            target_register = "rip",
            role = "fixed up packed double-precision special values by vfixupimmpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfixupimmss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vfixupimmss_scalar_fixup",
            target_register = "rip",
            role = "fixed up scalar single-precision special value by vfixupimmss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfixupimmsd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vfixupimmsd_scalar_fixup",
            target_register = "rip",
            role = "fixed up scalar double-precision special value by vfixupimmsd",
        },
    },

    -- AVX-512 reciprocal / reciprocal-square-root approximation helpers.

    {
        node_type = "instruction",
        mnemonic = "vrcp14ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrcp14ps_vector_reciprocal",
            target_register = "rip",
            role = "computed approximate packed single-precision reciprocals by vrcp14ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrcp14pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrcp14pd_vector_reciprocal",
            target_register = "rip",
            role = "computed approximate packed double-precision reciprocals by vrcp14pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrcp14ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrcp14ss_scalar_reciprocal",
            target_register = "rip",
            role = "computed approximate scalar single-precision reciprocal by vrcp14ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrcp14sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrcp14sd_scalar_reciprocal",
            target_register = "rip",
            role = "computed approximate scalar double-precision reciprocal by vrcp14sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrsqrt14ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrsqrt14ps_vector_reciprocal_sqrt",
            target_register = "rip",
            role = "computed approximate packed single-precision reciprocal square roots by vrsqrt14ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrsqrt14pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrsqrt14pd_vector_reciprocal_sqrt",
            target_register = "rip",
            role = "computed approximate packed double-precision reciprocal square roots by vrsqrt14pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrsqrt14ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrsqrt14ss_scalar_reciprocal_sqrt",
            target_register = "rip",
            role = "computed approximate scalar single-precision reciprocal square root by vrsqrt14ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrsqrt14sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrsqrt14sd_scalar_reciprocal_sqrt",
            target_register = "rip",
            role = "computed approximate scalar double-precision reciprocal square root by vrsqrt14sd",
        },
    },

    -- AVX-512ER approximate math helpers.

    {
        node_type = "instruction",
        mnemonic = "vrcp28ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrcp28ps_vector_reciprocal",
            target_register = "rip",
            role = "computed high-precision approximate packed single-precision reciprocals by vrcp28ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrcp28pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrcp28pd_vector_reciprocal",
            target_register = "rip",
            role = "computed high-precision approximate packed double-precision reciprocals by vrcp28pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrcp28ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrcp28ss_scalar_reciprocal",
            target_register = "rip",
            role = "computed high-precision approximate scalar single-precision reciprocal by vrcp28ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrcp28sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrcp28sd_scalar_reciprocal",
            target_register = "rip",
            role = "computed high-precision approximate scalar double-precision reciprocal by vrcp28sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrsqrt28ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrsqrt28ps_vector_reciprocal_sqrt",
            target_register = "rip",
            role = "computed high-precision approximate packed single-precision reciprocal square roots by vrsqrt28ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrsqrt28pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrsqrt28pd_vector_reciprocal_sqrt",
            target_register = "rip",
            role = "computed high-precision approximate packed double-precision reciprocal square roots by vrsqrt28pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrsqrt28ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrsqrt28ss_scalar_reciprocal_sqrt",
            target_register = "rip",
            role = "computed high-precision approximate scalar single-precision reciprocal square root by vrsqrt28ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vrsqrt28sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vrsqrt28sd_scalar_reciprocal_sqrt",
            target_register = "rip",
            role = "computed high-precision approximate scalar double-precision reciprocal square root by vrsqrt28sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vexp2ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vexp2ps_vector_exponential",
            target_register = "rip",
            role = "computed approximate packed single-precision powers of two by vexp2ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vexp2pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vexp2pd_vector_exponential",
            target_register = "rip",
            role = "computed approximate packed double-precision powers of two by vexp2pd",
        },
    },

    -- AVX-512 scale floating-point values.

    {
        node_type = "instruction",
        mnemonic = "vscalefps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "scale" },
        },
        effect = {
            kind = "register_write",
            name = "vscalefps_vector_scale",
            target_register = "rip",
            role = "scaled packed single-precision values by powers of two by vscalefps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vscalefpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "scale" },
        },
        effect = {
            kind = "register_write",
            name = "vscalefpd_vector_scale",
            target_register = "rip",
            role = "scaled packed double-precision values by powers of two by vscalefpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vscalefss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "scale" },
        },
        effect = {
            kind = "register_write",
            name = "vscalefss_scalar_scale",
            target_register = "rip",
            role = "scaled scalar single-precision value by power of two by vscalefss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vscalefsd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "scale" },
        },
        effect = {
            kind = "register_write",
            name = "vscalefsd_scalar_scale",
            target_register = "rip",
            role = "scaled scalar double-precision value by power of two by vscalefsd",
        },
    },

    -- AVX-512 integer rotates.

    {
        node_type = "instruction",
        mnemonic = "vprold",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "count" },
        },
        effect = {
            kind = "register_write",
            name = "vprold_vector_rotate",
            target_register = "rip",
            role = "rotated packed doublewords left by vprold",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprolq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "count" },
        },
        effect = {
            kind = "register_write",
            name = "vprolq_vector_rotate",
            target_register = "rip",
            role = "rotated packed quadwords left by vprolq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprord",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "count" },
        },
        effect = {
            kind = "register_write",
            name = "vprord_vector_rotate",
            target_register = "rip",
            role = "rotated packed doublewords right by vprord",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprorq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "count" },
        },
        effect = {
            kind = "register_write",
            name = "vprorq_vector_rotate",
            target_register = "rip",
            role = "rotated packed quadwords right by vprorq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprolvd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vprolvd_vector_variable_rotate",
            target_register = "rip",
            role = "rotated packed doublewords left by variable counts by vprolvd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprolvq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vprolvq_vector_variable_rotate",
            target_register = "rip",
            role = "rotated packed quadwords left by variable counts by vprolvq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprorvd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vprorvd_vector_variable_rotate",
            target_register = "rip",
            role = "rotated packed doublewords right by variable counts by vprorvd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprorvq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vprorvq_vector_variable_rotate",
            target_register = "rip",
            role = "rotated packed quadwords right by variable counts by vprorvq",
        },
    },

    -- AVX-512 variable vector shifts.

    {
        node_type = "instruction",
        mnemonic = "vpsllvw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vpsllvw_vector_variable_shift",
            target_register = "rip",
            role = "shifted packed words left by variable counts by vpsllvw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsllvd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vpsllvd_vector_variable_shift",
            target_register = "rip",
            role = "shifted packed doublewords left by variable counts by vpsllvd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsllvq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vpsllvq_vector_variable_shift",
            target_register = "rip",
            role = "shifted packed quadwords left by variable counts by vpsllvq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsrlvw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vpsrlvw_vector_variable_shift",
            target_register = "rip",
            role = "logically shifted packed words right by variable counts by vpsrlvw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsrlvd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vpsrlvd_vector_variable_shift",
            target_register = "rip",
            role = "logically shifted packed doublewords right by variable counts by vpsrlvd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsrlvq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vpsrlvq_vector_variable_shift",
            target_register = "rip",
            role = "logically shifted packed quadwords right by variable counts by vpsrlvq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsravw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vpsravw_vector_variable_shift",
            target_register = "rip",
            role = "arithmetically shifted packed words right by variable counts by vpsravw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsravd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vpsravd_vector_variable_shift",
            target_register = "rip",
            role = "arithmetically shifted packed doublewords right by variable counts by vpsravd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpsravq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vpsravq_vector_variable_shift",
            target_register = "rip",
            role = "arithmetically shifted packed quadwords right by variable counts by vpsravq",
        },
    },

    -- Rare AVX-512 accelerator helpers.

    {
        node_type = "instruction",
        mnemonic = "v4fmaddps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source_group" },
            { index = 3, role = "memory" },
        },
        effect = {
            kind = "register_write",
            name = "v4fmaddps_vector_accelerator",
            target_register = "rip",
            role = "performed four packed single-precision fused multiply-adds by v4fmaddps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "v4fnmaddps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source_group" },
            { index = 3, role = "memory" },
        },
        effect = {
            kind = "register_write",
            name = "v4fnmaddps_vector_accelerator",
            target_register = "rip",
            role = "performed four negative packed single-precision fused multiply-adds by v4fnmaddps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vp4dpwssd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source_group" },
            { index = 3, role = "memory" },
        },
        effect = {
            kind = "register_write",
            name = "vp4dpwssd_vector_accelerator",
            target_register = "rip",
            role = "performed four signed word dot-products into doublewords by vp4dpwssd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vp4dpwssds",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source_group" },
            { index = 3, role = "memory" },
        },
        effect = {
            kind = "register_write",
            name = "vp4dpwssds_vector_accelerator",
            target_register = "rip",
            role = "performed four saturating signed word dot-products into doublewords by vp4dpwssds",
        },
    },


    -- SSE / SSE2 / SSE3 / SSSE3 / SSE4 legacy SIMD utility visibility effects.
    -- Phase-one model: no vector register file yet, so most vector-only effects are exposed as RIP-side activity.

    -- SSE3 floating horizontal / add-sub helpers.

    {
        node_type = "instruction",
        mnemonic = "addsubps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "addsubps_vector_arithmetic",
            target_register = "rip",
            role = "alternating added and subtracted packed single-precision values by addsubps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "addsubpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "addsubpd_vector_arithmetic",
            target_register = "rip",
            role = "alternating added and subtracted packed double-precision values by addsubpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "haddps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "haddps_vector_horizontal",
            target_register = "rip",
            role = "horizontally added packed single-precision values by haddps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "haddpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "haddpd_vector_horizontal",
            target_register = "rip",
            role = "horizontally added packed double-precision values by haddpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "hsubps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "hsubps_vector_horizontal",
            target_register = "rip",
            role = "horizontally subtracted packed single-precision values by hsubps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "hsubpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "hsubpd_vector_horizontal",
            target_register = "rip",
            role = "horizontally subtracted packed double-precision values by hsubpd",
        },
    },

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
    },

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
    },

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
    },

    {
        node_type = "instruction",
        mnemonic = "lddqu",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "lddqu_vector_load",
            target_register = "rip",
            role = "loaded unaligned double-quadword integer data by lddqu",
        },
    },

    -- SSE4 blend helpers.

    {
        node_type = "instruction",
        mnemonic = "blendps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "blendps_vector_blend",
            target_register = "rip",
            role = "blended packed single-precision values by blendps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "blendpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "blendpd_vector_blend",
            target_register = "rip",
            role = "blended packed double-precision values by blendpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "blendvps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "blendvps_vector_blend",
            target_register = "rip",
            role = "variable-blended packed single-precision values by blendvps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "blendvpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "blendvpd_vector_blend",
            target_register = "rip",
            role = "variable-blended packed double-precision values by blendvpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pblendw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "pblendw_vector_blend",
            target_register = "rip",
            role = "blended packed words by pblendw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pblendvb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pblendvb_vector_blend",
            target_register = "rip",
            role = "variable-blended packed bytes by pblendvb",
        },
    },

    -- SSE4 insert / extract helpers.

    {
        node_type = "instruction",
        mnemonic = "extractps",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "index" },
        },
        effect = {
            kind = "register_write",
            name = "extractps_writes_gpr",
            target_operand = 1,
            role = "written with extracted single-precision lane by extractps",
        },
    },

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
    },

    {
        node_type = "instruction",
        mnemonic = "pinsrb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "index" },
        },
        effect = {
            kind = "register_write",
            name = "pinsrb_vector_insert",
            target_register = "rip",
            role = "inserted byte into packed integer vector by pinsrb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pinsrd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "index" },
        },
        effect = {
            kind = "register_write",
            name = "pinsrd_vector_insert",
            target_register = "rip",
            role = "inserted doubleword into packed integer vector by pinsrd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pinsrq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "index" },
        },
        effect = {
            kind = "register_write",
            name = "pinsrq_vector_insert",
            target_register = "rip",
            role = "inserted quadword into packed integer vector by pinsrq",
        },
    },

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
    },

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
    },

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
    },

    -- SSE4 packed min/max extended forms.

    {
        node_type = "instruction",
        mnemonic = "pminsb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pminsb_vector_minmax",
            target_register = "rip",
            role = "selected packed signed byte minimums by pminsb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pminsd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pminsd_vector_minmax",
            target_register = "rip",
            role = "selected packed signed doubleword minimums by pminsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pminuw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pminuw_vector_minmax",
            target_register = "rip",
            role = "selected packed unsigned word minimums by pminuw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pminud",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pminud_vector_minmax",
            target_register = "rip",
            role = "selected packed unsigned doubleword minimums by pminud",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmaxsb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmaxsb_vector_minmax",
            target_register = "rip",
            role = "selected packed signed byte maximums by pmaxsb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmaxsd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmaxsd_vector_minmax",
            target_register = "rip",
            role = "selected packed signed doubleword maximums by pmaxsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmaxuw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmaxuw_vector_minmax",
            target_register = "rip",
            role = "selected packed unsigned word maximums by pmaxuw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmaxud",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmaxud_vector_minmax",
            target_register = "rip",
            role = "selected packed unsigned doubleword maximums by pmaxud",
        },
    },

    -- SSE4 packed sign/zero extension helpers.

    {
        node_type = "instruction",
        mnemonic = "pmovsxbw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmovsxbw_vector_extend",
            target_register = "rip",
            role = "sign-extended packed bytes to words by pmovsxbw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovsxbd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmovsxbd_vector_extend",
            target_register = "rip",
            role = "sign-extended packed bytes to doublewords by pmovsxbd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovsxbq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmovsxbq_vector_extend",
            target_register = "rip",
            role = "sign-extended packed bytes to quadwords by pmovsxbq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovsxwd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmovsxwd_vector_extend",
            target_register = "rip",
            role = "sign-extended packed words to doublewords by pmovsxwd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovsxwq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmovsxwq_vector_extend",
            target_register = "rip",
            role = "sign-extended packed words to quadwords by pmovsxwq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovsxdq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmovsxdq_vector_extend",
            target_register = "rip",
            role = "sign-extended packed doublewords to quadwords by pmovsxdq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovzxbw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmovzxbw_vector_extend",
            target_register = "rip",
            role = "zero-extended packed bytes to words by pmovzxbw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovzxbd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmovzxbd_vector_extend",
            target_register = "rip",
            role = "zero-extended packed bytes to doublewords by pmovzxbd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovzxbq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmovzxbq_vector_extend",
            target_register = "rip",
            role = "zero-extended packed bytes to quadwords by pmovzxbq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovzxwd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmovzxwd_vector_extend",
            target_register = "rip",
            role = "zero-extended packed words to doublewords by pmovzxwd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovzxwq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmovzxwq_vector_extend",
            target_register = "rip",
            role = "zero-extended packed words to quadwords by pmovzxwq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmovzxdq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmovzxdq_vector_extend",
            target_register = "rip",
            role = "zero-extended packed doublewords to quadwords by pmovzxdq",
        },
    },

    -- SSE4 packed multiply / test helpers.

    {
        node_type = "instruction",
        mnemonic = "pmuldq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmuldq_vector_multiply",
            target_register = "rip",
            role = "multiplied packed signed doublewords to quadwords by pmuldq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmulld",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmulld_vector_multiply",
            target_register = "rip",
            role = "multiplied packed signed doublewords low by pmulld",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "ptest",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "ptest_updates_rflags",
            target_register = "rflags",
            role = "updated by packed integer test ptest",
        },
    },

    -- SSE4 string / text comparison helpers.
    -- These affect implicit integer/vector state, flags, and string-comparison result state.

    {
        node_type = "instruction",
        mnemonic = "pcmpestri",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "left_length" },
            { index = 3, role = "right" },
            { index = 4, role = "right_length" },
            { index = 5, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "pcmpestri_updates_rcx",
            target_register = "rcx",
            role = "written with explicit-length string comparison index by pcmpestri",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpestri",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "left_length" },
            { index = 3, role = "right" },
            { index = 4, role = "right_length" },
            { index = 5, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "pcmpestri_updates_rflags",
            target_register = "rflags",
            role = "updated by explicit-length string comparison pcmpestri",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpestrm",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "left_length" },
            { index = 3, role = "right" },
            { index = 4, role = "right_length" },
            { index = 5, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "pcmpestrm_updates_mask_state",
            target_register = "rip",
            role = "produced explicit-length string comparison mask by pcmpestrm",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpestrm",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "left_length" },
            { index = 3, role = "right" },
            { index = 4, role = "right_length" },
            { index = 5, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "pcmpestrm_updates_rflags",
            target_register = "rflags",
            role = "updated by explicit-length string comparison mask pcmpestrm",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpistri",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "right" },
            { index = 3, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "pcmpistri_updates_rcx",
            target_register = "rcx",
            role = "written with implicit-length string comparison index by pcmpistri",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpistri",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "right" },
            { index = 3, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "pcmpistri_updates_rflags",
            target_register = "rflags",
            role = "updated by implicit-length string comparison pcmpistri",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpistrm",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "right" },
            { index = 3, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "pcmpistrm_updates_mask_state",
            target_register = "rip",
            role = "produced implicit-length string comparison mask by pcmpistrm",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pcmpistrm",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "right" },
            { index = 3, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "pcmpistrm_updates_rflags",
            target_register = "rflags",
            role = "updated by implicit-length string comparison mask pcmpistrm",
        },
    },

    -- F16C / legacy FMA / AMD XOP / 3DNow! / legacy multimedia visibility effects.
    -- Phase-one model: no vector/MMX/3DNow register file yet, so vector-only effects are exposed as RIP-side activity.

    -- F16C half-precision conversion helpers.

    {
        node_type = "instruction",
        mnemonic = "vcvtph2ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vcvtph2ps_vector_f16c_convert",
            target_register = "rip",
            role = "converted packed half-precision values to single-precision values by vcvtph2ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vcvtps2ph",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "rounding" },
        },
        effect = {
            kind = "register_write",
            name = "vcvtps2ph_vector_f16c_convert",
            target_register = "rip",
            role = "converted packed single-precision values to half-precision values by vcvtps2ph",
        },
    },

    -- Legacy FMA4-style AMD fused multiply-add helpers.
    -- These are vendor-specific / older extension forms, useful for recognition in disassembly.

    {
        node_type = "instruction",
        mnemonic = "vfmaddps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "addend" },
        },
        effect = {
            kind = "register_write",
            name = "vfmaddps_vector_fma4",
            target_register = "rip",
            role = "fused multiply-added packed single-precision values by vfmaddps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmaddpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "addend" },
        },
        effect = {
            kind = "register_write",
            name = "vfmaddpd_vector_fma4",
            target_register = "rip",
            role = "fused multiply-added packed double-precision values by vfmaddpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmaddss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "addend" },
        },
        effect = {
            kind = "register_write",
            name = "vfmaddss_scalar_fma4",
            target_register = "rip",
            role = "fused multiply-added scalar single-precision value by vfmaddss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmaddsd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "addend" },
        },
        effect = {
            kind = "register_write",
            name = "vfmaddsd_scalar_fma4",
            target_register = "rip",
            role = "fused multiply-added scalar double-precision value by vfmaddsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsubps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "subtrahend" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsubps_vector_fma4",
            target_register = "rip",
            role = "fused multiply-subtracted packed single-precision values by vfmsubps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsubpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "subtrahend" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsubpd_vector_fma4",
            target_register = "rip",
            role = "fused multiply-subtracted packed double-precision values by vfmsubpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsubss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "subtrahend" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsubss_scalar_fma4",
            target_register = "rip",
            role = "fused multiply-subtracted scalar single-precision value by vfmsubss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsubsd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "subtrahend" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsubsd_scalar_fma4",
            target_register = "rip",
            role = "fused multiply-subtracted scalar double-precision value by vfmsubsd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmaddps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "addend" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmaddps_vector_fma4",
            target_register = "rip",
            role = "negative fused multiply-added packed single-precision values by vfnmaddps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmaddpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "addend" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmaddpd_vector_fma4",
            target_register = "rip",
            role = "negative fused multiply-added packed double-precision values by vfnmaddpd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmsubps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "subtrahend" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmsubps_vector_fma4",
            target_register = "rip",
            role = "negative fused multiply-subtracted packed single-precision values by vfnmsubps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmsubpd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "subtrahend" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmsubpd_vector_fma4",
            target_register = "rip",
            role = "negative fused multiply-subtracted packed double-precision values by vfnmsubpd",
        },
    },

    -- AMD XOP integer compare / conditional move / permutation helpers.

    {
        node_type = "instruction",
        mnemonic = "vpcomb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "predicate" },
        },
        effect = {
            kind = "register_write",
            name = "vpcomb_vector_xop_compare",
            target_register = "rip",
            role = "compared packed signed bytes by vpcomb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcomw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "predicate" },
        },
        effect = {
            kind = "register_write",
            name = "vpcomw_vector_xop_compare",
            target_register = "rip",
            role = "compared packed signed words by vpcomw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcomd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "predicate" },
        },
        effect = {
            kind = "register_write",
            name = "vpcomd_vector_xop_compare",
            target_register = "rip",
            role = "compared packed signed doublewords by vpcomd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcomq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "predicate" },
        },
        effect = {
            kind = "register_write",
            name = "vpcomq_vector_xop_compare",
            target_register = "rip",
            role = "compared packed signed quadwords by vpcomq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcomub",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "predicate" },
        },
        effect = {
            kind = "register_write",
            name = "vpcomub_vector_xop_compare",
            target_register = "rip",
            role = "compared packed unsigned bytes by vpcomub",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcomuw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "predicate" },
        },
        effect = {
            kind = "register_write",
            name = "vpcomuw_vector_xop_compare",
            target_register = "rip",
            role = "compared packed unsigned words by vpcomuw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcomud",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "predicate" },
        },
        effect = {
            kind = "register_write",
            name = "vpcomud_vector_xop_compare",
            target_register = "rip",
            role = "compared packed unsigned doublewords by vpcomud",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcomuq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "predicate" },
        },
        effect = {
            kind = "register_write",
            name = "vpcomuq_vector_xop_compare",
            target_register = "rip",
            role = "compared packed unsigned quadwords by vpcomuq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpcmov",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "true_source" },
            { index = 3, role = "false_source" },
            { index = 4, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "vpcmov_vector_xop_select",
            target_register = "rip",
            role = "conditionally selected packed values by vpcmov",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpperm",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "vpperm_vector_xop_permute",
            target_register = "rip",
            role = "permuted packed bytes by vpperm",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpermil2ps",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "selector" },
            { index = 5, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vpermil2ps_vector_xop_permute",
            target_register = "rip",
            role = "permuted two packed single-precision sources by vpermil2ps",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpermil2pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "selector" },
            { index = 5, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "vpermil2pd_vector_xop_permute",
            target_register = "rip",
            role = "permuted two packed double-precision sources by vpermil2pd",
        },
    },

    -- AMD XOP multiply / accumulate helpers.

    {
        node_type = "instruction",
        mnemonic = "vpmacsdd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "accumulator" },
        },
        effect = {
            kind = "register_write",
            name = "vpmacsdd_vector_xop_multiply_accumulate",
            target_register = "rip",
            role = "multiply-accumulated signed doublewords by vpmacsdd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmacsdqh",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "accumulator" },
        },
        effect = {
            kind = "register_write",
            name = "vpmacsdqh_vector_xop_multiply_accumulate",
            target_register = "rip",
            role = "multiply-accumulated signed doublewords to high quadwords by vpmacsdqh",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmacsdql",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "accumulator" },
        },
        effect = {
            kind = "register_write",
            name = "vpmacsdql_vector_xop_multiply_accumulate",
            target_register = "rip",
            role = "multiply-accumulated signed doublewords to low quadwords by vpmacsdql",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmacssdd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "accumulator" },
        },
        effect = {
            kind = "register_write",
            name = "vpmacssdd_vector_xop_multiply_accumulate",
            target_register = "rip",
            role = "saturating multiply-accumulated signed doublewords by vpmacssdd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmacsswd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "accumulator" },
        },
        effect = {
            kind = "register_write",
            name = "vpmacsswd_vector_xop_multiply_accumulate",
            target_register = "rip",
            role = "saturating multiply-accumulated signed words to doublewords by vpmacsswd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmacssww",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "accumulator" },
        },
        effect = {
            kind = "register_write",
            name = "vpmacssww_vector_xop_multiply_accumulate",
            target_register = "rip",
            role = "saturating multiply-accumulated signed words by vpmacssww",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmacswd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "accumulator" },
        },
        effect = {
            kind = "register_write",
            name = "vpmacswd_vector_xop_multiply_accumulate",
            target_register = "rip",
            role = "multiply-accumulated signed words to doublewords by vpmacswd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmacsww",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "accumulator" },
        },
        effect = {
            kind = "register_write",
            name = "vpmacsww_vector_xop_multiply_accumulate",
            target_register = "rip",
            role = "multiply-accumulated signed words by vpmacsww",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmadcsswd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "accumulator" },
        },
        effect = {
            kind = "register_write",
            name = "vpmadcsswd_vector_xop_multiply_accumulate",
            target_register = "rip",
            role = "saturating multiply-add accumulated signed words to doublewords by vpmadcsswd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vpmadcswd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
            { index = 4, role = "accumulator" },
        },
        effect = {
            kind = "register_write",
            name = "vpmadcswd_vector_xop_multiply_accumulate",
            target_register = "rip",
            role = "multiply-add accumulated signed words to doublewords by vpmadcswd",
        },
    },

    -- AMD XOP integer horizontal add/subtract and rotate helpers.

    {
        node_type = "instruction",
        mnemonic = "vphaddbd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphaddbd_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally added signed bytes to doublewords by vphaddbd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vphaddbq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphaddbq_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally added signed bytes to quadwords by vphaddbq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vphaddbw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphaddbw_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally added signed bytes to words by vphaddbw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vphadddq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphadddq_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally added signed doublewords to quadwords by vphadddq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vphaddubd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphaddubd_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally added unsigned bytes to doublewords by vphaddubd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vphaddubq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphaddubq_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally added unsigned bytes to quadwords by vphaddubq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vphaddubw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphaddubw_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally added unsigned bytes to words by vphaddubw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vphaddudq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphaddudq_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally added unsigned doublewords to quadwords by vphaddudq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vphadduwd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphadduwd_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally added unsigned words to doublewords by vphadduwd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vphadduwq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphadduwq_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally added unsigned words to quadwords by vphadduwq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vphaddwd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphaddwd_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally added signed words to doublewords by vphaddwd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vphaddwq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphaddwq_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally added signed words to quadwords by vphaddwq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vphsubbw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphsubbw_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally subtracted signed bytes to words by vphsubbw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vphsubdq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphsubdq_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally subtracted signed doublewords to quadwords by vphsubdq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vphsubwd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "vphsubwd_vector_xop_horizontal",
            target_register = "rip",
            role = "horizontally subtracted signed words to doublewords by vphsubwd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprotbi",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "count" },
        },
        effect = {
            kind = "register_write",
            name = "vprotbi_vector_xop_rotate",
            target_register = "rip",
            role = "rotated packed bytes by immediate count by vprotbi",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprotdi",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "count" },
        },
        effect = {
            kind = "register_write",
            name = "vprotdi_vector_xop_rotate",
            target_register = "rip",
            role = "rotated packed doublewords by immediate count by vprotdi",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprotqi",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "count" },
        },
        effect = {
            kind = "register_write",
            name = "vprotqi_vector_xop_rotate",
            target_register = "rip",
            role = "rotated packed quadwords by immediate count by vprotqi",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprotwi",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "count" },
        },
        effect = {
            kind = "register_write",
            name = "vprotwi_vector_xop_rotate",
            target_register = "rip",
            role = "rotated packed words by immediate count by vprotwi",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprotb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vprotb_vector_xop_rotate",
            target_register = "rip",
            role = "rotated packed bytes by variable counts by vprotb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprotd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vprotd_vector_xop_rotate",
            target_register = "rip",
            role = "rotated packed doublewords by variable counts by vprotd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprotq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vprotq_vector_xop_rotate",
            target_register = "rip",
            role = "rotated packed quadwords by variable counts by vprotq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vprotw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
            { index = 3, role = "counts" },
        },
        effect = {
            kind = "register_write",
            name = "vprotw_vector_xop_rotate",
            target_register = "rip",
            role = "rotated packed words by variable counts by vprotw",
        },
    },

    -- 3DNow! / Enhanced 3DNow! visibility.
    -- These are old AMD multimedia instructions, but useful for broad disassembly recognition.

    {
        node_type = "instruction",
        mnemonic = "pavgusb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pavgusb_3dnow_average",
            target_register = "rip",
            role = "averaged packed unsigned bytes by pavgusb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pf2id",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pf2id_3dnow_convert",
            target_register = "rip",
            role = "converted packed single-precision values to doubleword integers by pf2id",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pf2iw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pf2iw_3dnow_convert",
            target_register = "rip",
            role = "converted packed single-precision values to word integers by pf2iw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfacc",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfacc_3dnow_accumulate",
            target_register = "rip",
            role = "accumulated packed single-precision values by pfacc",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfadd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfadd_3dnow_arithmetic",
            target_register = "rip",
            role = "added packed single-precision values by pfadd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfcmpeq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfcmpeq_3dnow_compare",
            target_register = "rip",
            role = "compared packed single-precision values for equality by pfcmpeq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfcmpge",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfcmpge_3dnow_compare",
            target_register = "rip",
            role = "compared packed single-precision values greater-or-equal by pfcmpge",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfcmpgt",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfcmpgt_3dnow_compare",
            target_register = "rip",
            role = "compared packed single-precision values greater-than by pfcmpgt",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfmax",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfmax_3dnow_select",
            target_register = "rip",
            role = "selected packed single-precision maximum values by pfmax",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfmin",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfmin_3dnow_select",
            target_register = "rip",
            role = "selected packed single-precision minimum values by pfmin",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfmul",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfmul_3dnow_arithmetic",
            target_register = "rip",
            role = "multiplied packed single-precision values by pfmul",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfrcp",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfrcp_3dnow_reciprocal",
            target_register = "rip",
            role = "computed approximate packed reciprocal by pfrcp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfrcpit1",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfrcpit1_3dnow_reciprocal",
            target_register = "rip",
            role = "refined approximate packed reciprocal step one by pfrcpit1",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfrcpit2",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfrcpit2_3dnow_reciprocal",
            target_register = "rip",
            role = "refined approximate packed reciprocal step two by pfrcpit2",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfrsqit1",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfrsqit1_3dnow_reciprocal_sqrt",
            target_register = "rip",
            role = "refined approximate packed reciprocal square root by pfrsqit1",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfrsqrt",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfrsqrt_3dnow_reciprocal_sqrt",
            target_register = "rip",
            role = "computed approximate packed reciprocal square root by pfrsqrt",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfsub",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfsub_3dnow_arithmetic",
            target_register = "rip",
            role = "subtracted packed single-precision values by pfsub",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pfsubr",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pfsubr_3dnow_arithmetic",
            target_register = "rip",
            role = "reverse-subtracted packed single-precision values by pfsubr",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pi2fd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pi2fd_3dnow_convert",
            target_register = "rip",
            role = "converted packed doubleword integers to single-precision values by pi2fd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pi2fw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pi2fw_3dnow_convert",
            target_register = "rip",
            role = "converted packed word integers to single-precision values by pi2fw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pmulhrw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pmulhrw_3dnow_multiply",
            target_register = "rip",
            role = "multiplied packed words with rounding high result by pmulhrw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pswapd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pswapd_3dnow_shuffle",
            target_register = "rip",
            role = "swapped packed doublewords by pswapd",
        },
    },

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
    },

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
    },

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
    },

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
    },

    {
        node_type = "instruction",
        mnemonic = "maskmovq",
        operands = {
            { index = 1, role = "source" },
            { index = 2, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "maskmovq_masked_store",
            target_register = "rip",
            role = "masked-stored bytes from mmx state by maskmovq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "maskmovdqu",
        operands = {
            { index = 1, role = "source" },
            { index = 2, role = "mask" },
        },
        effect = {
            kind = "register_write",
            name = "maskmovdqu_masked_store",
            target_register = "rip",
            role = "masked-stored bytes from xmm state by maskmovdqu",
        },
    },

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
    },

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
    },

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
    },

    -- Older prefetch aliases / hints.

    {
        node_type = "instruction",
        mnemonic = "prefetch0",
        operands = {
            { index = 1, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "prefetch0_cache_hint",
            target_register = "rip",
            role = "prefetched data with level-zero locality hint by prefetch0",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "prefetch1",
        operands = {
            { index = 1, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "prefetch1_cache_hint",
            target_register = "rip",
            role = "prefetched data with level-one locality hint by prefetch1",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "prefetch2",
        operands = {
            { index = 1, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "prefetch2_cache_hint",
            target_register = "rip",
            role = "prefetched data with level-two locality hint by prefetch2",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "prefetchit0",
        operands = {
            { index = 1, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "prefetchit0_code_prefetch_hint",
            target_register = "rip",
            role = "prefetched code with level-zero locality hint by prefetchit0",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "prefetchit1",
        operands = {
            { index = 1, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "prefetchit1_code_prefetch_hint",
            target_register = "rip",
            role = "prefetched code with level-one locality hint by prefetchit1",
        },
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    -- Legacy push/pop all-register aliases.

    {
        node_type = "instruction",
        mnemonic = "pusha",
        operands = {},
        effect = {
            kind = "register_write",
            name = "pusha_decreases_rsp",
            target_register = "rsp",
            role = "decreased by legacy push-all pusha",
            value_delta = -32,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pushad",
        operands = {},
        effect = {
            kind = "register_write",
            name = "pushad_decreases_rsp",
            target_register = "rsp",
            role = "decreased by legacy push-all doubleword pushad",
            value_delta = -32,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pushal",
        operands = {},
        effect = {
            kind = "register_write",
            name = "pushal_decreases_rsp",
            target_register = "rsp",
            role = "decreased by legacy push-all long pushal",
            value_delta = -32,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pushaw",
        operands = {},
        effect = {
            kind = "register_write",
            name = "pushaw_decreases_rsp",
            target_register = "rsp",
            role = "decreased by legacy push-all word pushaw",
            value_delta = -16,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "popa",
        operands = {},
        effect = {
            kind = "register_write",
            name = "popa_increases_rsp",
            target_register = "rsp",
            role = "increased by legacy pop-all popa",
            value_delta = 32,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "popad",
        operands = {},
        effect = {
            kind = "register_write",
            name = "popad_increases_rsp",
            target_register = "rsp",
            role = "increased by legacy pop-all doubleword popad",
            value_delta = 32,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "popal",
        operands = {},
        effect = {
            kind = "register_write",
            name = "popal_increases_rsp",
            target_register = "rsp",
            role = "increased by legacy pop-all long popal",
            value_delta = 32,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "popaw",
        operands = {},
        effect = {
            kind = "register_write",
            name = "popaw_increases_rsp",
            target_register = "rsp",
            role = "increased by legacy pop-all word popaw",
            value_delta = 16,
        },
    },

    -- Legacy flags aliases.

    {
        node_type = "instruction",
        mnemonic = "pushfd",
        operands = {},
        effect = {
            kind = "register_write",
            name = "pushfd_decreases_rsp",
            target_register = "rsp",
            role = "decreased by push flags doubleword pushfd",
            value_delta = -4,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pushfw",
        operands = {},
        effect = {
            kind = "register_write",
            name = "pushfw_decreases_rsp",
            target_register = "rsp",
            role = "decreased by push flags word pushfw",
            value_delta = -2,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "popfd",
        operands = {},
        effect = {
            kind = "register_write",
            name = "popfd_increases_rsp",
            target_register = "rsp",
            role = "increased by pop flags doubleword popfd",
            value_delta = 4,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "popfd",
        operands = {},
        effect = {
            kind = "register_write",
            name = "popfd_updates_rflags",
            target_register = "rflags",
            role = "restored by pop flags doubleword popfd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "popfw",
        operands = {},
        effect = {
            kind = "register_write",
            name = "popfw_increases_rsp",
            target_register = "rsp",
            role = "increased by pop flags word popfw",
            value_delta = 2,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "popfw",
        operands = {},
        effect = {
            kind = "register_write",
            name = "popfw_updates_rflags",
            target_register = "rflags",
            role = "restored by pop flags word popfw",
        },
    },

    -- Near/far return aliases.

    {
        node_type = "instruction",
        mnemonic = "retn",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retn_updates_rip",
            target_register = "rip",
            role = "returned near by retn",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "retn",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retn_increases_rsp",
            target_register = "rsp",
            role = "increased by near return retn",
            value_delta = 8,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "retf",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retf_updates_rip",
            target_register = "rip",
            role = "returned far by retf",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "retf",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retf_increases_rsp",
            target_register = "rsp",
            role = "increased by far return retf",
            value_delta = 16,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "retfq",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retfq_updates_rip",
            target_register = "rip",
            role = "returned far quadword by retfq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "retfq",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retfq_increases_rsp",
            target_register = "rsp",
            role = "increased by far quadword return retfq",
            value_delta = 16,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "retfw",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retfw_updates_rip",
            target_register = "rip",
            role = "returned far word by retfw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "retfw",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retfw_increases_rsp",
            target_register = "rsp",
            role = "increased by far word return retfw",
            value_delta = 4,
        },
    },

    -- Interrupt return aliases.

    {
        node_type = "instruction",
        mnemonic = "iretw",
        operands = {},
        effect = {
            kind = "register_write",
            name = "iretw_updates_rip",
            target_register = "rip",
            role = "returned from word interrupt by iretw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "iretd",
        operands = {},
        effect = {
            kind = "register_write",
            name = "iretd_updates_rip",
            target_register = "rip",
            role = "returned from doubleword interrupt by iretd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "iretq",
        operands = {},
        effect = {
            kind = "register_write",
            name = "iretq_updates_rip",
            target_register = "rip",
            role = "returned from quadword interrupt by iretq",
        },
    },

    -- Legacy segment-load helpers.

    {
        node_type = "instruction",
        mnemonic = "lds",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "far_pointer" },
        },
        effect = {
            kind = "register_write",
            name = "lds_writes_destination",
            target_operand = 1,
            role = "written from far pointer by lds",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lds",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "far_pointer" },
        },
        effect = {
            kind = "register_write",
            name = "lds_updates_segment_state",
            target_register = "rip",
            role = "loaded ds segment state by lds",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "les",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "far_pointer" },
        },
        effect = {
            kind = "register_write",
            name = "les_writes_destination",
            target_operand = 1,
            role = "written from far pointer by les",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "les",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "far_pointer" },
        },
        effect = {
            kind = "register_write",
            name = "les_updates_segment_state",
            target_register = "rip",
            role = "loaded es segment state by les",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lfs",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "far_pointer" },
        },
        effect = {
            kind = "register_write",
            name = "lfs_writes_destination",
            target_operand = 1,
            role = "written from far pointer by lfs",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lfs",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "far_pointer" },
        },
        effect = {
            kind = "register_write",
            name = "lfs_updates_segment_state",
            target_register = "rip",
            role = "loaded fs segment state by lfs",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lgs",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "far_pointer" },
        },
        effect = {
            kind = "register_write",
            name = "lgs_writes_destination",
            target_operand = 1,
            role = "written from far pointer by lgs",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lgs",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "far_pointer" },
        },
        effect = {
            kind = "register_write",
            name = "lgs_updates_segment_state",
            target_register = "rip",
            role = "loaded gs segment state by lgs",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lss",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "far_pointer" },
        },
        effect = {
            kind = "register_write",
            name = "lss_writes_destination",
            target_operand = 1,
            role = "written from far pointer by lss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "far_pointer" },
        },
        effect = {
            kind = "register_write",
            name = "lss_updates_segment_state",
            target_register = "rip",
            role = "loaded ss segment state by lss",
        },
    },

    -- Protected-mode / descriptor helpers.

    {
        node_type = "instruction",
        mnemonic = "arpl",
        operands = {
            { index = 1, role = "selector" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "arpl_updates_rflags",
            target_register = "rflags",
            role = "updated by access-rights privilege adjustment arpl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "bound",
        operands = {
            { index = 1, role = "index" },
            { index = 2, role = "bounds" },
        },
        effect = {
            kind = "register_write",
            name = "bound_checks_bounds",
            target_register = "rip",
            role = "checked array bounds by bound",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lsl",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "lsl_writes_destination",
            target_operand = 1,
            role = "written with segment limit by lsl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lar",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "selector" },
        },
        effect = {
            kind = "register_write",
            name = "lar_writes_destination",
            target_operand = 1,
            role = "written with access rights by lar",
        },
    },

    -- Miscellaneous legacy control / undefined / invalid aliases.

    {
        node_type = "instruction",
        mnemonic = "icebp",
        operands = {},
        effect = {
            kind = "register_write",
            name = "icebp_updates_rip",
            target_register = "rip",
            role = "entered one-byte debug interrupt by icebp",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "int1",
        operands = {},
        effect = {
            kind = "register_write",
            name = "int1_updates_rip",
            target_register = "rip",
            role = "entered debug interrupt by int1",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "ud0",
        operands = {},
        effect = {
            kind = "register_write",
            name = "ud0_invalid_instruction",
            target_register = "rip",
            role = "entered invalid-instruction path by ud0",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "ud1",
        operands = {},
        effect = {
            kind = "register_write",
            name = "ud1_invalid_instruction",
            target_register = "rip",
            role = "entered invalid-instruction path by ud1",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "ud2a",
        operands = {},
        effect = {
            kind = "register_write",
            name = "ud2a_invalid_instruction",
            target_register = "rip",
            role = "entered invalid-instruction path by ud2a",
        },
    },

    -- SGX / GETSEC / WAITPKG / platform-security / system-extension visibility effects.
    -- Phase-one model: most privileged/platform state is exposed as RIP-side activity.

    -- Intel SGX enclave instructions.

    {
        node_type = "instruction",
        mnemonic = "encls",
        operands = {},
        effect = {
            kind = "register_write",
            name = "encls_updates_enclave_state",
            target_register = "rip",
            role = "entered privileged sgx enclave instruction path by encls",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "enclu",
        operands = {},
        effect = {
            kind = "register_write",
            name = "enclu_updates_enclave_state",
            target_register = "rip",
            role = "entered user sgx enclave instruction path by enclu",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "enclv",
        operands = {},
        effect = {
            kind = "register_write",
            name = "enclv_updates_enclave_state",
            target_register = "rip",
            role = "entered virtualized sgx enclave instruction path by enclv",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "eaccept",
        operands = {},
        effect = {
            kind = "register_write",
            name = "eaccept_updates_enclave_state",
            target_register = "rip",
            role = "accepted sgx enclave page by eaccept",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "eacceptcopy",
        operands = {},
        effect = {
            kind = "register_write",
            name = "eacceptcopy_updates_enclave_state",
            target_register = "rip",
            role = "accepted copied sgx enclave page by eacceptcopy",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "eaug",
        operands = {},
        effect = {
            kind = "register_write",
            name = "eaug_updates_enclave_state",
            target_register = "rip",
            role = "augmented sgx enclave page by eaug",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "eblock",
        operands = {},
        effect = {
            kind = "register_write",
            name = "eblock_updates_enclave_state",
            target_register = "rip",
            role = "blocked sgx enclave page by eblock",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "ecreate",
        operands = {},
        effect = {
            kind = "register_write",
            name = "ecreate_updates_enclave_state",
            target_register = "rip",
            role = "created sgx enclave control structure by ecreate",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "edbgrd",
        operands = {},
        effect = {
            kind = "register_write",
            name = "edbgrd_updates_enclave_state",
            target_register = "rip",
            role = "debug-read sgx enclave memory by edbgrd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "edbgwr",
        operands = {},
        effect = {
            kind = "register_write",
            name = "edbgwr_updates_enclave_state",
            target_register = "rip",
            role = "debug-wrote sgx enclave memory by edbgwr",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "eenter",
        operands = {},
        effect = {
            kind = "register_write",
            name = "eenter_updates_rip",
            target_register = "rip",
            role = "entered sgx enclave by eenter",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "eexit",
        operands = {},
        effect = {
            kind = "register_write",
            name = "eexit_updates_rip",
            target_register = "rip",
            role = "exited sgx enclave by eexit",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "egetkey",
        operands = {},
        effect = {
            kind = "register_write",
            name = "egetkey_updates_enclave_state",
            target_register = "rip",
            role = "derived sgx enclave key by egetkey",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "einit",
        operands = {},
        effect = {
            kind = "register_write",
            name = "einit_updates_enclave_state",
            target_register = "rip",
            role = "initialized sgx enclave by einit",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "eldb",
        operands = {},
        effect = {
            kind = "register_write",
            name = "eldb_updates_enclave_state",
            target_register = "rip",
            role = "loaded blocked sgx enclave page by eldb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "eldu",
        operands = {},
        effect = {
            kind = "register_write",
            name = "eldu_updates_enclave_state",
            target_register = "rip",
            role = "loaded unblocked sgx enclave page by eldu",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "emodpe",
        operands = {},
        effect = {
            kind = "register_write",
            name = "emodpe_updates_enclave_state",
            target_register = "rip",
            role = "modified sgx enclave page permissions by emodpe",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "emodpr",
        operands = {},
        effect = {
            kind = "register_write",
            name = "emodpr_updates_enclave_state",
            target_register = "rip",
            role = "restricted sgx enclave page permissions by emodpr",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "emodt",
        operands = {},
        effect = {
            kind = "register_write",
            name = "emodt_updates_enclave_state",
            target_register = "rip",
            role = "modified sgx enclave page type by emodt",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "epa",
        operands = {},
        effect = {
            kind = "register_write",
            name = "epa_updates_enclave_state",
            target_register = "rip",
            role = "created sgx version array page by epa",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "erdinfo",
        operands = {},
        effect = {
            kind = "register_write",
            name = "erdinfo_updates_enclave_state",
            target_register = "rip",
            role = "read sgx enclave report information by erdinfo",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "eremove",
        operands = {},
        effect = {
            kind = "register_write",
            name = "eremove_updates_enclave_state",
            target_register = "rip",
            role = "removed sgx enclave page by eremove",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "eresume",
        operands = {},
        effect = {
            kind = "register_write",
            name = "eresume_updates_rip",
            target_register = "rip",
            role = "resumed sgx enclave by eresume",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "etrack",
        operands = {},
        effect = {
            kind = "register_write",
            name = "etrack_updates_enclave_state",
            target_register = "rip",
            role = "tracked sgx enclave page invalidation by etrack",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "eextend",
        operands = {},
        effect = {
            kind = "register_write",
            name = "eextend_updates_enclave_state",
            target_register = "rip",
            role = "extended sgx enclave measurement by eextend",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "egetsec",
        operands = {},
        effect = {
            kind = "register_write",
            name = "egetsec_updates_security_state",
            target_register = "rip",
            role = "entered measured security operation by egetsec",
        },
    },

    -- Intel GETSEC / measured launch helpers.

    {
        node_type = "instruction",
        mnemonic = "getsec",
        operands = {},
        effect = {
            kind = "register_write",
            name = "getsec_updates_security_state",
            target_register = "rip",
            role = "entered measured security operation by getsec",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "senter",
        operands = {},
        effect = {
            kind = "register_write",
            name = "senter_updates_security_state",
            target_register = "rip",
            role = "entered measured launch environment by senter",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sexit",
        operands = {},
        effect = {
            kind = "register_write",
            name = "sexit_updates_security_state",
            target_register = "rip",
            role = "exited measured launch environment by sexit",
        },
    },

    -- WAITPKG / timed wait helpers.

    {
        node_type = "instruction",
        mnemonic = "umonitor",
        operands = {
            { index = 1, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "umonitor_updates_wait_state",
            target_register = "rip",
            role = "armed user-mode monitor address by umonitor",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "umwait",
        operands = {
            { index = 1, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "umwait_updates_wait_state",
            target_register = "rip",
            role = "entered user-mode wait state by umwait",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "tpause",
        operands = {
            { index = 1, role = "control" },
        },
        effect = {
            kind = "register_write",
            name = "tpause_updates_wait_state",
            target_register = "rip",
            role = "entered timed pause state by tpause",
        },
    },

    -- Processor trace / identity / invalidation helpers.

    {
        node_type = "instruction",
        mnemonic = "ptwrite",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "ptwrite_updates_trace_state",
            target_register = "rip",
            role = "wrote value to processor trace stream by ptwrite",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rdpid",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdpid_writes_destination",
            target_operand = 1,
            role = "written with processor id by rdpid",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "invpcid",
        operands = {
            { index = 1, role = "descriptor" },
            { index = 2, role = "type" },
        },
        effect = {
            kind = "register_write",
            name = "invpcid_updates_translation_state",
            target_register = "rip",
            role = "invalidated process-context translations by invpcid",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cldemote",
        operands = {
            { index = 1, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "cldemote_updates_cache_state",
            target_register = "rip",
            role = "demoted cache line by cldemote",
        },
    },

    -- Platform configuration / entropy / firmware-ish helpers.

    {
        node_type = "instruction",
        mnemonic = "pconfig",
        operands = {},
        effect = {
            kind = "register_write",
            name = "pconfig_updates_platform_state",
            target_register = "rip",
            role = "configured platform feature state by pconfig",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rdrand",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdrand_updates_rflags",
            target_register = "rflags",
            role = "updated by hardware random value generation rdrand",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "rdseed",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "rdseed_updates_rflags",
            target_register = "rflags",
            role = "updated by hardware seed generation rdseed",
        },
    },

    -- Lightweight profiling / monitoring helpers.

    {
        node_type = "instruction",
        mnemonic = "llwpcb",
        operands = {
            { index = 1, role = "address" },
        },
        effect = {
            kind = "register_write",
            name = "llwpcb_updates_profiling_state",
            target_register = "rip",
            role = "loaded lightweight profiling control block by llwpcb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "slwpcb",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "slwpcb_writes_destination",
            target_operand = 1,
            role = "written with lightweight profiling control block address by slwpcb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lwpins",
        operands = {
            { index = 1, role = "event_id" },
            { index = 2, role = "event_data" },
            { index = 3, role = "flags" },
        },
        effect = {
            kind = "register_write",
            name = "lwpins_updates_profiling_state",
            target_register = "rip",
            role = "inserted lightweight profiling event by lwpins",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "lwpval",
        operands = {
            { index = 1, role = "event_id" },
            { index = 2, role = "event_data" },
            { index = 3, role = "flags" },
        },
        effect = {
            kind = "register_write",
            name = "lwpval_updates_profiling_state",
            target_register = "rip",
            role = "validated lightweight profiling event by lwpval",
        },
    },

    -- VIA PadLock / old x86 crypto helpers.

    {
        node_type = "instruction",
        mnemonic = "xstore",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xstore_updates_crypto_state",
            target_register = "rip",
            role = "stored hardware random bytes by xstore",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xcryptecb",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xcryptecb_updates_crypto_state",
            target_register = "rip",
            role = "performed hardware aes ecb operation by xcryptecb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xcryptcbc",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xcryptcbc_updates_crypto_state",
            target_register = "rip",
            role = "performed hardware aes cbc operation by xcryptcbc",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xcryptcfb",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xcryptcfb_updates_crypto_state",
            target_register = "rip",
            role = "performed hardware aes cfb operation by xcryptcfb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xcryptofb",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xcryptofb_updates_crypto_state",
            target_register = "rip",
            role = "performed hardware aes ofb operation by xcryptofb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xcryptctr",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xcryptctr_updates_crypto_state",
            target_register = "rip",
            role = "performed hardware aes ctr operation by xcryptctr",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xsha1",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xsha1_updates_crypto_state",
            target_register = "rip",
            role = "performed hardware sha1 operation by xsha1",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xsha256",
        operands = {},
        effect = {
            kind = "register_write",
            name = "xsha256_updates_crypto_state",
            target_register = "rip",
            role = "performed hardware sha256 operation by xsha256",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "montmul",
        operands = {},
        effect = {
            kind = "register_write",
            name = "montmul_updates_crypto_state",
            target_register = "rip",
            role = "performed hardware montgomery multiply by montmul",
        },
    },

    -- System-call aliases / compatibility spellings.

    {
        node_type = "instruction",
        mnemonic = "sysretl",
        operands = {},
        effect = {
            kind = "register_write",
            name = "sysretl_updates_rip",
            target_register = "rip",
            role = "returned from system call in compatibility form by sysretl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sysretl",
        operands = {},
        effect = {
            kind = "register_write",
            name = "sysretl_clobbers_rcx",
            target_register = "rcx",
            role = "clobbered by system call return sysretl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sysretl",
        operands = {},
        effect = {
            kind = "register_write",
            name = "sysretl_clobbers_r11",
            target_register = "r11",
            role = "clobbered by system call return sysretl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sysexitl",
        operands = {},
        effect = {
            kind = "register_write",
            name = "sysexitl_updates_rip",
            target_register = "rip",
            role = "returned from fast system call in compatibility form by sysexitl",
        },
    },

    -- Real-mode / system-management-ish compatibility spellings.

    {
        node_type = "instruction",
        mnemonic = "rsm",
        operands = {},
        effect = {
            kind = "register_write",
            name = "rsm_updates_rip",
            target_register = "rip",
            role = "resumed from system management mode by rsm",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "smi",
        operands = {},
        effect = {
            kind = "register_write",
            name = "smi_updates_rip",
            target_register = "rip",
            role = "entered system management interrupt path by smi",
        },
    },

    -- FMA3 completion pass.
    -- Phase-one model: no vector register file yet, so vector-only effects are exposed as RIP-side activity.

    -- VFMSUB scalar forms.

    {
        node_type = "instruction",
        mnemonic = "vfmsub132ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsub132ss_scalar_fma",
            target_register = "rip",
            role = "fused multiply-subtracted scalar single-precision value by vfmsub132ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsub213ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsub213ss_scalar_fma",
            target_register = "rip",
            role = "fused multiply-subtracted scalar single-precision value by vfmsub213ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsub231ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsub231ss_scalar_fma",
            target_register = "rip",
            role = "fused multiply-subtracted scalar single-precision value by vfmsub231ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsub132sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsub132sd_scalar_fma",
            target_register = "rip",
            role = "fused multiply-subtracted scalar double-precision value by vfmsub132sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsub213sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsub213sd_scalar_fma",
            target_register = "rip",
            role = "fused multiply-subtracted scalar double-precision value by vfmsub213sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsub231sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsub231sd_scalar_fma",
            target_register = "rip",
            role = "fused multiply-subtracted scalar double-precision value by vfmsub231sd",
        },
    },

    -- VFNMADD packed/scalar completion.

    {
        node_type = "instruction",
        mnemonic = "vfnmadd132pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmadd132pd_vector_fma",
            target_register = "rip",
            role = "negative fused multiply-added packed double-precision values by vfnmadd132pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmadd213pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmadd213pd_vector_fma",
            target_register = "rip",
            role = "negative fused multiply-added packed double-precision values by vfnmadd213pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmadd231pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmadd231pd_vector_fma",
            target_register = "rip",
            role = "negative fused multiply-added packed double-precision values by vfnmadd231pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmadd132ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmadd132ss_scalar_fma",
            target_register = "rip",
            role = "negative fused multiply-added scalar single-precision value by vfnmadd132ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmadd213ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmadd213ss_scalar_fma",
            target_register = "rip",
            role = "negative fused multiply-added scalar single-precision value by vfnmadd213ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmadd231ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmadd231ss_scalar_fma",
            target_register = "rip",
            role = "negative fused multiply-added scalar single-precision value by vfnmadd231ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmadd132sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmadd132sd_scalar_fma",
            target_register = "rip",
            role = "negative fused multiply-added scalar double-precision value by vfnmadd132sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmadd213sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmadd213sd_scalar_fma",
            target_register = "rip",
            role = "negative fused multiply-added scalar double-precision value by vfnmadd213sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmadd231sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmadd231sd_scalar_fma",
            target_register = "rip",
            role = "negative fused multiply-added scalar double-precision value by vfnmadd231sd",
        },
    },

    -- VFNMSUB packed/scalar completion.

    {
        node_type = "instruction",
        mnemonic = "vfnmsub132pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmsub132pd_vector_fma",
            target_register = "rip",
            role = "negative fused multiply-subtracted packed double-precision values by vfnmsub132pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmsub213pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmsub213pd_vector_fma",
            target_register = "rip",
            role = "negative fused multiply-subtracted packed double-precision values by vfnmsub213pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmsub231pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmsub231pd_vector_fma",
            target_register = "rip",
            role = "negative fused multiply-subtracted packed double-precision values by vfnmsub231pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmsub132ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmsub132ss_scalar_fma",
            target_register = "rip",
            role = "negative fused multiply-subtracted scalar single-precision value by vfnmsub132ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmsub213ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmsub213ss_scalar_fma",
            target_register = "rip",
            role = "negative fused multiply-subtracted scalar single-precision value by vfnmsub213ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmsub231ss",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmsub231ss_scalar_fma",
            target_register = "rip",
            role = "negative fused multiply-subtracted scalar single-precision value by vfnmsub231ss",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmsub132sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmsub132sd_scalar_fma",
            target_register = "rip",
            role = "negative fused multiply-subtracted scalar double-precision value by vfnmsub132sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmsub213sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmsub213sd_scalar_fma",
            target_register = "rip",
            role = "negative fused multiply-subtracted scalar double-precision value by vfnmsub213sd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfnmsub231sd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfnmsub231sd_scalar_fma",
            target_register = "rip",
            role = "negative fused multiply-subtracted scalar double-precision value by vfnmsub231sd",
        },
    },

    -- VFMADDSUB / VFMSUBADD packed double completion.

    {
        node_type = "instruction",
        mnemonic = "vfmaddsub132pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmaddsub132pd_vector_fma",
            target_register = "rip",
            role = "fused multiply add-subtracted packed double-precision values by vfmaddsub132pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmaddsub213pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmaddsub213pd_vector_fma",
            target_register = "rip",
            role = "fused multiply add-subtracted packed double-precision values by vfmaddsub213pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmaddsub231pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmaddsub231pd_vector_fma",
            target_register = "rip",
            role = "fused multiply add-subtracted packed double-precision values by vfmaddsub231pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsubadd132pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsubadd132pd_vector_fma",
            target_register = "rip",
            role = "fused multiply sub-added packed double-precision values by vfmsubadd132pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsubadd213pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsubadd213pd_vector_fma",
            target_register = "rip",
            role = "fused multiply sub-added packed double-precision values by vfmsubadd213pd",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "vfmsubadd231pd",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "left" },
            { index = 3, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "vfmsubadd231pd_vector_fma",
            target_register = "rip",
            role = "fused multiply sub-added packed double-precision values by vfmsubadd231pd",
        },
    },

    -- Scalar suffix aliases / disassembler compatibility / data movement cleanup.
    -- These help recognize common GAS/objdump-style spellings and legacy width-explicit aliases.

    -- Call aliases.

    {
        node_type = "instruction",
        mnemonic = "callq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "callq_updates_rip",
            target_register = "rip",
            role = "called quadword target by callq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "callq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "callq_decreases_rsp",
            target_register = "rsp",
            role = "decreased by quadword call return-address push callq",
            value_delta = -8,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "calll",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "calll_updates_rip",
            target_register = "rip",
            role = "called long target by calll",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "calll",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "calll_decreases_rsp",
            target_register = "rsp",
            role = "decreased by long call return-address push calll",
            value_delta = -4,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "callw",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "callw_updates_rip",
            target_register = "rip",
            role = "called word target by callw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "callw",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "callw_decreases_rsp",
            target_register = "rsp",
            role = "decreased by word call return-address push callw",
            value_delta = -2,
        },
    },

    -- Jump aliases.

    {
        node_type = "instruction",
        mnemonic = "jmpq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jmpq_updates_rip",
            target_register = "rip",
            role = "jumped to quadword target by jmpq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jmpl",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jmpl_updates_rip",
            target_register = "rip",
            role = "jumped to long target by jmpl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jmpw",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jmpw_updates_rip",
            target_register = "rip",
            role = "jumped to word target by jmpw",
        },
    },

    -- Return aliases.

    {
        node_type = "instruction",
        mnemonic = "retq",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retq_updates_rip",
            target_register = "rip",
            role = "returned quadword by retq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "retq",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retq_increases_rsp",
            target_register = "rsp",
            role = "increased by quadword return retq",
            value_delta = 8,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "retl",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retl_updates_rip",
            target_register = "rip",
            role = "returned long by retl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "retl",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retl_increases_rsp",
            target_register = "rsp",
            role = "increased by long return retl",
            value_delta = 4,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "retw",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retw_updates_rip",
            target_register = "rip",
            role = "returned word by retw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "retw",
        operands = {},
        effect = {
            kind = "register_write",
            name = "retw_increases_rsp",
            target_register = "rsp",
            role = "increased by word return retw",
            value_delta = 2,
        },
    },

    -- Push aliases.

    {
        node_type = "instruction",
        mnemonic = "pushq",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pushq_decreases_rsp",
            target_register = "rsp",
            role = "decreased by quadword push pushq",
            value_delta = -8,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pushl",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pushl_decreases_rsp",
            target_register = "rsp",
            role = "decreased by long push pushl",
            value_delta = -4,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "pushw",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "pushw_decreases_rsp",
            target_register = "rsp",
            role = "decreased by word push pushw",
            value_delta = -2,
        },
    },

    -- Pop aliases.

    {
        node_type = "instruction",
        mnemonic = "popq",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "popq_writes_destination",
            target_operand = 1,
            role = "written by quadword pop popq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "popq",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "popq_increases_rsp",
            target_register = "rsp",
            role = "increased by quadword pop popq",
            value_delta = 8,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "popl",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "popl_writes_destination",
            target_operand = 1,
            role = "written by long pop popl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "popl",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "popl_increases_rsp",
            target_register = "rsp",
            role = "increased by long pop popl",
            value_delta = 4,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "popw",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "popw_writes_destination",
            target_operand = 1,
            role = "written by word pop popw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "popw",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "popw_increases_rsp",
            target_register = "rsp",
            role = "increased by word pop popw",
            value_delta = 2,
        },
    },

    -- Leave aliases.

    {
        node_type = "instruction",
        mnemonic = "leaveq",
        operands = {},
        effect = {
            kind = "register_write",
            name = "leaveq_restores_rsp",
            target_register = "rsp",
            role = "restored from frame pointer by leaveq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "leaveq",
        operands = {},
        effect = {
            kind = "register_write",
            name = "leaveq_restores_rbp",
            target_register = "rbp",
            role = "restored by frame teardown leaveq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "leavel",
        operands = {},
        effect = {
            kind = "register_write",
            name = "leavel_restores_rsp",
            target_register = "rsp",
            role = "restored from frame pointer by leavel",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "leavel",
        operands = {},
        effect = {
            kind = "register_write",
            name = "leavel_restores_rbp",
            target_register = "rbp",
            role = "restored by frame teardown leavel",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "leavew",
        operands = {},
        effect = {
            kind = "register_write",
            name = "leavew_restores_rsp",
            target_register = "rsp",
            role = "restored from frame pointer by leavew",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "leavew",
        operands = {},
        effect = {
            kind = "register_write",
            name = "leavew_restores_rbp",
            target_register = "rbp",
            role = "restored by frame teardown leavew",
        },
    },

    -- Enter aliases.

    {
        node_type = "instruction",
        mnemonic = "enterq",
        operands = {
            { index = 1, role = "frame_size" },
            { index = 2, role = "nesting_level" },
        },
        effect = {
            kind = "register_write",
            name = "enterq_updates_rsp",
            target_register = "rsp",
            role = "updated by quadword stack frame setup enterq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "enterq",
        operands = {
            { index = 1, role = "frame_size" },
            { index = 2, role = "nesting_level" },
        },
        effect = {
            kind = "register_write",
            name = "enterq_updates_rbp",
            target_register = "rbp",
            role = "updated by quadword stack frame setup enterq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "enterl",
        operands = {
            { index = 1, role = "frame_size" },
            { index = 2, role = "nesting_level" },
        },
        effect = {
            kind = "register_write",
            name = "enterl_updates_rsp",
            target_register = "rsp",
            role = "updated by long stack frame setup enterl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "enterl",
        operands = {
            { index = 1, role = "frame_size" },
            { index = 2, role = "nesting_level" },
        },
        effect = {
            kind = "register_write",
            name = "enterl_updates_rbp",
            target_register = "rbp",
            role = "updated by long stack frame setup enterl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "enterw",
        operands = {
            { index = 1, role = "frame_size" },
            { index = 2, role = "nesting_level" },
        },
        effect = {
            kind = "register_write",
            name = "enterw_updates_rsp",
            target_register = "rsp",
            role = "updated by word stack frame setup enterw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "enterw",
        operands = {
            { index = 1, role = "frame_size" },
            { index = 2, role = "nesting_level" },
        },
        effect = {
            kind = "register_write",
            name = "enterw_updates_rbp",
            target_register = "rbp",
            role = "updated by word stack frame setup enterw",
        },
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    -- Arithmetic / logical suffix aliases.
    -- These improve recognition of GAS/objdump-style width-explicit mnemonics.

    -- ADD suffix aliases.

    {
        node_type = "instruction",
        mnemonic = "addb",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "addb_writes_destination",
            target_operand = 1,
            role = "added byte source by addb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "addb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "addb_updates_rflags",
            target_register = "rflags",
            role = "updated by byte add addb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "addw",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "addw_writes_destination",
            target_operand = 1,
            role = "added word source by addw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "addw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "addw_updates_rflags",
            target_register = "rflags",
            role = "updated by word add addw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "addl",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "addl_writes_destination",
            target_operand = 1,
            role = "added long source by addl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "addl",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "addl_updates_rflags",
            target_register = "rflags",
            role = "updated by long add addl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "addq",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "addq_writes_destination",
            target_operand = 1,
            role = "added quadword source by addq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "addq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "addq_updates_rflags",
            target_register = "rflags",
            role = "updated by quadword add addq",
        },
    },

    -- SUB suffix aliases.

    {
        node_type = "instruction",
        mnemonic = "subb",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "subb_writes_destination",
            target_operand = 1,
            role = "subtracted byte source by subb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "subb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "subb_updates_rflags",
            target_register = "rflags",
            role = "updated by byte subtract subb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "subw",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "subw_writes_destination",
            target_operand = 1,
            role = "subtracted word source by subw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "subw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "subw_updates_rflags",
            target_register = "rflags",
            role = "updated by word subtract subw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "subl",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "subl_writes_destination",
            target_operand = 1,
            role = "subtracted long source by subl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "subl",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "subl_updates_rflags",
            target_register = "rflags",
            role = "updated by long subtract subl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "subq",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "subq_writes_destination",
            target_operand = 1,
            role = "subtracted quadword source by subq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "subq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "subq_updates_rflags",
            target_register = "rflags",
            role = "updated by quadword subtract subq",
        },
    },

    -- CMP suffix aliases.

    {
        node_type = "instruction",
        mnemonic = "cmpb",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "cmpb_updates_rflags",
            target_register = "rflags",
            role = "updated by byte compare cmpb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cmpw",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "cmpw_updates_rflags",
            target_register = "rflags",
            role = "updated by word compare cmpw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cmpl",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "cmpl_updates_rflags",
            target_register = "rflags",
            role = "updated by long compare cmpl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cmpq",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "cmpq_updates_rflags",
            target_register = "rflags",
            role = "updated by quadword compare cmpq",
        },
    },

    -- TEST suffix aliases.

    {
        node_type = "instruction",
        mnemonic = "testb",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "testb_updates_rflags",
            target_register = "rflags",
            role = "updated by byte test testb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "testw",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "testw_updates_rflags",
            target_register = "rflags",
            role = "updated by word test testw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "testl",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "testl_updates_rflags",
            target_register = "rflags",
            role = "updated by long test testl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "testq",
        operands = {
            { index = 1, role = "left" },
            { index = 2, role = "right" },
        },
        effect = {
            kind = "register_write",
            name = "testq_updates_rflags",
            target_register = "rflags",
            role = "updated by quadword test testq",
        },
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    -- INC / DEC suffix aliases.

    {
        node_type = "instruction",
        mnemonic = "incb",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "incb_writes_destination",
            target_operand = 1,
            role = "incremented byte by incb",
            value_delta = 1,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "incb",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "incb_updates_rflags",
            target_register = "rflags",
            role = "updated by byte increment incb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "incw",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "incw_writes_destination",
            target_operand = 1,
            role = "incremented word by incw",
            value_delta = 1,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "incw",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "incw_updates_rflags",
            target_register = "rflags",
            role = "updated by word increment incw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "incl",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "incl_writes_destination",
            target_operand = 1,
            role = "incremented long by incl",
            value_delta = 1,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "incl",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "incl_updates_rflags",
            target_register = "rflags",
            role = "updated by long increment incl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "incq",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "incq_writes_destination",
            target_operand = 1,
            role = "incremented quadword by incq",
            value_delta = 1,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "incq",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "incq_updates_rflags",
            target_register = "rflags",
            role = "updated by quadword increment incq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "decb",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "decb_writes_destination",
            target_operand = 1,
            role = "decremented byte by decb",
            value_delta = -1,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "decq",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "decq_writes_destination",
            target_operand = 1,
            role = "decremented quadword by decq",
            value_delta = -1,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "decq",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "decq_updates_rflags",
            target_register = "rflags",
            role = "updated by quadword decrement decq",
        },
    },


    -- Carry arithmetic / unary / shift / rotate suffix aliases.
    -- These improve recognition of GAS/objdump-style width-explicit mnemonics.

    -- ADC suffix aliases.

    {
        node_type = "instruction",
        mnemonic = "adcb",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "adcb_writes_destination",
            target_operand = 1,
            role = "added byte source with carry by adcb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "adcb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "adcb_updates_rflags",
            target_register = "rflags",
            role = "updated by byte add with carry adcb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "adcw",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "adcw_writes_destination",
            target_operand = 1,
            role = "added word source with carry by adcw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "adcw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "adcw_updates_rflags",
            target_register = "rflags",
            role = "updated by word add with carry adcw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "adcl",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "adcl_writes_destination",
            target_operand = 1,
            role = "added long source with carry by adcl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "adcl",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "adcl_updates_rflags",
            target_register = "rflags",
            role = "updated by long add with carry adcl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "adcq",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "adcq_writes_destination",
            target_operand = 1,
            role = "added quadword source with carry by adcq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "adcq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "adcq_updates_rflags",
            target_register = "rflags",
            role = "updated by quadword add with carry adcq",
        },
    },

    -- SBB suffix aliases.

    {
        node_type = "instruction",
        mnemonic = "sbbb",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "sbbb_writes_destination",
            target_operand = 1,
            role = "subtracted byte source with borrow by sbbb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sbbb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "sbbb_updates_rflags",
            target_register = "rflags",
            role = "updated by byte subtract with borrow sbbb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sbbw",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "sbbw_writes_destination",
            target_operand = 1,
            role = "subtracted word source with borrow by sbbw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sbbw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "sbbw_updates_rflags",
            target_register = "rflags",
            role = "updated by word subtract with borrow sbbw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sbbl",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "sbbl_writes_destination",
            target_operand = 1,
            role = "subtracted long source with borrow by sbbl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sbbl",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "sbbl_updates_rflags",
            target_register = "rflags",
            role = "updated by long subtract with borrow sbbl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sbbq",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "sbbq_writes_destination",
            target_operand = 1,
            role = "subtracted quadword source with borrow by sbbq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "sbbq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "sbbq_updates_rflags",
            target_register = "rflags",
            role = "updated by quadword subtract with borrow sbbq",
        },
    },

    -- NEG suffix aliases.

    {
        node_type = "instruction",
        mnemonic = "negb",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "negb_writes_destination",
            target_operand = 1,
            role = "arithmetically negated byte by negb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "negb",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "negb_updates_rflags",
            target_register = "rflags",
            role = "updated by byte negate negb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "negw",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "negw_writes_destination",
            target_operand = 1,
            role = "arithmetically negated word by negw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "negw",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "negw_updates_rflags",
            target_register = "rflags",
            role = "updated by word negate negw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "negl",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "negl_writes_destination",
            target_operand = 1,
            role = "arithmetically negated long by negl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "negl",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "negl_updates_rflags",
            target_register = "rflags",
            role = "updated by long negate negl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "negq",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "negq_writes_destination",
            target_operand = 1,
            role = "arithmetically negated quadword by negq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "negq",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "negq_updates_rflags",
            target_register = "rflags",
            role = "updated by quadword negate negq",
        },
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    -- IMUL suffix aliases.

    {
        node_type = "instruction",
        mnemonic = "imulb",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "imulb_writes_rax",
            target_register = "rax",
            role = "written with byte signed multiply result by imulb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "imulb",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "imulb_updates_rflags",
            target_register = "rflags",
            role = "updated by byte signed multiply imulb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "imulw",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "imulw_writes_rax",
            target_register = "rax",
            role = "written with word signed multiply result low by imulw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "imulw",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "imulw_writes_rdx",
            target_register = "rdx",
            role = "written with word signed multiply result high by imulw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "imull",
        operands = {
            { index = 1, kind = "register", role = "destination_or_source" },
        },
        effect = {
            kind = "register_write",
            name = "imull_writes_operand_or_rax",
            target_operand = 1,
            role = "written by long signed multiply imull",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "imull",
        operands = {
            { index = 1, role = "destination_or_source" },
        },
        effect = {
            kind = "register_write",
            name = "imull_updates_rflags",
            target_register = "rflags",
            role = "updated by long signed multiply imull",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "imulq",
        operands = {
            { index = 1, kind = "register", role = "destination_or_source" },
        },
        effect = {
            kind = "register_write",
            name = "imulq_writes_operand_or_rax",
            target_operand = 1,
            role = "written by quadword signed multiply imulq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "imulq",
        operands = {
            { index = 1, role = "destination_or_source" },
        },
        effect = {
            kind = "register_write",
            name = "imulq_updates_rflags",
            target_register = "rflags",
            role = "updated by quadword signed multiply imulq",
        },
    },

    -- MUL / DIV / IDIV suffix aliases.

    {
        node_type = "instruction",
        mnemonic = "mulb",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "mulb_writes_rax",
            target_register = "rax",
            role = "written with byte unsigned multiply result by mulb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "mulq",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "mulq_writes_rax",
            target_register = "rax",
            role = "written with quadword unsigned multiply result low by mulq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "mulq",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "mulq_writes_rdx",
            target_register = "rdx",
            role = "written with quadword unsigned multiply result high by mulq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "divb",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "divb_writes_rax",
            target_register = "rax",
            role = "written with byte unsigned divide quotient/remainder by divb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "divq",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "divq_writes_rax",
            target_register = "rax",
            role = "written with quadword unsigned divide quotient by divq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "divq",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "divq_writes_rdx",
            target_register = "rdx",
            role = "written with quadword unsigned divide remainder by divq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "idivb",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "idivb_writes_rax",
            target_register = "rax",
            role = "written with byte signed divide quotient/remainder by idivb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "idivq",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "idivq_writes_rax",
            target_register = "rax",
            role = "written with quadword signed divide quotient by idivq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "idivq",
        operands = {
            { index = 1, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "idivq_writes_rdx",
            target_register = "rdx",
            role = "written with quadword signed divide remainder by idivq",
        },
    },

    -- CMPXCHG / XADD suffix aliases.

    {
        node_type = "instruction",
        mnemonic = "cmpxchgb",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "cmpxchgb_writes_destination",
            target_operand = 1,
            role = "conditionally written by byte compare-exchange cmpxchgb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cmpxchgb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "cmpxchgb_updates_rax",
            target_register = "rax",
            role = "updated by byte compare-exchange cmpxchgb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cmpxchgb",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "cmpxchgb_updates_rflags",
            target_register = "rflags",
            role = "updated by byte compare-exchange cmpxchgb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cmpxchgw",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "cmpxchgw_writes_destination",
            target_operand = 1,
            role = "conditionally written by word compare-exchange cmpxchgw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cmpxchgl",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "cmpxchgl_writes_destination",
            target_operand = 1,
            role = "conditionally written by long compare-exchange cmpxchgl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cmpxchgq",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "cmpxchgq_writes_destination",
            target_operand = 1,
            role = "conditionally written by quadword compare-exchange cmpxchgq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cmpxchgq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "cmpxchgq_updates_rax",
            target_register = "rax",
            role = "updated by quadword compare-exchange cmpxchgq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "cmpxchgq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "cmpxchgq_updates_rflags",
            target_register = "rflags",
            role = "updated by quadword compare-exchange cmpxchgq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xaddb",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xaddb_writes_destination",
            target_operand = 1,
            role = "written by byte exchange-add xaddb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xaddb",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xaddb_writes_source",
            target_operand = 2,
            role = "written with original byte destination by xaddb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xaddq",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xaddq_writes_destination",
            target_operand = 1,
            role = "written by quadword exchange-add xaddq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xaddq",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xaddq_writes_source",
            target_operand = 2,
            role = "written with original quadword destination by xaddq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xaddq",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xaddq_updates_rflags",
            target_register = "rflags",
            role = "updated by quadword exchange-add xaddq",
        },
    },

    -- Remaining scalar suffix alias completion.
    -- This fills gaps left from the previous GAS/objdump-style suffix batches.

    -- DEC suffix aliases completion.

    {
        node_type = "instruction",
        mnemonic = "decb",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "decb_updates_rflags",
            target_register = "rflags",
            role = "updated by byte decrement decb",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "decw",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "decw_writes_destination",
            target_operand = 1,
            role = "decremented word by decw",
            value_delta = -1,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "decw",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "decw_updates_rflags",
            target_register = "rflags",
            role = "updated by word decrement decw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "decl",
        operands = {
            { index = 1, kind = "register", role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "decl_writes_destination",
            target_operand = 1,
            role = "decremented long by decl",
            value_delta = -1,
        },
    },

    {
        node_type = "instruction",
        mnemonic = "decl",
        operands = {
            { index = 1, role = "destination" },
        },
        effect = {
            kind = "register_write",
            name = "decl_updates_rflags",
            target_register = "rflags",
            role = "updated by long decrement decl",
        },
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    -- XADD word/long completion.

    {
        node_type = "instruction",
        mnemonic = "xaddw",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xaddw_writes_destination",
            target_operand = 1,
            role = "written by word exchange-add xaddw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xaddw",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xaddw_writes_source",
            target_operand = 2,
            role = "written with original word destination by xaddw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xaddw",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xaddw_updates_rflags",
            target_register = "rflags",
            role = "updated by word exchange-add xaddw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xaddl",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xaddl_writes_destination",
            target_operand = 1,
            role = "written by long exchange-add xaddl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xaddl",
        operands = {
            { index = 1, kind = "register", role = "destination" },
            { index = 2, kind = "register", role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xaddl_writes_source",
            target_operand = 2,
            role = "written with original long destination by xaddl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "xaddl",
        operands = {
            { index = 1, role = "destination" },
            { index = 2, role = "source" },
        },
        effect = {
            kind = "register_write",
            name = "xaddl_updates_rflags",
            target_register = "rflags",
            role = "updated by long exchange-add xaddl",
        },
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

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
    },

    -- Conditional jump suffix / alias completion.
    -- These improve recognition of GAS/objdump-style condition aliases and width-explicit jump spellings.

    -- Equality / zero aliases.

    {
        node_type = "instruction",
        mnemonic = "jeq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jeq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if equal by jeq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jel",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jel_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if equal by jel",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jew",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jew_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if equal by jew",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jzq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jzq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if zero by jzq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jzl",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jzl_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if zero by jzl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jzw",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jzw_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if zero by jzw",
        },
    },

    -- Not-equal / not-zero aliases.

    {
        node_type = "instruction",
        mnemonic = "jneq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jneq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if not equal by jneq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnel",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jnel_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if not equal by jnel",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnew",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jnew_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if not equal by jnew",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnzq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jnzq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if not zero by jnzq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnzl",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jnzl_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if not zero by jnzl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnzw",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jnzw_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if not zero by jnzw",
        },
    },

    -- Signed greater / greater-or-equal aliases.

    {
        node_type = "instruction",
        mnemonic = "jgq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jgq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if signed greater by jgq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jgl",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jgl_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if signed greater by jgl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jgw",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jgw_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if signed greater by jgw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jgeq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jgeq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if signed greater-or-equal by jgeq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jgel",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jgel_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if signed greater-or-equal by jgel",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jgew",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jgew_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if signed greater-or-equal by jgew",
        },
    },

    -- Signed less / less-or-equal aliases.

    {
        node_type = "instruction",
        mnemonic = "jlq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jlq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if signed less by jlq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jll",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jll_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if signed less by jll",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jlw",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jlw_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if signed less by jlw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jleq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jleq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if signed less-or-equal by jleq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jlel",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jlel_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if signed less-or-equal by jlel",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jlew",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jlew_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if signed less-or-equal by jlew",
        },
    },

    -- Unsigned above / above-or-equal aliases.

    {
        node_type = "instruction",
        mnemonic = "jaq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jaq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if unsigned above by jaq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jal",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jal_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if unsigned above by jal",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jaw",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jaw_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if unsigned above by jaw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jaeq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jaeq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if unsigned above-or-equal by jaeq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jael",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jael_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if unsigned above-or-equal by jael",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jaew",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jaew_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if unsigned above-or-equal by jaew",
        },
    },

    -- Unsigned below / below-or-equal / carry aliases.

    {
        node_type = "instruction",
        mnemonic = "jbq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jbq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if unsigned below by jbq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jbl",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jbl_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if unsigned below by jbl",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jbw",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jbw_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if unsigned below by jbw",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jbeq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jbeq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if unsigned below-or-equal by jbeq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jbel",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jbel_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if unsigned below-or-equal by jbel",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jbew",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jbew_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if unsigned below-or-equal by jbew",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jcq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jcq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if carry by jcq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jncq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jncq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if not carry by jncq",
        },
    },

    -- Sign / overflow / parity aliases.

    {
        node_type = "instruction",
        mnemonic = "jsq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jsq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if sign by jsq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnsq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jnsq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if not sign by jnsq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "joq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "joq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if overflow by joq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnoq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jnoq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if not overflow by jnoq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jpq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jpq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if parity by jpq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnpq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jnpq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if not parity by jnpq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jpeq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jpeq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if parity even by jpeq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jpoq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jpoq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if parity odd by jpoq",
        },
    },

    -- Negated signed aliases sometimes seen in assembler/disassembler output.

    {
        node_type = "instruction",
        mnemonic = "jngq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jngq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if not signed greater by jngq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jngeq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jngeq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if not signed greater-or-equal by jngeq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnlq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jnlq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if not signed less by jnlq",
        },
    },

    {
        node_type = "instruction",
        mnemonic = "jnleq",
        operands = {
            { index = 1, role = "target" },
        },
        effect = {
            kind = "register_write",
            name = "jnleq_updates_rip",
            target_register = "rip",
            role = "conditionally jumped if not signed less-or-equal by jnleq",
        },
    },



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
    },

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
    },

    -- sub reg, reg
    {
        node_type = "instruction",
        mnemonic = "sub",

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
            name = "sub_register_self_zero",
            target_operand = 1,
            value = "0",
            role = "zeroed by sub",
        },
    },

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
    },

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
    },

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
    },

    -- 'pop reg' writes an unknown stack value into the destination register.
    {
        node_type = "instruction",
        mnemonic = "pop",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "destination",
            },
        },

        effect = {
            kind = "register_write",
            name = "pop_register_unknown",
            target_operand = 1,
            role = "loaded from stack by pop",
        },
    },

    -- 'push' decreases rsp.
    {
        node_type = "instruction",
        mnemonic = "push",
        operands = {
            {
                index = 1,
                role = "pushed_value",
            },
        },

        effect = {
            kind = "register_write",
            name = "push_updates_rsp",
            target_register = "rsp",
            value_delta = -8,
            role = "decreased by push",
        },
    },

    -- 'pop' increases rsp.
    {
        node_type = "instruction",
        mnemonic = "pop",

        operands = {
            {
                index = 1,
                role = "destination",
            },
        },

        effect = {
            kind = "register_write",
            name = "pop_updates_rsp",
            target_register = "rsp",
            value_delta = 8,
            role = "increased by pop",
        },
    },

    -- 'call' decreases rsp.
    {
        node_type = "instruction",
        mnemonic = "call",

        operands = {
            {
                index = 1,
                role = "call_target",
            },
        },

        effect = {
            kind = "register_write",
            name = "call_updates_rsp",
            target_register = "rsp",
            value_delta = -8,
            role = "decreased by call",
        },
    },


    -- 'ret' increase rsp.
    {
        node_type = "instruction",
        mnemonic = "ret",

        operands = {},

        effect = {
            kind = "register_write",
            name = "ret_updates_rsp",
            target_register = "rsp",
            value_delta = 8,
            role = "increased by ret",
        },
    },

    -- 'leave' restores rsp from rbp.
    {
        node_type = "instruction",
        mnemonic = "leave",
        
        operands = {},

        effect = {
            kind = "register_write",
            name = "leave_restores_rsp",
            target_register = "rsp",
            value_from_register = "rbp",
            role = "restored stack pointer from  frame base by leave",
        },
    },

    -- 'leave' pops the previous frame pointer into rbp.
    {
        node_type = "instruction",
        mnemonic = "leave",

        operands = {},

        effect = {
            kind = "register_write",
            name = "leave_restores_rbp",
            target_register = "rbp",
            role = "loaded previous frame base from stack by leave",
        },
    },


    -- Linux x86-64 'syscall' clobbers rcx.
    {
        node_type = "instruction",
        mnemonic = "syscall",

        operands = {},

        effect = {
            kind = "register_write",
            name = "syscall_clobber_rcx",
            target_register = "rcx",
            role = "clobbered by Linux syscall",
            platform = "linux",
            abi = "linux_syscall",
        },
    },

    -- Linux x86-64 'syscall' clobbers r11.
    {
        node_type = "instruction",
        mnemonic = "syscall",

        operands = {},

        effect = {
            kind = "register_write",
            name = "syscall_clobber_r11",
            target_register = "r11",
            role = "clobbered by Linux syscall",
            platform = "linux",
            abi = "linux_syscall",
        },
    },

    -- 'cmp' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "cmp",

        operands = {
            {
                index = 1,
                role = "left",
            },
            {
                index = 2,
                role = "right",
            },
        },

        effect = {
            kind = "register_write",
            name = "cmp_updates_rflags",
            target_register = "rflags",
            role = "updated by cmp",
        },
    },

    -- 'test' updates rflags.
    {
        node_type = "instruction",
        mnemonic = "test",

        operands = {
            {
                index = 1,
                role = "left",
            },
            {
                index = 2,
                role = "right",
            },
        },

        effect = {
            kind = "register_write",
            name = "test_updates_rflags",
            target_register = "rflags",
            role = "updated by test",
        },
    },

    -- Linux x86-64 'syscall' writes its return value to rax.
    {
        node_type = "instruction",
        mnemonic = "syscall",

        operands = {},

        effect = {
            kind = "register_write",
            name = "syscall_return_rax",
            target_register = "rax",
            role = "receives Linux syscall return value",
            platform = "linux",
            abi = "linux_syscall",
        },
    },

    -- 'add'
    {
        node_type = "instruction",
        mnemonic = "add",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "destination",
            },
            {
                index = 2,
                kind = "integer",
                role = "increment_value",
            },
        },

        effect = {
            kind = "register_write",
            name = "add_register_immediate",
            target_operand = 1,
            value_delta_operand = 2,
            role = "increased by immediate",
        },
    },
    -- 'sub'
    {
        node_type = "instruction",
        mnemonic = "sub",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "destination",
            },
            {
                index = 2,
                kind = "integer",
                role = "decrement_value",
            },
        },

        effect = {
            kind = "register_write",
            name = "sub_register_immediate",
            target_operand = 1,
            value_delta_operand = 2,
            value_delta_sign = -1,
            role = "decreased by immediate",
        },
    },

    -- 'inc'
    {
        node_type = "instruction",
        mnemonic = "inc",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "destination",
            },
        },

        effect = {
            kind = "register_write",
            name = "inc_register",
            target_operand = 1,
            value_delta = 1,
            role = "incremented",
        },
    },
    -- 'dec'
    {
        node_type = "instruction",
        mnemonic = "dec",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "destination",
            },
        },

        effect = {
            kind = "register_write",
            name = "dec_register",
            target_operand = 1,
            value_delta = -1,
            role = "decremented",
        },
    },
}


M.stack_effects = {
    -- 'push'
    {
        node_type = "instruction",
        mnemonic = "push",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "pushed_value",
            },
        },

        effect = {
            kind = "stack_push",
            name = "push_register",
            value_operand = 1,
            size = 8,
            offset_delta = -8,
            role = "pushed register onto stack",
        },
    },

    -- 'push immediate'
    {
        node_type = "instruction",
        mnemonic = "push",

        operands = {
            {
                index = 1,
                kind = "integer",
                role = "pushed_value",
            },
        },

        effect = {
            kind = "stack_push",
            name = "push_immediate",
            value_operand = 1,
            size = 8,
            offset_delta = -8,
            role = "pushed immediate onto stack",
        },
    },

    -- 'push symbol'
    {
        node_type = "instruction",
        mnemonic = "push",

        operands = {
            {
                index = 1,
                kind = "symbol",
                role = "pushed_value",
            },
        },

        effect = {
            kind = "stack_push",
            name = "push_symbol",
            value_operand = 1,
            size = 8,
            offset_delta = -8,
            role = "pushed symbol onto stack",
        },
    },

    -- 'pop'
    {
        node_type = "instruction",
        mnemonic = "pop",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "destination",
            },
        },

        effect = {
            kind = "stack_pop",
            name = "pop_register",
            value_operand = 1,
            size = 8,
            offset_delta = 8,
            role = "popped stack value into register",
        },
    },
    -- 'sub'
    {
        node_type = "instruction",
        mnemonic = "sub",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "stack_pointer",
                value = "rsp",
            },
            {
                index = 2,
                kind = "integer",
                role = "allocation_size",
            },
        },

        effect = {
            kind = "stack_allocate",
            name = "sub_rsp_immediate",
            size_operand = 2,
            role = "allocated stack space",
        },
    },
    -- 'add'
    {
        node_type = "instruction",
        mnemonic = "add",

        operands = {
            {
                index = 1,
                kind = "register",
                role = "stack_pointer",
                value = "rsp",
            },
            {
                index = 2,
                kind = "integer",
                role = "deallocation_size",
            },
        },

        effect = {
            kind = "stack_deallocate",
            name = "add_rsp_immediate",
            size_operand = 2,
            role = "released stack space",
        },
    },

    -- 'call'
    {
        node_type = "instruction",
        mnemonic = "call",

        operands = {
            {
                index = 1,
                role = "call_target",
            },
        },

        effect = {
            kind = "stack_call",
            name = "call_symbol",
            value_operand = 1,
            size = 8,
            offset_delta = -8,
            role = "pushed return address and transferred control",
        },
    },

    -- 'ret'
    {
        node_type = "instruction",
        mnemonic = "ret",

        operands = {},

        effect = {
            kind = "stack_return",
            name = "ret",
            size = 8,
            offset_delta = 8,
            role = "popped return address and returned to caller",
        },
    },

    -- 'leave'
    {
        node_type = "instruction",
        mnemonic = "leave",

        operands = {},

        effect = {
            kind = "stack_frame_restore",
            name = "leave",
            role = "restored previous stack frame",
        },
    },
}

M.syscall = {
    instruction = "syscall",
    platform = "linux",
    abi = "linux_syscall",

    convention = {
        number_register = "rax",
        return_register = "rax",

        argument_registers = {
            "rdi",
            "rsi",
            "rdx",
            "r10",
            "r8",
            "r9",
        },
    },

    known_numbers = {
        ["0"] = "read",
        ["1"] = "write",
        ["9"] = "mmap",
        ["11"] = "munmap",
        ["12"] = "brk",
        ["60"] = "exit",
    },
}


M.boundary_effects = {
    {
        kind = "syscall",
        category = "system",
        platform = "linux",
        abi = "linux_syscall",
        node_type = "instruction",
        mnemonic = "syscall",

        reads = {
            number_register = "rax",
            argument_registers = {
                "rdi",
                "rsi",
                "rdx",
                "r10",
                "r8",
                "r9",
            },
        },

        writes = {
            return_register = "rax",
        },

        known_effects = {
            ["0"] = {
                name = "read",
                category = "io",
                required_arguments = { 1, 2, 3 },
                argument_names = {
                    [1] = "fd",
                    [2] = "buf",
                    [3] = "count",
                },
            },

            ["1"] = {
                name = "write",
                category = "io",
                required_arguments = { 1, 2, 3 },
                argument_names = {
                    [1] = "fd",
                    [2] = "buf",
                    [3] = "count",
                },
            },

            ["9"] = {
                name = "mmap",
                category = "heap",
                produces = {
                    kind = "memory_region",
                    result_register = "rax",
                },

                required_arguments = { 1, 2, 3, 4, 5, 6 },
                argument_names = {
                    [1] = "addr",
                    [2] = "length",
                    [3] = "prot",
                    [4] = "flags",
                    [5] = "fd",
                    [6] = "offset",
                },
            },

            ["11"] = {
                name = "munmap",
                category = "heap",
                consumes = {
                    pointer_register = "rdi",
                    size_register = "rsi",
                },

                required_arguments = { 1, 2 },
                argument_names ={
                    [1] = "addr",
                    [2] = "length",
                },
            },

            ["12"] = {
                name = "brk",
                category = "heap",
                required_arguments = { 1 },
                argument_names = {
                    [1] = "addr",
                },
            },

            ["60"] = {
                name = "exit",
                category = "process",
                required_arguments = { 1 },
                argument_names = {
                    [1] = "status",
                },
            },
        },
    },
}


M.warning_rules = {
    {
        source = "boundary_effects",
        check = "missing_read_value",
        severity = "state",

        match = {
            kind = "syscall",
        },

        read = {
            role = "number",
        },

        category = "boundary",
        message = "syscall number register {register} has no known value",
    },

    {
        source = "boundary_effects",
        check = "missing_known_effect",
        severity = "state",

        match = {
            kind = "syscall",
        },

        value_read = {
            role = "number",
        },

        category = "boundary",
        message = "unknown syscall number #{value}",
    },

    {
        source = "boundary_effects",
        check = "missing_required_reads",
        severity = "state",

        match = {
            kind = "syscall",
        },

        read = {
            role = "argument",
        },

        category = "boundary",
        message = "{name} argument {index} ({argument_name}) register {register} has no known value",
    },
}

M.register_families = {
    rax = {
        canonical = "rax",
        bits = 64,
        kind = "general",
        role = "accumulator / return value",
        aliases = {
            rax = { name = "rax", bits = 64, offset = 0, write_mode = "full" },
            eax = { name = "eax", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            ax  = { name = "ax",  bits = 16, offset = 0, write_mode = "partial" },
            ah  = { name = "ah",  bits = 8,  offset = 8, write_mode = "partial" },
            al  = { name = "al",  bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "rax", "eax", "ax", "ah", "al" },
    },

    rbx = {
        canonical = "rbx",
        bits = 64,
        kind = "general",
        role = "callee-saved general register",
        aliases = {
            rbx = { name = "rbx", bits = 64, offset = 0, write_mode = "full" },
            ebx = { name = "ebx", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            bx  = { name = "bx",  bits = 16, offset = 0, write_mode = "partial" },
            bh  = { name = "bh",  bits = 8,  offset = 8, write_mode = "partial" },
            bl  = { name = "bl",  bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "rbx", "ebx", "bx", "bh", "bl" },
    },

    rcx = {
        canonical = "rcx",
        bits = 64,
        kind = "general",
        role = "counter / argument register",
        aliases = {
            rcx = { name = "rcx", bits = 64, offset = 0, write_mode = "full" },
            ecx = { name = "ecx", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            cx  = { name = "cx",  bits = 16, offset = 0, write_mode = "partial" },
            ch  = { name = "ch",  bits = 8,  offset = 8, write_mode = "partial" },
            cl  = { name = "cl",  bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "rcx", "ecx", "cx", "ch", "cl" },
    },

    rdx = {
        canonical = "rdx",
        bits = 64,
        kind = "general",
        role = "data / argument register",
        aliases = {
            rdx = { name = "rdx", bits = 64, offset = 0, write_mode = "full" },
            edx = { name = "edx", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            dx  = { name = "dx",  bits = 16, offset = 0, write_mode = "partial" },
            dh  = { name = "dh",  bits = 8,  offset = 8, write_mode = "partial" },
            dl  = { name = "dl",  bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "rdx", "edx", "dx", "dh", "dl" },
    },

    rsi = {
        canonical = "rsi",
        bits = 64,
        kind = "general",
        role = "source index / argument register",
        aliases = {
            rsi = { name = "rsi", bits = 64, offset = 0, write_mode = "full" },
            esi = { name = "esi", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            si  = { name = "si",  bits = 16, offset = 0, write_mode = "partial" },
            sil = { name = "sil", bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "rsi", "esi", "si", "sil" },
    },

    rdi = {
        canonical = "rdi",
        bits = 64,
        kind = "general",
        role = "destination index / argument register",
        aliases = {
            rdi = { name = "rdi", bits = 64, offset = 0, write_mode = "full" },
            edi = { name = "edi", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            di  = { name = "di",  bits = 16, offset = 0, write_mode = "partial" },
            dil = { name = "dil", bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "rdi", "edi", "di", "dil" },
    },

    rbp = {
        canonical = "rbp",
        bits = 64,
        kind = "base_pointer",
        role = "frame/base pointer",
        aliases = {
            rbp = { name = "rbp", bits = 64, offset = 0, write_mode = "full" },
            ebp = { name = "ebp", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            bp  = { name = "bp",  bits = 16, offset = 0, write_mode = "partial" },
            bpl = { name = "bpl", bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "rbp", "ebp", "bp", "bpl" },
    },

    rsp = {
        canonical = "rsp",
        bits = 64,
        kind = "stack_pointer",
        role = "stack pointer",
        aliases = {
            rsp = { name = "rsp", bits = 64, offset = 0, write_mode = "full" },
            esp = { name = "esp", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            sp  = { name = "sp",  bits = 16, offset = 0, write_mode = "partial" },
            spl = { name = "spl", bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "rsp", "esp", "sp", "spl" },
    },

    r8 = {
        canonical = "r8", bits = 64, kind = "general", role = "argument / general register",
        aliases = {
            r8  = { name = "r8",  bits = 64, offset = 0, write_mode = "full" },
            r8d = { name = "r8d", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            r8w = { name = "r8w", bits = 16, offset = 0, write_mode = "partial" },
            r8b = { name = "r8b", bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "r8", "r8d", "r8w", "r8b" },
    },

    r9 = {
        canonical = "r9", bits = 64, kind = "general", role = "argument / general register",
        aliases = {
            r9  = { name = "r9",  bits = 64, offset = 0, write_mode = "full" },
            r9d = { name = "r9d", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            r9w = { name = "r9w", bits = 16, offset = 0, write_mode = "partial" },
            r9b = { name = "r9b", bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "r9", "r9d", "r9w", "r9b" },
    },

    r10 = {
        canonical = "r10", bits = 64, kind = "general", role = "temporary general register",
        aliases = {
            r10  = { name = "r10",  bits = 64, offset = 0, write_mode = "full" },
            r10d = { name = "r10d", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            r10w = { name = "r10w", bits = 16, offset = 0, write_mode = "partial" },
            r10b = { name = "r10b", bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "r10", "r10d", "r10w", "r10b" },
    },

    r11 = {
        canonical = "r11", bits = 64, kind = "general", role = "temporary general register",
        aliases = {
            r11  = { name = "r11",  bits = 64, offset = 0, write_mode = "full" },
            r11d = { name = "r11d", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            r11w = { name = "r11w", bits = 16, offset = 0, write_mode = "partial" },
            r11b = { name = "r11b", bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "r11", "r11d", "r11w", "r11b" },
    },

    r12 = {
        canonical = "r12", bits = 64, kind = "general", role = "callee-saved general register",
        aliases = {
            r12  = { name = "r12",  bits = 64, offset = 0, write_mode = "full" },
            r12d = { name = "r12d", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            r12w = { name = "r12w", bits = 16, offset = 0, write_mode = "partial" },
            r12b = { name = "r12b", bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "r12", "r12d", "r12w", "r12b" },
    },

    r13 = {
        canonical = "r13", bits = 64, kind = "general", role = "callee-saved general register",
        aliases = {
            r13  = { name = "r13",  bits = 64, offset = 0, write_mode = "full" },
            r13d = { name = "r13d", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            r13w = { name = "r13w", bits = 16, offset = 0, write_mode = "partial" },
            r13b = { name = "r13b", bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "r13", "r13d", "r13w", "r13b" },
    },

    r14 = {
        canonical = "r14", bits = 64, kind = "general", role = "callee-saved general register",
        aliases = {
            r14  = { name = "r14",  bits = 64, offset = 0, write_mode = "full" },
            r14d = { name = "r14d", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            r14w = { name = "r14w", bits = 16, offset = 0, write_mode = "partial" },
            r14b = { name = "r14b", bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "r14", "r14d", "r14w", "r14b" },
    },

    r15 = {
        canonical = "r15", bits = 64, kind = "general", role = "callee-saved general register",
        aliases = {
            r15  = { name = "r15",  bits = 64, offset = 0, write_mode = "full" },
            r15d = { name = "r15d", bits = 32, offset = 0, write_mode = "zero_extend_64" },
            r15w = { name = "r15w", bits = 16, offset = 0, write_mode = "partial" },
            r15b = { name = "r15b", bits = 8,  offset = 0, write_mode = "partial" },
        },
        alias_order = { "r15", "r15d", "r15w", "r15b" },
    },
}


M.registers = {
    static = {
        -- General purpose registers
        { name = "rax", kind = "general", role = "accumulator / return value", family = "rax" },
        { name = "rbx", kind = "general", role = "callee-saved general register", family = "rbx" },
        { name = "rcx", kind = "general", role = "counter / argument register", family = "rcx" },
        { name = "rdx", kind = "general", role = "data / argument register", family = "rdx" },
        { name = "rsi", kind = "general", role = "source index / argument register", family = "rsi" },
        { name = "rdi", kind = "general", role = "destination index / argument register", family = "rdi" },
        { name = "r8",  kind = "general", role = "argument / general register", family = "r8" },
        { name = "r9",  kind = "general", role = "argument / general register", family = "r9" },
        { name = "r10", kind = "general", role = "temporary general register", family = "r10" },
        { name = "r11", kind = "general", role = "temporary general register", family = "r11" },
        { name = "r12", kind = "general", role = "callee-saved general register", family = "r12" },
        { name = "r13", kind = "general", role = "callee-saved general register", family = "r13" },
        { name = "r14", kind = "general", role = "callee-saved general register", family = "r14" },
        { name = "r15", kind = "general", role = "callee-saved general register", family = "r15" },

        -- Special registers
        { name = "rsp", kind = "stack_pointer", role = "stack pointer", family = "rsp" },
        { name = "rbp", kind = "base_pointer", role = "frame/base pointer", family = "rbp" },
        { name = "rip", kind = "instruction_pointer", role = "instruction pointer" },
        { name = "rflags", kind = "flags", role = "status/control flags" },
    },
}


M.stack = {
    static = {
        {
            name = "current frame",
            kind = "frame",
            role = "active stack frame",
            source = "architecture",
        },
        {
            name = "return address",
            kind = "return_address",
            role = "call return target stored on stack",
            source = "architecture",
        },
        {
            name = "stack pointer",
            kind = "stack_pointer",
            role = "top of stack tracked by rsp",
            source = "architecture",
        },
        {
            name = "base pointer",
            kind = "base_pointer",
            role = "frame base tracked by rbp when frame pointers are used",
            source = "architecture",
        },
    },
}


return M
