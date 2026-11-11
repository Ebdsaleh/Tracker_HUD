-- lua/tracker_hud/adapters/asm/arch/x86_64/adapter.lua
--
-- x86-64 ASM variant description.
--
-- This file is spec-only. Shared hardware and target-overlay truth comes from
-- tracker_hud.architectures.x86_64; this module describes how ASM syntax and
-- instruction semantics expose that target.
--
-- It describes:
--   - ASM architecture aliases / target selection
--   - syntax and construct descriptions
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

local architecture_profile =
    assert(
        require("tracker_hud.architectures.registry").get(M.name),
        "missing shared x86-64 architecture profile"
    )

M.metadata = architecture_profile.metadata
M.platforms = architecture_profile.platforms
M.default_platform = architecture_profile.default_platform
M.platform_aliases = architecture_profile.platform_aliases
M.calling_conventions = architecture_profile.calling_conventions
M.register_roles = architecture_profile.register_roles


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

            memory = {
                kind = "memory",
                container_kind = "memory",
                address_kind = "address_expression",

                address_modes = {
                    rel = {
                        kind = "relative",
                    },
                    abs = {
                        kind = "absolute",
                    },
                },

                address_size_policy = {
                    default_bits = 64,
                    allowed_bits = {
                        32,
                        64,
                    },
                    register_width_map = {
                        [32] = 32,
                        [64] = 64,
                    },
                },

                brackets = {
                    open = "[",
                    close = "]",
                },

                size_prefixes = {
                    byte = { bits = 8, label = "byte" },
                    word = { bits = 16, label = "word" },
                    dword = { bits = 32, label = "doubleword" },
                    qword = { bits = 64, label = "quadword" },
                    tword = { bits = 80, label = "ten-byte" },
                    oword = { bits = 128, label = "octword" },
                    yword = { bits = 256, label = "YMM word" },
                    zword = { bits = 512, label = "ZMM word" },
                },

                component_roles = {
                    base_register = {
                        label = "base register",
                        kind = "register",
                    },

                    index_register = {
                        label = "index register",
                        kind = "register",
                    },

                    scale = {
                        label = "scale",
                        kind = "integer",
                    },

                    displacement = {
                        label = "displacement",
                        kind = "integer",
                    },

                    symbol = {
                        label = "symbol",
                        kind = "symbol",
                    },
                },

                register_role_overrides = {
                    rip = "instruction pointer relative base",
                    eip = "instruction pointer relative base",
                    rsp = "stack pointer base",
                    esp = "stack pointer base",
                    sp = "stack pointer base",
                    rbp = "frame pointer base",
                    ebp = "frame pointer base",
                    bp = "frame pointer base",
                },
            },
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

M.memory_accesses = require(
    "tracker_hud.adapters.asm.arch.x86_64.memory_accesses"
)


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
        source = "events",
        check = "missing_read_value",
        severity = "state",

        match = {
            kind = "conditional_branch_event",
        },

        read = {
            role = "condition_flags",
        },

        category = "control_flow",
        message = "conditional branch {name} reads unknown condition flags",
    },

    {
        source = "events",
        check = "missing_read_value",
        severity = "state",

        match = {
            kind = "counter_branch_event",
        },

        read = {
            role = "counter",
        },

        category = "control_flow",
        message = "{name} reads unknown counter register {register}",
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


-- The target CPU owns registers/aliases; ASM supplies their syntax/effects.
-- Keep these exact adapter fields for all existing context/Registers consumers.
M.register_families = architecture_profile.register_families
M.registers = architecture_profile.registers
M.register_alias_index = architecture_profile.register_alias_index

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
