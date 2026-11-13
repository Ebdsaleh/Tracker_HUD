-- tests/asm_stack_effects_smoke.lua
-- Parser-backed stack inference baseline.
--
-- nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"

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
            "push 7",
            "pop rax",
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

    assert(
        #facts == 2,
        "expected push + pop stack facts, got "
            .. tostring(#facts)
    )

    local push_fact = nil
    local pop_fact = nil

    for _, fact in ipairs(facts) do
        if fact.kind == "stack_push" then
            push_fact = fact
        elseif fact.kind == "stack_pop" then
            pop_fact = fact
        end
    end

    assert(
        push_fact
            and push_fact.resolved == true
            and tostring(push_fact.value)
                == "7"
            and push_fact.stack_depth_before
                == 0
            and push_fact.stack_depth_after
                == -8
            and push_fact.stack_depth_delta
                == -8,
        "push-immediate stack fact changed"
    )

    print(
        "PASS ASM stack: "
            .. "push immediate fact preserved"
    )

    assert(
        pop_fact
            and pop_fact.resolved == true
            and tostring(pop_fact.value)
                == "7"
            and pop_fact.destination_register
                == "rax"
            and pop_fact.stack_depth_before
                == -8
            and pop_fact.stack_depth_after
                == 0
            and pop_fact.stack_depth_delta
                == 8,
        "pop stack fact changed"
    )

    print(
        "PASS ASM stack: "
            .. "pop reuses tracked stack value"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "stack-effect smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM stack-effect smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
