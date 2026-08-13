-- lua/tracker_hud/adapters/asm/adapter.lua
--
-- ASM Tree-sitter adapter.
--
-- ASM is a variant-based adapter.
--
-- The master ASM adapter owns:
--   - filetype registration
--   - variant metadata
--   - source directive detection
--   - active variant loading
--
-- Architecture/variant files own:
--   - registers
--   - stack concepts
--   - scope member declarations
--
-- Example source directive:
--
--   ; arch=x86-64;


local variant_utils = require("tracker_hud.adapters.variant_utils")
local directive_utils = require("tracker_hud.directive_utils")

local M = {}

M.name = "asm"

M.filetypes = {
    "asm",
    "nasm",
    "gas",
    "s",
}


M.has_variant = true
M.variant_kind = "architecture"
M.variant_directive = "arch"
M.variant_comment_prefixes = {
    ";",
}

M.directive_comment_prefixes = {
    ";",
    "#",
    "//",
}

M.default_variant = "x86-64"


M.variants = {
    ["x86-64"] = "tracker_hud.adapters.asm.arch.x86_64",
}


M.variant_aliases = {
    ["x86-64"] = "x86-64",
    ["x86_64"] = "x86-64",
    ["amd64"] = "x86-64",
    ["x64"] = "x86-64",
}

M.target_directives = {
    architecture = "arch",
    platform = "platform",
    abi = "abi",
    syntax = "syntax",
    mode = "mode",
}

M.capabilities = {
    lexical_scopes = true,
    structural_scopes = false,
    members = true,
    values = false,
    source_jump = true,
    registers = true,
    stack = true,
    boundary_effects = true,
    instruction_events = true,
    heap = true,
}


M.sections = {
    registers = {
        id = "registers",
        label = "Registers",
    },

    events = {
        id = "events",
        label = "Events",
    },

    stack = {
        id = "stack",
        label = "Stack",
    },

    heap = {
        id = "heap",
        label = "Heap",
    },
}


M.base_presentation = {
    sections = {
        order = {
            "scope",
            "scope_members",
            "registers",
            "events",
            "stack",
            "heap",
            "warnings",
        },
    },
}



M.construct_specs = {
    ["label"] = {
        construct = {
            kind = "label",
            label = "Label",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
    },

    ["instruction"] = {
        construct = {
            kind = "instruction",
            label = "Instruction",
        },
    },
}

local default_instruction_parser = {
    module = "tracker_hud.adapters.asm.instruction_utils",
    function_name = "parse_instruction",
}

M.instruction_parser = default_instruction_parser


local function normalize_variant_name(name)
    if type(name) ~= "string" then
        return nil
    end

    local normalized = name:lower():gsub("^%s+", ""):gsub("%s+$", "")

    return M.variant_aliases[normalized] or normalized
end


local function normalize_target_value(value)
    if type(value) ~= "string" then
        return nil
    end

    local normalized = value:lower():gsub("^%s+", ""):gsub("%s+$", "")

    if normalized == "" then
        return nil
    end

    return normalized
end

local function normalize_target_table(targets)
    if type(targets) ~= "table" then
        return {}
    end

    return {
        architecture = normalize_target_value(targets.architecture),
        platform = normalize_target_value(targets.platform),
        abi = normalize_target_value(targets.abi),
        syntax = normalize_target_value(targets.syntax),
        mode = normalize_target_value(targets.mode),
    }
end


local function get_target_directive_names()
    local directive_names = {}
    local seen = {}

    for _, directive in pairs(M.target_directives or {}) do
        if type(directive) == "string" and directive ~= "" and not seen[directive] then
            seen[directive] = true
            table.insert(directive_names, directive)
        end
    end

    table.sort(directive_names)

    return directive_names
end


local function get_target_key_for_directive(directive)
    if type(directive) ~= "string" then
        return nil
    end

    for key, target_directive in pairs(M.target_directives or {}) do
        if target_directive == directive then
            return key
        end
    end

    return nil
end


local function scan_source_directives(bufnr)
    return variant_utils.scan_directives_from_buffer(bufnr, {
        directives = get_target_directive_names(),
        comment_prefixes = M.directive_comment_prefixes or M.variant_comment_prefixes,
        assignment_symbol = "=",
        terminator_symbol = ";",
        max_scan_lines = 20,
    })
end


local function detect_variant_from_source(bufnr)
    local scan = scan_source_directives(bufnr)
    local directive_name = M.variant_directive or "arch"

    for _, directive in ipairs(scan.directives or {}) do
        if directive.directive == directive_name then
            return normalize_variant_name(directive.value)
        end
    end

    return nil
end


local function get_directive_location(directive)
    if type(directive) ~= "table" then
        return nil
    end

    return {
        line = directive.line,
        column = directive.column,
        end_column = directive.end_column,
        comment_prefix = directive.comment_prefix,
        directive = directive.directive,
        value = directive.value,
    }
end


local function detect_targets_from_source(bufnr)
    local scan = scan_source_directives(bufnr)

    local source_targets = {
        architecture = nil,
        platform = nil,
        abi = nil,
        syntax = nil,
        mode = nil,

        locations = {},
        directives = {},
        diagnostics = scan.diagnostics or {},
    }

    for _, directive in ipairs(scan.directives or {}) do
        local key = get_target_key_for_directive(directive.directive)

        if key and source_targets[key] == nil then
            local value = directive.value

            if key == "architecture" then
                value = normalize_variant_name(value)
            else
                value = normalize_target_value(value)
            end

            source_targets[key] = value
            source_targets.locations[key] = get_directive_location(directive)
            source_targets.directives[key] = directive
        end
    end

    return source_targets
end


local function load_variant(variant_name)
    local normalized = normalize_variant_name(variant_name) or M.default_variant
    local module_name = M.variants[normalized]

    if not module_name then
        normalized = M.default_variant
        module_name = M.variants[normalized]
    end

    local ok, variant = pcall(require, module_name)

    if not ok or type(variant) ~= "table" then
        return nil
    end

    return variant
end



local function get_platform_abi(variant, platform)
    if type(variant) ~= "table"
        or type(variant.platforms) ~= "table"
        or type(platform) ~= "string"
    then
        return nil
    end

    local platform_spec = variant.platforms[platform]

    if type(platform_spec) ~= "table" then
        return nil
    end

    return platform_spec.abi
end


local function target_exists(spec_table, key)
    return type(spec_table) == "table"
        and type(key) == "string"
        and type(spec_table[key]) == "table"
end


local function normalize_diagnostic_messages(message_or_messages)
    if type(message_or_messages) == "table" then
        local panel = message_or_messages.panel
            or message_or_messages.full
            or message_or_messages.inline
            or "Target warning"

        return {
            inline = message_or_messages.inline or panel,
            panel = panel,
            full = message_or_messages.full or panel,
        }
    end

    local message = tostring(message_or_messages or "Target warning")

    return {
        inline = message,
        panel = message,
        full = message,
    }
end

local function add_target_diagnostic(diagnostics, key, value, message_or_messages, location)
    if type(diagnostics) ~= "table" then
        return
    end

    local messages = normalize_diagnostic_messages(message_or_messages)

    local diagnostic = {
        key = key,
        value = value,
        message = messages.panel,
        messages = messages,
    }

    if type(location) == "table" then
        diagnostic.line = location.line
        diagnostic.column = location.column
        diagnostic.end_column = location.end_column
    end

    table.insert(diagnostics, diagnostic)
end


local function add_existing_diagnostics(diagnostics, source_targets)
    if type(diagnostics) ~= "table"
        or type(source_targets) ~= "table"
        or type(source_targets.diagnostics) ~= "table"
    then
        return
    end

    for _, diagnostic in ipairs(source_targets.diagnostics) do
        table.insert(diagnostics, diagnostic)
    end
end


local function get_syntax_spec(variant, syntax)
    if type(variant) ~= "table"
        or type(variant.syntaxes) ~= "table"
        or type(syntax) ~= "string"
    then
        return nil
    end

    local syntax_spec = variant.syntaxes[syntax]

    if type(syntax_spec) ~= "table" then
        return nil
    end

    return syntax_spec
end


local function get_syntax_comment_prefixes(variant, syntax)
    local syntax_spec = get_syntax_spec(variant, syntax)

    if type(syntax_spec) == "table"
        and type(syntax_spec.directive_comment_prefixes) == "table"
    then
        return syntax_spec.directive_comment_prefixes
    end

    if type(syntax_spec) == "table"
        and type(syntax_spec.comment_prefixes) == "table"
    then
        return syntax_spec.comment_prefixes
    end

    if type(variant) == "table"
        and type(variant.comments) == "table"
        and type(variant.comments.line) == "table"
    then
        local prefixes = {}

        for _, comment in ipairs(variant.comments.line) do
            if type(comment) == "table"
                and type(comment.prefix) == "string"
                and comment.prefix ~= ""
            then
                table.insert(prefixes, comment.prefix)
            end
        end

        return prefixes
    end

    return M.variant_comment_prefixes or { ";" }
end


local function add_syntax_comment_prefix_diagnostics(diagnostics, source_targets, variant, syntax)
    if type(diagnostics) ~= "table"
        or type(source_targets) ~= "table"
        or type(source_targets.directives) ~= "table"
        or type(syntax) ~= "string"
    then
        return
    end

    local allowed_prefixes = get_syntax_comment_prefixes(variant, syntax)

    for key, directive in pairs(source_targets.directives) do
        local prefix = directive.comment_prefix

        if prefix
            and not directive_utils.comment_prefix_is_allowed(prefix, allowed_prefixes)
        then
            local expected = directive_utils.format_expected_forms(
                directive.directive,
                directive.value,
                allowed_prefixes,
                {
                    assignment_symbol = "=",
                    terminator_symbol = ";",
                }
            )

            add_target_diagnostic(
                diagnostics,
                key,
                directive.value,
                {
                    inline = "Target warning: directive prefix mismatch",
                    panel = "Target warning: directive uses '"
                        .. tostring(prefix)
                        .. "' under syntax '"
                        .. tostring(syntax)
                        .. "'",
                    full = "Target warning: directive comment prefix '"
                        .. tostring(prefix)
                        .. "' does not match active syntax '"
                        .. tostring(syntax)
                        .. "'. Use "
                        .. expected
                        .. ".",
                },
                source_targets.locations and source_targets.locations[key]
            )
        end
    end
end


local function build_comments_for_syntax(variant, syntax)
    local prefixes = get_syntax_comment_prefixes(variant, syntax)
    local line_comments = {}

    for _, prefix in ipairs(prefixes or {}) do
        if type(prefix) == "string" and prefix ~= "" then
            table.insert(line_comments, {
                prefix = prefix,
                role = "line comment",
            })
        end
    end

    if #line_comments == 0 then
        return variant and variant.comments or {}
    end

    return {
        line = line_comments,
    }
end


local function resolve_targets(bufnr, config, variant)
    local config_targets = normalize_target_table(config and config.targets)
    local source_targets = detect_targets_from_source(bufnr)
    local diagnostics = {}

    add_existing_diagnostics(diagnostics, source_targets)

    local architecture = source_targets.architecture
        or config_targets.architecture
        or M.default_variant

    local platform = source_targets.platform
        or config_targets.platform
        or variant.default_platform

    if type(variant.platform_aliases) == "table" and platform then
        platform = variant.platform_aliases[platform] or platform
    end

    local platform_from_source = source_targets.platform ~= nil
    local platform_abi = get_platform_abi(variant, platform)

    if platform and not target_exists(variant.platforms, platform) then
        add_target_diagnostic(
            diagnostics,
            "platform",
            platform,
            "Target warning: unknown platform '" .. tostring(platform) .. "'",
            source_targets.locations and source_targets.locations.platform
        )
    end

    local abi = source_targets.abi

    if not abi and platform_from_source then
        abi = platform_abi
    end

    if not abi then
        abi = config_targets.abi or platform_abi
    end

    if platform_from_source and not platform_abi and not source_targets.abi then
        abi = nil
    end

    if abi
        and type(variant.calling_conventions) == "table"
        and not target_exists(variant.calling_conventions, abi)
    then
        add_target_diagnostic(
            diagnostics,
            "abi",
            abi,
            "Target warning: unknown ABI '" .. tostring(abi) .. "'",
            source_targets.locations and source_targets.locations.abi
        )
    end

    local syntax = source_targets.syntax
        or config_targets.syntax

    if syntax
        and type(variant.syntaxes) == "table"
        and not target_exists(variant.syntaxes, syntax)
    then
        add_target_diagnostic(
            diagnostics,
            "syntax",
            syntax,
            "Target warning: unknown syntax '" .. tostring(syntax) .. "'",
            source_targets.locations and source_targets.locations.syntax
        )
    end

    add_syntax_comment_prefix_diagnostics(
        diagnostics,
        source_targets,
        variant,
        syntax
    )

    local mode = source_targets.mode
        or config_targets.mode

    if not mode and type(variant.metadata) == "table" and variant.metadata.bits == 64 then
        mode = "long64"
    end

    local resolved = {
        architecture = architecture,
        platform = platform,
        abi = abi,
        syntax = syntax,
        mode = mode,
        diagnostics = diagnostics,
    }

    if architecture and normalize_variant_name(architecture) ~= M.active_variant_name then
        add_target_diagnostic(
            diagnostics,
            "architecture",
            architecture,
            "Target warning: unknown architecture '" .. tostring(architecture) .. "'",
            source_targets.locations and source_targets.locations.architecture
        )
    end

    return resolved
end



local function resolve_presentation(variant)
    local presentation = {}

    if type(variant) == "table"
        and type(variant.presentation) == "table"
    then
        presentation = vim.deepcopy(variant.presentation)
    end

    -- ASM supplies the normal section workflow unless the architecture
    -- variant explicitly provides its own.
    if type(presentation.sections) ~= "table" then
        presentation.sections = vim.deepcopy(
            M.base_presentation.sections
        )
    end

    return presentation
end





local function apply_variant(variant)
    if type(variant) ~= "table" then
        return
    end

    M.active_variant = variant
    M.active_variant_name = variant.name or M.default_variant

    -- Keep architecture as an alias for older code paths and HUD metadata.
    M.architecture = M.active_variant_name

    -- Comments
    M.comments = variant.comments or {}

    -- Variant-owned descriptive specs.
    M.registers = variant.registers or { static = {} }
    M.register_families = variant.register_families or {}
    M.presentation = resolve_presentation(variant)
    M.stack = variant.stack or { static = {} }
    M.scope_members = variant.scope_members or { symbols = {} }
    M.range_scopes = variant.range_scopes or {}
    M.register_effects = variant.register_effects or {}
    M.stack_effects = variant.stack_effects or {}
    M.boundary_effects = variant.boundary_effects or {}
    M.instruction_events = variant.instruction_events or {}
    M.warning_rules = variant.warning_rules or {}
    M.syscall = variant.syscall

    -- Additional Parsing rules
    -- Variants may override the default ASM instruction parser if their
    -- grammar shape needs different handling.
    M.instruction_parser = variant.instruction_parser or default_instruction_parser

    -- Optional override point if a future ASM variant needs different grammar specs.
    if type(variant.construct_specs) == "table" then
        M.construct_specs = variant.construct_specs
    end
end


function M.configure_adapter_for_buffer(bufnr, config)
    local config_targets = normalize_target_table(config and config.targets)

    local variant_name = detect_variant_from_source(bufnr)
        or config_targets.architecture
        or M.default_variant

    local variant = load_variant(variant_name)

    apply_variant(variant)

    M.active_targets = resolve_targets(bufnr, config, variant or {})
    M.comments = build_comments_for_syntax(variant or {}, M.active_targets.syntax)
end

-- Default variant so the adapter still exposes useful specs before
-- configure_adapter_for_buffer() is called.
local default_variant = load_variant(M.default_variant)

apply_variant(default_variant)

M.active_targets = resolve_targets(nil, nil, default_variant or {})
M.comments = build_comments_for_syntax(default_variant or {}, M.active_targets.syntax)


return M

