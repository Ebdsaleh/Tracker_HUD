-- lua/tracker_hud/adapters/lua/adapter.lua
--
-- Lua Tree-sitter adapter.
--
-- This file is the reference high-level-language adapter for Tracker_HUD.
--
-- Adapter rule:
--
--     Tree-sitter syntax comes first.
--
-- Every construct/member declaration starts by describing the exact
-- Tree-sitter syntax that Tracker_HUD consumes. Language-native meaning and
-- Tracker_HUD semantics are layered onto that syntax declaration.
--
--     syntax
--         exact Tree-sitter node / field / child / token relationships
--
--     construct
--         Tracker_HUD semantic identity plus Lua-native terminology
--
--     scope
--         scope behaviour created by the syntax construct
--
--     value
--         value semantics represented by the syntax construct
--
--     member
--         Scope Members semantics represented by matching syntax
--
-- Mutability is orthogonal:
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
        syntax = {
            node_type = "function_declaration",

            fields = {
                name = "name",
                parameters = "parameters",
                body = "body",
            },

            tokens = {
                start = "function",
                local_prefix = "local",
                args_open = "(",
                args_close = ")",
                scope_close = "end",
            },
        },

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
        syntax = {
            node_type = "function_definition",

            fields = {
                parameters = "parameters",
                body = "body",
            },

            tokens = {
                start = "function",
                args_open = "(",
                args_close = ")",
                scope_close = "end",
            },
        },

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

        signature = {
            strategy = "first_line",
        },

        markers = {
            required = {
                "start",
                "args_open",
                "args_close",
                "scope_close",
            },

            total_required = 4,
        },
    },


    --------------------------------------------------------------------------
    -- Branches
    --------------------------------------------------------------------------

    ["if_statement"] = {
        syntax = {
            node_type = "if_statement",

            fields = {
                condition = "condition",
                consequence = "consequence",
                alternative = "alternative",
            },

            children = {
                alternatives = {
                    node_types = {
                        "elseif_statement",
                        "else_statement",
                    },
                    multiple = true,
                },
            },

            tokens = {
                start = "if",
                branch_open = "then",
                alternative_if = "elseif",
                alternative = "else",
                branch_close = "end",
            },
        },

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

        branch = {
            grouped = true,

            alternatives = {
                {
                    syntax = {
                        node_type = "elseif_statement",
                    },
                    label = "Else-If",
                },

                {
                    syntax = {
                        node_type = "else_statement",
                    },
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
        syntax = {
            node_type = "for_statement",

            fields = {
                clause = "clause",
                body = "body",
            },

            children = {
                clause = {
                    node_types = {
                        "for_generic_clause",
                        "for_numeric_clause",
                    },
                },
            },

            tokens = {
                start = "for",
                loop_open = "do",
                scope_close = "end",
            },
        },

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
        syntax = {
            node_type = "while_statement",

            fields = {
                condition = "condition",
                body = "body",
            },

            tokens = {
                start = "while",
                loop_open = "do",
                scope_close = "end",
            },
        },

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
        syntax = {
            node_type = "repeat_statement",

            fields = {
                body = "body",
                condition = "condition",
            },

            tokens = {
                start = "repeat",
                scope_close = "until",
            },
        },

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
        syntax = {
            node_type = "return_statement",

            children = {
                values = {
                    node_type = "expression_list",
                    optional = true,
                },
            },

            tokens = {
                start = "return",
            },
        },

        construct = {
            kind = "return",
            language_term = "return",
            label = "Return",
        },
    },


    ["assignment_statement"] = {
        syntax = {
            node_type = "assignment_statement",

            fields = {
                operator = "operator",
            },

            children = {
                names = {
                    node_type = "variable_list",
                },

                values = {
                    node_type = "expression_list",
                },
            },

            tokens = {
                operator = "=",
            },
        },

        construct = {
            kind = "assignment",
            language_term = "assignment",
            label = "Assignment",
        },
    },


    ["function_call"] = {
        syntax = {
            node_type = "function_call",

            fields = {
                name = "name",
                arguments = "arguments",
            },
        },

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
        syntax = {
            node_type = "string",

            fields = {
                start = "start",
                content = "content",
                finish = "end",
            },
        },

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
        syntax = {
            node_type = "number",
        },

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
        syntax = {
            node_type = "nil",

            tokens = {
                literal = "nil",
            },
        },

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
        syntax = {
            node_type = "true",

            tokens = {
                literal = "true",
            },
        },

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
        syntax = {
            node_type = "false",

            tokens = {
                literal = "false",
            },
        },

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
        syntax = {
            node_type = "table_constructor",

            children = {
                fields = {
                    node_type = "field",
                    multiple = true,
                    optional = true,
                },
            },

            tokens = {
                open = "{",
                close = "}",
            },
        },

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
            syntax = {
                node_type = "variable_declaration",

                children = {
                    names = {
                        node_type = "variable_list",
                    },

                    values = {
                        node_type = "expression_list",
                        optional = true,
                    },
                },

                tokens = {
                    declaration = "local",
                    operator = "=",
                },
            },

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
            syntax = {
                node_type = "assignment_statement",

                children = {
                    names = {
                        node_type = "variable_list",
                    },

                    values = {
                        node_type = "expression_list",
                    },
                },

                fields = {
                    operator = "operator",
                },

                exclusions = {
                    ancestor_node_types = {
                        "variable_declaration",
                        "local_declaration",
                    },
                },

                tokens = {
                    operator = "=",
                },
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
            syntax = {
                node_type = "function_declaration",

                children = {
                    names = {
                        node_type = "parameters",
                    },
                },

                fields = {
                    parameters = "parameters",
                },
            },

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
            syntax = {
                node_type = "function_definition",

                children = {
                    names = {
                        node_type = "parameters",
                    },
                },

                fields = {
                    parameters = "parameters",
                },
            },

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
            syntax = {
                node_type = "function_declaration",

                fields = {
                    name = "name",
                },
            },

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
            syntax = {
                node_type = "function_definition",
            },

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
            syntax = {
                node_type = "for_numeric_clause",

                fields = {
                    name = "name",
                    operator = "operator",
                    start = "start",
                    finish = "end",
                    step = "step",
                },

                tokens = {
                    operator = "=",
                    separator = ",",
                },
            },

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
            syntax = {
                node_type = "for_generic_clause",

                children = {
                    names = {
                        node_type = "variable_list",
                    },

                    values = {
                        node_type = "expression_list",
                    },
                },

                tokens = {
                    iterator = "in",
                },
            },

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
            syntax = {
                node_type = "return_statement",

                children = {
                    values = {
                        node_type = "expression_list",
                        optional = true,
                    },
                },

                tokens = {
                    start = "return",
                },
            },

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
            syntax = {
                node_type = "field",

                fields = {
                    name = "name",
                    operator = "operator",
                    value = "value",
                },

                tokens = {
                    operator = "=",
                },
            },

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

