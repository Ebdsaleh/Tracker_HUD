-- lua/tracker_hud/adapters/c/target_directives.lua
--
-- C and C++ source target metadata. Mirrors the *strict* ASM directive
-- syntax through the existing shared directive scanner:
--
--   // arch=x86-64;
--   // platform=windows;
--   // abi=win64;
--   // syntax=c;              (cpp in C++ files)
--   // mode=compiled;
--
-- Source metadata has precedence over config.targets, which has precedence
-- over the conservative defaults. Neither architecture nor ABI can be
-- inferred reliably from a C/C++ translation unit alone. Directives do not
-- change Neovim filetype, Tree-sitter parser or compiler settings.

local variant_utils = require("tracker_hud.adapters.variant_utils")
local target_dimensions =
    require("tracker_hud.adapters.target_dimensions")

local M = {}

M.directive_comment_prefixes = { "//" }
M.target_directives = {
    architecture = "arch",
    platform = "platform",
    abi = "abi",
    syntax = "syntax",
    mode = "mode",
}

local directive_names = { "abi", "arch", "mode", "platform", "syntax" }

local arch_aliases = {
    ["x86-64"] = "x86-64",
    ["x86_64"] = "x86-64",
    ["amd64"] = "x86-64",
    ["x64"] = "x86-64",
}

local function normalize(value)
    if type(value) ~= "string" then
        return nil
    end

    value = value:lower():gsub("^%s+", ""):gsub("%s+$", "")
    if value == "" then
        return nil
    end
    return value
end

local function normalize_architecture(value)
    local normalized = normalize(value)
    if normalized then
        return arch_aliases[normalized] or normalized
    end
    return nil
end

local function defaults(language)
    return {
        architecture = "unknown",
        platform = "unknown",
        abi = "unknown",
        syntax = language,
        mode = "compiled",
    }
end

local function semantic_dimension_names(
    declared_dimensions
)
    local names = {}

    for name in pairs(
        declared_dimensions or {}
    ) do
        table.insert(names, name)
    end

    table.sort(names)

    return names
end

local function scan_directive_names(
    declared_dimensions
)
    local names = vim.deepcopy(
        directive_names
    )

    for _, name in ipairs(
        semantic_dimension_names(
            declared_dimensions
        )
    ) do
        table.insert(names, name)
    end

    return names
end

local function read_directives(
    bufnr,
    declared_dimensions
)
    return variant_utils.scan_directives_from_buffer(bufnr, {
        directives = scan_directive_names(
            declared_dimensions
        ),
        comment_prefixes = M.directive_comment_prefixes,
        assignment_symbol = "=",
        terminator_symbol = ";",
        max_scan_lines = 20,
    })
end

local function unsupported_dimension_warning(
    name,
    source_directive,
    requested
)
    local expected =
        "// " .. name .. "=<supported-value>;"

    return {
        key = name,
        value = requested,
        directive = name,
        line = source_directive.line,
        column = source_directive.column,
        end_column = source_directive.end_column,
        message =
            "Target warning: unsupported "
            .. name
            .. " value",
        messages = {
            inline =
                "Target warning: unsupported "
                .. name
                .. " value",
            panel =
                "Target warning: unsupported "
                .. name
                .. " value",
            full =
                "Target warning: unsupported "
                .. name
                .. " value '"
                .. tostring(requested)
                .. "'. Use "
                .. expected,
        },
        expected = expected,
    }
end

local function invalid_syntax_warning(language, source_directive, requested)
    local expected = "// syntax=" .. language .. ";"
    return {
        key = "syntax",
        value = requested,
        directive = "syntax",
        line = source_directive.line,
        column = source_directive.column,
        end_column = source_directive.end_column,
        message = "Target warning: syntax does not match the " .. language .. " adapter",
        messages = {
            inline = "Target warning: incompatible syntax directive",
            panel = "Target warning: syntax does not match the " .. language .. " adapter",
            full = "Target warning: source syntax '" .. tostring(requested)
                .. "' does not match the " .. language
                .. " Tree-sitter adapter. Use '" .. expected
                .. "'. No parser switch was performed.",
        },
        expected = expected,
    }
end

function M.resolve(
    bufnr,
    config,
    language,
    declared_dimensions
)
    assert(language == "c" or language == "cpp",
        "C/C++ target directives require a c or cpp adapter")

    declared_dimensions =
        type(declared_dimensions) == "table"
            and declared_dimensions
            or {}

    local result = defaults(language)
    local config_targets = type(config) == "table"
        and type(config.targets) == "table"
        and config.targets
        or {}

    for key in pairs(M.target_directives) do
        local value = normalize(config_targets[key])
        if value then
            result[key] = key == "architecture"
                and normalize_architecture(value) or value
        end
    end

    for name, descriptor in pairs(
        declared_dimensions
    ) do
        local resolved =
            target_dimensions.resolve_value(
                descriptor,
                config_targets[name]
            )

        if resolved ~= nil then
            result[name] = resolved
        else
            local fallback =
                target_dimensions.resolve_value(
                    descriptor,
                    nil
                )

            if fallback ~= nil then
                result[name] = fallback
            end
        end
    end

    local scan =
        read_directives(
            bufnr,
            declared_dimensions
        )
    local source_directives = {}
    local semantic_directives = {}

    for _, directive in ipairs(
        scan.directives or {}
    ) do
        local handled = false

        for key, name in pairs(
            M.target_directives
        ) do
            if name == directive.directive
                and source_directives[key] == nil
            then
                source_directives[key] =
                    directive

                local value =
                    normalize(
                        directive.value
                    )

                if value then
                    result[key] =
                        key == "architecture"
                            and normalize_architecture(
                                value
                            )
                            or value
                end

                handled = true
                break
            end
        end

        if not handled then
            local descriptor =
                declared_dimensions[
                    directive.directive
                ]

            if descriptor ~= nil
                and semantic_directives[
                    directive.directive
                ] == nil
            then
                semantic_directives[
                    directive.directive
                ] = directive
            end
        end
    end

    result.diagnostics =
        scan.diagnostics or {}

    for name, directive in pairs(
        semantic_directives
    ) do
        local descriptor =
            declared_dimensions[name]

        local resolved =
            target_dimensions.resolve_value(
                descriptor,
                directive.value
            )

        if resolved ~= nil then
            result[name] = resolved
        else
            table.insert(
                result.diagnostics,
                unsupported_dimension_warning(
                    name,
                    directive,
                    directive.value
                )
            )
        end
    end

    -- The grammar is determined by the actual Neovim buffer's filetype.
    -- Displaying syntax=cpp for a C buffer would be misleading: warn and
    -- keep the adapter's real syntax rather than claiming a parser switch.
    if result.syntax ~= language then
        local source_syntax = source_directives.syntax
        if source_syntax then
            table.insert(result.diagnostics,
                invalid_syntax_warning(language, source_syntax, result.syntax))
        end
        result.syntax = language
    end

    return result
end

return M
