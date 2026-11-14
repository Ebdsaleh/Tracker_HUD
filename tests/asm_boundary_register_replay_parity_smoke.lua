-- tests/asm_boundary_register_replay_parity_smoke.lua
-- nvim --headless -c "luafile tests/asm_boundary_register_replay_parity_smoke.lua" -c "qa!"

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

    local context = {
        cursor = {
            line = #source,
            column = 200,
        },
    }

    local opts = {
        bufnr = buffer,
        root_node = root,
    }

    local engine =
        require(
            "tracker_hud.context_engine"
        )

    local optimized =
        engine.collect_boundary_effects(
            context,
            adapter,
            opts
        )

    local boundary_pipeline =
        require(
            "tracker_hud.low_level.boundary_effect_pipeline"
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

    local function parse_instruction(
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
    end

    local full =
        boundary_pipeline.collect(
            context,
            adapter,
            opts,
            {
                parse_instruction =
                    parse_instruction,

                collect_register_effects =
                    engine
                        .collect_register_effects,
            }
        )

    local function normalize(
        facts
    )
        local rows = {}

        for _, fact in ipairs(
            facts or {}
        ) do
            local reads = {}

            for _, read in ipairs(
                fact.reads or {}
            ) do
                reads[#reads + 1] =
                    table.concat({
                        tostring(
                            read.register
                        ),
                        tostring(
                            read.value
                        ),
                        tostring(
                            read.resolved
                        ),
                        tostring(
                            read.role
                        ),
                    }, ":")
            end

            table.sort(reads)

            rows[#rows + 1] =
                table.concat({
                    tostring(fact.kind),
                    tostring(fact.name),
                    tostring(
                        fact.effect_key
                    ),
                    tostring(
                        fact.category
                    ),
                    tostring(
                        fact.source_line
                    ),
                    table.concat(
                        reads,
                        ","
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
        "boundary replay parity fixture produced unexpected fact count"
    )

    assert(
        normalize(optimized)
            == normalize(full),
        "incremental boundary read contexts diverged from full replay"
    )

    print(
        "PASS ASM boundary replay: "
            .. "incremental facts match full replay"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "boundary register-replay parity smoke"
    )
end


local ok, err =
    pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM boundary register-replay parity smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
