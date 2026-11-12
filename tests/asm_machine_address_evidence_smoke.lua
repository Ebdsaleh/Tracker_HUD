-- tests/asm_machine_address_evidence_smoke.lua
-- Parser-backed machine-address provider evidence regression.
-- nvim --headless -c "luafile tests/asm_machine_address_evidence_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua").use_working_tree()

    local source = {
        "bits 64",
        "lea rsi, [rel msg]",
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
                        value = "0x400100",
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
                        value = "0x400107",
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
                        value = "0x401000",
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

    assert(#no_provider == 1
        and no_provider[1].machine_addresses == nil
        and no_provider[1].symbol_identity
        and no_provider[1].symbol_identity.status == "known"
        and no_provider[1].metadata.symbol_machine_address_status == "unknown"
        and no_provider[1].effective_address.status == "unknown"
        and no_provider[1].effective_address.reason
            == "relative address basis unresolved",
        "no-provider path must preserve pre-provider REL behavior")
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
        and evidence.instruction.value == "4194560"
        and evidence.next_instruction.status == "known"
        and evidence.next_instruction.value == "4194567"
        and evidence.symbol.status == "known"
        and evidence.symbol.value == "4198400"
        and evidence.symbol.provenance[1].provider_id == "fixture-listing"
        and evidence.symbol.provenance[1].provider_kind == "assembler_listing"
        and evidence.symbol.provenance[1].source == "fixture symbols"
        and fact.metadata.instruction_machine_address_status == "known"
        and fact.metadata.instruction_machine_address_value == "4194560"
        and fact.metadata.next_instruction_machine_address_status == "known"
        and fact.metadata.next_instruction_machine_address_value == "4194567"
        and fact.metadata.symbol_machine_address_status == "known"
        and fact.metadata.symbol_machine_address_value == "4198400"
        and fact.symbol_identity.status == "known"
        and fact.symbol_identity.source_line == 4
        and fact.effective_address.status == "unknown"
        and fact.effective_address.reason == "relative address basis unresolved",
        "provider evidence must attach without prematurely resolving REL address")
    print("PASS ASM machine address: source label + provider addresses stay separate")

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
        and external[1].metadata.symbol_machine_address_value == "5242880",
        "provider-known external symbol must not require a source declaration")
    print("PASS ASM machine address: external symbol address can be provider-known")

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
                and metadata.symbol_machine_address_value == "4198400"
                and metadata.next_instruction_machine_address_status == "known"
                and metadata.next_instruction_machine_address_value == "4194567"
                and metadata.memory_effective_address_status == "unknown",
                "Inspect must reuse provider evidence without resolving REL early")
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
        and by_line[2].machine_addresses.symbol.value == "4198400"
        and by_line[2].machine_addresses.next_instruction.value == "4194567"
        and by_line[3]
        and by_line[3].machine_addresses
        and by_line[3].machine_addresses.symbol.value == "5242880"
        and by_line[2].metadata.execution_status == "not_observed"
        and by_line[3].metadata.execution_status == "not_observed",
        "normal context must forward provider evidence without execution claims")
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
