-- lua/tracker_hud/adapters/cpp/adapter.lua
-- C++ structural baseline; extend the shared C grammar subset without
-- modifying the C adapter or the shared Tracker_HUD context/renderer.

local M = vim.deepcopy(require("tracker_hud.adapters.c.adapter"))

M.name = "cpp"
M.filetypes = { "cpp" }
M.active_targets = {
    architecture = "unknown",
    platform = "unknown",
    abi = "unknown",
    syntax = "cpp",
    mode = "compiled",
}

local function add_construct(node_type, kind, language_term, label, fields, scope_kind)
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
    M.construct_specs[node_type] = spec
end

add_construct("namespace_definition", "namespace", "namespace", "Namespace",
    { name = "name", body = "body" }, "lexical")
add_construct("class_specifier", "class", "class", "Class",
    { name = "name", body = "body" }, "lexical")
add_construct("template_declaration", "declaration", "template", "Template",
    { parameters = "parameters" }, nil)
add_construct("access_specifier", "declaration", "access specifier", "Access", nil, nil)
add_construct("alias_declaration", "type", "type alias", "Type Alias",
    { name = "name", type = "type" }, nil)
add_construct("using_declaration", "declaration", "using declaration", "Using", nil, nil)
add_construct("lambda_expression", "function", "lambda", "Lambda",
    { body = "body" }, "lexical")
add_construct("new_expression", "call", "new expression", "New",
    { type = "type" }, nil)
add_construct("delete_expression", "call", "delete expression", "Delete", nil, nil)
add_construct("reference_declarator", "declaration", "reference declarator", "Reference",
    nil, nil)
add_construct("throw_statement", "call", "throw", "Throw", nil, nil)
add_construct("try_statement", "block", "try", "Try", nil, "structural")
add_construct("co_return_statement", "return", "co_return", "Co Return", nil, nil)

-- C++ class, namespace, and alias declarations add visible source symbols.
-- These are declarations, not claims about allocated objects or lifetimes.
local function member(node_type, name_field, kind, language_term, owner_scope)
    return {
        syntax = {
            node_type = node_type,
            fields = { name = name_field },
        },
        member = {
            kind = kind,
            language_term = language_term,
            owner_scope = owner_scope,
        },
    }
end

table.insert(M.scope_members.types,
    member("class_specifier", "name", "symbol", "class", "parent_lexical"))
table.insert(M.scope_members.types,
    member("alias_declaration", "name", "symbol", "type alias", "lexical"))
table.insert(M.scope_members.symbols,
    member("namespace_definition", "name", "symbol", "namespace", "parent_lexical"))

return M
