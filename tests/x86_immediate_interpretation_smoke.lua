-- tests/x86_immediate_interpretation_smoke.lua
-- Parser-backed x86-64 source-immediate interpretation regression.
-- Requires ERIDU's configured ASM Tree-sitter parser.
-- nvim --headless -c "luafile tests/x86_immediate_interpretation_smoke.lua" -c "qa!"

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local source = {
        "bits 64",
        "mov rax, 0",
        "add rax, 0xFFFFFFFF",
        "mov rax, 0",
        "sub rax, 0xFFFFFFFF",
        "mov rax, 0",
        "add rax, 0x80000000",
        "mov rax, 0",
        "add rax, 0x7FFFFFFF",
        "mov rax, 0",
        "add eax, 0xFFFFFFFF",
        "mov rax, 0",
        "add ax, 0xFFFF",
        "mov rax, 0",
        "add al, 0xFF",
        "mov rax, 0",
        "add rax, 0x100000000",
    }

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = "asm"

    local ok, parser = pcall(vim.treesitter.get_parser, buffer, "asm")
    assert(ok and parser, "ASM Tree-sitter parser unavailable: " .. tostring(parser))
    local trees = parser:parse()
    assert(trees and trees[1], "ASM parser produced no tree")
    local root = trees[1]:root()

    local adapter = require("tracker_hud.adapters.asm.init")
    local registry = require("tracker_hud.adapters.registry")
    local registered, register_err = registry.register(adapter)
    assert(registered, "cannot register ASM adapter: " .. tostring(register_err))

    local configured, config_err =
        registry.configure_adapter_for_buffer("asm", buffer, {})
    assert(configured, "cannot configure ASM adapter: " .. tostring(config_err))

    local engine = require("tracker_hud.context_engine")

    local function state_after(line_number, canonical_name)
        local facts = engine.collect_register_effects(
            { cursor = { line = line_number, column = 200 } },
            adapter,
            {
                bufnr = buffer,
                root_node = root,
                limit_position = {
                    line = line_number + 1,
                    column = 0,
                },
            }
        )

        local found

        for _, fact in ipairs(facts or {}) do
            local canonical = fact.metadata and fact.metadata.canonical_name

            if canonical == canonical_name or fact.name == canonical_name then
                assert(not found,
                    "canonical register family must reduce to one latest state fact")
                found = fact
            end
        end

        return assert(found,
            "missing " .. canonical_name .. " state after line "
                .. tostring(line_number))
    end

    local add_minus_one = state_after(3, "rax")
    assert(add_minus_one.value == "18446744073709551615"
        and add_minus_one.metadata.source_integer_raw_value == "4294967295"
        and add_minus_one.metadata.source_integer_value == "-1"
        and add_minus_one.metadata.source_integer_bits == 32
        and add_minus_one.metadata.source_integer_bits_source == "target_capped"
        and add_minus_one.metadata.pre_width_write_value == "-1"
        and add_minus_one.metadata.value_wrapped == true,
        "RAX ADD 0xFFFFFFFF must interpret imm32 as -1 before wrapping")
    print("PASS x86 immediate interpretation: RAX ADD sign-interprets imm32")

    local sub_minus_one = state_after(5, "rax")
    assert(sub_minus_one.value == "1"
        and sub_minus_one.metadata.source_integer_value == "-1"
        and sub_minus_one.metadata.source_integer_bits == 32
        and sub_minus_one.metadata.pre_width_write_value == "1"
        and sub_minus_one.metadata.value_wrapped == false,
        "RAX SUB 0xFFFFFFFF must subtract sign-interpreted -1")
    print("PASS x86 immediate interpretation: RAX SUB uses interpreted source before sign")

    local min_imm32 = state_after(7, "rax")
    assert(min_imm32.value == "18446744071562067968"
        and min_imm32.metadata.source_integer_raw_value == "2147483648"
        and min_imm32.metadata.source_integer_value == "-2147483648"
        and min_imm32.metadata.source_integer_bits == 32,
        "0x80000000 must become signed imm32 minimum for RAX arithmetic")
    print("PASS x86 immediate interpretation: imm32 sign boundary minimum")

    local max_imm32 = state_after(9, "rax")
    assert(max_imm32.value == "2147483647"
        and max_imm32.metadata.source_integer_value == "2147483647"
        and max_imm32.metadata.source_integer_bits == 32
        and max_imm32.metadata.value_wrapped == false,
        "0x7FFFFFFF must remain positive signed imm32 maximum")
    print("PASS x86 immediate interpretation: imm32 sign boundary maximum")

    local eax = state_after(11, "rax")
    assert(eax.name == "eax"
        and eax.value == "0x00000000FFFFFFFF"
        and eax.metadata.write_value == "4294967295"
        and eax.metadata.source_integer_value == "-1"
        and eax.metadata.source_integer_bits == 32
        and eax.metadata.source_integer_bits_source == "target",
        "EAX immediate interpretation must derive 32 source bits")
    print("PASS x86 immediate interpretation: EAX derives 32 source bits")

    local ax = state_after(13, "rax")
    assert(ax.name == "ax"
        and ax.value == "0x000000000000FFFF"
        and ax.metadata.write_value == "65535"
        and ax.metadata.source_integer_value == "-1"
        and ax.metadata.source_integer_bits == 16
        and ax.metadata.source_integer_bits_source == "target",
        "AX immediate interpretation must derive 16 source bits")
    print("PASS x86 immediate interpretation: AX derives 16 source bits")

    local al = state_after(15, "rax")
    assert(al.name == "al"
        and al.value == "0x00000000000000FF"
        and al.metadata.write_value == "255"
        and al.metadata.source_integer_value == "-1"
        and al.metadata.source_integer_bits == 8
        and al.metadata.source_integer_bits_source == "target",
        "AL immediate interpretation must derive 8 source bits")
    print("PASS x86 immediate interpretation: AL derives 8 source bits")

    local overflow = state_after(17, "rax")
    assert(overflow.resolved == false
        and overflow.metadata.write_resolved == false
        and overflow.metadata.source_integer_raw_value == "4294967296"
        and overflow.metadata.source_integer_value == nil
        and overflow.metadata.source_integer_bits == 32
        and overflow.metadata.source_integer_error == "value does not fit source width",
        "unencodable RAX arithmetic immediate must fail closed")
    print("PASS x86 immediate interpretation: out-of-range imm32 fails closed")

    print("PASS Tracker_HUD x86 immediate interpretation smoke")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL x86 immediate interpretation smoke: "
        .. tostring(err) .. "\n")
    error(err)
end
