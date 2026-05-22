-- lua/tracker_hud/adapters/lua_adapter.lua
--
-- Lua Tree-sitter adapter.
--
-- Converts Lua Tree-sitter nodes into normalized Tracker HUD constructs.

local contract = require("tracker_hud.constructs.contract")


local M = {}

M.name = "lua"
M.filetypes =  { "lua" }

local node_specs = {
    function_declaration = {
        kind = "callable",
        label = "Function",
        creates_scope = true,
        signature = "first_line",
    },

    function_definition = {
        kind = "callable",
        label = "Function",
        creates_scope = true,
        signature = "first_line",
    },

    if_statement = {
        kind = "branch",
        label = "If",
        creates_scope = true,
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


local function get_range(node)
    if not node then
        return nil
    end

    local start_row, _, end_row, _ = node:range()

    if not start_row or not end_row then
        return nil
    end


    return {
        start_line = start_row + 1,
        end_line = end_row + 1,
    }
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
    if spec.signature ~= "first_line" then
        return nil
    end


    return get_first_line_text(node, bufnr)

end


function M.match_node(node, _bufnr)
    local node_type = get_node_type(node)

    if not node_type then
        return false
    end
    
    return node_specs[node_type] ~= nil
end
    

function M.parse_node(node, bufnr)
    local node_type = get_node_type(node)
    local spec = node_specs[node_type]

    if not spec then
        return nil, nil
    end

    local range = get_range(node)

    if not range then
        return nil, "could not get node range"
    end

    local signature = build_signature(node, bufnr, spec)
    local name = nil

    if spec.kind == "callable" then
        name = get_callable_name(signature)
    end

    local construct, err = contract.new_construct({
        kind = spec.kind,
        label = spec.label,
        node_type = node_type,
        name = name,
        signature = signature,
        range = range,
        creates_scope = spec.creates_scope,
        metadata = {
            adapter = M.name,
        },
    })

    if not construct then
        return nil, err
    end

    return construct, nil

end


return M
