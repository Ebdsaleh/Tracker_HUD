-- tests/memory_source_collection_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/memory_source_collection_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local collection =
    require("tracker_hud.low_level.memory_source_collection")

local function fake_node(id, start_row, start_column, end_row, end_column)
    return {
        id = id,
        type = function()
            return "instruction"
        end,
        range = function()
            return start_row,
                start_column,
                end_row,
                end_column
        end,
    }
end

local line2 = fake_node(
    "line2",
    1,
    0,
    1,
    30
)

local line2_duplicate = fake_node(
    "line2-duplicate",
    1,
    0,
    1,
    30
)

local line3 = fake_node(
    "line3",
    2,
    0,
    2,
    20
)

local line4_filtered = fake_node(
    "line4",
    3,
    0,
    3,
    20
)

local instructions = {
    line2 = {
        mnemonic = "mov",
        source_line = 2,
        operands = {
            {
                kind = "memory",
                text = "[rax + 8]",
                source_line = 2,
                source_start_column = 20,
                source_end_line = 2,
                source_end_column = 29,
                memory = {
                    normalized = {
                        address_mode = "default",
                        address_size_status = "known",
                        address_size_bits = 64,
                        address_size_source = "register_width",
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
            },
            {
                kind = "register",
                text = "rbx",
                source_line = 2,
                source_start_column = 4,
                source_end_line = 2,
                source_end_column = 7,
            },
            {
                kind = "memory",
                text = "[rcx]",
                source_line = 2,
                source_start_column = 10,
                source_end_line = 2,
                source_end_column = 15,
                memory = {
                    normalized = {
                        address_mode = "default",
                        address_size_status = "known",
                        address_size_bits = 64,
                        address_size_source = "register_width",
                        base = {
                            name = "rcx",
                        },
                        metadata = {
                            ambiguous = {},
                        },
                    },
                },
            },
        },
    },

    line3 = {
        mnemonic = "lea",
        source_line = 3,
        operands = {
            {
                kind = "register",
                text = "rdx",
                source_line = 3,
                source_start_column = 4,
                source_end_line = 3,
                source_end_column = 7,
            },
            {
                kind = "memory",
                text = "[rsp + 16]",
                source_line = 3,
                source_start_column = 12,
                source_end_line = 3,
                source_end_column = 22,
                memory = {
                    normalized = {
                        address_mode = "default",
                        address_size_status = "known",
                        address_size_bits = 64,
                        address_size_source = "register_width",
                        base = {
                            name = "rsp",
                        },
                        displacement = {
                            value = "16",
                        },
                        metadata = {
                            ambiguous = {},
                        },
                    },
                },
            },
        },
    },

    line4 = {
        mnemonic = "mov",
        source_line = 4,
        operands = {
            {
                kind = "memory",
                text = "[rsi]",
                source_line = 4,
                source_start_column = 8,
                source_end_line = 4,
                source_end_column = 13,
                memory = {
                    normalized = {
                        address_mode = "default",
                        address_size_status = "known",
                        address_size_bits = 64,
                        address_size_source = "register_width",
                        base = {
                            name = "rsi",
                        },
                        metadata = {
                            ambiguous = {},
                        },
                    },
                },
            },
        },
    },
}

local counts = {
    parse = 0,
    match = 0,
    evaluate = 0,
    role = 0,
    access = 0,
}

local facts = collection.collect({
    -- Deliberately out of source order, with a duplicate range and a later
    -- filtered line.
    nodes = {
        line3,
        line2_duplicate,
        line4_filtered,
        line2,
    },

    adapter = {
        metadata = {
            bits = 64,
        },
        construct_specs = {},
    },

    source_members = {},

    line_predicate = function(line)
        return line <= 3
    end,

    parse_instruction = function(node)
        counts.parse = counts.parse + 1

        -- The duplicate range is encountered before the canonical fixture
        -- object, so allow either ID to map to the same semantic instruction.
        if node.id == "line2"
            or node.id == "line2-duplicate"
        then
            return instructions.line2
        end

        return instructions[node.id]
    end,

    match_effects = function(_node, instruction)
        counts.match = counts.match + 1

        return {
            {
                mnemonic = instruction.mnemonic,
            },
        }
    end,

    evaluate_address = function(
        instruction,
        address
    )
        counts.evaluate = counts.evaluate + 1

        local base = address.base
            and address.base.name
            or "?"

        return {
            status = "known",
            value = table.concat({
                instruction.mnemonic,
                base,
            }, ":"),
            bits = 64,
            wrapped = false,
        }
    end,

    get_operand_role = function(
        _matching_specs,
        operand_index
    )
        counts.role = counts.role + 1
        return "source-" .. tostring(operand_index)
    end,

    resolve_access = function(
        instruction,
        operand_index
    )
        counts.access = counts.access + 1

        return instruction.mnemonic == "lea"
                and "address_only"
                or "read",
            {
                declared = true,
                ambiguous = false,
                rule_count = operand_index,
            }
    end,
})

assert(counts.parse == 2
    and counts.match == 2,
    "duplicate or filtered nodes must not be parsed/matched")
print("PASS memory source collection: filters and deduplicates before parsing")

assert(counts.evaluate == 3
    and counts.role == 3
    and counts.access == 3,
    "only normalized memory operands should reach memory-specific callbacks")
print("PASS memory source collection: memory-only callbacks preserved")

assert(#facts == 3,
    "expected exactly three source-memory facts")

assert(facts[1].source_line == 2
    and facts[1].source_start_column == 10
    and facts[1].operand_index == 3
    and facts[1].text == "[rcx]"
    and facts[2].source_line == 2
    and facts[2].source_start_column == 20
    and facts[2].operand_index == 1
    and facts[2].text == "[rax + 8]"
    and facts[3].source_line == 3
    and facts[3].source_start_column == 12
    and facts[3].operand_index == 2
    and facts[3].text == "[rsp + 16]",
    "source-memory facts must retain stable source ordering")
print("PASS memory source collection: stable source ordering preserved")

assert(facts[1].role == "source-3"
    and facts[1].access == "read"
    and facts[1].effective_address.value == "mov:rcx"
    and facts[1].metadata.access_rule_count == 3
    and facts[3].role == "source-2"
    and facts[3].access == "address_only"
    and facts[3].effective_address.value == "lea:rsp"
    and facts[3].metadata.execution_status == "not_observed",
    "collector must preserve injected semantic decisions without inventing execution")
print("PASS memory source collection: semantic callback results preserved")

assert(collection.collect({
        adapter = {},
        line_predicate = function() return true end,
    })[1] == nil,
    "incomplete collector dependencies must fail closed")
print("PASS memory source collection: incomplete dependencies fail closed")

print("PASS Tracker_HUD memory-source collection smoke")
