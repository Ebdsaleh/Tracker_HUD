-- tests/asm_memory_structure_smoke.lua
-- Parser-backed normalized x86-64 memory-operand regression.
-- nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local source = {
        "bits 64",
        "mov rax, qword [rbp + rcx*4 - 0x10]",
        "mov [rsp + 8], rax",
        "lea rsi, [rel msg]",
        "lea rdx, [abs 0x1234]",
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

    local instruction_utils = require("tracker_hud.adapters.asm.instruction_utils")
    local engine = require("tracker_hud.context_engine")

    local function instruction_on(line_number)
        local found

        local function visit(node)
            if found then return end

            local row = node:start()
            if row + 1 == line_number and node:type() == "instruction" then
                found = node
                return
            end

            for child in node:iter_children() do
                visit(child)
                if found then return end
            end
        end

        visit(root)
        return assert(found, "missing instruction on line " .. tostring(line_number))
    end

    local function parse_line(line_number)
        return assert(instruction_utils.parse_instruction(
            buffer,
            instruction_on(line_number),
            nil,
            adapter
        ))
    end

    local load = parse_line(2)
    local load_memory = assert(load.operands[2] and load.operands[2].memory,
        "line 2 memory source not parsed")
    local load_address = assert(load_memory.normalized,
        "line 2 normalized memory address missing")

    assert(load_address.memory_size_bits == 64
        and load_address.base and load_address.base.name == "rbp"
        and load_address.index and load_address.index.name == "rcx"
        and load_address.scale and load_address.scale.value == "4"
        and load_address.displacement
        and load_address.displacement.value == "-16",
        "base/index/scale/displacement structure changed")
    assert(load_address.base.role == "base_register"
        and load_address.base.display_role == "frame pointer base",
        "frame-pointer display role must not replace structural base role")
    print("PASS ASM memory structure: base/index/scale/displacement + qword size")

    local discovered_load = engine.discover_memory_source_operands(
        buffer,
        root,
        adapter,
        2
    )
    assert(#discovered_load == 1,
        "context memory discovery must return one line-2 operand")
    assert(discovered_load[1].kind == "memory_operand"
        and discovered_load[1].operand_index == 2
        and discovered_load[1].address.base.name == "rbp"
        and discovered_load[1].address.index.name == "rcx"
        and discovered_load[1].address.scale.value == "4"
        and discovered_load[1].address.displacement.value == "-16"
        and discovered_load[1].metadata.effective_address == "unknown"
        and discovered_load[1].metadata.runtime_address == "unknown",
        "first-class context memory fact changed")
    print("PASS ASM memory structure: context exposes normalized source memory operand")

    local store = parse_line(3)
    local store_address = assert(
        store.operands[1]
            and store.operands[1].memory
            and store.operands[1].memory.normalized
    )
    assert(store_address.base and store_address.base.name == "rsp"
        and store_address.displacement
        and store_address.displacement.value == "8"
        and store_address.base.display_role == "stack pointer base",
        "stack-relative address structure changed")
    print("PASS ASM memory structure: stack-relative base/displacement")

    local relative = parse_line(4)
    local relative_address = assert(
        relative.operands[2]
            and relative.operands[2].memory
            and relative.operands[2].memory.normalized
    )
    assert(relative_address.address_mode == "relative"
        and relative_address.address_mode_token == "rel"
        and relative_address.symbol
        and relative_address.symbol.name == "msg"
        and relative_address.base == nil
        and relative_address.index == nil,
        "REL symbol must be separated from address-mode syntax")
    print("PASS ASM memory structure: REL mode separated from symbol")

    local discovered_relative = engine.discover_memory_source_operands(
        buffer,
        root,
        adapter,
        4
    )
    assert(#discovered_relative == 1
        and discovered_relative[1].address.address_mode == "relative"
        and discovered_relative[1].address.symbol.name == "msg",
        "context memory discovery lost REL/symbol separation")

    local absolute = parse_line(5)
    local absolute_address = assert(
        absolute.operands[2]
            and absolute.operands[2].memory
            and absolute.operands[2].memory.normalized
    )
    assert(absolute_address.address_mode == "absolute"
        and absolute_address.address_mode_token == "abs"
        and absolute_address.displacement
        and absolute_address.displacement.value == "4660",
        "ABS numeric address must preserve exact displacement")
    print("PASS ASM memory structure: ABS mode + exact hexadecimal displacement")

    local register_occurrences =
        engine.discover_register_source_occurrences(
            buffer,
            root,
            adapter,
            2
        )

    local saw_structured_metadata = false
    local saw_base_component = false

    for _, occurrence in ipairs(register_occurrences) do
        local metadata = occurrence.metadata or {}

        if metadata.memory_address_structured then
            local address = metadata.memory_address_structured
            assert(address.base and address.base.name == "rbp"
                and address.index and address.index.name == "rcx"
                and address.scale and address.scale.value == "4"
                and address.displacement
                and address.displacement.value == "-16",
                "existing Inspect metadata disagrees with normalized memory structure")
            saw_structured_metadata = true
        end

        if occurrence.kind == "memory_component"
            and occurrence.text == "rbp"
        then
            assert(metadata.address_role_id == "base_register"
                and metadata.address_display_role_id == "frame pointer base",
                "memory component must keep structural and display roles separate")
            saw_base_component = true
        end
    end

    assert(saw_structured_metadata,
        "register occurrence metadata did not expose normalized memory address")
    assert(saw_base_component,
        "register occurrence metadata did not expose structural base role")
    print("PASS ASM memory structure: Inspect metadata reuses normalized address")

    print("PASS Tracker_HUD ASM normalized memory structure smoke")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL ASM normalized memory structure smoke: "
        .. tostring(err) .. "\n")
    error(err)
end
