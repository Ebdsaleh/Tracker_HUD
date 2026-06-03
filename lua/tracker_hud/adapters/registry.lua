-- lua/tracker_hud/adapters/registry.lua
--
-- Internal adapter registry.
--
-- Users should not edit this file.
--
-- The registry stores language adapters by filetype and exposes lookup/parse
-- helpers for the context engine.
--
-- Adapter contract:
--
-- return {
--     name = "lua",
--     filetypes = { "lua" },
--
--     construct_specs = {
--         [tree_sitter_node_type] = {
--             kind = "...",
--             label = "...",
--             creates_scope = true_or_false,
--         },
--     },
-- }

local core = require("tracker_hud.core")
local contract = require("tracker_hud.constructs.contract")
local context_engine = require("tracker_hud.context_engine")

local M = {}

local adapters_by_filetype = {}

local function normalize_filetypes(filetypes)
    if core.is_string(filetypes) then
        return { filetypes }
    end

    if core.is_table(filetypes) then
        return filetypes
    end

    return {}
end


local function validate_filetypes(filetypes)
    local normalized = normalize_filetypes(filetypes)

    if #normalized == 0 then
        return false, "adapter.filetypes must contain at least one filetype"
    end


    for _, filetype in ipairs(normalized) do
        if not core.is_string(filetype) or filetype == "" then
            return false, "adapter.filetypes must only contain non-empty strings"
        end
    end

    return true, nil
end


function M.validate_adapter(adapter)
    if not core.is_table(adapter) then
        return false, "adapter must be a table"
    end

    if not core.is_string(adapter.name) or adapter.name == "" then
        return false, "adapter.name must be a non-empty string"
    end

    local filetypes_ok, filetypes_err = validate_filetypes(adapter.filetypes)

    if not filetypes_ok then
        return false, filetypes_err
    end

    if not core.is_table(adapter.construct_specs) then
        return false, "adapter.construct_specs must be a table"
    end

    return true, nil
end


function M.register(adapter)
    local ok, err = M.validate_adapter(adapter)

    if not ok then
        return false, err
    end


    for _, filetype in ipairs(normalize_filetypes(adapter.filetypes)) do
        adapters_by_filetype[filetype] = adapter
    end


    return true, nil
end


function M.get_adapter(filetype)
    if not core.is_string(filetype) or filetype == "" then
        return nil
    end

    return adapters_by_filetype[filetype]
end


function M.configure_adapter_for_buffer(filetype, bufnr, config)
    local adapter = M.get_adapter(filetype)

    if not adapter then
        return false, "no adapter registered for filetype: " .. tostring(filetype)
    end

    if type(adapter.configure_adapter_for_buffer) ~= "function" then
        return true, nil
    end

    local ok, err = pcall(adapter.configure_adapter_for_buffer, bufnr, config)

    if not ok then
        return false, tostring(err)
    end

    return true, nil
end



function M.has_adapter(filetype)
    return M.get_adapter(filetype) ~= nil
end


function M.parse_node(filetype, node, bufnr)
    local adapter = M.get_adapter(filetype)

    if not adapter then
        return nil, "no adapter registered for filetype: ".. tostring(filetype)
    end


    local matched = context_engine.match_node(adapter, node)

    if not matched then
        return nil, nil
    end

    local parsed_ok, construct, parse_err = pcall(context_engine.parse_node, adapter, node, bufnr)

    if not parsed_ok then
        return nil, "context_engine.parse_node failed for " .. adapter.name .. ": " .. tostring(construct)
    end


    if not construct then
        return nil, parse_err
    end

    local valid, validation_err = contract.validate_construct(construct)

    if not valid then
        return nil, "invalid construct from " .. adapter.name .. ": " .. tostring(validation_err)
    end


    return construct, nil
end


function M.list_filetypes()
    local filetypes = {}

    for filetype, _ in pairs(adapters_by_filetype) do
        table.insert(filetypes, filetype)
    end

    table.sort(filetypes)

    return filetypes
end


function M.clear()
    adapters_by_filetype = {}
end


return M
