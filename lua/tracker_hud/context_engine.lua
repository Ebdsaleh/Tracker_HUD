-- lua/tracker_hud/context_engine.lua
--
-- Shared context engine helpers.
--
-- This module should contain language-neutral behavior only.
-- Language-specific rules belong in adapters.

local M = {}


local function is_number(value)
    return type(value) == "number"
end

local function is_table(value)
    return type(value) == "table"
end


function M.make_global_context()
    return {
        label = "Global Scope",
        node_type = nil,
        start_line = nil,
        end_line = nil,
        depth = 0,
        path = {},
        scopes = {},
    }
end

function M.make_unavailable_context(message, filetype)
    return {
        label = message,
        node_type = nil,
        start_line = nil,
        end_line = nil,
        depth = 0,
        path = {},
        scopes = {},
        unavailable = true,
        filetype = filetype,
    }
end

function M.position_in_node(row, col, node)
    if not node then
        return false
    end

    local start_row, start_col, end_row, end_col = node:range()

    if not is_number(start_row) or not is_number(end_row) then
        return false
    end

    if row < start_row or row > end_row then
        return false
    end

    if row == start_row and is_number(start_col) and col < start_col then
        return false
    end    

    if row == end_row and is_number(end_col) and col > end_col then
        return false
    end

    return true
end


function M.get_first_node_line(node)
    if not node then
        return nil
    end

    local start_row = node:range()


    if not is_number(start_row) then
        return nil
    end

    return start_row + 1
end


function M.build_scope_entry_from_construct(construct)
    if not is_table(construct) or not is_table(construct.range) then
        return nil
    end

    local line_number = construct.range.start_line
    local label = construct.signature or construct.label
    local display_label = nil

    if construct.metadata then
        display_label = construct.metadata.display_label
    end

    display_label = display_label or "[" .. line_number .. "] " .. label

    return {
        label = display_label,
        raw_label = label,
        node_type = construct.node_type,
        kind = construct.kind,
        start_line = construct.range.start_line,
        end_line = construct.range.end_line,
        construct = construct,
    }
end  


function M.build_context_from_scopes(scopes, config)
    local context = M.make_global_context()

    if not is_table(scopes) or #scopes == 0 then
        return context
    end

    local path = {}

    -- Scopes are collected innermost -> outermost.
    -- Reverse them so HUD reads outermost -> innermost.
    for i = #scopes, 1, -1 do
        table.insert(path, scopes[i].label)
    end
    
    local innermost = scopes[1]
    local separator = (config and config.separator) or " -> "


    context.label = "Scope: " .. table.concat(path, separator)
    context.node_type = innermost.node_type
    context.start_line = innermost.start_line
    context.end_line = innermost.end_line
    context.depth = #scopes
    context.path = path
    context.scopes = scopes

    return context
end


function M.get_node_range(node)
    if not node then
        return nil
    end
    
    local start_row, _, end_row, _ = node:range()

    if not is_number(start_row) or not is_number(end_row) then
        return nil
    end
    
    return {
        start_line = start_row + 1,
        end_line = end_row + 1,
    }
end


return M
