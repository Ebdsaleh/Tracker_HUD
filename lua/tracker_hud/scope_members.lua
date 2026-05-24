-- lua/tracker_hud/scope_members.lua
--
-- Static scope member discovery.
--
-- This module discovers simple names that are visible candidates for the
-- Scope Members HUD section. It does not resolve values or lifetimes yet.

local core = require("tracker_hud.core")

local M = {}

local function get_member_line(member)
    if not core.is_string(member) then
        return nil    
    end

    local line = member:match("^%[(%d+)%]")

    if not line then
        return nil
    end

    return tonumber(line)
end


local function add_member(members, seen, name, kind, line, opts)
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

    if seen[name] then
        return
    end

    seen[name] = true

    local label = name

    if core.is_non_empty_string(kind) then
        label = kind .. " " .. label
    end

    if line then
        label = "[" .. tostring(line) .. "] " .. label
    end

    table.insert(members, label)
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

local function node_type_matches(node, expected_type)
    return node
        and core.is_non_empty_string(expected_type)
        and node:type() == expected_type
end



local function collect_names_from_list_node(list_node, bufnr, members, seen, kind, line, opts)
    if not list_node then
        return
    end
    
    for i = 0, list_node:named_child_count() - 1 do
        local variable = list_node:named_child(i)
        local name = get_node_text(variable, bufnr)

        add_member(members, seen, name, kind, line, opts)
    end
end


local function collect_list_nodes_recursive(node, bufnr, list_node_type, members, seen, kind, line, opts)
    if not node then
        return
    end

    if node_type_matches(node, list_node_type) then
        collect_names_from_list_node(node, bufnr, members, seen, kind, line, opts)
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
            opts
        )
    end
end

local function collect_declaration(node, bufnr, declaration_spec, members, seen, opts)
    if not core.is_table(declaration_spec) then
        return
    end

    if not node_type_matches(node, declaration_spec.node_type) then
        return
    end

    local line = get_node_line(node)

    collect_list_nodes_recursive(
        node,
        bufnr,
        declaration_spec.list_node_type,
        members,
        seen,
        declaration_spec.kind,
        line,
        opts
    )
end


local function collect_from_node(node, bufnr, adapter, members, seen, opts)
    if not node or not core.is_table(adapter) then
        return
    end

    local scope_member_spec = adapter.scope_members or {}
    local declarations = scope_member_spec.declarations or {}

    if not core.is_table(declarations) then
        return
    end

    for _, declaration_spec in ipairs(declarations) do
        collect_declaration(node, bufnr, declaration_spec, members, seen, opts)
    end
end



local function walk_node(node, bufnr, adapter, members, seen, opts)
    if not node then
        return
    end

    collect_from_node(node, bufnr, adapter, members, seen, opts)

    for child in node:iter_children() do
        walk_node(child, bufnr, adapter, members, seen, opts)
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

    walk_node(root_node, bufnr, adapter, members, seen, opts)

    table.sort(members, function(left, right)
        local left_line = get_member_line(left)
        local right_line = get_member_line(right)

        if left_line and right_line then
            if left_line == right_line then
                return left < right
            end

            return left_line < right_line
        end

        return left < right
    end)

    return members
end

return M
