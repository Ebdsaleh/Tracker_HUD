-- tests/asm_address_prefix_semantics_smoke.lua
-- Parser-backed semantic regression for NASM A32/A64 instruction prefixes.
-- nvim --headless -c "luafile tests/asm_address_prefix_semantics_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua").use_working_tree()

    local source = {
        "bits 64",
        "a32 mov rbx, [eax + 4]",
        "a64 mov [rax + 8], rbx",
        "a32 lea rsi, [eax + 12]",
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

    local instructions_by_line = {}

    local function visit(node)
        if node:type() == "instruction" then
            local start_row = node:start()
            local parsed = instruction_utils.parse_instruction(
                buffer,
                node,
                nil,
                adapter
            )

            if parsed then
                instructions_by_line[start_row + 1] = parsed
            end
        end

        for child in node:iter_children() do
            visit(child)
        end
    end

    visit(root)

    local read = assert(instructions_by_line[2],
        "line 2 prefixed MOV did not parse")

    assert(read.mnemonic == "mov"
        and #read.prefixes == 1
        and read.prefixes[1].kind == "address_size"
        and read.prefixes[1].text == "a32"
        and read.prefixes[1].bits == 32
        and #read.operands == 2
        and read.operands[1].kind == "register"
        and read.operands[1].text == "rbx"
        and read.operands[2].kind == "memory"
        and read.operands[2].memory.normalized.address_size_bits == 32
        and read.operands[2].memory.normalized.address_size_source
            == "explicit_prefix",
        "A32 MOV must recover semantic mnemonic and destination operand")
    print("PASS ASM address prefix: A32 recovers MOV + destination operand")

    local write = assert(instructions_by_line[3],
        "line 3 prefixed MOV did not parse")

    assert(write.mnemonic == "mov"
        and #write.prefixes == 1
        and write.prefixes[1].text == "a64"
        and write.prefixes[1].bits == 64
        and #write.operands == 2
        and write.operands[1].kind == "memory"
        and write.operands[1].memory.normalized.address_size_bits == 64
        and write.operands[2].kind == "register"
        and write.operands[2].text == "rbx",
        "A64 MOV must preserve source-order operands")
    print("PASS ASM address prefix: A64 preserves MOV operand order")

    local lea = assert(instructions_by_line[4],
        "line 4 prefixed LEA did not parse")

    assert(lea.mnemonic == "lea"
        and #lea.operands == 2
        and lea.operands[1].text == "rsi"
        and lea.operands[2].kind == "memory"
        and lea.operands[2].memory.normalized.address_size_bits == 32,
        "A32 LEA must recover semantic mnemonic and operands")
    print("PASS ASM address prefix: A32 recovers LEA semantics")

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

    local read_fact = one(2)
    assert(read_fact.access == "read"
        and read_fact.metadata.access_declared == true
        and read_fact.address.address_size_bits == 32
        and read_fact.address.address_size_source == "explicit_prefix",
        "A32 MOV source memory must retain MOV read intent")
    print("PASS ASM address prefix: recovered MOV source is read")

    local write_fact = one(3)
    assert(write_fact.access == "write"
        and write_fact.metadata.access_declared == true
        and write_fact.address.address_size_bits == 64
        and write_fact.address.address_size_source == "explicit_prefix",
        "A64 MOV destination memory must retain MOV write intent")
    print("PASS ASM address prefix: recovered MOV destination is write")

    local lea_fact = one(4)
    assert(lea_fact.access == "address_only"
        and lea_fact.metadata.access_declared == true
        and lea_fact.address.address_size_bits == 32,
        "A32 LEA memory expression must retain address_only intent")
    print("PASS ASM address prefix: recovered LEA is address_only")

    print("PASS Tracker_HUD ASM address-prefix semantics smoke")
end

local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM address-prefix semantics smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
