-- lua/tracker_hud/directive_utils.lua
--
-- Strict source directive parsing utilities.
--
-- Core owns directive shape.
-- Adapters own comment prefixes, directive names, and directive meanings.

local core = require("tracker_hud.core")

local M = {}

local function escape_pattern(value)
    return tostring(value):gsub("([^%w])", "%%%1")
end

local function normalize_string_list(values)
    if core.is_string(values) and values ~= "" then
        return { values }
    end

    if not core.is_table(values) then
        return {}
    end

    local result = {}

    for _, value in ipairs(values) do
        if core.is_string(value) and value ~= "" then
            table.insert(result, value)
        end
    end

    return result
end

local function list_contains(values, expected)
    for _, value in ipairs(values or {}) do
        if value == expected then
            return true
        end
    end

    return false
end

local function strip_double_quoted_segments(line)
    if not core.is_string(line) then
        return ""
    end

    local result = {}
    local index = 1
    local in_quote = false

    while index <= #line do
        local char = line:sub(index, index)
        local previous = line:sub(index - 1, index - 1)

        if char == '"' and previous ~= "\\" then
            in_quote = not in_quote
            table.insert(result, " ")
        elseif in_quote then
            table.insert(result, " ")
        else
            table.insert(result, char)
        end

        index = index + 1
    end

    return table.concat(result)
end

local function make_expected(prefix, name, value, opts)
    local assignment = opts.assignment_symbol or "="
    local terminator = opts.terminator_symbol or ";"

    return prefix .. " " .. name .. assignment .. value .. terminator
end

local function make_diagnostic(name, value, prefix, line_number, column, end_column, reason, message, opts)
    return {
        key = name,
        value = value,
        directive = name,
        comment_prefix = prefix,
        line = line_number,
        column = column or 0,
        end_column = end_column,
        reason = reason,
        message = message,
        expected = make_expected(prefix, name, value, opts),
    }
end

local function build_message(reason, expected, prefix, assignment, terminator)
    if reason == "too_many_spaces_after_comment" then
        return "Target warning: malformed directive. Only one space permitted between comment and directive. Expected '" .. expected .. "'"
    end

    if reason == "missing_space_after_comment" then
        return "Target warning: malformed directive. Exactly one space required between comment and directive. Expected '" .. expected .. "'"
    end

    if reason == "indented_directive" then
        return "Target warning: malformed directive. Directive must start at column 0. Expected '" .. expected .. "'"
    end

    if reason == "spaces_around_assignment" then
        return "Target warning: malformed directive. No spaces permitted around assignment symbol '" .. assignment .. "'. Expected '" .. expected .. "'"
    end

    if reason == "missing_terminator" then
        return "Target warning: malformed directive. Missing directive terminator '" .. terminator .. "'. Expected '" .. expected .. "'"
    end

    if reason == "embedded_directive" then
        return "Target warning: malformed directive. Directive declarations must start at column 0. Expected '" .. expected .. "'"
    end

    return "Target warning: malformed directive. Expected '" .. expected .. "'"
end

local function match_strict_directive(line, line_number, prefix, name, opts)
    local assignment = opts.assignment_symbol or "="
    local terminator = opts.terminator_symbol or ";"
    local value_pattern = opts.value_pattern or "([^%s" .. escape_pattern(terminator) .. "]+)"

    local pattern = "^"
        .. escape_pattern(prefix)
        .. " "
        .. escape_pattern(name)
        .. escape_pattern(assignment)
        .. value_pattern
        .. escape_pattern(terminator)
        .. "%s*$"

    local value = line:match(pattern)

    if not value or value == "" then
        return nil
    end

    return {
        key = name,
        value = value,
        directive = name,
        comment_prefix = prefix,
        line = line_number,
        column = 0,
        end_column = #line,
        valid = true,
    }
end

local function find_suspicious_candidate(line, prefix, name, opts)
    local assignment = opts.assignment_symbol or "="
    local terminator = opts.terminator_symbol or ";"
    local search_line = strip_double_quoted_segments(line)

    local pattern = escape_pattern(prefix)
        .. "%s*"
        .. escape_pattern(name)
        .. "%s*"
        .. escape_pattern(assignment)
        .. "%s*"
        .. "([^%s" .. escape_pattern(terminator) .. "]+)"
        .. escape_pattern(terminator) .. "?"

    local start_column, end_column, value = search_line:find(pattern)

    if not start_column or not value or value == "" then
        return nil
    end

    return {
        key = name,
        value = value,
        directive = name,
        comment_prefix = prefix,
        start_column = start_column - 1,
        end_column = end_column,
    }
end

local function diagnose_candidate(line, candidate, opts)
    local prefix = candidate.comment_prefix
    local name = candidate.directive
    local value = candidate.value
    local assignment = opts.assignment_symbol or "="
    local terminator = opts.terminator_symbol or ";"
    local expected = make_expected(prefix, name, value, opts)

    if candidate.start_column > 0 then
        local before = line:sub(1, candidate.start_column)

        if before:match("^%s+$") then
            return "indented_directive", build_message("indented_directive", expected, prefix, assignment, terminator)
        end

        return "embedded_directive", build_message("embedded_directive", expected, prefix, assignment, terminator)
    end

    local after_prefix = line:sub(#prefix + 1)

    if after_prefix:sub(1, 1) ~= " " then
        return "missing_space_after_comment", build_message("missing_space_after_comment", expected, prefix, assignment, terminator)
    end

    if after_prefix:sub(2, 2) == " " or after_prefix:sub(2, 2) == "\t" then
        return "too_many_spaces_after_comment", build_message("too_many_spaces_after_comment", expected, prefix, assignment, terminator)
    end

    local assignment_start = line:find(escape_pattern(assignment), 1, false)

    if assignment_start then
        local before_assignment = line:sub(assignment_start - 1, assignment_start - 1)
        local after_assignment = line:sub(assignment_start + #assignment, assignment_start + #assignment)

        if before_assignment:match("%s") or after_assignment:match("%s") then
            return "spaces_around_assignment", build_message("spaces_around_assignment", expected, prefix, assignment, terminator)
        end
    end

    if not line:match(escape_pattern(terminator) .. "%s*$") then
        return "missing_terminator", build_message("missing_terminator", expected, prefix, assignment, terminator)
    end

    return "malformed_directive", build_message("malformed_directive", expected, prefix, assignment, terminator)
end

local function scan_line(line, line_number, prefixes, directive_names, valid_seen, opts)
    local directives = {}
    local diagnostics = {}

    if not core.is_string(line) then
        return directives, diagnostics
    end

    for _, prefix in ipairs(prefixes) do
        for _, name in ipairs(directive_names) do
            local directive = match_strict_directive(line, line_number, prefix, name, opts)

            if directive then
                table.insert(directives, directive)
                valid_seen[name] = directive
                return directives, diagnostics
            end
        end
    end

    for _, prefix in ipairs(prefixes) do
        for _, name in ipairs(directive_names) do
            local candidate = find_suspicious_candidate(line, prefix, name, opts)

            if candidate and not valid_seen[name] then
                local reason, message = diagnose_candidate(line, candidate, opts)

                table.insert(
                    diagnostics,
                    make_diagnostic(
                        name,
                        candidate.value,
                        prefix,
                        line_number,
                        candidate.start_column,
                        candidate.end_column,
                        reason,
                        message,
                        opts
                    )
                )

                return directives, diagnostics
            end
        end
    end

    return directives, diagnostics
end

local function read_buffer_lines(bufnr, max_scan_lines)
    if not bufnr then
        return {}
    end

    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local scan_count = math.min(line_count, max_scan_lines)

    return vim.api.nvim_buf_get_lines(bufnr, 0, scan_count, false)
end

function M.scan_lines(lines, opts)
    opts = opts or {}

    local prefixes = normalize_string_list(opts.comment_prefixes)
    local directive_names = normalize_string_list(opts.directives or opts.directive_names)
    local valid_seen = {}
    local directives = {}
    local diagnostics = {}

    for index, line in ipairs(lines or {}) do
        local line_directives, line_diagnostics = scan_line(
            line,
            index,
            prefixes,
            directive_names,
            valid_seen,
            opts
        )

        for _, directive in ipairs(line_directives) do
            table.insert(directives, directive)
        end

        for _, diagnostic in ipairs(line_diagnostics) do
            table.insert(diagnostics, diagnostic)
        end
    end

    return {
        directives = directives,
        diagnostics = diagnostics,
    }
end

function M.scan_buffer(bufnr, opts)
    opts = opts or {}

    local max_scan_lines = opts.max_scan_lines or 20
    local lines = read_buffer_lines(bufnr, max_scan_lines)

    return M.scan_lines(lines, opts)
end

function M.comment_prefix_is_allowed(prefix, allowed_prefixes)
    return list_contains(normalize_string_list(allowed_prefixes), prefix)
end

function M.format_expected_forms(name, value, prefixes, opts)
    opts = opts or {}

    local forms = {}

    for _, prefix in ipairs(normalize_string_list(prefixes)) do
        table.insert(forms, "'" .. make_expected(prefix, name, value, opts) .. "'")
    end

    return table.concat(forms, " or ")
end

return M

