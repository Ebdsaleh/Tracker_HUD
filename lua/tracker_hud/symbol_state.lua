-- lua/tracker_hud/symbol_state.lua
--
-- Language-agnostic symbol state enrichment.
--
-- This module is intended to become the reflection/state layer that can enrich
-- scope members with type/value information without making scope_members.lua or
-- scope_member_tree.lua responsible for value analysis.

local core = require("tracker_hud.core")

local M = {}

local function make_unknown_state(member)
    return {
        member_id = member and member.id or nil,
        name = member and member.name or nil,
        kind = member and member.kind or nil,
        type_label = "<unknown>",
        value_label = "<unknown>",
        source_line = member and member.line or nil,
    }
end

function M.get_member_state(member, _context)
    if not core.is_table(member) then
        return make_unknown_state(nil)
    end

    return make_unknown_state(member)
end

function M.enrich_member(member, context)
    if not core.is_table(member) then
        return member
    end

    local state = M.get_member_state(member, context)

    member.symbol_state = state
    member.type_label = state.type_label
    member.value_label = state.value_label

    return member
end

function M.enrich_members(members, context)
    local enriched = {}

    for _, member in ipairs(members or {}) do
        if core.is_table(member) then
            table.insert(enriched, M.enrich_member(member, context))
        end
    end

    return enriched
end

return M
