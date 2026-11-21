-- lua/tracker_hud/adapters/cpp/adapter.lua
-- C++ structural baseline; extend the shared C grammar subset without
-- modifying the C adapter or the shared Tracker_HUD context/renderer.

local M = vim.deepcopy(require("tracker_hud.adapters.c.adapter"))
local target_directives = require("tracker_hud.adapters.c.target_directives")
local scope_member_schema = require("tracker_hud.adapters.scope_member_schema")
local construct_schema = require("tracker_hud.adapters.construct_schema")

M.name = "cpp"
M.filetypes = { "cpp" }
M.target_directives.standard = "standard"
M.target_dimensions = {
    standard = {
        default = "cpp17",
        supported = {
            "cpp98",
            "cpp03",
            "cpp11",
            "cpp14",
            "cpp17",
            "cpp20",
            "cpp23",
        },
        aliases = {
            ["c++98"] = "cpp98",
            ["c++03"] = "cpp03",
            ["c++11"] = "cpp11",
            ["c++14"] = "cpp14",
            ["c++17"] = "cpp17",
            ["c++20"] = "cpp20",
            ["c++23"] = "cpp23",
            ["98"] = "cpp98",
            ["03"] = "cpp03",
            ["11"] = "cpp11",
            ["14"] = "cpp14",
            ["17"] = "cpp17",
            ["20"] = "cpp20",
            ["23"] = "cpp23",
        },
    },
}
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
    M.active_targets =
        target_directives.resolve(
            bufnr,
            config,
            "cpp",
            M.target_dimensions
        )
end

construct_schema.define(
    M.construct_specs,
    "namespace_definition",
    "namespace",
    {
        language_term = "namespace",
        label = "Namespace",
        fields = {
            name = "name",
            body = "body",
        },
        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "class_specifier",
    "class",
    {
        language_term = "class",
        label = "Class",
        fields = {
            name = "name",
            body = "body",
        },
        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "template_declaration",
    "declaration",
    {
        language_term = "template",
        label = "Template",
        fields = {
            parameters = "parameters",
        },
    }
)
for _, definition in ipairs({
    { "access_specifier", "declaration", "access specifier", "Access" },
    { "using_declaration", "declaration", "using declaration", "Using" },
    { "delete_expression", "call", "delete expression", "Delete" },
    { "reference_declarator", "declaration", "reference declarator", "Reference" },
    { "throw_statement", "call", "throw", "Throw" },
    { "co_return_statement", "return", "co_return", "Co Return" },
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
    "alias_declaration",
    "type",
    {
        language_term = "type alias",
        label = "Type Alias",
        fields = {
            name = "name",
            type = "type",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "lambda_expression",
    "function",
    {
        language_term = "lambda",
        label = "Lambda",
        fields = {
            body = "body",
        },
        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp11",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "new_expression",
    "call",
    {
        language_term =
            "new expression",
        label = "New",
        fields = {
            type = "type",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "optional_parameter_declaration",
    "parameter",
    {
        language_term =
            "defaulted parameter",
        label = "Defaulted Parameter",
        fields = {
            declarator = "declarator",
            default_value =
                "default_value",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "variadic_parameter_declaration",
    "parameter",
    {
        language_term =
            "variadic parameter",
        label = "Variadic Parameter",
        fields = {
            declarator = "declarator",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "for_range_loop",
    "loop",
    {
        language_term = "range-for",
        label = "Range For",
        fields = {
            declarator = "declarator",
            right = "right",
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
    "try_statement",
    "block",
    {
        language_term = "try",
        label = "Try",
        scope = {
            kind = "structural",
            affects_visibility = true,
            owns_members = false,
        },
    }
)

-- C++ class, namespace, and alias declarations add visible source symbols.
-- These are declarations, not claims about allocated objects or lifetimes.

-- C++ adds defaulted and variadic parameter syntax nodes beyond C's
-- parameter_declaration. Extract just the declared binding from each one.
table.insert(
    M.scope_members.symbols,
    scope_member_schema.named(
        "optional_parameter_declaration",
        "declarator",
        "parameter",
        {
            language_term =
                "defaulted parameter",
            fallback_node_type =
                "identifier",
        }
    )
)
table.insert(
    M.scope_members.symbols,
    scope_member_schema.named(
        "variadic_parameter_declaration",
        "declarator",
        "parameter",
        {
            language_term =
                "variadic parameter",
            fallback_node_type =
                "identifier",
        }
    )
)

-- The generic symbols collector runs after entering lexical scopes and
-- skips parent_lexical specs. Until the shared contract grows explicit
-- ownership handling, keep these declarations discoverable locally instead.
table.insert(
    M.scope_members.symbols,
    scope_member_schema.named(
        "class_specifier",
        "name",
        "symbol",
        {
            language_term = "class",
            fallback_node_type =
                "type_identifier",
        }
    )
)
table.insert(
    M.scope_members.symbols,
    scope_member_schema.named(
        "alias_declaration",
        "name",
        "symbol",
        {
            language_term = "type alias",
            fallback_node_type =
                "type_identifier",
        }
    )
)
table.insert(
    M.scope_members.symbols,
    scope_member_schema.named(
        "namespace_definition",
        "name",
        "symbol",
        {
            language_term = "namespace",
            fallback_node_type =
                "namespace_identifier",
        }
    )
)
M.scope_members.loops = {
    scope_member_schema.named(
        "for_range_loop",
        "declarator",
        "loop_variable",
        {
            language_term =
                "range-for variable",
            fallback_node_type =
                "identifier",
            visibility_range =
                "structural_scope",
        }
    ),
}

return M
