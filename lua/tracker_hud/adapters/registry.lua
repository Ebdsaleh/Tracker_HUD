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
--     match_node = function(node, bufnr)
--         return true_or_false
--     end,
--
--     parse_node = function(node, bufnr)
--         return construct_or_nil, error_or_nil
--     end,
-- }

local contract = require("tracker_hud.constructs.contract")

local M = {}

local adapters_by_filetype = {}

local function is_table(value)
    return type(value) == "table"
end

local function is_string(value)
    return type(value) == "string"
end


local function is_function(value)
    return type(value) == "function"
end


local function normalize_filetypes(filetypes)
    if is_string(filetypes) then
        return { filetypes }
    end

    if is_table(filetypes) then
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
        if not is_string(filetype) or filetype == "" then
            return false, "adapter.filetypes must only contain non-empty strings"
        end
    end

    return true, nil
end


function M.validate_adapter(adapter)
    if not is_table(adapter) then
        return false, "adapter must be a table"
    end

    if not is_string(adapter.name) or adapter.name == "" then
        return false, "adapter.name must be a non-empty string"
    end

    local filetypes_ok, filetypes_err = validate_filetypes(adapter.filetypes)

    if not filetypes_ok then
        return false, filetypes_err
    end

    if not is_function(adapter.match_node) then
        return false, "adapter.match_node(node, bufnr) must be a function"
    end
    
    if not is_function(adapter.parse_node) then
        return false, "adapter.parse_node(node, bufnr) must be a function"
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
    if not is_string(filetype) or filetype == "" then
        return nil
    end
    
    return adapters_by_filetype[filetype]
end


function M.has_adapter(filetype)
    return M.get_adapter(filetype) ~= nil
end


function M.parse_node(filetype, node, bufnr)
    local adapter = M.get_adapter(filetype)

    if not adapter then
        return nil, "no adapter registered for filetype: ".. tostring(filetype)
    end


    local matched_ok, matched = pcall(adapter.match_node, node, bufnr)

    if not matched_ok then
        return nil, nil
    end


    local parsed_ok, construct, parse_err = pcall(adapter.parse_node, node, bufnr)

    if not parsed_ok then
        return nil, "adapter.parse_node failed for " .. adapter.name .. ": " .. tostring(construct)
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
