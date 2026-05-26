-- lua/tracker_hud/symbol_state.lua
--
-- Language-agnostic symbol state enrichment.
--
-- This module is intended to become the reflection/state layer that can enrich
-- scope members with type/value information without making scope_members.lua or
-- scope_member_tree.lua responsible for value analysis.

local core = require("tracker_hud.core")

local M = {}


local function infer_type_from_node_type(value_node_type)
    if not core.is_non_empty_string(value_node_type) then
        return nil
    end

    if value_node_type == "string" then
        return "string"
    end

    if value_node_type == "number" then
        return "number"
    end

    if value_node_type == "nil" then
        return "nil"
    end

    if value_node_type == "true"
        or value_node_type == "false"
        or value_node_type == "boolean"
    then
        return "boolean"
    end

    if value_node_type == "table_constructor" then
        return "table"
    end

    if value_node_type == "function_call"
        or value_node_type == "call_expression"
    then
        return "call"
    end

    if value_node_type == "identifier" then
        return "identifier"
    end

    if value_node_type == "dot_index_expression"
        or value_node_type == "method_index_expression"
        or value_node_type == "field_expression"
    then
        return "reference"
    end

    return nil
end


local function infer_type_from_text(value_text)
    if not core.is_non_empty_string(value_text) then
        return nil
    end

    if value_text == "nil" then
        return "nil"
    end

    if value_text == "true" or value_text == "false" then
        return "boolean"
    end

    if tonumber(value_text) ~= nil then
        return "number"
    end

    if value_text:match('^".*"$') or value_text:match("^'.*'$") then
        return "string"
    end

    if value_text:match("^%{.*%}$") then
        return "table"
    end

    if value_text:match("%)$") then
        return "call"
    end

    if value_text:match("^[%a_][%w_%.:]*$") then
        return "reference"
    end

    return nil
end


local function infer_type_label(value_text, value_node_type)
    local type_label = infer_type_from_node_type(value_node_type)

    if type_label then
        return type_label
    end

    type_label = infer_type_from_text(value_text)

    if type_label then
        return type_label
    end

    return "<unknown>"
end


local function make_value_label(value_text)
    if not core.is_non_empty_string(value_text) then
        return "<unknown>"
    end

    return value_text
end



local function make_unknown_state(member)
    local value_text = member and member.value_text or nil
    local value_node_type = member and member.value_node_type or nil

    return {
        member_id = member and member.id or nil,
        name = member and member.name or nil,
        kind = member and member.kind or nil,
        type_label = infer_type_label(value_text, value_node_type),
        value_label = make_value_label(value_text),
        source_line = member and member.line or nil,
        value_node_type = value_node_type,
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
