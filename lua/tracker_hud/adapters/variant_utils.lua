-- lua/tracker_hud/adapters/variant_utils.lua
--
-- Shared adapter variant directive helpers.
--
-- This module does not decide what a variant means.
-- Base adapters declare directive names, comment syntax, aliases,
-- and default variants.

local core = require("tracker_hud.core")
local directive_utils = require("tracker_hud.directive_utils")

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


function M.scan_directives_from_buffer(bufnr, opts)
    opts = opts or {}

    return directive_utils.scan_buffer(bufnr, {
        directives = opts.directives or opts.directive_names,
        comment_prefixes = normalize_comment_prefixes(opts.comment_prefixes),
        assignment_symbol = opts.assignment_symbol or "=",
        terminator_symbol = opts.terminator_symbol or ";",
        max_scan_lines = opts.max_scan_lines or 20,
    })
end


function M.detect_from_buffer(bufnr, opts)
    opts = opts or {}

    if not bufnr then
        return nil
    end

    if not core.is_non_empty_string(opts.directive) then
        return nil
    end

    local scan = M.scan_directives_from_buffer(bufnr, {
        directives = {
            opts.directive,
        },
        comment_prefixes = opts.comment_prefixes,
        assignment_symbol = opts.assignment_symbol,
        terminator_symbol = opts.terminator_symbol,
        max_scan_lines = opts.max_scan_lines,
    })

    for _, directive in ipairs(scan.directives or {}) do
        if directive.directive == opts.directive then
            return M.normalize_name(directive.value, opts.aliases)
        end
    end

    return nil
end


return M

