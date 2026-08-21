-- lua/tracker_hud/low_level/register_infer.lua
--
-- Generic register inference helpers.
--
-- This module owns register-oriented state lookups and operand-to-value facts.
-- It is deliberately architecture-neutral: adapters/specs provide register names
-- and effect contracts; this module only reads and writes generic register facts.

local core = require("tracker_hud.core")
local inference = require("tracker_hud.low_level.inference")

local M = {}


function M.get_fact_from_map(facts_by_register, register_name)
    if not core.is_table(facts_by_register)
        or not core.is_non_empty_string(register_name)
    then
        return nil
    end

    return facts_by_register[register_name:lower()]
end


function M.fact_is_resolved(fact)
    return core.is_table(fact)
        and fact.value ~= nil
        and fact.resolved ~= false
end


function M.get_fact_from_context(context, register_name)
    if not core.is_table(context)
        or not core.is_non_empty_string(register_name)
    then
        return nil
    end

    local wanted = register_name:lower()

    for _, register in ipairs(context.registers or {}) do
        if core.is_table(register)
            and core.is_non_empty_string(register.name)
            and register.name:lower() == wanted
        then
            return register
        end
    end

    return nil
end


function M.get_value_from_context(context, register_name)
    local fact = M.get_fact_from_context(context, register_name)

    if fact then
        return fact.value
    end

    return nil
end


function M.get_resolved_from_context(context, register_name)
    local fact = M.get_fact_from_context(context, register_name)

    return M.fact_is_resolved(fact)
end


function M.resolve_operand_value(facts_by_register, instruction, operand, opts)
    opts = opts or {}

    if not core.is_table(operand) then
        return inference.new_value_fact({
            value = nil,
            resolved = false,
            source = "stack",
            source_kind = "unknown",
            source_text = "<unknown>",
        })
    end

    local value = operand.text
    local resolved = value ~= nil
    local source_kind = operand.kind or "unknown"
    local source_name = operand.text
    local source_text = operand.text

    if operand.kind == "register" then
        local source_fact = M.get_fact_from_map(
            facts_by_register,
            operand.text
        )

        resolved = M.fact_is_resolved(source_fact)

        if resolved then
            value = source_fact.value
        end
    elseif operand.kind == "integer" then
        local parse_numeric_value = opts.parse_numeric_value
        local numeric_value = type(parse_numeric_value) == "function"
            and parse_numeric_value(operand.text)
            or tonumber(operand.text)

        if numeric_value ~= nil then
            value = tostring(numeric_value)
            resolved = true
        else
            resolved = false
        end
    else
        resolved = value ~= nil
    end

    return inference.new_value_fact({
        value = value,
        resolved = resolved,
        source = "instruction",
        source_kind = source_kind,
        source_name = source_name,
        source_text = source_text,
        source_line = operand.source_line
            or (instruction and instruction.source_line),
        source_column = operand.source_column or 0,
        source_start_line = operand.source_start_line,
        source_start_column = operand.source_start_column or 0,
        source_end_line = operand.source_end_line,
        source_end_column = operand.source_end_column
            or operand.source_column
            or 0,
        metadata = {
            mnemonic = instruction and instruction.mnemonic,
        },
    })
end


function M.to_fact_list(facts_by_register)
    local facts = {}

    if not core.is_table(facts_by_register) then
        return facts
    end

    for _, fact in pairs(facts_by_register) do
        table.insert(facts, fact)
    end

    return facts
end


return M
