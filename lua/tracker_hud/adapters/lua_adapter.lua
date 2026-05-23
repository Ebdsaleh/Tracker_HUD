-- lua/tracker_hud/adapters/lua_adapter.lua
--
-- Lua Tree-sitter adapter.
--
-- Converts Lua Tree-sitter nodes into normalized Tracker HUD constructs.

local context_engine = require("tracker_hud.context_engine")

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




function M.match_node(node, _bufnr)
    local node_type = context_engine.get_node_type(node)

    if not node_type then
        return false
    end
    
    return M.construct_specs[node_type] ~= nil
end



function M.parse_node(node, bufnr)
    local node_type = context_engine.get_node_type(node)
    local spec, spec_err = context_engine.get_construct_spec(M.construct_specs, node_type)

    if not spec then
        return nil, spec_err
    end

    local range = context_engine.get_node_range(node)

    if not range then
        return nil, "could not get node range"
    end

    local signature = nil
    local name = nil

    if spec.kind == "callable" then
        signature = context_engine.build_signature(node, bufnr, spec)
        name = context_engine.extract_name_from_signature(signature, spec)
    end

    local label = spec.label
    local display_label = nil

    if spec.kind == "branch" and spec.branch then
        display_label = context_engine.build_branch_display_label(node, spec)
        label = display_label
    end
    
    local construct, err = context_engine.build_construct({
        kind = spec.kind,
        label = label,
        node_type = node_type,
        name = name,
        signature = signature,
        range = range,
        creates_scope = spec.creates_scope,
        metadata = {
            adapter = M.name,
            display_label = display_label,
        },
    }) 
    if not construct then
        return nil, err
    end

    return construct, nil

end


return M
