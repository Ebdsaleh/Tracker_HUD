-- lua/tracker_hud/init.lua

local M = {}

local context = require("tracker_hud.context")
local hud = require("tracker_hud.hud")

local hud_group = vim.api.nvim_create_augroup("CodeBlockHUD", { clear = true })


local defaults = {
    display = "winbar", -- "winbar" or "panel"

    show_line_numbers = true,
    show_branch_context = true,
    separator = " -> ",

    -- "left", "right", "top", or "bottom"
    panel_position = "right",

    -- Number = fixed size.
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
        step = 2,
    },

    -- Legacy aliases
    panel_side = nil,
    panel_width = nil,
}

local config = vim.deepcopy(defaults)

local state = {
    source_bufnr = nil,
    source_winid = nil,
    source_cursor = nil,
    source_context = nil,
}

local function is_valid_window(winid)
    return winid and vim.api.nvim_win_is_valid(winid)
end

local function is_trackable_buffer(bufnr)
    if hud.is_panel_buffer(bufnr) then
        return false
    end

    if vim.b[bufnr].tracker_hud_panel then
        return false
    end

    if vim.bo[bufnr].buftype ~= "" then
        return false
    end

    return true
end

local function restore_source_focus()
    if config.display ~= "panel" then
        return
    end

    if is_valid_window(state.source_winid) then
        pcall(vim.api.nvim_set_current_win, state.source_winid)
    end
end

local function close_panel_before_source_quit()
    if config.display ~= "panel" then
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()

    -- If the user is quitting the HUD panel itself, let normal :q happen.
    if hud.is_panel_buffer(bufnr) or vim.b[bufnr].tracker_hud_panel then
        return
    end

    -- Only react for normal tracked source buffers.
    if not is_trackable_buffer(bufnr) then
        return
    end

    hud.close_panel()
end

local function close_panel_if_source_window_closed(closed_winid)
    if not state.source_winid then
        return
    end

    if tostring(state.source_winid) ~= tostring(closed_winid) then
        return
    end

    vim.schedule(function()
        hud.close_panel()

        state.source_bufnr = nil
        state.source_winid = nil
        state.source_cursor = nil
        state.source_context = nil
    end)
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

        hud.render(current_context, config, state.source_winid)

        -- During plugin-created panel updates, source focus wins.
        restore_source_focus()
    end)

    if not ok then
        hud.clear(config)
        vim.notify("tracker_hud error: " .. tostring(err), vim.log.levels.WARN)
    end
end


local function resize_panel_command(command_opts)
    local requested_size = command_opts.args

    if requested_size == nil or requested_size == "" then
        vim.notify(
            "Usage: :TrackerHudSize <number|auto>",
            vim.log.levels.INFO
        )
        return
    end

    hud.resize_panel(requested_size, config, state.source_context)
end


local function resize_panel_by(delta)
    local current_size = hud.get_panel_size()

    if not current_size then
        vim.notify("tracker_hud: panel is not open", vim.log.levels.WARN)
        return
    end

    local next_size = current_size + delta

    if next_size < 1 then
        next_size = 1
    end

    hud.resize_panel(next_size, config, state.source_context)    
end



local function auto_resize_panel()
    hud.resize_panel("auto", config, state.source_context)    
end



local function setup_keymaps()
    local keymaps = config.keymaps or {}

    if keymaps.enabled == false then
        return
    end

    local step = tonumber(keymaps.step) or 2

    if keymaps.increase_size then
        vim.keymap.set("n", keymaps.increase_size, function()
            resize_panel_by(step)
        end, {
            desc = "increase Tracker HUD panel size",
            silent = true,
            noremap = true,
        })
    end

    if keymaps.decrease_size then
        vim.keymap.set("n", keymaps.decrease_size, function()
            resize_panel_by(-step)
        end, {
            desc = "Decrease Tracker HUD panel size",
            silent = true,
            noremap = true,
        })
    end
    
    if keymaps.auto_size then
        vim.keymap.set("n", keymaps.auto_size, function()
            auto_resize_panel()
    end, {
            desc = "Auto-size Tracker HUD panel",
            silent = true,
            noremap = true,
        })

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

    vim.api.nvim_create_autocmd("QuitPre", {
        group = hud_group,
        callback = close_panel_before_source_quit,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        group = hud_group,
        callback = function(args)
            close_panel_if_source_window_closed(args.match)
        end,
    })

    vim.api.nvim_create_user_command("TrackerHudSize", resize_panel_command, {
        nargs = 1,
        complete = function()
            return { "auto" }
        end,
        force = true,
    })

    setup_keymaps()
end

return M
