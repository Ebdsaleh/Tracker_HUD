-- lua/tracker_hud/scope_members.lua
--
-- Static scope member discovery.
--
-- This module discovers simple names that are visible candidates for the
-- Scope Members HUD section. It does not resolve values or lifetimes yet.

local core = require("tracker_hud.core")

local M = {}


local function add_member(members, seen, name, kind, line)
    if not core.is_string(name) or name == "" then
        return
    end

    if seen[name] then
        return
    end


    seen[name] = true

    local label = name

    if kind and kind ~= "" then
        label = kind .. " " .. label
    end

    if line then
        label ="[" .. tostring(line) .."] " .. label
    end

    table.insert(members, label)
end


local function get_node_line(node)
    if not node then
        return nil
    end

    local start_row = node:range()

    if type(start_row) ~= "number" then
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


-- THIS SHOULD BE GENERIC AND WE PASS IN THE SESSION'S ACTIVE LANGUAGE ADAPTER...
--  THERE SHOULD ALSO BE A LOOKUP TO VERIFY THE ADAPTER EXISTS ALONG WITH ITS SECTION
--  THAT HANDLES THESE MARKERS.

local function collect_lua_local_declaration(node, bufnr, members, seen)
    if not node or node:type() ~= "variable_declaration" then
        return
    end
    
    local line = get_node_line(node)

    for i = 0, node:named_child_count() - 1 do
        local child = node:named_child(i)

        if child and child:type() == "variable_list" then
            for j = 0, child:named_child_count() - 1 do
                local variable = child:named_child(j)
                local name = get_node_text(variable, bufnr)


                add_member(members, seen, name, "local", line)
            end
        end
    end
end


local function walk_node(node, bufnr, members, seen)
    if not node then
        return
    end

    -- THIS SHOULD BE GENERIC PASS IN THE ADAPTER OR LANGUAGE
    collect_lua_local_declaration(node, bufnr, members, seen)

    for i = 0, node:named_child_count() - 1 do
        walk_node(node:named_child(i), bufnr, members, seen)
    end
end


function M.collect(bufnr, root_node, filetype)
    local members = {}
    local seen = {}

    if filetype ~= "lua" then
        return members
    end

    if not root_node then
        return members
    end

    walk_node(root_node, bufnr, members, seen)

    table.sort(members)

    return members
end


return M
