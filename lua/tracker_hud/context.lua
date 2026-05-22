-- lua/tracker_hud/context.lua

local M = {}

local adapter_registry = require("tracker_hud.adapters.registry")

local function make_global_context()
    return {
        label = "Global Scope",
        node_type = nil,
        start_line = nil,
        end_line = nil,
        depth = 0,
        path = {},
        scopes = {},
    }
end

local function make_unavailable_context(message, filetype)
    return {
        label = message,
        node_type = nil,
        start_line = nil,
        end_line = nil,
        depth = 0,
        path = {},
        scopes = {},
        unavailable = true,
        filetype = filetype,
    }
end



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
        return make_unavailable_context(
            "No Tree-sitter parser available for filetype: " .. tostring(filetype),
            filetype
        )
    end

    if not adapter_registry.has_adapter(filetype) then
        return make_unavailable_context(
            "No Tracker HUD adapter available for filetype: " .. tostring(filetype),
            filetype
        )
    end

    local node = vim.treesitter.get_node()

    if not node then
        return make_global_context()
    end

    local context = make_global_context()

    local scopes = {}

    while node do
        local construct = try_parse_construct_with_adapter(bufnr, node)

        if construct then
            local line_number = construct.range.start_line
            local label = construct.signature or construct.label
            local display_label = construct.metadata.display_label 
                or "[" .. line_number .. "] " .. label

            table.insert(scopes, {
                label = display_label,
                raw_label = label,
                node_type = construct.node_type,
                kind = construct.kind,
                start_line = construct.range.start_line,
                end_line = construct.range.end_line,
                construct = construct,
            })

        end

        node = node:parent()
    end

    if #scopes == 0 then
        return context
    end

    -- We collected from innermost -> outermost.
    -- Reverse it so HUD reads outermost -> innermost.
    local path = {}

    for i = #scopes, 1, -1 do
        table.insert(path, scopes[i].label)
    end

    local innermost = scopes[1]
    local separator = config.separator or " -> "

    context.label = "Scope: " .. table.concat(path, separator)
    context.node_type = innermost.node_type
    context.start_line = innermost.start_line
    context.end_line = innermost.end_line
    context.depth = #scopes
    context.path = path
    context.scopes = scopes

    return context
end

return M
