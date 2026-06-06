-- lua/tracker_hud/adapters/asm_arch/x86_64.lua
--
-- x86-64 architecture facts for the ASM adapter.
--
-- This file is spec-only.
--
-- It describes:
--   - public architecture name
--   - aliases
--   - registers
--   - stack concepts
--   - scope member declarations
--
-- Behaviour belongs in:
--   - asm_adapter.lua
--   - scope_members.lua
--   - registers.lua
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
}

M.register_effects = {
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
}


M.registers = {
    static = {
        -- General purpose registers
        { name = "rax", kind = "general", role = "accumulator / return value" },
        { name = "rbx", kind = "general", role = "callee-saved general register" },
        { name = "rcx", kind = "general", role = "counter / argument register" },
        { name = "rdx", kind = "general", role = "data / argument register" },
        { name = "rsi", kind = "general", role = "source index / argument register" },
        { name = "rdi", kind = "general", role = "destination index / argument register" },
        { name = "r8", kind = "general", role = "argument / general register" },
        { name = "r9", kind = "general", role = "argument / general register" },
        { name = "r10", kind = "general", role = "temporary general register" },
        { name = "r11", kind = "general", role = "temporary general register" },
        { name = "r12", kind = "general", role = "callee-saved general register" },
        { name = "r13", kind = "general", role = "callee-saved general register" },
        { name = "r14", kind = "general", role = "callee-saved general register" },
        { name = "r15", kind = "general", role = "callee-saved general register" },

        -- Special registers
        { name = "rsp", kind = "stack_pointer", role = "stack pointer" },
        { name = "rbp", kind = "base_pointer", role = "frame/base pointer" },
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
