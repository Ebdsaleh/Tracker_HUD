-- lua/tracker_hud/low_level/register_fact_builder.lua
--
-- Register fact construction.
--
-- This module builds one reduced register fact from an already-matched effect.
-- It may read existing family state for alias composition, but it does not
-- publish/mutate register state maps.

local core = require("tracker_hud.core")
local register_effect_value =
    require("tracker_hud.low_level.register_effect_value")
local register_value_policy =
    require("tracker_hud.low_level.register_value_policy")
local register_state_read =
    require("tracker_hud.low_level.register_state_read")
local register_value_mask =
    require("tracker_hud.low_level.register_value_mask")
local register_source_metadata =
    require("tracker_hud.low_level.register_source_metadata")

local M = {}


function M.build(
    facts_by_register,
    family_state,
    adapter,
    instruction,
    effect_spec,
    instruction_state
)
    if not core.is_table(facts_by_register)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
        or not core.is_table(effect_spec.effect)
    then
        return nil
    end

    local effect =
        effect_spec.effect

    local target_index =
        tonumber(effect.target_operand)

    local target_operand = nil
    local target_register =
        effect.target_register

    if target_index then
        target_operand =
            instruction.operands
            and instruction.operands[
                target_index
            ]

        if not core.is_table(
            target_operand
        )
            or not core.is_non_empty_string(
                target_operand.text
            )
        then
            return nil
        end

        target_register =
            target_operand.text
    end

    if not core.is_non_empty_string(
        target_register
    )
    then
        return nil
    end

    local write_value,
        write_resolved,
        source_integer_metadata =
        register_effect_value.resolve(
            facts_by_register,
            instruction,
            effect,
            instruction_state,
            adapter,
            target_register
        )

    local width_metadata

    write_value,
        write_resolved,
        width_metadata =
        register_value_policy
            .apply_width_policy(
                adapter,
                target_register,
                effect,
                write_value,
                write_resolved
            )

    local value = write_value
    local resolved = write_resolved

    local alias_resolution =
        register_state_read
            .resolve_alias(
                adapter,
                target_register
            )

    local canonical_name =
        alias_resolution
        and alias_resolution.canonical
        or target_register:lower()

    local reduced_state = nil

    if alias_resolution
        and core.is_table(
            alias_resolution.family
        )
        and alias_resolution.family.bits
            == 64
        and core.is_table(
            alias_resolution.alias
        )
        and alias_resolution.alias.bits
            < 64
    then
        reduced_state =
            register_value_mask
                .apply_alias_write(
                    family_state
                    and family_state[
                        canonical_name
                    ],
                    alias_resolution.alias,
                    write_value,
                    write_resolved
                )

        if reduced_state then
            value =
                reduced_state.value

            resolved =
                reduced_state.resolved
        end
    end

    local static_spec =
        register_state_read
            .get_static_spec(
                adapter,
                canonical_name
            )
        or register_state_read
            .get_static_spec(
                adapter,
                target_register
            )
        or {}

    local metadata = {
        adapter = adapter.name,
        architecture =
            adapter.architecture,
        variant =
            adapter.active_variant_name,
        mnemonic =
            instruction.mnemonic,
        effect = effect.name,

        effect_target_origin =
            target_index
            and "operand"
            or "implicit_register",

        canonical_name =
            canonical_name,

        write_value =
            write_value,

        write_resolved =
            write_resolved ~= false,

        value_width_policy =
            width_metadata
            and width_metadata
                .value_width_policy
            or nil,

        value_width_bits =
            width_metadata
            and width_metadata
                .value_width_bits
            or nil,

        pre_width_write_value =
            width_metadata
            and width_metadata
                .pre_width_write_value
            or nil,

        value_wrapped =
            width_metadata
            and width_metadata
                .value_wrapped,

        value_width_error =
            width_metadata
            and width_metadata
                .value_width_error
            or nil,
    }

    if reduced_state
        and reduced_state.partial_value
    then
        metadata.partial_value =
            reduced_state.partial_value
    end

    register_source_metadata.merge(
        metadata,
        source_integer_metadata
    )

    register_source_metadata.merge(
        metadata,
        register_source_metadata.build(
            effect_spec,
            instruction,
            effect,
            instruction_state
        )
    )

    return {
        name =
            target_register:lower(),

        kind =
            static_spec.kind
            or "unknown",

        value = value,

        resolved =
            resolved ~= false,

        role =
            effect.role
            or static_spec.role,

        source = "instruction",

        source_line =
            target_operand
            and target_operand.source_line
            or instruction.source_line,

        source_column =
            target_operand
            and target_operand.source_column
            or instruction.source_column
            or 0,

        source_start_line =
            target_operand
            and target_operand
                .source_start_line
            or instruction
                .source_start_line
            or instruction.source_line,

        source_start_column =
            target_operand
            and target_operand
                .source_start_column
            or instruction
                .source_start_column
            or instruction.source_column
            or 0,

        source_end_line =
            target_operand
            and target_operand
                .source_end_line
            or instruction
                .source_end_line
            or instruction.source_line,

        source_end_column =
            target_operand
            and target_operand
                .source_end_column
            or instruction
                .source_end_column
            or instruction.source_column
            or 0,

        metadata = metadata,
    }
end


return M
