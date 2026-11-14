-- tests/memory_source_discovery_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/memory_source_discovery_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local discovery =
    require("tracker_hud.low_level.memory_source_discovery")

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
        1,
        0,
        1,
        22
    )

local root =
    fake_node(
        "program",
        0,
        0,
        2,
        0,
        {
            instruction_node,
        }
    )

local effect_spec = {
    operands = {
        {
            index = 1,
            kind = "register",
            role = "destination",
        },
        {
            index = 2,
            kind = "memory",
            role = "source_memory",
        },
    },
    effect = {
        name = "mov_register_memory",
        target_operand = 1,
    },
}

local effect_index = {
    node_types = {
        instruction = true,
    },
    by_node_type = {
        instruction = {
            __first = effect_spec,
            mov = {
                effect_spec,
            },
        },
    },
}

local memory_operand = {
    kind = "memory",
    text = "[rax + 8]",
    source_line = 2,
    source_start_column = 9,
    source_end_line = 2,
    source_end_column = 18,
    memory = {
        normalized = {
            address_mode = "default",
            address_size_status = "known",
            address_size_bits = 64,
            address_size_source =
                "register_width",
            base = {
                name = "rax",
            },
            displacement = {
                value = "8",
            },
            metadata = {
                ambiguous = {},
            },
        },
    },
}

local instruction = {
    mnemonic = "mov",
    source_line = 2,
    source_start_line = 2,
    source_start_column = 0,
    operands = {
        {
            kind = "register",
            text = "rbx",
            source_line = 2,
            source_start_column = 4,
            source_end_line = 2,
            source_end_column = 7,
        },
        memory_operand,
    },
}

local adapter = {
    metadata = {
        bits = 64,
    },
    construct_specs = {
        instruction = {
            syntax = {
                node_type = "instruction",
            },
        },
    },
    register_effects = {},
    memory_accesses = {
        mov = {
            {
                operand_index = 2,
                operand_kind = "memory",
                access = "read",
            },
        },
    },
}

local calls = {
    index = 0,
    parse = 0,
    evaluate = 0,
}

local facts =
    discovery.collect(
        7,
        root,
        adapter,
        function(line)
            return line == 2
        end,
        {},
        {
            get_register_effect_index =
                function(seen_adapter)
                    calls.index =
                        calls.index + 1

                    assert(
                        seen_adapter == adapter,
                        "wrong adapter reached effect index dependency"
                    )

                    return effect_index
                end,

            parse_instruction =
                function(
                    node,
                    representative
                )
                    calls.parse =
                        calls.parse + 1

                    assert(
                        node == instruction_node
                            and representative
                                == nil,
                        "memory discovery parse inputs changed"
                    )

                    return instruction
                end,

            evaluate_address =
                function(
                    seen_instruction,
                    address
                )
                    calls.evaluate =
                        calls.evaluate + 1

                    assert(
                        seen_instruction
                            == instruction
                            and address
                                == memory_operand
                                    .memory
                                    .normalized,
                        "memory discovery evaluation inputs changed"
                    )

                    return {
                        status = "known",
                        value = "4104",
                        bits = 64,
                        wrapped = false,
                    }
                end,
        }
    )

assert(
    calls.index == 1
        and calls.parse == 1
        and calls.evaluate == 1,
    "memory discovery dependency dispatch changed"
)
print("PASS memory source discovery: dependency dispatch preserved")

assert(
    #facts == 1
        and facts[1].text
            == "[rax + 8]"
        and facts[1].role
            == "source_memory"
        and facts[1].access
            == "read",
    "memory source semantic role/access wiring changed"
)
print("PASS memory source discovery: role and access wiring preserved")

assert(
    facts[1].effective_address
        and facts[1].effective_address.value
            == "4104"
        and facts[1].metadata
            .execution_status
            == "not_observed",
    "memory source evaluation certainty changed"
)
print("PASS memory source discovery: source-time certainty preserved")

assert(
    #discovery.collect(
        nil,
        root,
        adapter,
        function()
            return true
        end,
        {},
        {}
    ) == 0,
    "invalid discovery context must fail closed"
)
print("PASS memory source discovery: invalid inputs fail closed")

print("PASS Tracker_HUD memory-source discovery smoke")
