-- lua/tracker_hud/adapters/lua/adapter.lua
--
-- Lua Tree-sitter adapter.
--
-- This file is the reference high-level-language adapter for Tracker_HUD.
--
-- Tree-sitter-facing identity:
--
--     M.construct_specs[tree_sitter_node_type]
--     scope_members.*.node_type
--
-- Tracker_HUD semantic identity:
--
--     construct.kind
--     member.kind
--     value.kind
--
-- Active-language vocabulary:
--
--     *.language_term
--     construct.label
--     value.type_label
--
-- Mutability:
--
--     binding
--         whether a binding/name may be rebound
--
--     state
--         whether an existing value may change internally
--
--     shape
--         whether members/fields may be added or removed
--
-- Adapters describe language facts. They are not linters or LSPs.

local M = {}


M.name = "lua"

M.filetypes = {
    "lua",
}


M.presentation = {
    sections = {
        order = {
            "scope",
            "scope_members",
            "warnings",
        },
    },
}


M.capabilities = {
    lexical_scopes = true,
    structural_scopes = true,
    members = true,
    values = true,
    source_jump = true,
}


M.construct_specs = {

    --------------------------------------------------------------------------
    -- Functions
    --------------------------------------------------------------------------

    ["function_declaration"] = {
        construct = {
            kind = "function",
            language_term = "function",
            label = "Function",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        value = {
            kind = "function",
            language_term = "function",
            type_label = "function",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
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

            name_pattern =
                "^%s*function%s+([%w_%.:]+)",

            local_name_pattern =
                "^%s*local%s+function%s+([%w_%.:]+)",
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
            kind = "function",
            language_term = "function",
            label = "Function",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        value = {
            kind = "function",
            language_term = "function",
            type_label = "function",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
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

            name_pattern =
                "^%s*function%s+([%w_%.:]+)",

            local_name_pattern =
                "^%s*local%s+function%s+([%w_%.:]+)",
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


    --------------------------------------------------------------------------
    -- Branches
    --------------------------------------------------------------------------

    ["if_statement"] = {
        construct = {
            kind = "branch",
            language_term = "if",
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


    --------------------------------------------------------------------------
    -- Loops
    --------------------------------------------------------------------------

    ["for_statement"] = {
        construct = {
            kind = "loop",
            language_term = "for",
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
            language_term = "while",
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
            language_term = "repeat",
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


    --------------------------------------------------------------------------
    -- Statements / operations
    --------------------------------------------------------------------------

    ["return_statement"] = {
        construct = {
            kind = "return",
            language_term = "return",
            label = "Return",
        },
    },


    ["assignment_statement"] = {
        construct = {
            kind = "assignment",
            language_term = "assignment",
            label = "Assignment",
        },
    },


    ["function_call"] = {
        construct = {
            kind = "call",
            language_term = "function call",
            label = "Call",
        },

        value = {
            kind = "call",
            language_term = "function call",
            type_label = "call",
        },
    },


    --------------------------------------------------------------------------
    -- Scalar literals
    --------------------------------------------------------------------------

    ["string"] = {
        construct = {
            kind = "literal",
            language_term = "string",
            label = "String",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        value = {
            kind = "scalar",
            language_term = "string",
            type_label = "string",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },
    },


    ["number"] = {
        construct = {
            kind = "literal",
            language_term = "number",
            label = "Number",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        value = {
            kind = "scalar",
            language_term = "number",
            type_label = "number",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },
    },


    ["nil"] = {
        construct = {
            kind = "literal",
            language_term = "nil",
            label = "Nil",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        value = {
            kind = "scalar",
            language_term = "nil",
            type_label = "nil",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },
    },


    ["true"] = {
        construct = {
            kind = "literal",
            language_term = "boolean",
            label = "Boolean",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        value = {
            kind = "scalar",
            language_term = "boolean",
            type_label = "boolean",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },
    },


    ["false"] = {
        construct = {
            kind = "literal",
            language_term = "boolean",
            label = "Boolean",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        value = {
            kind = "scalar",
            language_term = "boolean",
            type_label = "boolean",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },
    },


    --------------------------------------------------------------------------
    -- Tables
    --------------------------------------------------------------------------

    ["table_constructor"] = {
        construct = {
            kind = "table",
            language_term = "table",
            label = "Table",

            mutability = {
                state = "mutable",
                shape = "extensible",
            },
        },

        scope = {
            kind = "structural",
            affects_visibility = false,
            owns_members = true,
        },

        value = {
            kind = "table",
            language_term = "table",
            type_label = "table",

            mutability = {
                state = "mutable",
                shape = "extensible",
            },
        },
    },
}


M.scope_members = {

    --------------------------------------------------------------------------
    -- Local declarations
    --------------------------------------------------------------------------

    declarations = {
        {
            node_type = "variable_declaration",
            name_list_node_type = "variable_list",
            value_list_node_type = "expression_list",

            member = {
                kind = "local",
                language_term = "local",
                owner_scope = "lexical",

                mutability = {
                    binding = "mutable",
                },
            },
        },
    },


    --------------------------------------------------------------------------
    -- Assignments
    --------------------------------------------------------------------------

    assignments = {
        {
            node_type = "assignment_statement",
            name_list_node_type = "variable_list",
            value_list_node_type = "expression_list",

            exclude_ancestor_node_types = {
                "variable_declaration",
                "local_declaration",
            },

            member = {
                kind = "assignment",
                language_term = "assignment",
                owner_scope = "lexical",

                mutability = {
                    binding = "mutable",
                },
            },
        },
    },


    --------------------------------------------------------------------------
    -- Parameters
    --------------------------------------------------------------------------

    parameters = {
        {
            node_type = "function_declaration",
            list_node_type = "parameters",

            member = {
                kind = "parameter",
                language_term = "parameter",
                owner_scope = "lexical",

                mutability = {
                    binding = "mutable",
                },
            },
        },

        {
            node_type = "function_definition",
            list_node_type = "parameters",

            member = {
                kind = "parameter",
                language_term = "parameter",
                owner_scope = "lexical",

                mutability = {
                    binding = "mutable",
                },
            },
        },
    },


    --------------------------------------------------------------------------
    -- Functions
    --------------------------------------------------------------------------

    functions = {
        {
            node_type = "function_declaration",

            member = {
                kind = "function",
                language_term = "function",
                owner_scope = "parent_lexical",

                mutability = {
                    binding = "mutable",
                },
            },
        },

        {
            node_type = "function_definition",

            member = {
                kind = "function",
                language_term = "function",
                owner_scope = "parent_lexical",

                mutability = {
                    binding = "mutable",
                },
            },
        },
    },


    --------------------------------------------------------------------------
    -- Loop variables
    --------------------------------------------------------------------------

    loops = {
        {
            node_type = "for_numeric_clause",
            name_field = "name",

            member = {
                kind = "loop_variable",
                language_term = "loop variable",
                owner_scope = "lexical",

                mutability = {
                    binding = "conditional",
                },
            },
        },

        {
            node_type = "for_generic_clause",
            name_list_node_type = "variable_list",

            member = {
                kind = "loop_variable",
                language_term = "loop variable",
                owner_scope = "lexical",

                mutability = {
                    binding = "conditional",
                },
            },
        },
    },


    --------------------------------------------------------------------------
    -- Return values
    --------------------------------------------------------------------------

    returns = {
        {
            node_type = "return_statement",
            value_list_node_type = "expression_list",

            member = {
                kind = "return_value",
                language_term = "return value",
                owner_scope = "lexical",
            },
        },
    },


    --------------------------------------------------------------------------
    -- Table fields
    --------------------------------------------------------------------------

    fields = {
        {
            node_type = "field",

            member = {
                kind = "field",
                language_term = "field",
                owner_scope = "structural",

                mutability = {
                    binding = "mutable",
                },
            },
        },
    },
}


return M
