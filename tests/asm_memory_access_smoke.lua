-- tests/asm_memory_access_smoke.lua
-- Parser-backed x86-64 memory access-intent regression.
-- nvim --headless -c "luafile tests/asm_memory_access_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua").use_working_tree()

    local source = {
        "bits 64",
        "mov rax, [rbp + 8]",
        "mov [rsp + 8], rax",
        "lea rsi, [rel msg]",
        "inc qword [rax]",
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

    local read = one(2)
    assert(read.access == "read"
        and read.metadata.access_intent == "read"
        and read.metadata.access_declared == true
        and read.metadata.execution_status == "not_observed"
        and read.address.base.name == "rbp"
        and read.address.displacement.value == "8",
        "MOV source memory must carry read intent without execution claim")
    print("PASS ASM memory access: MOV source memory is read")

    local write = one(3)
    assert(write.access == "write"
        and write.metadata.access_intent == "write"
        and write.metadata.access_declared == true
        and write.metadata.execution_status == "not_observed"
        and write.address.base.name == "rsp",
        "MOV destination memory must carry write intent")
    print("PASS ASM memory access: MOV destination memory is write")

    local address_only = one(4)
    assert(address_only.access == "address_only"
        and address_only.metadata.access_intent == "address_only"
        and address_only.metadata.access_declared == true
        and address_only.address.address_mode == "relative"
        and address_only.address.symbol.name == "msg",
        "LEA must classify its memory syntax as address_only")
    print("PASS ASM memory access: LEA is address_only")

    local focus = engine.discover_register_source_occurrences(
        buffer,
        root,
        adapter,
        4
    )
    local saw_symbol_component = false

    for _, occurrence in ipairs(focus or {}) do
        if occurrence.kind == "memory_component"
            and occurrence.text == "msg"
        then
            local metadata = occurrence.metadata or {}

            assert(metadata.memory_access_intent == "address_only"
                and metadata.memory_access_declared == true
                and metadata.memory_execution_status == "not_observed",
                "Inspect memory metadata must reuse normalized access intent")
            saw_symbol_component = true
        end
    end

    assert(saw_symbol_component,
        "LEA symbol memory component missing from source occurrences")
    print("PASS ASM memory access: Inspect reuses address-only intent")

    local unknown = one(5)
    assert(unknown.access == "unknown"
        and unknown.metadata.access_intent == "unknown"
        and unknown.metadata.access_declared == false
        and unknown.metadata.execution_status == "not_observed"
        and unknown.address.memory_size_bits == 64,
        "undeclared memory semantics must stay unknown without losing structure")
    print("PASS ASM memory access: undeclared instruction stays unknown")

    vim.api.nvim_set_current_buf(buffer)
    vim.api.nvim_win_set_cursor(0, { 4, 0 })
    local context = require("tracker_hud.context")
        .get_cursor_context(buffer, {})

    assert(#(context.source_memory_operands or {}) == 3,
        "cursor context must contain visible memory operands only")
    assert(context.source_memory_operands[1].access == "read"
        and context.source_memory_operands[2].access == "write"
        and context.source_memory_operands[3].access == "address_only",
        "context lifecycle lost normalized access intent")
    for _, fact in ipairs(context.source_memory_operands) do
        assert(fact.metadata.execution_status == "not_observed",
            "source access intent must not become execution proof")
    end
    print("PASS ASM memory access: context preserves ON/PAST access intent")

    print("PASS Tracker_HUD ASM memory access-intent smoke")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL ASM memory access-intent smoke: "
        .. tostring(err) .. "\n")
    error(err)
end
