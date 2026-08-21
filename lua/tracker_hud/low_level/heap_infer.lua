-- lua/tracker_hud/low_level/heap_infer.lua
--
-- Generic heap/resource inference helpers.
--
-- This module consumes boundary facts that adapters already declared and the
-- boundary inferencer resolved. It does not parse source and does not render HUD
-- nodes. Display models decide how to label the returned entry specs.

local core = require("tracker_hud.core")

local M = {}


local function get_known_effect_table(boundary_effect, key)
    if not core.is_table(boundary_effect) then
        return nil
    end

    local known_effect = boundary_effect.known_effect or {}

    if core.is_table(known_effect[key]) then
        return known_effect[key]
    end

    return nil
end


local function find_write_register(boundary_effect, role)
    if not core.is_table(boundary_effect) then
        return nil
    end

    for _, write in ipairs(boundary_effect.writes or {}) do
        if core.is_table(write) and write.role == role then
            return write.register
        end
    end

    return nil
end


local function infer_kind(boundary_effect)
    if not core.is_table(boundary_effect) then
        return "unknown"
    end

    local produces = get_known_effect_table(boundary_effect, "produces")

    if core.is_table(produces)
        and core.is_non_empty_string(produces.kind)
    then
        return produces.kind
    end

    local consumes = get_known_effect_table(boundary_effect, "consumes")

    if core.is_table(consumes)
        and core.is_non_empty_string(consumes.kind)
    then
        return consumes.kind
    end

    if boundary_effect.name == "munmap" then
        return "heap_deallocation"
    end

    if boundary_effect.name == "brk" then
        return "heap_boundary"
    end

    return "unknown"
end


function M.from_boundary_effect(boundary_effect)
    if not core.is_table(boundary_effect) then
        return nil
    end

    if boundary_effect.category ~= "heap" then
        return nil
    end

    local produces = get_known_effect_table(boundary_effect, "produces")
    local consumes = get_known_effect_table(boundary_effect, "consumes")

    return {
        name = boundary_effect.name or boundary_effect.kind or "heap_effect",
        kind = infer_kind(boundary_effect),
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
    }
end


function M.collect_from_boundaries(context)
    local entries = {}

    if not core.is_table(context)
        or not core.is_table(context.boundary_effects)
    then
        return entries
    end

    for _, boundary_effect in ipairs(context.boundary_effects) do
        local entry = M.from_boundary_effect(boundary_effect)

        if entry then
            table.insert(entries, entry)
        end
    end

    return entries
end


return M
