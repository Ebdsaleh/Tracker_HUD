-- tests/asm_stack_effect_match_smoke.lua
-- Parser-backed integration for extracted stack-effect operand matching.
--
-- nvim --headless -c "luafile tests/asm_stack_effect_match_smoke.lua" -c "qa!"

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
            "push rax",
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
        engine.collect_stack_effects(
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

    local push_fact = nil

    for _, fact in ipairs(
        facts or {}
    ) do
        if fact.kind == "stack_push"
            and fact.source_line == 2
        then
            push_fact = fact
            break
        end
    end

    assert(
        push_fact,
        "push rax no longer matched stack push rule"
    )

    assert(
        push_fact.metadata
            and push_fact.metadata
                .effect
                == "push_register",
        "push rax selected wrong stack effect"
    )

    assert(
        push_fact.resolved == true
            and tostring(
                push_fact.value
            ) == "42",
        "matched push register no longer consumes carried state"
    )

    print(
        "PASS ASM stack effect match: "
            .. "push register rule selected"
    )

    print(
        "PASS ASM stack effect match: "
            .. "matched rule preserves carried value"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "stack-effect match smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM stack-effect match smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
