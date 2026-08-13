-- lua/tracker_hud/sections/templates/lookup.lua
--
-- Lookup-style section template.
--
-- Lookup sections expose collections of discoverable/stateful entries.
-- Concrete sections such as Registers, Stack, and Heap derive from this
-- template and provide their own collection semantics.

local section = require("tracker_hud.section")

local M = section.new({
    category = "lookup",
    abstract = true,
})


function M.is_enabled(opts)
    opts = opts or {}

    return opts.enabled ~= false
end


function M.new_collection()
    return {}, {}
end


return M
