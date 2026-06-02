-- lua/tracker_hud/context.lua

local M = {}

local adapter_registry = require("tracker_hud.adapters.registry")
local context_engine = require("tracker_hud.context_engine")
local scope_members = require("tracker_hud.scope_members")
local registers = require("tracker_hud.registers")
local stack = require("tracker_hud.stack")


local function try_parse_construct_with_adapter(bufnr, node)
    if not node then
        return nil
    end

    local filetype = vim.bo[bufnr].filetype

    if not filetype or filetype == "" then
        return nil
    end

    if not adapter_registry.has_adapter(filetype) then
        return nil
    end

    local construct, _err = adapter_registry.parse_node(filetype, node, bufnr)
    return construct
end


local function find_nearest_member_scope(scopes)
    for _, scope_entry in ipairs(scopes or {}) do
        local scope = scope_entry.scope

        if type(scope) == "table"
            and (
                scope.affects_visibility == true
                or scope.owns_members == true
            )
        then
            return scope_entry
        end
    end

    return nil
end


local function build_member_scope_context(scope_entry)
    if type(scope_entry) ~= "table" then
        return nil
    end

    return {
        label = scope_entry.label,
        raw_label = scope_entry.raw_label,
        node_type = scope_entry.node_type,
        kind = scope_entry.kind,
        start_line = scope_entry.start_line,
        end_line = scope_entry.end_line,
    }
end


function M.get_cursor_context(bufnr, config)
    config = config or {}

    local filetype = vim.bo[bufnr].filetype
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)

    if not ok or not parser then
        return context_engine.make_unavailable_context(
            "No Tree-sitter parser available for filetype: " .. tostring(filetype),
            filetype
        )
    end

    if not adapter_registry.has_adapter(filetype) then
        return context_engine.make_unavailable_context(
            "No Tracker HUD adapter available for filetype: " .. tostring(filetype),
            filetype
        )
    end

    local tree = parser:parse()[1]
    local root_node = nil

    if tree then
        root_node = tree:root()
    end

    local adapter = adapter_registry.get_adapter(filetype)
    local node = vim.treesitter.get_node()

    if not node then
        local context = context_engine.make_global_context()

        context.member_scope = nil

        context.scope_members = scope_members.collect(bufnr, root_node, adapter, {
            scope_depth = 0,
            cursor_line = context.cursor and context.cursor.line,
        })

        context.all_scope_members = scope_members.collect(bufnr, root_node, adapter)
        context.registers = registers.collect(context, adapter)
        context.stack = stack.collect(context, adapter)

        return context
    end

    local scopes = {}

    while node do
        local construct = try_parse_construct_with_adapter(bufnr, node)

        if construct then
            local scope_entry = context_engine.build_scope_entry_from_construct(construct)

            if scope_entry then
                table.insert(scopes, scope_entry)
            end
        end

        node = node:parent()
    end

    local context = context_engine.build_context_from_scopes(scopes, config)

    local scope_member_opts = {
        cursor_line = context.cursor and context.cursor.line,
    }

    local nearest_member_scope = find_nearest_member_scope(context.scopes)

    if nearest_member_scope then
        scope_member_opts.start_line = nearest_member_scope.start_line
        scope_member_opts.end_line = nearest_member_scope.end_line
        context.member_scope = build_member_scope_context(nearest_member_scope)
    else
        scope_member_opts.scope_depth = 0
        context.member_scope = nil
    end

    context.scope_members = scope_members.collect(bufnr, root_node, adapter, scope_member_opts)
    context.all_scope_members = scope_members.collect(bufnr, root_node, adapter)
    context.registers = registers.collect(context, adapter)
    context.stack = stack.collect(context, adapter)

    return context
end

return M
