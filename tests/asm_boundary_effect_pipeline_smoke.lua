-- tests/asm_boundary_effect_pipeline_smoke.lua
-- Parser-backed proof for the extracted boundary-effect pipeline.
--
-- nvim --headless -c "luafile tests/asm_boundary_effect_pipeline_smoke.lua" -c "qa!"

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
            "mov rax, 60",
            "mov rdi, 7",
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

    assert(
        registry.register(adapter)
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
        engine.collect_boundary_effects(
            {
                cursor = {
                    line = 3,
                    column = 1,
                },
            },
            adapter,
            {
                bufnr = buffer,
                root_node = root,
            }
        )

    assert(
        #facts == 1
            and facts[1].kind
                == "syscall"
            and facts[1].name
                == "exit"
            and facts[1].effect_key
                == "60",
        "parser-backed boundary pipeline result changed"
    )

    local status_read = nil

    for _, read in ipairs(
        facts[1].reads or {}
    ) do
        if read.register == "rdi" then
            status_read = read
            break
        end
    end

    assert(
        status_read
            and status_read.value == "7"
            and status_read.resolved
                == true,
        "pre-boundary argument state changed"
    )

    print(
        "PASS ASM boundary pipeline: "
            .. "exit syscall and pre-state preserved"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "boundary-effect pipeline smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM boundary-effect pipeline smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
