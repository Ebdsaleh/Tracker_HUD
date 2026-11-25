-- lua/tracker_hud/adapters/c/adapter.lua
-- C structural baseline for Adapter Contract v1.
-- Only source/Tree-sitter facts. No compiler execution or invented runtime state.
-- C and C++ share grammar constructs; the C++ adapter extends this base.

local target_directives = require("tracker_hud.adapters.c.target_directives")
local scope_member_schema = require("tracker_hud.adapters.scope_member_schema")
local construct_schema = require("tracker_hud.adapters.construct_schema")

local M = {
    contract_version = 1,
    name = "c",
    filetypes = { "c" },
    target_directives = vim.deepcopy(target_directives.target_directives),
    directive_comment_prefixes = { "//" },
    active_targets = {
        architecture = "unknown",
        platform = "unknown",
        abi = "unknown",
        syntax = "c",
        mode = "compiled",
    },
    capabilities = {
        lexical_scopes = true,
        structural_scopes = true,
        members = true,
        values = true,
        source_jump = true,
    },
    -- These are persistent HUD inspection surfaces, like the ASM adapter's
    -- sections. Exposure does not assert machine-register, stack-frame, or
    -- heap-allocation facts before the compiler/flow analysis proves them.
    -- A source-level C file is not enough to identify physical registers.
    sections = {
        registers = { id = "registers", label = "Registers" },
        events = { id = "events", label = "Events" },
        stack = { id = "stack", label = "Stack" },
        heap = { id = "heap", label = "Heap" },
    },
    presentation = {
        sections = {
            order = {
                "scope", "scope_members", "registers",
                "events", "stack", "heap", "warnings",
            },
        },
    },
    construct_specs = {},
    scope_members = {},
}

-- Keep this callback bound to the C adapter, not to a shared config module.
-- C++ deep-copies this adapter and explicitly overrides this callback.
function M.configure_adapter_for_buffer(bufnr, config)
    M.active_targets = target_directives.resolve(bufnr, config, "c")
end

construct_schema.define(
    M.construct_specs,
    "translation_unit",
    "module",
    {
        language_term = "translation unit",
        label = "Translation Unit",
        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "function_definition",
    "function",
    {
        language_term = "function",
        label = "Function",
        fields = {
            declarator = "declarator",
            body = "body",
        },
        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
        signature = {
            strategy = "first_line",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "compound_statement",
    "block",
    {
        language_term = "compound block",
        label = "Block",
        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "struct_specifier",
    "struct",
    {
        language_term = "struct",
        label = "Struct",
        fields = {
            name = "name",
            body = "body",
        },
        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
        signature = {
            strategy = "first_line",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "union_specifier",
    "union",
    {
        language_term = "union",
        label = "Union",
        fields = {
            name = "name",
            body = "body",
        },
        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
        signature = {
            strategy = "first_line",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "enum_specifier",
    "enum",
    {
        language_term = "enum",
        label = "Enum",
        fields = {
            name = "name",
            body = "body",
        },
        signature = {
            strategy = "first_line",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "type_definition",
    "type",
    {
        language_term = "typedef",
        label = "Typedef",
        fields = {
            declarator = "declarator",
        },
        signature = {
            strategy = "first_line",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "declaration",
    "declaration",
    {
        language_term = "declaration",
        label = "Declaration",
        fields = {
            declarator = "declarator",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "init_declarator",
    "declaration",
    {
        language_term = "initializer",
        label = "Initializer",
        fields = {
            declarator = "declarator",
            value = "value",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "field_declaration",
    "field",
    {
        language_term = "field",
        label = "Field",
        fields = {
            declarator = "declarator",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "parameter_declaration",
    "parameter",
    {
        language_term = "parameter",
        label = "Parameter",
        fields = {
            declarator = "declarator",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "if_statement",
    "branch",
    {
        language_term = "if",
        label = "If",
        fields = {
            condition = "condition",
            consequence = "consequence",
        },
        scope = {
            kind = "structural",
            affects_visibility = true,
            owns_members = false,
        },
    }
)
for _, definition in ipairs({
    { "else_clause", "branch", "else", "Else" },
    { "switch_statement", "branch", "switch", "Switch" },
    { "case_statement", "branch", "case", "Case" },
}) do
    construct_schema.define(
        M.construct_specs,
        definition[1],
        definition[2],
        {
            language_term = definition[3],
            label = definition[4],
            scope = {
                kind = "structural",
                affects_visibility = true,
                owns_members = false,
            },
        }
    )
end
construct_schema.define(
    M.construct_specs,
    "for_statement",
    "loop",
    {
        language_term = "for",
        label = "For",
        fields = {
            body = "body",
        },
        scope = {
            kind = "structural",
            affects_visibility = true,
            owns_members = false,
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "while_statement",
    "loop",
    {
        language_term = "while",
        label = "While",
        fields = {
            condition = "condition",
            body = "body",
        },
        scope = {
            kind = "structural",
            affects_visibility = true,
            owns_members = false,
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "do_statement",
    "loop",
    {
        language_term = "do while",
        label = "Do While",
        scope = {
            kind = "structural",
            affects_visibility = true,
            owns_members = false,
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "assignment_expression",
    "assignment",
    {
        language_term = "assignment",
        label = "Assignment",
        fields = {
            left = "left",
            right = "right",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "call_expression",
    "call",
    {
        language_term = "function call",
        label = "Call",
        fields = {
            function_name = "function",
            arguments = "arguments",
        },
    }
)
for _, definition in ipairs({
    { "return_statement", "return", "return", "Return" },
    { "identifier", "symbol", "identifier", "Identifier" },
    { "field_identifier", "symbol", "field identifier", "Field Identifier" },
    { "type_identifier", "type", "type identifier", "Type Identifier" },
    { "number_literal", "literal", "number literal", "Number" },
    { "string_literal", "literal", "string literal", "String" },
    { "char_literal", "literal", "character literal", "Character" },
}) do
    construct_schema.define(
        M.construct_specs,
        definition[1],
        definition[2],
        {
            language_term = definition[3],
            label = definition[4],
        }
    )
end
construct_schema.define(
    M.construct_specs,
    "preproc_include",
    "declaration",
    {
        language_term = "include",
        label = "Include",
        fields = {
            path = "path",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "preproc_def",
    "declaration",
    {
        language_term = "macro definition",
        label = "Macro",
        fields = {
            name = "name",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "pointer_declarator",
    "declaration",
    {
        language_term =
            "pointer declarator",
        label = "Pointer Declarator",
        fields = {
            declarator = "declarator",
        },
    }
)

-- Keep the named AST field as primary evidence. Parser versions can differ
-- in direct field exposure, so named-binding specs can declare an exact AST
-- fallback without duplicating the Adapter Contract table shape here.

-- A declaration can also be a function prototype. Keep its meaning neutral.
-- Do not claim inferred types, pointer values, or runtime state here.
M.scope_members = {
    functions = {
        scope_member_schema.named(
            "function_definition",
            "declarator",
            "function",
            {
                owner_scope =
                    "parent_lexical",
                fallback_node_type =
                    "identifier",
            }
        ),
    },
    -- The generic parameters/list collector renders a whole declaration
    -- (e.g. "int amount") as a name, and can accidentally include the type.
    -- Using the existing symbol collector with the real declarator field
    -- reports the binding itself (e.g. "amount"). No shared-engine changes.
    -- Unnamed parameters are correctly omitted.
    -- The shared symbol collector consumes named Tree-sitter fields.
    -- C declarations include prototypes, so don't assume every one is a variable.
    symbols = {
        -- Only direct function-definition parameters establish bindings
        -- for this role. Prototype and other parameter observations retain
        -- their ownership without shadow eligibility. Normalize simple
        -- pointer declarators through their declared identifier field.
        scope_member_schema.named(
            "parameter_declaration",
            {
                field = "declarator",
                recursive = {
                    field = "declarator",
                    terminal_node_types = { "identifier" },
                    container_node_types = { "pointer_declarator" },
                },
            },
            "parameter",
            {
                binding_mutability =
                    "unknown",
                fallback_node_type =
                    "identifier",
                constraints = {
                    parent_path = {
                        "parameter_list",
                        "function_declarator",
                        "function_definition",
                    },
                },
            }
        ),
        scope_member_schema.named(
            "parameter_declaration",
            {
                field = "declarator",
                recursive = {
                    field = "declarator",
                    terminal_node_types = { "identifier" },
                    container_node_types = { "pointer_declarator" },
                },
            },
            "parameter",
            {
                fallback_node_type =
                    "identifier",
                exclusions = {
                    parent_path = {
                        "parameter_list",
                        "function_declarator",
                        "function_definition",
                    },
                },
            }
        ),
        -- Match only the exact initializer parent chain. Ordinary declarations
        -- inside the loop body keep lexical ownership, and an expired header
        -- binding cannot fall through to an unbounded ordinary rule.
        scope_member_schema.named(
            "declaration",
            "declarator",
            "symbol",
            {
                language_term =
                    "for declaration",
                fallback_node_type =
                    "identifier",
                constraints = {
                    parent_path = { "for_statement" },
                },
                visibility_range =
                    "structural_scope",
            }
        ),
        scope_member_schema.named(
            "declaration",
            "declarator",
            "symbol",
            {
                language_term =
                    "declaration",
                fallback_node_type =
                    "identifier",
                exclusions = {
                    parent_path = { "for_statement" },
                },
            }
        ),
        -- Initialized variables are source bindings, but these rules do not
        -- distinguish const qualification or prove runtime mutability.
        scope_member_schema.named(
            "init_declarator",
            "declarator",
            "variable",
            {
                language_term =
                    "for initialized variable",
                binding_mutability =
                    "unknown",
                fallback_node_type =
                    "identifier",
                constraints = {
                    parent_path = { "declaration", "for_statement" },
                },
                visibility_range =
                    "structural_scope",
            }
        ),
        scope_member_schema.named(
            "init_declarator",
            "declarator",
            "variable",
            {
                language_term =
                    "initialized variable",
                binding_mutability =
                    "unknown",
                fallback_node_type =
                    "identifier",
                exclusions = {
                    parent_path = { "declaration", "for_statement" },
                },
            }
        ),
        scope_member_schema.named(
            "type_definition",
            "declarator",
            "symbol",
            {
                language_term =
                    "typedef",
            }
        ),
        -- The symbols collector currently collects inside the lexical scope.
        -- parent_lexical is only processed pre-scope for the functions group;
        -- on symbols it silently drops the entry. Keep struct/union names
        -- visible here without changing the shared collector.
        scope_member_schema.named(
            "struct_specifier",
            "name",
            "symbol",
            {
                language_term =
                    "struct",
                fallback_node_type =
                    "type_identifier",
            }
        ),
        scope_member_schema.named(
            "union_specifier",
            "name",
            "symbol",
            {
                language_term =
                    "union",
                fallback_node_type =
                    "type_identifier",
            }
        ),
        scope_member_schema.named(
            "enum_specifier",
            "name",
            "symbol",
            {
                language_term =
                    "enum",
                fallback_node_type =
                    "type_identifier",
            }
        ),
        scope_member_schema.named(
            "preproc_def",
            "name",
            "symbol",
            {
                language_term =
                    "macro",
                fallback_node_type =
                    "identifier",
            }
        ),
    },
    fields = {
        scope_member_schema.named(
            "field_declaration",
            "declarator",
            "field",
            {
                fallback_node_type =
                    "field_identifier",
            }
        ),
        {
            syntax = {
                node_type = "assignment_expression",
                fields = { name = "left", value = "right" },
            },
            member = {
                kind = "assignment",
                language_term = "assignment",
                owner_scope = "lexical",
            },
        },
    },
}

return M
