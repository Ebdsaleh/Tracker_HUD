-- tests/memory_source_evidence_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/memory_source_evidence_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local evidence =
    require("tracker_hud.low_level.memory_source_evidence")

local adapter = {
    metadata = {
        bits = 64,
    },
    construct_specs = {
        ptr = {
            operand = {
                memory = {
                    symbol_resolution = {
                        member_kinds = { "label" },
                        allow_forward = true,
                        case_sensitive = true,
                    },
                    instruction_relative = {
                        bases = {
                            rip = {
                                basis = "next_instruction",
                                result_width = "address_size",
                                symbol_mode = "target",
                            },
                        },
                    },
                },
            },
        },
    },
}

local operand = {
    node_type = "ptr",
    source_line = 2,
    memory = {
        normalized = {
            address_mode = "default",
            address_size_status = "known",
            address_size_bits = 64,
            base = {
                name = "rip",
            },
            symbol = {
                name = "msg",
            },
            displacement = {
                text = "8",
                value = "8",
            },
            metadata = {
                ambiguous = {},
            },
        },
    },
}

local members = {
    {
        id = "member:msg",
        kind = "label",
        name = "msg",
        line = 6,
        source_start_line = 6,
        source_start_column = 0,
        source_end_line = 6,
        source_end_column = 4,
    },
}

local identity = evidence.resolve_symbol_identity(
    members,
    adapter,
    operand
)

assert(identity
    and identity.status == "known"
    and identity.name == "msg"
    and identity.source_line == 6
    and identity.forward_reference == true,
    "extracted evidence helper must preserve source-symbol policy")
print("PASS memory source evidence: source-symbol identity preserved")

local policy = evidence.get_instruction_relative_policy(
    adapter,
    operand
)

assert(policy
    and policy.bases
    and policy.bases.rip
    and policy.bases.rip.symbol_mode == "target",
    "extracted evidence helper must preserve adapter relative policy")
print("PASS memory source evidence: instruction-relative policy preserved")

local provider = {
    id = "memory-evidence-fixture",
    kind = "assembler_listing",
    resolve = function(query)
        if query.kind == "instruction" then
            return {
                status = "known",
                value = "0x100000200",
            }
        elseif query.kind == "next_instruction" then
            return {
                status = "known",
                value = "0x100000207",
            }
        elseif query.kind == "symbol"
            and query.name == "msg"
        then
            assert(query.source_symbol_member_id == "member:msg"
                and query.source_symbol_line == 6,
                "symbol provider query must preserve source identity keys")
            return {
                status = "known",
                value = "0x100001000",
            }
        end

        return {
            status = "unknown",
            reason = "not in fixture",
        }
    end,
}

local addresses = evidence.resolve_machine_addresses(
    { provider },
    adapter,
    {
        mnemonic = "lea",
        source_start_line = 2,
        source_start_column = 0,
    },
    operand.memory.normalized,
    identity,
    policy
)

assert(addresses
    and addresses.instruction.status == "known"
    and addresses.instruction.value == "4294967808"
    and addresses.instruction.bits == 64
    and addresses.next_instruction.status == "known"
    and addresses.next_instruction.value == "4294967815"
    and addresses.next_instruction.bits == 64
    and addresses.symbol.status == "known"
    and addresses.symbol.value == "4294971392"
    and addresses.symbol.bits == 64,
    "extracted evidence helper must preserve exact 64-bit provider evidence")
print("PASS memory source evidence: machine-address evidence preserved")

assert(evidence.resolve_machine_addresses(
        nil,
        adapter,
        {
            mnemonic = "lea",
            source_start_line = 2,
        },
        operand.memory.normalized,
        identity,
        policy
    ) == nil,
    "no-provider behavior must remain unchanged")
print("PASS memory source evidence: no-provider path preserved")

local metadata = {}

evidence.append_effective_address_metadata(
    metadata,
    {
        status = "known",
        value = "4294971400",
        bits = 64,
        wrapped = false,
    },
    "effective_address"
)

evidence.append_source_symbol_metadata(
    metadata,
    identity
)

evidence.append_machine_address_metadata(
    metadata,
    addresses
)

assert(metadata.effective_address_status == "known"
    and metadata.effective_address_value == "4294971400"
    and metadata.effective_address_bits == 64
    and metadata.effective_address_wrapped == false
    and metadata.source_symbol_status == "known"
    and metadata.source_symbol_name == "msg"
    and metadata.symbol_machine_address_status == "known"
    and metadata.symbol_machine_address_value == "4294971392"
    and metadata.next_instruction_machine_address_status == "known"
    and metadata.next_instruction_machine_address_value == "4294967815",
    "extracted evidence helper must preserve flattened metadata contract")
print("PASS memory source evidence: flattened metadata contract preserved")

print("PASS Tracker_HUD memory-source evidence smoke")
