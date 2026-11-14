-- lua/tracker_hud/low_level/boundary_register_context.lua
--
-- Pre-boundary register-context construction.
--
-- Boundary inference reads register facts as they existed immediately before
-- the boundary instruction. Register reduction itself remains owned by the
-- caller and is injected here to avoid a context-engine dependency cycle.

local core = require("tracker_hud.core")
local inference = require("tracker_hud.low_level.inference")

local M = {}


function M.collect(
    context,
    adapter,
    opts,
    instruction,
    deps
)
    opts = opts or {}
    deps = deps or {}

    if not core.is_table(context)
        or not core.is_table(adapter)
        or not core.is_table(opts)
        or not core.is_table(instruction)
        or (
            type(
                deps.collect_register_effects_before
            ) ~= "function"
            and type(
                deps.collect_register_effects
            ) ~= "function"
        )
    then
        return context
    end

    local limit_position =
        inference.normalize_position({
            line = instruction.source_start_line
                or instruction.source_line,
            column = instruction.source_start_column
                or instruction.source_column
                or 0,
        })

    if not limit_position then
        return context
    end

    local registers_before = nil

    if type(
        deps.collect_register_effects_before
    ) == "function"
    then
        registers_before =
            deps.collect_register_effects_before(
                limit_position
            )
    else
        registers_before =
            deps.collect_register_effects(
                context,
                adapter,
                {
                    bufnr = opts.bufnr,
                    root_node = opts.root_node,
                    limit_position =
                        limit_position,
                }
            )
    end

    return inference.with_section_facts(
        context,
        "registers",
        registers_before
    )
end


return M
