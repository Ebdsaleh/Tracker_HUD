-- lua/tracker_hud/core.lua
--
-- Shared small utility helpers.

local M = {}


function M.is_table(value)
    return type(value) == "table"
end


function M.is_string(value)
    return type(value) == "string" 
end


function M.is_number(value)
    return type(value) == "number"
end


function M.is_function(value)
    return type(value) == "function"
end


function M.is_non_empty_string(value)
    return M.is_string(value) and value ~= ""
end

function M.is_valid_buffer(bufnr)
    return type(bufnr) == "number"
        and vim.api.nvim_buf_is_valid(bufnr)
end

function M.is_valid_window(winid)
    return type(winid) == "number"
        and vim.api.nvim_win_is_valid(winid)
end

function M.is_valid_cursor(cursor)
    return type(cursor) == "table"
        and type(cursor[1]) == "number"
        and type(cursor[2]) == "number"
end

return M
