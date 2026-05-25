-- lua/tracker_hud/hud_sections.lua
--
-- HUD section state and section construction.

local hud_controls = require("tracker_hud.hud_controls")
local scope_member_tree = require("tracker_hud.scope_member_tree")

local M = {}

local section_state = {
    scope = true,
    scope_members = false,
    registers = false,
    stack = false,
    warnings = false,
}


local function is_valid_section(section_id)
    return section_id ~= nil
        and section_state[section_id] ~= nil
end

function M.toggle(section_id)
    if not is_valid_section(section_id) then
        return false
    end

    section_state[section_id] = not section_state[section_id]
    return true
end

function M.is_expanded(section_id)
    if not is_valid_section(section_id) then
        return false
    end

    return section_state[section_id] == true
end



local function build_scope_member_tree_lines(members)
    local lines = {}

    for _, member in ipairs(members or {}) do
        if type(member) == "table" then
            table.insert(lines, member.label or tostring(member.name or ""))
        elseif type(member) == "string" then
            table.insert(lines, member)
        end
    end

    return lines
end

function M.build(context)
    local show_all_scope_members = hud_controls.is_enabled("show_all_scope_members")
    local scope_members = context.scope_members or {}

    if show_all_scope_members then
        scope_members = context.all_scope_members or {}

    end


    local scope_member_nodes = scope_member_tree.build(scope_members, context)
    local sections = {
        {
            id = "scope",
            title = "Scope",
            expanded = M.is_expanded("scope"),
            lines = {},
            empty_text = "<no scope context>",
        },
        {
            id = "show_all_scope_members",
            kind = "control",
            title = hud_controls.build_title("show_all_scope_members"),
        },

        {
            id = "scope_members",
            title = "Scope Members",
            expanded = M.is_expanded("scope_members"),
            lines = build_scope_member_tree_lines(scope_member_nodes),
            empty_text = "<no scope members tracked yet>",
        },
        {
            id = "registers",
            title = "Registers",
            expanded = M.is_expanded("registers"),
            lines = {},
            empty_text = "<register tracking not available yet>",
        },
        {
            id = "stack",
            title = "Stack",
            expanded = M.is_expanded("stack"),
            lines = {},
            empty_text = "<stack tracking not available yet>",
        },
        {
            id = "warnings",
            title = "Warnings",
            expanded = M.is_expanded("warnings"),
            lines = {},
            empty_text = "<no warnings>",
        },
    }

    local scope_section = sections[1]

    if context.path and #context.path > 0 then
        for index, item in ipairs(context.path) do
            local prefix = "  "

            if index > 1 then
                prefix = "  -> "
            end

            table.insert(scope_section.lines, prefix .. item)
        end
    else
        table.insert(scope_section.lines, "  " .. context.label)
    end

    return sections
end

return M
