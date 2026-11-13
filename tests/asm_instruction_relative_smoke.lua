-- tests/asm_instruction_relative_smoke.lua
-- Parser-backed RIP-relative machine-address evaluation regression.
-- nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua").use_working_tree()

    local source = {
        "bits 64",
        "lea rax, [rip + 16]",
        "a32 lea eax, [rip + 16]",
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
                            record = "a32-rip-instruction",
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
                            record = "a32-rip-next",
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
        and no_provider_rip[1].address.address_size_status == "known"
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
        and rip_fact.address.address_size_source == "register_width"
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

    local no_provider_a32 =
        engine.discover_memory_source_operands(
            buffer,
            root,
            adapter,
            3
        )

    assert(#no_provider_a32 == 1
        and no_provider_a32[1].address.base
        and no_provider_a32[1].address.base.name == "rip"
        and no_provider_a32[1].address.address_size_status == "known"
        and no_provider_a32[1].address.address_size_bits == 32
        and no_provider_a32[1].address.address_size_source
            == "explicit_prefix"
        and no_provider_a32[1].effective_address.status == "unknown"
        and no_provider_a32[1].effective_address.reason
            == "relative address basis unresolved",
        "A32 RIP-relative source must preserve explicit 32-bit address size")
    print("PASS ASM instruction-relative: A32 RIP source preserves 32-bit width")

    local a32 = engine.discover_memory_source_operands(
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

    assert(#a32 == 1,
        "A32 RIP line must expose one memory fact")

    local a32_fact = a32[1]

    assert(a32_fact.address.base
        and a32_fact.address.base.name == "rip"
        and a32_fact.address.address_size_status == "known"
        and a32_fact.address.address_size_bits == 32
        and a32_fact.address.address_size_source == "explicit_prefix"
        and a32_fact.machine_addresses
        and a32_fact.machine_addresses.next_instruction.status == "known"
        and a32_fact.machine_addresses.next_instruction.value
            == "4294967335"
        and a32_fact.machine_addresses.next_instruction.bits == 64
        and a32_fact.effective_address.status == "known"
        and a32_fact.effective_address.value == "55"
        and a32_fact.effective_address.bits == 32
        and a32_fact.effective_address.wrapped == true
        and a32_fact.effective_address.components.base.name == "rip"
        and a32_fact.effective_address.components.exact_target
            == "4294967351"
        and a32_fact.metadata.effective_address_value == "55"
        and a32_fact.metadata.effective_address_bits == 32
        and a32_fact.metadata.effective_address_wrapped == true
        and a32_fact.metadata.execution_status == "not_observed",
        "A32 RIP-relative fact must truncate computed address to 32 bits")
    print("PASS ASM instruction-relative: A32 RIP target truncates to 32 bits")

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
