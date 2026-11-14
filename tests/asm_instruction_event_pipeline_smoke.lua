-- tests/asm_instruction_event_pipeline_smoke.lua
-- Parser-backed proof for the extracted instruction-event pipeline.
--
-- nvim --headless -c "luafile tests/asm_instruction_event_pipeline_smoke.lua" -c "qa!"

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

    assert(
        registry.register(adapter)
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
                    line = 3,
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
        #facts == 2
            and facts[1].name
                == "call"
            and facts[2].name
                == "ret",
        "parser-backed instruction-event pipeline ordering changed"
    )

    assert(
        facts[1].metadata
            and facts[1].metadata
                .operands
            and facts[1].metadata
                .operands[1]
            and facts[1].metadata
                .operands[1].text
                == "target",
        "parser-backed call operand metadata changed"
    )

    print(
        "PASS ASM instruction event pipeline: "
            .. "call/ret ordering and operand metadata preserved"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "instruction-event pipeline smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM instruction-event pipeline smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
