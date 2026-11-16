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
local configured_adapter_cache = nil
local validated_components_by_adapter =
    setmetatable(
        {},
        { __mode = "k" }
    )


local function invalidate_configuration_cache()
    configured_adapter_cache = nil
end


local function remember_validated_components(
    adapter
)
    local declared =
        type(adapter) == "table"
        and adapter.validation_stable_components
        or nil

    if type(declared) ~= "table" then
        validated_components_by_adapter[adapter] =
            nil
        return
    end

    local remembered = {}

    for component, enabled in pairs(declared) do
        if enabled == true then
            remembered[component] =
                adapter[component]
        end
    end

    validated_components_by_adapter[adapter] =
        remembered
end


local function validation_options(
    adapter,
    opts
)
    local result = {}

    if type(opts) == "table" then
        for key, value in pairs(opts) do
            result[key] = value
        end
    end

    local remembered =
        validated_components_by_adapter[adapter]
    local declared =
        type(adapter) == "table"
        and adapter.validation_stable_components
        or nil

    if type(remembered) == "table"
        and type(declared) == "table"
    then
        local eligible = {}

        for component, value in pairs(remembered) do
            if declared[component] == true then
                eligible[component] = value
            end
        end

        result.validated_components =
            eligible
    end

    return result
end


local function profile_begin(
    opts,
    name
)
    if type(opts) ~= "table"
        or type(opts.profile_begin) ~= "function"
    then
        return nil
    end

    return opts.profile_begin(name)
end


local function profile_end(
    opts,
    name,
    started
)
    if type(opts) ~= "table"
        or type(opts.profile_end) ~= "function"
    then
        return nil
    end

    return opts.profile_end(
        name,
        started
    )
end


local function get_buffer_changedtick(bufnr)
    if not bufnr
        or not vim
        or not vim.api
        or type(
            vim.api.nvim_buf_get_changedtick
        ) ~= "function"
    then
        return nil
    end

    local ok, changedtick =
        pcall(
            vim.api.nvim_buf_get_changedtick,
            bufnr
        )

    if not ok then
        return nil
    end

    return changedtick
end


local function configuration_cache_matches(
    adapter,
    filetype,
    bufnr,
    config,
    changedtick
)
    local cached =
        configured_adapter_cache

    return cached ~= nil
        and changedtick ~= nil
        and cached.adapter == adapter
        and cached.filetype == filetype
        and cached.bufnr == bufnr
        and cached.changedtick
            == changedtick
        and cached.config == config
end


local function remember_configuration(
    adapter,
    filetype,
    bufnr,
    config
)
    local changedtick =
        get_buffer_changedtick(
            bufnr
        )

    if changedtick == nil then
        invalidate_configuration_cache()
        return
    end

    configured_adapter_cache = {
        adapter = adapter,
        filetype = filetype,
        bufnr = bufnr,
        changedtick = changedtick,
        config = config,
    }
end


local function normalize_filetypes(filetypes)
    if core.is_string(filetypes) then
        return { filetypes }
    end

    if core.is_table(filetypes) then
        return filetypes
    end

    return {}
end


function M.validate_adapter(
    adapter,
    opts
)
    return adapter_contract.validate_adapter(
        adapter,
        opts
    )
end


function M.register(adapter)
    invalidate_configuration_cache()

    local ok, err = M.validate_adapter(adapter)

    if not ok then
        return false, err
    end

    remember_validated_components(
        adapter
    )

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
    config,
    opts
)
    opts = type(opts) == "table"
        and opts
        or nil

    local phase =
        profile_begin(
            opts,
            "context.configure.lookup"
        )

    local adapter = M.get_adapter(filetype)

    profile_end(
        opts,
        "context.configure.lookup",
        phase
    )

    if not adapter then
        return false,
            "no adapter registered for filetype: "
            .. tostring(filetype)
    end

    phase =
        profile_begin(
            opts,
            "context.configure.changedtick"
        )

    local changedtick =
        get_buffer_changedtick(
            bufnr
        )

    profile_end(
        opts,
        "context.configure.changedtick",
        phase
    )

    phase =
        profile_begin(
            opts,
            "context.configure.cache_check"
        )

    local cache_matches =
        configuration_cache_matches(
            adapter,
            filetype,
            bufnr,
            config,
            changedtick
        )

    profile_end(
        opts,
        "context.configure.cache_check",
        phase
    )

    if cache_matches then
        return true, nil
    end

    -- Once configuration input changes, the previously-active adapter state
    -- cannot be treated as reusable. Clear first so failures never leave a
    -- stale success entry behind.
    invalidate_configuration_cache()

    if type(adapter.configure_adapter_for_buffer) == "function" then
        phase =
            profile_begin(
                opts,
                "context.configure.adapter"
            )

        local ok, err = pcall(
            adapter.configure_adapter_for_buffer,
            bufnr,
            config
        )

        profile_end(
            opts,
            "context.configure.adapter",
            phase
        )

        if not ok then
            return false, tostring(err)
        end
    end

    -- Variant-backed adapters mutate their active descriptive spec during
    -- per-buffer configuration. Validate the resulting active adapter too,
    -- not only the default state that was registered at startup.
    phase =
        profile_begin(
            opts,
            "context.configure.validate"
        )

    local valid, validation_err =
        M.validate_adapter(
            adapter,
            validation_options(
                adapter,
                opts
            )
        )

    profile_end(
        opts,
        "context.configure.validate",
        phase
    )

    if not valid then
        return false,
            "configured adapter is invalid: "
            .. tostring(validation_err)
    end

    remember_validated_components(
        adapter
    )

    phase =
        profile_begin(
            opts,
            "context.configure.remember"
        )

    remember_configuration(
        adapter,
        filetype,
        bufnr,
        config
    )

    profile_end(
        opts,
        "context.configure.remember",
        phase
    )

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
    validated_components_by_adapter =
        setmetatable(
            {},
            { __mode = "k" }
        )
    invalidate_configuration_cache()
end


return M