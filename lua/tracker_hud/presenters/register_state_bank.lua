-- lua/tracker_hud/presenters/register_state_bank.lua
--
-- Compact persistent register-state projection for diagram mode.
-- Consumes already-reduced normalized facts from the Registers snapshot.
-- No parser, source replay, or semantic inference belongs here.

local byte_diagram = require("tracker_hud.presenters.byte_diagram")
local hud_text = require("tracker_hud.hud_text")

local M = {}

local function status_label(fact)
    local value = type(fact.value) == "table" and fact.value or {}
    return tostring(value.status or "unknown")
end

local function cells_for_fact(fact)
    local value = type(fact.value) == "table" and fact.value or {}

    if value.status ~= "known" then
        return byte_diagram.cells(nil)
    end

    local bytes = byte_diagram.bytes_for(value.data)
    if not bytes then
        return byte_diagram.cells(nil)
    end

    return byte_diagram.cells(bytes)
end

function M.lines(facts, cursor_line)
    local lines = {
        "Persistent register state (through cursor):",
    }

    local rendered = 0

    for _, fact in ipairs(type(facts) == "table" and facts or {}) do
        if type(fact) == "table"
            and fact.kind == "register"
            and type(fact.subject) == "table"
            and fact.subject.width_bits == 64
            and type(fact.subject.name) == "string"
        then
            local marker = type(fact.source) == "table"
                and fact.source.line == cursor_line
                and ">"
                or " "

            local source_line = type(fact.source) == "table"
                and fact.source.line
                or nil

            lines[#lines + 1] = string.format(
                "  %s %-4s %s  %-7s%s",
                marker,
                fact.subject.name:upper(),
                cells_for_fact(fact),
                status_label(fact),
                source_line and (" @ line " .. tostring(source_line)) or ""
            )
            rendered = rendered + 1
        end
    end

    if rendered == 0 then
        lines[#lines + 1] =
            "  No source-established 64-bit register state yet."
    else
        lines[#lines + 1] =
            "  > = register whose latest state change is on the current line."
        lines[#lines + 1] =
            "  Earlier rows remain because their reduced state still reaches this cursor."
    end

    return lines
end

local function append_cell_tokens(line, cells, style, relevance)
    local search_from = 1
    while true do
        local start_index, end_index = cells:find("%[[^%]]+%]", search_from)
        if not start_index then break end

        local offset = #line.text
        hud_text.append(line, cells:sub(search_from, start_index - 1), nil)
        local token = cells:sub(start_index, end_index)
        local start_col = #line.text
        hud_text.append(line, token, nil)
        hud_text.add_span(
            line,
            start_col,
            #line.text,
            style,
            420
        )
        line.spans[#line.spans].relevance = relevance
        search_from = end_index + 1
    end

    hud_text.append(line, cells:sub(search_from), nil)
end

local function rich_state_row(fact, cursor_line)
    local line = hud_text.new()
    local current = type(fact.source) == "table"
        and fact.source.line == cursor_line
    local relevance = current and "current" or "historical"
    local value = type(fact.value) == "table" and fact.value or {}
    local marker = current and ">" or " "
    local name = fact.subject.name:upper()
    local cells = cells_for_fact(fact)
    local state_style = value.status == "known"
        and (current and "affected" or "immediate")
        or "unresolved"

    hud_text.append(line, "  ", nil)
    hud_text.append(line, marker, current and "affected" or "muted")
    hud_text.append(line, " ", nil)

    local name_start = #line.text
    hud_text.append(line, string.format("%-4s", name), nil)
    hud_text.add_span(
        line,
        name_start,
        #line.text,
        current and "affected" or "register",
        390
    )
    line.spans[#line.spans].relevance = relevance

    hud_text.append(line, " ", nil)
    append_cell_tokens(
        line,
        cells,
        state_style,
        relevance
    )

    hud_text.append(line, "  ", nil)
    local status_start = #line.text
    hud_text.append(line, string.format("%-7s", status_label(fact)), nil)
    hud_text.add_span(
        line,
        status_start,
        #line.text,
        value.status == "known" and "value" or "unresolved",
        340
    )
    line.spans[#line.spans].relevance = relevance

    if type(fact.source) == "table" and fact.source.line then
        hud_text.append(line, " @ line ", "muted")
        local line_start = #line.text
        hud_text.append(line, tostring(fact.source.line), nil)
        hud_text.add_span(
            line,
            line_start,
            #line.text,
            "line_number",
            320
        )
        line.spans[#line.spans].relevance = relevance
    end

    return line
end

-- Structured equivalent of lines(). Current-line state uses semantic
-- affected/unresolved emphasis; carried state uses historical relevance.
-- Plain mode still retains the literal > marker and explanatory text.
function M.rich_lines(facts, cursor_line)
    local lines = {
        hud_text.plain(
            "Persistent register state (through cursor):",
            "title"
        ),
    }

    local rendered = 0

    for _, fact in ipairs(type(facts) == "table" and facts or {}) do
        if type(fact) == "table"
            and fact.kind == "register"
            and type(fact.subject) == "table"
            and fact.subject.width_bits == 64
            and type(fact.subject.name) == "string"
        then
            lines[#lines + 1] = rich_state_row(fact, cursor_line)
            rendered = rendered + 1
        end
    end

    if rendered == 0 then
        lines[#lines + 1] = hud_text.plain(
            "  No source-established 64-bit register state yet.",
            "muted"
        )
    else
        lines[#lines + 1] = hud_text.plain(
            "  > = register whose latest state change is on the current line.",
            "muted"
        )
        lines[#lines + 1] = hud_text.plain(
            "  Earlier rows remain because their reduced state still reaches this cursor.",
            "muted"
        )
    end

    return lines
end

return M
