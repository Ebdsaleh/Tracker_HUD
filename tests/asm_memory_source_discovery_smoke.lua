-- tests/asm_memory_source_discovery_smoke.lua
-- Parser-backed proof for the memory-source discovery coordinator.
--
-- nvim --headless -c "luafile tests/asm_memory_source_discovery_smoke.lua" -c "qa!"

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
            "mov rcx, [rax + 16]",
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

    local facts =
        engine.discover_memory_source_operands(
            buffer,
            root,
            adapter,
            3
        )

    assert(
        #facts == 1,
        "exact-line memory discovery changed"
    )

    local fact = facts[1]

    assert(
        fact.source_line == 3
            and fact.text
                == "[rax + 8]"
            and fact.access == "read",
        "memory discovery exact-line/access result changed"
    )

    assert(
        fact.effective_address
            and fact.effective_address.status
                == "known"
            and fact.effective_address.value
                == "4104"
            and fact.metadata
                .execution_status
                == "not_observed",
        "memory discovery source-time certainty changed"
    )

    print(
        "PASS ASM memory discovery: "
            .. "exact-line access and address preserved"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "memory-source discovery smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM memory-source discovery smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
