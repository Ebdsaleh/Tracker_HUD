-- lua/tracker_hud/sections/low_level/stack_tree.lua
--
-- Builds display-ready tree nodes from collected stack records.

local core = require("tracker_hud.core")
local lookup_tree = require("tracker_hud.sections.templates.lookup_tree")

local M = {}


local function build_stack_detail_node(entry, detail_id, label)
    return lookup_tree.new_detail_node(
        entry,
        detail_id,
        label
    )
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

    local node = lookup_tree.new_node(entry, {
    kind = "stack",
    label = entry.label or tostring(entry.name or "<unknown>"),
    children = children,
    })

    if not node then
        return nil
    end

    node.stack_entry = entry

    return node

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
