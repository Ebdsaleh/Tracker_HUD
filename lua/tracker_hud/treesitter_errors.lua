-- lua/tracker_hud/treesitter_errors.lua
--
-- Generic Tree-sitter syntax warning provider.

local core = require("tracker_hud.core")

local M = {}


local function node_is_missing(node)
    if not node then
        return false
    end

    local ok, missing = pcall(function()
        return node:missing()
    end)

    return ok and missing == true
end


local function node_range(node)
    if not node then
        return nil
    end

    local start_row, start_column, end_row, end_column = node:range()

    if not core.is_number(start_row) or not core.is_number(end_row) then
        return nil
    end

    return {
        source_line = start_row + 1,
        source_column = start_column or 0,

        source_start_line = start_row + 1,
        source_start_column = start_column or 0,
        source_end_line = end_row + 1,
        source_end_column = end_column or 0,
    }
end


local function make_syntax_warning(node, opts)
    opts = opts or {}

    local node_type = node and node:type() or "<unknown>"
    local range = node_range(node) or {}

    local is_missing = node_is_missing(node)
    local message = "Tree-sitter parse error"

    if is_missing then
        message = "Tree-sitter missing node: " .. tostring(node_type)
    end

    return {
        message = message,
        kind = "warning",
        severity = "syntax",
        category = "parser",
        source = "treesitter",

        source_line = range.source_line,
        source_column= range.source_column,

        source_start_line = range.source_start_line,
        source_start_column = range.source_start_column,
        source_end_line = range.source_end_line,
        source_end_column = range.source_end_column,

        metadata = {
            provider = "treesitter",
            node_type = node_type,
            missing = is_missing,
            filetype = opts.filetype,
        },
    }
end


local function collect_from_node(node, warnings, opts)
    if not node then
        return
    end

    opts = opts or {}

    local node_type = node:type()
    local is_error = node_type == "ERROR"
    local is_missing = node_is_missing(node)

    if is_error or is_missing then
        local range = node_range(node)

        if not opts.cursor_line
            or not range
            or range.source_line <= opts.cursor_line
        then
            table.insert(warnings, make_syntax_warning(node, opts))
        end
    end

    for child in node:iter_children() do
        collect_from_node(child, warnings, opts)
    end
end


function M.collect(bufnr, root_node, opts)
    opts = opts or {}

    local warnings = {}

    if not bufnr or not root_node then
        return warnings
    end

    collect_from_node(root_node, warnings, {
        cursor_line = opts.cursor_line,
        filetype = opts.filetype,
    })

    return warnings
end


return M
