-- lua/tracker_hud/adapters/lua/adapter.lua
--
-- Lua Tree-sitter adapter.
--
-- Describes Lua Tree-sitter constructs for Tracker HUD.

local M = {}

M.name = "lua"
M.filetypes = { "lua" }

M.capabilities = {
    lexical_scopes = true,
    structural_scopes = true,
    members = true,
    values = true,
    source_jump = true,
}

M.construct_specs = {
    ["function_declaration"] = {
        construct = {
            kind = "callable",
            label = "Function",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        value = {
            kind = "callable",
            type_label = "function",
        },

        tokens = {
            start = "function",
            local_prefix = "local",
            args_open = "(",
            args_close = ")",
            scope_close = "end",
        },

        signature = {
            strategy = "first_line",
            name_pattern = "^%s*function%s+([%w_%.:]+)",
            local_name_pattern = "^%s*local%s+function%s+([%w_%.:]+)",
        },

        markers = {
            required = {
                "start",
                "args_open",
                "args_close",
                "scope_close",
            },

            optional = {
                "local_prefix",
            },

            total_required = 4,
        },
    },

    ["function_definition"] = {
        construct = {
            kind = "callable",
            label = "Function",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        value = {
            kind = "callable",
            type_label = "function",
        },

        tokens = {
            start = "function",
            local_prefix = "local",
            args_open = "(",
            args_close = ")",
            scope_close = "end",
        },

        signature = {
            strategy = "first_line",
            name_pattern = "^%s*function%s+([%w_%.:]+)",
            local_name_pattern = "^%s*local%s+function%s+([%w_%.:]+)",
        },

        markers = {
            required = {
                "start",
                "args_open",
                "args_close",
                "scope_close",
            },

            optional = {
                "local_prefix",
            },

            total_required = 4,
        },
    },

    ["if_statement"] = {
        construct = {
            kind = "branch",
            label = "If",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        tokens = {
            start = "if",
            branch_open = "then",
            alternative_if = "elseif",
            alternative = "else",
            branch_close = "end",
        },

        branch = {
            grouped = true,
            alternatives = {
                {
                    node_match = "elseif",
                    label = "Else-If",
                },
                {
                    node_match = "else",
                    label = "Else",
                },
            },
        },

        markers = {
            required = {
                "start",
                "branch_open",
                "branch_close",
            },

            optional = {
                "alternative_if",
                "alternative",
            },

            total_required = 3,
        },
    },

    ["for_statement"] = {
        construct = {
            kind = "loop",
            label = "For",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        tokens = {
            start = "for",
            loop_open = "do",
            scope_close = "end",
        },

        markers = {
            required = {
                "start",
                "loop_open",
                "scope_close",
            },

            total_required = 3,
        },
    },

    ["while_statement"] = {
        construct = {
            kind = "loop",
            label = "While",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        tokens = {
            start = "while",
            loop_open = "do",
            scope_close = "end",
        },

        markers = {
            required = {
                "start",
                "loop_open",
                "scope_close",
            },

            total_required = 3,
        },
    },

    ["repeat_statement"] = {
        construct = {
            kind = "loop",
            label = "Repeat",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        tokens = {
            start = "repeat",
            scope_close = "until",
        },

        markers = {
            required = {
                "start",
                "scope_close",
            },

            total_required = 2,  
        },
    },


    ["return_statement"] = {
        construct = {
            kind = "statement",
            label = "Return",
        },
    },

    ["assignment_statement"] = {
        construct = {
            kind = "assignment",
            label = "Assignment",
        },
    },

    ["function_call"] = {
        construct = {
            kind = "expression",
            label = "Call",
        },

        value = {
            kind = "call",
            type_label = "call",
        },
    },

    ["string"] = {
        construct = {
            kind = "literal",
            label = "String",
        },

        value = {
            kind = "scalar",
            type_label = "string",
        },
    },

    ["number"] = {
        construct = {
            kind = "literal",
            label = "Number",
        },

        value = {
            kind = "scalar",
            type_label = "number",
        },
    },

    ["nil"] = {
        construct = {
            kind = "literal",
            label = "Nil",
        },

        value = {
            kind = "scalar",
            type_label = "nil",
        },
    },

    ["true"] = {
        construct = {
            kind = "literal",
            label = "Boolean",
        },

        value = {
            kind = "scalar",
            type_label = "boolean",
        },
    },

    ["false"] = {
        construct = {
            kind = "literal",
            label = "Boolean",
        },

        value = {
            kind = "scalar",
            type_label = "boolean",
        },
    },

    ["table_constructor"] = {
        construct = {
            kind = "literal",
            label = "Table",
        },

        scope = {
            kind = "structural",
            affects_visibility = false,
            owns_members = true,
        },

        value = {
            kind = "structural",
            type_label = "table",
        },
    },
}

M.scope_members = {
    declarations = {
        {
            node_type = "variable_declaration",
            name_list_node_type = "variable_list",
            value_list_node_type = "expression_list",

            member = {
                kind = "local_",
                owner_scope = "lexical",
            },
        },
    },

    assignments = {
        {
            node_type = "assignment_statement",
            name_list_node_type = "variable_list",
            value_list_node_type = "expression_list",
            -- exclude types
            exclude_ancestor_node_types = {
                "variable_declaration",
                "local_declaration"
            },

            member = {
                kind = "assignment",
                owner_scope = "lexical",
            },
        },
    },


    parameters = {
        {
            node_type = "function_declaration",
            list_node_type = "parameters",

            member = {
                kind = "parameter",
                owner_scope = "lexical",
            },
        },
        {
            node_type = "function_definition",
            list_node_type = "parameters",

            member = {
                kind = "parameter",
                owner_scope = "lexical",
            },
        },
    },


    functions = {
        {
            node_type = "function_declaration",

            member = {
                kind = "function_",
                owner_scope = "parent_lexical",
            },
        },
        {
            node_type = "function_definition",

            member = {
                kind = "function_",
                owner_scope = "parent_lexical",
            },
        },
    },

    loops = {
        {
            node_type = "for_numeric_clause",
            name_field = "name",

            member = {
                kind = "loop_variable",
                owner_scope = "lexical",
            },
        },
        {
            node_type = "for_generic_clause",
            name_list_node_type = "variable_list",

            member = {
                kind = "loop_variable",
                owner_scope = "lexical",
            },
        },
    },

    returns = {
        {
            node_type = "return_statement",
            value_list_node_type = "expression_list",

            member = {
                kind = "return_value",
                owner_scope = "lexical",
            },
        },
    },

    fields = {
        {
            node_type = "field",

            member = {
                kind = "field",
                owner_scope = "structural",
            },
        },
    },

}

return M

