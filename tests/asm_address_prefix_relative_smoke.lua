-- tests/asm_address_prefix_relative_smoke.lua
-- Cross-feature regression: explicit address-size prefix + REL symbol.
-- nvim --headless -c "luafile tests/asm_address_prefix_relative_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua").use_working_tree()

    local source = {
        "bits 64",
        "a32 lea rsi, [rel msg]",
        "msg:",
        "mov rax, rax",
    }

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = "asm"

    local ok, parser = pcall(vim.treesitter.get_parser, buffer, "asm")
    assert(ok and parser, "ASM Tree-sitter parser unavailable: " .. tostring(parser))

    local tree = assert(parser:parse()[1], "ASM parser produced no tree")
    local root = tree:root()

    local adapter = require("tracker_hud.adapters.asm.init")
    local registry = require("tracker_hud.adapters.registry")

    local registered, register_err = registry.register(adapter)
    assert(registered, "cannot register ASM adapter: " .. tostring(register_err))

    local configured, config_err =
        registry.configure_adapter_for_buffer("asm", buffer, {})
    assert(configured, "cannot configure ASM adapter: " .. tostring(config_err))

    local instruction_utils =
        require("tracker_hud.adapters.asm.instruction_utils")

    local parsed

    local function visit(node)
        if node:type() == "instruction" then
            local start_row = node:start()

            if start_row + 1 == 2 then
                parsed = instruction_utils.parse_instruction(
                    buffer,
                    node,
                    nil,
                    adapter
                )
            end
        end

        for child in node:iter_children() do
            visit(child)
        end
    end

    visit(root)

    local function expect_equal(actual, expected, label)
        assert(actual == expected,
            label
                .. ": expected "
                .. tostring(expected)
                .. ", got "
                .. tostring(actual))
    end

    assert(parsed,
        "A32 REL instruction did not parse")

    local operand_shape = {}

    for index, operand in ipairs(parsed.operands or {}) do
        operand_shape[#operand_shape + 1] =
            tostring(index)
            .. ":"
            .. tostring(operand.kind)
            .. ":"
            .. tostring(operand.text)
    end

    print(
        "A32 REL parsed shape: mnemonic="
            .. tostring(parsed.mnemonic)
            .. " prefixes="
            .. tostring(#(parsed.prefixes or {}))
            .. " operands=["
            .. table.concat(operand_shape, " | ")
            .. "]"
    )

    expect_equal(parsed.mnemonic, "lea",
        "A32 REL semantic mnemonic")
    expect_equal(#parsed.prefixes, 1,
        "A32 REL prefix count")
    expect_equal(parsed.prefixes[1].text, "a32",
        "A32 REL prefix text")
    expect_equal(parsed.prefixes[1].bits, 32,
        "A32 REL prefix bits")
    expect_equal(#parsed.operands, 2,
        "A32 REL operand count")
    expect_equal(parsed.operands[1].kind, "register",
        "A32 REL operand 1 kind")
    expect_equal(parsed.operands[1].text, "rsi",
        "A32 REL operand 1 text")
    expect_equal(parsed.operands[2].kind, "memory",
        "A32 REL operand 2 kind")
    print("PASS ASM A32 REL: semantic LEA + operands recovered")

    local address = parsed.operands[2].memory
        and parsed.operands[2].memory.normalized
        or nil

    assert(address
        and address.address_mode == "relative"
        and address.address_mode_token == "rel"
        and address.address_size_status == "known"
        and address.address_size_bits == 32
        and address.address_size_source == "explicit_prefix"
        and address.symbol
        and address.symbol.name == "msg",
        "A32 REL memory must retain relative mode, symbol, and 32-bit address size")
    print("PASS ASM A32 REL: relative mode + symbol survive prefix recovery")

    local engine = require("tracker_hud.context_engine")
    local facts = engine.discover_memory_source_operands(
        buffer,
        root,
        adapter,
        2
    )

    assert(#facts == 1,
        "A32 REL line must expose exactly one memory fact")

    local fact = facts[1]

    assert(fact.machine_addresses == nil,
        "no-provider A32 REL fact must not fabricate machine-address evidence")
    assert(fact.symbol_identity
        and fact.symbol_identity.status == "known"
        and fact.symbol_identity.name == "msg"
        and fact.symbol_identity.source_line == 3
        and fact.symbol_identity.forward_reference == true,
        "A32 REL fact must preserve forward source-symbol identity")
    assert(fact.metadata.symbol_machine_address_status == "unknown",
        "source identity must not imply a machine address")
    assert(fact.effective_address.status == "unknown"
        and fact.effective_address.reason
            == "relative address basis unresolved",
        "A32 REL must remain unresolved without machine-address basis")
    print("PASS ASM A32 REL: no-provider REL behavior preserved")

    print("PASS Tracker_HUD ASM A32 REL smoke")
end

local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM A32 REL smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
