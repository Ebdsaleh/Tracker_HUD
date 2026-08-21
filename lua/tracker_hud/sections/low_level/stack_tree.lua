-- lua/tracker_hud/sections/low_level/stack_tree.lua
--
-- Builds display-ready tree nodes from collected stack records.

local core = require("tracker_hud.core")
local lookup_tree = require("tracker_hud.sections.templates.lookup_tree")

local M = {}


local function build_stack_node(entry)
    if not core.is_table(entry) then
        return nil
    end

    local children = {}

    lookup_tree.add_detail(children, entry, "kind", "kind", entry.kind or "<unknown>")

    if entry.value ~= nil then
        lookup_tree.add_detail(children, entry, "value", "value", entry.value)
    elseif entry.resolved == false then
        lookup_tree.add_detail(children, entry, "value", "value", "<unknown>")
    end

    if core.is_non_empty_string(entry.destination_register) then
        lookup_tree.add_detail(
            children,
            entry,
            "destination",
            "destination",
            entry.destination_register
        )
    end

    lookup_tree.add_detail(children, entry, "offset", "offset", entry.offset or "<unknown>")
    lookup_tree.add_detail(children, entry, "size", "size", entry.size or "<unknown>")

    if entry.stack_depth_before ~= nil or entry.stack_depth_after ~= nil then
        local before = entry.stack_depth_before ~= nil
            and tostring(entry.stack_depth_before)
            or "<unknown>"
        local after = entry.stack_depth_after ~= nil
            and tostring(entry.stack_depth_after)
            or "<unknown>"

        lookup_tree.add_detail(
            children,
            entry,
            "stack_depth",
            "stack depth",
            before .. " -> " .. after
        )
    end

    if entry.stack_depth_delta ~= nil then
        lookup_tree.add_detail(
            children,
            entry,
            "stack_delta",
            "stack delta",
            entry.stack_depth_delta
        )
    end

    local metadata = core.is_table(entry.metadata) and entry.metadata or {}

    if metadata.value_source_kind ~= nil or metadata.value_source_text ~= nil then
        local value_source = tostring(metadata.value_source_kind or "value")

        if metadata.value_source_text ~= nil then
            value_source = value_source .. " " .. tostring(metadata.value_source_text)
        end

        lookup_tree.add_detail(
            children,
            entry,
            "value_source",
            "value source",
            value_source
        )
    end

    lookup_tree.add_detail(children, entry, "role", "role", entry.role or "<unknown>")

    if entry.resolved == false then
        lookup_tree.add_detail(children, entry, "resolved", "resolved", "false")
    end

    lookup_tree.add_detail(children, entry, "source", "source", entry.source or "<unknown>")

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
