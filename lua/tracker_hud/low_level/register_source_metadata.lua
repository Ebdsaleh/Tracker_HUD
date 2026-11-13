-- lua/tracker_hud/low_level/register_source_metadata.lua
--
-- Register-effect source metadata construction.
--
-- This module converts already-resolved effect/instruction source information
-- into stable descriptive metadata. It does not parse instructions, resolve
-- values, or apply register state.

local core = require("tracker_hud.core")
local operand_metadata =
    require("tracker_hud.low_level.operand_metadata")

local M = {}


function M.get_effect_operand_spec(
    effect_spec,
    operand_index
)
    if not core.is_table(effect_spec)
        or not core.is_table(
            effect_spec.operands
        )
        or not operand_index
    then
        return nil
    end

    for _, operand_spec in ipairs(
        effect_spec.operands
    ) do
        if tonumber(operand_spec.index)
            == tonumber(operand_index)
        then
            return operand_spec
        end
    end

    return nil
end


function M.get_source_operand_index(effect)
    if not core.is_table(effect) then
        return nil
    end

    return tonumber(effect.value_operand)
        or tonumber(
            effect.value_from_register_operand
        )
        or tonumber(
            effect.value_delta_operand
        )
        or tonumber(effect.size_operand)
end


function M.build(
    effect_spec,
    instruction,
    effect,
    instruction_state
)
    if not core.is_table(instruction)
        or not core.is_table(effect)
    then
        return {}
    end

    local metadata = {}

    if effect.value_from_stack_top == true
        or effect.value_from_stack == "top"
    then
        local stack_value =
            core.is_table(instruction_state)
            and instruction_state.stack_pop
            or nil

        local source_text = "stack"

        if core.is_table(stack_value) then
            source_text =
                stack_value.source_text
                or stack_value.source_name
                or stack_value.source
                or source_text
        end

        metadata.source_operand_kind =
            "stack"
        metadata.source_kind =
            "stack"
        metadata.source_operand_role =
            "stack_top"
        metadata.source_role =
            "stack top"
        metadata.source_operand =
            source_text
        metadata.source_operand_text =
            source_text
        metadata.value_source =
            "stack " .. tostring(source_text)
        metadata.value_source_kind =
            "stack"
        metadata.value_source_text =
            source_text

        if core.is_table(stack_value) then
            metadata.stack_value_source_kind =
                stack_value.source_kind
            metadata.stack_value_source_name =
                stack_value.source_name
            metadata.stack_value_source_text =
                stack_value.source_text
            metadata.stack_value_resolved =
                stack_value.resolved ~= false
        end

        return metadata
    end

    local source_index =
        M.get_source_operand_index(effect)

    local source_operand =
        source_index
        and instruction.operands
        and instruction.operands[
            source_index
        ]
        or nil

    if core.is_table(source_operand)
        and core.is_non_empty_string(
            source_operand.text
        )
    then
        local operand_spec =
            M.get_effect_operand_spec(
                effect_spec,
                source_index
            )
            or {}

        local kind_label =
            operand_metadata.kind_label(
                source_operand.kind
            )

        local role_label =
            operand_metadata
                .format_role_label(
                    operand_spec.role
                )

        local value_source =
            operand_metadata
                .value_source_label(
                    source_operand
                )

        metadata.source_operand_index =
            source_index
        metadata.source_operand =
            source_operand.text
        metadata.source_operand_text =
            source_operand.text
        metadata.source_operand_kind =
            source_operand.kind
        metadata.source_kind =
            kind_label
        metadata.source_operand_role =
            operand_spec.role
        metadata.source_role =
            role_label
        metadata.value_source =
            value_source
        metadata.value_source_kind =
            kind_label
        metadata.value_source_text =
            source_operand.text

        metadata.source_operand_line =
            source_operand.source_line
        metadata.source_operand_column =
            source_operand.source_column
        metadata.source_operand_start_line =
            source_operand.source_start_line
        metadata.source_operand_start_column =
            source_operand.source_start_column
        metadata.source_operand_end_line =
            source_operand.source_end_line
        metadata.source_operand_end_column =
            source_operand.source_end_column

        operand_metadata
            .append_memory_operand(
                metadata,
                source_operand
            )

        return metadata
    end

    -- Kept structurally equivalent to the previous context-engine helper.
    -- The earlier stack-source branch returns first, so this remains inert.
    if effect.value_from_stack_top == true
        or effect.value_from_stack == "top"
    then
        local stack_value =
            core.is_table(instruction_state)
            and instruction_state.stack_pop
            or nil

        if core.is_table(stack_value) then
            return stack_value.value,
                stack_value.resolved ~= false
        end

        return nil, false
    end

    if core.is_non_empty_string(
        effect.value_from_register
    ) then
        metadata.source_operand_kind =
            "register"
        metadata.source_kind =
            "register"
        metadata.source_operand_role =
            "source_register"
        metadata.source_role =
            "source register"
        metadata.source_operand =
            effect.value_from_register
        metadata.source_operand_text =
            effect.value_from_register
        metadata.value_source =
            "register "
            .. effect.value_from_register
        metadata.value_source_kind =
            "register"
        metadata.value_source_text =
            effect.value_from_register
    end

    return metadata
end


function M.merge(target, source)
    if not core.is_table(target)
        or not core.is_table(source)
    then
        return target
    end

    for key, value in pairs(source) do
        if value ~= nil then
            target[key] = value
        end
    end

    return target
end


return M
