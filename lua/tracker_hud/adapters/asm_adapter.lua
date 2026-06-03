-- lua/tracker_hud/adapters/asm_adapter.lua
--
-- ASM Tree-sitter adapter.
--
-- ASM is different from high-level language adapters because register and stack
-- meaning depends on the selected CPU architecture. The adapter owns the ASM
-- language-level behavior, while architecture modules provide machine facts.

local M = {}
local asm_instruction_utils = require("tracker_hud.adapters.asm_instruction_utils")

M.name = "asm"
M.filetypes = {
    "asm",
    "nasm",
    "gas",
    "s",
}

M.capabilities = {
    lexical_scopes = true,
    structural_scopes = false,
    members = false,
    values = false,
    source_jump = true,
    registers = true,
    stack = true,
}


local architecture_modules = {
    ["x86-64"] = "tracker_hud.adapters.asm_arch.x86_64",
}


local architecture_aliases = {
    ["x86-64"] = "x86-64",
    ["x86_64"] = "x86-64",
    ["amd64"] = "x86-64",
    ["x64"] = "x86-64",
}


local function normalize_architecture_name(name)
    if type(name) ~= "string" then
        return nil
    end

    local normalized = name:lower():gsub("^%s+", ""):gsub("%s+$", "")

    return architecture_aliases[normalized] or normalized
end


local function read_buffer_line(bufnr, index)
    local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, index, index + 1, false)

    if not ok or type(lines) ~= "table" then
        return nil
    end

    return lines[1]
end


local function detect_architecture_from_source(bufnr)
    if not bufnr then
        return nil
    end

    local max_scan_lines = 20
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local scan_count = math.min(max_scan_lines, line_count)

    for index = 0, scan_count - 1 do
        local line = read_buffer_line(bufnr, index)

        if type(line) == "string" then
            local arch = line:match("^%s*;%s*arch%s*=%s*([%w%-_]+)%s*;?")

            if arch then
                return normalize_architecture_name(arch)
            end
        end
    end

    return nil
end


local function load_architecture(architecture_name)
    local normalized = normalize_architecture_name(architecture_name) or "x86-64"
    local module_name = architecture_modules[normalized]

    if not module_name then
        normalized = "x86-64"
        module_name = architecture_modules[normalized]
    end

    local ok, architecture = pcall(require, module_name)

    if not ok or type(architecture) ~= "table" then
        return nil
    end

    return architecture
end


local function apply_architecture(architecture)
    if type(architecture) ~= "table" then
        return
    end

    M.architecture = architecture.name or "x86-64"
    M.registers = architecture.registers or { static = {} }
    M.stack = architecture.stack or { static = {} }
end


function M.configure_for_buffer(bufnr, _config)
    local architecture_name = detect_architecture_from_source(bufnr) or "x86-64"
    local architecture = load_architecture(architecture_name)

    apply_architecture(architecture)
end


-- Default architecture so the adapter still provides useful data before
-- configure_for_buffer() is called.
apply_architecture(load_architecture("x86-64"))


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



M.construct_specs = {
    ["label"] = {
        construct = {
            kind = "label",
            label = "Label",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = false,
        },
    },

    ["instruction"] = {
        construct = {
            kind = "instruction",
            label = "Instruction",
        },
    },
}
return M
