-- lua/tracker_hud/target_diagnostics.lua
--
-- Editor diagnostics for adapter target metadata.
--
-- This module displays adapter-reported target diagnostics inline in the
-- source buffer. It does not resolve targets itself.


local M = {}

local namespace = vim.api.nvim_create_namespace("tracker_hud_diagnostics")

local function is_valid_buffer(bufnr)
    return bufnr and vim.api.nvim_buf_is_valid(bufnr)
end

local function normalize_line_number(line)
    local numeric_line = tonumber(line)

    if not numeric_line or numeric_line < 1 then
        return nil
    end

    return numeric_line
end


local function diagnostic_column(diagnostic)
    local column = tonumber(diagnostic.column)

    if column and column >= 0 then
        return column
    end

    return 0
end


local function diagnostic_end_column(diagnostic, line_text)
    local end_column = tonumber(diagnostic.end_column)

    if end_column and end_column >= 0 then
        return end_column
    end

    return #line_text
end


local function build_diagnostic(bufnr, target_diagnostic)
    if type(target_diagnostic) ~= "table" then
        return nil
    end

    local line = normalize_line_number(target_diagnostic.line)

    if not line then
        return nil
    end

    local line_text = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1] or ""

    return {
        lnum = line - 1,
        col = diagnostic_column(target_diagnostic),
        end_lnum = line - 1,
        end_col = diagnostic_end_column(target_diagnostic, line_text),
        severity = vim.diagnostic.severity.WARN,
        source = "tracker HUD",
        message = target_diagnostic.message or "target metadata warning",

    }

end

function M.clear(bufnr)
    if not is_valid_buffer(bufnr) then
        return
    end

    vim.diagnostic.reset(namespace, bufnr)
end


function M.show(bufnr, targets)
    if not is_valid_buffer(bufnr) then
        return
    end

    if type(targets) ~= "table" or type(targets.diagnostics) ~= "table" then
        M.clear(bufnr)
        return 
    end

    local diagnostics = {}

    for _, target_diagnostic in ipairs(targets.diagnostics) do
        local diagnostic = build_diagnostic(bufnr, target_diagnostic)
        if diagnostic then
            table.insert(diagnostics, diagnostic)
        end
    end

    vim.diagnostic.set(namespace, bufnr, diagnostics, {})

end


return M
