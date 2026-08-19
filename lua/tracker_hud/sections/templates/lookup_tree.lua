-- lua/tracker_hud/sections/templates/lookup_tree.lua
--
-- Lookup-style section tree template.
--
-- Provides the common tree-node primitives used by lookup-style sections.
-- Concrete trees decide which records and details they expose, while the
-- shared section tree blueprint assigns structured key/value semantics.

local section_tree = require("tracker_hud.section_tree")

local M = {}


function M.new_node(entry, opts)
    return section_tree.new_node(entry, opts)
end


function M.new_detail_node(entry, detail_id, label, opts)
    return section_tree.new_detail_node(entry, detail_id, label, opts)
end


function M.new_detail(entry, detail_id, key, value, opts)
    return section_tree.new_detail(entry, detail_id, key, value, opts)
end


function M.add_detail(children, entry, detail_id, key, value, opts)
    return section_tree.add_detail(children, entry, detail_id, key, value, opts)
end


return M
