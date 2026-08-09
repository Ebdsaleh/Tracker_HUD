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
    abi= "abi",
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

    return variant_utils.detect_from_buffer(bufnr, {
        directive = directive,
        comment_prefixes = M.variant_comment_prefixes,
        aliases = nil,
        max_scan_lines = 20,
    })
end


local function detect_targets_from_source(bufnr)
    return {
        architecture = detect_target_from_source(bufnr, "architecture"),
        platform = detect_target_from_source(bufnr, "platform"),
        abi = detect_target_from_source(bufnr, "abi"),
        syntax = detect_target_from_source(bufnr, "syntax"),
        mode = detect_target_from_source(bufnr, "mode"),
    }

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


local function resolve_targets(bufnr, config, variant)
    local config_targets = normalize_target_table(config and config.targets)
    local source_targets = detect_targets_from_source(bufnr)

    local resolved = {
        architecture = source_targets.architecture
            or config_targets.architecture
            or M.default_variant,

        platform = source_targets.platform
            or config_targets.platform
            or variant.default_platform,

        abi = source_targets.abi
            or config_targets.abi,

        syntax = source_targets.syntax
            or config_targets.syntax,

        mode = source_targets.mode
            or config_targets.mode,
    }

    if type(variant.platform_aliases) == "table" and resolved.platform then
        resolved.platform = variant.platform_aliases[resolved.platform] or resolved.platform
    end

    if type(variant.platforms) == "table"
        and resolved.platform
        and type(variant.platforms[resolved.platform]) == "table"
        and not resolved.abi
    then
        resolved.abi = variant.platforms[resolved.platform].abi
    end

    if not resolved.mode and type(variant.metadata) == "table" and variant.metadata.bits == 64 then
        resolved.mode = "long64"
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


