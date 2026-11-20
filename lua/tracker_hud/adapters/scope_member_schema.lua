-- lua/tracker_hud/adapters/scope_member_schema.lua
--
-- Shared Scope Member adapter vocabulary and small authoring helpers.
--
-- This module is intentionally declarative. Helpers expand to the same plain
-- Adapter Contract v1 tables consumed by the runtime; they do not add a
-- runtime dispatch layer.

local M = {}


M.group_names = {
    "declarations",
    "assignments",
    "parameters",
    "functions",
    "loops",
    "returns",
    "fields",
    "symbols",
}


local supported_groups = {}

for _, group_name in ipairs(
    M.group_names
) do
    supported_groups[group_name] = true
end


function M.is_supported_group(group_name)
    return supported_groups[group_name] == true
end


function M.supported_groups_text()
    return table.concat(
        M.group_names,
        ", "
    )
end


-- General Scope Member declaration helper.
--
-- Syntax descriptors remain ordinary Adapter Contract v1 tables. The helper
-- only removes repeated wrapper boilerplate from adapter source.
function M.rule(
    node_type,
    kind,
    opts
)
    opts = type(opts) == "table"
        and opts
        or {}

    local syntax = {
        node_type = node_type,
    }

    for _, key in ipairs({
        "fields",
        "children",
        "tokens",
        "exclusions",
        "constraints",
    }) do
        if opts[key] ~= nil then
            syntax[key] = opts[key]
        end
    end

    local member = {
        kind = kind,
        language_term =
            opts.language_term
            or kind,
        owner_scope =
            opts.owner_scope
            or "lexical",
    }

    if opts.binding_mutability ~= nil then
        member.mutability = {
            binding =
                opts.binding_mutability,
        }
    end

    if opts.visibility_range ~= nil then
        member.visibility = {
            range =
                opts.visibility_range,
        }
    end

    local result = {
        syntax = syntax,
        member = member,
    }

    if opts.value ~= nil then
        result.value = opts.value
    end

    return result
end


-- Common named-binding declaration helper.
--
-- The returned value is a normal Adapter Contract v1 member spec.
function M.named(
    node_type,
    name_field,
    kind,
    opts
)
    opts = type(opts) == "table"
        and opts
        or {}

    local fields = nil

    if name_field ~= nil then
        fields = {
            name = name_field,
        }
    end

    local children = nil

    if opts.fallback_node_type ~= nil then
        children = {
            name = {
                node_type =
                    opts.fallback_node_type,
            },
        }
    end

    return M.rule(
        node_type,
        kind,
        {
            fields = fields,
            children = children,
            language_term =
                opts.language_term,
            owner_scope =
                opts.owner_scope,
            binding_mutability =
                opts.binding_mutability,
            visibility_range =
                opts.visibility_range,
            value =
                opts.value,
        }
    )
end


return M
