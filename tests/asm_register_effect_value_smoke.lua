-- tests/asm_register_effect_value_smoke.lua
-- Parser-backed integration for extracted register-effect value resolution.
--
-- nvim --headless -c "luafile tests/asm_register_effect_value_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua")
        .use_working_tree()

    local source = {
        "bits 64",
        "mov rax, 40",
        "mov rbx, rax",
        "add rbx, 2",
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

    local function state_after(
        line_number,
        canonical_name
    )
        local facts =
            engine.collect_register_effects(
                {
                    cursor = {
                        line = line_number,
                        column = 200,
                    },
                },
                adapter,
                {
                    bufnr = buffer,
                    root_node = root,
                    limit_position = {
                        line =
                            line_number + 1,
                        column = 0,
                    },
                }
            )

        for _, fact in ipairs(
            facts or {}
        ) do
            local canonical =
                fact.metadata
                and fact.metadata
                    .canonical_name

            if canonical
                    == canonical_name
                or fact.name
                    == canonical_name
            then
                return fact
            end
        end

        return nil
    end

    local copied =
        assert(
            state_after(
                3,
                "rbx"
            ),
            "missing RBX copy state"
        )

    assert(
        copied.resolved == true
            and tostring(copied.value)
                == "40"
            and copied.metadata
                .effect
                == "mov_register_register",
        "MOV register-source resolution changed"
    )

    print(
        "PASS ASM register effect value: "
            .. "register copy resolves from prior state"
    )

    local added =
        assert(
            state_after(
                4,
                "rbx"
            ),
            "missing RBX arithmetic state"
        )

    assert(
        added.resolved == true
            and tostring(added.value)
                == "42"
            and added.metadata
                .effect
                == "add_register_immediate",
        "ADD delta value resolution changed"
    )

    print(
        "PASS ASM register effect value: "
            .. "delta arithmetic consumes copied state"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "register-effect value smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM register-effect value smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
