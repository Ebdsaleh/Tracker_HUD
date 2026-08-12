-- lua/tracker_hud/section_layout.lua
--
-- Generic adapter-backed HUD section ordering.
--
-- This module knows nothing about Registers, Stack, Heap, Events, x86, ARM,
-- Rust, or any other adapter/domain-specific section meaning.
--
-- Adapters describe the desired section workflow through:
--
--     adapter.presentation.sections.order
--
-- The actual section implementations remain elsewhere.
-- This module only resolves display order.
--
-- Later, when adapter-defined custom sections are introduced, this same
-- resolver can order those section IDs without needing architecture-specific
-- logic here.

local core = require("tracker_hud.core")

local M = {}


-- Transitional fallback matching Tracker_HUD's current section layout.
--
-- This intentionally preserves existing behaviour while the generic custom
-- section architecture is introduced in stages.
--
-- Once adapter-owned sections are fully migrated, the eventual core-only
-- fallback can become:
--
--     scope
--     scope_members
--     warnings
--
local fallback_order = {
    "scope",
    "scope_members",
    "registers",
    "events",
    "stack",
    "heap",
    "warnings",
}


local function copy_order(order)
    local result = {}

    for _, section_id in ipairs(order or {}) do
        table.insert(result, section_id)
    end

    return result
end


local function normalize_order(order)
    if not core.is_table(order) then
        return nil
    end

    local result = {}
    local seen = {}

    for _, section_id in ipairs(order) do
        if core.is_non_empty_string(section_id)
            and not seen[section_id]
        then
            seen[section_id] = true
            table.insert(result, section_id)
        end
    end

    if #result == 0 then
        return nil
    end

    return result
end


function M.get_fallback_order()
    return copy_order(fallback_order)
end


function M.resolve(adapter)
    if not core.is_table(adapter)
        or not core.is_table(adapter.presentation)
        or not core.is_table(adapter.presentation.sections)
    then
        return M.get_fallback_order()
    end

    local resolved = normalize_order(
        adapter.presentation.sections.order
    )

    if not resolved then
        return M.get_fallback_order()
    end

    return resolved
end


return M
