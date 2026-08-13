-- lua/tracker_hud/sections/low_level/heap.lua
--
-- Heap discovery / collection.
--
-- Heap entries are derived from generic boundary effects for now.
-- Later this can also consume C malloc/free, C++ new/delete, Rust ownership/drop,
-- and other adapter-provided heap/resource effects.

local core = require("tracker_hud.core")
local section = require("tracker_hud.section")
local lookup = require("tracker_hud.sections.templates.lookup")
local heap_model = require("tracker_hud.sections.low_level.heap_model")

local M = section.extend(lookup, {
    id = "heap",
    label = "Heap",
    abstract = false,
})



local function find_write_register(boundary_effect, role)
    for _, write in ipairs(boundary_effect.writes or {}) do
        if core.is_table(write) and write.role == role then
            return write.register
        end
    end

    return nil
end


local function get_known_effect_table(boundary_effect, key)
    local known_effect = boundary_effect.known_effect or {}

    if core.is_table(known_effect[key]) then
        return known_effect[key]
    end

    return nil
end


local function add_boundary_heap_effect(entries, seen, boundary_effect)
    if not core.is_table(boundary_effect) then
        return nil
    end

    if boundary_effect.category ~= "heap" then
        return nil
    end

    local produces = get_known_effect_table(boundary_effect, "produces")
    local consumes = get_known_effect_table(boundary_effect, "consumes")

    return heap_model.add(entries, seen, {
        name = boundary_effect.name or boundary_effect.kind or "heap_effect",
        kind = heap_model.kind_from_boundary_effect(boundary_effect),
        category = boundary_effect.category,
        effect_key = boundary_effect.effect_key,

        result_register = produces and produces.result_register
            or find_write_register(boundary_effect, "return"),

        pointer_register = consumes and consumes.pointer_register,
        size_register = consumes and consumes.size_register,

        role = boundary_effect.kind,
        source = boundary_effect.source or "boundary_effect",

        reads = boundary_effect.reads or {},
        writes = boundary_effect.writes or {},

        source_line = boundary_effect.source_line,
        source_column = boundary_effect.source_column,
        source_start_line = boundary_effect.source_start_line,
        source_start_column = boundary_effect.source_start_column,
        source_end_line = boundary_effect.source_end_line,
        source_end_column = boundary_effect.source_end_column,

        metadata = {
            boundary_effect = boundary_effect,
        },
    })
end


local function collect_boundary_heap_effects(entries, seen, context)
    if not core.is_table(context) or not core.is_table(context.boundary_effects) then
        return
    end

    for _, boundary_effect in ipairs(context.boundary_effects) do
        add_boundary_heap_effect(entries, seen, boundary_effect)
    end
end


function M.collect(context, _adapter, opts)
    local entries, seen = M.new_collection()

    opts = opts or {}

    if not M.is_enabled(opts) then
        return entries
    end

    collect_boundary_heap_effects(entries, seen, context)

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
