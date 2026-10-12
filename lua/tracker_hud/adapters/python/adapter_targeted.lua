-- lua/tracker_hud/adapters/python/adapter_targeted.lua
--
-- Thin Python adapter wrapper.
--
-- The visibility-first adapter is the active implementation. This wrapper keeps
-- that implementation intact, adds a stable high-level target identity, and
-- applies Python-specific HUD scope policy.
--
-- Tracker_HUD uses scopes to answer two related questions:
--
--     1. Where am I structurally in the source layout?
--     2. Which region owns the currently visible member tree?
--
-- Python if/for/try blocks do not introduce a new Python local variable
-- namespace, but they are absolutely meaningful structural locations for the
-- HUD. Keep them as structural scopes so nested layout remains visible and
-- inspectable, while member ownership remains anchored to module/class/function.

local M = require("tracker_hud.adapters.python.adapter_visible")

local function mark_structural_member_scope(node_type)
    local specs = M.construct_specs or {}
    local spec = specs[node_type]

    if type(spec) ~= "table" then
        return
    end

    spec.scope = {
        kind = "structural",
        affects_visibility = true,
        owns_members = true,
    }
end

mark_structural_member_scope("if_statement")
mark_structural_member_scope("for_statement")
mark_structural_member_scope("try_statement")

-- Member ownership and structural nesting are intentionally separate.
--
-- Scope still shows if/for/try nesting. Scope Members is anchored to the
-- nearest Python region that owns names/members.
M.member_scope_construct_kinds = {
    module = true,
    class = true,
    function = true,
}

M.active_targets = {
    architecture = "python",
    platform = "python",
    abi = "python-runtime",
    syntax = "python",
    mode = "dynamic",
}

return M
