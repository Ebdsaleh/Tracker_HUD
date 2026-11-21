-- lua/tracker_hud/adapters/availability.lua
--
-- Generic semantic availability decisions for adapter-owned ordered target
-- dimensions.
--
-- Adapters declare vocabulary and ordered target values. This shared helper
-- decides whether one semantic declaration is available at a selected target.
-- It does not mutate adapters, scan directives, or filter runtime structures.

local core =
    require("tracker_hud.core")
local target_dimensions =
    require("tracker_hud.adapters.target_dimensions")

local M = {}


local function ordered_index(descriptor)
    if not core.is_table(descriptor) then
        return nil,
            "availability target descriptor must be a table"
    end

    if not core.is_table(descriptor.supported)
        or #descriptor.supported == 0
    then
        return nil,
            "availability target descriptor must declare ordered supported values"
    end

    local index = {}

    for position, value in ipairs(
        descriptor.supported
    ) do
        if not core.is_non_empty_string(
            value
        ) then
            return nil,
                "availability target descriptor supported values must be non-empty strings"
        end

        if index[value] ~= nil then
            return nil,
                "availability target descriptor supported values must be unique"
        end

        index[value] = position
    end

    return index, nil
end


local function resolve(
    descriptor,
    requested,
    label
)
    local value, err =
        target_dimensions.resolve_value(
            descriptor,
            requested
        )

    if value == nil then
        return nil,
            label
                .. " could not be resolved: "
                .. tostring(err)
    end

    return value, nil
end


local function resolve_position(
    descriptor,
    index,
    requested,
    label
)
    local value, err =
        resolve(
            descriptor,
            requested,
            label
        )

    if value == nil then
        return nil, nil, err
    end

    local position = index[value]

    if position == nil then
        return nil, nil,
            label
                .. " is not present in ordered supported values: "
                .. tostring(value)
    end

    return value, position, nil
end


function M.is_available(
    declaration,
    context
)
    if declaration == nil then
        return true, nil
    end

    if not core.is_table(declaration) then
        return false,
            "availability declaration must be a table"
    end

    if not core.is_table(context) then
        return false,
            "availability context must be a table"
    end

    if not core.is_non_empty_string(
        declaration.language
    ) then
        return false,
            "availability declaration language must be a non-empty string"
    end

    if not core.is_non_empty_string(
        context.language
    ) then
        return false,
            "availability context language must be a non-empty string"
    end

    if declaration.language
        ~= context.language
    then
        return false, nil
    end

    local descriptor = context.descriptor

    local index, index_err =
        ordered_index(descriptor)

    if index == nil then
        return false, index_err
    end

    local selected,
        selected_position,
        selected_err =
        resolve_position(
            descriptor,
            index,
            context.selected,
            "selected target"
        )

    if selected == nil then
        return false, selected_err
    end

    local standards =
        declaration.standards

    if standards ~= nil then
        if declaration.since ~= nil
            or declaration["until"] ~= nil
        then
            return false,
                "availability explicit standards cannot be combined with a range"
        end

        if not core.is_table(standards)
            or #standards == 0
        then
            return false,
                "availability standards must be a non-empty list"
        end

        -- ipairs() skips extra keys and stops at holes. Validate the whole
        -- table before interpreting any explicit target as available.
        local length = #standards
        local entries = 0

        for key in pairs(standards) do
            if type(key) ~= "number"
                or key < 1
                or key > length
                or key ~= math.floor(key)
            then
                return false,
                    "availability standards must be a dense integer-indexed list"
            end

            entries = entries + 1
        end

        if entries ~= length then
            return false,
                "availability standards must be a dense integer-indexed list"
        end

        -- Validate the complete declaration even after a matching value.
        -- An invalid trailing or duplicate canonical target must never
        -- activate a semantic rule.
        local matched = false
        local seen = {}

        for _, requested in ipairs(
            standards
        ) do
            local resolved, err =
                resolve(
                    descriptor,
                    requested,
                    "availability standard"
                )

            if resolved == nil then
                return false, err
            end

            if seen[resolved] then
                return false,
                    "availability standards must be unique by resolved target: "
                        .. tostring(resolved)
            end

            seen[resolved] = true

            if resolved == selected then
                matched = true
            end
        end

        return matched, nil
    end

    local since_position = nil
    local until_position = nil

    if declaration.since ~= nil then
        local _, position, err =
            resolve_position(
                descriptor,
                index,
                declaration.since,
                "availability since boundary"
            )

        if position == nil then
            return false, err
        end

        since_position = position
    end

    if declaration["until"] ~= nil then
        local _, position, err =
            resolve_position(
                descriptor,
                index,
                declaration["until"],
                "availability until boundary"
            )

        if position == nil then
            return false, err
        end

        until_position = position
    end

    if since_position == nil
        and until_position == nil
    then
        return false,
            "availability declaration must define a range or explicit standards"
    end

    if since_position ~= nil
        and until_position ~= nil
        and since_position > until_position
    then
        return false,
            "availability range is reversed"
    end

    if since_position ~= nil
        and selected_position < since_position
    then
        return false, nil
    end

    if until_position ~= nil
        and selected_position > until_position
    then
        return false, nil
    end

    return true, nil
end


return M
