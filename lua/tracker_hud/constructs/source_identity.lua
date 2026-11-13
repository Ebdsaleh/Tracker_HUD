-- lua/tracker_hud/constructs/source_identity.lua
--
-- Construct source identity helpers.
--
-- This module owns signature/name extraction and canonical construct assembly.
-- Runtime parse orchestration remains in context_engine.

local core = require("tracker_hud.core")
local syntax_spec = require("tracker_hud.syntax_spec")
local ts_utils = require("tracker_hud.treesitter_utils")
local contract = require("tracker_hud.constructs.contract")

local M = {}


function M.get_first_line_text(
    node,
    bufnr
)
    local node_text =
        ts_utils.get_node_text(
            node,
            bufnr
        )

    if not node_text then
        return nil
    end

    return node_text:match(
        "([^\n]+)"
    )
end


function M.build_signature(
    node,
    bufnr,
    spec
)
    if not core.is_table(spec)
        or not core.is_table(
            spec.signature
        )
    then
        return nil
    end

    if spec.signature.strategy
        ~= "first_line"
    then
        return nil
    end

    return M.get_first_line_text(
        node,
        bufnr
    )
end


function M.extract_name_from_signature(
    signature,
    spec
)
    if type(signature) ~= "string" then
        return nil
    end

    if not core.is_table(spec)
        or not core.is_table(
            spec.signature
        )
    then
        return nil
    end

    local signature_spec =
        spec.signature

    if type(
        signature_spec
            .local_name_pattern
    ) == "string"
    then
        local name =
            signature:match(
                signature_spec
                    .local_name_pattern
            )

        if name then
            return name
        end
    end

    if type(
        signature_spec.name_pattern
    ) == "string"
    then
        return signature:match(
            signature_spec.name_pattern
        )
    end

    return nil
end


function M.extract_name_from_syntax(
    node,
    bufnr,
    spec
)
    if not node
        or not core.is_table(spec)
    then
        return nil
    end

    local name_field =
        syntax_spec.get_field(
            spec,
            "name"
        )

    if not name_field then
        return nil
    end

    local name_node =
        ts_utils.get_child_by_field_name(
            node,
            name_field
        )

    if not name_node then
        return nil
    end

    return ts_utils.get_node_text(
        name_node,
        bufnr
    )
end


function M.build_construct(opts)
    opts = opts or {}

    return contract.new_construct({
        construct = opts.construct,
        scope = opts.scope,
        member = opts.member,
        value = opts.value,

        node_type = opts.node_type,
        name = opts.name,
        signature = opts.signature,
        range = opts.range,

        metadata =
            opts.metadata or {},
    })
end


return M
