-- lua/tracker_hud/low_level/register_source_occurrence.lua
--
-- Register source-occurrence construction for Inspect.
--
-- The context engine remains responsible for parsing instructions, matching
-- semantic effect rules, evaluating addresses, and replaying register state.
-- This module only turns an already-parsed instruction plus already-matched
-- effect specs into stable mnemonic/operand/memory-component occurrence rows.

local core = require("tracker_hud.core")
local memory_access = require("tracker_hud.low_level.memory_access")
local operand_metadata = require("tracker_hud.low_level.operand_metadata")

local M = {}


function M.resolve_register_name(
    adapter,
    register_name
)
    if not core.is_non_empty_string(
        register_name
    ) then
        return nil
    end

    local normalized =
        register_name:lower()

    for canonical, family in pairs(
        core.is_table(adapter)
            and adapter.register_families
            or {}
    ) do
        if core.is_table(family)
            and core.is_table(
                family.aliases
            )
            and core.is_table(
                family.aliases[normalized]
            )
        then
            return tostring(
                family.canonical
                or canonical
            ):lower()
        end
    end

    return normalized
end


local function target_id(
    adapter,
    register_name
)
    local canonical =
        M.resolve_register_name(
            adapter,
            register_name
        )

    if not canonical then
        return nil
    end

    return "register:" .. canonical
end


function M.normalize_role(role)
    if not core.is_non_empty_string(role) then
        return nil
    end

    local normalized = role:lower()

    if normalized:match("^destination") then
        return "destination"
    end

    if normalized:match("^source") then
        return "source"
    end

    return role
end


local function add_unique_string(
    result,
    seen,
    value
)
    if not core.is_non_empty_string(value)
        or seen[value]
    then
        return
    end

    seen[value] = true
    table.insert(result, value)
end


local function get_effect_operand_spec(
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


local function get_effect_target_operand_role(
    effect_spec,
    operand_index
)
    local operand_spec =
        get_effect_operand_spec(
            effect_spec,
            operand_index
        )

    return core.is_table(operand_spec)
        and M.normalize_role(
            operand_spec.role
        )
        or nil
end


function M.build_mnemonic(
    adapter,
    instruction,
    effect_specs
)
    if not core.is_table(instruction)
        or not core.is_table(
            instruction.mnemonic_range
        )
    then
        return nil
    end

    local target_ids = {}
    local seen_target_ids = {}
    local target_roles = {}

    for _, effect_spec in ipairs(
        effect_specs or {}
    ) do
        local effect =
            effect_spec.effect

        if core.is_table(effect) then
            if core.is_non_empty_string(
                effect.target_register
            ) then
                add_unique_string(
                    target_ids,
                    seen_target_ids,
                    target_id(
                        adapter,
                        effect.target_register
                    )
                )
            end

            local target_operand =
                tonumber(
                    effect.target_operand
                )

            local operand =
                target_operand
                and instruction.operands
                and instruction.operands[
                    target_operand
                ]
                or nil

            if core.is_table(operand)
                and operand.kind
                    == "register"
            then
                local id = target_id(
                    adapter,
                    operand.text
                )

                add_unique_string(
                    target_ids,
                    seen_target_ids,
                    id
                )

                local role =
                    get_effect_target_operand_role(
                        effect_spec,
                        target_operand
                    )

                if id and role then
                    target_roles[id] = role
                end
            end
        end
    end

    local range =
        instruction.mnemonic_range

    return {
        kind = "mnemonic",
        text = instruction.mnemonic,
        start_column =
            range.source_start_column,
        end_column =
            range.source_end_column,
        targets = {
            state = target_ids,
        },
        metadata = {
            mnemonic =
                instruction.mnemonic,
            inspection_kind =
                "operation",
            target_roles =
                target_roles,
            instruction_start_column =
                instruction
                    .source_start_column,
            instruction_end_column =
                instruction
                    .source_end_column,
        },
    }
end


local function role_is_source(role)
    if not core.is_non_empty_string(role) then
        return false
    end

    return role:lower():match("^source")
        ~= nil
end


local function role_is_destination(role)
    if not core.is_non_empty_string(role) then
        return false
    end

    return role:lower():match(
        "^destination"
    ) ~= nil
end


local function add_effect_target_ids(
    target_ids,
    seen_target_ids,
    adapter,
    instruction,
    effect_spec
)
    if not core.is_table(target_ids)
        or not core.is_table(
            seen_target_ids
        )
        or not core.is_table(effect_spec)
        or not core.is_table(
            effect_spec.effect
        )
    then
        return
    end

    local effect =
        effect_spec.effect

    if core.is_non_empty_string(
        effect.target_register
    ) then
        add_unique_string(
            target_ids,
            seen_target_ids,
            target_id(
                adapter,
                effect.target_register
            )
        )
    end

    local target_operand_index =
        tonumber(effect.target_operand)

    local target_operand =
        target_operand_index
        and instruction
        and instruction.operands
        and instruction.operands[
            target_operand_index
        ]
        or nil

    if core.is_table(target_operand)
        and target_operand.kind
            == "register"
    then
        add_unique_string(
            target_ids,
            seen_target_ids,
            target_id(
                adapter,
                target_operand.text
            )
        )
    end
end


local function get_effect_target_ids(
    adapter,
    instruction,
    effect_spec
)
    local target_ids = {}
    local seen_target_ids = {}

    add_effect_target_ids(
        target_ids,
        seen_target_ids,
        adapter,
        instruction,
        effect_spec
    )

    return target_ids
end


local function build_operand_metadata(
    adapter,
    instruction,
    operand,
    operand_index,
    operand_role,
    target_roles
)
    local metadata = {
        instruction_start_column =
            instruction
            and instruction
                .source_start_column
            or nil,
        instruction_end_column =
            instruction
            and instruction
                .source_end_column
            or nil,
        target_roles = target_roles,
    }

    if core.is_table(operand) then
        metadata.operand_kind =
            operand.kind
        metadata.operand_kind_label =
            operand_metadata.kind_label(
                operand.kind
            )
        metadata.operand_role =
            operand_role
        metadata.operand_role_label =
            operand_metadata.format_role_label(
                operand_role
            )
        metadata.operand_index =
            operand_index
    end

    if core.is_table(operand)
        and core.is_non_empty_string(
            operand.text
        )
    then
        metadata.source_operand_index =
            operand_index
        metadata.source_operand =
            operand.text
        metadata.source_operand_text =
            operand.text
        metadata.source_operand_kind =
            operand.kind
        metadata.source_kind =
            operand_metadata.kind_label(
                operand.kind
            )
        metadata.source_operand_role =
            operand_role
        metadata.source_role =
            operand_metadata.format_role_label(
                operand_role
            )
        metadata.value_source =
            operand_metadata.value_source_label(
                operand
            )
        metadata.value_source_kind =
            operand_metadata.kind_label(
                operand.kind
            )
        metadata.value_source_text =
            operand.text

        operand_metadata.append_memory_operand(
            metadata,
            operand
        )

        if operand.kind == "memory" then
            local access,
                access_metadata =
                memory_access.resolve(
                    adapter
                        and adapter
                            .memory_accesses,
                    instruction
                        and instruction
                            .mnemonic,
                    operand_index,
                    operand
                )

            metadata.memory_access_intent =
                access
            metadata.memory_access_declared =
                access_metadata.declared
            metadata.memory_access_ambiguous =
                access_metadata.ambiguous
            metadata.memory_access_rule_count =
                access_metadata.rule_count
            metadata.memory_execution_status =
                "not_observed"
        end
    end

    if core.is_table(operand)
        and operand.kind == "register"
    then
        metadata.register_name =
            M.resolve_register_name(
                adapter,
                operand.text
            )
        metadata.written_name =
            operand.text
    end

    return metadata
end


function M.build_operand(
    adapter,
    instruction,
    operand,
    operand_index,
    effect_specs
)
    if not core.is_table(operand)
        or not core.is_non_empty_string(
            operand.text
        )
    then
        return nil
    end

    local target_ids = {}
    local seen_target_ids = {}
    local target_roles = {}
    local own_register_id = nil
    local occurrence_role = nil
    local operand_role = nil

    if operand.kind == "register" then
        own_register_id = target_id(
            adapter,
            operand.text
        )

        add_unique_string(
            target_ids,
            seen_target_ids,
            own_register_id
        )
    end

    for _, effect_spec in ipairs(
        effect_specs or {}
    ) do
        local operand_spec =
            get_effect_operand_spec(
                effect_spec,
                operand_index
            )

        local raw_role =
            core.is_table(operand_spec)
            and operand_spec.role
            or nil

        local normalized_role =
            M.normalize_role(raw_role)

        if normalized_role then
            operand_role =
                operand_role
                or raw_role
                or normalized_role
            occurrence_role =
                occurrence_role
                or normalized_role
        end

        if own_register_id
            and normalized_role
        then
            target_roles[
                own_register_id
            ] = normalized_role
        end

        if role_is_source(
            raw_role
            or normalized_role
        )
        then
            for _, id in ipairs(
                get_effect_target_ids(
                    adapter,
                    instruction,
                    effect_spec
                )
            ) do
                add_unique_string(
                    target_ids,
                    seen_target_ids,
                    id
                )

                target_roles[id] =
                    "source"
            end
        elseif role_is_destination(
            raw_role
            or normalized_role
        )
        then
            for _, id in ipairs(
                get_effect_target_ids(
                    adapter,
                    instruction,
                    effect_spec
                )
            ) do
                if id == own_register_id then
                    target_roles[id] =
                        "destination"
                end
            end
        end
    end

    if #target_ids == 0 then
        return nil
    end

    return {
        kind = "operand",
        text = operand.text,
        start_column =
            operand.source_start_column,
        end_column =
            operand.source_end_column,
        operand_index = operand_index,
        role = occurrence_role,
        targets = {
            state = target_ids,
        },
        metadata =
            build_operand_metadata(
                adapter,
                instruction,
                operand,
                operand_index,
                operand_role,
                target_roles
            ),
    }
end


local function build_memory_component(
    adapter,
    instruction,
    operand,
    operand_index,
    component,
    effect_specs
)
    if not core.is_table(operand)
        or not core.is_table(component)
        or not core.is_non_empty_string(
            component.text
        )
    then
        return nil
    end

    local target_ids = {}
    local seen_target_ids = {}
    local target_roles = {}
    local component_register_id = nil
    local occurrence_role = nil
    local operand_role = nil

    if component.kind == "register" then
        component_register_id =
            target_id(
                adapter,
                component.text
            )

        add_unique_string(
            target_ids,
            seen_target_ids,
            component_register_id
        )

        if component_register_id then
            target_roles[
                component_register_id
            ] =
                component.role_label
                or operand_metadata
                    .format_role_label(
                        component.role
                    )
                or "address component"
        end
    end

    for _, effect_spec in ipairs(
        effect_specs or {}
    ) do
        local operand_spec =
            get_effect_operand_spec(
                effect_spec,
                operand_index
            )

        local raw_role =
            core.is_table(operand_spec)
            and operand_spec.role
            or nil

        local normalized_role =
            M.normalize_role(raw_role)

        if normalized_role then
            operand_role =
                operand_role
                or raw_role
                or normalized_role
            occurrence_role =
                occurrence_role
                or normalized_role
        end

        if role_is_source(
            raw_role
            or normalized_role
        )
        then
            for _, id in ipairs(
                get_effect_target_ids(
                    adapter,
                    instruction,
                    effect_spec
                )
            ) do
                add_unique_string(
                    target_ids,
                    seen_target_ids,
                    id
                )

                target_roles[id] =
                    "source"
            end
        end
    end

    if #target_ids == 0 then
        return nil
    end

    local metadata =
        build_operand_metadata(
            adapter,
            instruction,
            operand,
            operand_index,
            operand_role,
            target_roles
        )

    operand_metadata.append_memory_component(
        metadata,
        operand,
        component
    )

    return {
        kind = "memory_component",
        text = component.text,
        start_column =
            component.source_start_column,
        end_column =
            component.source_end_column,
        operand_index = operand_index,
        role = occurrence_role,
        targets = {
            state = target_ids,
        },
        metadata = metadata,
    }
end


function M.build_memory_components(
    adapter,
    instruction,
    operand,
    operand_index,
    effect_specs
)
    local occurrences = {}

    if not core.is_table(operand)
        or not core.is_table(
            operand.memory
        )
        or not core.is_table(
            operand.memory.components
        )
    then
        return occurrences
    end

    for _, component in ipairs(
        operand.memory.components
    ) do
        local occurrence =
            build_memory_component(
                adapter,
                instruction,
                operand,
                operand_index,
                component,
                effect_specs
            )

        if occurrence then
            table.insert(
                occurrences,
                occurrence
            )
        end
    end

    return occurrences
end


return M
