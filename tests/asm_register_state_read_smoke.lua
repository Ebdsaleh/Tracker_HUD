-- tests/asm_register_state_read_smoke.lua
-- Parser-backed integration for extracted register read policy.
--
-- nvim --headless -c "luafile tests/asm_register_state_read_smoke.lua" -c "qa!"

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
            "nop",
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

    local read =
        require(
            "tracker_hud.low_level.register_state_read"
        )

    local facts =
        engine.collect_register_effects(
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

    local facts_by_register = {}

    for _, fact in ipairs(facts) do
        facts_by_register[
            fact.name:lower()
        ] = fact

        local canonical =
            fact.metadata
            and fact.metadata
                .canonical_name

        if type(canonical) == "string"
            and canonical ~= ""
        then
            facts_by_register[
                canonical:lower()
            ] = fact
        end
    end

    local eax =
        read.get_fact_for_read(
            facts_by_register,
            adapter,
            "eax"
        )

    assert(
        eax
            and eax.resolved == true
            and tostring(eax.value)
                == "42"
            and eax.name == "eax",
        "eax alias read no longer projects proven rax state"
    )

    print(
        "PASS ASM register state read: "
            .. "canonical rax projects through eax"
    )

    assert(
        read.state_key(
            adapter,
            "eax"
        ) == "rax"
            and read.get_value_width(
                adapter,
                "eax"
            ) == 32
            and read.get_value_width(
                adapter,
                "rax"
            ) == 64,
        "x86 alias key/width policy changed"
    )

    print(
        "PASS ASM register state read: "
            .. "canonical key and widths preserved"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "register-state read smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM register-state read smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
