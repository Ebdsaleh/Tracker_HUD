-- lua/tracker_hud/adapters/registry.lua
--
-- Internal adapter registry.
--
-- Users should not edit this file.
--
-- The registry stores language adapters by filetype and exposes lookup/parse
-- helpers for the context engine.
--
-- Adapter shape validation belongs to tracker_hud.adapters.contract.
-- Registry responsibilities stay limited to registration, lookup, per-buffer
-- configuration, and runtime construct validation.

local core = require("tracker_hud.core")
local adapter_contract = require("tracker_hud.adapters.contract")
local construct_contract = require("tracker_hud.constructs.contract")
local context_engine = require("tracker_hud.context_engine")

local M = {}


M.current_contract_version = adapter_contract.current_version


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


function M.validate_adapter(adapter)
    return adapter_contract.validate_adapter(adapter)
end


function M.register(adapter)
    local ok, err = M.validate_adapter(adapter)

    if not ok then
        return false, err
    end

    for _, filetype in ipairs(
        normalize_filetypes(adapter.filetypes)
    ) do
        adapters_by_filetype[filetype] = adapter
    end

    return true, nil
end


function M.get_adapter(filetype)
    if not core.is_non_empty_string(filetype) then
        return nil
    end

    return adapters_by_filetype[filetype]
end


function M.configure_adapter_for_buffer(
    filetype,
    bufnr,
    config
)
    local adapter = M.get_adapter(filetype)

    if not adapter then
        return false,
            "no adapter registered for filetype: "
            .. tostring(filetype)
    end

    if type(adapter.configure_adapter_for_buffer) == "function" then
        local ok, err = pcall(
            adapter.configure_adapter_for_buffer,
            bufnr,
            config
        )

        if not ok then
            return false, tostring(err)
        end
    end

    -- Variant-backed adapters mutate their active descriptive spec during
    -- per-buffer configuration. Validate the resulting active adapter too,
    -- not only the default state that was registered at startup.
    local valid, validation_err = M.validate_adapter(adapter)

    if not valid then
        return false,
            "configured adapter is invalid: "
            .. tostring(validation_err)
    end

    return true, nil
end


function M.has_adapter(filetype)
    return M.get_adapter(filetype) ~= nil
end


function M.parse_node(
    filetype,
    node,
    bufnr
)
    local adapter = M.get_adapter(filetype)

    if not adapter then
        return nil,
            "no adapter registered for filetype: "
            .. tostring(filetype)
    end

    local matched = context_engine.match_node(
        adapter,
        node
    )

    if not matched then
        return nil, nil
    end

    local parsed_ok,
        construct,
        parse_err =
        pcall(
            context_engine.parse_node,
            adapter,
            node,
            bufnr
        )

    if not parsed_ok then
        return nil,
            "context_engine.parse_node failed for "
            .. adapter.name
            .. ": "
            .. tostring(construct)
    end

    if not construct then
        return nil, parse_err
    end

    local valid, validation_err =
        construct_contract.validate_construct(
            construct
        )

    if not valid then
        return nil,
            "invalid construct from "
            .. adapter.name
            .. ": "
            .. tostring(validation_err)
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
