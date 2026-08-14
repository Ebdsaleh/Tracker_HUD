-- lua/tracker_hud/source_index/compiler.lua
--
-- Source-index compilation helpers.
--
-- This module converts already-discovered source occurrences into the generic
-- line representation stored by tracker_hud.source_index.
--
-- It does not parse language syntax and does not know about ASM, registers,
-- instructions, or any other language-specific concepts. Adapters/context
-- machinery provide discovered occurrences and targets.

local core = require("tracker_hud.core")

local M = {}


local function copy_string_list(values)
    local result = {}

    if not core.is_table(values) then
        return result
    end

    for _, value in ipairs(values) do
        if core.is_non_empty_string(value) then
            table.insert(result, value)
        end
    end

    return result
end


local function copy_targets(targets)
    local result = {}

    if not core.is_table(targets) then
        return result
    end

    for section_id, target_ids in pairs(targets) do
        if core.is_non_empty_string(section_id) then
            result[section_id] = copy_string_list(target_ids)
        end
    end

    return result
end


local function normalize_occurrence(occurrence)
    if not core.is_table(occurrence)
        or not core.is_non_empty_string(occurrence.kind)
    then
        return nil
    end

    local start_column = tonumber(occurrence.start_column)
    local end_column = tonumber(occurrence.end_column)

    if start_column == nil
        or end_column == nil
        or start_column < 0
        or end_column < start_column
    then
        return nil
    end

    return {
        kind = occurrence.kind,
        text = occurrence.text,

        start_column = start_column,
        end_column = end_column,

        operand_index = occurrence.operand_index,
        role = occurrence.role,

        targets = copy_targets(occurrence.targets),

        metadata = core.is_table(occurrence.metadata)
            and vim.deepcopy(occurrence.metadata)
            or {},
    }
end


local function add_unique_target(result, seen, section_id, target_id)
    if not core.is_non_empty_string(section_id)
        or not core.is_non_empty_string(target_id)
    then
        return
    end

    result[section_id] = result[section_id] or {}
    seen[section_id] = seen[section_id] or {}

    if seen[section_id][target_id] then
        return
    end

    seen[section_id][target_id] = true
    table.insert(result[section_id], target_id)
end


local function build_line_targets(occurrences)
    local result = {}
    local seen = {}

    for _, occurrence in ipairs(occurrences or {}) do
        for section_id, target_ids in pairs(occurrence.targets or {}) do
            for _, target_id in ipairs(target_ids or {}) do
                add_unique_target(
                    result,
                    seen,
                    section_id,
                    target_id
                )
            end
        end
    end

    return result
end


function M.compile_line(discovered_occurrences)
    local occurrences = {}

    for _, occurrence in ipairs(discovered_occurrences or {}) do
        local normalized = normalize_occurrence(occurrence)

        if normalized then
            table.insert(occurrences, normalized)
        end
    end

    table.sort(occurrences, function(left, right)
        if left.start_column == right.start_column then
            return left.end_column < right.end_column
        end

        return left.start_column < right.start_column
    end)

    return {
        occurrences = occurrences,
        line_targets = build_line_targets(occurrences),
    }
end


return M
