-- tests/asm_boundary_effects_smoke.lua
-- Parser-backed boundary inference regression.
--
-- nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"

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
            "mov rax, 1",
            "mov rdi, 1",
            "mov rsi, 4096",
            "mov rdx, 5",
            "syscall",
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

    local context = {
        cursor = {
            line = 5,
            column = 1,
        },
    }

    local facts =
        engine.collect_boundary_effects(
            context,
            adapter,
            {
                bufnr = buffer,
                root_node = root,
            }
        )

    assert(
        #facts == 1,
        "expected one syscall boundary fact, got "
            .. tostring(#facts)
    )

    local fact = facts[1]

    assert(
        fact.kind == "syscall"
            and fact.effect_key == "1"
            and fact.name == "write"
            and fact.category == "io"
            and fact.known_effect
            and fact.known_effect.name
                == "write",
        "known syscall resolution changed"
    )

    print(
        "PASS ASM boundary: "
            .. "known syscall resolved from pre-boundary registers"
    )

    local reads = {}
    for _, read in ipairs(
        fact.reads or {}
    ) do
        reads[read.register] = read
    end

    assert(
        reads.rax
            and reads.rax.resolved == true
            and tostring(reads.rax.value)
                == "1"
            and reads.rdi
            and reads.rdi.resolved == true
            and tostring(reads.rdi.value)
                == "1"
            and reads.rsi
            and reads.rsi.resolved == true
            and tostring(reads.rsi.value)
                == "4096"
            and reads.rdx
            and reads.rdx.resolved == true
            and tostring(reads.rdx.value)
                == "5",
        "boundary register reads changed"
    )

    print(
        "PASS ASM boundary: "
            .. "pre-instruction register reads preserved"
    )

    assert(
        fact.metadata
            and fact.metadata
                .boundary_reads_state
                == "before_instruction"
            and fact.metadata
                .boundary_writes_state
                == "after_instruction",
        "boundary phase metadata changed"
    )

    print(
        "PASS ASM boundary: "
            .. "read/write phase metadata preserved"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "boundary-effect smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM boundary-effect smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
