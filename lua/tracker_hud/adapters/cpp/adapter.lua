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
    -- Parser-facing callers may run before buffer configuration.
    -- Keep the initial semantic target aligned with the declared default.
    standard = M.target_dimensions.standard.default,
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
-- A named C++20 module declaration identifies a module/partition;
-- it does not establish a lexical scope for source member visibility.
construct_schema.define(
    M.construct_specs,
    "module_declaration",
    "module",
    {
        language_term = "module",
        label = "Module",
        fields = {
            name = "name",
            partition = "partition",
        },
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp20",
        },
    }
)
-- The global module fragment starts with "module;" and does not
-- declare a named module or introduce a lexical member scope.
construct_schema.define(
    M.construct_specs,
    "global_module_fragment_declaration",
    "module",
    {
        language_term = "global module fragment",
        label = "Global Module Fragment",
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp20",
        },
    }
)
-- "module : private;" marks the private module fragment.
-- Like the global fragment, this is a module construct, not a lexical scope.
construct_schema.define(
    M.construct_specs,
    "private_module_fragment_declaration",
    "module",
    {
        language_term = "private module fragment",
        label = "Private Module Fragment",
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp20",
        },
    }
)
-- Module imports reference a module, partition, or header unit;
-- this declaration does not introduce a lexical binding scope.
construct_schema.define(
    M.construct_specs,
    "import_declaration",
    "declaration",
    {
        language_term = "module import",
        label = "Import",
        fields = {
            name = "name",
            partition = "partition",
            header = "header",
        },
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp20",
        },
    }
)
-- An export declaration annotates the visibility of its enclosed
-- declaration(s). It does not create a lexical owner or member scope.
construct_schema.define(
    M.construct_specs,
    "export_declaration",
    "declaration",
    {
        language_term = "module export",
        label = "Export",
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp20",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "concept_definition",
    "declaration",
    {
        language_term = "concept",
        label = "Concept",
        fields = {
            name = "name",
        },
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp20",
        },
    }
)
construct_schema.define(
    M.construct_specs,
    "requires_expression",
    "block",
    {
        language_term = "requires expression",
        label = "Requires",
        fields = {
            parameters = "parameters",
            requirements = "requirements",
        },
        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp20",
        },
    }
)
-- A requires-clause constrains a template/function but does not open
-- a lexical scope or introduce Scope Members by itself.
construct_schema.define(
    M.construct_specs,
    "requires_clause",
    "condition",
    {
        language_term = "requires clause",
        label = "Requires Clause",
        fields = {
            constraint = "constraint",
        },
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp20",
        },
    }
)
for _, definition in ipairs({
    { "access_specifier", "declaration", "access specifier", "Access" },
    { "using_declaration", "declaration", "using declaration", "Using" },
    { "delete_expression", "call", "delete expression", "Delete" },
    { "reference_declarator", "declaration", "reference declarator", "Reference" },
    { "throw_statement", "call", "throw", "Throw" },
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
-- C++20 coroutine-return semantics are unavailable in earlier standards.
construct_schema.define(
    M.construct_specs,
    "co_return_statement",
    "return",
    {
        language_term = "co_return",
        label = "Co Return",
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp20",
        },
    }
)
-- C++23 explicit object parameters wrap an ordinary parameter.
-- The wrapper represents a parameter binding, not a lexical scope.
construct_schema.define(
    M.construct_specs,
    "explicit_object_parameter_declaration",
    "parameter",
    {
        language_term = "explicit object parameter",
        label = "Explicit Object Parameter",
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp23",
        },
    }
)
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
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp11",
        },
    }
)
-- C++11 static assertions are compile-time declarations, not scopes.
-- Capture condition/message fields without presenting semantics in C++98/03.
construct_schema.define(
    M.construct_specs,
    "static_assert_declaration",
    "declaration",
    {
        language_term = "static_assert",
        label = "Static Assert",
        fields = {
            condition = "condition",
            message = "message",
        },
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp11",
        },
    }
)
-- C++17 structured bindings declare multiple names without introducing a scope.
-- Keep the child identifiers intact; do not fabricate a singular name field.
construct_schema.define(
    M.construct_specs,
    "structured_binding_declarator",
    "declaration",
    {
        language_term = "structured binding",
        label = "Structured Binding",
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp17",
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
        availability = {
            language = "cpp",
            dimension = "standard",
            since = "cpp11",
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

-- C++ structured bindings have independent identifier children. Suppress
-- the inherited C singular-name rules only along their declarator fields,
-- so an ordinary initializer containing unrelated syntax is unaffected.
for _, spec in ipairs(M.scope_members.symbols) do
    local node_type = spec.syntax.node_type
    -- C++ references have one unnamed declarator child. Preserve the
    -- inherited field traversal for pointers and arrays in both parameter roles.
    if node_type == "parameter_declaration" then
        local recursive = spec.syntax.fields.name.recursive
        table.insert(recursive.container_node_types, "reference_declarator")
        recursive.single_named_child_node_types = { "reference_declarator" }

        -- Extend both complementary callable/prototype roles using exact
        -- contiguous paths. The lambda construct's existing standard gate
        -- controls whether its subtree is discovered at all.
        local role = spec.syntax.constraints or spec.syntax.exclusions
        role.parent_paths = {
            role.parent_path,
            { "parameter_list", "lambda_declarator", "lambda_expression" },
        }
        role.parent_path = nil
    end
    if node_type == "declaration" or node_type == "init_declarator" then
        spec.syntax.exclusions = spec.syntax.exclusions or {}
        spec.syntax.exclusions.field_paths = {
            {
                fields = { "declarator" },
                node_types = { "structured_binding_declarator" },
            },
        }
        if node_type == "declaration" then
            table.insert(spec.syntax.exclusions.field_paths, {
                fields = { "declarator", "declarator" },
                node_types = { "structured_binding_declarator" },
            })
        end
    end
end

-- Distinguish the loop's declarator from an ordinary binding declaration
-- inside its body. The shared walker gates unavailable C++17 ancestors.
local range_binding_parent_path = {
    "structured_binding_declarator",
    "for_range_loop",
}

table.insert(
    M.scope_members.symbols,
    scope_member_schema.rule(
        "identifier",
        "variable",
        {
            language_term = "structured binding",
            binding_mutability = "unknown",
            children = { name = { node_type = "identifier" } },
            constraints = {
                parent_node_types = { "structured_binding_declarator" },
            },
            exclusions = { parent_path = range_binding_parent_path },
        }
    )
)
table.insert(
    M.scope_members.symbols,
    scope_member_schema.rule(
        "identifier",
        "loop_variable",
        {
            language_term = "structured range-for binding",
            binding_mutability = "unknown",
            children = { name = { node_type = "identifier" } },
            constraints = { parent_path = range_binding_parent_path },
            visibility_range = "structural_scope",
        }
    )
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
        "concept_definition",
        "name",
        "symbol",
        {
            language_term = "concept",
            fallback_node_type =
                "identifier",
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
-- Use the general rule builder: named() does not forward exclusions.
-- Keep the existing field and fallback while excluding composite bindings.
M.scope_members.loops = {
    scope_member_schema.rule(
        "for_range_loop",
        "loop_variable",
        {
            language_term =
                "range-for variable",
            binding_mutability = "unknown",
            fields = { name = "declarator" },
            children = { name = { node_type = "identifier" } },
            exclusions = {
                field_paths = {
                    {
                        fields = { "declarator" },
                        node_types = { "structured_binding_declarator" },
                    },
                },
            },
            visibility_range =
                "structural_scope",
        }
    ),
}

return M
