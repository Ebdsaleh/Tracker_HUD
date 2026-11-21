-- lua/tracker_hud/adapters/construct_schema.lua
--
-- Shared authoring helpers for Adapter Contract v1 construct declarations.
--
-- Language-specific Tree-sitter grammar stays in each adapter. These helpers
-- only remove repeated wrapper boilerplate and return the same plain tables
-- consumed by the existing runtime.

local M = {}


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
    }) do
        if opts[key] ~= nil then
            syntax[key] = opts[key]
        end
    end

    local language_term =
        opts.language_term
        or kind

    local construct = {
        kind = kind,
        language_term = language_term,
        label =
            opts.label
            or language_term,
    }

    if opts.construct_mutability ~= nil then
        construct.mutability =
            opts.construct_mutability
    end

    local result = {
        syntax = syntax,
        construct = construct,
    }

    for _, key in ipairs({
        "scope",
        "value",
        "signature",
        "markers",
        "branch",
        "availability",
    }) do
        if opts[key] ~= nil then
            result[key] = opts[key]
        end
    end

    return result
end


-- Incremental adapter authoring helper.
--
-- This is intentionally only a convenience around rule(): it creates the
-- same plain Adapter Contract table and stores it by Tree-sitter node type.
function M.define(
    construct_specs,
    node_type,
    kind,
    opts
)
    local spec =
        M.rule(
            node_type,
            kind,
            opts
        )

    construct_specs[node_type] = spec

    return spec
end


return M
