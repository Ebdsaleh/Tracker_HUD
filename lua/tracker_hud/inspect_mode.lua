-- lua/tracker_hud/inspect_mode.lua
--
-- Active source-side HUD inspection mode.
--
-- The available inspect modes come from the active HUD section order.
-- This keeps inspection workflow aligned with adapter presentation.
--
-- This module does not know about Registers, Stack, Heap, Events,
-- architecture names, languages, or adapter-specific section meanings.

local core = require("tracker_hud.core")

local M = {}

local modes = {
    "scope",
    "scope_members",
    "warnings",
}

local mode_index_by_id = {}
local current_mode = "scope"


local function humanize_section_id(section_id)
    if not core.is_non_empty_string(section_id) then
        return "<unknown>"
    end

    local label = section_id:gsub("_", " ")

    label = label:gsub("(%a)([%w']*)", function(first, rest)
        return first:upper() .. rest
    end)

    return label
end


local function rebuild_mode_index()
    mode_index_by_id = {}

    for index, mode_id in ipairs(modes) do
        mode_index_by_id[mode_id] = index
    end
end


local function normalize_modes(section_order)
    local normalized = {}
    local seen = {}

    for _, section_id in ipairs(section_order or {}) do
        if core.is_non_empty_string(section_id)
            and not seen[section_id]
        then
            seen[section_id] = true
            table.insert(normalized, section_id)
        end
    end

    return normalized
end


local function normalize_mode(mode_id)
    if not core.is_non_empty_string(mode_id) then
        return nil
    end

    if not mode_index_by_id[mode_id] then
        return nil
    end

    return mode_id
end


function M.set_modes(section_order)
    local next_modes = normalize_modes(section_order)

    if #next_modes == 0 then
        return false
    end

    modes = next_modes
    rebuild_mode_index()

    -- Preserve the user's current inspect mode when the new adapter also
    -- exposes it. Otherwise move to the first section in that adapter's
    -- presentation order.
    if not mode_index_by_id[current_mode] then
        current_mode = modes[1]
    end

    return true
end


function M.get_modes()
    local result = {}

    for _, mode_id in ipairs(modes) do
        table.insert(result, mode_id)
    end

    return result
end


function M.is_valid_mode(mode_id)
    return normalize_mode(mode_id) ~= nil
end


function M.get_mode()
    return current_mode
end


function M.get_label(mode_id)
    mode_id = normalize_mode(mode_id or current_mode)

    if not mode_id then
        return "<unknown>"
    end

    return humanize_section_id(mode_id)
end


function M.set_mode(mode_id)
    mode_id = normalize_mode(mode_id)

    if not mode_id then
        return false
    end

    current_mode = mode_id
    return true
end


function M.cycle_mode()
    if #modes == 0 then
        return nil
    end

    local current_index = mode_index_by_id[current_mode]

    if not current_index then
        current_mode = modes[1]
        return current_mode
    end

    local next_index = current_index + 1

    if next_index > #modes then
        next_index = 1
    end

    current_mode = modes[next_index]

    return current_mode
end


function M.get_status_label()
    return "Inspect: " .. M.get_label(current_mode)
end


rebuild_mode_index()

return M
