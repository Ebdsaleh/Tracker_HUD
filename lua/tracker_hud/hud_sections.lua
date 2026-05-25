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


local function get_display_width(text)
    local ok, width = pcall(vim.fn.strdisplaywidth, text or "")

    if ok and type(width) == "number" then
        return width
    end

    return #(text or "")
end


local function fit_width(text, max_width)
    if not max_width or max_width <= 0 then
        return true
    end

    return get_display_width(text) <= max_width
end



local function build_scope_range_label(node)
    if type(node) ~= "table" then
        return nil
    end

    if not node.scope_start_line or not node.scope_end_line then
        return nil
    end

    return "[scope "
        .. tostring(node.scope_start_line)
        .. " - "
        .. tostring(node.scope_end_line)
        .. "]"
end


local function append_scope_member_tree_lines(lines, nodes, depth, opts)
    depth = depth or 0
    opts = opts or {}

    local indent = string.rep("  ", depth)
    local panel_width = opts.panel_width or 0

    for _, node in ipairs(nodes or {}) do
        if type(node) == "table" then
            local label = node.label or tostring(node.id or "")
            local range_label = build_scope_range_label(node)

            if node.kind == "scope" and range_label then
                local inline_label = label .. "  " .. range_label
                local rendered_inline = indent .. inline_label

                if fit_width(rendered_inline, panel_width) then
                    table.insert(lines, rendered_inline)
                else
                    table.insert(lines, indent .. label)
                    table.insert(lines, indent .. "  " .. range_label)
                end
            else
                table.insert(lines, indent .. label)
            end

            if node.children and #node.children > 0 then
                append_scope_member_tree_lines(lines, node.children, depth + 1, opts)
            end
        elseif type(node) == "string" then
            table.insert(lines, indent .. node)
        end
    end
end


local function build_scope_member_tree_lines(nodes, opts)
    local lines = {}

    append_scope_member_tree_lines(lines, nodes, 0, opts)

    return lines
end


function M.build(context, opts)
    local show_all_scope_members = hud_controls.is_enabled("show_all_scope_members")
    local scope_members = context.scope_members or {}
    opts = opts or {}

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
            lines = build_scope_member_tree_lines(scope_member_nodes, {
                panel_width = opts.panel_width,
            }),
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
