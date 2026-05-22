-- lua/tracker_hud/context.lua

local M = {}

local adapter_registry = require("tracker_hud.adapters.registry")


local target_nodes = {
    -- Functions / Methods / Procedures
    function_declaration = true,
    function_definition = true,
    method_declaration = true,
    function_item = true,
    fn_proto = true,
    procedure_declaration = true,

    -- Conditionals / Scopes
    if_statement = true,
    for_statement = true,
    while_statement = true,
    loop_statement = true,
}

local function is_function_like(node_type)
    return node_type:match("function")
        or node_type:match("method")
        or node_type == "fn_proto"
        or node_type == "procedure_declaration"
end

local function position_in_node(row, col, node)
    if not node then
        return false
    end

    local start_row, start_col, end_row, end_col = node:range()

    if not start_row or not end_row then
        return false
    end

    if row < start_row or row > end_row then
        return false
    end

    if row == start_row and col < start_col then
        return false
    end

    if row == end_row and col > end_col then
        return false
    end

    return true
end

local function get_first_node_line(node)
    if not node then
        return nil
    end

    local start_row = node:range()

    if not start_row then
        return nil
    end

    return start_row + 1
end

local function get_if_branch_label(node, _bufnr, row, col, if_line)
    local alternative_nodes = {}

    -- Prefer Tree-sitter field lookup when the grammar supports it.
    local ok, field_nodes = pcall(function()
        return node:field("alternative")
    end)

    if ok and field_nodes then
        for _, alternative in ipairs(field_nodes) do
            table.insert(alternative_nodes, alternative)
        end
    end

    -- Fallback: look for named children that are clearly else/elseif nodes.
    for i = 0, node:named_child_count() - 1 do
        local child = node:named_child(i)
        local child_type = child:type()

        if child_type:match("else") or child_type:match("elseif") then
            table.insert(alternative_nodes, child)
        end
    end

    for _, alternative in ipairs(alternative_nodes) do
        if position_in_node(row, col, alternative) then
            local else_line = get_first_node_line(alternative) or if_line
            return "([" .. if_line .. "] If : Else [" .. else_line .. "])"
        end
    end

    return "[" .. if_line .. "] If"
end

local function try_parse_construct_with_adapter(bufnr, node)
    if not node then
        return nil
    end

    local filetype = vim.bo[bufnr].filetype

    if not filetype or filetype == "" then
        return nil
    end

    if not adapter_registry.has_adapter(filetype) then
        return nil
    end

    local construct, _err = adapter_registry.parse_node(filetype, node, bufnr)
    
    return construct
end

function M.get_cursor_context(bufnr, config)
    config = config or {}

    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)

    if not ok or not parser then
        return nil
    end

    local node = vim.treesitter.get_node()

    if not node then
        return nil
    end

    local context = {
        label = "Global Scope",
        node_type = nil,
        start_line = nil,
        end_line = nil,
    }

    local scopes = {}

    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_row = cursor[1] - 1
    local cursor_col = cursor[2]

    while node do
        local node_type = node:type()
        local construct = try_parse_construct_with_adapter(bufnr, node)

        if construct then
            local line_number = construct.range.start_line
            local label = construct.signature or construct.label
            local display_label = "[" .. line_number .. "] " .. label

            table.insert(scopes, {
                label = display_label,
                raw_label = label,
                node_type = construct.node_type,
                kind = construct.kind,
                start_line = construct.range.start_line,
                end_line = construct.range.end_line,
                construct = construct,
            })

        elseif target_nodes[node_type] then
            local start_row, _, end_row, _ = node:range()

            if start_row and end_row then
                local label = nil

                if is_function_like(node_type) then
                    local node_text = vim.treesitter.get_node_text(node, bufnr)
                    label = node_text:match("([^\n]+)") or "Function"
                else
                    label = node_type
                        :gsub("_statement", "")
                        :gsub("^%l", string.upper)
                end

                local line_number = start_row + 1
                local display_label = "[" .. line_number .. "] " .. label

                if node_type == "if_statement" then
                    display_label = get_if_branch_label(
                        node, 
                        bufnr,
                        cursor_row,
                        cursor_col,
                        line_number
                    )
                end


                table.insert(scopes, {
                    label = display_label,
                    raw_label = label,
                    node_type = node_type,
                    start_line = line_number,
                    end_line = end_row + 1,
                })
            end
        end

        node = node:parent()
    end

    if #scopes == 0 then
        return context
    end

    -- We collected from innermost -> outermost.
    -- Reverse it so HUD reads outermost -> innermost.
    local path = {}

    for i = #scopes, 1, -1 do
        table.insert(path, scopes[i].label)
    end

    local innermost = scopes[1]
    local separator = config.separator or " -> "

    context.label = "Scope: " .. table.concat(path, separator)
    context.node_type = innermost.node_type
    context.start_line = innermost.start_line
    context.end_line = innermost.end_line
    context.depth = #scopes
    context.path = path
    context.scopes = scopes

    return context
end

return M
