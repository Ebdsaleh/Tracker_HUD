-- lua/tracker_hud/register_tree.lua
--
-- Builds display-ready tree nodes from collected register records.

local core = require("tracker_hud.core")

local M = {}


local function build_register_detail_node(register, detail_id, label)
    if not core.is_table(register) then
        return nil
    end

    return {
        id = register.id .. ":" .. detail_id,
        kind = "detail",
        label = label,
        source_line = register.source_line,
        source_column = register.source_column or 0,
        source_start_line = register.source_start_line,
        source_start_column = register.source_start_column or 0,
        source_end_line = register.source_end_line,
        source_end_column = register.source_end_column or register.source_column or 0,
        children = {},
    }
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

    return {
        id = register.id,
        kind = "register",
        label = register.label or tostring(register.name or "<unknown>"),

        source_line = register.source_line,
        source_column = register.source_column or 0,
        source_start_line = register.source_start_line,
        source_start_column = register.source_start_column or 0,
        source_end_line = register.source_end_line,
        source_end_column = register.source_end_column or register.source_column or 0,

        register = register,
        children = children,
    }
end


function M.build(registers, _context)
    local nodes = {}

    for _, register in ipairs(registers or {}) do
        local node = build_register_node(register)

        if node then
            table.insert(nodes, node)
        end
    end

    table.sort(nodes, function(left, right)
        return tostring(left.label or "") < tostring(right.label or "")
    end)

    return nodes
end


return M
