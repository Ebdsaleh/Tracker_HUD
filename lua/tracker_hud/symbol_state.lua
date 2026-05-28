-- lua/tracker_hud/symbol_state.lua
--
-- Language-agnostic symbol state enrichment.
--
-- This module enriches collected scope members with normalized type/value
-- display information. Language-specific meaning should come from adapters,
-- not from hardcoded Tree-sitter node names here.

local core = require("tracker_hud.core")

local M = {}

local function make_type_label(member)
    if core.is_table(member) and core.is_non_empty_string(member.type_label) then
        return member.type_label
    end

    return "<unknown>"
end

local function make_value_kind(member)
    if core.is_table(member) and core.is_non_empty_string(member.value_kind) then
        return member.value_kind
    end

    return "unknown"
end

local function make_single_line_text(text)
    if not core.is_non_empty_string(text) then
        return nil
    end

    return text
        :gsub("\r\n", "\\n")
        :gsub("\n", "\\n")
        :gsub("\r", "\\n")
end

local function make_value_label(member)
    if not core.is_table(member) then
        return "<unknown>"
    end

    if member.value_kind == "structural" or member.value_kind == "callable" then
        local type_label = member.type_label or member.value_kind

        if member.value_start_line and member.value_end_line then
            return type_label
                .. " ["
                .. tostring(member.value_start_line)
                .. " - "
                .. tostring(member.value_end_line)
                .. "]"
        end

        return type_label
    end

    local value_text = make_single_line_text(member.value_text)

    if core.is_non_empty_string(value_text) then
        return value_text
    end

    return "<unknown>"
end


local function make_member_state(member)
    return {
        member_id = member and member.id or nil,
        name = member and member.name or nil,
        kind = member and member.kind or nil,

        type_label = make_type_label(member),
        value_label = make_value_label(member),
        value_kind = make_value_kind(member),

        source_line = member and member.line or nil,
        value_node_type = member and member.value_node_type or nil,
        value_start_line = member and member.value_start_line or nil,
        value_end_line = member and member.value_end_line or nil,
    }
end

function M.get_member_state(member, _context)
    if not core.is_table(member) then
        return make_member_state(nil)
    end

    return make_member_state(member)
end

function M.enrich_member(member, context)
    if not core.is_table(member) then
        return member
    end

    local state = M.get_member_state(member, context)

    member.symbol_state = state
    member.type_label = state.type_label
    member.value_label = state.value_label
    member.value_kind = state.value_kind

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
