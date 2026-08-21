-- lua/tracker_hud/sections/low_level/heap.lua
--
-- Heap discovery / collection.
--
-- Heap entries are derived from low-level heap inference facts for now.
-- Later this can also consume C malloc/free, C++ new/delete, Rust ownership/drop,
-- and other adapter-provided heap/resource effects.

local core = require("tracker_hud.core")
local section = require("tracker_hud.section")
local lookup = require("tracker_hud.sections.templates.lookup")
local heap_infer = require("tracker_hud.low_level.heap_infer")
local heap_model = require("tracker_hud.sections.low_level.heap_model")

local M = section.extend(lookup, {
    id = "heap",
    label = "Heap",
    abstract = false,
})


local function collect_inferred_heap_entries(entries, seen, context)
    local inferred_entries = heap_infer.collect_from_boundaries(context)

    for _, entry_spec in ipairs(inferred_entries) do
        heap_model.add(entries, seen, entry_spec)
    end
end


function M.collect(context, _adapter, opts)
    local entries, seen = M.new_collection()

    opts = opts or {}

    if not M.is_enabled(opts) then
        return entries
    end

    collect_inferred_heap_entries(entries, seen, context)

    table.sort(entries, function(left, right)
        local left_line = left.source_line
        local right_line = right.source_line

        if left_line and right_line then
            if left_line == right_line then
                return tostring(left.label or left.name or "") < tostring(right.label or right.name or "")
            end

            return left_line < right_line
        end

        if left_line then
            return true
        end

        if right_line then
            return false
        end

        return tostring(left.label or left.name or "") < tostring(right.label or right.name or "")
    end)

    return entries
end


return M
