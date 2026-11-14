-- tests/asm_register_source_discovery_smoke.lua
-- Parser-backed proof for the register-source discovery coordinator.
--
-- nvim --headless -c "luafile tests/asm_register_source_discovery_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua")
        .use_working_tree()

    local buffer =
        vim.api.nvim_create_buf(
            false,
            true
        )

    vim.api.nvim_buf_set_lines(
        buffer,
        0,
        -1,
        false,
        {
            "bits 64",
            "mov rax, 0x1000",
            "mov rbx, [rax + 8]",
        }
    )

    vim.bo[buffer].filetype = "asm"

    local ok, parser =
        pcall(
            vim.treesitter.get_parser,
            buffer,
            "asm"
        )

    assert(
        ok and parser,
        "ASM Tree-sitter parser unavailable: "
            .. tostring(parser)
    )

    local trees = parser:parse()

    assert(
        trees and trees[1],
        "ASM parser produced no tree"
    )

    local root = trees[1]:root()

    local adapter =
        require(
            "tracker_hud.adapters.asm.init"
        )

    local registry =
        require(
            "tracker_hud.adapters.registry"
        )

    local registered, register_error =
        registry.register(adapter)

    assert(
        registered,
        "cannot register ASM adapter: "
            .. tostring(register_error)
    )

    local configured, configure_error =
        registry.configure_adapter_for_buffer(
            "asm",
            buffer,
            {}
        )

    assert(
        configured,
        "cannot configure ASM adapter: "
            .. tostring(configure_error)
    )

    local engine =
        require(
            "tracker_hud.context_engine"
        )

    local occurrences =
        engine.discover_register_source_occurrences(
            buffer,
            root,
            adapter,
            3
        )

    local saw_mnemonic = false
    local saw_destination = false
    local saw_memory = false
    local saw_base = false

    for _, occurrence in ipairs(
        occurrences or {}
    ) do
        if occurrence.kind == "mnemonic"
            and occurrence.text == "mov"
        then
            saw_mnemonic = true
        elseif occurrence.kind == "operand"
            and occurrence.text == "rbx"
        then
            saw_destination = true
        elseif occurrence.kind == "operand"
            and occurrence.text
                == "[rax + 8]"
        then
            saw_memory =
                occurrence.metadata
                and occurrence.metadata
                    .memory_effective_address_value
                    == "4104"
        elseif occurrence.kind
                == "memory_component"
            and occurrence.text == "rax"
        then
            saw_base =
                occurrence.metadata
                and occurrence.metadata
                    .memory_effective_address_value
                    == "4104"
        end
    end

    assert(
        saw_mnemonic
            and saw_destination
            and saw_memory
            and saw_base,
        "parser-backed register source discovery changed"
    )

    print(
        "PASS ASM register discovery: "
            .. "mnemonic operands and address evidence preserved"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "register-source discovery smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM register-source discovery smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
