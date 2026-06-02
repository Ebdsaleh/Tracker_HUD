-- lua/tracker_hud/hud_nodes.lua
--
-- Generic expandable HUD node state.
--
-- This is for tree-like HUD rows such as scope/member/value nodes.
-- It is intentionally separate from hud_controls.lua, because controls are
-- command-like rows, while nodes are expandable data rows.

local M = {}

local expanded_nodes = {}


local function node_has_children(node)
    return type(node) == "table"
        and type(node.children) == "table"
        and #node.children > 0
end


local function set_tree_expanded(node, expanded)
    if type(node) ~= "table" then
        return false
    end

    if node.id then
        M.set_expanded(node.id, expanded)
    end

    for _, child in ipairs(node.children or {}) do
        set_tree_expanded(child, expanded)
    end

    return true
end


function M.is_expanded(node_id, default)
    if not node_id then
        return default == true
    end

    if expanded_nodes[node_id] == nil then
        return default == true
    end

    return expanded_nodes[node_id] == true
end


function M.toggle(node_id, default)
    if not node_id then
        return false
    end

    expanded_nodes[node_id] = not M.is_expanded(node_id, default)
    return true
end


function M.expand(node_id)
    return M.set_expanded(node_id, true)
end


function M.collapse(node_id)
    return M.set_expanded(node_id, false)
end


function M.set_expanded(node_id, expanded)
    if not node_id then
        return false
    end

    expanded_nodes[node_id] = expanded == true
    return true
end


function M.expand_tree(node)
    return set_tree_expanded(node, true)
end


function M.collapse_tree(node)
    return set_tree_expanded(node, false)
end


function M.expand_children(node)
    if not node_has_children(node) then
        return false
    end

    for _, child in ipairs(node.children or {}) do
        if type(child) == "table" and child.id then
            M.expand(child.id)
        end
    end

    return true
end


function M.collapse_children(node)
    if not node_has_children(node) then
        return false
    end

    for _, child in ipairs(node.children or {}) do
        if type(child) == "table" and child.id then
            M.collapse(child.id)
        end
    end

    return true
end


function M.reset()
    expanded_nodes = {}
end


return M
