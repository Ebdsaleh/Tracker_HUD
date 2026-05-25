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


local function get_current_scope_label(context)
    if not core.is_table(context) then
        return nil
    end

    if core.is_table(context.path) and #context.path > 0 then
        return context.path[#context.path]
    end

    if core.is_non_empty_string(context.label) then
        return context.label
    end

    return nil
end

local function member_matches_current_scope(member, context)
    if not core.is_table(member) or not core.is_table(context) then
        return false
    end

    return member.scope_start_line == context.start_line
        and member.scope_end_line == context.end_line
end



local function build_scope_label(member, context)
    if member_matches_current_scope(member, context) then
        local current_scope_label = get_current_scope_label(context)

        if core.is_non_empty_string(current_scope_label) then
            return current_scope_label
        end
    end

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
        children = {
            {
                id = member.id .. ":type",
                kind = "detail",
                label = "type: " .. tostring(member.type_label or "<unknown>"),
                children = {},
            },
            {
                id = member.id .. ":value",
                kind = "detail",
                label = "value: " .. tostring(member.value_label or "<unknown>"),
                children = {},
            },
        },    
    }

end



local function build_scope_node(member, context)
    local scope_key = get_scope_key(member)

    return {
        id = scope_key,
        kind = "scope",
        label = build_scope_label(member, context),
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



function M.build(members, context)
    local scope_nodes = {}
    local scope_order = {}

    for _, member in ipairs(members or {}) do
        if core.is_table(member) then
            local scope_key = get_scope_key(member)
            local scope_node = scope_nodes[scope_key]

            if not scope_node then
                scope_node = build_scope_node(member, context)
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
