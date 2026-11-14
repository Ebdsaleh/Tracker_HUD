-- tests/register_source_discovery_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_source_discovery_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local discovery =
    require("tracker_hud.low_level.register_source_discovery")

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
        components = {
            {
                kind = "register",
                text = "rax",
                role = "base",
                role_label =
                    "base register",
                source_start_column = 10,
                source_end_column = 13,
            },
        },
    },
}

local instruction = {
    mnemonic = "mov",
    source_line = 2,
    source_start_column = 0,
    source_end_column = 18,
    mnemonic_range = {
        source_start_column = 0,
        source_end_column = 3,
    },
    operands = {
        {
            kind = "register",
            text = "rbx",
            source_line = 2,
            source_start_column = 4,
            source_end_column = 7,
        },
        memory_operand,
    },
}

local adapter = {
    metadata = {
        bits = 64,
    },
    register_effects = {},
    register_families = {
        rax = {
            canonical = "rax",
            aliases = {
                rax = {
                    bits = 64,
                },
            },
        },
        rbx = {
            canonical = "rbx",
            aliases = {
                rbx = {
                    bits = 64,
                },
            },
        },
    },
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

local occurrences =
    discovery.collect(
        9,
        root,
        adapter,
        2,
        {},
        {
            get_register_effect_index =
                function(seen_adapter)
                    calls.index =
                        calls.index + 1

                    assert(
                        seen_adapter == adapter,
                        "wrong adapter reached register discovery index dependency"
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
                                == effect_spec,
                        "register discovery parse inputs changed"
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
                        "register discovery evaluation inputs changed"
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
    "register discovery dependency dispatch changed"
)
print("PASS register source discovery: dependency dispatch preserved")

local saw_mnemonic = false
local saw_destination = false
local saw_memory = false
local saw_base = false

for _, occurrence in ipairs(
    occurrences
) do
    if occurrence.kind == "mnemonic"
        and occurrence.text == "mov"
    then
        saw_mnemonic = true
    elseif occurrence.kind == "operand"
        and occurrence.text == "rbx"
    then
        saw_destination =
            occurrence.role
                == "destination"
    elseif occurrence.kind == "operand"
        and occurrence.text
            == "[rax + 8]"
    then
        saw_memory =
            occurrence.metadata
            and occurrence.metadata
                .memory_effective_address_value
                == "4104"
    elseif occurrence.kind
            == "memory_component"
        and occurrence.text == "rax"
    then
        saw_base =
            occurrence.metadata
            and occurrence.metadata
                .memory_effective_address_value
                == "4104"
    end
end

assert(
    saw_mnemonic
        and saw_destination
        and saw_memory
        and saw_base,
    "register source occurrence wiring changed"
)
print("PASS register source discovery: occurrence and memory evidence preserved")

assert(
    #discovery.collect(
        nil,
        root,
        adapter,
        2,
        {},
        {}
    ) == 0,
    "invalid register discovery context must fail closed"
)
print("PASS register source discovery: invalid inputs fail closed")

print("PASS Tracker_HUD register-source discovery smoke")
