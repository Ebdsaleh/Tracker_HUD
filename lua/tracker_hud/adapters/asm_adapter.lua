-- lua/tracker_hud/adapters/asm_adapter.lua
--
-- ASM Tree-sitter adapter.
--
-- ASM is different from high-level language adapters because register and stack
-- meaning depends on the selected CPU architecture. The adapter owns the ASM
-- language-level behavior, while architecture modules provide machine facts.

local M = {}

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

    ["directive"] = {
        construct = {
            kind = "directive",
            label = "Directive",
        },
    },
}

return M
