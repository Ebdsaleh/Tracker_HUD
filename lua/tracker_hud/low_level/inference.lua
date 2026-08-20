-- lua/tracker_hud/low_level/inference.lua
--
-- Generic low-level inference helpers.
--
-- This module is intentionally not ASM-specific. It provides tiny shared
-- primitives for low-level state reducers:
--
--   - compare source positions
--   - make cheap context overlays for pre/post state reads
--   - index section facts by stable keys
--   - read known values from a section fact list
--
-- Adapters still only declare facts. Concrete reducers decide how to apply
-- those facts for Registers, Stack, Heap, Events, Warnings, or future
-- low-level language adapters.

local core = require("tracker_hud.core")

local M = {}


local function first_number(...)
    for index = 1, select("#", ...) do
        local value = select(index, ...)

        if core.is_number(value) then
            return value
        end
    end

    return nil
end


function M.normalize_position(position)
    if not core.is_table(position) then
        return nil
    end

    local line = first_number(
        position.line,
        position.source_line,
        position.source_start_line
    )

    local column = first_number(
        position.column,
        position.source_column,
        position.source_start_column
    )

    if not core.is_number(line) then
        return nil
    end

    return {
        line = line,
        column = column or 0,
    }
end


function M.position_is_before(left, right)
    left = M.normalize_position(left)
    right = M.normalize_position(right)

    if not left or not right then
        return false
    end

    if left.line ~= right.line then
        return left.line < right.line
    end

    return left.column < right.column
end


function M.position_is_at_or_before(left, right)
    left = M.normalize_position(left)
    right = M.normalize_position(right)

    if not left or not right then
        return false
    end

    if left.line ~= right.line then
        return left.line < right.line
    end

    return left.column <= right.column
end


function M.shallow_copy_context(context)
    local result = {}

    if not core.is_table(context) then
        return result
    end

    for key, value in pairs(context) do
        result[key] = value
    end

    return result
end


function M.with_section_facts(context, section_name, facts)
    local result = M.shallow_copy_context(context)

    if core.is_non_empty_string(section_name)
        and core.is_table(facts)
    then
        result[section_name] = facts
    end

    return result
end


function M.fact_key(fact, key_field)
    if not core.is_table(fact) then
        return nil
    end

    key_field = key_field or "id"

    local value = fact[key_field]
        or fact.id
        or fact.name
        or fact.register
        or fact.key

    if not core.is_non_empty_string(value) then
        return nil
    end

    return value:lower()
end


function M.index_facts(facts, key_field)
    local result = {}

    if not core.is_table(facts) then
        return result
    end

    for _, fact in ipairs(facts) do
        local key = M.fact_key(fact, key_field)

        if key then
            result[key] = fact
        end
    end

    return result
end


function M.get_fact(facts_or_index, name, key_field)
    if not core.is_table(facts_or_index)
        or not core.is_non_empty_string(name)
    then
        return nil
    end

    local wanted = name:lower()

    local direct = facts_or_index[wanted]

    if core.is_table(direct) then
        return direct
    end

    for _, fact in ipairs(facts_or_index) do
        if M.fact_key(fact, key_field) == wanted then
            return fact
        end
    end

    return nil
end


function M.fact_is_resolved(fact)
    return core.is_table(fact)
        and fact.value ~= nil
        and fact.resolved ~= false
end


function M.get_fact_value(facts_or_index, name, key_field)
    local fact = M.get_fact(facts_or_index, name, key_field)

    if fact then
        return fact.value
    end

    return nil
end


return M
