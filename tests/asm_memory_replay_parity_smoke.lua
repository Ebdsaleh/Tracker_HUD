-- tests/asm_memory_replay_parity_smoke.lua
-- nvim --headless -c "luafile tests/asm_memory_replay_parity_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua")
        .use_working_tree()

    local source =
        vim.fn.readfile(
            "samples/asm/x86_64/performance_baseline.asm"
        )

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
        source
    )

    vim.bo[buffer].filetype = "asm"

    local ok, parser_object =
        pcall(
            vim.treesitter.get_parser,
            buffer,
            "asm"
        )

    assert(
        ok and parser_object,
        "ASM Tree-sitter parser unavailable: "
            .. tostring(
                parser_object
            )
    )

    local trees =
        parser_object:parse()

    assert(
        trees and trees[1],
        "ASM parser produced no tree"
    )

    local root =
        trees[1]:root()

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

    local configured,
        configure_error =
        registry
            .configure_adapter_for_buffer(
                "asm",
                buffer,
                {}
            )

    assert(
        configured,
        "cannot configure ASM adapter: "
            .. tostring(
                configure_error
            )
    )

    local register_pipeline =
        require(
            "tracker_hud.low_level.register_effect_pipeline"
        )

    local original_new_replay_session =
        register_pipeline
            .new_replay_session

    local created_sessions = 0
    local captured_session = nil

    register_pipeline
        .new_replay_session =
        function(...)
            created_sessions =
                created_sessions + 1

            local session =
                original_new_replay_session(
                    ...
                )

            captured_session =
                session

            return session
        end

    package.loaded[
        "tracker_hud.context_engine"
    ] = nil

    local engine =
        require(
            "tracker_hud.context_engine"
        )

    local optimized = nil
    local full = nil

    local success, err =
        pcall(
            function()
                optimized =
                    engine
                        .collect_memory_source_operands(
                            buffer,
                            root,
                            adapter,
                            103,
                            {}
                        )

                assert(
                    created_sessions == 1
                        and captured_session,
                    "source-memory collection did not create exactly one replay session"
                )

                local stats =
                    captured_session:stats()

                assert(
                    stats.query_count > 1,
                    "source-memory fixture did not exercise repeated replay queries"
                )

                assert(
                    stats.fallback_count == 0,
                    "source-memory replay moved backwards unexpectedly"
                )

                assert(
                    stats.processed_count
                        <= stats.source_node_count,
                    "source-memory replay processed nodes more than once"
                )

                print(
                    "PASS ASM memory replay: "
                        .. "one monotonic session serves visible memory queries"
                )

                register_pipeline
                    .new_replay_session =
                    function()
                        return nil
                    end

                full =
                    engine
                        .collect_memory_source_operands(
                            buffer,
                            root,
                            adapter,
                            103,
                            {}
                        )
            end
        )

    register_pipeline
        .new_replay_session =
        original_new_replay_session

    package.loaded[
        "tracker_hud.context_engine"
    ] = nil

    assert(
        success,
        tostring(err)
    )

    local function normalize(
        facts
    )
        local rows = {}

        for _, fact in ipairs(
            facts or {}
        ) do
            local effective =
                fact.effective_address
                or {}

            rows[#rows + 1] =
                table.concat({
                    tostring(
                        fact.source_line
                    ),
                    tostring(
                        fact.source_start_column
                    ),
                    tostring(
                        fact.operand_index
                    ),
                    tostring(fact.text),
                    tostring(fact.role),
                    tostring(fact.access),
                    tostring(
                        effective.status
                    ),
                    tostring(
                        effective.value
                    ),
                    tostring(
                        effective.bits
                    ),
                    tostring(
                        effective.reason
                    ),
                }, "|")
        end

        table.sort(rows)

        return table.concat(
            rows,
            "\n"
        )
    end

    assert(
        #optimized > 0
            and #optimized == #full,
        "source-memory replay parity fixture produced unexpected fact count"
    )

    assert(
        normalize(optimized)
            == normalize(full),
        "incremental source-memory replay diverged from full replay"
    )

    print(
        "PASS ASM memory replay: "
            .. "optimized facts match full replay"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "source-memory replay parity smoke"
    )
end


local ok, err =
    pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM source-memory replay parity smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
