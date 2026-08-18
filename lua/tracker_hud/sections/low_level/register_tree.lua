-- lua/tracker_hud/sections/low_level/register_tree.lua
--
-- Builds display-ready tree nodes from collected register records.

local core = require("tracker_hud.core")
local lookup_tree = require("tracker_hud.sections.templates.lookup_tree")

local M = {}


local function build_register_detail_node(register, detail_id, label)
    return lookup_tree.new_detail_node(
        register,
        detail_id,
        label
    )
end


local function append_metadata_detail(children, register, detail_id, label, value)
    if value == nil then
        return
    end

    if type(value) == "string" and value == "" then
        return
    end

    table.insert(children, build_register_detail_node(
        register,
        detail_id,
        label .. ": " .. tostring(value)
    ))
end


local function occurrence_targets_register(occurrence, register_id)
    if not core.is_table(occurrence)
        or not core.is_non_empty_string(register_id)
        or not core.is_table(occurrence.targets)
        or not core.is_table(occurrence.targets.state)
    then
        return false
    end

    for _, target_id in ipairs(occurrence.targets.state) do
        if target_id == register_id then
            return true
        end
    end

    return false
end


local function get_selected_source_metadata(context, register_id)
    if not core.is_table(context)
        or not core.is_table(context.register_inspection)
        or context.register_inspection.active ~= true
        or context.register_inspection.exact_occurrence ~= true
    then
        return nil
    end

    local occurrence = context.register_inspection.occurrence

    if not occurrence_targets_register(occurrence, register_id) then
        return nil
    end

    local metadata = core.is_table(occurrence.metadata)
        and occurrence.metadata
        or nil

    if not core.is_table(metadata)
        or not core.is_non_empty_string(metadata.value_source)
    then
        return nil
    end

    local source_role = type(metadata.source_role) == "string"
        and metadata.source_role:lower()
        or nil

    if not source_role or not source_role:match("^source") then
        return nil
    end

    return metadata
end


local function append_source_details(children, register, context)
    local metadata = register.metadata or {}
    local selected_metadata = get_selected_source_metadata(
        context,
        register.id
    )

    if selected_metadata then
        append_metadata_detail(
            children,
            register,
            "selected-source",
            "selected source",
            selected_metadata.value_source
        )
    end

    append_metadata_detail(
        children,
        register,
        "value-source",
        "value source",
        metadata.value_source
    )

    append_metadata_detail(
        children,
        register,
        "source-operand",
        "source operand",
        metadata.source_operand_text or metadata.source_operand
    )

    append_metadata_detail(
        children,
        register,
        "source-kind",
        "source kind",
        metadata.source_kind
    )

    append_metadata_detail(
        children,
        register,
        "source-role",
        "source role",
        metadata.source_role
    )
end

local function alias_label(register, alias_name, alias_spec)
    local metadata = register.metadata or {}
    local written_alias = metadata.alias_written
    local label = alias_name

    if core.is_table(alias_spec) then
        if alias_spec.bits then
            label = label .. " : " .. tostring(alias_spec.bits) .. "-bit"
        end

        if alias_spec.offset then
            label = label .. " @" .. tostring(alias_spec.offset)
        end

        if core.is_non_empty_string(alias_spec.write_mode) then
            label = label .. " [" .. alias_spec.write_mode .. "]"
        end
    end

    if written_alias == alias_name and register.value ~= nil then
        label = label .. " = " .. tostring(register.value)
    end

    return label
end


local function build_alias_node(register, alias_name, alias_spec)
    if not core.is_table(register) or not core.is_non_empty_string(alias_name) then
        return nil
    end

    return {
        id = register.id .. ":alias:" .. alias_name,
        kind = "register_alias",
        label = alias_label(register, alias_name, alias_spec),

        -- Structured presentation facts. The HUD renderer can target each
        -- visible component without reparsing the label string.
        register = register,
        alias_name = alias_name,
        alias_spec = alias_spec,

        source_line = register.source_line,
        source_column = register.source_column or 0,
        source_start_line = register.source_start_line,
        source_start_column = register.source_start_column or 0,
        source_end_line = register.source_end_line,
        source_end_column = register.source_end_column or register.source_column or 0,
        children = {},
    }
end


local function append_alias_children(children, register)
    local metadata = register.metadata or {}
    local family = metadata.family

    if not core.is_table(family) or not core.is_table(family.aliases) then
        return
    end

    local order = family.alias_order or {}
    local used = {}

    for _, alias_name in ipairs(order) do
        local alias_spec = family.aliases[alias_name]
        local alias_node = build_alias_node(register, alias_name, alias_spec)

        if alias_node then
            table.insert(children, alias_node)
            used[alias_name] = true
        end
    end

    for alias_name, alias_spec in pairs(family.aliases) do
        if not used[alias_name] then
            local alias_node = build_alias_node(register, alias_name, alias_spec)

            if alias_node then
                table.insert(children, alias_node)
            end
        end
    end
end


local function get_inspection_role(context, register_id)
    if not core.is_table(context)
        or not core.is_table(context.register_inspection)
        or context.register_inspection.active ~= true
        or not core.is_table(context.register_inspection.roles)
    then
        return nil
    end

    return context.register_inspection.roles[register_id]
end


local function build_register_node(register, context)
    if not core.is_table(register) then
        return nil
    end

    local children = {}

    append_alias_children(children, register)

    table.insert(children, build_register_detail_node(
        register,
        "kind",
        "kind: " .. tostring(register.kind or "<unknown>")
    ))

    local inspection_role = get_inspection_role(
        context,
        register.id
    )

    table.insert(children, build_register_detail_node(
        register,
        "role",
        "role: " .. tostring(
            inspection_role
            or register.role
            or "<unknown>"
        )
    ))

    table.insert(children, build_register_detail_node(
        register,
        "source",
        "source: " .. tostring(register.source or "<unknown>")
    ))

    append_source_details(children, register, context)

    local metadata = register.metadata or {}

    if core.is_non_empty_string(metadata.raw_name)
        and metadata.raw_name ~= register.name
    then
        table.insert(children, build_register_detail_node(
            register,
            "raw-name",
            "written alias: " .. metadata.raw_name
        ))
    end

    local node = lookup_tree.new_node(register, {
        kind = "register",
        label = register.label or tostring(register.name or "<unknown>"),
        children = children,
    })

    if not node then
        return nil
    end

    node.register = register

    return node

end


local function get_register_group(register)
    if not core.is_table(register)
        or not core.is_table(register.metadata)
        or not core.is_table(register.metadata.presentation_group)
    then
        return nil
    end

    return register.metadata.presentation_group
end


local function build_group_node(group)
    return {
        id = "register-group:" .. tostring(group.id),
        kind = "register_group",
        label = tostring(group.label or group.id or "Registers"),
        default_expanded = group.default_expanded ~= false,
        children = {},
    }
end


function M.build(registers, context)
    local nodes = {}

    local active_group_id = nil
    local active_group_node = nil

    for _, register in ipairs(registers or {}) do
        local node = build_register_node(register, context)

        if node then
            local group = get_register_group(register)

            if group then
                local group_id = tostring(group.id)

                if active_group_id ~= group_id then
                    active_group_id = group_id
                    active_group_node = build_group_node(group)

                    table.insert(nodes, active_group_node)
                end

                table.insert(active_group_node.children, node)
            else
                active_group_id = nil
                active_group_node = nil

                table.insert(nodes, node)
            end
        end
    end

    return nodes
end

return M
