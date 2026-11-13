-- lua/tracker_hud/constructs/spec_validation.lua
--
-- Construct-spec lookup and validation.
--
-- This module owns only validation of adapter construct declarations. Runtime
-- construct parsing and source-node interpretation remain elsewhere.

local core = require("tracker_hud.core")
local syntax_spec = require("tracker_hud.syntax_spec")
local contract = require("tracker_hud.constructs.contract")

local M = {}


function M.validate(
    spec,
    expected_node_type
)
    if not core.is_table(spec) then
        return false,
            "construct spec must be a table"
    end

    local syntax =
        syntax_spec.get(spec)

    if spec.syntax ~= nil
        and not core.is_table(spec.syntax)
    then
        return false,
            "construct spec syntax must be a table when provided"
    end

    if core.is_table(spec.syntax) then
        if not core.is_non_empty_string(
            syntax.node_type
        )
        then
            return false,
                "construct spec syntax.node_type must be a non-empty Tree-sitter node type"
        end

        if core.is_non_empty_string(
            expected_node_type
        )
            and syntax.node_type
                ~= expected_node_type
        then
            return false,
                "construct spec syntax.node_type '"
                .. tostring(
                    syntax.node_type
                )
                .. "' does not match construct_specs key '"
                .. tostring(
                    expected_node_type
                )
                .. "'"
        end

        if syntax.fields ~= nil
            and not core.is_table(
                syntax.fields
            )
        then
            return false,
                "construct spec syntax.fields must be a table when provided"
        end

        if syntax.children ~= nil
            and not core.is_table(
                syntax.children
            )
        then
            return false,
                "construct spec syntax.children must be a table when provided"
        end

        if syntax.tokens ~= nil
            and not core.is_table(
                syntax.tokens
            )
        then
            return false,
                "construct spec syntax.tokens must be a table when provided"
        end

        if syntax.exclusions ~= nil
            and not core.is_table(
                syntax.exclusions
            )
        then
            return false,
                "construct spec syntax.exclusions must be a table when provided"
        end
    end

    local ok, err =
        contract.validate_construct_spec(
            spec.construct
        )

    if not ok then
        return false, err
    end

    ok, err =
        contract.validate_scope_spec(
            spec.scope
        )

    if not ok then
        return false, err
    end

    ok, err =
        contract.validate_member_spec(
            spec.member
        )

    if not ok then
        return false, err
    end

    ok, err =
        contract.validate_value_spec(
            spec.value
        )

    if not ok then
        return false, err
    end

    if spec.markers ~= nil then
        if not core.is_table(
            spec.markers
        )
        then
            return false,
                "construct spec markers must be a table when provided"
        end

        local required =
            spec.markers.required or {}

        local optional =
            spec.markers.optional or {}

        if not core.is_table(required) then
            return false,
                "construct spec markers.required must be a table"
        end

        if not core.is_table(optional) then
            return false,
                "construct spec markers.optional must be a table"
        end

        local tokens =
            syntax_spec.get_tokens(spec)

        if tokens == nil then
            return false,
                "construct spec markers require syntax.tokens"
        end

        for _, marker_name in ipairs(
            required
        ) do
            if type(marker_name) ~= "string"
                or marker_name == ""
            then
                return false,
                    "required marker names must be non-empty strings"
            end

            if tokens[marker_name] == nil then
                return false,
                    "required marker '"
                    .. marker_name
                    .. "' is missing from syntax.tokens"
            end
        end

        for _, marker_name in ipairs(
            optional
        ) do
            if type(marker_name) ~= "string"
                or marker_name == ""
            then
                return false,
                    "optional marker names must be non-empty strings"
            end

            if tokens[marker_name] == nil then
                return false,
                    "optional marker '"
                    .. marker_name
                    .. "' is missing from syntax.tokens"
            end
        end

        if spec.markers.total_required
            ~= nil
            and spec.markers
                .total_required
                ~= #required
        then
            return false,
                "markers.total_required does not match number of required markers"
        end
    end

    return true, nil
end


function M.get(
    construct_specs,
    node_type
)
    if not core.is_table(
        construct_specs
    )
    then
        return nil,
            "construct_specs must be table"
    end

    if type(node_type) ~= "string"
        or node_type == ""
    then
        return nil,
            "node_type must be a non-empty string"
    end

    local spec =
        construct_specs[node_type]

    if not spec then
        return nil, nil
    end

    local ok, err =
        M.validate(
            spec,
            node_type
        )

    if not ok then
        return nil, err
    end

    return spec, nil
end


return M
