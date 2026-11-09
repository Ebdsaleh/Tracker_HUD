-- lua/tracker_hud/presentation_mode.lua
--
-- User-controlled *meaning/detail* presentation, independent of:
--   :HudVisualMode (terminal colours/tags)
--   Inspect Mode (selected HUD section)
-- The original text HUD is always the backward-compatible default.

local M = {}

local modes = { "standard", "learning", "diagram" }
local valid = { standard = true, learning = true, diagram = true }

function M.mode_names()
    return { "standard", "learning", "diagram", "cycle" }
end

function M.resolve(config)
    local candidate = type(config) == "table"
        and type(config.presentation) == "table"
        and config.presentation.mode
        or nil
    return valid[candidate] and candidate or "standard"
end

function M.set_mode(config, requested)
    if type(config) ~= "table" then
        return nil, "presentation configuration must be a table"
    end

    local mode = type(requested) == "string"
        and requested:lower()
        or nil
    if mode == "cycle" then
        local current = M.resolve(config)
        for i, candidate in ipairs(modes) do
            if candidate == current then
                mode = modes[(i % #modes) + 1]
                break
            end
        end
    end

    if not valid[mode] then
        return nil, "expected standard, learning, diagram, or cycle"
    end

    -- Never touch source state, Inspect Mode, expansion state or adapters.
    if type(config.presentation) ~= "table" then
        config.presentation = {}
    end
    config.presentation.mode = mode
    return mode
end

return M
