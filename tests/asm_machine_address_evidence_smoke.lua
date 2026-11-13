-- tests/asm_machine_address_evidence_smoke.lua
-- Parser-backed machine-address provider evidence regression.
-- nvim --headless -c "luafile tests/asm_machine_address_evidence_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua").use_working_tree()

    local source = {
        "bits 64",
        "a32 lea rsi, [rel msg]",
        "lea rdi, [rel external]",
        "msg:",
        "mov rax, rax",
    }

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = "asm"

    local ok, parser = pcall(vim.treesitter.get_parser, buffer, "asm")
    assert(ok and parser, "ASM Tree-sitter parser unavailable: " .. tostring(parser))

    local tree = assert(parser:parse()[1], "ASM parser produced no tree")
    local root = tree:root()

    local adapter = require("tracker_hud.adapters.asm.init")
    local registry = require("tracker_hud.adapters.registry")

    local registered, register_err = registry.register(adapter)
    assert(registered, "cannot register ASM adapter: " .. tostring(register_err))

    local configured, config_err =
        registry.configure_adapter_for_buffer("asm", buffer, {})
    assert(configured, "cannot configure ASM adapter: " .. tostring(config_err))

    local provider = {
        id = "fixture-listing",
        kind = "assembler_listing",

        resolve = function(query)
            if query.kind == "instruction" then
                if query.source_line == 2 then
                    return {
                        status = "known",
                        value = "0x100000100",
                        provenance = {
                            source = "fixture listing",
                            record = "line2",
                        },
                    }
                elseif query.source_line == 3 then
                    return {
                        status = "known",
                        value = "0x400200",
                        provenance = {
                            source = "fixture listing",
                            record = "line3",
                        },
                    }
                end
            elseif query.kind == "next_instruction" then
                if query.source_line == 2 then
                    return {
                        status = "known",
                        value = "0x100000107",
                        provenance = {
                            source = "fixture listing",
                            record = "line2-next",
                        },
                    }
                elseif query.source_line == 3 then
                    return {
                        status = "known",
                        value = "0x400207",
                        provenance = {
                            source = "fixture listing",
                            record = "line3-next",
                        },
                    }
                end
            elseif query.kind == "symbol" then
                if query.name == "msg" then
                    return {
                        status = "known",
                        value = "0x100001000",
                        provenance = {
                            source = "fixture symbols",
                            record = "msg",
                        },
                    }
                elseif query.name == "external" then
                    return {
                        status = "known",
                        value = "0x500000",
                        provenance = {
                            source = "fixture symbols",
                            record = "external",
                        },
                    }
                end
            end

            return {
                status = "unknown",
                reason = "fixture has no matching address",
            }
        end,
    }

    local engine = require("tracker_hud.context_engine")

    local no_provider = engine.discover_memory_source_operands(
        buffer,
        root,
        adapter,
        2
    )

    local function expect_equal(actual, expected, label)
        assert(actual == expected,
            label
                .. ": expected "
                .. tostring(expected)
                .. ", got "
                .. tostring(actual))
    end

    expect_equal(#no_provider, 1,
        "no-provider memory fact count")

    local no_provider_fact = no_provider[1]

    assert(no_provider_fact.machine_addresses == nil,
        "no-provider machine_addresses must stay nil")
    assert(no_provider_fact.symbol_identity,
        "no-provider source symbol identity missing")
    expect_equal(
        no_provider_fact.symbol_identity.status,
        "known",
        "no-provider source symbol status"
    )
    expect_equal(
        no_provider_fact.metadata.symbol_machine_address_status,
        "unknown",
        "no-provider symbol machine-address status"
    )
    expect_equal(
        no_provider_fact.effective_address.status,
        "unknown",
        "no-provider effective-address status"
    )
    expect_equal(
        no_provider_fact.effective_address.reason,
        "relative address basis unresolved",
        "no-provider effective-address reason"
    )
    print("PASS ASM machine address: no providers preserve existing REL behavior")

    local with_provider = engine.discover_memory_source_operands(
        buffer,
        root,
        adapter,
        2,
        {
            machine_address_providers = {
                provider,
            },
        }
    )

    assert(#with_provider == 1,
        "line 2 must expose one memory fact")

    local fact = with_provider[1]
    local evidence = fact.machine_addresses

    assert(evidence
        and evidence.instruction.status == "known"
        and evidence.instruction.value == "4294967552"
        and evidence.instruction.bits == 64
        and evidence.next_instruction.status == "known"
        and evidence.next_instruction.value == "4294967559"
        and evidence.next_instruction.bits == 64
        and evidence.symbol.status == "known"
        and evidence.symbol.value == "4294971392"
        and evidence.symbol.bits == 64
        and evidence.symbol.provenance[1].provider_id == "fixture-listing"
        and evidence.symbol.provenance[1].provider_kind == "assembler_listing"
        and evidence.symbol.provenance[1].source == "fixture symbols"
        and fact.metadata.instruction_machine_address_status == "known"
        and fact.address.address_size_bits == 32
        and fact.metadata.instruction_machine_address_value == "4294967552"
        and fact.metadata.instruction_machine_address_bits == 64
        and fact.metadata.next_instruction_machine_address_status == "known"
        and fact.metadata.next_instruction_machine_address_value == "4294967559"
        and fact.metadata.next_instruction_machine_address_bits == 64
        and fact.metadata.symbol_machine_address_status == "known"
        and fact.metadata.symbol_machine_address_value == "4294971392"
        and fact.metadata.symbol_machine_address_bits == 64
        and fact.symbol_identity.status == "known"
        and fact.symbol_identity.source_line == 4
        and fact.effective_address.status == "known"
        and fact.effective_address.value == "4294971392"
        and fact.effective_address.bits == 64
        and fact.effective_address.components.basis.value == "4294967559"
        and fact.effective_address.components.relative_delta == "3833"
        and fact.metadata.effective_address_status == "known"
        and fact.metadata.effective_address_value == "4294971392"
        and fact.metadata.effective_address_bits == 64,
        "provider evidence must prove the REL target in machine-address width")
    print("PASS ASM machine address: A32 REL resolves 64-bit machine target")

    local external = engine.discover_memory_source_operands(
        buffer,
        root,
        adapter,
        3,
        {
            machine_address_providers = {
                provider,
            },
        }
    )

    assert(#external == 1
        and external[1].symbol_identity
        and external[1].symbol_identity.status == "unknown"
        and external[1].symbol_identity.reason
            == "source symbol declaration not found"
        and external[1].machine_addresses
        and external[1].machine_addresses.symbol.status == "known"
        and external[1].machine_addresses.symbol.value == "5242880"
        and external[1].metadata.symbol_machine_address_status == "known"
        and external[1].metadata.symbol_machine_address_value == "5242880"
        and external[1].effective_address.status == "known"
        and external[1].effective_address.value == "5242880"
        and external[1].effective_address.bits == 64
        and external[1].effective_address.components.relative_delta == "1048057",
        "provider-known external symbol must resolve without a source declaration")
    print("PASS ASM machine address: provider-known external REL target resolves")

    local focus = engine.discover_register_source_occurrences(
        buffer,
        root,
        adapter,
        2,
        {
            machine_address_providers = {
                provider,
            },
        }
    )

    local saw_symbol = false

    for _, occurrence in ipairs(focus or {}) do
        if occurrence.kind == "memory_component"
            and occurrence.text == "msg"
        then
            local metadata = occurrence.metadata or {}

            assert(metadata.source_symbol_status == "known"
                and metadata.source_symbol_line == 4
                and metadata.symbol_machine_address_status == "known"
                and metadata.memory_address_size_bits == 32
                and metadata.symbol_machine_address_value == "4294971392"
                and metadata.symbol_machine_address_bits == 64
                and metadata.next_instruction_machine_address_status == "known"
                and metadata.next_instruction_machine_address_value == "4294967559"
                and metadata.next_instruction_machine_address_bits == 64
                and metadata.memory_effective_address_status == "known"
                and metadata.memory_effective_address_value == "4294971392"
                and metadata.memory_effective_address_bits == 64,
                "Inspect must reuse the proven REL target")
            saw_symbol = true
        end
    end

    assert(saw_symbol,
        "Inspect did not expose msg memory component")
    print("PASS ASM machine address: Inspect reuses machine-address evidence")

    vim.api.nvim_set_current_buf(buffer)
    vim.api.nvim_win_set_cursor(0, { 5, 0 })

    local context = require("tracker_hud.context")
        .get_cursor_context(
            buffer,
            {
                machine_address_providers = {
                    provider,
                },
            }
        )

    local by_line = {}

    for _, item in ipairs(context.source_memory_operands or {}) do
        by_line[item.source_line] = item
    end

    assert(by_line[2]
        and by_line[2].machine_addresses
        and by_line[2].address.address_size_bits == 32
        and by_line[2].machine_addresses.symbol.value == "4294971392"
        and by_line[2].machine_addresses.symbol.bits == 64
        and by_line[2].machine_addresses.next_instruction.value == "4294967559"
        and by_line[2].machine_addresses.next_instruction.bits == 64
        and by_line[2].effective_address.status == "known"
        and by_line[2].effective_address.value == "4294971392"
        and by_line[2].effective_address.bits == 64
        and by_line[3]
        and by_line[3].machine_addresses
        and by_line[3].machine_addresses.symbol.value == "5242880"
        and by_line[3].effective_address.status == "known"
        and by_line[3].effective_address.value == "5242880"
        and by_line[2].metadata.execution_status == "not_observed"
        and by_line[3].metadata.execution_status == "not_observed",
        "normal context must forward proven REL targets without execution claims")
    print("PASS ASM machine address: context forwards provider evidence")

    print("PASS Tracker_HUD ASM machine-address evidence smoke")
end

local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM machine-address evidence smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
