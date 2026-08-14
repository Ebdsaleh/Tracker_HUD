-- lua/tracker_hud/source_index/init.lua
--
-- Generic per-buffer source index.
--
-- Indexed data is stored by:
--
--     buffer
--         -> section
--             -> line
--
-- Section IDs are supplied dynamically by adapters. This module does not
-- know about Registers, Events, Stack, Heap, or any other concrete section.
--
-- A cached line remains structurally valid while its source text remains
-- unchanged.
--
-- This module owns:
--     - per-buffer index storage
--     - dynamic section storage
--     - source-line validity
--     - line storage
--     - invalidation
--
-- Language-specific parsing and semantic compilation belong elsewhere.

local core = require("tracker_hud.core")

local M = {}


local indexes = {}


local function is_valid_line_number(line_number)
    return core.is_number(line_number)
        and line_number >= 1
        and line_number % 1 == 0
end


local function is_valid_section_id(section_id)
    return core.is_non_empty_string(section_id)
end


local function get_source_line(bufnr, line_number)
    if not core.is_valid_buffer(bufnr)
        or not is_valid_line_number(line_number)
    then
        return nil
    end

    local line_count = vim.api.nvim_buf_line_count(bufnr)

    if line_number > line_count then
        return nil
    end

    local lines = vim.api.nvim_buf_get_lines(
        bufnr,
        line_number - 1,
        line_number,
        false
    )

    return lines[1]
end


local function new_buffer_index(bufnr)
    return {
        bufnr = bufnr,
        sections = {},
    }
end


local function new_section_index(section_id)
    return {
        id = section_id,
        lines = {},
    }
end


function M.get_buffer(bufnr)
    if not core.is_valid_buffer(bufnr) then
        return nil
    end

    local index = indexes[bufnr]

    if not index then
        index = new_buffer_index(bufnr)
        indexes[bufnr] = index
    end

    return index
end


function M.get_section(bufnr, section_id)
    if not is_valid_section_id(section_id) then
        return nil
    end

    local index = M.get_buffer(bufnr)

    if not index then
        return nil
    end

    local section_index = index.sections[section_id]

    if not section_index then
        section_index = new_section_index(section_id)
        index.sections[section_id] = section_index
    end

    return section_index
end


function M.get_line(bufnr, section_id, line_number)
    if not is_valid_line_number(line_number) then
        return nil
    end

    local section_index = M.get_section(
        bufnr,
        section_id
    )

    if not section_index then
        return nil
    end

    return section_index.lines[line_number]
end


function M.line_is_current(bufnr, line_number, cached_line)
    if not core.is_table(cached_line) then
        return false
    end

    local current_source = get_source_line(
        bufnr,
        line_number
    )

    if current_source == nil then
        return false
    end

    return cached_line.source == current_source
end


function M.store_line(
    bufnr,
    section_id,
    line_number,
    compiled_line
)
    if not core.is_table(compiled_line)
        or not is_valid_line_number(line_number)
    then
        return nil
    end

    local section_index = M.get_section(
        bufnr,
        section_id
    )

    if not section_index then
        return nil
    end

    local source = get_source_line(
        bufnr,
        line_number
    )

    if source == nil then
        return nil
    end

    compiled_line.source = source
    compiled_line.compiled = true

    section_index.lines[line_number] = compiled_line

    return compiled_line
end


function M.ensure_line(
    bufnr,
    section_id,
    line_number,
    compile_fn
)
    if not is_valid_section_id(section_id)
        or not is_valid_line_number(line_number)
        or type(compile_fn) ~= "function"
    then
        return nil, false
    end

    local cached_line = M.get_line(
        bufnr,
        section_id,
        line_number
    )

    if M.line_is_current(
        bufnr,
        line_number,
        cached_line
    ) then
        return cached_line, false
    end

    local source = get_source_line(
        bufnr,
        line_number
    )

    if source == nil then
        return nil, false
    end

    local compiled_line = compile_fn(
        bufnr,
        section_id,
        line_number,
        source
    )

    if not core.is_table(compiled_line) then
        compiled_line = {}
    end

    compiled_line = M.store_line(
        bufnr,
        section_id,
        line_number,
        compiled_line
    )

    return compiled_line, true
end


function M.invalidate_line(
    bufnr,
    section_id,
    line_number
)
    if not is_valid_section_id(section_id)
        or not is_valid_line_number(line_number)
    then
        return false
    end

    local index = indexes[bufnr]

    if not index then
        return false
    end

    local section_index = index.sections[section_id]

    if not section_index then
        return false
    end

    if section_index.lines[line_number] == nil then
        return false
    end

    section_index.lines[line_number] = nil

    return true
end


function M.invalidate_section(bufnr, section_id)
    if not is_valid_section_id(section_id) then
        return false
    end

    local index = indexes[bufnr]

    if not index
        or index.sections[section_id] == nil
    then
        return false
    end

    index.sections[section_id] = nil

    return true
end


function M.invalidate_buffer(bufnr)
    if indexes[bufnr] == nil then
        return false
    end

    indexes[bufnr] = nil

    return true
end


function M.clear()
    indexes = {}
end


return M
