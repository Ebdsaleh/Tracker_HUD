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


local function update_hud()
    local ok, err = pcall(function()
        local bufnr = vim.api.nvim_get_current_buf()
        local current_context = context.get_cursor_context(bufnr, config)

        hud.render(current_context, config)
    end)

    if not ok then
        hud.clear(config)
        vim.notify("tracker_hud error: " .. tostring(err), vim.log.levels.WARN)
    end
end

function M.setup(opts)
    config = vim.tbl_deep_extend("force", defaults, opts or {})

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufWinEnter" }, {
    group = hud_group,
    callback = update_hud,
  })
end

return M
