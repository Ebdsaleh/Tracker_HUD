-- tests/asm_effective_address_smoke.lua
-- Parser-backed x86-64 effective-address evaluation regression.
-- nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua").use_working_tree()

    local source = {
        "bits 64",
        "mov rbp, 0x1000",
        "mov rcx, 3",
        "mov rax, [rbp + rcx*4 - 8]",
        "mov rdx, [rbp + r8*2]",
        "mov rbx, [abs 0x1234]",
        "lea rsi, [rel msg]",
        "mov rax, 0xFFFFFFFFFFFFFFFF",
        "mov rbx, [rax + 1]",
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

    assert(adapter.metadata
        and adapter.metadata.architecture == "x86-64"
        and adapter.metadata.bits == 64,
        "configured ASM adapter must expose active architecture metadata")
    print("PASS ASM effective address: active architecture width is available")

    local engine = require("tracker_hud.context_engine")

    local function one(line_number)
        local facts = engine.discover_memory_source_operands(
            buffer,
            root,
            adapter,
            line_number
        )

        assert(#facts == 1,
            "expected one memory operand on line " .. tostring(line_number))

        return facts[1]
    end

    local computed = one(4)
    assert(computed.effective_address.status == "known"
        and computed.effective_address.value == "4100"
        and computed.effective_address.bits == 64
        and computed.effective_address.wrapped == false
        and computed.effective_address.components.base.value == "4096"
        and computed.effective_address.components.index.value == "3"
        and computed.effective_address.components.scale == "4"
        and computed.effective_address.components.displacement == "-8"
        and computed.metadata.effective_address_status == "known"
        and computed.metadata.effective_address_value == "4100"
        and computed.metadata.execution_status == "not_observed",
        "known base/index/scale/displacement must evaluate before the memory instruction")
    print("PASS ASM effective address: proven pre-instruction state evaluates exactly")

    local focus = engine.discover_register_source_occurrences(
        buffer,
        root,
        adapter,
        4
    )
    local saw_base = false
    local saw_index = false

    for _, occurrence in ipairs(focus or {}) do
        if occurrence.kind == "memory_component"
            and occurrence.text == "rbp"
        then
            local metadata = occurrence.metadata or {}

            assert(metadata.memory_effective_address_status == "known"
                and metadata.memory_effective_address_value == "4100"
                and metadata.memory_effective_address_bits == 64
                and metadata.memory_effective_address_wrapped == false,
                "Inspect base component lost effective-address certainty")
            saw_base = true
        elseif occurrence.kind == "memory_component"
            and occurrence.text == "rcx"
        then
            local metadata = occurrence.metadata or {}

            assert(metadata.memory_effective_address_status == "known"
                and metadata.memory_effective_address_value == "4100",
                "Inspect index component lost effective-address certainty")
            saw_index = true
        end
    end

    assert(saw_base and saw_index,
        "Inspect did not expose both effective-address register components")
    print("PASS ASM effective address: Inspect reuses evaluated address certainty")

    local unresolved = one(5)
    assert(unresolved.effective_address.status == "unknown"
        and unresolved.effective_address.reason == "index register unresolved"
        and unresolved.effective_address.details.register == "r8"
        and unresolved.metadata.effective_address_value == nil
        and unresolved.metadata.execution_status == "not_observed",
        "unknown index register must prevent effective-address fabrication")
    print("PASS ASM effective address: unknown register fails closed")

    local absolute = one(6)
    assert(absolute.effective_address.status == "known"
        and absolute.effective_address.value == "4660"
        and absolute.effective_address.bits == 64,
        "absolute numeric memory expression must evaluate exactly")
    print("PASS ASM effective address: absolute numeric address evaluates")

    local symbolic = one(7)
    assert(symbolic.effective_address.status == "unknown"
        and symbolic.effective_address.reason
            == "relative address basis unresolved"
        and symbolic.effective_address.details.symbol == "msg"
        and symbolic.metadata.execution_status == "not_observed",
        "REL symbol must remain unresolved without instruction-position basis")
    print("PASS ASM effective address: symbolic REL address stays unresolved")

    local rel_focus = engine.discover_register_source_occurrences(
        buffer,
        root,
        adapter,
        7
    )
    local saw_symbol = false

    for _, occurrence in ipairs(rel_focus or {}) do
        if occurrence.kind == "memory_component"
            and occurrence.text == "msg"
        then
            local metadata = occurrence.metadata or {}

            assert(metadata.memory_effective_address_status == "unknown"
                and metadata.memory_effective_address_reason
                    == "relative address basis unresolved",
                "Inspect REL component must preserve unresolved instruction basis")
            saw_symbol = true
        end
    end

    assert(saw_symbol,
        "Inspect did not expose REL symbol component")
    print("PASS ASM effective address: Inspect preserves unresolved REL basis")

    local wrapped = one(9)
    assert(wrapped.effective_address.status == "known"
        and wrapped.effective_address.value == "0"
        and wrapped.effective_address.wrapped == true
        and wrapped.effective_address.components.exact
            == "18446744073709551616",
        "64-bit address arithmetic must wrap only at target-width boundary")
    print("PASS ASM effective address: 64-bit address wrap is explicit")

    vim.api.nvim_set_current_buf(buffer)
    vim.api.nvim_win_set_cursor(0, { 9, 0 })

    local context = require("tracker_hud.context")
        .get_cursor_context(buffer, {})

    local saw_computed = false
    local saw_unknown = false
    local saw_absolute = false
    local saw_symbolic = false
    local saw_wrapped = false

    for _, fact in ipairs(context.source_memory_operands or {}) do
        if fact.source_line == 4 then
            saw_computed = fact.effective_address.value == "4100"
        elseif fact.source_line == 5 then
            saw_unknown = fact.effective_address.status == "unknown"
        elseif fact.source_line == 6 then
            saw_absolute = fact.effective_address.value == "4660"
        elseif fact.source_line == 7 then
            saw_symbolic = fact.effective_address.status == "unknown"
        elseif fact.source_line == 9 then
            saw_wrapped = fact.effective_address.value == "0"
        end

        assert(fact.metadata.execution_status == "not_observed",
            "known effective address must not become execution proof")
    end

    assert(saw_computed
        and saw_unknown
        and saw_absolute
        and saw_symbolic
        and saw_wrapped,
        "normal context must preserve per-source effective-address certainty")
    print("PASS ASM effective address: context preserves source-time address certainty")

    print("PASS Tracker_HUD ASM effective-address smoke")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL ASM effective-address smoke: "
        .. tostring(err) .. "\n")
    error(err)
end
