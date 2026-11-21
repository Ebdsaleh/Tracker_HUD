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


-- The resolver case-folds canonical and alias names into lookup keys.
-- Reject collisions before a later entry can silently replace an earlier one.
function M.validate_name_uniqueness(descriptor)
    if not core.is_table(descriptor) then
        return false,
            "target dimension descriptor must be a table"
    end

    if not core.is_table(descriptor.supported) then
        return false,
            "target dimension supported values must be a list"
    end

    -- A sparse table's # length is not reliably defined in Lua.
    -- Validate every key before ipairs() can silently skip entries.
    local entries = 0
    local last_index = 0

    for index in pairs(
        descriptor.supported
    ) do
        if type(index) ~= "number"
            or index < 1
            or index ~= math.floor(index)
        then
            return false,
                "target dimension supported values must be a dense integer-indexed list"
        end

        entries = entries + 1

        if index > last_index then
            last_index = index
        end
    end

    if entries ~= last_index then
        return false,
            "target dimension supported values must be a dense integer-indexed list"
    end

    local seen = {}
    local canonical_values = {}

    for _, value in ipairs(
        descriptor.supported
    ) do
        if not core.is_non_empty_string(value) then
            return false,
                "target dimension canonical names must be non-empty strings"
        end

        local key = value:lower()

        if seen[key] then
            return false,
                "target dimension normalized name collision: "
                    .. tostring(value)
        end

        seen[key] = true
        canonical_values[value] = true
    end

    if descriptor.aliases ~= nil then
        if not core.is_table(descriptor.aliases) then
            return false,
                "target dimension aliases must be a table"
        end

        for alias, target in pairs(
            descriptor.aliases
        ) do
            if not core.is_non_empty_string(alias) then
                return false,
                    "target dimension alias names must be non-empty strings"
            end

            if not core.is_non_empty_string(target)
                or not canonical_values[target]
            then
                return false,
                    "target dimension alias must resolve directly to a supported canonical value: "
                        .. tostring(alias)
            end

            local key = alias:lower()

            if seen[key] then
                return false,
                    "target dimension normalized name collision: "
                        .. tostring(alias)
            end

            seen[key] = true
        end
    end

    return true, nil
end


function M.resolve_value(
    descriptor,
    requested
)
    local valid, validation_err =
        M.validate_name_uniqueness(descriptor)

    if not valid then
        return nil, validation_err
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
