-- lua/tracker_hud/inspect_mode.lua
--
-- Active source-side HUD inspection mode.
--
-- This module tracks which HUD section should respond when the user runs
-- a source-side inspect/reveal command.

local core = require("tracker_hud.core")

local M = {}

local modes = {
    "scope",
    "scope_members",
    "registers",
    "events",
    "stack",
    "heap",
    "warnings",
}


local labels = {
    scope = "Scope",
    scope_members = "Scope Members",
    registers = "Registers",
    events = "Events",
    stack = "Stack",
    heap = "Heap",
    warnings = "Warnings",
}


local mode_index_by_id = {}

for index, mode_id in ipairs(modes) do
    mode_index_by_id[mode_id] = index
end

local current_mode = "scope"

local function normalize_mode(mode_id)
    if not core.is_non_empty_string(mode_id) then
        return nil
    end


    if not mode_index_by_id[mode_id] then
        return nil
    end

    return mode_id
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

    return labels[mode_id] or mode_id
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
    local current_index = mode_index_by_id[current_mode] or 1
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


return M
