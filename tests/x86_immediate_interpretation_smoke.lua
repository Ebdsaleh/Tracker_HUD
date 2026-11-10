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

    local function expect_equal(actual, expected, label)
        assert(actual == expected,
            label
                .. ": expected "
                .. vim.inspect(expected)
                .. ", got "
                .. vim.inspect(actual))
    end

    local function find_effect(effect_name)
        for _, rules in pairs(adapter.register_effects or {}) do
            for _, rule in ipairs(rules or {}) do
                if rule.effect and rule.effect.name == effect_name then
                    return rule.effect
                end
            end
        end

        return nil
    end

    local active_add = assert(
        find_effect("add_register_immediate"),
        "configured ASM adapter lost add_register_immediate"
    )
    assert(type(active_add.value_delta_operand_interpretation) == "table",
        "configured ASM adapter lost ADD immediate interpretation policy")
    expect_equal(
        active_add.value_delta_operand_interpretation.kind,
        "signed_bits",
        "configured ADD immediate interpretation kind"
    )
    expect_equal(
        active_add.value_delta_operand_interpretation.bits_from,
        "target",
        "configured ADD immediate width source"
    )
    expect_equal(
        active_add.value_delta_operand_interpretation.max_bits,
        32,
        "configured ADD immediate maximum width"
    )
    print("PASS x86 immediate interpretation: configured adapter retains source policy")

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
    expect_equal(
        add_minus_one.metadata.effect,
        "add_register_immediate",
        "RAX ADD latest effect"
    )
    expect_equal(
        add_minus_one.value,
        "18446744073709551615",
        "RAX ADD final value"
    )
    expect_equal(
        add_minus_one.metadata.source_integer_raw_value,
        "4294967295",
        "RAX ADD raw immediate"
    )
    expect_equal(
        add_minus_one.metadata.source_integer_value,
        "-1",
        "RAX ADD interpreted immediate"
    )
    expect_equal(
        add_minus_one.metadata.source_integer_bits,
        32,
        "RAX ADD source width"
    )
    expect_equal(
        add_minus_one.metadata.source_integer_bits_source,
        "target_capped",
        "RAX ADD source width origin"
    )
    expect_equal(
        add_minus_one.metadata.pre_width_write_value,
        "-1",
        "RAX ADD pre-width result"
    )
    expect_equal(
        add_minus_one.metadata.value_wrapped,
        true,
        "RAX ADD destination wrap flag"
    )
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
    expect_equal(eax.name, "eax", "EAX source alias")
    expect_equal(eax.value, "0x00000000FFFFFFFF", "EAX canonical value")
    expect_equal(eax.metadata.write_value, "4294967295", "EAX written value")
    expect_equal(eax.metadata.source_integer_value, "-1", "EAX interpreted immediate")
    expect_equal(eax.metadata.source_integer_bits, 32, "EAX source width")
    expect_equal(
        eax.metadata.source_integer_bits_source,
        "target",
        "EAX source width origin"
    )
    print("PASS x86 immediate interpretation: EAX derives 32 source bits")

    local ax = state_after(13, "rax")
    expect_equal(ax.name, "ax", "AX source alias")
    expect_equal(ax.value, "0x000000000000FFFF", "AX canonical value")
    expect_equal(ax.metadata.write_value, "65535", "AX written value")
    expect_equal(ax.metadata.source_integer_value, "-1", "AX interpreted immediate")
    expect_equal(ax.metadata.source_integer_bits, 16, "AX source width")
    expect_equal(
        ax.metadata.source_integer_bits_source,
        "target",
        "AX source width origin"
    )
    print("PASS x86 immediate interpretation: AX derives 16 source bits")

    local al = state_after(15, "rax")
    expect_equal(al.name, "al", "AL source alias")
    expect_equal(al.value, "0x00000000000000FF", "AL canonical value")
    expect_equal(al.metadata.write_value, "255", "AL written value")
    expect_equal(al.metadata.source_integer_value, "-1", "AL interpreted immediate")
    expect_equal(al.metadata.source_integer_bits, 8, "AL source width")
    expect_equal(
        al.metadata.source_integer_bits_source,
        "target",
        "AL source width origin"
    )
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
