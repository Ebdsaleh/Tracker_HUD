-- lua/tracker_hud/hud.lua

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

local function ensure_panel_buffer()
    if is_valid_buffer(panel_bufnr) then
        return panel_bufnr
    end

    panel_bufnr = vim.api.nvim_create_buf(false, true)

    vim.bo[panel_bufnr].buftype = "nofile"
    vim.bo[panel_bufnr].bufhidden = "hide"
    vim.bo[panel_bufnr].swapfile = false
    vim.bo[panel_bufnr].modifiable = false

    -- Internal marker only. Do NOT use filetype here.
    vim.b[panel_bufnr].tracker_hud_panel = true

    pcall(vim.api.nvim_buf_set_name, panel_bufnr, "Tracker HUD")

    return panel_bufnr
end

local function render_winbar(context, _config)
    if not context then
        clear_winbar()
        return
    end

    vim.wo.winbar = "%#Title# [+] HUD: %#Normal# " .. context.label
end


local function restore_focus(source_winid, fallback_winid, panel_position)
    if is_valid_window(source_winid) then
        pcall(vim.api.nvim_set_current_win, source_winid)
        return
    end

    if is_valid_window(fallback_winid) then
        pcall(vim.api.nvim_set_current_win, fallback_winid)
        return
    end

    -- Last-resort directional fallback from the HUD panel.
    if panel_position == "left" then
        vim.cmd("wincmd l")
    elseif panel_position == "right" then
        vim.cmd("wincmd h")
    elseif panel_position == "top" then
        vim.cmd("wincmd j")
    elseif panel_position == "bottom" then
        vim.cmd("wincmd k")
    end
end


local function create_panel(config, source_winid)
    if is_valid_window(panel_winid) and is_valid_buffer(panel_bufnr) then
        return
    end

    local fallback_winid = vim.api.nvim_get_current_win()
    local target_winid = source_winid

    if not is_valid_window(target_winid) then
        target_winid = fallback_winid
    end

    local bufnr = ensure_panel_buffer()
    local panel_position = config.panel_position or config.panel_side or "right"
    local panel_size = tostring(config.panel_size or config.panel_width or 42)

    -- Create the split from the source window, not from wherever Neovim happens to be.
    pcall(vim.api.nvim_set_current_win, target_winid)

    if panel_position == "left" then
        vim.cmd("noautocmd topleft vertical " .. panel_size .. "split")
    elseif panel_position == "right" then
        vim.cmd("noautocmd botright vertical " .. panel_size .. "split")
    elseif panel_position == "top" then
        vim.cmd("noautocmd topleft " .. panel_size .. "split")
    elseif panel_position == "bottom" then
        vim.cmd("noautocmd botright " .. panel_size .. "split")
    else
        vim.notify(
            "tracker_hud: invalid panel_position '" .. tostring(panel_position) .. "', falling back to right",
            vim.log.levels.WARN
        )

        vim.cmd("noautocmd botright vertical " .. panel_size .. "split")
        panel_position = "right"
    end

    panel_winid = vim.api.nvim_get_current_win()

    -- Put our scratch HUD buffer into the split.
    vim.api.nvim_win_set_buf(panel_winid, bufnr)

    vim.wo[panel_winid].number = false
    vim.wo[panel_winid].relativenumber = false
    vim.wo[panel_winid].signcolumn = "no"

    if panel_position == "left" or panel_position == "right" then
        vim.wo[panel_winid].winfixwidth = true
        vim.wo[panel_winid].winfixheight = false
    else
        vim.wo[panel_winid].winfixwidth = false
        vim.wo[panel_winid].winfixheight = true
    end

    restore_focus(source_winid, fallback_winid, panel_position)
end

local function format_panel_lines(context)
    if not context then
        return {
            "Tracker HUD",
            "",
            "No Tree-sitter context available.",
            "",
            "Tip: Use Ctrl+w then h/j/k/l to switch window focus.",
        }
    end

    local lines = {
        "Tracker HUD",
        "",
        "Tip: Use Ctrl+w then h/j/k/l to switch window focus.",
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

local function render_panel(context, config, source_winid)
    create_panel(config, source_winid)

    if not is_valid_buffer(panel_bufnr) then
        return
    end

    local lines = format_panel_lines(context)

    vim.bo[panel_bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(panel_bufnr, 0, -1, false, lines)
    vim.bo[panel_bufnr].modifiable = false

    -- If creating/updating the panel moved focus, give it back to source.
    local panel_position = config.panel_position or config.panel_side or "right"
    restore_focus(source_winid, nil, panel_position)
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
                "",
                "Tip: Use Ctrl+w then h/j/k/l to switch window focus.",
            })
            vim.bo[panel_bufnr].modifiable = false
        end
    else
        clear_winbar()
    end
end

function M.render(context, config, source_winid)
    config = config or {}

    if config.display == "panel" then
        render_panel(context, config, source_winid)
    else
        render_winbar(context, config)
    end
end

function M.close_panel()
    if is_valid_window(panel_winid) then
        pcall(vim.api.nvim_win_close, panel_winid, true)
    end

    if is_valid_buffer(panel_bufnr) then
        pcall(vim.api.nvim_buf_delete, panel_bufnr, { force = true })
    end

    panel_winid = nil
    panel_bufnr = nil
end

function M.is_panel_buffer(bufnr)
    return is_valid_buffer(bufnr)
        and bufnr == panel_bufnr
end

function M.is_panel_window(winid)
    return is_valid_window(winid)
        and winid == panel_winid
end

return M
