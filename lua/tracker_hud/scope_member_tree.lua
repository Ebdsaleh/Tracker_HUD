-- lua/tracker_hud/scope_member_tree.lua
--
-- Builds display-ready tree nodes from collected scope member objects.

local core = require("tracker_hud.core")

local M = {}

local function get_scope_key(member)
    if not core.is_table(member) then
        return "scope:global"
    end

    return table.concat({
        "scope",
        tostring(member.scope_start_line or "global"),
        tostring(member.scope_end_line or "global"),
    }, ":")
end

local function build_scope_label(member)
    if not core.is_table(member) then
        return "[global scope]"
    end

    if member.scope_start_line and member.scope_end_line then
        return "[scope " .. tostring(member.scope_start_line) .. " - " .. tostring(member.scope_end_line) .. "]"
    end

    return "[global scope]"
end

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

local function build_scope_node(member)
    local scope_key = get_scope_key(member)

    return {
        id = scope_key,
        kind = "scope",
        label = build_scope_label(member),
        scope_start_line = member and member.scope_start_line or nil,
        scope_end_line = member and member.scope_end_line or nil,
        scope_depth = member and member.scope_depth or 0,
        children = {},
    }
end

local function sort_scope_nodes(left, right)
    local left_line = left.scope_start_line or 0
    local right_line = right.scope_start_line or 0

    if left_line == right_line then
        return (left.label or "") < (right.label or "")
    end

    return left_line < right_line
end

function M.build(members, _context)
    local scope_nodes = {}
    local scope_order = {}

    for _, member in ipairs(members or {}) do
        if core.is_table(member) then
            local scope_key = get_scope_key(member)
            local scope_node = scope_nodes[scope_key]

            if not scope_node then
                scope_node = build_scope_node(member)
                scope_nodes[scope_key] = scope_node
                table.insert(scope_order, scope_node)
            end

            local member_node = build_member_node(member)

            if member_node then
                table.insert(scope_node.children, member_node)
            end
        end
    end

    table.sort(scope_order, sort_scope_nodes)

    return scope_order
end

return M
