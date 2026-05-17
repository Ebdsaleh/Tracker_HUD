-- C:\Users\Developer\AppData\Local\nvim\lua\tracker_hud\init.lua
local M = {}

local context = require("tracker_hud.context")
local hud = require("tracker_hud.hud")

local hud_group = vim.api.nvim_create_augroup("CodeBlockHUD", { clear = true })

local function update_hud()
    local ok, err = pcall(function()
        local bufnr = vim.api.nvim_get_current_buf()
        local current_context = context.get_cursor_context(bufnr)

        hud.render(current_context)
    end)

    if not ok then
        hud.clear()
        vim.notify("tracker_hud error: " .. tostring(err), vim.log.levels.WARN)
    end
end

function M.setup()
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufWinEnter" }, {
    group = hud_group,
    callback = update_hud,
  })
end

return M
