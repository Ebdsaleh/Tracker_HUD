-- lua/tracker_hud/adapters/target_dimensions.lua
--
-- Pure helpers for adapter-owned semantic target dimensions.
--
-- This module resolves one already-declared dimension descriptor. It does not
-- scan source directives, configure adapters, decide cache identity, or apply
-- language/architecture semantics.

local core = require("tracker_hud.core")

local M = {}


local function normalize_requested(value)
    if not core.is_string(value) then
        return nil
    end

    value =
        value:gsub("^%s+", "")
            :gsub("%s+$", "")

    if value == "" then
        return nil
    end

    return value:lower()
end


local function canonical_lookup(descriptor)
    local lookup = {}

    for _, canonical in ipairs(
        descriptor.supported or {}
    ) do
        if core.is_non_empty_string(canonical) then
            lookup[canonical:lower()] =
                canonical
        end
    end

    return lookup
end


local function alias_lookup(
    descriptor,
    canonical
)
    local lookup = {}

    for alias, target in pairs(
        descriptor.aliases or {}
    ) do
        if core.is_non_empty_string(alias)
            and core.is_non_empty_string(target)
        then
            local target_canonical =
                canonical[target:lower()]

            if target_canonical ~= nil then
                lookup[alias:lower()] =
                    target_canonical
            end
        end
    end

    return lookup
end


function M.resolve_value(
    descriptor,
    requested
)
    if not core.is_table(descriptor) then
        return nil,
            "target dimension descriptor must be a table"
    end

    local canonical =
        canonical_lookup(descriptor)

    if requested == nil then
        local default =
            normalize_requested(
                descriptor.default
            )

        if not default then
            return nil,
                "target dimension default must be a non-empty string"
        end

        local resolved =
            canonical[default]

        if resolved == nil then
            return nil,
                "target dimension default is unsupported: "
                .. tostring(
                    descriptor.default
                )
        end

        return resolved, nil
    end

    local normalized =
        normalize_requested(requested)

    if not normalized then
        return nil,
            "requested target dimension value must be a non-empty string"
    end

    local resolved =
        canonical[normalized]

    if resolved ~= nil then
        return resolved, nil
    end

    resolved =
        alias_lookup(
            descriptor,
            canonical
        )[normalized]

    if resolved ~= nil then
        return resolved, nil
    end

    return nil,
        "unsupported target dimension value: "
        .. tostring(requested)
end


return M
