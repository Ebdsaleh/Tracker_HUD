-- lua\tracker_hud\init.lua
local M = {}

local context = require("tracker_hud.context")
local hud = require("tracker_hud.hud")

local hud_group = vim.api.nvim_create_augroup("CodeBlockHUD", { clear = true })

local defaults = {
    display = "winbar", -- "winbar" or "panel"

    show_line_numbers = true,
    show_branch_context = true,
    separator = " -> ",

    panel_side = "right", -- "left" or "right"
    panel_width = 42,
}

local config = vim.deepcopy(defaults)

local state = {
    source_bufnr = nil,
    source_winid = nil,
    source_cursor = nil,
    source_context = nil,
}

local function is_trackable_buffer(bufnr)
    if hud.is_panel_buffer(bufnr) then
        return false
    end

    if vim.bo[bufnr].filetype == "tracker_hud" then
        return false
    end

    if vim.bo[bufnr].buftype ~= "" then
        return false
    end

    return true
end

local function update_hud()
    local ok, err = pcall(function()
        local bufnr = vim.api.nvim_get_current_buf()

        -- Do not let the HUD panel become the analyzed source buffer.
        if not is_trackable_buffer(bufnr) then
            return
        end

        local winid = vim.api.nvim_get_current_win()
        local cursor = vim.api.nvim_win_get_cursor(winid)
        local current_context = context.get_cursor_context(bufnr, config)

        state.source_bufnr = bufnr
        state.source_winid = winid
        state.source_cursor = cursor
        state.source_context = current_context

        hud.render(current_context, config)
    end)

    if not ok then
        hud.clear(config)
        vim.notify("tracker_hud error: " .. tostring(err), vim.log.levels.WARN)
    end
end

function M.setup(opts)
    config = vim.tbl_deep_extend("force", defaults, opts or {})

    vim.api.nvim_clear_autocmds({
        group = hud_group,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufWinEnter" }, {
        group = hud_group,
        callback = update_hud,
    })
end

return M
