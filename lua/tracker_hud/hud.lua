-- lua\tracker_hud\hud.lua
local M = {}

local panel_bufnr = nil
local panel_winid = nil

local function is_valid_window(winid)
    return winid and vim.api.nvim_win_is_valid(winid)
end

local function is_valid_buffer(bufnr)
    return bufnr and vim.api.nvim_buf_is_valid(bufnr)
end

local function clear_winbar()
    vim.wo.winbar = nil
end

local function render_winbar(context, config)
    if not context then
        clear_winbar()
        return
    end

    vim.wo.winbar = "%#Title# [+] HUD: %#Normal# " .. context.label
end

local function create_panel(config)
    if is_valid_window(panel_winid) and is_valid_buffer(panel_bufnr) then
        return
    end

    local current_win = vim.api.nvim_get_current_win()

    if config.panel_side == "left" then
        vim.cmd("topleft vertical " .. tostring(config.panel_width) .. "new")
    else
        vim.cmd("botright vertical " .. tostring(config.panel_width) .. "new")
    end

    panel_winid = vim.api.nvim_get_current_win()
    panel_bufnr = vim.api.nvim_get_current_buf()

    vim.bo[panel_bufnr].buftype = "nofile"
    vim.bo[panel_bufnr].bufhidden = "hide"
    vim.bo[panel_bufnr].swapfile = false
    vim.bo[panel_bufnr].filetype = "tracker_hud"

    vim.wo[panel_winid].number = false
    vim.wo[panel_winid].relativenumber = false
    vim.wo[panel_winid].signcolumn = "no"
    vim.wo[panel_winid].winfixwidth = true

    vim.api.nvim_buf_set_name(panel_bufnr, "Tracker HUD")

    vim.api.nvim_set_current_win(current_win)
end

local function format_panel_lines(context)
    if not context then
        return {
            "Tracker HUD",
            "",
            "No Tree-sitter context available.",
        }
    end

    local lines = {
        "Tracker HUD",
        "",
        "Scope:",
    }

    if context.path and #context.path > 0 then
        for index, item in ipairs(context.path) do
            local prefix = "  "

            if index > 1 then
                prefix = "  -> "
            end

            table.insert(lines, prefix .. item)
        end
    else
        table.insert(lines, "  " .. context.label)
    end

    table.insert(lines, "")
    table.insert(lines, "Depth: " .. tostring(context.depth or 0))

    if context.start_line and context.end_line then
        table.insert(lines, "Current scope lines: " .. context.start_line .. " - " .. context.end_line)
    end

    return lines
end

local function render_panel(context, config)
    create_panel(config)

    if not is_valid_buffer(panel_bufnr) then
        return
    end

    local lines = format_panel_lines(context)

    vim.bo[panel_bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(panel_bufnr, 0, -1, false, lines)
    vim.bo[panel_bufnr].modifiable = false
end

function M.clear(config)
    config = config or {}

    if config.display == "panel" then
        if is_valid_buffer(panel_bufnr) then
            vim.bo[panel_bufnr].modifiable = true
            vim.api.nvim_buf_set_lines(panel_bufnr, 0, -1, false, {
                "Tracker HUD",
                "",
                "No active context.",
            })
            vim.bo[panel_bufnr].modifiable = false
        end
    else
        clear_winbar()
    end
end

function M.render(context, config)
    config = config or {}

    if config.display == "panel" then
        render_panel(context, config)
    else
        render_winbar(context, config)
    end
end

function M.is_panel_buffer(bufnr)
    return is_valid_buffer(bufnr)
        and bufnr == panel_bufnr
end

return M
