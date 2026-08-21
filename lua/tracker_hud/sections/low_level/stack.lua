-- lua/tracker_hud/sections/low_level/stack.lua
--
-- Stack discovery / collection.
--
-- Static stack entries come from adapters / variant specs.
-- Dynamic stack facts come from declarative stack effects interpreted by
-- the context engine.

local core = require("tracker_hud.core")
local section = require("tracker_hud.section")
local lookup = require("tracker_hud.sections.templates.lookup")
local context_engine = require("tracker_hud.context_engine")
local stack_model = require("tracker_hud.sections.low_level.stack_model")


local M = section.extend(lookup, {
    id = "stack",
    label = "Stack",
    abstract = false,
})


local function collect_engine_stack_effects(entries, seen, context, adapter, opts)
    if not core.is_table(adapter) then
        return
    end

    local dynamic_entries = context_engine.collect_stack_effects(
        context,
        adapter,
        opts
    )

    if not core.is_table(dynamic_entries) then
        return
    end

    for _, entry_spec in ipairs(dynamic_entries) do
        if core.is_table(entry_spec) then
            stack_model.add(entries, seen, {
                name = entry_spec.name,
                kind = entry_spec.kind,
                value = entry_spec.value,
                resolved = entry_spec.resolved,
                destination = entry_spec.destination,
                destination_register = entry_spec.destination_register,
                offset = entry_spec.offset,
                offset_delta = entry_spec.offset_delta,
                size = entry_spec.size,
                stack_depth_before = entry_spec.stack_depth_before,
                stack_depth_after = entry_spec.stack_depth_after,
                stack_depth_delta = entry_spec.stack_depth_delta,
                stack_depth_label = entry_spec.stack_depth_label,
                role = entry_spec.role,
                source = entry_spec.source or "analysis",

                source_line = entry_spec.source_line,
                source_column = entry_spec.source_column,
                source_start_line = entry_spec.source_start_line,
                source_start_column = entry_spec.source_start_column,
                source_end_line = entry_spec.source_end_line,
                source_end_column = entry_spec.source_end_column,

                metadata = entry_spec.metadata or {},
            })
        end
    end
end


local function collect_adapter_stack_entries(entries, seen, context, adapter)
    if not core.is_table(adapter) or not core.is_table(adapter.stack) then
        return
    end

    local static_entries = adapter.stack.static or {}

    for _, entry_spec in ipairs(static_entries) do
        if core.is_table(entry_spec) then
            stack_model.add(entries, seen, {
                name = entry_spec.name,
                kind = entry_spec.kind,
                value = entry_spec.value,
                resolved = entry_spec.resolved,
                destination = entry_spec.destination,
                destination_register = entry_spec.destination_register,
                offset = entry_spec.offset,
                size = entry_spec.size,
                role = entry_spec.role,
                source = entry_spec.source or "adapter",
                metadata = {
                    adapter = adapter.name,
                    context = context,
                },
            })
        end
    end
end


function M.collect(context, adapter, opts)
    local entries, seen = M.new_collection()

    opts = opts or {}

    if not M.is_enabled(opts) then
        return entries
    end

    -- Dynamic facts go first so source-derived entries are shown alongside
    -- static architecture entries.
    collect_engine_stack_effects(entries, seen, context, adapter, opts)
    collect_adapter_stack_entries(entries, seen, context, adapter)

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
