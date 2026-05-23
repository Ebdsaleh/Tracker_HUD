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
        label = "For",
        creates_scope = true,
    },

    while_statement = {
        kind = "loop",
        label = "While",
        creates_scope = true,
    },

    repeat_statement = {
        kind = "loop",
        label = "Repeat",
        creates_scope = true,
    },
}


return M
