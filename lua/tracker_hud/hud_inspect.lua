-- lua/tracker_hud/hud_inspect.lua
--
-- Generic source-position inspection dispatch.
--
-- The source cursor acts like an inspection point/window.
-- The active inspect mode decides which HUD section interprets it.

local hud_sections = require("tracker_hud.hud_sections")

local M = {}


local function make_result(ok, target_node_id, message)
    return {
        ok = ok == true,
        target_node_id = target_node_id,
        message = message,
    }
end


local function inspect_scope_members(request)
    local ok, target_node_id = hud_sections.inspect_scope_members(request)

    if not ok then
        return make_result(
            false,
            nil,
            "tracker_hud: no Scope Members node found for current source position"
        )
    end

    return make_result(true, target_node_id, nil)
end


local function expand_scope_members(request)
    local ok, target_node_id = hud_sections.expand_scope_members_in_current_scope(request)

    if not ok then
        return make_result(
            false,
            nil,
            "tracker_hud: no Scope Members scope found for current source position"
        )
    end

    return make_result(true, target_node_id, nil)
end


local function collapse_scope_members(request)
    local ok, target_node_id = hud_sections.collapse_scope_members_in_current_scope(request)

    if not ok then
        return make_result(
            false,
            nil,
            "tracker_hud: no Scope Members scope found for current source position"
        )
    end

    return make_result(true, target_node_id, nil)
end


function M.inspect(mode, request)
    if mode == "scope_members" then
        return inspect_scope_members(request)
    end

    return make_result(
        false,
        nil,
        "tracker_hud: source inspect for " .. tostring(mode) .. " is not implemented yet"
    )
end


function M.expand_all(mode, request)
    if mode == "scope_members" then
        return expand_scope_members(request)
    end

    return make_result(
        false,
        nil,
        "tracker_hud: expand all for " .. tostring(mode) .. " is not implemented yet"
    )
end


function M.collapse_all(mode, request)
    if mode == "scope_members" then
        return collapse_scope_members(request)
    end

    return make_result(
        false,
        nil,
        "tracker_hud: collapse all for " .. tostring(mode) .. " is not implemented yet"
    )
end


return M
