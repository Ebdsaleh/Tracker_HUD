-- lua/tracker_hud/low_level/boundary_effect_apply.lua
--
-- Boundary-effect matching, fact construction, and append semantics.
--
-- Syntax-derived mnemonic policy is injected by the caller. Boundary read,
-- write, not-preserved, and known-effect inference remains owned by
-- boundary_infer.

local core = require("tracker_hud.core")
local boundary_infer =
    require("tracker_hud.low_level.boundary_infer")

local M = {}


function M.matches(
    instruction,
    effect_spec,
    opts
)
    opts = opts or {}

    if not core.is_table(instruction)
        or not core.is_table(effect_spec)
        or type(opts.get_mnemonic)
            ~= "function"
        or type(opts.normalize_mnemonic)
            ~= "function"
    then
        return false
    end

    local expected_mnemonic =
        opts.get_mnemonic(
            effect_spec
        )

    if expected_mnemonic
        and opts.normalize_mnemonic(
            instruction.mnemonic
        ) ~= expected_mnemonic
    then
        return false
    end

    return true
end


function M.build(
    context,
    adapter,
    instruction,
    effect_spec,
    phase_contexts
)
    return boundary_infer.make_effect_fact(
        context,
        adapter,
        instruction,
        effect_spec,
        phase_contexts
    )
end


function M.apply(
    facts,
    context,
    adapter,
    instruction,
    effect_spec,
    phase_contexts,
    opts
)
    opts = opts or {}

    if not core.is_table(facts)
        or not core.is_table(context)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return
    end

    if not M.matches(
        instruction,
        effect_spec,
        opts
    )
    then
        return
    end

    local fact =
        M.build(
            context,
            adapter,
            instruction,
            effect_spec,
            phase_contexts
        )

    if fact then
        table.insert(facts, fact)
    end
end


return M
