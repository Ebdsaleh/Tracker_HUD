-- lua/tracker_hud/config.lua

local M = {}

M.defaults = {
    display = "winbar", -- "winbar" or "panel"
    
    show_line_numbers = true,
    show_branch_context = true,
    separator = " -> ",

    -- "left", "right", "top", or "bottom"
    panel_position = "right",

    -- Number = fixed size
    -- "auto" = calculate once when panel opens.
    panel_size = "auto",

    -- Auto-size padding.
    -- Left/right uses width padding.
    -- Top/bottom uses height padding.
    panel_auto_width_padding = 2,
    panel_auto_height_padding = 2,

    -- Fallbacks if auto-size cannot calculate.
    panel_default_width = 52,
    panel_default_height = 9,

    keymaps = {
        enabled = true,
        increase_size = "<leader>+",
        decrease_size = "<leader>-",
        auto_size = "<leader><CR>",
        step= 2,
    },
}


function M.resolve(opts)
    return vim.tbl_deep_extend("force", M.defaults, opts or {})
end


return M
