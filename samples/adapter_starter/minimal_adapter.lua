-- samples/adapter_starter/minimal_adapter.lua
--
-- Minimal high-level-language Adapter Contract v1 starter.
--
-- Replace the example Tree-sitter node/field names with exact names from the
-- grammar you are adapting. Shared helpers describe Tracker_HUD semantics;
-- they do not guess language syntax.

local construct_schema =
    require("tracker_hud.adapters.construct_schema")
local scope_member_schema =
    require("tracker_hud.adapters.scope_member_schema")

local M = {
    contract_version = 1,
    name = "example",
    filetypes = {
        "example",
    },

    capabilities = {
        lexical_scopes = true,
        members = true,
        source_jump = true,
    },

    presentation = {
        sections = {
            order = {
                "scope",
                "scope_members",
                "warnings",
            },
        },
    },

    construct_specs = {},
    scope_members = {},
}


-- Every adapter needs at least one construct. Use the actual grammar root node.
construct_schema.define(
    M.construct_specs,
    "source_file",
    "module",
    {
        language_term = "source file",
        label = "Source File",
        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
    }
)


-- Example function syntax. These field names belong to the example grammar,
-- not to Tracker_HUD core.
construct_schema.define(
    M.construct_specs,
    "function_definition",
    "function",
    {
        language_term = "function",
        label = "Function",
        fields = {
            name = "name",
            parameters = "parameters",
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


-- Scope Members translate grammar bindings into shared programming concepts.
M.scope_members.functions = {
    scope_member_schema.named(
        "function_definition",
        "name",
        "function",
        {
            owner_scope =
                "parent_lexical",
        }
    ),
}

M.scope_members.parameters = {
    scope_member_schema.rule(
        "function_definition",
        "parameter",
        {
            fields = {
                parameters =
                    "parameters",
            },
            children = {
                names = {
                    node_type =
                        "parameters",
                },
            },
        }
    ),
}


return M
