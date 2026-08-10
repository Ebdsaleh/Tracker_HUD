-- lua/tracker_hud/hud_sections.lua
--
-- HUD section state and section construction.

local hud_controls = require("tracker_hud.hud_controls")
local scope_member_tree = require("tracker_hud.scope_member_tree")
local register_tree = require("tracker_hud.register_tree")
local event_tree = require("tracker_hud.event_tree")
local stack_tree = require("tracker_hud.stack_tree")
local heap_tree = require("tracker_hud.heap_tree")
local warning_tree = require("tracker_hud.warning_tree")
local hud_nodes = require("tracker_hud.hud_nodes")
local symbol_state = require("tracker_hud.symbol_state")


local M = {}

local section_state = {
    scope = true,
    scope_members = false,
    registers = false,
    events = false,
    stack = false,
    heap = false,
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


local function node_matches_cursor(node, opts)
    if type(node) ~= "table" or type(opts) ~= "table" then
        return false
    end

    local source_line = tonumber(opts.active_source_line)
    local source_column = tonumber(opts.active_source_column)

    if not source_line or not source_column then
        return false
    end

    local start_line = tonumber(node.source_start_line or node.source_line)
    local end_line = tonumber(node.source_end_line or node.source_line)

    if not start_line or not end_line then
        return false
    end

    if source_line < start_line or source_line > end_line then
        return false
    end

    local start_column = tonumber(node.source_start_column or node.source_column or 0)
    local end_column = tonumber(node.source_end_column or node.source_column or start_column)

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


local function get_node_marker(node, opts)
    local active_marker = " "

    if node_has_children(node) and node_matches_cursor(node, opts) then
        active_marker = "*"
    end

    if not node_has_children(node) then
        return "  -"
    end

    if hud_nodes.is_expanded(node.id, get_node_default_expanded(node)) then
        return active_marker .. "[-]"
    end

    return active_marker .. "[+]"
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
            local matches_cursor = node_matches_cursor(node, opts)

            if matches_cursor then
                result.active = true
            end

            local marker = get_node_marker(node, opts)
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

            if node_has_children(node)
                and hud_nodes.is_expanded(node.id, get_node_default_expanded(node))
            then
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
        active = false,
    }

    append_scope_member_tree_lines(result, nodes, 0, opts)

    return result
end


local function build_hud_tree_lines(nodes, opts)
    local result = {
        lines = {},
        targets = {},
        active = false,
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
            start_column = node.scope_start_column or 0,
            end_line = node.scope_end_line,
            end_column = node.scope_end_column or 0,
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


local function range_contains_line(range, source_line)
    if type(range) ~= "table" or not source_line then
        return false
    end

    if not range.start_line or not range.end_line then
        return false
    end

    return source_line >= range.start_line
        and source_line <= range.end_line
end


local function get_column_distance_to_range(source_line, source_column, range)
    if type(range) ~= "table" then
        return 999999
    end

    source_column = tonumber(source_column) or 0

    local start_column = tonumber(range.start_column) or 0
    local end_column = tonumber(range.end_column) or start_column

    if range.start_line ~= range.end_line then
        return 0
    end

    if source_column < start_column then
        return start_column - source_column
    end

    if source_column > end_column then
        return source_column - end_column
    end

    return 0
end


local function find_closest_node_path_for_line(nodes, source_line, source_column, current_path, best)
    current_path = current_path or {}
    best = best or nil

    for _, node in ipairs(nodes or {}) do
        if type(node) == "table" then
            local range = get_node_source_range(node)

            if range_contains_line(range, source_line) then
                local next_path = {}

                for _, path_node in ipairs(current_path) do
                    table.insert(next_path, path_node)
                end

                table.insert(next_path, node)

                local distance = get_column_distance_to_range(
                    source_line,
                    source_column,
                    range
                )

                local depth = #next_path

                if not best
                    or distance < best.distance
                    or (
                        distance == best.distance
                        and depth > best.depth
                    )
                then
                    best = {
                        path = next_path,
                        distance = distance,
                        depth = depth,
                    }
                end

                if node_has_children(node) then
                    best = find_closest_node_path_for_line(
                        node.children,
                        source_line,
                        source_column,
                        next_path,
                        best
                    )
                end
            end
        end
    end

    return best
end



local function section_has_cursor_target(nodes, source_line, source_column)
    source_line = tonumber(source_line)
    source_column = tonumber(source_column) or 0

    if not source_line then
        return false
    end

    local node_path = find_deepest_node_path_for_position(
        nodes,
        source_line,
        source_column
    )

    if node_path and #node_path > 0 then
        return true
    end

    local fallback = find_closest_node_path_for_line(
        nodes,
        source_line,
        source_column
    )

    return fallback ~= nil and fallback.path ~= nil
end



local function build_scope_member_nodes_for_context(context, use_all_members)
    if type(context) ~= "table" then
        return {}
    end

    local scope_members = context.scope_members or {}

    if use_all_members then
        scope_members = context.all_scope_members or {}
    end

    scope_members = symbol_state.enrich_members(scope_members, context)

    return scope_member_tree.build(scope_members, context)
end


local function get_context_member_scope_range(context)
    if type(context) ~= "table" then
        return nil
    end

    if type(context.member_scope) == "table"
        and context.member_scope.start_line
        and context.member_scope.end_line
    then
        return {
            start_line = context.member_scope.start_line,
            end_line = context.member_scope.end_line,
        }
    end

    return nil
end


local function scope_node_matches_range(node, range)
    return type(node) == "table"
        and type(range) == "table"
        and node.kind == "scope"
        and node.scope_start_line == range.start_line
        and node.scope_end_line == range.end_line
end


local function find_scope_node_by_range(nodes, range)
    for _, node in ipairs(nodes or {}) do
        if scope_node_matches_range(node, range) then
            return node
        end

        local found = find_scope_node_by_range(node.children, range)

        if found then
            return found
        end
    end

    return nil
end
local function find_scope_node_inside_range(nodes, range)
    if type(range) ~= "table" then
        return nil
    end

    for _, node in ipairs(nodes or {}) do
        if type(node) == "table" and node.kind == "scope" then
            local start_line = node.scope_start_line

            if start_line
                and range.start_line
                and range.end_line
                and start_line >= range.start_line
                and start_line <= range.end_line
            then
                return node
            end
        end

        local found = find_scope_node_inside_range(node.children, range)

        if found then
            return found
        end
    end

    return nil
end


local function find_scope_node_for_range(nodes, range)
    return find_scope_node_by_range(nodes, range)
        or find_scope_node_inside_range(nodes, range)
end


local function find_deepest_expandable_node_in_path(node_path)
    for index = #(node_path or {}), 1, -1 do
        local node = node_path[index]

        if node_has_children(node) then
            return node, index
        end
    end

    return nil, nil
end


local function reveal_path_and_toggle_best_node(section_id, node_path)
    if not node_path or #node_path == 0 then
        return false, nil
    end

    local section_was_expanded = M.is_expanded(section_id)

    -- Always reveal the section first.
    M.set_expanded(section_id, true)

    local toggle_node, toggle_index = find_deepest_expandable_node_in_path(node_path)
    local target_node = toggle_node or node_path[#node_path]
    local target_node_id = target_node and target_node.id

    for index, node in ipairs(node_path) do
        if node_has_children(node) then
            if not section_was_expanded then
                -- First press opens/reveals the path.
                hud_nodes.set_expanded(node.id, true)
            elseif index < (toggle_index or #node_path) then
                -- Ancestors stay open so the target remains visible.
                hud_nodes.set_expanded(node.id, true)
            elseif node == toggle_node then
                -- Second press toggles the target.
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

local function toggle_section_fallback(section_id)
    if not validate_section(section_id) then
        return false, nil
    end

    M.set_expanded(section_id, not M.is_expanded(section_id))

    return true, nil
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
    local scope_member_nodes = build_scope_member_nodes_for_context(context, false)

    local node_path = find_deepest_node_path_for_position(
        scope_member_nodes,
        source_line,
        source_column
    )

    if not node_path or #node_path == 0 then
        local fallback = find_closest_node_path_for_line(
            scope_member_nodes,
            source_line,
            source_column
        )

        node_path = fallback and fallback.path or nil
    end

    return reveal_path_and_toggle_best_node("scope_members", node_path)
end



local function build_register_nodes_for_context(context)
    if type(context) ~= "table" then
        return {}
    end

    return register_tree.build(context.registers or {}, context)
end


local function build_event_nodes_for_context(context)
    if type(context) ~= "table" then
        return {}
    end
    return event_tree.build(context.events or {}, context)
end


local function build_stack_nodes_for_context(context)
    if type(context) ~= "table" then
        return {}
    end

    return stack_tree.build(context.stack or {}, context)
end


local function build_heap_nodes_for_context(context)
    if type(context) ~= "table" then
        return {}
    end

    local heap_root = heap_tree.build_tree(context.heap or {})

    if type(heap_root) ~= "table" then
        return {}
    end

    return heap_root.children or {}
end


local function build_warning_nodes_for_context(context)
    if type(context) ~= "table" then
        return {}
    end

    return warning_tree.build(context.warnings or {}, context)
end


local function inspect_hud_nodes_for_source_position(request, section_id, nodes)
    if type(request) ~= "table" then
        return false
    end

    local source_line = tonumber(request.line)
    local source_column = tonumber(request.column) or 0

    if not source_line then
        return false
    end

    local node_path = find_deepest_node_path_for_position(
        nodes,
        source_line,
        source_column
    )

    if not node_path or #node_path == 0 then
        local fallback = find_closest_node_path_for_line(
            nodes,
            source_line,
            source_column
        )

        node_path = fallback and fallback.path or nil
    end

    return reveal_path_and_toggle_best_node(section_id, node_path)
end


function M.inspect_registers(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local register_nodes = build_register_nodes_for_context(request.context)

    if not register_nodes or #register_nodes == 0 then
        return false
    end

    local ok, target_node_id = inspect_hud_nodes_for_source_position(
        request,
        "registers",
        register_nodes
    )

    if ok then
        return true, target_node_id
    end

    -- Fallback: Registers may contain static architecture rows that do not map
    -- to the current source position. In that case, toggle the section itself.
    return toggle_section_fallback("registers")
end


function M.inspect_events(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local event_nodes = build_event_nodes_for_context(request.context)

    if not event_nodes or #event_nodes == 0 then
        return toggle_section_fallback("events")
    end

    local ok, target_node_id = inspect_hud_nodes_for_source_position(
        request,
        "events",
        event_nodes
    )

    if ok then
        return true, target_node_id
    end

    return toggle_section_fallback("events")
end


function M.inspect_stack(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local stack_nodes = build_stack_nodes_for_context(request.context)

    if not stack_nodes or #stack_nodes == 0 then
        return false
    end

    local ok, target_node_id = inspect_hud_nodes_for_source_position(
        request,
        "stack",
        stack_nodes
    )

    if ok then
        return true, target_node_id
    end

    -- Fallback: Stack v1 is mostly static architecture data right now, so it
    -- often has no source-specific node to target yet. Toggle the section itself.
    return toggle_section_fallback("stack")
end


function M.inspect_heap(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local heap_nodes = build_heap_nodes_for_context(request.context)

    if not heap_nodes or #heap_nodes == 0 then
        return toggle_section_fallback("heap")
    end

    local ok, target_node_id = inspect_hud_nodes_for_source_position(
        request,
        "heap",
        heap_nodes
    )

    if ok then
        return true, target_node_id
    end

    return toggle_section_fallback("heap")
end


function M.inspect_warnings(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local warning_nodes = build_warning_nodes_for_context(request.context)

    if not warning_nodes or #warning_nodes == 0 then
        return toggle_section_fallback("warnings")
    end

    local ok, target_node_id = inspect_hud_nodes_for_source_position(
        request,
        "warnings",
        warning_nodes
    )

    if ok then
        return true, target_node_id
    end

    return toggle_section_fallback("warnings")
end


local function get_section_nodes(context, section_id, use_all_members)
    if type(context) ~= "table" then
        return {}
    end

    if section_id == "scope_members" then
        return build_scope_member_nodes_for_context(context, use_all_members == true)
    end

    if section_id == "registers" then
        return build_register_nodes_for_context(context)
    end

    if section_id == "events" then
        return build_event_nodes_for_context(context)
    end

    if section_id == "stack" then
        return build_stack_nodes_for_context(context)
    end

    if section_id == "heap" then
        return build_heap_nodes_for_context(context)
    end

    if section_id == "warnings" then
        return build_warning_nodes_for_context(context)
    end

    return {}
end


function M.expand_section_tree(request, section_id)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local nodes = get_section_nodes(request.context, section_id, true)

    if not nodes or #nodes == 0 then
        return false
    end

    M.set_expanded(section_id, true)

    for _, node in ipairs(nodes) do
        hud_nodes.expand_tree(node)
    end

    return true, nodes[1] and nodes[1].id
end


function M.collapse_section_tree(request, section_id)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local nodes = get_section_nodes(request.context, section_id, true)

    if not nodes or #nodes == 0 then
        return false
    end

    M.set_expanded(section_id, true)

    for _, node in ipairs(nodes) do
        hud_nodes.collapse_tree(node)
    end

    return true, nodes[1] and nodes[1].id
end


function M.expand_scope_members_in_current_scope(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local context = request.context
    local scope_range = get_context_member_scope_range(context)

    if not scope_range then
        return false
    end

    local scope_member_nodes = build_scope_member_nodes_for_context(context, true)
    local target_scope_node = find_scope_node_for_range(scope_member_nodes, scope_range)

    if not target_scope_node then
        return false
    end

    M.set_expanded("scope_members", true)
    hud_nodes.expand_tree(target_scope_node)

    return true, target_scope_node.id
end



function M.collapse_scope_members_in_current_scope(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local context = request.context
    local scope_range = get_context_member_scope_range(context)

    if not scope_range then
        return false
    end

    local scope_member_nodes = build_scope_member_nodes_for_context(context, true)
    local target_scope_node = find_scope_node_for_range(scope_member_nodes, scope_range)

    if not target_scope_node then
        return false
    end

    M.set_expanded("scope_members", true)
    hud_nodes.collapse_tree(target_scope_node)

    -- Keep the owning scope visible/open so the section does not feel like it vanished.
    hud_nodes.expand(target_scope_node.id)

    return true, target_scope_node.id
end

function M.build(context, opts)
    local show_all_scope_members = hud_controls.is_enabled("show_all_scope_members")
    local scope_members = context.scope_members or {}
    opts = opts or {}
    local active_source_line = context.cursor and context.cursor.line
    local active_source_column = nil
    if context.cursor and context.cursor.column then
        active_source_column = math.max(0, tonumber(context.cursor.column) - 1)
    end

    if show_all_scope_members then
        scope_members = context.all_scope_members or {}
    end

    scope_members = symbol_state.enrich_members(scope_members, context)

    local scope_member_nodes = scope_member_tree.build(scope_members, context)
    local scope_member_render = build_scope_member_tree_lines(scope_member_nodes, {
        panel_width = opts.panel_width,
        active_source_line = active_source_line,
        active_source_column = active_source_column,
    })

    local register_nodes = register_tree.build(context.registers or {}, context)
    local register_render = build_hud_tree_lines(register_nodes, {
        panel_width = opts.panel_width,
        active_source_line = active_source_line,
        active_source_column = active_source_column,
    })

    local event_nodes = event_tree.build(context.events or {}, context)
    local event_render = build_hud_tree_lines(event_nodes, {
        panel_width = opts.panel_width,
        active_source_line = active_source_line,
        active_source_column = active_source_column,
    })


    local stack_nodes = stack_tree.build(context.stack or {}, context)
    local stack_render = build_hud_tree_lines(stack_nodes, {
        panel_width = opts.panel_width,
        active_source_line = active_source_line,
        active_source_column = active_source_column,
    })

    local heap_root = heap_tree.build_tree(context.heap or {})
    local heap_render = build_hud_tree_lines(heap_root.children or {}, {
        panel_width = opts.panel_width,
        active_source_line = active_source_line,
        active_source_column = active_source_column,
    })

    local warning_nodes = build_warning_nodes_for_context(context)
    local warning_render = build_hud_tree_lines(warning_nodes, {
        panel_width = opts.panel_width,
        active_source_line = active_source_line,
        active_source_column = active_source_column,
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
            active = section_has_cursor_target(
                scope_member_nodes,
                active_source_line,
                active_source_column
            ),
            line_targets = scope_member_render.targets,
            empty_text = "<no scope members tracked yet>",
        },
        {
            id = "registers",
            title = "Registers",
            expanded = M.is_expanded("registers"),
            active = section_has_cursor_target(
                register_nodes,
                active_source_line,
                active_source_column
            ),
            lines = register_render.lines,
            line_targets = register_render.targets,
            empty_text = "<no registers tracked yet>",
        },
        {
            id = "events",
            title = "Events",
            expanded = M.is_expanded("events"),
            active = section_has_cursor_target(
                event_nodes,
                active_source_line,
                active_source_column
            ),
            lines = event_render.lines,
            line_targets = event_render.targets,
            empty_text = "<no events tracked yet>",
        },
        {
            id = "stack",
            title = "Stack",
            expanded = M.is_expanded("stack"),
            active = section_has_cursor_target(
                stack_nodes,
                active_source_line,
                active_source_column
            ),
            lines = stack_render.lines,
            line_targets = stack_render.targets,
            empty_text = "<no stack entries tracked yet>",
        },
        {
            id = "heap",
            title = "Heap",
            expanded = M.is_expanded("heap"),
            active = section_has_cursor_target(
                heap_root.children or {},
                active_source_line,
                active_source_column
            ),
            lines = heap_render.lines,
            line_targets = heap_render.targets,
            empty_text = "<no heap entries tracked yet>",
        },
        {
            id = "warnings",
            title = "Warnings",
            expanded = M.is_expanded("warnings"),
            active = section_has_cursor_target(
                warning_nodes,
                active_source_line,
                active_source_column
            ),
            lines = warning_render.lines,
            line_targets = warning_render.targets,
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

