-- tests/asm_instruction_event_index_smoke.lua
-- Parser-backed regression for the extracted instruction-event index.
-- Requires ERIDU's configured ASM Tree-sitter parser.
--
-- nvim --headless -c "luafile tests/asm_instruction_event_index_smoke.lua" -c "qa!"

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
            "call target",
            "ret",
            "target:",
            "nop",
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
        engine.collect_instruction_events(
            {
                cursor = {
                    line = 4,
                    column = 1,
                },
            },
            adapter,
            {
                bufnr = buffer,
                root_node = root,
            }
        )

    assert(
        #facts == 2,
        "expected call + ret events, got "
            .. tostring(#facts)
    )

    assert(
        facts[1].name == "call"
            and facts[1].kind
                == "control_event"
            and facts[1].category
                == "control_flow"
            and facts[1].source_line == 1
            and facts[1].metadata
            and facts[1].metadata.mnemonic
                == "call",
        "call event fact changed"
    )

    print(
        "PASS ASM instruction events: "
            .. "call fact preserved"
    )

    assert(
        facts[2].name == "ret"
            and facts[2].kind
                == "control_event"
            and facts[2].category
                == "control_flow"
            and facts[2].source_line == 2
            and facts[2].metadata
            and facts[2].metadata.mnemonic
                == "ret",
        "ret event fact changed"
    )

    print(
        "PASS ASM instruction events: "
            .. "ret fact preserved"
    )

    local call_operands =
        facts[1].metadata.operands
        or {}

    assert(
        #call_operands == 1
            and call_operands[1].text
                == "target",
        "call operand metadata changed"
    )

    print(
        "PASS ASM instruction events: "
            .. "parsed operand metadata preserved"
    )

    local early_facts =
        engine.collect_instruction_events(
            {
                cursor = {
                    line = 1,
                    column = 1,
                },
            },
            adapter,
            {
                bufnr = buffer,
                root_node = root,
            }
        )

    assert(
        #early_facts == 1
            and early_facts[1].name
                == "call",
        "cursor-line event visibility changed"
    )

    print(
        "PASS ASM instruction events: "
            .. "cursor visibility preserved"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "instruction-event index smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM instruction-event "
            .. "index smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
