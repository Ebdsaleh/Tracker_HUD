-- lua/tracker_hud/symbol_state.lua
--
-- Language-agnostic symbol state enrichment.
--
-- This module enriches collected scope members with normalized type/value
-- display information. Language-specific meaning should come from adapters,
-- not from hardcoded Tree-sitter node names here.

local core = require("tracker_hud.core")

local M = {}


local resolvable_member_kinds = {
    ["local"] = true,
    assignment = true,
    parameter = true,
    ["function"] = true,
    loop_variable = true,
}

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

    if member.resolved_symbol then
        local resolved = member.resolved_symbol

        if core.is_non_empty_string(resolved.value_label) then
            return tostring(member.value_text or member.name or "<reference>")
                .. " -> "
                .. resolved.value_label
        end

        if core.is_non_empty_string(resolved.type_label) then
            return tostring(member.value_text or member.name or "<reference>")
                .. " -> "
                .. resolved.type_label
        end
    end

    if member.value_kind == "table"
        or member.value_kind == "function"
    then
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

        resolved_symbol = member and member.resolved_symbol or nil,

        source_line = member and member.line or nil,
        value_node_type = member and member.value_node_type or nil,
        value_start_line = member and member.value_start_line or nil,
        value_end_line = member and member.value_end_line or nil,
        value_start_column = member and member.value_start_column or nil,
        value_end_column = member and member.value_end_column or nil,
    }
end


local function member_can_define_symbol(member)
    return core.is_table(member)
        and core.is_non_empty_string(member.name)
        and resolvable_member_kinds[member.kind] == true
end


local function member_can_reference_symbol(member)
    return core.is_table(member)
        and core.is_non_empty_string(member.value_text)
        and member.value_node_type == "identifier"
end


local function symbol_is_before_or_at(symbol_member, reference_member)
    local symbol_line = symbol_member and symbol_member.line
    local reference_line = reference_member and reference_member.line

    if not symbol_line or not reference_line then
        return false
    end

    return symbol_line <= reference_line
end


local function symbol_is_visible_to_reference(symbol_member, reference_member)
    if not symbol_is_before_or_at(symbol_member, reference_member) then
        return false
    end

    local reference_scope_start = reference_member.scope_start_line
    local reference_scope_end = reference_member.scope_end_line
    local symbol_scope_start = symbol_member.scope_start_line
    local symbol_scope_end = symbol_member.scope_end_line

    if not reference_scope_start or not reference_scope_end then
        return true
    end

    if not symbol_scope_start or not symbol_scope_end then
        return true
    end

    return symbol_scope_start <= reference_scope_start
        and symbol_scope_end >= reference_scope_end
end


local function build_symbol_index(members)
    local symbol_index = {}

    for _, member in ipairs(members or {}) do
        if member_can_define_symbol(member) then
            local name = member.name

            if not symbol_index[name] then
                symbol_index[name] = {}
            end

            table.insert(symbol_index[name], member)
        end
    end

    return symbol_index
end


local function find_visible_symbol(symbol_index, reference_member)
    if not member_can_reference_symbol(reference_member) then
        return nil
    end

    local candidates = symbol_index[reference_member.value_text]

    if not core.is_table(candidates) then
        return nil
    end

    local best = nil

    for _, candidate in ipairs(candidates) do
        if candidate ~= reference_member
            and symbol_is_visible_to_reference(candidate, reference_member)
        then
            if not best or (candidate.line or 0) >= (best.line or 0) then
                best = candidate
            end
        end
    end

    return best
end


local function apply_resolved_symbol(member, resolved_symbol)
    if not core.is_table(member) or not core.is_table(resolved_symbol) then
        return
    end

    member.resolved_symbol = {
        member_id = resolved_symbol.id,
        name = resolved_symbol.name,
        kind = resolved_symbol.kind,
        line = resolved_symbol.line,
        type_label = resolved_symbol.type_label,
        value_label = resolved_symbol.value_label,
        value_kind = resolved_symbol.value_kind,
        value_text = resolved_symbol.value_text,
        value_start_line = resolved_symbol.value_start_line,
        value_end_line = resolved_symbol.value_end_line,
        value_start_column = resolved_symbol.value_start_column,
        value_end_column = resolved_symbol.value_end_column,
    }

    if not core.is_non_empty_string(member.type_label)
        and core.is_non_empty_string(resolved_symbol.type_label)
    then
        member.type_label = resolved_symbol.type_label
    end

    if not core.is_non_empty_string(member.value_kind)
        and core.is_non_empty_string(resolved_symbol.value_kind)
    then
        member.value_kind = resolved_symbol.value_kind
    end
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
    local symbol_index = build_symbol_index(members)

    for _, member in ipairs(members or {}) do
        if core.is_table(member) then
            local resolved_symbol = find_visible_symbol(symbol_index, member)

            if resolved_symbol then
                -- Ensure the target symbol has display labels before copying from it.
                M.enrich_member(resolved_symbol, context)
                apply_resolved_symbol(member, resolved_symbol)
            end

            table.insert(enriched, M.enrich_member(member, context))
        end
    end

    return enriched
end


return M
