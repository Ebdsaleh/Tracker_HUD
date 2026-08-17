-- lua/tracker_hud/namespace.lua
--
-- Public identifier namespace helpers.
--
-- The plugin's public-facing identifiers should be derived from semantic
-- suffixes instead of hard-coding the project name throughout the codebase.
-- This keeps command/highlight naming independent from the final plugin name.

local core = require("tracker_hud.core")

local M = {}

local DEFAULT_PREFIX = "Hud"


local function configured_prefix(config)
    if not core.is_table(config) then
        return DEFAULT_PREFIX
    end

    local namespace = config.namespace

    if not core.is_table(namespace) then
        return DEFAULT_PREFIX
    end

    if namespace.prefix == nil then
        return DEFAULT_PREFIX
    end

    return namespace.prefix
end


function M.validate_prefix(prefix)
    if not core.is_non_empty_string(prefix) then
        return false, "namespace.prefix must be a non-empty string"
    end

    -- Neovim user commands must begin with an uppercase character. Keeping
    -- the shared public prefix to this identifier-safe subset also makes it
    -- suitable for future highlight-group names.
    if not prefix:match("^[A-Z][A-Za-z0-9]*$") then
        return false,
            "namespace.prefix must start with an uppercase letter and contain only letters or digits"
    end

    return true, nil
end


function M.prefix(config)
    local prefix = configured_prefix(config)
    local valid, err = M.validate_prefix(prefix)

    if not valid then
        error("tracker_hud: " .. tostring(err), 2)
    end

    return prefix
end


function M.name(config, suffix)
    if not core.is_non_empty_string(suffix) then
        error("tracker_hud: namespace suffix must be a non-empty string", 2)
    end

    if not suffix:match("^[A-Z][A-Za-z0-9]*$") then
        error(
            "tracker_hud: namespace suffix must start with an uppercase letter and contain only letters or digits",
            2
        )
    end

    return M.prefix(config) .. suffix
end


return M

