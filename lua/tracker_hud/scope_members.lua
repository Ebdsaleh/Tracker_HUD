-- lua/tracker_hud/scope_members.lua
--
-- Static scope member discovery.
--
-- This module discovers simple names that are visible candidates for the
-- Scope Members HUD section. It does not resolve values or lifetimes yet.

local core = require("tracker_hud.core")

local M = {}

local function build_member_label(member)
    if not core.is_table(member) then
        return ""
    end

    local label = member.name or ""

    if core.is_non_empty_string(member.kind) then
        label = "(" .. member.kind .. ") " .. label
    end

    if member.line then
        label = "[" .. tostring(member.line) .. "] " .. label
    end

    return label
end



local function get_member_line(member)
    if not core.is_table(member) then
        return nil
    end

    return member.line
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

        value_text = metadata.value_text,
        value_node_type = metadata.value_node_type,
        value_start_line = metadata.value_start_line,
        value_end_line = metadata.value_end_line,
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


local function get_node_range(node)
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

local function get_node_range_fields(node)
    local range = get_node_range(node)

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



local function get_node_line(node)
    if not node then
        return nil
    end

    local start_row = node:range()

    if not core.is_number(start_row) then
        return nil
    end

    return start_row + 1
end

local function get_node_text(node, bufnr)
    local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)

    if not ok then
        return nil
    end

    return text
end


local function get_child_by_field_name(node, field_name)
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



local function get_field_value_node(node)
    if not node then
        return nil
    end

    local value_node = get_child_by_field_name(node, "value")

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

    local name_node = get_child_by_field_name(node, "name")
        or get_child_by_field_name(node, "key")

    if name_node then
        return strip_quotes(get_node_text(name_node, bufnr))
    end

    local first_named_child = node:named_child(0)

    if not first_named_child then
        return nil
    end

    local child_type = first_named_child:type()

    if child_type ~= "identifier" and child_type ~= "string" then
        return nil
    end

    return strip_quotes(get_node_text(first_named_child, bufnr))
end




local function get_construct_spec(node, adapter)
    if not node or not core.is_table(adapter) or not core.is_table(adapter.construct_specs) then
        return nil
    end

    return adapter.construct_specs[node:type()]
end



local function node_creates_lexical_scope(node, adapter)
    local spec = get_construct_spec(node, adapter)

    if not core.is_table(spec) then
        return false
    end

    if core.is_table(spec.scope_effect) then
        return spec.scope_effect.lexical == true
    end

    return spec.creates_scope == true
end


local function node_creates_structural_scope(node, adapter)
    local spec = get_construct_spec(node, adapter)

    if not core.is_table(spec) then
        return false
    end

    if core.is_table(spec.scope_effect) then
        return spec.scope_effect.structural == true
    end

    return spec.scope_kind == "structural"
end



local function node_type_matches(node, expected_type)
    return node
        and core.is_non_empty_string(expected_type)
        and node:type() == expected_type
end



local function collect_names_from_list_node(list_node, bufnr, members, seen, kind, line, state)
    if not list_node then
        return
    end

    for i = 0, list_node:named_child_count() - 1 do
        local variable = list_node:named_child(i)
        local name = get_node_text(variable, bufnr)

        add_member(members, seen, name, kind, line, state)
    end
end


local function collect_list_nodes_recursive(node, bufnr, list_node_type, members, seen, kind, line, state)
    if not node then
        return
    end

    if node_type_matches(node, list_node_type) then
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



local function collect_member_spec(node, bufnr, member_spec, members, seen, state)
    if not core.is_table(member_spec) then
        return
    end

    local opts = state.opts or {}
    local scope_depth = state.scope_depth or 0

    if opts and opts.scope_depth ~= nil and scope_depth ~= opts.scope_depth then
        return
    end

    if not node_type_matches(node, member_spec.node_type) then
        return
    end

    local line = get_node_line(node)

    collect_list_nodes_recursive(
        node,
        bufnr,
        member_spec.list_node_type,
        members,
        seen,
        member_spec.kind,
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


local function collect_field_member_spec(node, bufnr, member_spec, members, seen, state)
    if not core.is_table(member_spec) then
        return
    end

    if not node_type_matches(node, member_spec.node_type) then
        return
    end

    local name = get_field_name(node, bufnr)

    if not core.is_non_empty_string(name) then
        return
    end

    local line = get_node_line(node)
    local member_state = state
    local value_node = get_field_value_node(node)
    local value_text = nil
    local value_node_type = nil
    local value_range = {
        start_line = nil,
        end_line = nil,
    }

    if value_node then
        value_text = get_node_text(value_node, bufnr)
        value_node_type = value_node:type()
        value_range = get_node_range_fields(value_node)
    end

    if member_spec.scope_kind == "structural" then
        member_state = make_structural_member_state(state)
    end

    add_member(
        members,
        seen,
        name,
        member_spec.kind,
        line,
        member_state,
        {
            value_text = value_text,
            value_node_type = value_node_type,
            value_start_line = value_range.start_line,
            value_end_line = value_range.end_line,
            source_node_type = node:type(),
        }
    )
end



local function collect_member_group(node, bufnr, specs, members, seen, state, collector)
    if not core.is_table(specs) then
        return
    end

    collector = collector or collect_member_spec

    for _, member_spec in ipairs(specs) do
        collector(node, bufnr, member_spec, members, seen, state)
    end
end



local function collect_from_node(node, bufnr, adapter, members, seen, state)
    if not node or not core.is_table(adapter) then
        return
    end

    local scope_member_spec = adapter.scope_members or {}

    collect_member_group(
        node,
        bufnr,
        scope_member_spec.declarations,
        members,
        seen,
        state
    )

    collect_member_group(
        node,
        bufnr,
        scope_member_spec.parameters,
        members,
        seen,
        state
    )

    collect_member_group(
        node,
        bufnr,
        scope_member_spec.fields,
        members,
        seen,
        state,
        collect_field_member_spec
    )
end


local function walk_node(node, bufnr, adapter, members, seen, state)
    if not node then
        return
    end

    state = state or make_state()

    local current_state = state

    if node_creates_lexical_scope(node, adapter) then
        current_state = make_state(
            state.opts,
            state.scope_depth + 1,
            get_node_range(node),
            state.structural_depth,
            state.structural_range
        )
    end

    if node_creates_structural_scope(node, adapter) then
        current_state = make_state(
            current_state.opts,
            current_state.scope_depth,
            current_state.scope_range,
            current_state.structural_depth + 1,
            get_node_range(node)
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
