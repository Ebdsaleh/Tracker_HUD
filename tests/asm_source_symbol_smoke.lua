-- tests/asm_source_symbol_smoke.lua
-- Parser-backed ASM source-symbol identity regression.
-- nvim --headless -c "luafile tests/asm_source_symbol_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua").use_working_tree()

    local source = {
        "bits 64",
        "lea rsi, [rel msg]",
        "lea rdi, [rel missing]",
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

    local scope_members = require("tracker_hud.scope_members")
    local members = scope_members.collect(buffer, root, adapter)

    local saw_msg_label = false

    for _, member in ipairs(members or {}) do
        if member.kind == "label"
            and member.name == "msg"
            and member.source_start_line == 4
        then
            saw_msg_label = true
        end
    end

    assert(saw_msg_label,
        "ASM scope-member discovery did not expose label msg")
    print("PASS ASM source symbol: label declaration discovered")

    local engine = require("tracker_hud.context_engine")

    local forward = engine.discover_memory_source_operands(
        buffer,
        root,
        adapter,
        2
    )

    assert(#forward == 1,
        "line 2 must expose one memory operand")

    local forward_fact = forward[1]
    local identity = forward_fact.symbol_identity

    assert(identity
        and identity.status == "known"
        and identity.name == "msg"
        and identity.kind == "label"
        and identity.source_line == 4
        and identity.forward_reference == true
        and identity.machine_address_status == "unknown"
        and identity.machine_address == nil
        and forward_fact.metadata.source_symbol_status == "known"
        and forward_fact.metadata.source_symbol_line == 4
        and forward_fact.metadata.source_symbol_forward_reference == true
        and forward_fact.metadata.symbol_machine_address_status == "unknown"
        and forward_fact.effective_address.status == "unknown"
        and forward_fact.effective_address.reason
            == "relative address basis unresolved",
        "forward REL label identity must resolve without inventing machine address")
    print("PASS ASM source symbol: forward REL label identity resolves")

    local missing = engine.discover_memory_source_operands(
        buffer,
        root,
        adapter,
        3
    )

    assert(#missing == 1,
        "line 3 must expose one memory operand")

    local missing_identity = missing[1].symbol_identity

    assert(missing_identity
        and missing_identity.status == "unknown"
        and missing_identity.name == "missing"
        and missing_identity.reason
            == "source symbol declaration not found"
        and missing_identity.machine_address_status == "unknown"
        and missing[1].effective_address.status == "unknown",
        "missing REL label must remain unresolved")
    print("PASS ASM source symbol: missing label fails closed")

    local focus = engine.discover_register_source_occurrences(
        buffer,
        root,
        adapter,
        2
    )

    local saw_msg_component = false

    for _, occurrence in ipairs(focus or {}) do
        if occurrence.kind == "memory_component"
            and occurrence.text == "msg"
        then
            local metadata = occurrence.metadata or {}

            assert(metadata.source_symbol_status == "known"
                and metadata.source_symbol_name == "msg"
                and metadata.source_symbol_kind == "label"
                and metadata.source_symbol_line == 4
                and metadata.source_symbol_forward_reference == true
                and metadata.symbol_machine_address_status == "unknown"
                and metadata.memory_effective_address_status == "unknown"
                and metadata.memory_effective_address_reason
                    == "relative address basis unresolved",
                "Inspect must reuse source-symbol identity without machine-address claim")
            saw_msg_component = true
        end
    end

    assert(saw_msg_component,
        "Inspect did not expose msg memory component")
    print("PASS ASM source symbol: Inspect reuses source-label identity")

    vim.api.nvim_set_current_buf(buffer)
    vim.api.nvim_win_set_cursor(0, { 5, 0 })

    local context = require("tracker_hud.context")
        .get_cursor_context(buffer, {})

    local by_line = {}

    for _, fact in ipairs(context.source_memory_operands or {}) do
        by_line[fact.source_line] = fact
    end

    assert(by_line[2]
        and by_line[2].symbol_identity
        and by_line[2].symbol_identity.status == "known"
        and by_line[2].symbol_identity.source_line == 4
        and by_line[3]
        and by_line[3].symbol_identity
        and by_line[3].symbol_identity.status == "unknown",
        "normal context must preserve source-symbol identity certainty")
    print("PASS ASM source symbol: context preserves source identity certainty")

    print("PASS Tracker_HUD ASM source-symbol identity smoke")
end

local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM source-symbol identity smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
