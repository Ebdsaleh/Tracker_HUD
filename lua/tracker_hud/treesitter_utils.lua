-- lua/tracker_hud/treesitter_utils.lua
--
-- Small Tree-sitter node helper functions.
--
-- These helpers do not own state or manage traversal systems. They only
-- provide safe, reusable ways to inspect Tree-sitter nodes.

local core = require("tracker_hud.core")

local M = {}


function M.get_node_range(node)
    if not node then
        return nil
    end

    local start_row, _, end_row, _ = node:range()

    if not core.is_number(start_row) or not core.is_number(end_row) then
        return nil
    end

    return {
        start_line = start_row + 1,
        end_line = end_row + 1,
    }
end


function M.get_node_range_fields(node)
    local range = M.get_node_range(node)

    if not range then
        return {
            start_line = nil,
            end_line = nil,
        }
    end

    return {
        start_line = range.start_line,
        end_line = range.end_line,
    }
end


function M.get_node_line(node)
    if not node then
        return nil
    end

    local start_row = node:range()

    if not core.is_number(start_row) then
        return nil
    end

    return start_row + 1
end


function M.get_node_text(node, bufnr)
    if not node then
        return nil
    end

    local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)

    if not ok then
        return nil
    end

    return text
end


function M.get_child_by_field_name(node, field_name)
    if not node or not core.is_non_empty_string(field_name) then
        return nil
    end

    local ok, child = pcall(function()
        return node:child_by_field_name(field_name)
    end)

    if ok then
        return child
    end

    return nil
end


function M.node_type_matches(node, expected_type)
    return node
        and core.is_non_empty_string(expected_type)
        and node:type() == expected_type
end


function M.node_has_ancestor_type(node, ancestor_node_types)
    if not node or not core.is_table(ancestor_node_types) then
        return false
    end

    local current = node:parent()

    while current do
        for _, ancestor_node_type in ipairs(ancestor_node_types) do
            if M.node_type_matches(current, ancestor_node_type) then
                return true
            end
        end

        current = current:parent()
    end

    return false
end


function M.find_first_descendant_by_type(node, node_type)
    if not node or not core.is_non_empty_string(node_type) then
        return nil
    end

    if M.node_type_matches(node, node_type) then
        return node
    end

    for child in node:iter_children() do
        local found = M.find_first_descendant_by_type(child, node_type)

        if found then
            return found
        end
    end

    return nil
end


return M
