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

    vim.api.nvim_buf_set_lines(
        buffer,
        0,
        -1,
        false,
        {
            "mov rax, 42",
            "push rax",
            "pop rbx",
            "push rbx",
        }
    )

    trees = parser:parse()

    assert(
        trees and trees[1],
        "ASM parser produced no tree for stack/register feedback proof"
    )

    root = trees[1]:root()

    local feedback_context = {
        cursor = {
            line = 4,
            column = 200,
        },
    }

    local register_source_cache = {}

    local _before,
        _visible,
        register_timeline =
        engine.collect_register_effect_pair(
            feedback_context,
            adapter,
            {
                bufnr = buffer,
                root_node = root,
                register_source_cache =
                    register_source_cache,
                before_position = {
                    line = 4,
                    column = 0,
                },
            }
        )

    assert(
        register_timeline,
        "parser-backed Register timeline was not created for Stack feedback proof"
    )

    local before_final_push =
        register_timeline:snapshot_before({
            line = 4,
            column = 0,
        })

    local rbx_before_push = nil

    for _, fact in ipairs(
        before_final_push or {}
    ) do
        if tostring(
            fact.name or ""
        ):lower() == "rbx"
        then
            rbx_before_push = fact
            break
        end
    end

    assert(
        rbx_before_push
            and rbx_before_push.resolved
                == true
            and tostring(
                rbx_before_push.value
            ) == "42",
        "Register timeline did not carry PUSH/POP stack feedback into RBX"
    )

    print(
        "PASS ASM stack pipeline: "
            .. "Register timeline carries PUSH/POP feedback into later register state"
    )

    local legacy_feedback_facts =
        engine.collect_stack_effects(
            feedback_context,
            adapter,
            {
                bufnr = buffer,
                root_node = root,
                register_source_cache =
                    register_source_cache,
            }
        )

    local timeline_feedback_facts =
        engine.collect_stack_effects(
            feedback_context,
            adapter,
            {
                bufnr = buffer,
                root_node = root,
                register_source_cache =
                    register_source_cache,
                register_timeline =
                    register_timeline,
            }
        )

    local function final_push_value(facts)
        for index = #facts, 1, -1 do
            local fact = facts[index]

            if fact.kind == "stack_push"
                and fact.source_line == 4
            then
                return fact.value,
                    fact.resolved
            end
        end

        return nil, false
    end

    local legacy_value,
        legacy_resolved =
        final_push_value(
            legacy_feedback_facts
        )

    local timeline_value,
        timeline_resolved =
        final_push_value(
            timeline_feedback_facts
        )

    assert(
        legacy_resolved == true
            and timeline_resolved
                == true
            and tostring(
                legacy_value
            ) == "42"
            and tostring(
                timeline_value
            ) == tostring(
                legacy_value
            ),
        "timeline-driven Stack changed PUSH/POP/register feedback semantics"
    )

    print(
        "PASS ASM stack pipeline: "
            .. "timeline carry matches legacy mixed reducer across PUSH/POP feedback"
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
