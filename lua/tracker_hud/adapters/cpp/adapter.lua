-- lua/tracker_hud/adapters/cpp/adapter.lua
-- C++ structural baseline; extend the shared C grammar subset without
-- modifying the C adapter or the shared Tracker_HUD context/renderer.

local M = vim.deepcopy(require("tracker_hud.adapters.c.adapter"))
local target_directives = require("tracker_hud.adapters.c.target_directives")

M.name = "cpp"
M.filetypes = { "cpp" }
M.active_targets = {
    architecture = "unknown",
    platform = "unknown",
    abi = "unknown",
    syntax = "cpp",
    mode = "compiled",
}

-- Do not inherit the C function closure: it captures the original C adapter
-- table and would update C's targets rather than this C++ adapter.
function M.configure_adapter_for_buffer(bufnr, config)
    M.active_targets = target_directives.resolve(bufnr, config, "cpp")
end

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
add_construct("optional_parameter_declaration", "parameter",
    "defaulted parameter", "Defaulted Parameter",
    { declarator = "declarator", default_value = "default_value" }, nil)
add_construct("variadic_parameter_declaration", "parameter",
    "variadic parameter", "Variadic Parameter",
    { declarator = "declarator" }, nil)
add_construct("reference_declarator", "declaration", "reference declarator", "Reference",
    nil, nil)
add_construct("for_range_loop", "loop", "range-for", "Range For",
    { declarator = "declarator", right = "right", body = "body" }, "structural")
add_construct("throw_statement", "call", "throw", "Throw", nil, nil)
add_construct("try_statement", "block", "try", "Try", nil, "structural")
add_construct("co_return_statement", "return", "co_return", "Co Return", nil, nil)

-- C++ class, namespace, and alias declarations add visible source symbols.
-- These are declarations, not claims about allocated objects or lifetimes.
local function member(node_type, name_field, kind, language_term, owner_scope, fallback)
    return {
        syntax = {
            node_type = node_type,
            fields = { name = name_field },
            children = fallback and { name = { node_type = fallback } } or nil,
        },
        member = {
            kind = kind,
            language_term = language_term,
            owner_scope = owner_scope,
        },
    }
end

-- C++ adds defaulted and variadic parameter syntax nodes beyond C's
-- parameter_declaration. Extract just the declared binding from each one.
table.insert(M.scope_members.symbols,
    member("optional_parameter_declaration", "declarator",
        "parameter", "defaulted parameter", "lexical", "identifier"))
table.insert(M.scope_members.symbols,
    member("variadic_parameter_declaration", "declarator",
        "parameter", "variadic parameter", "lexical", "identifier"))

-- The generic symbols collector runs after entering lexical scopes and
-- skips parent_lexical specs. Until the shared contract grows explicit
-- ownership handling, keep these declarations discoverable locally instead.
table.insert(M.scope_members.symbols,
    member("class_specifier", "name", "symbol", "class", "lexical", "type_identifier"))
table.insert(M.scope_members.symbols,
    member("alias_declaration", "name", "symbol", "type alias", "lexical", "type_identifier"))
table.insert(M.scope_members.symbols,
    member("namespace_definition", "name", "symbol", "namespace", "lexical", "namespace_identifier"))
M.scope_members.loops = {
    member("for_range_loop", "declarator", "loop_variable", "range-for variable", "lexical", "identifier"),
}

return M
