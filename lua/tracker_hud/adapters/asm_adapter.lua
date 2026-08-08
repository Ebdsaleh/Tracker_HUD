-- lua/tracker_hud/adapters/asm_adapter.lua
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
    ["x86-64"] = "tracker_hud.adapters.asm_arch.x86_64",
}


M.variant_aliases = {
    ["x86-64"] = "x86-64",
    ["x86_64"] = "x86-64",
    ["amd64"] = "x86-64",
    ["x64"] = "x86-64",
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
    module = "tracker_hud.adapters.asm_instruction_utils",
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


local function detect_variant_from_source(bufnr)
    return variant_utils.detect_from_buffer(bufnr, {
        directive = M.variant_directive or "arch",
        comment_prefixes = M.variant_comment_prefixes,
        aliases = M.variant_aliases,
        max_scan_lines = 20,
    })
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


function M.configure_adapter_for_buffer(bufnr, _config)
    local variant_name = detect_variant_from_source(bufnr) or M.default_variant
    local variant = load_variant(variant_name)

    apply_variant(variant)
end


-- Default variant so the adapter still exposes useful specs before
-- configure_adapter_for_buffer() is called.
apply_variant(load_variant(M.default_variant))


return M
