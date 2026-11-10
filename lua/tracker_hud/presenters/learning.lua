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
    local metadata = type(record) == "table"
        and type(record.metadata) == "table"
        and record.metadata or {}
    local partial = type(metadata.partial_value) == "table"
        and metadata.partial_value or nil

    if partial
        and type(partial.known_mask) == "string"
        and type(partial.known_value) == "string"
    then
        return {
            status = "partial",
            known_mask = partial.known_mask,
            known_value = partial.known_value,
        }
    end

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
        -- Architecture facts stay detached in the normalized snapshot so
        -- alternate presenters can explain aliases without reaching back
        -- into the live adapter or inference state.
        metadata = {
            register_family = type(record.metadata) == "table"
                and record.metadata.family or nil,
            source_alias = type(record.metadata) == "table"
                and record.metadata.alias_written or nil,
        },
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

local function dynamic_record_by_name(records)
    local result = {}

    for _, record in ipairs(type(records) == "table" and records or {}) do
        if type(record) == "table"
            and type(record.name) == "string"
            and record.name ~= ""
            and type(record.source_line) == "number"
        then
            result[record.name:lower()] = record
        end
    end

    return result
end

local function record_is_64_bit_scalar(record)
    return type(record) == "table"
        and type(record.metadata) == "table"
        and type(record.metadata.family) == "table"
        and record.metadata.family.bits == 64
end

-- Diagram mode has a slightly different UX need from the introductory
-- learning lens. If the cursor is still before this line's register effect
-- (for example on the "mov" mnemonic), keep showing the previously proven
-- state for that SAME register family rather than flashing an empty diagram.
--
-- This does not make the pending instruction visible early: the returned fact
-- comes from registers_before_current_line and is explicitly marked carried.
function M.select_diagram_fact(context)
    local current = M.select_fact(context)
    if current then
        return current
    end

    if type(context) ~= "table"
        or type(context.cursor) ~= "table"
        or type(context.registers) ~= "table"
        or type(context.registers_before_current_line) ~= "table"
    then
        return nil
    end

    local cursor = {
        line = context.cursor.line,
        column = cursor_column_to_zero(context.cursor.column),
    }

    local prior_by_name =
        dynamic_record_by_name(context.registers_before_current_line)

    local fallback_target = nil

    for _, record in ipairs(context.registers) do
        if type(record) == "table"
            and record.source_line == cursor.line
            and record_is_64_bit_scalar(record)
        then
            local fact = M.register_fact(record, context)

            if fact and not facts.visible_at(fact, cursor) then
                -- Prefer an explicit operand target over implicit architectural
                -- side effects such as RFLAGS when a mnemonic touches both.
                local origin = type(record.metadata) == "table"
                    and record.metadata.effect_target_origin
                    or nil

                if origin == "operand" then
                    fallback_target = record
                    break
                end

                fallback_target = fallback_target or record
            end
        end
    end

    if not fallback_target
        or type(fallback_target.name) ~= "string"
    then
        return nil
    end

    local prior = prior_by_name[fallback_target.name:lower()]
    if not prior then
        return nil
    end

    local fact = M.register_fact(prior, context)
    if not fact or not facts.visible_at(fact, cursor) then
        return nil
    end

    fact.metadata = fact.metadata or {}
    fact.metadata.carried_state = true
    fact.metadata.carried_for_line = cursor.line
    fact.metadata.pending_source_alias =
        type(fallback_target.metadata) == "table"
        and fallback_target.metadata.alias_written
        or nil
    fact.metadata.pending_mnemonic =
        type(fallback_target.metadata) == "table"
        and fallback_target.metadata.mnemonic
        or nil

    return fact
end

-- The Registers section already contains the reduced state through the
-- current cursor position. Expose detached normalized snapshots of those
-- dynamic records without re-parsing/replaying source. Unlike select_fact(),
-- this intentionally includes facts whose last effect occurred on an earlier
-- line: that is the persistence the technical Registers tree already shows.
function M.state_facts(context)
    local result = {}

    if type(context) ~= "table"
        or type(context.cursor) ~= "table"
        or type(context.registers) ~= "table"
    then
        return result
    end

    local cursor = {
        line = context.cursor.line,
        column = cursor_column_to_zero(context.cursor.column),
    }

    local prior_by_name =
        dynamic_record_by_name(context.registers_before_current_line)
    local emitted = {}

    for _, record in ipairs(context.registers) do
        -- Static architecture rows have no source position. Only reduced
        -- source/inference state is eligible for the persistent bank.
        if type(record.source_line) == "number"
            and type(record.name) == "string"
        then
            local name = record.name:lower()
            local fact = M.register_fact(record, context)

            if fact and facts.visible_at(fact, cursor) then
                result[#result + 1] = fact
                emitted[name] = true
            elseif not emitted[name] then
                -- The latest reduced state may belong to the current line but
                -- still be to the right of the cursor. Fall back to the state
                -- that reached the start of this line instead of erasing the
                -- row until the current effect becomes visible.
                local prior = prior_by_name[name]
                local prior_fact = prior and M.register_fact(prior, context)

                if prior_fact and facts.visible_at(prior_fact, cursor) then
                    prior_fact.metadata = prior_fact.metadata or {}
                    prior_fact.metadata.carried_state = true
                    prior_fact.metadata.carried_for_line = cursor.line

                    result[#result + 1] = prior_fact
                    emitted[name] = true
                end
            end
        end
    end

    return result
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
