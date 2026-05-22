-- lua/tracker_hud/adapters/lua_adapter.lua
--
-- Lua Tree-sitter adapter.
--
-- Converts Lua Tree-sitter nodes into normalized Tracker HUD constructs.

local contract = require("tracker_hud.constructs.contract")
local context_engine = require("tracker_hud.context_engine")

local M = {}

M.name = "lua"
M.filetypes =  { "lua" }

local construct_specs = {
    function_declaration = {
        kind = "callable",
        label = "Function",
        creates_scope = true,

        signature = {
            strategy = "first_line",
            name_pattern = "^%s*function%s+([%w_%.:]+)",
            local_name_pattern = "^%s*local%s+function%s+([%w_%.:]+)",
        },
    },

    function_definition = {
        kind = "callable",
        label = "Function",
        creates_scope = true,
        signature = {
            strategy = "first_line",
            name_pattern = "^%s*function%s+([%w_%.:]+)",
            local_name_pattern = "^%s*local%s+function%s+([%w_%.:]+)",
        },
    },

    if_statement = {
        kind = "branch",
        label = "If",
        creates_scope = true,

        branch = {
            grouped = true, 
            alternatives = {
                elseif_label = "Else-If",
                else_label = "Else",
            },
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


local function get_node_type(node)
    if not node then
        return nil
    end
    
    return node:type()
end


local function get_first_line_text(node, bufnr)
    local ok, node_text = pcall(vim.treesitter.get_node_text, node, bufnr)

    if not ok or not node_text then
        return nil
    end

    return node_text:match("([^\n]+)")
end


local function get_callable_name(first_line)
    if not first_line then
        return nil
    end

    -- Handles:
    -- function my_func()
    -- local function my_func()
    -- function table_name:method_name()
    -- function table_name.method_name()
    return first_line:match("^%s*local%s+function%s+([%w_%.:]+)")
        or first_line:match("^%s*function%s+([%w_%.:]+)")
end


local function build_signature(node, bufnr, spec)
    if not spec.signature or spec.signature.strategy ~= "first_line" then
        return nil
    end


    return get_first_line_text(node, bufnr)

end


function M.match_node(node, _bufnr)
    local node_type = get_node_type(node)

    if not node_type then
        return false
    end
    
    return construct_specs[node_type] ~= nil
end


local function get_if_branch_label(node)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_row = cursor[1] - 1
    local cursor_col = cursor[2]

    local if_line = context_engine.get_first_node_line(node)

    if not if_line then
        return "If"
    end

    local alternative_nodes = {}

    local ok, field_nodes = pcall(function()
        return node:field("alternative")
    end)

    if ok and field_nodes then
        for _, alternative in ipairs(field_nodes) do
            table.insert(alternative_nodes, alternative)
        end
    end

    for i = 0, node:named_child_count() - 1 do
        local child = node:named_child(i)
        local child_type = child:type()

        if child_type:match("else") or child_type:match("elseif") then
            table.insert(alternative_nodes, child)
        end
    end

    for _, alternative in ipairs(alternative_nodes) do
        if context_engine.position_in_node(cursor_row, cursor_col, alternative) then
            local alternative_line = context_engine.get_first_node_line(alternative) or if_line
            local alternative_type = alternative:type()

            if alternative_type:match("elseif") then
                return "([" .. if_line .. "] If : Else-If [" .. alternative_line .. "])"
            end

            return "([" .. if_line .. "] If : Else [" .. alternative_line .. "])"
        end
    end

    return "[" .. if_line .. "] If"
end



function M.parse_node(node, bufnr)
    local node_type = get_node_type(node)
    local spec = construct_specs[node_type]

    if not spec then
        return nil, nil
    end

    local range = context_engine.get_node_range(node)

    if not range then
        return nil, "could not get node range"
    end

    local signature = nil
    local name = nil

    if spec.kind == "callable" then
        signature = build_signature(node, bufnr, spec)
        name = get_callable_name(signature)
    end

    local label = spec.label
    local display_label = nil

    if node_type == "if_statement" then
        display_label = get_if_branch_label(node)
        label = display_label
    end

    
    local construct, err = contract.new_construct({
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
