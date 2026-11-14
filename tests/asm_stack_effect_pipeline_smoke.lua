-- tests/asm_stack_effect_pipeline_smoke.lua
-- Parser-backed proof for the extracted stack-effect pipeline.
--
-- nvim --headless -c "luafile tests/asm_stack_effect_pipeline_smoke.lua" -c "qa!"

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

    for _, fact in ipairs(facts) do
        if fact.kind == "stack_push"
            and fact.source_line == 2
        then
            push_fact = fact
            break
        end
    end

    assert(
        push_fact
            and push_fact.resolved
                == true
            and tostring(
                push_fact.value
            ) == "42",
        "parser-backed stack pipeline register carry changed"
    )

    print(
        "PASS ASM stack pipeline: "
            .. "MOV register state reaches PUSH"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "stack-effect pipeline smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM stack-effect pipeline smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
