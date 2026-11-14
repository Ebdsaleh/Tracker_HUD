-- tests/asm_register_effect_selection_smoke.lua
-- Parser-backed proof for shared register-effect selection.
--
-- nvim --headless -c "luafile tests/asm_register_effect_selection_smoke.lua" -c "qa!"

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

    local rule_syntax =
        require(
            "tracker_hud.low_level.rule_syntax"
        )

    local effect_index =
        require(
            "tracker_hud.low_level.register_effect_index"
        ).get(
            adapter,
            rule_syntax.index_options()
        )

    local instruction_source =
        require(
            "tracker_hud.low_level.instruction_source"
        )

    local nodes =
        instruction_source
            .collect_nodes_by_type(
                root,
                "instruction"
            )

    assert(
        #nodes == 1,
        "expected one ASM instruction node"
    )

    local selection =
        require(
            "tracker_hud.low_level.register_effect_selection"
        )

    local parser_dispatch =
        require(
            "tracker_hud.low_level.instruction_parser_dispatch"
        )

    local instruction,
        matching =
        selection.match_node(
            effect_index,
            nodes[1],
            {
                normalize_mnemonic =
                    rule_syntax
                        .normalize_mnemonic,

                parse_instruction = function(
                    node,
                    representative
                )
                    return parser_dispatch.parse(
                        adapter,
                        buffer,
                        node,
                        representative
                    )
                end,
            }
        )

    assert(
        instruction
            and instruction.mnemonic
                == "mov"
            and instruction.operands
            and #instruction.operands
                == 2,
        "real ASM instruction parse changed"
    )

    assert(
        #matching == 1
            and matching[1].effect
            and matching[1].effect.name
                == "mov_register_immediate",
        "real MOV register/immediate effect selection changed"
    )

    print(
        "PASS ASM register effect selection: "
            .. "MOV register/immediate rule preserved"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "register-effect selection smoke"
    )
end


local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM register-effect selection smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
