-- lua/tracker_hud/adapters/c/adapter.lua
-- C structural baseline for Adapter Contract v1.
-- Only source/Tree-sitter facts. No compiler execution or invented runtime state.
-- C and C++ share grammar constructs; the C++ adapter extends this base.

local M = {
    contract_version = 1,
    name = "c",
    filetypes = { "c" },
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

local function add_construct(node_type, kind, language_term, label, fields, scope_kind, signature)
    local spec = {
        syntax = { node_type = node_type },
        construct = {
            kind = kind,
            language_term = language_term,
            label = label,
        },
    }
    if fields then
        spec.syntax.fields = fields
    end
    if scope_kind then
        spec.scope = {
            kind = scope_kind,
            affects_visibility = true,
            owns_members = scope_kind == "lexical",
        }
    end
    if signature then
        spec.signature = { strategy = "first_line" }
    end
    M.construct_specs[node_type] = spec
end

add_construct("translation_unit", "module", "translation unit", "Translation Unit", nil, "lexical", false)
add_construct("function_definition", "function", "function", "Function", { declarator = "declarator", body = "body" }, "lexical", true)
add_construct("compound_statement", "block", "compound block", "Block", nil, "lexical", false)
add_construct("struct_specifier", "struct", "struct", "Struct", { name = "name", body = "body" }, "lexical", true)
add_construct("union_specifier", "union", "union", "Union", { name = "name", body = "body" }, "lexical", true)
add_construct("enum_specifier", "enum", "enum", "Enum", { name = "name", body = "body" }, nil, true)
add_construct("type_definition", "type", "typedef", "Typedef", { declarator = "declarator" }, nil, true)
add_construct("declaration", "declaration", "declaration", "Declaration", { declarator = "declarator" }, nil, false)
add_construct("init_declarator", "declaration", "initializer", "Initializer", { declarator = "declarator", value = "value" }, nil, false)
add_construct("field_declaration", "field", "field", "Field", { declarator = "declarator" }, nil, false)
add_construct("parameter_declaration", "parameter", "parameter", "Parameter", { declarator = "declarator" }, nil, false)
add_construct("if_statement", "branch", "if", "If", { condition = "condition", consequence = "consequence" }, "structural", false)
add_construct("else_clause", "branch", "else", "Else", nil, "structural", false)
add_construct("switch_statement", "branch", "switch", "Switch", nil, "structural", false)
add_construct("case_statement", "branch", "case", "Case", nil, "structural", false)
add_construct("for_statement", "loop", "for", "For", { body = "body" }, "structural", false)
add_construct("while_statement", "loop", "while", "While", { condition = "condition", body = "body" }, "structural", false)
add_construct("do_statement", "loop", "do while", "Do While", nil, "structural", false)
add_construct("assignment_expression", "assignment", "assignment", "Assignment", { left = "left", right = "right" }, nil, false)
add_construct("call_expression", "call", "function call", "Call", { function_name = "function", arguments = "arguments" }, nil, false)
add_construct("return_statement", "return", "return", "Return", nil, nil, false)
add_construct("preproc_include", "declaration", "include", "Include", { path = "path" }, nil, false)
add_construct("preproc_def", "declaration", "macro definition", "Macro", { name = "name" }, nil, false)
add_construct("identifier", "symbol", "identifier", "Identifier", nil, nil, false)
add_construct("field_identifier", "symbol", "field identifier", "Field Identifier", nil, nil, false)
add_construct("type_identifier", "type", "type identifier", "Type Identifier", nil, nil, false)
add_construct("number_literal", "literal", "number literal", "Number", nil, nil, false)
add_construct("string_literal", "literal", "string literal", "String", nil, nil, false)
add_construct("char_literal", "literal", "character literal", "Character", nil, nil, false)
add_construct("pointer_declarator", "declaration", "pointer declarator", "Pointer Declarator", { declarator = "declarator" }, nil, false)

-- Keep the named AST field as primary evidence. Parser versions can differ
-- in direct field exposure: precise named-node-type fallbacks are permitted
-- by each rule and used only when the field lookup doesn't produce a name.
local function member(node_type, name_field, kind, language_term, owner_scope, fallback)
    return {
        syntax = {
            node_type = node_type,
            fields = name_field and { name = name_field } or nil,
            children = fallback and { name = { node_type = fallback } } or nil,
        },
        member = {
            kind = kind,
            language_term = language_term,
            owner_scope = owner_scope,
        },
    }
end

-- A declaration can also be a function prototype. Keep its meaning neutral.
-- Do not claim inferred types, pointer values, or runtime state here.
M.scope_members = {
    functions = {
        member("function_definition", "declarator", "function", "function", "parent_lexical", "identifier"),
    },
    -- The generic parameters/list collector renders a whole declaration
    -- (e.g. "int amount") as a name, and can accidentally include the type.
    -- Using the existing symbol collector with the real declarator field
    -- reports the binding itself (e.g. "amount"). No shared-engine changes.
    -- Unnamed parameters are correctly omitted.
    -- The shared symbol collector consumes named Tree-sitter fields.
    -- C declarations include prototypes, so don't assume every one is a variable.
    symbols = {
        member("parameter_declaration", "declarator", "parameter", "parameter", "lexical", "identifier"),
        member("declaration", "declarator", "symbol", "declaration", "lexical", "identifier"),
        member("init_declarator", "declarator", "variable", "initialized variable", "lexical", "identifier"),
        member("type_definition", "declarator", "symbol", "typedef", "lexical"),
        -- The symbols collector currently collects inside the lexical scope.
        -- parent_lexical is only processed pre-scope for the functions group;
        -- on symbols it silently drops the entry. Keep struct/union names
        -- visible here without changing the shared collector.
        member("struct_specifier", "name", "symbol", "struct", "lexical", "type_identifier"),
        member("union_specifier", "name", "symbol", "union", "lexical", "type_identifier"),
        member("enum_specifier", "name", "symbol", "enum", "lexical", "type_identifier"),
        member("preproc_def", "name", "symbol", "macro", "lexical", "identifier"),
    },
    fields = {
        member("field_declaration", "declarator", "field", "field", "lexical", "field_identifier"),
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
