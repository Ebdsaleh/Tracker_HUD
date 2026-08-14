-- lua/tracker_hud/source_index/compiler.lua
--
-- Generic source-index line compiler.
--
-- This module converts already-discovered source occurrences into the
-- normalized line representation stored by tracker_hud.source_index.
--
-- It does not parse source code.
-- It does not know about concrete adapters or section names.
-- It does not decide which sections use the source index.
--
-- Adapter/context-specific discovery supplies occurrences.
-- This module normalizes and organizes them.

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

    for target_group, target_ids in pairs(targets) do
        if core.is_non_empty_string(target_group) then
            result[target_group] = copy_string_list(target_ids)
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


local function add_unique_target(
    line_targets,
    seen_targets,
    target_group,
    target_id
)
    if not core.is_non_empty_string(target_group)
        or not core.is_non_empty_string(target_id)
    then
        return
    end

    line_targets[target_group] = line_targets[target_group] or {}
    seen_targets[target_group] = seen_targets[target_group] or {}

    if seen_targets[target_group][target_id] then
        return
    end

    seen_targets[target_group][target_id] = true

    table.insert(
        line_targets[target_group],
        target_id
    )
end


local function build_line_targets(occurrences)
    local line_targets = {}
    local seen_targets = {}

    for _, occurrence in ipairs(occurrences or {}) do
        for target_group, target_ids in pairs(
            occurrence.targets or {}
        ) do
            for _, target_id in ipairs(target_ids or {}) do
                add_unique_target(
                    line_targets,
                    seen_targets,
                    target_group,
                    target_id
                )
            end
        end
    end

    return line_targets
end


local function sort_occurrences(occurrences)
    table.sort(occurrences, function(left, right)
        if left.start_column == right.start_column then
            if left.end_column == right.end_column then
                return tostring(left.kind or "")
                    < tostring(right.kind or "")
            end

            return left.end_column < right.end_column
        end

        return left.start_column < right.start_column
    end)
end


function M.compile_line(discovered_occurrences)
    local occurrences = {}

    if core.is_table(discovered_occurrences) then
        for _, occurrence in ipairs(discovered_occurrences) do
            local normalized = normalize_occurrence(
                occurrence
            )

            if normalized then
                table.insert(
                    occurrences,
                    normalized
                )
            end
        end
    end

    sort_occurrences(occurrences)

    return {
        occurrences = occurrences,

        line_targets = build_line_targets(
            occurrences
        ),
    }
end


function M.find_occurrence(
    compiled_line,
    source_column
)
    if not core.is_table(compiled_line)
        or not core.is_number(source_column)
    then
        return nil
    end

    for _, occurrence in ipairs(
        compiled_line.occurrences or {}
    ) do
        if source_column >= occurrence.start_column
            and source_column < occurrence.end_column
        then
            return occurrence
        end
    end

    return nil
end


function M.get_line_targets(compiled_line)
    if not core.is_table(compiled_line)
        or not core.is_table(compiled_line.line_targets)
    then
        return {}
    end

    return compiled_line.line_targets
end


return M
