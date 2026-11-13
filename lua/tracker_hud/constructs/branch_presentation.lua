-- lua/tracker_hud/constructs/branch_presentation.lua
--
-- Generic branch presentation policy.
--
-- This module owns only branch-alternative discovery and display-label policy
-- for construct presentation. It does not parse constructs or infer semantics.

local core = require("tracker_hud.core")
local syntax_spec = require("tracker_hud.syntax_spec")
local context_primitives =
    require("tracker_hud.constructs.context_primitives")

local M = {}


function M.format_display_label(
    start_line,
    base_label,
    alternative_label,
    alternative_line,
    grouped
)
    if grouped then
        return "(["
            .. start_line
            .. "] "
            .. base_label
            .. " : "
            .. alternative_label
            .. " ["
            .. alternative_line
            .. "])"
    end

    return "["
        .. start_line
        .. "] "
        .. base_label
        .. " : "
        .. alternative_label
        .. " ["
        .. alternative_line
        .. "]"
end


function M.node_matches_alternative(
    node,
    spec
)
    if not node
        or not core.is_table(spec)
    then
        return false
    end

    local branch_spec =
        spec.branch or {}

    local alternatives =
        branch_spec.alternatives or {}

    local node_type =
        node:type()

    for _, alternative_spec in ipairs(
        alternatives
    ) do
        if core.is_table(
            alternative_spec
        ) then
            local alternative_node_type =
                syntax_spec.get_node_type(
                    alternative_spec
                )

            if core.is_non_empty_string(
                alternative_node_type
            )
                and node_type
                    == alternative_node_type
            then
                return true
            end

            -- Temporary compatibility for pre-syntax adapters.
            if type(
                alternative_spec.node_match
            ) == "string"
                and node_type:match(
                    alternative_spec.node_match
                )
            then
                return true
            end
        end
    end

    return false
end


function M.get_node_alternatives(
    node,
    spec
)
    local alternatives = {}

    if not node then
        return alternatives
    end

    local alternative_field =
        syntax_spec.get_field(
            spec,
            "alternative"
        )
        or "alternative"

    local ok, field_nodes =
        pcall(function()
            return node:field(
                alternative_field
            )
        end)

    if ok and field_nodes then
        for _, alternative in ipairs(
            field_nodes
        ) do
            table.insert(
                alternatives,
                alternative
            )
        end
    end

    for i = 0,
        node:named_child_count() - 1
    do
        local child =
            node:named_child(i)

        if M.node_matches_alternative(
            child,
            spec
        ) then
            table.insert(
                alternatives,
                child
            )
        end
    end

    return alternatives
end


function M.get_alternative_label(
    alternative_node,
    spec
)
    if not alternative_node
        or not core.is_table(spec)
    then
        return nil
    end

    local branch_spec =
        spec.branch or {}

    local alternatives =
        branch_spec.alternatives or {}

    local alternative_type =
        alternative_node:type()

    for _, alternative_spec in ipairs(
        alternatives
    ) do
        if core.is_table(
            alternative_spec
        )
            and type(
                alternative_spec.label
            ) == "string"
        then
            local alternative_node_type =
                syntax_spec.get_node_type(
                    alternative_spec
                )

            if core.is_non_empty_string(
                alternative_node_type
            )
                and alternative_type
                    == alternative_node_type
            then
                return alternative_spec.label
            end

            -- Temporary compatibility for pre-syntax adapters.
            if type(
                alternative_spec.node_match
            ) == "string"
                and alternative_type:match(
                    alternative_spec.node_match
                )
            then
                return alternative_spec.label
            end
        end
    end

    return nil
end


function M.build_display_label(
    node,
    spec
)
    local start_line =
        context_primitives
            .get_first_node_line(node)

    local construct_spec =
        spec.construct or {}

    local base_label =
        construct_spec.label
        or "Branch"

    if not start_line then
        return base_label
    end

    local cursor =
        context_primitives
            .get_cursor_position()

    local alternatives =
        M.get_node_alternatives(
            node,
            spec
        )

    local branch_spec =
        spec.branch or {}

    local grouped =
        branch_spec.grouped == true

    for _, alternative in ipairs(
        alternatives
    ) do
        if context_primitives
            .position_in_node(
                cursor.row,
                cursor.col,
                alternative
            )
        then
            local alternative_line =
                context_primitives
                    .get_first_node_line(
                        alternative
                    )
                or start_line

            local label =
                M.get_alternative_label(
                    alternative,
                    spec
                )
                or "Alternative"

            return M.format_display_label(
                start_line,
                base_label,
                label,
                alternative_line,
                grouped
            )
        end
    end

    return "["
        .. start_line
        .. "] "
        .. base_label
end


return M
