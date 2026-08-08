-- lua/tracker_hud/adapters/variant_utils.lua
--
-- Shared adapter variant directive helpers.
--
-- This module does not decide what a variant means.
-- Base adapters declare the directive name, comment syntax, aliases,
-- and default variant.

local core = require("tracker_hud.core")

local M = {}


local function trim(value)
    if not core.is_string(value) then
        return nil
    end

    value = value:gsub("^%s+", ""):gsub("%s+$", "")

    if value == "" then
        return nil
    end

    return value
end


local function escape_pattern(value)
    return tostring(value):gsub("([^%w])", "%%%1")
end


local function normalize_comment_prefixes(prefixes)
    if core.is_string(prefixes) then
        return { prefixes }
    end

    if core.is_table(prefixes) then
        return prefixes
    end

    return {}
end


function M.normalize_name(name, aliases)
    local normalized = trim(name)

    if not normalized then
        return nil
    end

    normalized = normalized:lower()

    if core.is_table(aliases) then
        return aliases[normalized] or normalized
    end

    return normalized
end


local function line_matches_directive(line, opts)
    if not core.is_string(line) then
        return nil
    end

    if not core.is_non_empty_string(opts.directive) then
        return nil
    end

    local directive = escape_pattern(opts.directive)
    local prefixes = normalize_comment_prefixes(opts.comment_prefixes)

    for _, prefix in ipairs(prefixes) do
        if core.is_string(prefix) and prefix ~= "" then
            local pattern = "^%s*"
                .. escape_pattern(prefix)
                .. "%s*"
                .. directive
                .. "%s*=%s*([^%s;*/]+)"

            local variant_name = line:match(pattern)

            if variant_name then
                return M.normalize_name(variant_name, opts.aliases)
            end
        end
    end

    return nil
end


local function read_buffer_line(bufnr, index)
    local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, index, index + 1, false)

    if not ok or not core.is_table(lines) then
        return nil
    end

    return lines[1]
end


function M.detect_from_buffer(bufnr, opts)
    opts = opts or {}

    if not bufnr then
        return nil
    end

    local max_scan_lines = opts.max_scan_lines or 20
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local scan_count = math.min(max_scan_lines, line_count)

    for index = 0, scan_count - 1 do
        local line = read_buffer_line(bufnr, index)
        local variant_name = line_matches_directive(line, opts)

        if variant_name then
            return variant_name
        end
    end

    return nil
end


return M
