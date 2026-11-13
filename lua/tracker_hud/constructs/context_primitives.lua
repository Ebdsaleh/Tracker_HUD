-- lua/tracker_hud/constructs/context_primitives.lua
--
-- Shared construct/context primitives.
--
-- This module owns only cursor, node-range and scope-context mechanics used by
-- context_engine. It does not parse constructs or apply language semantics.

local core = require("tracker_hud.core")

local M = {}


function M.get_cursor_position()
    local cursor =
        vim.api.nvim_win_get_cursor(0)

    return {
        row = cursor[1] - 1,
        col = cursor[2],
    }
end


function M.get_cursor_location()
    local cursor =
        vim.api.nvim_win_get_cursor(0)

    return {
        line = cursor[1],
        column = cursor[2] + 1,
    }
end


function M.make_global_context()
    return {
        label = "Global Scope",
        node_type = nil,
        start_line = nil,
        end_line = nil,
        depth = 0,
        path = {},
        scopes = {},
        scope_members = {},
        targets = {},
        cursor = M.get_cursor_location(),
    }
end


function M.make_unavailable_context(
    message,
    filetype
)
    return {
        label = message,
        node_type = nil,
        start_line = nil,
        end_line = nil,
        depth = 0,
        path = {},
        scopes = {},
        scope_members = {},
        cursor = M.get_cursor_location(),
        unavailable = true,
        filetype = filetype,
    }
end


function M.position_in_node(
    row,
    col,
    node
)
    if not node then
        return false
    end

    local start_row,
        start_col,
        end_row,
        end_col =
        node:range()

    if not core.is_number(start_row)
        or not core.is_number(end_row)
    then
        return false
    end

    if row < start_row
        or row > end_row
    then
        return false
    end

    if row == start_row
        and core.is_number(start_col)
        and col < start_col
    then
        return false
    end

    if row == end_row
        and core.is_number(end_col)
        and col > end_col
    then
        return false
    end

    return true
end


function M.get_node_type(node)
    if not node then
        return nil
    end

    return node:type()
end


function M.get_first_node_line(node)
    if not node then
        return nil
    end

    local start_row =
        node:range()

    if not core.is_number(start_row) then
        return nil
    end

    return start_row + 1
end


function M.get_node_range(node)
    if not node then
        return nil
    end

    local start_row,
        _,
        end_row,
        _ =
        node:range()

    if not core.is_number(start_row)
        or not core.is_number(end_row)
    then
        return nil
    end

    return {
        start_line = start_row + 1,
        end_line = end_row + 1,
    }
end


function M.build_scope_entry_from_construct(
    construct
)
    if not core.is_table(construct)
        or not core.is_table(
            construct.range
        )
    then
        return nil
    end

    local construct_spec =
        construct.construct or {}

    local line_number =
        construct.range.start_line

    local label =
        construct.signature
        or construct_spec.label

    local display_label = nil

    if construct.metadata then
        display_label =
            construct.metadata.display_label
    end

    display_label =
        display_label
        or "["
            .. line_number
            .. "] "
            .. tostring(
                label or "<unknown>"
            )

    return {
        label = display_label,
        raw_label = label,
        node_type = construct.node_type,
        kind = construct_spec.kind,
        scope = construct.scope,
        value = construct.value,
        start_line =
            construct.range.start_line,
        end_line =
            construct.range.end_line,
        construct = construct,
    }
end


function M.build_context_from_scopes(
    scopes,
    config
)
    local context =
        M.make_global_context()

    if not core.is_table(scopes)
        or #scopes == 0
    then
        return context
    end

    local path = {}

    -- Scopes are collected innermost -> outermost.
    -- Reverse them so HUD reads outermost -> innermost.
    for i = #scopes, 1, -1 do
        table.insert(
            path,
            scopes[i].label
        )
    end

    local innermost =
        scopes[1]

    local separator =
        (config and config.separator)
        or " -> "

    context.label =
        "Scope: "
        .. table.concat(
            path,
            separator
        )

    context.node_type =
        innermost.node_type

    context.start_line =
        innermost.start_line

    context.end_line =
        innermost.end_line

    context.depth =
        #scopes

    context.path =
        path

    context.scopes =
        scopes

    context.scope_members =
        {}

    return context
end


return M
