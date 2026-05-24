-- lua/tracker_hud/state.lua

local core = require("tracker_hud.core")
local M = {}

M.source_bufnr = nil
M.source_winid = nil
M.source_cursor = nil
M.source_context = nil


function M.update_source(bufnr, winid, cursor, context)
    if not core.is_valid_buffer(bufnr) then
        return false
    end

    if not core.is_valid_window(winid) then
        return false
    end

    if not core.is_valid_cursor(cursor) then
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




