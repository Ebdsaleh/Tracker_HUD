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
