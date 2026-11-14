-- tests/asm_register_fact_builder_smoke.lua
-- Parser-backed integration for extracted register fact construction.
--
-- nvim --headless -c "luafile tests/asm_register_fact_builder_smoke.lua" -c "qa!"

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
            "bits 64",
            "mov eax, 0xFFFFFFFF",
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
        engine.collect_register_effects(
            {
                cursor = {
                    line = 2,
                    column = 200,
                },
            },
            adapter,
            {
                bufnr = buffer,
                root_node = root,
                limit_position = {
                    line = 3,
                    column = 0,
                },
            }
        )

    local rax = nil

    for _, fact in ipairs(
        facts or {}
    ) do
        local canonical =
            fact.metadata
            and fact.metadata
                .canonical_name

        if canonical == "rax"
            or fact.name == "rax"
        then
            rax = fact
            break
        end
    end

    assert(
        rax,
        "missing reduced RAX-family fact"
    )

    assert(
        rax.name == "eax"
            and rax.resolved == true
            and rax.value
                == "0x00000000FFFFFFFF",
        "EAX fact construction changed"
    )

    print(
        "PASS ASM register fact builder: "
            .. "EAX zero-extends into canonical RAX"
    )

    assert(
        rax.metadata
            and rax.metadata
                .write_value
                == "4294967295"
            and rax.metadata
                .canonical_name
                == "rax"
            and rax.metadata
                .effect_target_origin
                == "operand"
            and rax.metadata
                .effect
                == "mov_register_immediate",
        "register fact metadata changed"
    )

    print(
        "PASS ASM register fact builder: "
            .. "write and canonical metadata preserved"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "register-fact builder smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM register-fact builder smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
