-- lua/tracker_hud/stack_tree.lua
--
-- Builds display-ready tree nodes from collected stack records.

local core = require("tracker_hud.core")

local M = {}


local function build_stack_detail_node(entry, detail_id, label)
    if not core.is_table(entry) then
        return nil
    end

    return {
        id = entry.id .. ":" .. detail_id,
        kind = "detail",
        label = label,

        source_line = entry.source_line,
        source_column = entry.source_column or 0,
        source_start_line = entry.source_start_line,
        source_start_column = entry.source_start_column or 0,
        source_end_line = entry.source_end_line,
        source_end_column = entry.source_end_column or entry.source_column or 0,

        children = {},
    }
end


local function build_stack_node(entry)
    if not core.is_table(entry) then
        return nil
    end

    local children = {}

    table.insert(children, build_stack_detail_node(
        entry,
        "kind",
        "kind: " .. tostring(entry.kind or "<unknown>")
    ))

    table.insert(children, build_stack_detail_node(
        entry,
        "offset",
        "offset: " .. tostring(entry.offset or "<unknown>")
    ))

    table.insert(children, build_stack_detail_node(
        entry,
        "size",
        "size: " .. tostring(entry.size or "<unknown>")
    ))

    table.insert(children, build_stack_detail_node(
        entry,
        "role",
        "role: " .. tostring(entry.role or "<unknown>")
    ))

    table.insert(children, build_stack_detail_node(
        entry,
        "source",
        "source: " .. tostring(entry.source or "<unknown>")
    ))

    return {
        id = entry.id,
        kind = "stack",
        label = entry.label or tostring(entry.name or "<unknown>"),

        source_line = entry.source_line,
        source_column = entry.source_column or 0,
        source_start_line = entry.source_start_line,
        source_start_column = entry.source_start_column or 0,
        source_end_line = entry.source_end_line,
        source_end_column = entry.source_end_column or entry.source_column or 0,

        stack_entry = entry,
        children = children,
    }
end


function M.build(entries, _context)
    local nodes = {}

    for _, entry in ipairs(entries or {}) do
        local node = build_stack_node(entry)

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
