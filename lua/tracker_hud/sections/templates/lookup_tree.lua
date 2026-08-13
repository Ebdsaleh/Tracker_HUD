-- lua/tracker_hud/sections/templates/lookup_tree.lua
--
-- Lookup-style section tree template.
--
-- Provides the common tree-node primitives used by lookup-style sections.
-- Concrete trees decide which details and children each entry exposes.

local section_tree = require("tracker_hud.section_tree")

local M = {}


function M.new_node(entry, opts)
    return section_tree.new_node(entry, opts)
end


function M.new_detail_node(entry, detail_id, label)
    return section_tree.new_detail_node(entry, detail_id, label)
end


return M
