-- tests/asm_instruction_event_fact_smoke.lua
-- Parser-backed integration for extracted instruction-event fact application.
--
-- nvim --headless -c "luafile tests/asm_instruction_event_fact_smoke.lua" -c "qa!"

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
                    line = 2,
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
        #facts == 1,
        "expected one call event, got "
            .. tostring(#facts)
    )

    local fact = facts[1]

    assert(
        fact.kind == "control_event"
            and fact.category
                == "control_flow"
            and fact.name == "call"
            and fact.source_line == 1,
        "call event identity/source changed"
    )

    print(
        "PASS ASM instruction event fact: "
            .. "call identity and source preserved"
    )

    local operands =
        fact.metadata
        and fact.metadata.operands
        or {}

    assert(
        fact.metadata
            and fact.metadata.adapter
                == "asm"
            and fact.metadata.architecture
                == "x86-64"
            and fact.metadata.mnemonic
                == "call"
            and fact.metadata.event
                == "call"
            and #operands == 1
            and operands[1].text
                == "target",
        "call event metadata changed"
    )

    print(
        "PASS ASM instruction event fact: "
            .. "adapter and operand metadata preserved"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "instruction-event fact smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM instruction-event fact smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
