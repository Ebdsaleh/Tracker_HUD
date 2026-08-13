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


local function build_register_node(register)
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

    table.insert(children, build_register_detail_node(
        register,
        "role",
        "role: " .. tostring(register.role or "<unknown>")
    ))

    table.insert(children, build_register_detail_node(
        register,
        "source",
        "source: " .. tostring(register.source or "<unknown>")
    ))

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


function M.build(registers, _context)
    local nodes = {}

    local active_group_id = nil
    local active_group_node = nil

    for _, register in ipairs(registers or {}) do
        local node = build_register_node(register)

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
