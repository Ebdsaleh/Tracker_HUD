-- lua/tracker_hud/hud.lua

local hud_sections = require("tracker_hud.hud_sections")
local hud_controls = require("tracker_hud.hud_controls")
local hud_nodes = require("tracker_hud.hud_nodes")

local M = {}

local panel_bufnr = nil
local panel_winid = nil
local resolved_panel_size = nil
local last_context = nil
local last_config = nil
local last_source_winid = nil
local panel_line_targets = {}



local function is_valid_window(winid)
    return winid and vim.api.nvim_win_is_valid(winid)
end

local function is_valid_buffer(bufnr)
    return bufnr and vim.api.nvim_buf_is_valid(bufnr)
end


local function get_panel_cursor_location()
    if not is_valid_window(panel_winid) then
        return nil
    end

    local ok, cursor = pcall(vim.api.nvim_win_get_cursor, panel_winid)

    if not ok or not cursor then
        return nil
    end

    return {
        line = cursor[1],
        column = cursor[2],
    }
end


local function set_panel_cursor_location(cursor)
    if not cursor or not is_valid_window(panel_winid) or not is_valid_buffer(panel_bufnr) then
        return false
    end

    local line_count = vim.api.nvim_buf_line_count(panel_bufnr)
    local line = math.max(1, math.min(cursor.line or 1, line_count))
    local column = math.max(0, cursor.column or 0)

    pcall(vim.api.nvim_win_set_cursor, panel_winid, { line, column })

    return true
end



local function clear_winbar()
    vim.wo.winbar = nil
end

local function get_panel_position(config)
    return config.panel_position or  "right"
end

local function is_vertical_panel(panel_position)
    return panel_position == "left" or panel_position == "right"
end

local function get_line_width(line)
    local ok, width = pcall(vim.fn.strdisplaywidth, line)

    if ok and width then
        return width
    end

    return #line
end

local function get_longest_line_width(lines)
    local longest = 0

    for _, line in ipairs(lines or {}) do
        local width = get_line_width(line)

        if width > longest then
            longest = width
        end
    end

    return longest
end

local function calculate_auto_panel_size(config, panel_position, lines)
    if is_vertical_panel(panel_position) then
        local width = get_longest_line_width(lines)
        local padding = config.panel_auto_width_padding or 2
        local fallback = config.panel_default_width or 52

        if width <= 0 then
            return fallback
        end

        return width + padding
    end

    local height = #(lines or {})
    local padding = config.panel_auto_height_padding or 2
    local fallback = config.panel_default_height or 9

    if height <= 0 then
        return fallback
    end

    return height + padding
end

local function get_resolved_panel_size(config, panel_position, lines)
    if resolved_panel_size then
        return resolved_panel_size
    end

    local requested_size = config.panel_size  or "auto"

    if requested_size == "auto" then
        resolved_panel_size = calculate_auto_panel_size(config, panel_position, lines)
        return resolved_panel_size
    end

    local numeric_size = tonumber(requested_size)

    if numeric_size then
        resolved_panel_size = numeric_size
        return resolved_panel_size
    end

    if is_vertical_panel(panel_position) then
        resolved_panel_size = config.panel_default_width or 52
    else
        resolved_panel_size = config.panel_default_height or 9
    end

    return resolved_panel_size
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

    -- Toggle HUD sections from inside the panel.
    vim.keymap.set("n", "<CR>", function()
        require("tracker_hud.hud").toggle_section_at_panel_cursor()
    end, {
        buffer = panel_bufnr,
        silent = true,
        noremap = true,
        desc = "Toggle Tracker HUD section",
    })
    
    -- Toggle HUD sections from inside the panel (mouse support).
    vim.keymap.set("n", "<2-LeftMouse>", function()
        require("tracker_hud.hud").toggle_section_at_panel_cursor()
    end, {
        buffer = panel_bufnr,
        silent = true,
        noremap = true,
        desc = "Toggle Tracker HUD section with double click",
    })

    pcall(vim.api.nvim_buf_set_name, panel_bufnr, "Tracker HUD")

    return panel_bufnr
end

local function render_winbar(context, _config)
    if not context then
        clear_winbar()
        return
    end

    local label = context.label

    if context.cursor and context.cursor.line then
        label = label .. " -> [" .. tostring(context.cursor.line) .. "] Current"
    end

    vim.wo.winbar = "%#Title# [+] HUD: %#Normal# " .. label
end


local function restore_focus(source_winid, fallback_winid, panel_position)
    local function do_restore()
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
            pcall(vim.cmd, "wincmd l")
        elseif panel_position == "right" then
            pcall(vim.cmd, "wincmd h")
        elseif panel_position == "top" then
            pcall(vim.cmd, "wincmd j")
        elseif panel_position == "bottom" then
            pcall(vim.cmd, "wincmd k")
        end
    end

    do_restore()
    vim.schedule(do_restore)
end

local function create_panel(config, source_winid, lines)
    if is_valid_window(panel_winid) and is_valid_buffer(panel_bufnr) then
        return
    end

    local fallback_winid = vim.api.nvim_get_current_win()
    local target_winid = source_winid

    if not is_valid_window(target_winid) then
        target_winid = fallback_winid
    end

    local bufnr = ensure_panel_buffer()
    local panel_position = get_panel_position(config)
    local panel_size = tostring(get_resolved_panel_size(config, panel_position, lines))

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

        panel_position = "right"
        panel_size = tostring(get_resolved_panel_size(config, panel_position, lines))
        vim.cmd("noautocmd botright vertical " .. panel_size .. "split")
    end

    panel_winid = vim.api.nvim_get_current_win()

    -- Put our scratch HUD buffer into the split.
    vim.api.nvim_win_set_buf(panel_winid, bufnr)

    vim.wo[panel_winid].number = false
    vim.wo[panel_winid].relativenumber = false
    vim.wo[panel_winid].signcolumn = "no"

    if is_vertical_panel(panel_position) then
        vim.wo[panel_winid].winfixwidth = true
        vim.wo[panel_winid].winfixheight = false
        pcall(vim.api.nvim_win_set_width, panel_winid, tonumber(panel_size))
    else
        vim.wo[panel_winid].winfixwidth = false
        vim.wo[panel_winid].winfixheight = true
        pcall(vim.api.nvim_win_set_height, panel_winid, tonumber(panel_size))
    end

    restore_focus(source_winid, fallback_winid, panel_position)
end



local function append_section_lines(lines, section)
    if section.kind == "control" then
        table.insert(lines, section.title or "<control>")
        panel_line_targets[#lines] = {
            kind = "control",
            id = section.id,
        }
        return
    end

    local marker = section.expanded and "[-]" or "[+]"
    table.insert(lines, section.title .. " " .. marker)

    panel_line_targets[#lines] = {
        kind = "section",
        id = section.id,
    }

    if section.expanded then
        if section.lines and #section.lines > 0 then
            for index, line in ipairs(section.lines) do
                table.insert(lines, line)

                if section.line_targets and section.line_targets[index] then
                    panel_line_targets[#lines] = section.line_targets[index]
                end
            end
        else
            table.insert(lines, "  " .. (section.empty_text or "<empty>"))
        end
    end

    table.insert(lines, "")
end


local function format_panel_lines(context)
    if not context then
        return {
            "Tracker HUD",
            "",
            "No Tree-sitter context available.",
            "",
            "Tip: Ctrl+w h/j/k/l to focus panel, Enter to toggle sections.",
        }
    end

    panel_line_targets = {}

    local lines = {
        "Tracker HUD",
        "",
        "Tip: Ctrl+w h/j/k/l to focus panel, Enter to toggle sections.",
        "",
    }

    -- Current Scope Lines:
    local scope_line_text = "Current scope lines:"

    if context.start_line and context.end_line then
        scope_line_text = scope_line_text
            .. " "
            .. tostring(context.start_line)
            .. " - "
            .. tostring(context.end_line)
    end
    table.insert(lines, scope_line_text)

    -- Depth:
    table.insert(lines, "Depth: " .. tostring(context.depth or 0))

    -- Current Line:
    local current_line_text = "Current Line:"

    if context.cursor and context.cursor.line then
        current_line_text = current_line_text
            .. " ["
            .. tostring(context.cursor.line)
            .. "]"
    end
    table.insert(lines, current_line_text)

    table.insert(lines, "")

    local panel_width = resolved_panel_size

    if is_valid_window(panel_winid) then
        local ok, width = pcall(vim.api.nvim_win_get_width, panel_winid)

        if ok and width then
            panel_width = width
        end
    end

    local sections = hud_sections.build(context, {
        panel_width = panel_width,
    })

    for _, section in ipairs(sections) do
        append_section_lines(lines, section)
    end

    return lines
end

local function render_panel(context, config, source_winid)
    local lines = format_panel_lines(context)

    create_panel(config, source_winid, lines)

    if not is_valid_buffer(panel_bufnr) then
        return
    end

    vim.bo[panel_bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(panel_bufnr, 0, -1, false, lines)
    vim.bo[panel_bufnr].modifiable = false

    local panel_position = get_panel_position(config)
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
                "Tip: Ctrl+w h/j/k/l to focus panel, Enter to toggle sections.",
            })
            vim.bo[panel_bufnr].modifiable = false
        end
    else
        clear_winbar()
    end
end

function M.render(context, config, source_winid)
    config = config or {}

    last_context = context
    last_config = config
    last_source_winid = source_winid

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
    resolved_panel_size = nil
end

function M.is_panel_buffer(bufnr)
    return is_valid_buffer(bufnr)
        and bufnr == panel_bufnr
end

function M.is_panel_window(winid)
    return is_valid_window(winid)
        and winid == panel_winid
end

local function apply_panel_size(panel_position, size)
    if not is_valid_window(panel_winid) then
        return false
    end
    
    local numeric_size = tonumber(size)

    if not numeric_size then
        return false
    end
    
    if is_vertical_panel(panel_position) then
        pcall(vim.api.nvim_win_set_width, panel_winid, numeric_size)
    else
        pcall(vim.api.nvim_win_set_height, panel_winid, numeric_size)
    end

    resolved_panel_size = numeric_size
    return true
end

function M.resize_panel(size, config, context)
    config = config or {}

    if not is_valid_window(panel_winid) then
        vim.notify("tracker_hud: panel is not open", vim.log.levels.WARN)
        return
    end

    local panel_position = get_panel_position(config)

    if size == "auto" then
        local lines = format_panel_lines(context)
        resolved_panel_size = calculate_auto_panel_size(config, panel_position, lines)
        apply_panel_size(panel_position, resolved_panel_size)
        return
    end

    local numeric_size = tonumber(size)

    if not numeric_size then
        vim.notify(
            "tracker_hud: invalid panel size '" .. tostring(size) .. "'",
            vim.log.levels.WARN
        )
        return
    end

    apply_panel_size(panel_position, numeric_size)
end

function M.get_panel_size()
    return resolved_panel_size
end


function M.reopen_panel()
    if is_valid_window(panel_winid) then
        pcall(vim.api.nvim_win_close, panel_winid, true)
    end

    panel_winid = nil
    resolved_panel_size = nil
end


function M.update_panel()
    if not last_context then
        return false
    end

    if not is_valid_window(panel_winid) or not is_valid_buffer(panel_bufnr) then
        return M.refresh()
    end

    local current_winid = vim.api.nvim_get_current_win()
    local panel_cursor = get_panel_cursor_location()
    local lines = format_panel_lines(last_context)

    vim.bo[panel_bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(panel_bufnr, 0, -1, false, lines)
    vim.bo[panel_bufnr].modifiable = false

    set_panel_cursor_location(panel_cursor)

    if is_valid_window(current_winid) then
        pcall(vim.api.nvim_set_current_win, current_winid)
    end

    return true
end

function M.refresh()
    if not last_context then
        return false
    end

    M.render(last_context, last_config or {}, last_source_winid)
    return true
end


function M.toggle_section_at_panel_cursor()
    local target = M.get_target_at_panel_cursor()

    if not target then
        return false
    end

    return M.toggle_target(target)
end


function M.get_target_at_panel_cursor()
    if not is_valid_window(panel_winid) then
        return nil
    end

    local cursor = vim.api.nvim_win_get_cursor(panel_winid)
    local line_number = cursor[1]

    return panel_line_targets[line_number]
end


function M.toggle_target(target)
    if not target or not target.id then
        return false
    end

    local ok = false

    if target.kind == "section" then
        ok = hud_sections.toggle(target.id)
    elseif target.kind == "control" then
        ok = hud_controls.toggle(target.id)
    elseif target.kind == "node" then
        ok = hud_nodes.toggle(target.id)
    end

    if not ok then
        return false
    end

    M.update_panel()
    return true
end

return M
