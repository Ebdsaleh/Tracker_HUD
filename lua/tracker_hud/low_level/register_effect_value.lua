-- lua/tracker_hud/low_level/register_effect_value.lua
--
-- Register-effect value resolution.
--
-- This module decides where a register write value comes from and performs
-- exact arithmetic/read-only lookup. It does not construct facts or mutate
-- register state.

local core = require("tracker_hud.core")
local integer_value =
    require("tracker_hud.low_level.integer_value")
local register_state_read =
    require("tracker_hud.low_level.register_state_read")
local register_value_policy =
    require("tracker_hud.low_level.register_value_policy")

local M = {}


function M.resolve(
    facts_by_register,
    instruction,
    effect,
    instruction_state,
    adapter,
    target_register
)
    local value = effect.value
    local resolved =
        value ~= nil

    if effect.value_from_stack_top
            == true
        or effect.value_from_stack
            == "top"
    then
        local stack_value =
            core.is_table(
                instruction_state
            )
            and instruction_state
                .stack_pop
            or nil

        if core.is_table(
            stack_value
        )
        then
            return stack_value.value,
                stack_value.resolved
                    ~= false
        end

        return nil, false
    end

    if core.is_non_empty_string(
        effect.value_from_register
    )
    then
        local source_fact =
            register_state_read
                .get_fact_for_read(
                    facts_by_register,
                    adapter,
                    effect
                        .value_from_register
                )

        if register_state_read
            .fact_is_resolved(
                source_fact
            )
        then
            return source_fact.value,
                true
        end

        return effect
            .value_from_register,
            false
    end

    if tonumber(
        effect
            .value_from_register_operand
    )
    then
        local source_operand =
            instruction.operands[
                tonumber(
                    effect
                        .value_from_register_operand
                )
            ]

        if source_operand
            and core.is_non_empty_string(
                source_operand.text
            )
        then
            local source_fact =
                register_state_read
                    .get_fact_for_read(
                        facts_by_register,
                        adapter,
                        source_operand.text
                    )

            if register_state_read
                .fact_is_resolved(
                    source_fact
                )
            then
                return source_fact.value,
                    true
            end

            return source_operand.text,
                false
        end
    end

    if tonumber(
        effect.value_delta_operand
    )
        or effect.value_delta ~= nil
    then
        local target_operand = nil
        local delta_target_register =
            effect.target_register

        if tonumber(
            effect.target_operand
        )
        then
            target_operand =
                instruction.operands[
                    tonumber(
                        effect.target_operand
                    )
                ]

            if target_operand then
                delta_target_register =
                    target_operand.text
            end
        end

        local target_fact =
            delta_target_register
            and register_state_read
                .get_fact_for_read(
                    facts_by_register,
                    adapter,
                    delta_target_register
                )

        if not register_state_read
            .fact_is_resolved(
                target_fact
            )
        then
            return nil, false
        end

        local current_value =
            register_value_policy
                .parse_numeric_value(
                    target_fact.value
                )

        if not current_value then
            return nil, false
        end

        local total_delta = "0"
        local has_delta = false

        if effect.value_delta
            ~= nil
        then
            local fixed_delta =
                register_value_policy
                    .parse_numeric_value(
                        effect.value_delta
                    )

            if not fixed_delta then
                return nil, false
            end

            total_delta =
                integer_value.add(
                    total_delta,
                    fixed_delta
                )

            has_delta =
                total_delta ~= nil
        end

        local source_integer_metadata =
            nil

        if tonumber(
            effect.value_delta_operand
        )
        then
            local delta_operand =
                instruction.operands[
                    tonumber(
                        effect
                            .value_delta_operand
                    )
                ]

            if delta_operand
                and delta_operand.text
                    ~= nil
            then
                local operand_delta
                local operand_resolved

                operand_delta,
                    operand_resolved,
                    source_integer_metadata =
                    register_value_policy
                        .interpret_integer_operand(
                            adapter,
                            delta_target_register,
                            delta_operand.text,
                            effect
                                .value_delta_operand_interpretation
                        )

                if not operand_resolved
                    or not operand_delta
                then
                    return nil,
                        false,
                        source_integer_metadata
                end

                total_delta =
                    integer_value.add(
                        total_delta,
                        operand_delta
                    )

                has_delta =
                    total_delta ~= nil
            elseif effect.value_delta
                == nil
            then
                return nil, false
            end
        end

        if not has_delta
            or not total_delta
        then
            return nil, false
        end

        local sign =
            tonumber(
                effect.value_delta_sign
            )
            or 1

        if sign == -1 then
            total_delta =
                integer_value.negate(
                    total_delta
                )
        elseif sign ~= 1 then
            return nil, false
        end

        local result =
            integer_value.add(
                current_value,
                total_delta
            )

        return result,
            result ~= nil,
            source_integer_metadata
    end

    if value == nil
        and tonumber(
            effect.value_operand
        )
    then
        local value_operand =
            instruction.operands[
                tonumber(
                    effect.value_operand
                )
            ]

        if value_operand then
            value =
                value_operand.text

            if value_operand.kind
                == "register"
            then
                local source_fact =
                    register_state_read
                        .get_fact_for_read(
                            facts_by_register,
                            adapter,
                            value_operand.text
                        )

                resolved =
                    register_state_read
                        .fact_is_resolved(
                            source_fact
                        )

                if resolved then
                    value =
                        source_fact.value
                end
            elseif value_operand.kind
                == "integer"
            then
                local source_integer_metadata

                value,
                    resolved,
                    source_integer_metadata =
                    register_value_policy
                        .interpret_integer_operand(
                            adapter,
                            target_register,
                            value_operand.text,
                            effect
                                .value_operand_interpretation
                        )

                return value,
                    resolved,
                    source_integer_metadata
            else
                resolved =
                    value ~= nil
            end
        end
    end

    return value, resolved
end


return M
