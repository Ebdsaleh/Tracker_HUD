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
M.default_variant = "x86-64"
M.variant_directive = "arch"


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


local function normalize_variant_name(name)
    if type(name) ~= "string" then
        return nil
    end

    local normalized = name:lower():gsub("^%s+", ""):gsub("%s+$", "")

    return M.variant_aliases[normalized] or normalized
end


local function read_buffer_line(bufnr, index)
    local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, index, index + 1, false)

    if not ok or type(lines) ~= "table" then
        return nil
    end

    return lines[1]
end


local function detect_variant_from_source(bufnr)
    if not bufnr then
        return nil
    end

    local directive = M.variant_directive or "arch"
    local max_scan_lines = 20
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local scan_count = math.min(max_scan_lines, line_count)

    for index = 0, scan_count - 1 do
        local line = read_buffer_line(bufnr, index)

        if type(line) == "string" then
            local pattern = "^%s*;%s*"
                .. directive
                .. "%s*=%s*([%w%-_]+)%s*;?"

            local variant_name = line:match(pattern)

            if variant_name then
                return normalize_variant_name(variant_name)
            end
        end
    end

    return nil
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

    -- Variant-owned descriptive specs.
    M.registers = variant.registers or { static = {} }
    M.register_families = variant.register_families or {}
    M.stack = variant.stack or { static = {} }
    M.scope_members = variant.scope_members or { symbols = {} }
    M.range_scopes = variant.range_scopes or {}
    M.register_effects = variant.register_effects or {}
    M.stack_effects = variant.stack_effects or {}
    M.boundary_effects = variant.boundary_effects or {}
    M.syscall = variant.syscall

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
