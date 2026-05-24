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
        label = member.kind .. " " .. label
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

local function add_member(members, seen, name, kind, line, opts, scope_depth)
    if not core.is_non_empty_string(name) then
        return
    end

    opts = opts or {}

    if opts.start_line and line and line < opts.start_line then
        return
    end

    if opts.end_line and line and line > opts.end_line then
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

    local member = {
        line = line,
        kind = kind,
        name = name,
        scope_depth = scope_depth or 0,
    }

    member.label = build_member_label(member)

    table.insert(members, member)
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


local function node_creates_scope(node, adapter)
    if not node or not core.is_table(adapter) or not core.is_table(adapter.construct_specs) then
        return false
    end
    
    local spec = adapter.construct_specs[node:type()]

    return core.is_table(spec) and spec.creates_scope == true
end


local function node_type_matches(node, expected_type)
    return node
        and core.is_non_empty_string(expected_type)
        and node:type() == expected_type
end



local function collect_names_from_list_node(list_node, bufnr, members, seen, kind, line, opts, scope_depth)
    if not list_node then
        return
    end
    
    for i = 0, list_node:named_child_count() - 1 do
        local variable = list_node:named_child(i)
        local name = get_node_text(variable, bufnr)

        add_member(members, seen, name, kind, line, opts, scope_depth)
    end
end


local function collect_list_nodes_recursive(node, bufnr, list_node_type, members, seen, kind, line, opts, scope_depth)
    if not node then
        return
    end

    if node_type_matches(node, list_node_type) then
        collect_names_from_list_node(node, bufnr, members, seen, kind, line, opts, scope_depth)
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
            opts,
            scope_depth
        )
    end
end

local function collect_member_spec(node, bufnr, member_spec, members, seen, opts, scope_depth)
    if not core.is_table(member_spec) then
        return
    end

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
        opts,
        scope_depth
    )
end

local function collect_member_group(node, bufnr, specs, members, seen, opts, scope_depth)
    if not core.is_table(specs) then
        return
    end

    for _, member_spec in ipairs(specs) do
        collect_member_spec(node, bufnr, member_spec, members, seen, opts, scope_depth)
    end
end

local function collect_from_node(node, bufnr, adapter, members, seen, opts, scope_depth)
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
        opts,
        scope_depth
    )

    collect_member_group(
        node,
        bufnr,
        scope_member_spec.parameters,
        members,
        seen,
        opts,
        scope_depth
    )
end

local function walk_node(node, bufnr, adapter, members, seen, opts, scope_depth)
    if not node then
        return
    end

    scope_depth = scope_depth or 0
    collect_from_node(node, bufnr, adapter, members, seen, opts, scope_depth)

    local child_scope_depth = scope_depth

    if node_creates_scope(node, adapter) then
        child_scope_depth = child_scope_depth + 1
    end

    for child in node:iter_children() do
        walk_node(child, bufnr, adapter, members, seen, opts, child_scope_depth)
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

    walk_node(root_node, bufnr, adapter, members, seen, opts or {}, 0)

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
