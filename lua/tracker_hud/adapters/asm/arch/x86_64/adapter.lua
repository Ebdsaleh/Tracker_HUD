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
        syntax = {
            node_type = "label",

            fields = {
                name = "name",
            },

            children = {
                name = {
                    node_types = {
                        "ident",
                        "word",
                    },
                    optional = true,
                },
            },

            tokens = {
                terminator = ":",
                declaration = "label",
            },
        },

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
        syntax = {
            node_type = "label",

            fields = {
                name = "name",
            },

            children = {
                name = {
                    node_types = {
                        "ident",
                        "word",
                    },
                    optional = true,
                },
            },

            tokens = {
                terminator = ":",
                declaration = "label",
            },
        },

        construct = {
            kind = "label",
            language_term = "label",
            label = "Label",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        value = {
            kind = "reference",
            language_term = "label",
            type_label = "label",
        },
    },

    ["instruction"] = {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = "kind",
            },

            children = {
                kind = {
                    node_type = "word",
                },

                operands = {
                    node_types = {
                        "ptr",
                        "ident",
                        "int",
                        "string",
                        "float",
                        "list",
                        "tc_infix",
                        "reg",
                    },
                    multiple = true,
                    optional = true,
                },
            },

            tokens = {
                operand_separator = ",",
            },
        },

        construct = {
            kind = "instruction",
            language_term = "instruction",
            label = "Instruction",
        },

        scope = {
            kind = "structural",
            affects_visibility = false,
            owns_members = false,
        },

        value = {
            kind = "unknown",
            language_term = "instruction",
            type_label = "instruction",
        },
    },

    ["reg"] = {
        syntax = {
            node_type = "reg",

            children = {
                value = {
                    node_types = {
                        "word",
                        "address",
                    },
                    optional = true,
                },
            },
        },

        construct = {
            kind = "register",
            language_term = "register",
            label = "Register",
        },

        value = {
            kind = "reference",
            language_term = "register",
            type_label = "register",
        },

        operand = {
            kind = "register",
        },
    },

    ["int"] = {
        syntax = {
            node_type = "int",
        },

        construct = {
            kind = "immediate",
            language_term = "immediate",
            label = "Immediate",
        },

        value = {
            kind = "scalar",
            language_term = "integer",
            type_label = "integer",
        },

        operand = {
            kind = "integer",
        },
    },

    ["ident"] = {
        syntax = {
            node_type = "ident",

            children = {
                register = {
                    node_type = "reg",
                    optional = true,
                },
            },
        },

        construct = {
            kind = "symbol",
            language_term = "symbol",
            label = "Symbol",
        },

        value = {
            kind = "reference",
            language_term = "symbol",
            type_label = "symbol",
        },

        operand = {
            kind = "symbol",

            descendant_overrides = {
                reg = "register",
            },
        },
    },

    ["word"] = {
        syntax = {
            node_type = "word",
        },

        construct = {
            kind = "mnemonic",
            language_term = "mnemonic",
            label = "Mnemonic",
        },

        value = {
            kind = "symbol",
            language_term = "mnemonic",
            type_label = "instruction",
        },

        operand = {
            kind = "symbol",
        },
    },

    ["ptr"] = {
        syntax = {
            node_type = "ptr",

            children = {
                registers = {
                    node_type = "reg",
                    multiple = true,
                },

                displacement = {
                    node_types = {
                        "int",
                        "ident",
                    },
                    optional = true,
                },
            },

            tokens = {
                open = "[",
                close = "]",
            },
        },

        construct = {
            kind = "operand",
            language_term = "memory operand",
            label = "Memory Operand",
        },

        value = {
            kind = "reference",
            language_term = "memory address",
            type_label = "memory",
        },

        operand = {
            kind = "memory",
        },
    },

    ["string"] = {
        syntax = {
            node_type = "string",
        },

        construct = {
            kind = "immediate",
            language_term = "string immediate",
            label = "String",
        },

        value = {
            kind = "scalar",
            language_term = "string",
            type_label = "string",
        },

        operand = {
            kind = "string",
        },
    },

    ["float"] = {
        syntax = {
            node_type = "float",
        },

        construct = {
            kind = "immediate",
            language_term = "floating-point immediate",
            label = "Float",
        },

        value = {
            kind = "scalar",
            language_term = "floating-point number",
            type_label = "float",
        },

        operand = {
            kind = "float",
        },
    },

    ["list"] = {
        syntax = {
            node_type = "list",

            children = {
                registers = {
                    node_type = "reg",
                    multiple = true,
                    optional = true,
                },
            },

            tokens = {
                open = "{",
                close = "}",
                separator = ",",
            },
        },

        construct = {
            kind = "operand",
            language_term = "register list",
            label = "Register List",
        },

        value = {
            kind = "unknown",
            language_term = "register list",
            type_label = "register list",
        },

        operand = {
            kind = "register_list",
        },
    },

    ["tc_infix"] = {
        syntax = {
            node_type = "tc_infix",

            fields = {
                lhs = "lhs",
                op = "op",
                rhs = "rhs",
            },
        },

        construct = {
            kind = "operand",
            language_term = "expression",
            label = "Expression",
        },

        value = {
            kind = "unknown",
            language_term = "expression",
            type_label = "expression",
        },

        operand = {
            kind = "expression",
        },
    },
}


M.scope_members = {
    symbols = {
        {
            syntax = {
                node_type = "label",

                fields = {
                    name = "name",
                },

                children = {
                    name = {
                        node_types = {
                            "ident",
                            "word",
                        },
                        optional = true,
                    },
                },
            },

            member = {
                kind = "label",
                language_term = "label",
                owner_scope = "lexical",
            },

            value = {
                kind = "symbol",
                language_term = "label",
                type_label = "label",
            },
        },

        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = "kind",
                },

                children = {
                    kind = {
                        node_type = "word",
                    },

                    operands = {
                        node_types = {
                            "ptr",
                            "ident",
                            "int",
                            "string",
                            "float",
                            "list",
                            "tc_infix",
                            "reg",
                        },
                        multiple = true,
                        optional = true,
                    },
                },
            },

            mnemonic = "global",
            operand_index = 1,

            member = {
                kind = "global",
                language_term = "global",
                owner_scope = "lexical",
            },

            value = {
                kind = "symbol",
                language_term = "global symbol",
                type_label = "global",
            },
        },
    },

    declarations = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = "kind",
                },

                children = {
                    kind = {
                        node_type = "word",
                    },

                    operands = {
                        node_types = {
                            "ptr",
                            "ident",
                            "int",
                            "string",
                            "float",
                            "list",
                            "tc_infix",
                            "reg",
                        },
                        multiple = true,
                        optional = true,
                    },
                },
            },

            member = {
                kind = "instruction",
                language_term = "instruction",
                owner_scope = "lexical",
            },
        },
    },
}



M.register_effects = require("tracker_hud.adapters.asm.arch.x86_64.register_effects")


M.stack_effects = require(
    "tracker_hud.adapters.asm.arch.x86_64.stack_effects"
)


M.instruction_events = require("tracker_hud.adapters.asm.arch.x86_64.instruction_events")


M.boundary_effects = require(
    "tracker_hud.adapters.asm.arch.x86_64.boundary_effects"
)


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

    {
        source = "stack",
        check = "unresolved_stack_read",
        severity = "state",

        match = {
            kind = "stack_pop",
        },

        category = "stack",
        message = "pop into {destination_register} reads an unknown stack value",
    },

    {
        source = "stack",
        check = "unresolved_stack_read",
        severity = "state",

        match = {
            kind = "stack_return",
        },

        category = "stack",
        message = "return reads an unknown return address from the stack",
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

    zmm16 = {
        canonical = "zmm16",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm16 = { name = "zmm16", bits = 512, offset = 0, write_mode = "full" },
            ymm16 = { name = "ymm16", bits = 256, offset = 0 },
            xmm16 = { name = "xmm16", bits = 128, offset = 0 },
        },
        alias_order = { "zmm16", "ymm16", "xmm16" },
    },

    zmm17 = {
        canonical = "zmm17",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm17 = { name = "zmm17", bits = 512, offset = 0, write_mode = "full" },
            ymm17 = { name = "ymm17", bits = 256, offset = 0 },
            xmm17 = { name = "xmm17", bits = 128, offset = 0 },
        },
        alias_order = { "zmm17", "ymm17", "xmm17" },
    },

    zmm18 = {
        canonical = "zmm18",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm18 = { name = "zmm18", bits = 512, offset = 0, write_mode = "full" },
            ymm18 = { name = "ymm18", bits = 256, offset = 0 },
            xmm18 = { name = "xmm18", bits = 128, offset = 0 },
        },
        alias_order = { "zmm18", "ymm18", "xmm18" },
    },

    zmm19 = {
        canonical = "zmm19",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm19 = { name = "zmm19", bits = 512, offset = 0, write_mode = "full" },
            ymm19 = { name = "ymm19", bits = 256, offset = 0 },
            xmm19 = { name = "xmm19", bits = 128, offset = 0 },
        },
        alias_order = { "zmm19", "ymm19", "xmm19" },
    },

    zmm20 = {
        canonical = "zmm20",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm20 = { name = "zmm20", bits = 512, offset = 0, write_mode = "full" },
            ymm20 = { name = "ymm20", bits = 256, offset = 0 },
            xmm20 = { name = "xmm20", bits = 128, offset = 0 },
        },
        alias_order = { "zmm20", "ymm20", "xmm20" },
    },

    zmm21 = {
        canonical = "zmm21",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm21 = { name = "zmm21", bits = 512, offset = 0, write_mode = "full" },
            ymm21 = { name = "ymm21", bits = 256, offset = 0 },
            xmm21 = { name = "xmm21", bits = 128, offset = 0 },
        },
        alias_order = { "zmm21", "ymm21", "xmm21" },
    },

    zmm22 = {
        canonical = "zmm22",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm22 = { name = "zmm22", bits = 512, offset = 0, write_mode = "full" },
            ymm22 = { name = "ymm22", bits = 256, offset = 0 },
            xmm22 = { name = "xmm22", bits = 128, offset = 0 },
        },
        alias_order = { "zmm22", "ymm22", "xmm22" },
    },

    zmm23 = {
        canonical = "zmm23",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm23 = { name = "zmm23", bits = 512, offset = 0, write_mode = "full" },
            ymm23 = { name = "ymm23", bits = 256, offset = 0 },
            xmm23 = { name = "xmm23", bits = 128, offset = 0 },
        },
        alias_order = { "zmm23", "ymm23", "xmm23" },
    },

    zmm24 = {
        canonical = "zmm24",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm24 = { name = "zmm24", bits = 512, offset = 0, write_mode = "full" },
            ymm24 = { name = "ymm24", bits = 256, offset = 0 },
            xmm24 = { name = "xmm24", bits = 128, offset = 0 },
        },
        alias_order = { "zmm24", "ymm24", "xmm24" },
    },

    zmm25 = {
        canonical = "zmm25",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm25 = { name = "zmm25", bits = 512, offset = 0, write_mode = "full" },
            ymm25 = { name = "ymm25", bits = 256, offset = 0 },
            xmm25 = { name = "xmm25", bits = 128, offset = 0 },
        },
        alias_order = { "zmm25", "ymm25", "xmm25" },
    },

    zmm26 = {
        canonical = "zmm26",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm26 = { name = "zmm26", bits = 512, offset = 0, write_mode = "full" },
            ymm26 = { name = "ymm26", bits = 256, offset = 0 },
            xmm26 = { name = "xmm26", bits = 128, offset = 0 },
        },
        alias_order = { "zmm26", "ymm26", "xmm26" },
    },

    zmm27 = {
        canonical = "zmm27",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm27 = { name = "zmm27", bits = 512, offset = 0, write_mode = "full" },
            ymm27 = { name = "ymm27", bits = 256, offset = 0 },
            xmm27 = { name = "xmm27", bits = 128, offset = 0 },
        },
        alias_order = { "zmm27", "ymm27", "xmm27" },
    },

    zmm28 = {
        canonical = "zmm28",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm28 = { name = "zmm28", bits = 512, offset = 0, write_mode = "full" },
            ymm28 = { name = "ymm28", bits = 256, offset = 0 },
            xmm28 = { name = "xmm28", bits = 128, offset = 0 },
        },
        alias_order = { "zmm28", "ymm28", "xmm28" },
    },

    zmm29 = {
        canonical = "zmm29",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm29 = { name = "zmm29", bits = 512, offset = 0, write_mode = "full" },
            ymm29 = { name = "ymm29", bits = 256, offset = 0 },
            xmm29 = { name = "xmm29", bits = 128, offset = 0 },
        },
        alias_order = { "zmm29", "ymm29", "xmm29" },
    },

    zmm30 = {
        canonical = "zmm30",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm30 = { name = "zmm30", bits = 512, offset = 0, write_mode = "full" },
            ymm30 = { name = "ymm30", bits = 256, offset = 0 },
            xmm30 = { name = "xmm30", bits = 128, offset = 0 },
        },
        alias_order = { "zmm30", "ymm30", "xmm30" },
    },

    zmm31 = {
        canonical = "zmm31",
        bits = 512,
        kind = "vector",
        role = "vector register",
        aliases = {
            zmm31 = { name = "zmm31", bits = 512, offset = 0, write_mode = "full" },
            ymm31 = { name = "ymm31", bits = 256, offset = 0 },
            xmm31 = { name = "xmm31", bits = 128, offset = 0 },
        },
        alias_order = { "zmm31", "ymm31", "xmm31" },
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
        { name = "zmm16", kind = "vector", role = "vector register", family = "zmm16" },
        { name = "zmm17", kind = "vector", role = "vector register", family = "zmm17" },
        { name = "zmm18", kind = "vector", role = "vector register", family = "zmm18" },
        { name = "zmm19", kind = "vector", role = "vector register", family = "zmm19" },
        { name = "zmm20", kind = "vector", role = "vector register", family = "zmm20" },
        { name = "zmm21", kind = "vector", role = "vector register", family = "zmm21" },
        { name = "zmm22", kind = "vector", role = "vector register", family = "zmm22" },
        { name = "zmm23", kind = "vector", role = "vector register", family = "zmm23" },
        { name = "zmm24", kind = "vector", role = "vector register", family = "zmm24" },
        { name = "zmm25", kind = "vector", role = "vector register", family = "zmm25" },
        { name = "zmm26", kind = "vector", role = "vector register", family = "zmm26" },
        { name = "zmm27", kind = "vector", role = "vector register", family = "zmm27" },
        { name = "zmm28", kind = "vector", role = "vector register", family = "zmm28" },
        { name = "zmm29", kind = "vector", role = "vector register", family = "zmm29" },
        { name = "zmm30", kind = "vector", role = "vector register", family = "zmm30" },
        { name = "zmm31", kind = "vector", role = "vector register", family = "zmm31" },
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
