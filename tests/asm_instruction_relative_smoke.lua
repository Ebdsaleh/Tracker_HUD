-- tests/asm_instruction_relative_smoke.lua
-- Parser-backed RIP/EIP-relative machine-address evaluation regression.
-- nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua").use_working_tree()

    local source = {
        "bits 64",
        "lea rax, [rip + 16]",
        "lea eax, [eip + 16]",
    }

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = "asm"

    local ok, parser = pcall(
        vim.treesitter.get_parser,
        buffer,
        "asm"
    )
    assert(ok and parser,
        "ASM Tree-sitter parser unavailable: " .. tostring(parser))

    local tree = assert(
        parser:parse()[1],
        "ASM parser produced no tree"
    )
    local root = tree:root()

    local adapter =
        require("tracker_hud.adapters.asm.init")
    local registry =
        require("tracker_hud.adapters.registry")

    local registered, register_err =
        registry.register(adapter)
    assert(registered,
        "cannot register ASM adapter: "
            .. tostring(register_err))

    local configured, config_err =
        registry.configure_adapter_for_buffer(
            "asm",
            buffer,
            {}
        )
    assert(configured,
        "cannot configure ASM adapter: "
            .. tostring(config_err))

    assert(adapter.register_alias_index
        and adapter.register_alias_index.rip
        and adapter.register_alias_index.rip.alias
        and adapter.register_alias_index.rip.alias.bits == 64
        and adapter.register_alias_index.eip
        and adapter.register_alias_index.eip.alias
        and adapter.register_alias_index.eip.alias.bits == 32,
        "x86 architecture profile must expose RIP/EIP widths")
    print("PASS ASM instruction-relative: architecture exposes RIP/EIP widths")

    local provider = {
        id = "instruction-relative-fixture",
        kind = "assembler_listing",

        resolve = function(query)
            if query.kind == "instruction" then
                if query.source_line == 2 then
                    return {
                        status = "known",
                        value = "0x100000100",
                        provenance = {
                            source = "fixture listing",
                            record = "rip-instruction",
                        },
                    }
                elseif query.source_line == 3 then
                    return {
                        status = "known",
                        value = "0x100000020",
                        provenance = {
                            source = "fixture listing",
                            record = "eip-instruction",
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
                            record = "rip-next",
                        },
                    }
                elseif query.source_line == 3 then
                    return {
                        status = "known",
                        value = "0x100000027",
                        provenance = {
                            source = "fixture listing",
                            record = "eip-next",
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

    local no_provider_rip =
        engine.discover_memory_source_operands(
            buffer,
            root,
            adapter,
            2
        )

    assert(#no_provider_rip == 1
        and no_provider_rip[1].address.base
        and no_provider_rip[1].address.base.name == "rip"
        and no_provider_rip[1].address.address_size_bits == 64
        and no_provider_rip[1].machine_addresses == nil
        and no_provider_rip[1].effective_address.status == "unknown"
        and no_provider_rip[1].effective_address.reason
            == "relative address basis unresolved",
        "RIP-relative source must fail closed without provider evidence")
    print("PASS ASM instruction-relative: RIP without provider fails closed")

    local rip = engine.discover_memory_source_operands(
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

    assert(#rip == 1,
        "RIP line must expose one memory fact")

    local rip_fact = rip[1]

    assert(rip_fact.address.base
        and rip_fact.address.base.name == "rip"
        and rip_fact.address.address_size_status == "known"
        and rip_fact.address.address_size_bits == 64
        and rip_fact.machine_addresses
        and rip_fact.machine_addresses.next_instruction.status == "known"
        and rip_fact.machine_addresses.next_instruction.value
            == "4294967559"
        and rip_fact.machine_addresses.next_instruction.bits == 64
        and rip_fact.effective_address.status == "known"
        and rip_fact.effective_address.value == "4294967575"
        and rip_fact.effective_address.bits == 64
        and rip_fact.effective_address.wrapped == false
        and rip_fact.effective_address.components.base.name == "rip"
        and rip_fact.effective_address.components.relative_delta == "16"
        and rip_fact.metadata.effective_address_status == "known"
        and rip_fact.metadata.effective_address_value == "4294967575"
        and rip_fact.metadata.next_instruction_machine_address_status
            == "known"
        and rip_fact.metadata.execution_status == "not_observed",
        "RIP-relative fact must use proven next-instruction basis")
    print("PASS ASM instruction-relative: RIP target resolves from next instruction")

    local no_provider_eip =
        engine.discover_memory_source_operands(
            buffer,
            root,
            adapter,
            3
        )

    assert(#no_provider_eip == 1
        and no_provider_eip[1].address.base
        and no_provider_eip[1].address.base.name == "eip"
        and no_provider_eip[1].address.address_size_bits == 32
        and no_provider_eip[1].effective_address.status == "unknown"
        and no_provider_eip[1].effective_address.reason
            == "relative address basis unresolved",
        "EIP-relative source must preserve 32-bit address size and fail closed")
    print("PASS ASM instruction-relative: EIP source preserves 32-bit width")

    local eip = engine.discover_memory_source_operands(
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

    assert(#eip == 1,
        "EIP line must expose one memory fact")

    local eip_fact = eip[1]

    assert(eip_fact.address.base
        and eip_fact.address.base.name == "eip"
        and eip_fact.address.address_size_status == "known"
        and eip_fact.address.address_size_bits == 32
        and eip_fact.machine_addresses
        and eip_fact.machine_addresses.next_instruction.status == "known"
        and eip_fact.machine_addresses.next_instruction.value
            == "4294967335"
        and eip_fact.machine_addresses.next_instruction.bits == 64
        and eip_fact.effective_address.status == "known"
        and eip_fact.effective_address.value == "55"
        and eip_fact.effective_address.bits == 32
        and eip_fact.effective_address.wrapped == true
        and eip_fact.effective_address.components.base.name == "eip"
        and eip_fact.effective_address.components.exact_target
            == "4294967351"
        and eip_fact.metadata.effective_address_value == "55"
        and eip_fact.metadata.effective_address_bits == 32
        and eip_fact.metadata.effective_address_wrapped == true
        and eip_fact.metadata.execution_status == "not_observed",
        "EIP-relative fact must truncate computed address to 32 bits")
    print("PASS ASM instruction-relative: EIP target obeys address-size truncation")

    local rip_focus =
        engine.discover_register_source_occurrences(
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

    local saw_rip = false

    for _, occurrence in ipairs(rip_focus or {}) do
        if occurrence.kind == "memory_component"
            and occurrence.text == "rip"
        then
            local metadata = occurrence.metadata or {}

            assert(metadata.next_instruction_machine_address_status
                    == "known"
                and metadata.next_instruction_machine_address_value
                    == "4294967559"
                and metadata.memory_effective_address_status
                    == "known"
                and metadata.memory_effective_address_value
                    == "4294967575"
                and metadata.memory_effective_address_bits == 64,
                "Inspect must reuse RIP-relative evaluation")
            saw_rip = true
        end
    end

    assert(saw_rip,
        "Inspect did not expose RIP memory component")
    print("PASS ASM instruction-relative: Inspect reuses RIP target")

    print("PASS Tracker_HUD ASM instruction-relative smoke")
end

local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM instruction-relative smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
