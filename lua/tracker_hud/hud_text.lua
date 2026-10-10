-- lua/tracker_hud/hud_text.lua
--
-- Semantic HUD text composition.
--
-- This module builds plain text plus byte-column highlight spans. It does not
-- know about Neovim highlight-group names; callers use stable semantic style
-- keys and tracker_hud.highlights resolves those keys at the final render
-- boundary.
--
-- Keeping text and presentation spans side-by-side means the same rendered
-- information can later gain bold/italic/underline/undercurl attributes
-- without changing adapters or semantic models.

local visual_language = require("tracker_hud.visual_language")

local M = {}


local function normalize_text(value)
    if value == nil then
        return ""
    end

    return tostring(value)
end


function M.new()
    return {
        text = "",
        spans = {},
    }
end


function M.add_span(
    line,
    start_col,
    end_col,
    style,
    priority
)
    if type(line) ~= "table"
        or type(style) ~= "string"
        or style == ""
    then
        return line
    end

    start_col = tonumber(start_col)
    end_col = tonumber(end_col)

    if not start_col
        or not end_col
        or end_col <= start_col
    then
        return line
    end

    table.insert(line.spans, {
        style = style,
        start_col = start_col,
        end_col = end_col,
        priority = visual_language.highlight_priority_for(
            style,
            priority
        ),
    })

    return line
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


local function add_style_run(
    line,
    literal_start_col,
    run_start,
    run_end,
    style,
    priority
)
    if not run_start or not run_end or not style then
        return
    end

    M.add_span(
        line,
        literal_start_col + run_start - 1,
        literal_start_col + run_end,
        style,
        priority
    )
end


local function add_hex_literal_digit_spans(
    line,
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

        if style ~= run_style or (run_end and character_index ~= run_end + 1) then
            add_style_run(
                line,
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

    add_style_run(
        line,
        literal_start_col,
        run_start,
        run_end,
        run_style,
        priority
    )
end


function M.add_hex_width_spans(
    line,
    text_start_col,
    text,
    config,
    priority
)
    if type(line) ~= "table"
        or type(text) ~= "string"
        or text == ""
        or not visual_language.hex_width_coloring_enabled(config)
    then
        return line
    end

    text_start_col = tonumber(text_start_col) or 0
    priority = tonumber(priority) or 275

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
        local literal_col = text_start_col + start_index - 1

        M.add_span(
            line,
            literal_col,
            literal_col + 2,
            "punctuation",
            priority - 5
        )

        add_hex_literal_digit_spans(
            line,
            literal_col + digit_start - 1,
            digit_literal,
            priority
        )

        search_from = end_index + 1
    end

    return line
end


function M.append(line, value, style)
    if type(line) ~= "table" then
        return line
    end

    local text = normalize_text(value)

    if text == "" then
        return line
    end

    local start_col = #(line.text or "")
    line.text = (line.text or "") .. text
    local end_col = #line.text

    if type(style) == "string"
        and style ~= ""
        and end_col > start_col
    then
        M.add_span(
            line,
            start_col,
            end_col,
            style
        )
    end

    return line
end


function M.annotations_enabled(config, panel_width)
    return visual_language.annotations_enabled(
        config,
        panel_width
    )
end


function M.annotation_for(style, config, panel_width)
    return visual_language.annotation_for(
        style,
        config,
        panel_width
    )
end


function M.append_annotation_prefix(
    line,
    style,
    config,
    panel_width
)
    if type(line) ~= "table" then
        return false
    end

    local annotation = visual_language.annotation_for(
        style,
        config,
        panel_width
    )

    if type(annotation) ~= "table"
        or type(annotation.text) ~= "string"
        or annotation.text == ""
    then
        return false
    end

    M.append(
        line,
        annotation.text,
        annotation.semantic_style or style
    )

    M.append(line, " ", nil)

    return true
end


function M.append_semantic_value(
    line,
    value,
    style,
    config,
    panel_width
)
    M.append_annotation_prefix(
        line,
        style,
        config,
        panel_width
    )

    M.append(
        line,
        value,
        style
    )

    return line
end


function M.append_segments(line, segments)
    for _, segment in ipairs(segments or {}) do
        if type(segment) == "table" then
            M.append(
                line,
                segment.text,
                segment.style
            )
        else
            M.append(line, segment, nil)
        end
    end

    return line
end


function M.segment(text, style)
    return {
        text = normalize_text(text),
        style = style,
    }
end


function M.from_segments(segments)
    local line = M.new()
    return M.append_segments(line, segments)
end


function M.plain(text, style)
    local line = M.new()
    M.append(line, text, style)
    return line
end


function M.clone(line)
    local result = M.new()

    if type(line) ~= "table" then
        M.append(result, line, nil)
        return result
    end

    result.text = normalize_text(line.text)

    for _, span in ipairs(line.spans or {}) do
        if type(span) == "table" then
            table.insert(result.spans, {
                style = span.style,
                start_col = span.start_col,
                end_col = span.end_col,
                priority = span.priority,
                relevance = span.relevance,
            })
        end
    end

    return result
end


function M.prefixed(prefix, line, prefix_style)
    local result = M.new()

    M.append(result, prefix, prefix_style)

    if type(line) == "table" then
        local offset = #result.text

        M.append(result, line.text or "", nil)

        for _, span in ipairs(line.spans or {}) do
            if type(span) == "table"
                and tonumber(span.start_col)
                and tonumber(span.end_col)
            then
                table.insert(result.spans, {
                    style = span.style,
                    start_col = offset + tonumber(span.start_col),
                    end_col = offset + tonumber(span.end_col),
                    priority = span.priority,
                    relevance = span.relevance,
                })
            end
        end
    else
        M.append(result, line, nil)
    end

    return result
end


function M.detail(key, value, opts)
    opts = opts or {}

    local line = M.new()

    M.append(
        line,
        normalize_text(key),
        opts.key_style or "metadata_key"
    )

    M.append(
        line,
        opts.separator or ": ",
        opts.separator_style or "punctuation"
    )

    M.append(
        line,
        normalize_text(value),
        opts.value_style or "metadata_value"
    )

    return line
end


function M.parse_detail(text, opts)
    opts = opts or {}

    local raw = normalize_text(text)
    local key, value = raw:match("^([^:]+):%s?(.*)$")

    if not key then
        return M.plain(
            raw,
            opts.fallback_style or "metadata_value"
        )
    end

    return M.detail(key, value, opts)
end


function M.set_relevance(line, relevance)
    if type(line) ~= "table"
        or type(line.spans) ~= "table"
        or type(relevance) ~= "string"
        or relevance == ""
    then
        return line
    end

    for _, span in ipairs(line.spans) do
        if type(span) == "table" then
            span.relevance = relevance
        end
    end

    return line
end


function M.with_relevance(line, relevance)
    local result = M.clone(line)
    return M.set_relevance(result, relevance)
end


function M.to_text(line)
    if type(line) == "table" then
        return normalize_text(line.text)
    end

    return normalize_text(line)
end


function M.spans(line)
    if type(line) ~= "table"
        or type(line.spans) ~= "table"
    then
        return {}
    end

    return line.spans
end


return M
