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


local function line_is_comment(bufnr, line_number, comment_spec)
    if not bufnr
        or not line_number
        or not core.is_table(comment_spec)
        or not core.is_table(comment_spec.line)
    then
        return false
    end

    local lines = vim.api.nvim_buf_get_lines(
        bufnr,
        line_number - 1,
        line_number,
        false
    )

    local line = lines[1]

    if not core.is_non_empty_string(line) then
        return false
    end

    local trimmed = line:match("^%s*(.-)%s*$") or ""

    for _, line_comment in ipairs(comment_spec.line) do
        if core.is_table(line_comment)
            and core.is_non_empty_string(line_comment.prefix)
            and trimmed:sub(1, #line_comment.prefix) == line_comment.prefix
        then
            return true
        end
    end

    return false
end


local function warning_is_inside_comment(bufnr, range, opts)
    if not range then
        return false
    end

    return line_is_comment(
        bufnr,
        range.source_line,
        opts and opts.comments
    )
end


local function classify_warning_location(range, opts)
    opts = opts or {}

    if not range then
        return "unknown"
    end

    local cursor_line = opts.cursor_line
    local scope_start_line = opts.scope_start_line
    local scope_end_line = opts.scope_end_line

    local start_line = range.source_start_line or range.source_line
    local end_line = range.source_end_line or range.source_line

    if not start_line or not end_line then
        return "unknown"
    end

    if cursor_line and cursor_line >= start_line and cursor_line <= end_line then
        return "current"
    end

    if scope_start_line
        and scope_end_line
        and start_line >= scope_start_line
        and start_line <= scope_end_line
    then
        return "scope"
    end

    if cursor_line and start_line < cursor_line then
        return "earlier"
    end

    return "file"
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

    local location = classify_warning_location(range, opts)

    return {
        message = message,
        kind = "warning",
        severity = "syntax",
        category = "parser",
        source = "treesitter",

        source_line = range.source_line,
        source_column = range.source_column,

        source_start_line = range.source_start_line,
        source_start_column = range.source_start_column,
        source_end_line = range.source_end_line,
        source_end_column = range.source_end_column,

        metadata = {
            provider = "treesitter",
            node_type = node_type,
            missing = is_missing,
            filetype = opts.filetype,
            location = location,
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

        if not warning_is_inside_comment(opts.bufnr, range, opts)
            and (
                not opts.cursor_line
                or not range
                or range.source_line <= opts.cursor_line
            )
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
        bufnr = bufnr,
        cursor_line = opts.cursor_line,
        scope_start_line = opts.scope_start_line,
        scope_end_line = opts.scope_end_line,
        filetype = opts.filetype,
        comments = opts.comments,
    })

    return warnings
end


return M
