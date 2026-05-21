-- lua/tracker_hud/state.lua

local M = {}

M.source_bufnr = nil
M.source_winid = nil
M.source_cursor = nil
M.source_context = nil


function M.update_source(bufnr, winid, cursor, context)
    M.source_bufnr = bufnr
    M.source_winid = winid
    M.source_cursor = cursor
    M.source_context = context
end


function M.reset_source()
    M.source_bufnr = nil
    M.source_winid = nil
    M.source_cursor = nil
    M.source_context = nil
end

return M




