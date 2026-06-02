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


local function build_register_node(register)
    if not core.is_table(register) then
        return nil
    end

    local children = {}

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
