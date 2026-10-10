-- lua/tracker_hud/hex_width.lua
--
-- Plugin-wide source-buffer hexadecimal width guides.
--
-- The HUD renderer can color hex values that appear inside the Tracker HUD
-- panel. This module separately colors hexadecimal literals directly in normal
-- source buffers, regardless of language adapter, so low-level values keep the
-- same byte-width visual grammar in ASM, Lua, C, Rust, and other languages.

local highlights = require("tracker_hud.highlights")
local visual_language = require("tracker_hud.visual_language")

local M = {}

local render_namespace = vim.api.nvim_create_namespace(
    "tracker_hud_hex_width_source"
)


local function is_valid_buffer(bufnr)
    return bufnr and vim.api.nvim_buf_is_valid(bufnr)
end


local function is_hex_digit(character)
    return type(character) == "string"
        and character:match("^[%da-fA-F]$") ~= nil
end


local function collect_hex_digit_positions(literal)
    local positions = {}

    if type(literal) ~= "string" then
        return positions
    end

    for index = 1, #literal do
        local character = literal:sub(index, index)

        if is_hex_digit(character) then
            table.insert(positions, index)
        end
    end

    return positions
end


local function apply_style_run(
    bufnr,
    config,
    row,
    literal_start_col,
    run_start,
    run_end,
    style,
    priority
)
    if not run_start or not run_end or not style then
        return
    end

    local group = highlights.group_name(config, style)

    if not group then
        return
    end

    pcall(
        vim.api.nvim_buf_set_extmark,
        bufnr,
        render_namespace,
        row,
        literal_start_col + run_start - 1,
        {
            end_row = row,
            end_col = literal_start_col + run_end,
            hl_group = group,
            priority = priority or 350,
        }
    )
end


local function apply_hex_literal_digit_spans(
    bufnr,
    config,
    row,
    literal_start_col,
    literal,
    priority
)
    local digit_positions = collect_hex_digit_positions(literal)
    local total_digits = #digit_positions

    if total_digits == 0 then
        return
    end

    local run_start = nil
    local run_end = nil
    local run_style = nil

    for digit_number, character_index in ipairs(digit_positions) do
        local digit_from_right = total_digits - digit_number + 1
        local style = visual_language.hex_width_style_for_digit_from_right(
            digit_from_right
        )

        if style ~= run_style
            or (run_end and character_index ~= run_end + 1)
        then
            apply_style_run(
                bufnr,
                config,
                row,
                literal_start_col,
                run_start,
                run_end,
                run_style,
                priority
            )

            run_start = character_index
            run_end = character_index
            run_style = style
        else
            run_end = character_index
        end
    end

    apply_style_run(
        bufnr,
        config,
        row,
        literal_start_col,
        run_start,
        run_end,
        run_style,
        priority
    )
end


local function highlight_line(bufnr, config, row, text, priority)
    if type(text) ~= "string" or text == "" then
        return
    end

    local search_from = 1

    while search_from <= #text do
        local start_index, end_index = text:find(
            "0[xX][%da-fA-F_]+",
            search_from
        )

        if not start_index then
            break
        end

        local literal = text:sub(start_index, end_index)
        local digit_start = 3
        local digit_literal = literal:sub(digit_start)
        local digit_start_col = start_index - 1 + digit_start - 1

        apply_hex_literal_digit_spans(
            bufnr,
            config,
            row,
            digit_start_col,
            digit_literal,
            priority
        )

        search_from = end_index + 1
    end
end


function M.clear_buffer(bufnr)
    if not is_valid_buffer(bufnr) then
        return false
    end

    vim.api.nvim_buf_clear_namespace(
        bufnr,
        render_namespace,
        0,
        -1
    )

    return true
end


local function scan_range_for_window(winid, line_count)
    if not winid or not vim.api.nvim_win_is_valid(winid) then
        return 0, line_count
    end

    local ok_top, top = pcall(vim.fn.line, "w0", winid)
    local ok_bottom, bottom = pcall(vim.fn.line, "w$", winid)

    if not ok_top or not ok_bottom then
        return 0, line_count
    end

    top = math.max(1, tonumber(top) or 1)
    bottom = math.max(top, tonumber(bottom) or top)

    return top - 1, math.min(bottom, line_count)
end


function M.refresh_buffer(bufnr, config, winid)
    if not is_valid_buffer(bufnr) then
        return false
    end

    M.clear_buffer(bufnr)

    if not visual_language.hex_width_source_coloring_enabled(config) then
        return true
    end

    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local max_lines = visual_language.hex_width_source_max_lines(config)
    local start_line = 0
    local end_line = line_count

    -- Whole-buffer highlighting is easiest to reason about for normal files.
    -- Very large buffers fall back to the visible window to avoid making cursor
    -- movement expensive in logs, dumps, or generated files.
    if line_count > max_lines then
        start_line, end_line = scan_range_for_window(winid, line_count)
    end

    local ok, lines = pcall(
        vim.api.nvim_buf_get_lines,
        bufnr,
        start_line,
        end_line,
        false
    )

    if not ok then
        return false
    end

    for offset, line in ipairs(lines) do
        highlight_line(
            bufnr,
            config,
            start_line + offset - 1,
            line,
            350
        )
    end

    return true
end


return M
