-- lua/tracker_hud/section_tree.lua
--
-- Generic section tree-node construction helpers.
--
-- Concrete section trees decide which nodes and details exist.
-- This module only provides the common HUD tree-node shape.

local core = require("tracker_hud.core")

local M = {}


function M.new_node(entry, opts)
    if not core.is_table(entry) then
        return nil
    end

    opts = opts or {}

    return {
        id = opts.id or entry.id,
        kind = opts.kind or entry.kind or "section_entry",
        label = opts.label or entry.label or entry.name or "<unknown>",

        source_line = entry.source_line,
        source_column = entry.source_column or 0,
        source_start_line = entry.source_start_line,
        source_start_column = entry.source_start_column or 0,
        source_end_line = entry.source_end_line,
        source_end_column = entry.source_end_column or entry.source_column or 0,

        children = opts.children or {},
    }
end


function M.new_detail_node(entry, detail_id, label)
    if not core.is_table(entry)
        or not core.is_non_empty_string(detail_id)
    then
        return nil
    end

    return M.new_node(entry, {
        id = entry.id .. ":" .. detail_id,
        kind = "detail",
        label = label,
        children = {},
    })
end


return M
