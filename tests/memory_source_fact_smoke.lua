-- tests/memory_source_fact_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/memory_source_fact_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local memory_source_fact =
    require("tracker_hud.low_level.memory_source_fact")

local address = {
    address_mode = "relative",
    address_size_bits = 32,
    address_size_status = "known",
    address_size_source = "explicit_prefix",
    address_size_reason = nil,
    symbol = {
        name = "msg",
    },
    metadata = {
        ambiguous = {},
    },
}

local evaluation = {
    status = "known",
    value = "4294971392",
    bits = 64,
    wrapped = false,
}

local identity = {
    status = "known",
    name = "msg",
    kind = "label",
    member_id = "member:msg",
    source_line = 6,
    source_start_column = 0,
    source_end_line = 6,
    source_end_column = 4,
    forward_reference = true,
    reason = nil,
    machine_address_status = "unknown",
    machine_address = nil,
    machine_address_reason = "machine address unavailable",
}

local machine_addresses = {
    instruction = {
        status = "known",
        value = "4294967552",
        bits = 64,
    },
    next_instruction = {
        status = "known",
        value = "4294967559",
        bits = 64,
    },
    symbol = {
        status = "known",
        value = "4294971392",
        bits = 64,
    },
}

local fact = memory_source_fact.new({
    instruction = {
        mnemonic = "lea",
        source_line = 2,
    },
    operand = {
        kind = "memory",
        text = "[rel msg]",
        source_line = 2,
        source_column = 13,
        source_start_line = 2,
        source_start_column = 13,
        source_end_line = 2,
        source_end_column = 22,
        memory = {
            normalized = address,
        },
    },
    operand_index = 2,
    role = "source",
    access = "address_only",
    access_metadata = {
        declared = true,
        ambiguous = false,
        rule_count = 1,
    },
    evaluation = evaluation,
    symbol_identity = identity,
    machine_addresses = machine_addresses,
})

assert(fact
    and fact.id == "memory-operand:2:13:2"
    and fact.kind == "memory_operand"
    and fact.category == "memory"
    and fact.source == "asm_source_memory"
    and fact.text == "[rel msg]"
    and fact.role == "source"
    and fact.access == "address_only"
    and fact.operand_index == 2,
    "source-memory fact identity and role contract changed")
print("PASS memory source fact: identity and role preserved")

assert(fact.source_line == 2
    and fact.source_start_column == 13
    and fact.source_end_line == 2
    and fact.source_end_column == 22
    and fact.address == address
    and fact.effective_address == evaluation
    and fact.symbol_identity == identity
    and fact.machine_addresses == machine_addresses,
    "source-memory fact nested evidence contract changed")
print("PASS memory source fact: source range and nested evidence preserved")

local metadata = fact.metadata or {}

assert(metadata.observation == "source memory operand only"
    and metadata.mnemonic == "lea"
    and metadata.operand_role == "source"
    and metadata.access_intent == "address_only"
    and metadata.access_declared == true
    and metadata.access_ambiguous == false
    and metadata.access_rule_count == 1
    and metadata.address_size_bits == 32
    and metadata.address_size_status == "known"
    and metadata.address_size_source == "explicit_prefix"
    and metadata.runtime_address == "unknown"
    and metadata.execution_status == "not_observed",
    "source-memory fact base metadata contract changed")
print("PASS memory source fact: base metadata preserved")

assert(metadata.effective_address_status == "known"
    and metadata.effective_address_value == "4294971392"
    and metadata.effective_address_bits == 64
    and metadata.effective_address_wrapped == false
    and metadata.source_symbol_status == "known"
    and metadata.source_symbol_name == "msg"
    and metadata.source_symbol_forward_reference == true
    and metadata.instruction_machine_address_status == "known"
    and metadata.instruction_machine_address_value == "4294967552"
    and metadata.next_instruction_machine_address_status == "known"
    and metadata.next_instruction_machine_address_value == "4294967559"
    and metadata.symbol_machine_address_status == "known"
    and metadata.symbol_machine_address_value == "4294971392",
    "source-memory fact flattened certainty metadata changed")
print("PASS memory source fact: flattened certainty metadata preserved")

assert(memory_source_fact.new({
        instruction = {
            mnemonic = "mov",
            source_line = 2,
        },
        operand = {
            kind = "register",
            text = "rax",
        },
        operand_index = 1,
    }) == nil,
    "non-memory operand must not produce a source-memory fact")
print("PASS memory source fact: non-memory operands remain excluded")

assert(memory_source_fact.new({
        instruction = {
            mnemonic = "mov",
            source_line = 2,
        },
        operand = {
            kind = "memory",
            text = "[rax]",
            memory = {},
        },
        operand_index = 1,
    }) == nil,
    "unstructured memory operand must not produce a source-memory fact")
print("PASS memory source fact: unnormalized memory remains excluded")

print("PASS Tracker_HUD memory-source fact smoke")
