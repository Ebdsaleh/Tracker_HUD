-- lua/tracker_hud/low_level/line_summary.lua
--
-- Pure line-summary and instruction-position policy.
--
-- This module contains no Tree-sitter traversal and no register-state
-- mutation. It classifies source columns relative to instruction ranges and
-- applies configured before/inside/after visibility policy.

local core = require("tracker_hud.core")

local M = {}


function M.resolve_options(config)
    local line_summary =
        core.is_table(config)
        and config.line_summary
        or nil

    if not core.is_table(line_summary) then
        line_summary = {}
    end

    local enabled =
        line_summary.enabled ~= false

    return {
        enabled = enabled,
        show_before_instruction =
            enabled
            and line_summary
                .show_before_instruction
                == true,
        show_after_instruction =
            enabled
            and line_summary
                .show_after_instruction
                ~= false,
    }
end


function M.classify_instruction_position(
    instruction_start_column,
    instruction_end_column,
    source_column
)
    local start_column =
        tonumber(instruction_start_column)
    local end_column =
        tonumber(instruction_end_column)
    local column =
        tonumber(source_column)

    if not start_column
        or not end_column
        or not column
    then
        return nil
    end

    if column < start_column then
        return "before_instruction"
    end

    if column >= end_column then
        return "after_instruction"
    end

    return "inside_instruction"
end


function M.allows_position(config, position)
    if position == "inside_instruction" then
        return true
    end

    local options =
        M.resolve_options(config)

    if options.enabled ~= true then
        return false
    end

    if position == "before_instruction" then
        return options.show_before_instruction
            == true
    end

    if position == "after_instruction" then
        return options.show_after_instruction
            == true
    end

    return false
end


local function get_occurrence_instruction_range(
    occurrence
)
    if not core.is_table(occurrence) then
        return nil
    end

    local metadata =
        core.is_table(occurrence.metadata)
        and occurrence.metadata
        or {}

    local start_column = tonumber(
        metadata.instruction_start_column
        or occurrence.start_column
    )

    local end_column = tonumber(
        metadata.instruction_end_column
        or occurrence.end_column
    )

    if not start_column
        or not end_column
    then
        return nil
    end

    return start_column, end_column
end


function M.get_compiled_line_instruction_range(
    compiled_line
)
    if not core.is_table(compiled_line)
        or not core.is_table(
            compiled_line.occurrences
        )
    then
        return nil, nil
    end

    local first_start = nil
    local last_end = nil

    for _, occurrence in ipairs(
        compiled_line.occurrences
    ) do
        local start_column,
            end_column =
            get_occurrence_instruction_range(
                occurrence
            )

        if start_column and end_column then
            if not first_start
                or start_column < first_start
            then
                first_start =
                    start_column
            end

            if not last_end
                or end_column > last_end
            then
                last_end =
                    end_column
            end
        end
    end

    return first_start, last_end
end


function M.classify_compiled_line_position(
    compiled_line,
    source_column
)
    local start_column,
        end_column =
        M.get_compiled_line_instruction_range(
            compiled_line
        )

    return M.classify_instruction_position(
        start_column,
        end_column,
        source_column
    )
end


function M.allows_compiled_line_position(
    config,
    compiled_line,
    source_column
)
    return M.allows_position(
        config,
        M.classify_compiled_line_position(
            compiled_line,
            source_column
        )
    )
end


return M
