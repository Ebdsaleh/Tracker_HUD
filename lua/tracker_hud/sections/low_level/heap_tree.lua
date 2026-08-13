-- lua/tracker_hud/sections/low_level/heap_tree.lua
--
-- Builds display-ready tree nodes from collected heap records.

local core = require("tracker_hud.core")
local lookup_tree = require("tracker_hud.sections.templates.lookup_tree")

local M = {}


local function build_heap_detail_node(entry, detail_id, label)
    return lookup_tree.new_detail_node(
        entry,
        detail_id,
        label
    )
end


local function add_detail(children, entry, detail_id, label)
    if label == nil then
        return
    end

    local node = build_heap_detail_node(entry, detail_id, label)

    if node then
        table.insert(children, node)
    end
end


local function build_heap_node(entry)
    if not core.is_table(entry) then
        return nil
    end

    local children = {}

    add_detail(children, entry, "kind", "kind: " .. tostring(entry.kind or "unknown"))
    add_detail(children, entry, "category", "category: " .. tostring(entry.category or "heap"))

    if entry.effect_key ~= nil then
        add_detail(children, entry, "effect_key", "effect key: " .. tostring(entry.effect_key))
    end

    if entry.result_register ~= nil then
        add_detail(children, entry, "result", "result register: " .. tostring(entry.result_register))
    end

    if entry.pointer_register ~= nil then
        add_detail(children, entry, "pointer", "pointer register: " .. tostring(entry.pointer_register))
    end

    if entry.size_register ~= nil then
        add_detail(children, entry, "size", "size register: " .. tostring(entry.size_register))
    end

    if entry.source_line ~= nil then
        add_detail(children, entry, "source", "source line: " .. tostring(entry.source_line))
    end

    return lookup_tree.new_node(entry, {
        kind = "heap_entry",
        label = entry.label or entry.name or "<heap entry>",
        children = children,
    })

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
