-- lua/tracker_hud/adapters/lua_adapter.lua
--
-- Lua Tree-sitter adapter.
--
-- Describes Lua Tree-sitter constructs for Tracker HUD.

local M = {}

M.name = "lua"
M.filetypes =  { "lua" }

M.construct_specs = {
    function_declaration = {
        kind = "callable",
        scope_kind = "lexical",
        scope_effect = {
            lexical = true,
            structural = false,
        },
        label = "Function",
        creates_scope = true,

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

    function_definition = {
        kind = "callable",
        scope_kind = "lexical",
        scope_effect = {
            lexical = true,
            structural = false,
        },
        label = "Function",
        creates_scope = true,

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

    if_statement = {
        kind = "branch",
        scope_kind = "lexical",
        scope_effect = {
            lexical = true,
            structural = false,
        },
        label = "If",
        creates_scope = true,

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

    for_statement = { 
        kind = "loop",
        scope_kind = "lexical",
        scope_effect = {
            lexical = true,
            structural = false,
        },
        label = "For",
        creates_scope = true,
    },

    while_statement = {
        kind = "loop",
        scope_kind = "lexical",
        scope_effect = {
            lexical = true,
            structural = false,
        },
        label = "While",
        creates_scope = true,
    },

    repeat_statement = {
        kind = "loop",
        scope_kind = "lexical",
        scope_effect = {
            lexical = true,
            structural = false,
        },
        label = "Repeat",
        creates_scope = true,
    },

    table_constructor = {
        kind = "structural",
        scope_kind = "structural",
        scope_effect = {
            lexical = false,
            structural = true,
        },
        label = "Table",
        creates_scope = false,
    },
}


M.scope_members = {
    declarations = {
        {
            node_type = "variable_declaration",
            list_node_type = "variable_list",
            kind = "local",
        },
    },

    parameters = {
        {
            node_type = "function_declaration",
            list_node_type = "parameters",
            kind = "param",
        },
        {
            node_type = "function_definition",
            list_node_type = "parameters",
            kind = "param",
        },
    },
}
return M
