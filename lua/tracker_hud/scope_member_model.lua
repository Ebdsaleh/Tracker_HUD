-- lua/tracker_hud/scope_member_model.lua
--
-- Scope Member record construction and labeling.
--
-- This module owns the data shape for Scope Members. It does not walk
-- Tree-sitter nodes and does not know about language adapters.

local core = require("tracker_hud.core")

local M = {}


local scope_depth_filter_by_member =
    setmetatable(
        {},
        { __mode = "k" }
    )


local member_kind_labels = {
    parameter = "param",
}


local function copy_structural_path(path)
    local result = {}

    for _, frame in ipairs(path or {}) do
        if core.is_table(frame) then
            table.insert(
                result,
                {
                    depth = frame.depth,
                    node_type = frame.node_type,
                    construct_kind =
                        frame.construct_kind,
                    language_term =
                        frame.language_term,
                    label = frame.label,

                    start_line =
                        frame.start_line,
                    start_column =
                        frame.start_column,
                    end_line =
                        frame.end_line,
                    end_column =
                        frame.end_column,
                }
            )
        end
    end

    return result
end

function M.get_kind_label(kind)
    if not core.is_non_empty_string(kind) then
        return nil
    end

    return member_kind_labels[kind] or kind
end


function M.get_line(member)
    if not core.is_table(member) then
        return nil
    end

    return member.line
end


function M.scope_depth_filter_enabled(
    member
)
    return scope_depth_filter_by_member[
        member
    ] ~= false
end


function M.build_label(member)
    if not core.is_table(member) then
        return ""
    end

    local label = member.name or ""
    local kind_label = M.get_kind_label(member.kind)

    if core.is_non_empty_string(kind_label) then
        label = "(" .. kind_label .. ") " .. label
    end

    if member.line then
        label = "[" .. tostring(member.line) .. "] " .. label
    end

    return label
end


local function build_member_id(
    member
)
    return table.concat({
        "member",
        tostring(
            member.scope_start_line
            or ""
        ),
        tostring(
            member.scope_end_line
            or ""
        ),
        tostring(
            member.line
            or ""
        ),
        tostring(
            member.kind
            or ""
        ),
        tostring(
            member.name
            or ""
        ),
    }, ":")
end


function M.set_owner_scope(
    member,
    scope_depth,
    scope_range
)
    if not core.is_table(member) then
        return false
    end

    member.scope_depth =
        scope_depth or 0

    member.scope_start_line =
        scope_range
        and scope_range.start_line
        or nil
    member.scope_start_column =
        scope_range
        and scope_range.start_column
        or nil
    member.scope_end_line =
        scope_range
        and scope_range.end_line
        or nil
    member.scope_end_column =
        scope_range
        and scope_range.end_column
        or nil

    member.id =
        build_member_id(member)

    return true
end


function M.add(members, seen, name, kind, source_range, state, metadata)
    if not core.is_non_empty_string(name) then
        return
    end

    state = state or {}
    metadata = metadata or {}

    local opts = state.opts or {}
    local scope_depth = state.scope_depth or 0
    local scope_range = state.scope_range
    local structural_depth =
        state.structural_depth or 0
    local structural_range =
        state.structural_range

    local line = nil
    local source_start_column = nil
    local source_end_line = nil
    local source_end_column = nil

    if core.is_table(source_range) then
        line = source_range.start_line
        source_start_column = source_range.start_column
        source_end_line = source_range.end_line
        source_end_column = source_range.end_column
    else
        line = source_range
    end

    if opts.start_line and line and line < opts.start_line then
        return
    end

    if opts.end_line and line and line > opts.end_line then
        return
    end

    if opts.cursor_line and line and line > opts.cursor_line then
        return
    end

    local seen_key = table.concat({
        tostring(line or ""),
        tostring(kind or ""),
        tostring(scope_depth or 0),
        name,
    }, "|")

    if seen[seen_key] then
        return
    end

    seen[seen_key] = true

    local member = {
        line = line,
        kind = kind,
        name = name,
        scope_depth = scope_depth or 0,

        scope_start_line = scope_range and scope_range.start_line,
        scope_start_column = scope_range and scope_range.start_column,
        scope_end_line = scope_range and scope_range.end_line,
        scope_end_column = scope_range and scope_range.end_column,

        structural_depth = structural_depth,
        structural_path =
            copy_structural_path(
                state.structural_path
            ),
        structural_scope_start_line =
            structural_range
            and structural_range.start_line,
        structural_scope_start_column =
            structural_range
            and structural_range.start_column,
        structural_scope_end_line =
            structural_range
            and structural_range.end_line,
        structural_scope_end_column =
            structural_range
            and structural_range.end_column,

        visibility_start_line =
            state.member_visibility_range
            and state.member_visibility_range
                .start_line,
        visibility_end_line =
            state.member_visibility_range
            and state.member_visibility_range
                .end_line,

        source_start_line = line,
        source_start_column = source_start_column,
        source_end_line = source_end_line,
        source_end_column = source_end_column,

        -- metadata
        value_text = metadata.value_text,
        value_node_type = metadata.value_node_type,
        value_start_line = metadata.value_start_line,
        value_end_line = metadata.value_end_line,
        value_start_column = metadata.value_start_column,
        value_end_column = metadata.value_end_column,
        value_kind = metadata.value_kind,
        type_label = metadata.type_label,
        source_node_type = metadata.source_node_type,
    }

    member.id =
        build_member_id(member)

    member.label = M.build_label(member)

    scope_depth_filter_by_member[
        member
    ] =
        state.scope_depth_filter
        ~= false

    table.insert(members, member)
end


return M
