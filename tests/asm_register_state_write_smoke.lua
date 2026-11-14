-- tests/asm_register_state_write_smoke.lua
-- Parser-backed integration for extracted register-state publication.
--
-- nvim --headless -c "luafile tests/asm_register_state_write_smoke.lua" -c "qa!"

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
            "mov rax, 0xFFFFFFFFFFFFFFFF",
            "mov eax, 1",
            "mov rbx, rax",
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
                    line = 4,
                    column = 200,
                },
            },
            adapter,
            {
                bufnr = buffer,
                root_node = root,
                limit_position = {
                    line = 5,
                    column = 0,
                },
            }
        )

    local rax = nil
    local rbx = nil

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
        elseif canonical == "rbx"
            or fact.name == "rbx"
        then
            rbx = fact
        end
    end

    assert(
        rax
            and rax.name == "eax"
            and rax.resolved == true
            and rax.value
                == "0x0000000000000001",
        "EAX publication no longer replaces canonical RAX state"
    )

    print(
        "PASS ASM register state write: "
            .. "EAX publishes zero-extended canonical RAX"
    )

    assert(
        rbx
            and rbx.resolved == true
            and rbx.value == rax.value
            and rbx.value
                == "0x0000000000000001"
            and rbx.metadata
                .effect
                == "mov_register_register",
        "later RAX read did not reuse newly published canonical state"
    )

    print(
        "PASS ASM register state write: "
            .. "later register copy reads published canonical state"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "register-state write smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM register-state write smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
