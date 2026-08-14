-- lua/tracker_hud/scope_member_tree.lua
--
-- Builds display-ready tree nodes from collected scope member objects.
--
-- Scope nodes exist independently of whether they currently contain members.
-- This is important because source constructs such as:
--
--     if ... then
--     for ... do
--     while ... do
--
-- create real scopes before a member has necessarily been encountered.
--
-- Members populate scopes; they do not create the scopes themselves.

local core = require("tracker_hud.core")

local M = {}


local function make_scope_key(start_line, end_line)
    if not start_line or not end_line then
        return "scope:global"
    end

    return table.concat({
        "scope",
        tostring(start_line),
        tostring(end_line),
    }, ":")
end


local function get_scope_key(member)
    if not core.is_table(member) then
        return "scope:global"
    end

    return make_scope_key(
        member.scope_start_line,
        member.scope_end_line
    )
end


local function get_current_scope_label(context)
    if not core.is_table(context) then
        return nil
    end

    if core.is_table(context.path)
        and #context.path > 0
    then
        return context.path[#context.path]
    end

    if core.is_non_empty_string(context.label) then
        return context.label
    end

    return nil
end


local function member_matches_current_scope(
    member,
    context
)
    if not core.is_table(member)
        or not core.is_table(context)
    then
        return false
    end

    return member.scope_start_line == context.start_line
        and member.scope_end_line == context.end_line
end


local function build_scope_label(member, context)
    if member_matches_current_scope(member, context) then
        local current_scope_label =
            get_current_scope_label(context)

        if core.is_non_empty_string(
            current_scope_label
        ) then
            return current_scope_label
        end
    end

    if not core.is_table(member) then
        return "[global scope]"
    end

    if member.scope_start_line
        and member.scope_end_line
    then
        return "[scope "
            .. tostring(member.scope_start_line)
            .. " - "
            .. tostring(member.scope_end_line)
            .. "]"
    end

    return "[global scope]"
end


local function build_member_scope_label(
    member_scope,
    context
)
    if core.is_table(member_scope) then
        if core.is_non_empty_string(
            member_scope.label
        ) then
            return member_scope.label
        end

        if member_scope.start_line
            and member_scope.end_line
        then
            return "[scope "
                .. tostring(member_scope.start_line)
                .. " - "
                .. tostring(member_scope.end_line)
                .. "]"
        end
    end

    return get_current_scope_label(context)
        or "[global scope]"
end


local function build_member_node(member)
    if not core.is_table(member) then
        return nil
    end

    return {
        id = member.id,
        kind = "member",
        label = member.label
            or tostring(member.name or ""),

        source_line =
            member.source_start_line
            or member.line,

        source_column =
            member.source_start_column
            or 0,

        source_start_line =
            member.source_start_line
            or member.line,

        source_start_column =
            member.source_start_column
            or 0,

        source_end_line =
            member.source_end_line
            or member.line,

        source_end_column =
            member.source_end_column
            or member.source_start_column
            or 0,

        member = member,

        children = {
            {
                id = member.id .. ":type",
                kind = "detail",

                label = "type: "
                    .. tostring(
                        member.type_label
                        or "<unknown>"
                    ),

                children = {},
            },

            {
                id = member.id .. ":value",
                kind = "detail",

                label = "value: "
                    .. tostring(
                        member.value_label
                        or "<unknown>"
                    ),

                source_line =
                    member.value_start_line
                    or member.source_start_line
                    or member.line,

                source_column =
                    member.value_start_column
                    or member.source_start_column
                    or 0,

                source_start_line =
                    member.value_start_line
                    or member.source_start_line
                    or member.line,

                source_start_column =
                    member.value_start_column
                    or member.source_start_column
                    or 0,

                source_end_line =
                    member.value_end_line
                    or member.source_end_line
                    or member.line,

                source_end_column =
                    member.value_end_column
                    or member.source_end_column
                    or member.source_start_column
                    or 0,

                children = {},
            },
        },
    }
end


local function build_scope_node(
    member,
    context
)
    local scope_key = get_scope_key(member)

    return {
        id = scope_key,
        kind = "scope",
        label = build_scope_label(
            member,
            context
        ),

        source_line =
            member
            and member.scope_start_line
            or nil,

        source_column =
            member
            and member.scope_start_column
            or 0,

        source_start_line =
            member
            and member.scope_start_line
            or nil,

        source_start_column =
            member
            and member.scope_start_column
            or 0,

        source_end_line =
            member
            and member.scope_end_line
            or nil,

        source_end_column =
            member
            and member.scope_end_column
            or 0,

        scope_start_line =
            member
            and member.scope_start_line
            or nil,

        scope_start_column =
            member
            and member.scope_start_column
            or 0,

        scope_end_line =
            member
            and member.scope_end_line
            or nil,

        scope_end_column =
            member
            and member.scope_end_column
            or 0,

        scope_depth =
            member
            and member.scope_depth
            or 0,

        children = {},
    }
end


local function build_scope_node_from_context(
    context
)
    if not core.is_table(context)
        or not core.is_table(
            context.member_scope
        )
    then
        return nil
    end

    local member_scope = context.member_scope

    if not member_scope.start_line
        or not member_scope.end_line
    then
        return nil
    end

    return {
        id = make_scope_key(
            member_scope.start_line,
            member_scope.end_line
        ),

        kind = "scope",

        label = build_member_scope_label(
            member_scope,
            context
        ),

        source_line =
            member_scope.start_line,

        source_column = 0,

        source_start_line =
            member_scope.start_line,

        source_start_column = 0,

        source_end_line =
            member_scope.end_line,

        source_end_column = 0,

        scope_start_line =
            member_scope.start_line,

        scope_start_column = 0,

        scope_end_line =
            member_scope.end_line,

        scope_end_column = 0,

        scope_depth =
            context.depth or 0,

        node_type =
            member_scope.node_type,

        construct_kind =
            member_scope.kind,

        children = {},
    }
end


local function sort_scope_nodes(left, right)
    local left_line =
        left.scope_start_line or 0

    local right_line =
        right.scope_start_line or 0

    if left_line == right_line then
        return (left.label or "")
            < (right.label or "")
    end

    return left_line < right_line
end


local function get_scope_range_key(
    start_line,
    end_line
)
    if not start_line or not end_line then
        return nil
    end

    return table.concat({
        "scope_range",
        tostring(start_line),
        tostring(end_line),
    }, ":")
end


local function member_has_structural_value(
    member
)
    return core.is_table(member)
        and (
            member.value_kind == "table"
            or member.value_kind == "structural"
        )
        and member.value_start_line ~= nil
        and member.value_end_line ~= nil
end


local function build_scope_range_index(
    scope_order
)
    local scope_range_index = {}

    for _, scope_node in ipairs(
        scope_order or {}
    ) do
        local range_key =
            get_scope_range_key(
                scope_node.scope_start_line,
                scope_node.scope_end_line
            )

        if range_key then
            scope_range_index[range_key] =
                scope_node
        end
    end

    return scope_range_index
end


local function attach_structural_scopes_to_members(
    scope_order
)
    local scope_range_index =
        build_scope_range_index(scope_order)

    local attached_scope_ids = {}

    for _, scope_node in ipairs(
        scope_order or {}
    ) do
        for _, member_node in ipairs(
            scope_node.children or {}
        ) do
            local member =
                member_node.member

            if member_has_structural_value(
                member
            ) then
                local range_key =
                    get_scope_range_key(
                        member.value_start_line,
                        member.value_end_line
                    )

                local structural_scope_node =
                    scope_range_index[
                        range_key
                    ]

                if structural_scope_node
                    and structural_scope_node.id
                        ~= scope_node.id
                then
                    table.insert(
                        member_node.children,
                        structural_scope_node
                    )

                    attached_scope_ids[
                        structural_scope_node.id
                    ] = true
                end
            end
        end
    end

    local filtered_scope_order = {}

    for _, scope_node in ipairs(
        scope_order or {}
    ) do
        if not attached_scope_ids[
            scope_node.id
        ] then
            table.insert(
                filtered_scope_order,
                scope_node
            )
        end
    end

    return filtered_scope_order
end


function M.build(members, context)
    local scope_nodes = {}
    local scope_order = {}

    --
    -- A scope exists independently of its members.
    --
    -- Seed the active member scope first so constructs such as an empty
    -- if/for/while branch remain represented and inspectable even before
    -- their first member has been encountered.
    --

    local context_scope_node =
        build_scope_node_from_context(
            context
        )

    if context_scope_node then
        scope_nodes[
            context_scope_node.id
        ] = context_scope_node

        table.insert(
            scope_order,
            context_scope_node
        )
    end


    for _, member in ipairs(
        members or {}
    ) do
        if core.is_table(member) then
            local scope_key =
                get_scope_key(member)

            local scope_node =
                scope_nodes[scope_key]

            if not scope_node then
                scope_node =
                    build_scope_node(
                        member,
                        context
                    )

                scope_nodes[scope_key] =
                    scope_node

                table.insert(
                    scope_order,
                    scope_node
                )
            end

            local member_node =
                build_member_node(member)

            if member_node then
                table.insert(
                    scope_node.children,
                    member_node
                )
            end
        end
    end

    table.sort(
        scope_order,
        sort_scope_nodes
    )

    scope_order =
        attach_structural_scopes_to_members(
            scope_order
        )

    return scope_order
end


return M
