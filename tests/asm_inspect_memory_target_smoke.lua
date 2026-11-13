-- tests/asm_inspect_memory_target_smoke.lua
-- Parser-backed HUD Inspect regression for proven memory-target certainty.
-- nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua").use_working_tree()

    local source = {
        "bits 64",
        "lea rax, [rip + 16]",
        "nop",
        "lea rbx, [rip + msg + 8]",
        "msg:",
        "mov rax, rax",
    }

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = "asm"
    vim.api.nvim_set_current_buf(buffer)

    local msg_start = assert(
        source[4]:find("msg", 1, true),
        "fixture msg token missing"
    ) - 1

    vim.api.nvim_win_set_cursor(
        0,
        { 4, msg_start }
    )

    local ok, parser = pcall(
        vim.treesitter.get_parser,
        buffer,
        "asm"
    )
    assert(ok and parser,
        "ASM Tree-sitter parser unavailable: " .. tostring(parser))
    assert(parser:parse()[1],
        "ASM parser produced no tree")

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
        id = "inspect-target-fixture",
        kind = "assembler_listing",

        resolve = function(query)
            if query.kind == "instruction"
                and query.source_line == 4
            then
                return {
                    status = "known",
                    value = "0x100000200",
                    provenance = {
                        source = "fixture listing",
                        record = "line4",
                    },
                }
            elseif query.kind == "next_instruction"
                and query.source_line == 4
            then
                return {
                    status = "known",
                    value = "0x100000207",
                    provenance = {
                        source = "fixture listing",
                        record = "line4-next",
                    },
                }
            elseif query.kind == "symbol"
                and query.name == "msg"
            then
                return {
                    status = "known",
                    value = "0x100001000",
                    provenance = {
                        source = "fixture symbols",
                        record = "msg",
                    },
                }
            end

            return {
                status = "unknown",
                reason = "fixture has no matching address",
            }
        end,
    }

    local context_module =
        require("tracker_hud.context")
    local context =
        context_module.get_cursor_context(
            buffer,
            {}
        )

    assert(type(context) == "table"
        and type(context.registers) == "table",
        "cursor context did not expose registers")

    local hud_sections =
        require("tracker_hud.hud_sections")

    local without_provider =
        hud_sections.update_register_cursor_inspection({
            bufnr = buffer,
            line = 4,
            column = msg_start,
            context = context,
            config = {},
        })

    assert(without_provider == true,
        "Inspect without provider did not select msg occurrence")
    assert(context.register_inspection
        and context.register_inspection.occurrence
        and context.register_inspection.occurrence.text == "msg",
        "Inspect did not select msg memory component")

    local unknown_metadata =
        context.register_inspection.occurrence.metadata or {}

    assert(unknown_metadata.memory_effective_address_status
            == "unknown"
        and unknown_metadata.memory_effective_address_reason
            == "relative address basis unresolved"
        and unknown_metadata.source_symbol_status == "known"
        and unknown_metadata.source_symbol_name == "msg"
        and unknown_metadata.symbol_machine_address_status
            == "unknown"
        and unknown_metadata.memory_execution_status
            == "not_observed",
        "provider-free Inspect certainty must remain fail-closed")
    print("PASS ASM Inspect target: provider-free occurrence stays unknown")

    local with_provider =
        hud_sections.update_register_cursor_inspection({
            bufnr = buffer,
            line = 4,
            column = msg_start,
            context = context,
            config = {
                machine_address_providers = {
                    provider,
                },
            },
        })

    assert(with_provider == true,
        "provider-aware Inspect did not select msg occurrence")

    local occurrence =
        context.register_inspection
        and context.register_inspection.occurrence
        or nil
    local metadata =
        occurrence and occurrence.metadata or {}

    assert(occurrence
        and occurrence.text == "msg"
        and metadata.memory_effective_address_status == "known"
        and metadata.memory_effective_address_value
            == "4294971400"
        and metadata.memory_effective_address_bits == 64
        and metadata.source_symbol_status == "known"
        and metadata.source_symbol_name == "msg"
        and metadata.symbol_machine_address_status == "known"
        and metadata.symbol_machine_address_value
            == "4294971392"
        and metadata.next_instruction_machine_address_status
            == "known"
        and metadata.next_instruction_machine_address_value
            == "4294967815"
        and metadata.memory_execution_status == "not_observed",
        "provider-aware Inspect must refresh cached occurrence evidence")
    print("PASS ASM Inspect target: provider change refreshes cached evidence")

    local register_tree =
        require("tracker_hud.sections.low_level.register_tree")
    local nodes =
        register_tree.build(
            context.registers,
            context,
            {
                config = {
                    machine_address_providers = {
                        provider,
                    },
                },
            }
        )

    local function find_node_by_id(items, id)
        for _, item in ipairs(items or {}) do
            if item.id == id then
                return item
            end

            local found = find_node_by_id(
                item.children,
                id
            )

            if found then
                return found
            end
        end

        return nil
    end

    local rbx = find_node_by_id(
        nodes,
        "register:rbx"
    )
    assert(rbx,
        "Registers tree did not expose RBX")

    local labels = {}

    for _, child in ipairs(rbx.children or {}) do
        labels[child.label] = true
    end

    local expected = {
        ["effective target: 4294971400"] = true,
        ["target certainty: known"] = true,
        ["target width: 64-bit"] = true,
        ["target wrapped: false"] = true,
        ["source symbol: msg"] = true,
        ["source symbol certainty: known"] = true,
        ["symbol machine address: 4294971392"] = true,
        ["symbol machine address certainty: known"] = true,
        ["next instruction address: 4294967815"] = true,
        ["execution status: not_observed"] = true,
    }

    for label, _ in pairs(expected) do
        assert(labels[label] == true,
            "Registers Inspect missing detail: " .. label)
    end

    assert(labels["execution status: observed"] ~= true,
        "known target must never imply observed execution")
    print("PASS ASM Inspect target: Registers renders certainty-separated details")

    print("PASS Tracker_HUD ASM Inspect memory-target smoke")
end

local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM Inspect memory-target smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
