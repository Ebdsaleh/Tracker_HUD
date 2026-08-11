-- lua/tracker_hud/adapters/asm/arch/x86_64/adapter.lua
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
--   - register effects / instruction events
--
-- Behaviour belongs in:
--   - adapters/asm/adapter.lua
--   - adapters/asm/instruction_utils.lua
--   - context_engine.lua
--   - registers.lua
--   - register_model.lua
--   - register_tree.lua
--   - stack.lua


local M = {}

M.name = "x86-64"

M.aliases = {
    "x86-64",
    "x86_64",
    "amd64",
    "x64",
}

M.metadata = {
    architecture = "x86-64",
    family = "x86",
    bits = 64,
    endian = "little",
}

M.platforms = {
    linux = {
        abi = "linux_syscall",
        status = "supported",
    },

    windows = {
        abi = "windows_x64",
        status = "declared",
    },
    darwin = {
        abi = "darwin_x86_64",
        status = "declared",
    },
}

M.default_platform = "linux"

M.platform_aliases = {

    linux = "linux",

    windows = "windows",
    win64 = "windows",

    darwin = "darwin",
    macos = "darwin",
    mac = "darwin",
}


M.syntaxes = {
    nasm = {
        status = "supported",
        directive_comment_prefixes = {
            ";",
        },
    },

    gas = {
        status = "declared",
        directive_comment_prefixes = {
            "#",
            "//",
        },
    },

    masm = {
        status = "declared",
        directive_comment_prefixes = {
            ";",
        },
    },
}


M.calling_conventions = {
    linux_syscall = {
        kind = "syscall",
        platform = "linux",

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

        clobbers = {
            "rcx",
            "r11",
        },
    },

    windows_x64 = {
        kind = "function_call",
        platform = "windows",
        status = "declared",
    },

    darwin_x86_64 = {
        kind = "syscall",
        platform = "darwin",
        status = "declared",
    },
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


M.register_effects = require("tracker_hud.adapters.asm.arch.x86_64.register_effects")


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


M.instruction_events = require("tracker_hud.adapters.asm.arch.x86_64.instruction_events")


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


M.presentation = {
    registers = {
        default_layout = "extended",

        layouts = {
            extended = {
                item_order = "natural",

                groups = {
                    {
                        id = "general",
                        label = "General",
                        default_expanded = true,

                        match = {
                            kinds = {
                                "general",
                            },
                        },

                        item_order = "custom",

                        custom_order = {
                            "rax",
                            "rbx",
                            "rcx",
                            "rdx",
                            "rsi",
                            "rdi",
                            "r8",
                            "r9",
                            "r10",
                            "r11",
                            "r12",
                            "r13",
                            "r14",
                            "r15",
                        },
                    },

                    {
                        id = "pointers",
                        label = "Pointers",
                        default_expanded = true,

                        match = {
                            kinds = {
                                "base_pointer",
                                "stack_pointer",
                                "instruction_pointer",
                            },
                        },

                        item_order = "custom",

                        custom_order = {
                            "rbp",
                            "rsp",
                            "rip",
                        },
                    },

                    {
                        id = "flags",
                        label = "Flags",
                        default_expanded = true,

                        match = {
                            kinds = {
                                "flags",
                            },
                        },

                        item_order = "natural",
                    },

                    {
                        id = "vector",
                        label = "Vector",
                        default_expanded = true,

                        match = {
                            kinds = {
                                "vector",
                            },
                        },

                        item_order = "natural",
                    },
                },

                unmatched_item_order = "natural",
            },
        },
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

    -- Vector register families.
    --
    -- XMM/YMM/ZMM names describe overlapping low portions of the same
    -- architectural vector-register family. Encoding-specific upper-bit
    -- write behaviour belongs to instruction/register-effect specs rather
    -- than the family definition.

    zmm0 = {
        canonical = "zmm0",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm0 = { name = "zmm0", bits = 512, offset = 0, write_mode = "full" },
            ymm0 = { name = "ymm0", bits = 256, offset = 0 },
            xmm0 = { name = "xmm0", bits = 128, offset = 0 },
        },
        alias_order = { "zmm0", "ymm0", "xmm0" },
    },

    zmm1 = {
        canonical = "zmm1",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm1 = { name = "zmm1", bits = 512, offset = 0, write_mode = "full" },
            ymm1 = { name = "ymm1", bits = 256, offset = 0 },
            xmm1 = { name = "xmm1", bits = 128, offset = 0 },
        },
        alias_order = { "zmm1", "ymm1", "xmm1" },
    },

    zmm2 = {
        canonical = "zmm2",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm2 = { name = "zmm2", bits = 512, offset = 0, write_mode = "full" },
            ymm2 = { name = "ymm2", bits = 256, offset = 0 },
            xmm2 = { name = "xmm2", bits = 128, offset = 0 },
        },
        alias_order = { "zmm2", "ymm2", "xmm2" },
    },

    zmm3 = {
        canonical = "zmm3",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm3 = { name = "zmm3", bits = 512, offset = 0, write_mode = "full" },
            ymm3 = { name = "ymm3", bits = 256, offset = 0 },
            xmm3 = { name = "xmm3", bits = 128, offset = 0 },
        },
        alias_order = { "zmm3", "ymm3", "xmm3" },
    },

    zmm4 = {
        canonical = "zmm4",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm4 = { name = "zmm4", bits = 512, offset = 0, write_mode = "full" },
            ymm4 = { name = "ymm4", bits = 256, offset = 0 },
            xmm4 = { name = "xmm4", bits = 128, offset = 0 },
        },
        alias_order = { "zmm4", "ymm4", "xmm4" },
    },

    zmm5 = {
        canonical = "zmm5",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm5 = { name = "zmm5", bits = 512, offset = 0, write_mode = "full" },
            ymm5 = { name = "ymm5", bits = 256, offset = 0 },
            xmm5 = { name = "xmm5", bits = 128, offset = 0 },
        },
        alias_order = { "zmm5", "ymm5", "xmm5" },
    },

    zmm6 = {
        canonical = "zmm6",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm6 = { name = "zmm6", bits = 512, offset = 0, write_mode = "full" },
            ymm6 = { name = "ymm6", bits = 256, offset = 0 },
            xmm6 = { name = "xmm6", bits = 128, offset = 0 },
        },
        alias_order = { "zmm6", "ymm6", "xmm6" },
    },

    zmm7 = {
        canonical = "zmm7",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm7 = { name = "zmm7", bits = 512, offset = 0, write_mode = "full" },
            ymm7 = { name = "ymm7", bits = 256, offset = 0 },
            xmm7 = { name = "xmm7", bits = 128, offset = 0 },
        },
        alias_order = { "zmm7", "ymm7", "xmm7" },
    },

    zmm8 = {
        canonical = "zmm8",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm8 = { name = "zmm8", bits = 512, offset = 0, write_mode = "full" },
            ymm8 = { name = "ymm8", bits = 256, offset = 0 },
            xmm8 = { name = "xmm8", bits = 128, offset = 0 },
        },
        alias_order = { "zmm8", "ymm8", "xmm8" },
    },

    zmm9 = {
        canonical = "zmm9",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm9 = { name = "zmm9", bits = 512, offset = 0, write_mode = "full" },
            ymm9 = { name = "ymm9", bits = 256, offset = 0 },
            xmm9 = { name = "xmm9", bits = 128, offset = 0 },
        },
        alias_order = { "zmm9", "ymm9", "xmm9" },
    },

    zmm10 = {
        canonical = "zmm10",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm10 = { name = "zmm10", bits = 512, offset = 0, write_mode = "full" },
            ymm10 = { name = "ymm10", bits = 256, offset = 0 },
            xmm10 = { name = "xmm10", bits = 128, offset = 0 },
        },
        alias_order = { "zmm10", "ymm10", "xmm10" },
    },

    zmm11 = {
        canonical = "zmm11",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm11 = { name = "zmm11", bits = 512, offset = 0, write_mode = "full" },
            ymm11 = { name = "ymm11", bits = 256, offset = 0 },
            xmm11 = { name = "xmm11", bits = 128, offset = 0 },
        },
        alias_order = { "zmm11", "ymm11", "xmm11" },
    },

    zmm12 = {
        canonical = "zmm12",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm12 = { name = "zmm12", bits = 512, offset = 0, write_mode = "full" },
            ymm12 = { name = "ymm12", bits = 256, offset = 0 },
            xmm12 = { name = "xmm12", bits = 128, offset = 0 },
        },
        alias_order = { "zmm12", "ymm12", "xmm12" },
    },

    zmm13 = {
        canonical = "zmm13",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm13 = { name = "zmm13", bits = 512, offset = 0, write_mode = "full" },
            ymm13 = { name = "ymm13", bits = 256, offset = 0 },
            xmm13 = { name = "xmm13", bits = 128, offset = 0 },
        },
        alias_order = { "zmm13", "ymm13", "xmm13" },
    },

    zmm14 = {
        canonical = "zmm14",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm14 = { name = "zmm14", bits = 512, offset = 0, write_mode = "full" },
            ymm14 = { name = "ymm14", bits = 256, offset = 0 },
            xmm14 = { name = "xmm14", bits = 128, offset = 0 },
        },
        alias_order = { "zmm14", "ymm14", "xmm14" },
    },

    zmm15 = {
        canonical = "zmm15",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm15 = { name = "zmm15", bits = 512, offset = 0, write_mode = "full" },
            ymm15 = { name = "ymm15", bits = 256, offset = 0 },
            xmm15 = { name = "xmm15", bits = 128, offset = 0 },
        },
        alias_order = { "zmm15", "ymm15", "xmm15" },
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

        -- Vector registers
        { name = "zmm0",  kind = "vector", role = "vector register", family = "zmm0" },
        { name = "zmm1",  kind = "vector", role = "vector register", family = "zmm1" },
        { name = "zmm2",  kind = "vector", role = "vector register", family = "zmm2" },
        { name = "zmm3",  kind = "vector", role = "vector register", family = "zmm3" },
        { name = "zmm4",  kind = "vector", role = "vector register", family = "zmm4" },
        { name = "zmm5",  kind = "vector", role = "vector register", family = "zmm5" },
        { name = "zmm6",  kind = "vector", role = "vector register", family = "zmm6" },
        { name = "zmm7",  kind = "vector", role = "vector register", family = "zmm7" },
        { name = "zmm8",  kind = "vector", role = "vector register", family = "zmm8" },
        { name = "zmm9",  kind = "vector", role = "vector register", family = "zmm9" },
        { name = "zmm10", kind = "vector", role = "vector register", family = "zmm10" },
        { name = "zmm11", kind = "vector", role = "vector register", family = "zmm11" },
        { name = "zmm12", kind = "vector", role = "vector register", family = "zmm12" },
        { name = "zmm13", kind = "vector", role = "vector register", family = "zmm13" },
        { name = "zmm14", kind = "vector", role = "vector register", family = "zmm14" },
        { name = "zmm15", kind = "vector", role = "vector register", family = "zmm15" },
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
