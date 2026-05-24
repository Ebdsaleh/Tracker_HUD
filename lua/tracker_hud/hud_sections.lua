-- lua/tracker_hud/hud_sections.lua
--
-- HUD section state and section construction.

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

function M.build(context)
    local sections = {
        {
            id = "scope",
            title = "Scope",
            expanded = M.is_expanded("scope"),
            lines = {},
        },
        {
            id = "scope_members",
            title = "Scope Members",
            expanded = M.is_expanded("scope_members"),
            lines = {},
        },
        {
            id = "registers",
            title = "Registers",
            expanded = M.is_expanded("registers"),
            lines = {},
        },
        {
            id = "stack",
            title = "Stack",
            expanded = M.is_expanded("stack"),
            lines = {},
        },
        {
            id = "warnings",
            title = "Warnings",
            expanded = M.is_expanded("warnings"),
            lines = {},
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
