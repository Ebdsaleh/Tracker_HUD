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
    heap = true,
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


local function detect_variant_from_source(bufnr)
    return variant_utils.detect_from_buffer(bufnr, {
        directive = M.variant_directive or "arch",
        comment_prefixes = M.variant_comment_prefixes,
        aliases = M.variant_aliases,
        max_scan_lines = 20,
    })
end


local function detect_target_from_source(bufnr, target_key)
    if type(target_key) ~= "string" then
        return nil
    end

    local directive = M.target_directives[target_key]

    if type(directive) ~= "string" or directive == "" then
        return nil
    end

    local value = variant_utils.detect_from_buffer(bufnr, {
        directive = directive,
        comment_prefixes = M.variant_comment_prefixes,
        aliases = nil,
        max_scan_lines = 20,
    })

    if not value then
        return nil
    end

    return {
        key = target_key,
        directive = directive,
        value = value,
    }
end


local function find_directive_line(bufnr, directive, value)
    if not bufnr
        or type(directive) ~= "string"
        or directive == ""
        or type(value) ~= "string"
        or value == ""
    then
        return nil
    end

    local max_scan_lines = 20
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local scan_count = math.min(line_count, max_scan_lines)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, scan_count, false)

    local pattern = directive .. "%s*=%s*" .. vim.pesc(value)

    for index, line in ipairs(lines) do
        local start_column, end_column = line:find(pattern)

        if start_column then
            return {
                line = index,
                column = start_column - 1,
                end_column = end_column,
            }
        end
    end

    return nil
end


local function detect_targets_from_source(bufnr)
    local architecture = detect_target_from_source(bufnr, "architecture")
    local platform = detect_target_from_source(bufnr, "platform")
    local abi = detect_target_from_source(bufnr, "abi")
    local syntax = detect_target_from_source(bufnr, "syntax")
    local mode = detect_target_from_source(bufnr, "mode")

    local source_targets = {
        architecture = architecture and normalize_variant_name(architecture.value),
        platform = platform and normalize_target_value(platform.value),
        abi = abi and normalize_target_value(abi.value),
        syntax = syntax and normalize_target_value(syntax.value),
        mode = mode and normalize_target_value(mode.value),

        locations = {},
    }

    local detected = {
        architecture = architecture,
        platform = platform,
        abi = abi,
        syntax = syntax,
        mode = mode,
    }

    for key, detected_target in pairs(detected) do
        if detected_target and detected_target.value then
            source_targets.locations[key] = find_directive_line(
                bufnr,
                detected_target.directive,
                detected_target.value
            )
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


local function add_target_diagnostic(diagnostics, key, value, message, location)
    if type(diagnostics) ~= "table" then
        return
    end

    local diagnostic = {
        key = key,
        value = value,
        message = message,
    }

    if type(location) == "table" then
        diagnostic.line = location.line
        diagnostic.column = location.column
        diagnostic.end_column = location.end_column
    end

    table.insert(diagnostics, diagnostic)
end


local function resolve_targets(bufnr, config, variant)
    local config_targets = normalize_target_table(config and config.targets)
    local source_targets = detect_targets_from_source(bufnr)
    local diagnostics = {}

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
    M.stack = variant.stack or { static = {} }
    M.scope_members = variant.scope_members or { symbols = {} }
    M.range_scopes = variant.range_scopes or {}
    M.register_effects = variant.register_effects or {}
    M.stack_effects = variant.stack_effects or {}
    M.boundary_effects = variant.boundary_effects or {}
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
end

-- Default variant so the adapter still exposes useful specs before
-- configure_adapter_for_buffer() is called.
local default_variant = load_variant(M.default_variant)

apply_variant(default_variant)

M.active_targets = resolve_targets(nil, nil, default_variant or {})


return M


