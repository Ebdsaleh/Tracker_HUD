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

    if opts.value ~= nil then
        result.value = opts.value
    end

    return result
end


return M
