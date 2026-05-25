-- lua/tracker_hud/hud_nodes.lua
--
-- Generic expandable HUD node state.
--
-- This is for tree-like HUD rows such as scope/member/value nodes.
-- It is intentionally separate from hud_controls.lua, because controls are
-- command-like rows, while nodes are expandable data rows.


local M = {}

local expanded_nodes = {}


function M.is_expanded(node_id, default)
    if not node_id then
        return default == true
    end

    if expanded_nodes[node_id] == nil then
        return default == true
    end

    return expanded_nodes[node_id] == true
end


function M.toggle(node_id)
    if not node_id then
        return false
    end

    expanded_nodes[node_id] = not M.is_expanded(node_id, true)
    return true
end

function M.set_expanded(node_id, expanded)
    if not node_id then
        return false
    end

    expanded_nodes[node_id] = expanded == true
    return true
end


function M.reset()
    expanded_nodes = {}
end


return M
