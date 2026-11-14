-- tests/boundary_effect_pipeline_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/boundary_effect_pipeline_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local pipeline =
    require("tracker_hud.low_level.boundary_effect_pipeline")

local function fake_node(
    node_type,
    start_row,
    start_column,
    end_row,
    end_column,
    children
)
    local node = {
        _type = node_type,
        _children = children or {},
    }

    function node:type()
        return self._type
    end

    function node:range()
        return start_row,
            start_column,
            end_row,
            end_column
    end

    function node:iter_children()
        local index = 0

        return function()
            index = index + 1
            return self._children[index]
        end
    end

    return node
end

local instruction_node =
    fake_node(
        "instruction",
        0,
        0,
        0,
        7
    )

local root =
    fake_node(
        "program",
        0,
        0,
        1,
        0,
        {
            instruction_node,
        }
    )

local effect_spec = {
    syntax = {
        node_type = "instruction",
        fields = {
            kind = {
                field = "kind",
                node_type = "word",
                text = "syscall",
            },
        },
    },
    kind = "syscall",
    category = "system",
    reads = {
        number_register = "rax",
    },
    known_effects = {
        ["1"] = {
            name = "write",
            category = "io",
        },
    },
}

local adapter = {
    name = "asm",
    architecture = "x86_64",
    active_variant_name = "x86_64",
    boundary_effects = {
        syscall = {
            effect_spec,
        },
    },
}

local instruction = {
    mnemonic = "syscall",
    source_line = 1,
    source_start_line = 1,
    source_start_column = 0,
    source_column = 0,
    source_end_column = 7,
    operands = {},
}

local parse_calls = 0
local replay_calls = 0

local facts =
    pipeline.collect(
        {
            cursor = {
                line = 1,
                column = 1,
            },
        },
        adapter,
        {
            bufnr = 7,
            root_node = root,
        },
        {
            parse_instruction = function(
                node,
                representative
            )
                parse_calls =
                    parse_calls + 1

                assert(
                    node == instruction_node
                        and representative
                            == effect_spec,
                    "boundary pipeline parse dispatch changed"
                )

                return instruction
            end,

            collect_register_effects =
                function(
                    _context,
                    seen_adapter,
                    replay_opts
                )
                    replay_calls =
                        replay_calls + 1

                    assert(
                        seen_adapter == adapter
                            and replay_opts
                                .limit_position
                                .line == 1
                            and replay_opts
                                .limit_position
                                .column == 0,
                        "boundary pipeline pre-instruction replay limit changed"
                    )

                    return {
                        {
                            name = "rax",
                            value = "1",
                            resolved = true,
                        },
                    }
                end,
        }
    )

assert(
    parse_calls == 1
        and replay_calls == 1,
    "boundary pipeline dependency sequencing changed"
)
print("PASS boundary pipeline: parser and pre-register replay preserved")

assert(
    #facts == 1
        and facts[1].kind == "syscall"
        and facts[1].name == "write"
        and facts[1].category == "io"
        and facts[1].effect_key == "1",
    "boundary pipeline known-effect resolution changed"
)
print("PASS boundary pipeline: known effect resolution preserved")

assert(
    facts[1].reads
        and facts[1].reads[1]
        and facts[1].reads[1].register
            == "rax"
        and facts[1].reads[1].value
            == "1"
        and facts[1].reads[1].resolved
            == true
        and facts[1].metadata
            .boundary_reads_state
            == "before_instruction"
        and facts[1].metadata
            .boundary_writes_state
            == "after_instruction",
    "boundary pipeline phase/read semantics changed"
)
print("PASS boundary pipeline: read and phase semantics preserved")

assert(
    #pipeline.collect(
        {},
        {},
        {},
        {}
    ) == 0,
    "invalid boundary pipeline inputs must fail closed"
)
print("PASS boundary pipeline: invalid inputs fail closed")

print("PASS Tracker_HUD boundary-effect pipeline smoke")
