-- lua/tracker_hud/sections/templates/lookup_model.lua
--
-- Lookup-style section model template.
--
-- Provides common record construction and deduplicated insertion for
-- lookup-style sections. Concrete models add their own fields and labels.

local section_model = require("tracker_hud.section_model")

local M = {}


function M.new(opts, default_id_prefix)
    return section_model.new(opts, default_id_prefix)
end


function M.add(entries, seen, entry)
    return section_model.add(entries, seen, entry)
end


return M
