-- lua/tracker_hud/state.lua

local M = {}

M.source_bufnr = nil
M.source_winid = nil
M.source_cursor = nil
M.source_context = nil

local function is_valid_buffer(bufnr)
    return type(bufnr) == "number"
        and vim.api.nvim_buf_is_valid(bufnr)
end

local function is_valid_window(winid)
    return type(winid) == "number"
        and vim.api.nvim_win_is_valid(winid)
end

local function is_valid_cursor(cursor)
    return type(cursor) == "table"
        and type(cursor[1]) == "number"
        and type(cursor[2]) == "number"
end

function M.update_source(bufnr, winid, cursor, context)
    if not is_valid_buffer(bufnr) then
        return false
    end

    if not is_valid_window(winid) then
        return false
    end

    if not is_valid_cursor(cursor) then
        return false
    end

    M.source_bufnr = bufnr
    M.source_winid = winid
    M.source_cursor = cursor
    M.source_context = context
    return true
end


function M.reset_source()
    M.source_bufnr = nil
    M.source_winid = nil
    M.source_cursor = nil
    M.source_context = nil
end

return M




