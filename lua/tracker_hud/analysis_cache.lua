-- lua/tracker_hud/analysis_cache.lua
--
-- Shared analysis/cache line-limit policy.
--
-- This module intentionally separates two concepts:
--
--   cache window   = how much source an adapter may pre-read/analyze early
--   HUD visibility = what facts are allowed to be shown at the cursor
--
-- A bounded cache must never make future source facts visible before the
-- cursor reaches them.

local M = {}

M.DEFAULT_LINE_LIMIT = 200


local function ensure_analysis_table(config)
    if type(config) ~= "table" then
        return nil
    end

    if type(config.analysis) ~= "table" then
        config.analysis = {}
    end

    return config.analysis
end


local function normalize_positive_integer(value)
    local numeric = tonumber(value)

    if not numeric then
        return nil
    end

    numeric = math.floor(numeric)

    if numeric < 1 then
        return nil
    end

    return numeric
end


function M.get_limit(config)
    local analysis = type(config) == "table" and config.analysis or nil

    if type(analysis) ~= "table" then
        return M.DEFAULT_LINE_LIMIT
    end

    local value = analysis.cache_line_limit

    if value == false
        or value == "off"
        or value == 0
    then
        return nil
    end

    local numeric = normalize_positive_integer(value)

    if numeric then
        return numeric
    end

    return M.DEFAULT_LINE_LIMIT
end


function M.describe(config)
    local limit = M.get_limit(config)

    if not limit then
        return "off (unlimited)"
    end

    return tostring(limit) .. " line(s)"
end


function M.set_limit(config, raw_value)
    local analysis = ensure_analysis_table(config)

    if not analysis then
        return nil, "missing config table"
    end

    local value = tostring(raw_value or "")
    value = value:gsub("^%s+", ""):gsub("%s+$", "")

    if value == "" then
        return M.get_limit(config), nil
    end

    local lowered = value:lower()

    if lowered == "on" then
        analysis.cache_line_limit = M.DEFAULT_LINE_LIMIT
        return M.DEFAULT_LINE_LIMIT, nil
    end

    if lowered == "off" then
        analysis.cache_line_limit = false
        return nil, nil
    end

    local numeric = normalize_positive_integer(value)

    if numeric then
        analysis.cache_line_limit = numeric
        return numeric, nil
    end

    return nil, "expected on, off, or a positive line count"
end


function M.usage(command_name)
    return "Usage: :" .. tostring(command_name) .. " [on|off|<line-count>]"
end


function M.cursor_line(context, fallback)
    local line = type(context) == "table"
        and type(context.cursor) == "table"
        and tonumber(context.cursor.line)
        or nil

    if line and line > 0 then
        return math.floor(line)
    end

    return fallback
end


function M.visible_line_limit(context, total_lines)
    local total = normalize_positive_integer(total_lines) or total_lines or 0
    local cursor_line = M.cursor_line(context, total)

    if not cursor_line then
        return total
    end

    if total and total > 0 then
        return math.min(cursor_line, total)
    end

    return cursor_line
end


function M.initial_cache_limit(config, total_lines)
    local limit = M.get_limit(config)
    local total = normalize_positive_integer(total_lines) or total_lines or nil

    if not limit then
        return total
    end

    if total then
        return math.min(limit, total)
    end

    return limit
end


function M.get_visible_lines(bufnr, context)
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return {}, 0
    end

    local total = vim.api.nvim_buf_line_count(bufnr)
    local end_line = M.visible_line_limit(context, total)

    if not end_line or end_line < 1 then
        return {}, 0
    end

    return vim.api.nvim_buf_get_lines(
        bufnr,
        0,
        end_line,
        false
    ), end_line
end


function M.make_visible_prefix_get_lines(context, original_get_lines, target_bufnr)
    if type(original_get_lines) ~= "function" then
        return nil
    end

    local cursor_line = M.cursor_line(context, nil)

    if not cursor_line then
        return nil
    end

    local current_buf = target_bufnr

    if not current_buf then
        local ok_current, bufnr = pcall(vim.api.nvim_get_current_buf)

        if ok_current and bufnr then
            current_buf = bufnr
        end
    end

    if not current_buf then
        return nil
    end

    return function(bufnr, start_index, end_index, strict_indexing)
        if bufnr == current_buf
            and start_index == 0
            and end_index == -1
        then
            local ok_count, total = pcall(vim.api.nvim_buf_line_count, bufnr)

            if ok_count and total and total > 0 then
                return original_get_lines(
                    bufnr,
                    0,
                    math.min(cursor_line, total),
                    false
                )
            end
        end

        return original_get_lines(bufnr, start_index, end_index, strict_indexing)
    end
end


function M.with_visible_prefix_get_lines(context, callback, target_bufnr)
    if type(callback) ~= "function" then
        return false, nil
    end

    local original_get_lines = vim.api.nvim_buf_get_lines
    local prefix_get_lines = M.make_visible_prefix_get_lines(
        context,
        original_get_lines,
        target_bufnr
    )

    if not prefix_get_lines then
        return pcall(callback)
    end

    vim.api.nvim_buf_get_lines = prefix_get_lines

    local ok, result = pcall(callback)

    vim.api.nvim_buf_get_lines = original_get_lines

    return ok, result
end


return M
