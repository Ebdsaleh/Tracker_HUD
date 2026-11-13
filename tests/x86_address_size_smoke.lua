-- tests/x86_address_size_smoke.lua
-- Parser-backed x86-64 address-size semantics regression.
-- nvim --headless -c "luafile tests/x86_address_size_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua").use_working_tree()

    local source = {
        "bits 64",
        "mov rax, 0x00000000FFFFFFF0",
        "mov rcx, 2",
        "mov rbx, qword [eax + ecx*8 + 0x20]",
        "mov rbx, qword [rax + rcx*8 + 0x20]",
        "mov rbx, [rax + ecx*4]",
        "mov rbx, [ax]",
        "mov rbx, [abs 0x1234]",
        "a32 lea eax, [rip + 16]",
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

    local address32 = one(4)
    assert(address32.address.memory_size_bits == 64
        and address32.address.address_size_status == "known"
        and address32.address.address_size_bits == 32
        and address32.address.address_size_source == "register_width"
        and address32.metadata.address_size_bits == 32
        and address32.effective_address.status == "known"
        and address32.effective_address.bits == 32
        and address32.effective_address.components.base.value == "4294967280"
        and address32.effective_address.components.index.value == "2"
        and address32.effective_address.components.exact == "4294967328"
        and address32.effective_address.value == "32"
        and address32.effective_address.wrapped == true,
        "qword data width must remain independent from 32-bit address arithmetic")
    print("PASS x86 address size: qword data with 32-bit effective address")

    local address64 = one(5)
    assert(address64.address.memory_size_bits == 64
        and address64.address.address_size_status == "known"
        and address64.address.address_size_bits == 64
        and address64.address.address_size_source == "register_width"
        and address64.effective_address.status == "known"
        and address64.effective_address.bits == 64
        and address64.effective_address.value == "4294967328"
        and address64.effective_address.wrapped == false,
        "64-bit address registers must keep 64-bit effective-address width")
    print("PASS x86 address size: 64-bit register addressing remains 64-bit")

    local mixed = one(6)
    assert(mixed.address.address_size_status == "unknown"
        and mixed.address.address_size_bits == nil
        and mixed.address.address_size_reason == "mixed address register widths"
        and mixed.effective_address.status == "unknown"
        and mixed.effective_address.reason == "address size unresolved",
        "mixed 32/64-bit address registers must fail closed")
    print("PASS x86 address size: mixed address register widths fail closed")

    local unsupported = one(7)
    assert(unsupported.address.address_size_status == "unknown"
        and unsupported.address.address_size_reason
            == "unsupported address register width"
        and unsupported.effective_address.status == "unknown"
        and unsupported.effective_address.reason == "address size unresolved",
        "16-bit address register in long mode must fail closed")
    print("PASS x86 address size: unsupported 16-bit address form fails closed")

    local absolute = one(8)
    assert(absolute.address.address_size_status == "known"
        and absolute.address.address_size_bits == 64
        and absolute.address.address_size_source == "default"
        and absolute.effective_address.status == "known"
        and absolute.effective_address.bits == 64
        and absolute.effective_address.value == "4660",
        "register-free address must use x86-64 default address size")
    print("PASS x86 address size: register-free address uses 64-bit default")

    local a32_rip = one(9)
    assert(a32_rip.address.base
        and a32_rip.address.base.name == "rip"
        and a32_rip.address.address_size_status == "known"
        and a32_rip.address.address_size_bits == 32
        and a32_rip.address.address_size_source == "explicit_prefix"
        and a32_rip.effective_address.status == "unknown"
        and a32_rip.effective_address.reason
            == "relative address basis unresolved",
        "A32 must be allowed to override RIP-relative effective-address width")
    print("PASS x86 address size: A32 RIP-relative width is explicit 32-bit")

    local focus = engine.discover_register_source_occurrences(
        buffer,
        root,
        adapter,
        4
    )
    local saw_eax = false

    for _, occurrence in ipairs(focus or {}) do
        if occurrence.kind == "memory_component"
            and occurrence.text == "eax"
        then
            local metadata = occurrence.metadata or {}

            assert(metadata.memory_address_size_status == "known"
                and metadata.memory_address_size_bits == 32
                and metadata.memory_address_size_source == "register_width"
                and metadata.memory_effective_address_status == "known"
                and metadata.memory_effective_address_bits == 32
                and metadata.memory_effective_address_value == "32",
                "Inspect must reuse normalized 32-bit address semantics")
            saw_eax = true
        end
    end

    assert(saw_eax, "Inspect did not expose EAX address component")
    print("PASS x86 address size: Inspect reuses 32-bit address semantics")

    vim.api.nvim_set_current_buf(buffer)
    vim.api.nvim_win_set_cursor(0, { 9, 0 })

    local context = require("tracker_hud.context")
        .get_cursor_context(buffer, {})

    local by_line = {}

    for _, fact in ipairs(context.source_memory_operands or {}) do
        by_line[fact.source_line] = fact
    end

    assert(by_line[4]
        and by_line[4].address.address_size_bits == 32
        and by_line[4].effective_address.bits == 32
        and by_line[4].effective_address.value == "32"
        and by_line[5]
        and by_line[5].address.address_size_bits == 64
        and by_line[5].effective_address.bits == 64
        and by_line[6]
        and by_line[6].address.address_size_status == "unknown"
        and by_line[7]
        and by_line[7].address.address_size_status == "unknown"
        and by_line[8]
        and by_line[8].address.address_size_source == "default"
        and by_line[9]
        and by_line[9].address.address_size_bits == 32
        and by_line[9].address.address_size_source == "explicit_prefix"
        and by_line[9].effective_address.status == "unknown",
        "normal context must preserve each source operand's address-size semantics")
    print("PASS x86 address size: context preserves source-time address widths")

    print("PASS Tracker_HUD x86 address-size smoke")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL x86 address-size smoke: "
        .. tostring(err) .. "\n")
    error(err)
end
