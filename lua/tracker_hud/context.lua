-- lua/tracker_hud/context.lua

local M = {}

local adapter_registry = require("tracker_hud.adapters.registry")
local context_engine = require("tracker_hud.context_engine")
local scope_members = require("tracker_hud.scope_members")



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
        context.scope_members = scope_members.collect(bufnr, root_node, adapter)
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
    context.scope_members = scope_members.collect(bufnr, root_node, adapter)

    return context
end

return M
