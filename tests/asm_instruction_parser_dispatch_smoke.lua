-- tests/asm_instruction_parser_dispatch_smoke.lua
-- Parser-backed integration for adapter instruction-parser dispatch.
--
-- nvim --headless -c "luafile tests/asm_instruction_parser_dispatch_smoke.lua" -c "qa!"

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
            "mov rax, 42",
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

    local instruction_source =
        require(
            "tracker_hud.low_level.instruction_source"
        )

    local dispatch =
        require(
            "tracker_hud.low_level.instruction_parser_dispatch"
        )

    local nodes =
        instruction_source.collect_nodes_by_type(
            root,
            "instruction"
        )

    assert(
        #nodes == 1,
        "expected one instruction node, got "
            .. tostring(#nodes)
    )

    local effect_spec =
        adapter.register_effects
        and adapter.register_effects.mov
        and adapter.register_effects.mov[1]

    assert(
        effect_spec,
        "configured ASM mov effect unavailable"
    )

    local instruction =
        dispatch.parse(
            adapter,
            buffer,
            nodes[1],
            effect_spec
        )

    assert(
        instruction
            and instruction.mnemonic
                == "mov"
            and instruction.source_line
                == 1
            and #(
                instruction.operands
                or {}
            ) == 2,
        "real ASM parser dispatch changed"
    )

    assert(
        instruction.operands[1].text
            == "rax"
            and instruction.operands[1].kind
                == "register"
            and instruction.operands[2].text
                == "42"
            and instruction.operands[2].kind
                == "integer",
        "real ASM parser operand output changed"
    )

    print(
        "PASS ASM parser dispatch: "
            .. "real instruction parser invoked"
    )

    print(
        "PASS ASM parser dispatch: "
            .. "operand semantics preserved"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "instruction-parser dispatch smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM instruction-parser dispatch smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
