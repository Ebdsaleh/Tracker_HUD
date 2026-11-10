-- lua/tracker_hud/presenters/register_state_bank.lua
--
-- Compact persistent register-state projection for diagram mode.
-- Consumes already-reduced normalized facts from the Registers snapshot.
-- No parser, source replay, or semantic inference belongs here.

local byte_diagram = require("tracker_hud.presenters.byte_diagram")

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

return M
