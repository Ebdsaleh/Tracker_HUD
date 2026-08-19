-- lua/tracker_hud/sections/low_level/heap_tree.lua
--
-- Builds display-ready tree nodes from collected heap records.

local core = require("tracker_hud.core")
local lookup_tree = require("tracker_hud.sections.templates.lookup_tree")

local M = {}


local function add_detail(children, entry, detail_id, key, value, opts)
    lookup_tree.add_detail(
        children,
        entry,
        detail_id,
        key,
        value,
        opts
    )
end


local function build_heap_node(entry)
    if not core.is_table(entry) then
        return nil
    end

    local children = {}

    add_detail(children, entry, "kind", "kind", entry.kind or "unknown")
    add_detail(children, entry, "category", "category", entry.category or "heap")
    add_detail(children, entry, "effect_key", "effect key", entry.effect_key)
    add_detail(children, entry, "result", "result register", entry.result_register)
    add_detail(children, entry, "pointer", "pointer register", entry.pointer_register)
    add_detail(children, entry, "size", "size register", entry.size_register)
    add_detail(children, entry, "source", "source line", entry.source_line)

    local node = lookup_tree.new_node(entry, {
        kind = "heap_entry",
        label = entry.label or entry.name or "<heap entry>",
        children = children,
    })

    if node then
        node.heap_entry = entry
    end

    return node
end


function M.build_tree(entries)
    local root = {
        id = "heap:root",
        kind = "heap_root",
        label = "Heap",
        children = {},
    }

    for _, entry in ipairs(entries or {}) do
        local node = build_heap_node(entry)

        if node then
            table.insert(root.children, node)
        end
    end

    return root
end


return M
