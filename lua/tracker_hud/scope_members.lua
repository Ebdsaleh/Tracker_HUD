-- lua/tracker_hud/scope_members.lua
--
-- Static scope member discovery.
--
-- This module discovers simple names that are visible candidates for the
-- Scope Members HUD section. It does not resolve values or lifetimes yet.

local core = require("tracker_hud.core")

local M = {}

local function add_member(members, seen, name, kind, line)
    if not core.is_non_empty_string(name) then
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

local function collect_declaration(node, bufnr, declaration_spec, members, seen)
    if not core.is_table(declaration_spec) then
        return
    end

    if not node_type_matches(node, declaration_spec.node_type) then
        return
    end

    local line = get_node_line(node)
    local list_node_type = declaration_spec.list_node_type

    for i = 0, node:named_child_count() - 1 do
        local child = node:named_child(i)

        if node_type_matches(child, list_node_type) then
            for j = 0, child:named_child_count() - 1 do
                local variable = child:named_child(j)
                local name = get_node_text(variable, bufnr)

                add_member(
                    members,
                    seen,
                    name,
                    declaration_spec.kind,
                    line
                )
            end
        end
    end
end

local function collect_from_node(node, bufnr, adapter, members, seen)
    if not node or not core.is_table(adapter) then
        return
    end

    local scope_member_spec = adapter.scope_members or {}
    local declarations = scope_member_spec.declarations or {}

    if not core.is_table(declarations) then
        return
    end

    for _, declaration_spec in ipairs(declarations) do
        collect_declaration(node, bufnr, declaration_spec, members, seen)
    end
end

local function walk_node(node, bufnr, adapter, members, seen)
    if not node then
        return
    end

    collect_from_node(node, bufnr, adapter, members, seen)

    for i = 0, node:named_child_count() - 1 do
        walk_node(node:named_child(i), bufnr, adapter, members, seen)
    end
end

function M.collect(bufnr, root_node, adapter)
    local members = {}
    local seen = {}

    if not root_node or not core.is_table(adapter) then
        return members
    end

    if not core.is_table(adapter.scope_members) then
        return members
    end

    walk_node(root_node, bufnr, adapter, members, seen)

    table.sort(members)

    return members
end

return M
