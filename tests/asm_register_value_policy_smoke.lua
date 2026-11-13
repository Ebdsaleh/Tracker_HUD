-- tests/asm_register_value_policy_smoke.lua
-- Parser-backed integration for extracted register value policy.
--
-- nvim --headless -c "luafile tests/asm_register_value_policy_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua")
        .use_working_tree()

    local source = {
        "bits 64",
        "mov al, 0xFF",
        "inc al",
        "mov rax, 0",
        "add rax, 0xFFFFFFFF",
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
        line_number
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

            if canonical == "rax"
                or fact.name == "rax"
            then
                return fact
            end
        end

        return nil
    end

    local wrapped =
        assert(
            state_after(3),
            "missing AL state after INC"
        )

    assert(
        wrapped.name == "al"
            and wrapped.metadata
                .write_value == "0"
            and wrapped.metadata
                .value_width_bits == 8
            and wrapped.metadata
                .value_wrapped == true,
        "parser-backed AL wrap changed"
    )

    print(
        "PASS ASM register value policy: "
            .. "AL wrap uses target width"
    )

    local signed =
        assert(
            state_after(5),
            "missing RAX state after ADD"
        )

    assert(
        signed.value
            == "18446744073709551615"
            and signed.metadata
                .source_integer_value
                == "-1"
            and signed.metadata
                .source_integer_bits
                == 32
            and signed.metadata
                .source_integer_bits_source
                == "target_capped"
            and signed.metadata
                .value_wrapped
                == true,
        "parser-backed signed immediate policy changed"
    )

    print(
        "PASS ASM register value policy: "
            .. "RAX ADD sign-interprets imm32"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "register-value policy smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM register-value policy smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
