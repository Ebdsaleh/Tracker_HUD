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


local function inspect_registers(request)
    local ok, target_node_id = hud_sections.inspect_registers(request)

    if not ok then
        return make_result(
            false,
            nil,
            "tracker_hud: no Registers node found for current source position"
        )
    end

    return make_result(true, target_node_id, nil)
end


local function inspect_stack(request)
    local ok, target_node_id = hud_sections.inspect_stack(request)

    if not ok then
        return make_result(
            false,
            nil,
            "tracker_hud: no Stack node found for current source position"
        )
    end

    return make_result(true, target_node_id, nil)
end

local function inspect_heap(request)
    local ok, target_node_id = hud_sections.inspect_heap(request)

    if not ok then
        return make_result(
            false,
            nil,
            "tracker_hud: no Heap node found for current source position"
        )
    end

    return make_result(true, target_node_id, nil)
end

local function inspect_scope(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return make_result(
            false,
            nil,
            "tracker_hud: no Scope context available for current source position"
        )
    end

    hud_sections.set_expanded("scope", true)

    return make_result(true, nil, nil)
end

local function inspect_section_shell(section_id, section_label, request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return make_result(
            false,
            nil,
            "tracker_hud: no " .. tostring(section_label) .. " context available for current source position"
        )
    end

    hud_sections.set_expanded(section_id, true)

    return make_result(true, nil, nil)
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


local function expand_section_tree(mode, request)
    local ok, target_node_id = hud_sections.expand_section_tree(request, mode)

    if not ok then
        return make_result(
            false,
            nil,
            "tracker_hud: no " .. tostring(mode) .. " nodes found to expand"
        )
    end

    return make_result(true, target_node_id, nil)
end


local function collapse_section_tree(mode, request)
    local ok, target_node_id = hud_sections.collapse_section_tree(request, mode)

    if not ok then
        return make_result(
            false,
            nil,
            "tracker_hud: no " .. tostring(mode) .. " nodes found to collapse"
        )
    end

    return make_result(true, target_node_id, nil)
end


function M.inspect(mode, request)
    if mode == "scope" then
        return inspect_scope(request)
    end

    if mode == "scope_members" then
        return inspect_scope_members(request)
    end

    if mode == "registers" then
        return inspect_registers(request)
    end

    if mode == "stack" then
        return inspect_stack(request)
    end

    if mode == "heap" then
        return inspect_heap(request)
    end

    if mode == "warnings" then
        return inspect_section_shell("warnings", "Warnings", request)
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

    if mode == "registers" or mode == "stack" or mode == "heap" then
        return expand_section_tree(mode, request)
    end

    if mode == "warnings" then
        hud_sections.set_expanded(mode, true)
        return make_result(true, nil, nil)
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

    if mode == "registers" or mode == "stack" or mode == "heap" then
        return collapse_section_tree(mode, request)
    end

    if mode == "warnings" then
        hud_sections.set_expanded(mode, false)
        return make_result(true, nil, nil)
    end

    return make_result(
        false,
        nil,
        "tracker_hud: collapse all for " .. tostring(mode) .. " is not implemented yet"
    )
end

return M
