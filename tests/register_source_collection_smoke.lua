-- tests/register_source_collection_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_source_collection_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local collection =
    require("tracker_hud.low_level.register_source_collection")

local function fake_node(
    id,
    start_row,
    start_column,
    end_row,
    end_column
)
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

local filtered = fake_node(
    "filtered",
    0,
    0,
    0,
    12
)

local duplicate = fake_node(
    "duplicate",
    1,
    0,
    1,
    20
)

local canonical = fake_node(
    "canonical",
    1,
    0,
    1,
    20
)

local syntax_only = fake_node(
    "syntax-only",
    1,
    24,
    1,
    35
)

local memory_operand = {
    kind = "memory",
    text = "[rbp]",
    source_line = 2,
    source_start_column = 13,
    source_end_line = 2,
    source_end_column = 18,
    memory = {
        address_text = "rbp",
        address_kind = "bracketed",
        normalized = {
            address_mode = "default",
            address_size_bits = 64,
            address_size_status = "known",
            address_size_source = "register_width",
            base = {
                name = "rbp",
            },
        },
        components = {
            {
                kind = "register",
                text = "rbp",
                role = "base",
                role_label = "base register",
                structural_role = "base",
                source_start_column = 14,
                source_end_column = 17,
            },
        },
    },
}

local mov_instruction = {
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
            text = "eax",
            source_line = 2,
            source_start_column = 4,
            source_end_column = 7,
        },
        memory_operand,
    },
}

local syntax_instruction = {
    mnemonic = "mystery",
    source_line = 2,
    source_start_column = 24,
    source_end_column = 35,
    mnemonic_range = {
        source_start_column = 24,
        source_end_column = 31,
    },
    operands = {
        {
            kind = "register",
            text = "rsi",
            source_line = 2,
            source_start_column = 32,
            source_end_column = 35,
        },
    },
}

local effect_specs = {
    {
        operands = {
            {
                index = 1,
                role = "destination_register",
            },
            {
                index = 2,
                role = "source_memory",
            },
        },
        effect = {
            target_operand = 1,
        },
    },
}

local adapter = {
    metadata = {
        bits = 64,
    },
    register_families = {
        rax = {
            canonical = "rax",
            aliases = {
                rax = { bits = 64 },
                eax = { bits = 32 },
            },
        },
        rbp = {
            canonical = "rbp",
            aliases = {
                rbp = { bits = 64 },
            },
        },
        rsi = {
            canonical = "rsi",
            aliases = {
                rsi = { bits = 64 },
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

local counts = {
    collect_nodes = 0,
    parse = 0,
    evaluate = 0,
}

local occurrences = collection.collect({
    adapter = adapter,
    line_number = 2,
    node_types = {
        instruction = true,
    },
    source_members = {},

    collect_nodes = function(node_type)
        counts.collect_nodes =
            counts.collect_nodes + 1

        assert(node_type == "instruction",
            "unexpected node type requested")

        return {
            filtered,
            duplicate,
            canonical,
            syntax_only,
        }
    end,

    parse_and_match = function(node)
        counts.parse = counts.parse + 1

        if node.id == "duplicate"
            or node.id == "canonical"
        then
            return mov_instruction,
                effect_specs
        end

        if node.id == "syntax-only" then
            return syntax_instruction,
                {}
        end

        error("filtered node reached parser")
    end,

    evaluate_address = function(
        instruction,
        address
    )
        counts.evaluate =
            counts.evaluate + 1

        assert(instruction == mov_instruction
            and address == memory_operand.memory.normalized,
            "unexpected address evaluation input")

        return {
            status = "known",
            value = "4096",
            bits = 64,
            wrapped = false,
        }
    end,
})

assert(counts.collect_nodes == 1
    and counts.parse == 2,
    "line filtering and duplicate suppression must happen before parsing")
print("PASS register source collection: filters and deduplicates before parsing")

assert(counts.evaluate == 1,
    "only normalized memory operands should be evaluated")
print("PASS register source collection: evaluates normalized memory only")

assert(#occurrences == 6,
    "expected mnemonic/operand/component occurrences from two instructions")

local mov_mnemonic = occurrences[1]
local destination = occurrences[2]
local source = occurrences[3]
local base = occurrences[4]
local syntax_mnemonic = occurrences[5]
local syntax_register = occurrences[6]

assert(mov_mnemonic.kind == "mnemonic"
    and mov_mnemonic.text == "mov"
    and destination.kind == "operand"
    and destination.text == "eax"
    and source.kind == "operand"
    and source.text == "[rbp]"
    and base.kind == "memory_component"
    and base.text == "rbp",
    "semantic instruction occurrence ordering changed")
print("PASS register source collection: occurrence ordering preserved")

assert(source.metadata.memory_effective_address_status == "known"
    and source.metadata.memory_effective_address_value == "4096"
    and source.metadata.memory_effective_address_bits == 64
    and source.metadata.memory_effective_address_wrapped == false
    and source.metadata.memory_execution_status == "not_observed"
    and base.metadata.memory_effective_address_status == "known"
    and base.metadata.memory_effective_address_value == "4096",
    "memory certainty evidence must be attached to operand and component occurrences")
print("PASS register source collection: memory evidence attachment preserved")

assert(syntax_mnemonic.kind == "mnemonic"
    and syntax_mnemonic.text == "mystery"
    and #syntax_mnemonic.targets.state == 0
    and syntax_register.kind == "operand"
    and syntax_register.text == "rsi"
    and syntax_register.role == nil
    and #syntax_register.targets.state == 1
    and syntax_register.targets.state[1] == "register:rsi",
    "syntax-only focus must survive an empty semantic match set")
print("PASS register source collection: syntax-only focus preserved")

assert(#collection.collect({
        adapter = {},
        line_number = 2,
        node_types = {},
    }) == 0,
    "incomplete collection dependencies must fail closed")
print("PASS register source collection: incomplete dependencies fail closed")

print("PASS Tracker_HUD register-source collection smoke")
