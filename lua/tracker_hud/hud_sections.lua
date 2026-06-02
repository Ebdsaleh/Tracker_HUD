-- lua/tracker_hud/hud_sections.lua
--
-- HUD section state and section construction.

local hud_controls = require("tracker_hud.hud_controls")
local scope_member_tree = require("tracker_hud.scope_member_tree")
local hud_nodes = require("tracker_hud.hud_nodes")
local symbol_state = require("tracker_hud.symbol_state")


local M = {}

local section_state = {
    scope = true,
    scope_members = false,
    registers = false,
    stack = false,
    warnings = false,
}


local function validate_section(section_id)
    return section_id ~= nil
        and section_state[section_id] ~= nil
end

function M.toggle(section_id)
    if not validate_section(section_id) then
        return false
    end

    section_state[section_id] = not section_state[section_id]
    return true
end

function M.is_expanded(section_id)
    if not validate_section(section_id) then
        return false
    end

    return section_state[section_id] == true
end


function M.set_expanded(section_id, expanded)
    if not validate_section(section_id) then
        return false
    end

    section_state[section_id] = expanded == true
    return true
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


local function node_has_children(node)
    return type(node) == "table"
        and type(node.children) == "table"
        and #node.children > 0
end


local function get_node_default_expanded(node)
    if type(node) ~= "table" then
        return false
    end

    return node.kind == "scope"
end


local function get_node_marker(node)
    if not node_has_children(node) then
        return "   "
    end

    if hud_nodes.is_expanded(node.id, get_node_default_expanded(node)) then
        return "[-]"
    end

    return "[+]"
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


local function append_scope_member_tree_lines(result, nodes, depth, opts)
    depth = depth or 0
    opts = opts or {}

    local indent = string.rep("  ", depth)
    local panel_width = opts.panel_width or 0

    for _, node in ipairs(nodes or {}) do
        if type(node) == "table" then
            local label = node.label or tostring(node.id or "")
            local marker = get_node_marker(node)
            local rendered_label = marker .. " " .. label
            local range_label = build_scope_range_label(node)

            if node.kind == "scope" and range_label then
                local inline_label = rendered_label .. "  " .. range_label
                local rendered_inline = indent .. inline_label

                if fit_width(rendered_inline, panel_width) then
                    table.insert(result.lines, rendered_inline)
                    result.targets[#result.lines] = {
                        kind = "node",
                        id = node.id,
                        source_line = node.source_line,
                        source_column = node.source_column,
                    }
                else
                    table.insert(result.lines, indent .. rendered_label)
                    result.targets[#result.lines] = {
                        kind = "node",
                        id = node.id,
                        source_line = node.source_line,
                        source_column = node.source_column,
                    }

                    table.insert(result.lines, indent .. "  " .. range_label)
                end
            else
                table.insert(result.lines, indent .. rendered_label)
                result.targets[#result.lines] = {
                    kind = "node",
                    id = node.id,
                    source_line = node.source_line,
                    source_column = node.source_column,
                }
            end

            if node_has_children(node) and hud_nodes.is_expanded(node.id, get_node_default_expanded(node)) then
                append_scope_member_tree_lines(result, node.children, depth + 1, opts)
            end
        elseif type(node) == "string" then
            table.insert(result.lines, indent .. node)
        end
    end
end



local function build_scope_member_tree_lines(nodes, opts)
    local result = {
        lines = {},
        targets = {},
    }

    append_scope_member_tree_lines(result, nodes, 0, opts)

    return result
end

local function get_node_source_range(node)
    if type(node) ~= "table" then
        return nil
    end

    if node.source_start_line and node.source_end_line then
        return {
            start_line = node.source_start_line,
            start_column = node.source_start_column or 0,
            end_line = node.source_end_line,
            end_column = node.source_end_column or 0,
        }
    end

    if node.scope_start_line and node.scope_end_line then
        return {
            start_line = node.scope_start_line,
            start_column = 0,
            end_line = node.scope_end_line,
            end_column = 0,
        }
    end

    if type(node.member) == "table" then
        if node.member.value_start_line and node.member.value_end_line then
            return {
                start_line = node.member.value_start_line,
                start_column = node.member.value_start_column or 0,
                end_line = node.member.value_end_line,
                end_column = node.member.value_end_column or 0,
            }
        end

        if node.member.source_start_line and node.member.source_end_line then
            return {
                start_line = node.member.source_start_line,
                start_column = node.member.source_start_column or 0,
                end_line = node.member.source_end_line,
                end_column = node.member.source_end_column or 0,
            }
        end

        if node.member.line then
            return {
                start_line = node.member.line,
                start_column = 0,
                end_line = node.member.line,
                end_column = 0,
            }
        end
    end

    if node.source_line then
        return {
            start_line = node.source_line,
            start_column = node.source_column or 0,
            end_line = node.source_line,
            end_column = node.source_column or 0,
        }
    end

    return nil
end


local function position_is_in_range(source_line, source_column, range)
    if not source_line or type(range) ~= "table" then
        return false
    end

    local start_line = range.start_line
    local end_line = range.end_line

    if not start_line or not end_line then
        return false
    end

    source_column = tonumber(source_column) or 0

    local start_column = tonumber(range.start_column) or 0
    local end_column = tonumber(range.end_column) or 0

    if source_line < start_line or source_line > end_line then
        return false
    end

    if start_line == end_line then
        return source_column >= start_column
            and source_column <= end_column
    end

    if source_line == start_line then
        return source_column >= start_column
    end

    if source_line == end_line and end_column > 0 then
        return source_column <= end_column
    end

    return true
end

local function node_contains_position(node, source_line, source_column)
    local range = get_node_source_range(node)

    return position_is_in_range(source_line, source_column, range)
end

local function find_deepest_node_path_for_position(nodes, source_line, source_column, current_path, best_path)
    current_path = current_path or {}
    best_path = best_path or nil

    for _, node in ipairs(nodes or {}) do
        if type(node) == "table" and node_contains_position(node, source_line, source_column) then
            local next_path = {}

            for _, path_node in ipairs(current_path) do
                table.insert(next_path, path_node)
            end

            table.insert(next_path, node)
            best_path = next_path

            if node_has_children(node) then
                best_path = find_deepest_node_path_for_position(
                    node.children,
                    source_line,
                    source_column,
                    next_path,
                    best_path
                )
            end
        end
    end

    return best_path
end



function M.inspect_scope_members(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local source_line = tonumber(request.line)
    local source_column = tonumber(request.column) or 0

    if not source_line then
        return false
    end

    local context = request.context
    local show_all_scope_members = hud_controls.is_enabled("show_all_scope_members")
    local scope_members = context.scope_members or {}

    if show_all_scope_members then
        scope_members = context.all_scope_members or {}
    end

    scope_members = symbol_state.enrich_members(scope_members, context)

    local scope_member_nodes = scope_member_tree.build(scope_members, context)

    -- Use the source cursor position to reveal/toggle the deepest matching Scope Members node.
    local node_path = find_deepest_node_path_for_position(
        scope_member_nodes,
        source_line,
        source_column
    )

    if not node_path or #node_path == 0 then
        return false
    end

    M.set_expanded("scope_members", true)

    local target_index = #node_path
    local target_node = node_path[target_index]
    local target_node_id = target_node and target_node.id

    for index, node in ipairs(node_path) do
        if node_has_children(node) then
            if index < target_index then
                -- Ancestors must stay open so the target remains visible.
                hud_nodes.set_expanded(node.id, true)
            else
                -- The target itself toggles open/closed.
                local currently_expanded = hud_nodes.is_expanded(
                    node.id,
                    get_node_default_expanded(node)
                )

                hud_nodes.set_expanded(node.id, not currently_expanded)
            end
        end
    end

    return true, target_node_id
end


function M.build(context, opts)
    local show_all_scope_members = hud_controls.is_enabled("show_all_scope_members")
    local scope_members = context.scope_members or {}
    opts = opts or {}

    if show_all_scope_members then
        scope_members = context.all_scope_members or {}
    end

    scope_members = symbol_state.enrich_members(scope_members, context)

    local scope_member_nodes = scope_member_tree.build(scope_members, context)
    local scope_member_render = build_scope_member_tree_lines(scope_member_nodes, {
        panel_width = opts.panel_width,
    })

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
            lines = scope_member_render.lines,
            line_targets = scope_member_render.targets,
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
