-- lua/tracker_hud/constructs/parser.lua
--
-- Construct match + parse orchestration.
--
-- This module coordinates existing construct helpers. It does not own
-- construct validation, source identity, branch presentation or scope logic.

local core = require("tracker_hud.core")
local context_primitives =
    require("tracker_hud.constructs.context_primitives")
local spec_validation =
    require("tracker_hud.constructs.spec_validation")
local source_identity =
    require("tracker_hud.constructs.source_identity")
local branch_presentation =
    require("tracker_hud.constructs.branch_presentation")

local M = {}


function M.match_node(
    adapter,
    node
)
    if not core.is_table(adapter)
        or not core.is_table(
            adapter.construct_specs
        )
    then
        return false
    end

    local node_type =
        context_primitives.get_node_type(
            node
        )

    if not node_type then
        return false
    end

    return adapter.construct_specs[
        node_type
    ] ~= nil
end


function M.parse_node(
    adapter,
    node,
    bufnr
)
    if not core.is_table(adapter) then
        return nil,
            "adapter must be a table"
    end

    if not core.is_table(
        adapter.construct_specs
    )
    then
        return nil,
            "adapter.construct_specs must be a table"
    end

    local node_type =
        context_primitives.get_node_type(
            node
        )

    local spec, spec_err =
        spec_validation.get(
            adapter.construct_specs,
            node_type
        )

    if not spec then
        return nil, spec_err
    end

    local range =
        context_primitives.get_node_range(
            node
        )

    if not range then
        return nil,
            "could not get node range"
    end

    local construct_spec =
        spec.construct or {}

    local signature = nil
    local name = nil

    if core.is_table(
        spec.signature
    )
    then
        signature =
            source_identity.build_signature(
                node,
                bufnr,
                spec
            )
    end

    -- Tree-sitter fields are authoritative for syntax identity.
    -- Text-pattern parsing remains only a fallback when the grammar does not
    -- expose the requested field.
    name =
        source_identity
            .extract_name_from_syntax(
                node,
                bufnr,
                spec
            )

    if not name and signature then
        name =
            source_identity
                .extract_name_from_signature(
                    signature,
                    spec
                )
    end

    local label =
        construct_spec.label
        or "<unknown>"

    local display_label = nil

    if core.is_table(spec.branch) then
        display_label =
            branch_presentation
                .build_display_label(
                    node,
                    spec
                )

        label = display_label
    end

    local resolved_construct =
        vim.deepcopy(
            construct_spec
        )

    resolved_construct.label =
        label

    return source_identity.build_construct({
        construct =
            resolved_construct,

        scope = spec.scope,
        member = spec.member,
        value = spec.value,

        node_type = node_type,
        name = name,
        signature = signature,
        range = range,

        metadata = {
            adapter = adapter.name,
            display_label =
                display_label,
        },
    })
end


return M
