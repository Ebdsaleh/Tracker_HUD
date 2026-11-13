-- lua/tracker_hud/low_level/effect_match.lua
--
-- Generic low-level effect matching helpers.
--
-- This module owns architecture-neutral operand value/kind checks and simple
-- operand-equality conditions. Architecture-specific exceptions remain in
-- their caller-specific matchers.

local core = require("tracker_hud.core")

local M = {}


function M.normalize_operand_value(value)
    if type(value) ~= "string" then
        return nil
    end

    value = value:lower()
    value = value:gsub("^%s+", "")
    value = value:gsub("%s+$", "")
    value = value:gsub("^%%", "")

    return value
end


function M.collect_operand_values(operand)
    local values = {}

    if not core.is_table(operand) then
        return values
    end

    local candidate_fields = {
        "value",
        "text",
        "name",
        "raw",
        "display",
        "source",
        "register",
    }

    for _, field in ipairs(
        candidate_fields
    ) do
        local normalized =
            M.normalize_operand_value(
                operand[field]
            )

        if normalized ~= nil
            and normalized ~= ""
        then
            values[normalized] = true
        end
    end

    return values
end


function M.operand_value_matches(
    operand,
    expected_value
)
    if expected_value == nil then
        return true
    end

    local operand_values =
        M.collect_operand_values(
            operand
        )

    if type(expected_value) == "string" then
        local normalized_expected =
            M.normalize_operand_value(
                expected_value
            )

        if normalized_expected == nil then
            return true
        end

        return operand_values[
            normalized_expected
        ] == true
    end

    if core.is_table(expected_value) then
        for _, candidate in ipairs(
            expected_value
        ) do
            local normalized_candidate =
                M.normalize_operand_value(
                    candidate
                )

            if normalized_candidate ~= nil
                and operand_values[
                    normalized_candidate
                ] == true
            then
                return true
            end
        end

        return false
    end

    return true
end


function M.operand_matches_spec(
    operand,
    operand_spec
)
    if not core.is_table(operand)
        or not core.is_table(operand_spec)
    then
        return false
    end

    if not M.operand_value_matches(
        operand,
        operand_spec.value
    ) then
        return false
    end

    if not M.operand_value_matches(
        operand,
        operand_spec.values
    ) then
        return false
    end

    if type(operand_spec.kind) == "string"
        and operand.kind
            ~= operand_spec.kind
    then
        return false
    end

    return true
end


function M.operands_match_effect(
    instruction,
    effect_spec
)
    if not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return false
    end

    for _, operand_spec in ipairs(
        effect_spec.operands or {}
    ) do
        local index =
            tonumber(operand_spec.index)

        if not index then
            return false
        end

        local operand =
            instruction.operands
            and instruction.operands[index]

        if not M.operand_matches_spec(
            operand,
            operand_spec
        ) then
            return false
        end
    end

    return true
end


function M.condition_matches(
    instruction,
    condition_spec
)
    if not core.is_table(condition_spec) then
        return true
    end

    local operands_equal =
        condition_spec.operands_equal

    if core.is_table(operands_equal) then
        local left_index =
            tonumber(operands_equal[1])
        local right_index =
            tonumber(operands_equal[2])

        if not left_index
            or not right_index
        then
            return false
        end

        local left =
            instruction
            and instruction.operands
            and instruction.operands[
                left_index
            ]

        local right =
            instruction
            and instruction.operands
            and instruction.operands[
                right_index
            ]

        if not left or not right then
            return false
        end

        if tostring(
            left.text or ""
        ):lower() ~= tostring(
            right.text or ""
        ):lower()
        then
            return false
        end
    end

    return true
end


return M
