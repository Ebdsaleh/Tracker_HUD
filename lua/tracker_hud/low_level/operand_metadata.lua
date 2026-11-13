-- lua/tracker_hud/low_level/operand_metadata.lua
--
-- Shared source-operand metadata formatting.
--
-- This module does not parse source or infer runtime state. It only converts
-- already-normalized operand structure into the stable descriptive metadata
-- consumed by register facts and Inspect occurrences.

local core = require("tracker_hud.core")

local M = {}


function M.format_role_label(role)
    if not core.is_non_empty_string(role) then
        return nil
    end

    return role:gsub("_", " ")
end


function M.kind_label(kind)
    if not core.is_non_empty_string(kind) then
        return nil
    end

    if kind == "integer" then
        return "immediate"
    end

    return kind:gsub("_", " ")
end


function M.value_source_label(operand)
    if not core.is_table(operand)
        or not core.is_non_empty_string(operand.text)
    then
        return nil
    end

    local kind_label = M.kind_label(
        operand.kind
    )

    if core.is_non_empty_string(kind_label) then
        return kind_label
            .. " "
            .. operand.text
    end

    return operand.text
end


function M.memory_size_label(size)
    if not core.is_table(size) then
        return nil
    end

    local label = size.label or size.prefix

    if size.bits then
        return tostring(label or "memory")
            .. " ("
            .. tostring(size.bits)
            .. "-bit)"
    end

    return label
end


function M.append_memory_operand(
    metadata,
    operand
)
    if not core.is_table(metadata)
        or not core.is_table(operand)
        or not core.is_table(operand.memory)
    then
        return
    end

    local memory = operand.memory

    metadata.containing_operand = operand.text
    metadata.containing_operand_kind =
        "memory"
    metadata.containing_operand_kind_label =
        "memory operand"
    metadata.memory_address =
        memory.address_text
    metadata.memory_address_kind =
        memory.address_kind
    metadata.memory_size =
        M.memory_size_label(memory.size)

    if core.is_table(memory.size) then
        metadata.memory_size_bits =
            memory.size.bits
        metadata.memory_size_prefix =
            memory.size.prefix
    end

    if core.is_table(memory.normalized) then
        local address = memory.normalized

        metadata.memory_address_structured =
            address
        metadata.memory_address_mode =
            address.address_mode
        metadata.memory_address_size_bits =
            address.address_size_bits
        metadata.memory_address_size_status =
            address.address_size_status
        metadata.memory_address_size_source =
            address.address_size_source
        metadata.memory_address_size_reason =
            address.address_size_reason
        metadata.memory_base_register =
            address.base
            and address.base.name
            or nil
        metadata.memory_index_register =
            address.index
            and address.index.name
            or nil
        metadata.memory_scale =
            address.scale
            and address.scale.value
            or nil
        metadata.memory_displacement =
            address.displacement
            and address.displacement.value
            or nil
        metadata.memory_symbol =
            address.symbol
            and address.symbol.name
            or nil
    end

    local component_labels = {}

    for _, component in ipairs(
        memory.components or {}
    ) do
        if core.is_table(component)
            and core.is_non_empty_string(
                component.text
            )
        then
            table.insert(
                component_labels,
                tostring(
                    component.role_label
                    or component.role
                    or "component"
                )
                    .. ": "
                    .. component.text
            )
        end
    end

    if #component_labels > 0 then
        metadata.memory_address_components =
            table.concat(
                component_labels,
                ", "
            )
    end
end


function M.append_memory_component(
    metadata,
    operand,
    component
)
    if not core.is_table(metadata)
        or not core.is_table(component)
    then
        return
    end

    M.append_memory_operand(
        metadata,
        operand
    )

    metadata.focused_token =
        component.text
    metadata.focused_token_kind =
        M.kind_label(component.kind)
    metadata.address_role =
        component.role_label
        or M.format_role_label(
            component.role
        )
    metadata.address_role_id =
        component.structural_role
        or component.role
    metadata.address_display_role_id =
        component.role

    if core.is_non_empty_string(
        operand and operand.text
    ) then
        metadata.value_source =
            M.value_source_label(operand)
        metadata.value_source_text =
            operand.text
        metadata.value_source_kind =
            M.kind_label(operand.kind)
    end
end


return M
