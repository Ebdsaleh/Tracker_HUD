-- lua/tracker_hud/scope_members.lua
--
-- Static scope member discovery.
--
-- This module discovers simple names that are visible candidates for the
-- Scope Members HUD section. It does not resolve values or lifetimes yet.

local core = require("tracker_hud.core")
local ts_utils = require("tracker_hud.treesitter_utils")
local construct_utils = require("tracker_hud.construct_utils")
local M = {}


local member_kind_labels = {
    local_ = "local",
    parameter = "param",
    function_ = "function",
}


local function get_member_kind_label(kind)
    if not core.is_non_empty_string(kind) then
        return nil
    end

    return member_kind_labels[kind] or kind 
end



local function get_member_line(member)
    if not core.is_table(member) then
        return nil
    end

    return member.line
end


local function build_member_label(member)
    if not core.is_table(member) then
        return ""
    end

    local label = member.name or ""
    local kind_label = get_member_kind_label(member.kind)

    if core.is_non_empty_string(kind_label) then
        label = "(" .. kind_label .. ") " .. label
    end

    if member.line then
        label = "[" .. tostring(member.line) .. "] " .. label
    end

    return label
end


local function make_state(opts, scope_depth, scope_range, structural_depth, structural_range)
    return {
        opts = opts or {},
        scope_depth = scope_depth or 0,
        scope_range = scope_range,

        structural_depth = structural_depth or 0,
        structural_range = structural_range,
    }
end



local function add_member(members, seen, name, kind, line, state, metadata)
    if not core.is_non_empty_string(name) then
        return
    end

    local opts = state.opts or {}
    local scope_depth = state.scope_depth or 0
    local scope_range = state.scope_range

    if opts.start_line and line and line < opts.start_line then
        return
    end

    if opts.end_line and line and line > opts.end_line then
        return
    end

    if opts.cursor_line and line and line > opts.cursor_line then
        return
    end

    local seen_key = table.concat({
        tostring(line or ""),
        tostring(kind or ""),
        tostring(scope_depth or 0),
        name,
    }, "|")

    if seen[seen_key] then
        return
    end

    seen[seen_key] = true

    metadata = metadata or {}

    local member = {
        line = line,
        kind = kind,
        name = name,
        scope_depth = scope_depth or 0,
        scope_start_line = scope_range and scope_range.start_line,
        scope_end_line = scope_range and scope_range.end_line,

        -- metadata
        value_text = metadata.value_text,
        value_node_type = metadata.value_node_type,
        value_start_line = metadata.value_start_line,
        value_end_line = metadata.value_end_line,
        value_kind = metadata.value_kind,
        type_label = metadata.type_label,
        source_node_type = metadata.source_node_type,
    }

    member.id = table.concat({
        "member",
        tostring(member.scope_start_line or ""),
        tostring(member.scope_end_line or ""),
        tostring(member.line or ""),
        tostring(member.kind or ""),
        tostring(member.name or ""),
    }, ":")

    member.label = build_member_label(member)

    table.insert(members, member)
end





local function get_field_value_node(node)
    if not node then
        return nil
    end

    local value_node = ts_utils.get_child_by_field_name(node, "value")

    if value_node then
        return value_node
    end

    if node:named_child_count() >= 2 then
        return node:named_child(1)
    end

    return nil
end



local function strip_quotes(text)
    if not core.is_non_empty_string(text) then
        return text
    end

    return text
        :gsub('^"', "")
        :gsub('"$', "")
        :gsub("^'", "")
        :gsub("'$", "")
end


local function get_field_name(node, bufnr)
    if not node then
        return nil
    end

    local name_node = ts_utils.get_child_by_field_name(node, "name")
        or ts_utils.get_child_by_field_name(node, "key")

    if name_node then
        return strip_quotes(ts_utils.get_node_text(name_node, bufnr))
    end

    local first_named_child = node:named_child(0)

    if not first_named_child then
        return nil
    end

    local child_type = first_named_child:type()

    if child_type ~= "identifier" and child_type ~= "string" then
        return nil
    end

    return strip_quotes(ts_utils.get_node_text(first_named_child, bufnr))
end




local function should_skip_member_spec_node(node, member_spec)
    return core.is_table(member_spec)
        and ts_utils.node_has_ancestor_type(
            node,
            member_spec.exclude_ancestor_node_types
        )
end


local function collect_names_with_values_from_list_nodes(
    name_list_node,
    value_list_node,
    bufnr,
    adapter,
    members,
    seen,
    kind,
    line,
    state
)
    if not name_list_node then
        return
    end

    for i = 0, name_list_node:named_child_count() - 1 do
        local name_node = name_list_node:named_child(i)
        local value_node = nil

        if value_list_node and i < value_list_node:named_child_count() then
            value_node = value_list_node:named_child(i)
        end

        local name = ts_utils.get_node_text(name_node, bufnr)
        local metadata = construct_utils.build_value_metadata(value_node, bufnr, adapter)

        add_member(
            members,
            seen,
            name,
            kind,
            line,
            state,
            metadata
        )
    end
end


local function collect_names_from_list_node(list_node, bufnr, members, seen, kind, line, state)
    if not list_node then
        return
    end

    for i = 0, list_node:named_child_count() - 1 do
        local variable = list_node:named_child(i)
        local name = ts_utils.get_node_text(variable, bufnr)

        add_member(members, seen, name, kind, line, state)
    end
end


local function collect_list_nodes_recursive(node, bufnr, list_node_type, members, seen, kind, line, state)
    if not node then
        return
    end

    if ts_utils.node_type_matches(node, list_node_type) then
        collect_names_from_list_node(node, bufnr, members, seen, kind, line, state)
        return
    end

    for child in node:iter_children() do
        collect_list_nodes_recursive(
            child,
            bufnr,
            list_node_type,
            members,
            seen,
            kind,
            line,
            state
        )
    end
end


local function collect_declaration_member_spec(node, bufnr, member_spec, members, seen, state, adapter)
    if not core.is_table(member_spec) then
        return
    end

    local opts = state.opts or {}
    local scope_depth = state.scope_depth or 0

    if opts and opts.scope_depth ~= nil and scope_depth ~= opts.scope_depth then
        return
    end

    if not ts_utils.node_type_matches(node, member_spec.node_type) then
        return
    end

    if should_skip_member_spec_node(node, member_spec) then
        return
    end

    local name_list_node = ts_utils.find_first_descendant_by_type(
        node,
        member_spec.name_list_node_type or member_spec.list_node_type
    )

    if not name_list_node then
        return
    end

    local value_list_node = ts_utils.find_first_descendant_by_type(
        node,
        member_spec.value_list_node_type
    )

    local line = ts_utils.get_node_line(node)

    collect_names_with_values_from_list_nodes(
        name_list_node,
        value_list_node,
        bufnr,
        adapter,
        members,
        seen,
        member_spec.member and member_spec.member.kind,
        line,
        state
    )
end


local function collect_return_member_spec(node, bufnr, member_spec, members, seen, state, adapter)
    if not core.is_table(member_spec) then
        return
    end

    local opts = state.opts or {}
    local scope_depth = state.scope_depth or 0

    if opts and opts.scope_depth ~= nil and scope_depth ~= opts.scope_depth then
        return
    end

    if not ts_utils.node_type_matches(node, member_spec.node_type) then
        return
    end

    local value_list_node = ts_utils.find_first_descendant_by_type(
        node,
        member_spec.value_list_node_type
    )

    if not value_list_node then
        return
    end

    local line = ts_utils.get_node_line(node)
    local kind = member_spec.member and member_spec.member.kind

    for i = 0, value_list_node:named_child_count() - 1 do
        local value_node = value_list_node:named_child(i)
        local metadata = construct_utils.build_value_metadata(value_node, bufnr, adapter)
        local name = "return"

        if value_list_node:named_child_count() > 1 then
            name = "return #" .. tostring(i + 1)
        end

        add_member(
            members,
            seen,
            name,
            kind,
            line,
            state,
            metadata
        )
    end
end


local function get_function_name(node, bufnr)
    if not node then
        return nil
    end

    local name_node = ts_utils.get_child_by_field_name(node, "name")

    if not name_node then
        return nil
    end

    return ts_utils.get_node_text(name_node, bufnr)
end


local function collect_function_member_spec(node, bufnr, member_spec, members, seen, state, adapter)
    if not core.is_table(member_spec) then
        return
    end

    local opts = state.opts or {}
    local scope_depth = state.scope_depth or 0

    if opts and opts.scope_depth ~= nil and scope_depth ~= opts.scope_depth then
        return
    end

    if not ts_utils.node_type_matches(node, member_spec.node_type) then
        return
    end

    local name = get_function_name(node, bufnr)

    if not core.is_non_empty_string(name) then
        return
    end

    local line = ts_utils.get_node_line(node)
    local range = ts_utils.get_node_range_fields(node)
    local kind = member_spec.member and member_spec.member.kind
    local value_spec = construct_utils.get_value_spec_from_node(node, adapter)

    local metadata = {
        value_text = name,
        value_node_type = node:type(),
        value_start_line = range.start_line,
        value_end_line = range.end_line,
        value_kind = nil,
        type_label = nil,
        source_node_type = node:type(),
    }

    if core.is_table(value_spec) then
        metadata.value_kind = value_spec.kind
        metadata.type_label = value_spec.type_label
    end

    add_member(
        members,
        seen,
        name,
        kind,
        line,
        state,
        metadata
    )
end


local function collect_loop_member_spec(node, bufnr, member_spec, members, seen, state)
    if not core.is_table(member_spec) then
        return
    end
    
    local opts = state.opts or {}
    local scope_depth = state.scope_depth or 0
    
    if opts and opts.scope_depth ~= nil and scope_depth ~= opts.scope_depth then
        return
    end

    if not ts_utils.node_type_matches(node, member_spec.node_type) then
        return 
    end
    
    local line = ts_utils.get_node_line(node)
    local kind = member_spec.member and member_spec.member.kind

    if core.is_non_empty_string(member_spec.name_field) then
        local name_node = ts_utils.get_child_by_field_name(node, member_spec.name_field)

        if name_node then
            local name = ts_utils.get_node_text(name_node, bufnr)

            add_member(
                members,
                seen,
                name,
                kind,
                line,
                state
            )
        end
        return
    end

    local name_list_node = ts_utils.find_first_descendant_by_type(
        node,
        member_spec.name_list_node_type
    )

    if not name_list_node then
        return 
    end

    collect_names_from_list_node(
        name_list_node,
        bufnr,
        members,
        seen,
        kind,
        line,
        state
    )

end




local function collect_member_spec(node, bufnr, member_spec, members, seen, state)
    if not core.is_table(member_spec) then
        return
    end

    local opts = state.opts or {}
    local scope_depth = state.scope_depth or 0

    if opts and opts.scope_depth ~= nil and scope_depth ~= opts.scope_depth then
        return
    end

    if not ts_utils.node_type_matches(node, member_spec.node_type) then
        return
    end

    local line = ts_utils.get_node_line(node)

    collect_list_nodes_recursive(
        node,
        bufnr,
        member_spec.list_node_type,
        members,
        seen,
        member_spec.member and member_spec.member.kind,
        line,
        state
    )
end



local function make_structural_member_state(state)
    if not state then
        return make_state()
    end

    return make_state(
        state.opts,
        state.scope_depth,
        state.structural_range or state.scope_range,
        state.structural_depth,
        state.structural_range
    )
end


local function collect_field_member_spec(node, bufnr, member_spec, members, seen, state, adapter)
    if not core.is_table(member_spec) then
        return
    end

    if not ts_utils.node_type_matches(node, member_spec.node_type) then
        return
    end

    local name = get_field_name(node, bufnr)

    if not core.is_non_empty_string(name) then
        return
    end

    local line = ts_utils.get_node_line(node)
    local member_state = state
    local value_node = get_field_value_node(node)
    local metadata = construct_utils.build_value_metadata(value_node, bufnr, adapter)


    if member_spec.member and member_spec.member.owner_scope == "structural" then
        member_state = make_structural_member_state(state)
    end

    add_member(
        members,
        seen,
        name,
        member_spec.member and member_spec.member.kind,
        line,
        member_state,
        {
            value_text = metadata.value_text,
            value_node_type = metadata.value_node_type,
            value_start_line = metadata.value_start_line,
            value_end_line = metadata.value_end_line,
            value_kind = metadata.value_kind,
            type_label = metadata.type_label,
            source_node_type = node:type(),
        }
    )
end


local function should_collect_before_scope_enter(member_spec)
    return core.is_table(member_spec)
        and core.is_table(member_spec.member)
        and member_spec.member.owner_scope == "parent_lexical"
end


local function collect_member_group(node, bufnr, specs, members, seen, state, collector, adapter)
    if not core.is_table(specs) then
        return
    end

    collector = collector or collect_member_spec

    for _, member_spec in ipairs(specs) do
        if not should_collect_before_scope_enter(member_spec) then
            collector(node, bufnr, member_spec, members, seen, state, adapter)
        end
    end
end


local function collect_member_group_before_scope_enter(
    node,
    bufnr,
    specs,
    members,
    seen,
    state,
    collector,
    adapter
)
    if not core.is_table(specs) then
        return
    end

    for _, member_spec in ipairs(specs) do
        if should_collect_before_scope_enter(member_spec) then
            collector(node, bufnr, member_spec, members, seen, state, adapter)
        end
    end
end



local function collect_from_node(node, bufnr, adapter, members, seen, state)
    if not node or not core.is_table(adapter) then
        return
    end

    local scope_member_spec = adapter.scope_members or {}

    -- declarations
    collect_member_group(
        node,
        bufnr,
        scope_member_spec.declarations,
        members,
        seen,
        state,
        collect_declaration_member_spec,
        adapter
    )

    -- assignments
    collect_member_group(
        node,
        bufnr,
        scope_member_spec.assignments,
        members,
        seen,
        state,
        collect_declaration_member_spec,
        adapter
    )

    -- parameters
    collect_member_group(
        node,
        bufnr,
        scope_member_spec.parameters,
        members,
        seen,
        state
    )

    -- functions
    collect_member_group(
        node,
        bufnr,
        scope_member_spec.functions,
        members,
        seen,
        state,
        collect_function_member_spec,
        adapter
    )

    -- loops
    collect_member_group(
        node,
        bufnr,
        scope_member_spec.loops,
        members,
        seen,
        state,
        collect_loop_member_spec
    )

    -- returns
    collect_member_group(
        node,
        bufnr,
        scope_member_spec.returns,
        members,
        seen,
        state,
        collect_return_member_spec,
        adapter
    )

    -- fields
    collect_member_group(
        node,
        bufnr,
        scope_member_spec.fields,
        members,
        seen,
        state,
        collect_field_member_spec,
        adapter
    )
end


local function walk_node(node, bufnr, adapter, members, seen, state)
    if not node then
        return
    end

    state = state or make_state()

    local current_state = state

    local scope_member_spec = adapter.scope_members or {}

    collect_member_group_before_scope_enter(
        node,
        bufnr,
        scope_member_spec.functions,
        members,
        seen,
        state,
        collect_function_member_spec,
        adapter
    )


    if construct_utils.node_creates_lexical_scope(node, adapter) then
        current_state = make_state(
            state.opts,
            state.scope_depth + 1,
            ts_utils.get_node_range(node),
            state.structural_depth,
            state.structural_range
        )
    end

    if construct_utils.node_creates_structural_scope(node, adapter) then
        current_state = make_state(
            current_state.opts,
            current_state.scope_depth,
            current_state.scope_range,
            current_state.structural_depth + 1,
            ts_utils.get_node_range(node)
        )
    end

    collect_from_node(node, bufnr, adapter, members, seen, current_state)

    for child in node:iter_children() do
        walk_node(child, bufnr, adapter, members, seen, current_state)
    end
end


function M.collect(bufnr, root_node, adapter, opts)
    local members = {}
    local seen = {}

    if not root_node or not core.is_table(adapter) then
        return members
    end

    if not core.is_table(adapter.scope_members) then
        return members
    end

    walk_node(root_node, bufnr, adapter, members, seen, make_state(opts, 0))

    table.sort(members, function(left, right)
        local left_line = get_member_line(left)
        local right_line = get_member_line(right)

        if left_line and right_line then
            if left_line == right_line then
                return (left.label or "") < (right.label or "")
            end

            return left_line < right_line
        end

        return (left.label or "") < (right.label or "")
    end)

    return members
end

return M
