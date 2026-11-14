-- tests/asm_register_effect_apply_smoke.lua
-- Parser-backed proof for the extracted register application wrapper.
--
-- nvim --headless -c "luafile tests/asm_register_effect_apply_smoke.lua" -c "qa!"

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
            "mov rax, 41",
            "inc rax",
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
                    line = 3,
                    column = 200,
                },
            },
            adapter,
            {
                bufnr = buffer,
                root_node = root,
                limit_position = {
                    line = 4,
                    column = 0,
                },
            }
        )

    local rax = nil
    local count = 0

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
            count = count + 1
        end
    end

    assert(
        count == 1
            and rax
            and rax.resolved == true
            and tostring(rax.value)
                == "42"
            and rax.metadata
            and rax.metadata.effect
                == "inc_register",
        "extracted register application changed MOV/INC reduction"
    )

    print(
        "PASS ASM register apply: "
            .. "MOV then INC publishes canonical RAX 42"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "register-effect apply smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM register-effect apply smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
