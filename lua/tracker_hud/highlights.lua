-- lua/tracker_hud/highlights.lua
--
-- Semantic HUD highlight groups.
--
-- Internal code refers to stable semantic style keys such as "destination"
-- and "warning". Public Neovim highlight group names are resolved through
-- tracker_hud.namespace so they remain independent from the final plugin name.

local namespace = require("tracker_hud.namespace")

local M = {}

local STYLE_SUFFIXES = {
    title = "Title",
    tip = "Tip",
    section = "Section",
    control = "Control",
    active = "Active",
    destination = "Destination",
    source = "Source",
    implicit = "Implicit",
    value = "Value",
    metadata = "Metadata",
    warning = "Warning",
    muted = "Muted",
}

local DEFAULT_LINKS = {
    title = "Title",
    tip = "Comment",
    section = "Function",
    control = "Special",
    active = "IncSearch",
    destination = "DiagnosticOk",
    source = "DiagnosticInfo",
    implicit = "DiagnosticHint",
    value = "Constant",
    metadata = "Comment",
    warning = "DiagnosticWarn",
    muted = "Comment",
}

local render_namespace = vim.api.nvim_create_namespace("tracker_hud_render_highlights")


local function highlights_enabled(config)
    return not (
        type(config) == "table"
        and type(config.highlights) == "table"
        and config.highlights.enabled == false
    )
end


function M.group_name(config, style)
    local suffix = STYLE_SUFFIXES[style]

    if not suffix then
        return nil
    end

    return namespace.name(config, suffix)
end


function M.setup(config)
    if not highlights_enabled(config) then
        return false
    end

    for style, link in pairs(DEFAULT_LINKS) do
        local group = M.group_name(config, style)

        if group then
            vim.api.nvim_set_hl(0, group, {
                link = link,
                default = true,
            })
        end
    end

    return true
end


function M.clear_buffer(bufnr)
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return false
    end

    vim.api.nvim_buf_clear_namespace(
        bufnr,
        render_namespace,
        0,
        -1
    )

    return true
end


function M.apply_line_styles(bufnr, config, line_styles)
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return false
    end

    M.clear_buffer(bufnr)

    if not highlights_enabled(config) then
        return true
    end

    for line_number, style in pairs(line_styles or {}) do
        local group = M.group_name(config, style)

        if group and tonumber(line_number) then
            pcall(
                vim.api.nvim_buf_add_highlight,
                bufnr,
                render_namespace,
                group,
                tonumber(line_number) - 1,
                0,
                -1
            )
        end
    end

    return true
end


function M.styles()
    local result = {}

    for style, _suffix in pairs(STYLE_SUFFIXES) do
        table.insert(result, style)
    end

    table.sort(result)
    return result
end


return M

