-- lua/tracker_hud/adapters/compatibility.lua
--
-- Adapter-framework compatibility application.
--
-- Adapters own dimension names, ordered values, aliases, active selections,
-- and declaration metadata. This shared wrapper selects the declared dimension
-- and delegates ordered availability decisions to the generic resolver.

local core =
    require("tracker_hud.core")
local availability =
    require("tracker_hud.adapters.availability")

local M = {}


local function normalized_declaration(
    declaration
)
    local normalized = {
        language = declaration.language,
        since = declaration.since,
        ["until"] = declaration["until"],
    }

    if declaration.values ~= nil then
        normalized.standards =
            declaration.values
    elseif declaration.standards ~= nil then
        -- Transitional compatibility with checkpoint-204/205 metadata.
        normalized.standards =
            declaration.standards
    end

    return normalized
end


function M.is_available(
    adapter,
    declaration
)
    if declaration == nil then
        return true, nil
    end

    if not core.is_table(adapter) then
        return false,
            "compatibility adapter must be a table"
    end

    if not core.is_table(declaration) then
        return false,
            "compatibility declaration must be a table"
    end

    if not core.is_non_empty_string(
        declaration.dimension
    ) then
        return false,
            "compatibility declaration dimension must be a non-empty string"
    end

    if not core.is_table(
        adapter.target_dimensions
    ) then
        return false,
            "adapter does not declare target dimensions"
    end

    local descriptor =
        adapter.target_dimensions[
            declaration.dimension
        ]

    if not core.is_table(descriptor) then
        return false,
            "unknown compatibility dimension: "
                .. tostring(
                    declaration.dimension
                )
    end

    if not core.is_table(
        adapter.active_targets
    ) then
        return false,
            "adapter does not expose active targets"
    end

    local selected =
        adapter.active_targets[
            declaration.dimension
        ]

    if selected == nil then
        return false,
            "active target missing for compatibility dimension: "
                .. tostring(
                    declaration.dimension
                )
    end

    return availability.is_available(
        normalized_declaration(
            declaration
        ),
        {
            language = adapter.name,
            descriptor = descriptor,
            selected = selected,
        }
    )
end


return M
