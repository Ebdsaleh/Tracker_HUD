-- lua/tracker_hud/presenters/learning.lua
--
-- First accessible, text-only learning lens. Deliberately small:
-- only currently discovered register facts can produce an explanation.
-- The existing technical section tree remains untouched and available.
-- This presenter NEVER parses source or runs state/effect inference.

local facts = require("tracker_hud.facts.contract")

local M = {}

local function numeric_literal(value)
    if type(value) == "number" then return true end
    if type(value) ~= "string" then return false end
    return value:match("^%-?%d+$") ~= nil
        or value:match("^0[xX]%x+$") ~= nil
end

local function register_value(record)
    if record.resolved == false or record.value == nil then
        return { status = "unknown" }
    end
    if numeric_literal(record.value) or type(record.value) == "boolean" then
        return { status = "known", data = record.value }
    end
    -- Symbolic expression, address or metadata is not a proven number.
    return { status = "partial" }
end

-- Tree-sitter register facts store 0-based source columns.
-- The current Tracker_HUD cursor object uses 1-based columns (the
-- context engine adds 1 to nvim_win_get_cursor). Convert ONLY the cursor.
local function source_column_to_zero(column)
    return type(column) == "number" and math.max(0, column) or 0
end

local function cursor_column_to_zero(column)
    return type(column) == "number" and math.max(0, column - 1) or 0
end

function M.register_fact(record, context)
    if type(record) ~= "table" or type(context) ~= "table"
        or type(record.name) ~= "string" or record.name == ""
        or type(record.source_line) ~= "number"
        or record.source_line < 1
    then
        return nil
    end

    local column = source_column_to_zero(
        record.source_start_column or record.source_column
    )
    return facts.new({
        id = "register:" .. record.name .. "@" .. tostring(record.source_line),
        kind = "register",
        subject = {
            kind = "register",
            name = record.name,
            architecture = type(context.targets) == "table"
                and context.targets.architecture or nil,
            -- Width is architecture-owned. Never infer 64 bits merely
            -- from a register-looking name in source code.
            width_bits = type(record.metadata) == "table"
                and type(record.metadata.family) == "table"
                and record.metadata.family.bits or nil,
        },
        source = {
            line = record.source_line,
            start_column = column,
        },
        effect = { role = record.role },
        value = register_value(record),
        provenance = { kind = record.source or "source" },
    })
end

-- Share precisely the same source-discovery selection across text and
-- diagram presenters. Inference already happened in context construction.
function M.select_fact(context)
    if type(context) ~= "table" or type(context.cursor) ~= "table"
        or type(context.registers) ~= "table"
    then
        return nil
    end

    local cursor = {
        line = context.cursor.line,
        column = cursor_column_to_zero(context.cursor.column),
    }

    for _, record in ipairs(context.registers) do
        -- Static architectural register listings are not source effects.
        if record.source_line == cursor.line then
            local fact = M.register_fact(record, context)
            if fact and facts.visible_at(fact, cursor) then
                return fact
            end
        end
    end

    return nil
end

function M.lines(context)
    local lines = {
        "Learning view (source-based, not program execution):",
    }

    if type(context) ~= "table" or type(context.cursor) ~= "table" then
        lines[#lines + 1] = "  Move onto source code to explore its state."
        return lines
    end

    local fact = M.select_fact(context)
    if not fact then
        lines[#lines + 1] =
            "  No register value established at this cursor position."
        lines[#lines + 1] =
            "  Explore the sections below for source facts."
        return lines
    end

    -- Keep the introductory view calm: one focused example per update.
    local name = fact.subject.name:upper()
    local role = type(fact.effect.role) == "string"
        and fact.effect.role or nil

    if facts.is_known(fact) then
        lines[#lines + 1] = "  " .. name .. " = "
            .. tostring(fact.value.data)
            .. " (inferred from source)"
    elseif fact.value.status == "partial" then
        lines[#lines + 1] = "  " .. name
            .. " has a symbolic/partial value, not a confirmed number."
    else
        lines[#lines + 1] = "  " .. name
            .. " does not have a confirmed value here."
    end

    if role and role ~= "" then
        lines[#lines + 1] = "  Source role: " .. role
        if role == "destination" then
            lines[#lines + 1] =
                "  A destination register receives an instruction's result."
        elseif role == "source" then
            lines[#lines + 1] =
                "  A source register supplies data to an instruction."
        end
    end
    return lines
end

return M
