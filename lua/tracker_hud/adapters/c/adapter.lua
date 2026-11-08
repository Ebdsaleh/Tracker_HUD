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
    presentation = {
        sections = { order = { "scope", "scope_members", "warnings" } },
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

local function member(node_type, name_field, kind, language_term, owner_scope)
    return {
        syntax = {
            node_type = node_type,
            fields = name_field and { name = name_field } or nil,
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
        member("function_definition", "declarator", "function", "function", "parent_lexical"),
    },
    parameters = {
        member("parameter_declaration", "declarator", "parameter", "parameter", "lexical"),
    },
    declarations = {
        member("declaration", "declarator", "symbol", "declaration", "lexical"),
        member("init_declarator", "declarator", "variable", "initialized variable", "lexical"),
    },
    types = {
        member("type_definition", "declarator", "symbol", "typedef", "lexical"),
        member("struct_specifier", "name", "symbol", "struct", "parent_lexical"),
        member("union_specifier", "name", "symbol", "union", "parent_lexical"),
        member("enum_specifier", "name", "symbol", "enum", "lexical"),
    },
    fields = {
        member("field_declaration", "declarator", "field", "field", "lexical"),
    },
    symbols = {
        member("preproc_def", "name", "symbol", "macro", "lexical"),
    },
    assignments = {
        member("assignment_expression", "left", "assignment", "assignment", "lexical"),
    },
    returns = {
        member("return_statement", nil, "return_value", "return", "lexical"),
    },
}

return M
