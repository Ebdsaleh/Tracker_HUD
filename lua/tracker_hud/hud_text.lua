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
