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

local asm_instruction_utils = require("tracker_hud.adapters.asm_instruction_utils")


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
    M.stack = variant.stack or { static = {} }
    M.scope_members = variant.scope_members or { symbols = {} }
    M.range_scopes = variant.range_scopes or {}

    -- Optional override point if a future ASM variant needs different grammar specs.
    if type(variant.construct_specs) == "table" then
        M.construct_specs = variant.construct_specs
    end
end



function M.configure_for_buffer(bufnr, _config)
    local variant_name = detect_variant_from_source(bufnr) or M.default_variant
    local variant = load_variant(variant_name)

    apply_variant(variant)
end


-- Default variant so the adapter still exposes useful specs before
-- configure_for_buffer() is called.
apply_variant(load_variant(M.default_variant))


local function get_static_register_spec(name)
    if type(name) ~= "string" then
        return nil
    end

    local normalized = name:lower()

    for _, register_spec in ipairs((M.registers and M.registers.static) or {}) do
        if type(register_spec) == "table"
            and type(register_spec.name) == "string"
            and register_spec.name:lower() == normalized
        then
            return register_spec
        end
    end

    return nil
end


local function make_register_fact(name, value, role, source_line)
    if type(name) ~= "string" or name == "" then
        return nil
    end

    local static_spec = get_static_register_spec(name) or {}

    return {
        name = name:lower(),
        kind = static_spec.kind or "unknown",
        value = value,
        role = role or static_spec.role,
        source = "instruction",
        source_line = source_line,
        metadata = {
            architecture = M.architecture,
            variant = M.active_variant_name,
        },
    }
end


local function collect_instruction_nodes(root_node, cursor_line, result)
    result = result or {}

    if not root_node then
        return result
    end

    if root_node:type() == "instruction" then
        local line = root_node:start() + 1

        if not cursor_line or line <= cursor_line then
            table.insert(result, root_node)
        end

        return result
    end

    for child in root_node:iter_children() do
        collect_instruction_nodes(child, cursor_line, result)
    end

    return result
end


local function apply_mov_rule(facts_by_register, instruction)
    if not instruction or instruction.mnemonic ~= "mov" then
        return
    end

    local dst = instruction.operands and instruction.operands[1]
    local src = instruction.operands and instruction.operands[2]

    if not dst or not src then
        return
    end

    if dst.kind ~= "register" then
        return
    end

    if src.kind ~= "integer" then
        return
    end

    facts_by_register[dst.text:lower()] = make_register_fact(
        dst.text,
        src.text,
        "written by mov",
        instruction.source_line
    )
end


local function apply_xor_zero_rule(facts_by_register, instruction)
    if not instruction or instruction.mnemonic ~= "xor" then
        return
    end

    local left = instruction.operands and instruction.operands[1]
    local right = instruction.operands and instruction.operands[2]

    if not left or not right then
        return
    end

    if left.kind ~= "register" or right.kind ~= "register" then
        return
    end

    if left.text:lower() ~= right.text:lower() then
        return
    end

    facts_by_register[left.text:lower()] = make_register_fact(
        left.text,
        "0",
        "zeroed by xor",
        instruction.source_line
    )
end


function M.collect_registers(context, opts)
    opts = opts or {}

    local bufnr = opts.bufnr
    local root_node = opts.root_node

    if not bufnr or not root_node then
        return {}
    end

    local cursor_line = context
        and context.cursor
        and context.cursor.line

    local instruction_nodes = collect_instruction_nodes(root_node, cursor_line)
    local facts_by_register = {}

    for _, instruction_node in ipairs(instruction_nodes) do
        local instruction = asm_instruction_utils.parse_instruction(bufnr, instruction_node)

        apply_mov_rule(facts_by_register, instruction)
        apply_xor_zero_rule(facts_by_register, instruction)
    end

    local facts = {}

    for _, fact in pairs(facts_by_register) do
        table.insert(facts, fact)
    end

    return facts
end


return M
