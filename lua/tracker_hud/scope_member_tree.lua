-- lua/tracker_hud/scope_member_tree.lua
--
-- Builds display-ready tree nodes from collected scope member objects.

local core = require("tracker_hud.core")

local M = {}

local function build_member_node(member)
    if not core.is_table(member) then
        return nil
    end

    return {
        id = member.id,
        kind = "member",
        label = member.label or tostring(member.name or ""),
        member = member,
        children = {},
    }
end


function M.build(members, _context)
    local nodes = {}

    for _, member in ipairs(members or {}) do
        local node = build_member_node(member)

        if node then
            table.insert(nodes, node)
        end
    end

    return nodes
end


return M

