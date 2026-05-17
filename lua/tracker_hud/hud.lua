--C:\Users\Developer\AppData\Local\nvim\lua\tracker_hud\hud.lua
local M = {}

function M.clear()
    vim.wo.winbar = nil
end


function M.render(context)
    if not context then
        M.clear()
        return
    end

    vim.wo.winbar = "%#Title# [+] HUD: %#Normal# " .. context.label
end

return M

