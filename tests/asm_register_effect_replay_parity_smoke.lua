-- tests/asm_register_effect_replay_parity_smoke.lua
-- nvim --headless -c "luafile tests/asm_register_effect_replay_parity_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua")
        .use_working_tree()

    local source = {
        "bits 64",
        "mov rax, 41",
        "mov rbx, rax",
        "inc rax",
        "mov rcx, rax",
    }

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

    local pipeline =
        require(
            "tracker_hud.low_level.register_effect_pipeline"
        )

    local instruction_source =
        require(
            "tracker_hud.low_level.instruction_source"
        )

    local parser_dispatch =
        require(
            "tracker_hud.low_level.instruction_parser_dispatch"
        )

    local ts_utils =
        require(
            "tracker_hud.treesitter_utils"
        )

    local deps = {
        parse_instruction = function(
            node,
            representative
        )
            return instruction_source
                .collect_instruction(
                    adapter,
                    node,
                    buffer,
                    representative,
                    {
                        parse_with_adapter =
                            parser_dispatch.parse,
                        get_node_text =
                            ts_utils
                                .get_node_text,
                    }
                )
        end,
    }

    local context = {
        cursor = {
            line = #source,
            column = 200,
        },
    }

    local opts = {
        bufnr = buffer,
        root_node = root,
        config = {},
    }

    local session =
        pipeline.new_replay_session(
            context,
            adapter,
            opts,
            deps
        )

    assert(
        session,
        "ASM register replay session was not created"
    )

    local function normalize(facts)
        local rows = {}

        for _, fact in ipairs(
            facts or {}
        ) do
            local key =
                fact.metadata
                and fact.metadata
                    .canonical_name
                or fact.name

            rows[#rows + 1] =
                table.concat({
                    tostring(key),
                    tostring(fact.value),
                    tostring(
                        fact.resolved
                    ),
                    tostring(
                        fact.metadata
                            and fact.metadata
                                .effect
                    ),
                }, "|")
        end

        table.sort(rows)

        return table.concat(
            rows,
            "\n"
        )
    end

    local positions = {
        {
            line = 3,
            column = 0,
        },
        {
            line = 4,
            column = 0,
        },
        {
            line = 5,
            column = 0,
        },
        {
            line = 6,
            column = 0,
        },
    }

    for _, position in ipairs(
        positions
    ) do
        local incremental =
            session:collect_before(
                position
            )

        local full =
            pipeline.collect(
                context,
                adapter,
                {
                    bufnr = buffer,
                    root_node = root,
                    config = {},
                    limit_position =
                        position,
                },
                deps
            )

        assert(
            normalize(incremental)
                == normalize(full),
            "incremental/full register replay diverged before "
                .. tostring(
                    position.line
                )
        )
    end

    print(
        "PASS ASM register replay: "
            .. "forward snapshots match full replay"
    )

    local backward = {
        line = 3,
        column = 0,
    }

    local fallback =
        session:collect_before(
            backward
        )

    local full_backward =
        pipeline.collect(
            context,
            adapter,
            {
                bufnr = buffer,
                root_node = root,
                config = {},
                limit_position =
                    backward,
            },
            deps
        )

    assert(
        normalize(fallback)
            == normalize(
                full_backward
            ),
        "backward replay fallback diverged"
    )

    local stats =
        session:stats()

    assert(
        stats.query_count == 5
            and stats.fallback_count
                == 1
            and stats.processed_count
                > 0
            and stats.processed_count
                <= stats.source_node_count,
        "register replay session accounting changed"
    )

    print(
        "PASS ASM register replay: "
            .. "backward request falls back with parity"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "register-effect replay parity smoke"
    )
end


local ok, err =
    pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM register-effect replay parity smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
