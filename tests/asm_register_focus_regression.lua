-- tests/asm_register_focus_regression.lua
-- Parser-backed cursor focus regression for the actual x86-64 ASM sample.
-- Run with ERIDU's configured Neovim, which has the ASM Tree-sitter parser:
-- nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
--
-- Distinguishes source-occurrence discovery from HUD highlight/refresh.
-- Does not edit the sample, source files, Neovim settings or user workspace.

local function run()
    dofile("tests/test_runtime.lua").use_working_tree()

    local sample = "samples/asm/x86_64/memory_operand_validation.asm"
    local lines = vim.fn.readfile(sample)
    assert(#lines > 0, "missing ASM sample: " .. sample)

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.bo[buffer].filetype = "asm"

    local ok, parser = pcall(vim.treesitter.get_parser, buffer, "asm")
    assert(ok and parser, "ASM Tree-sitter parser unavailable: " .. tostring(parser))
    local trees = parser:parse()
    assert(trees and trees[1], "ASM parser produced no tree")
    local root = trees[1]:root()

    local adapter = require("tracker_hud.adapters.asm.init")
    local registry = require("tracker_hud.adapters.registry")
    local registered, err = registry.register(adapter)
    assert(registered, "cannot register ASM adapter: " .. tostring(err))
    local configured, config_err =
        registry.configure_adapter_for_buffer("asm", buffer, {})
    assert(configured, "cannot configure ASM adapter: " .. tostring(config_err))

    local engine = require("tracker_hud.context_engine")
    local function contains(list, expected)
        for _, x in ipairs(list or {}) do
            if x == expected then return true end
        end
        return false
    end
    -- Stable order: when a case fails, diagnostics always identify the
    -- same first regression rather than depending on Lua table iteration.
    local targets = {
        { source = "mov rbp, rsp", registers = { "rbp", "rsp" } },
        { source = "mov rax, [rbp + rax*4 - 8]",
          registers = { "rax", "rbp" } },
        { source = "mov [rsp + 8], rax", registers = { "rsp", "rax" } },
        { source = "lea rsi, [rel msg]", registers = { "rsi" } },
    }

    local count = 0
    for _, case in ipairs(targets) do
        local search, expected = case.source, case.registers
        local line_number
        for i, line in ipairs(lines) do
            if line:find(search, 1, true) then
                line_number = i
                break
            end
        end
        assert(line_number, "missing regression line: " .. search)
        local occurrences = engine.discover_register_source_occurrences(
            buffer, root, adapter, line_number
        )
        local observed = {}
        for _, occ in ipairs(occurrences) do
            local state_targets = (occ.targets or {}).state or {}
            observed[#observed + 1] =
                string.format("%s:%s@%s-%s -> %s",
                    tostring(occ.kind), tostring(occ.text),
                    tostring(occ.start_column), tostring(occ.end_column),
                    table.concat(state_targets, ","))
        end
        print("ASM line " .. line_number .. " [" .. search .. "]: "
            .. table.concat(observed, " | "))
        -- The memory-load regression must preserve exact token focus,
        -- not merely attach every mentioned register to the mnemonic.
        if search == "mov rax, [rbp + rax*4 - 8]" then
            local function has_source_token(kind, name)
                local target = "register:" .. name
                for _, occurrence in ipairs(occurrences) do
                    if occurrence.kind == kind
                        and occurrence.text == name
                        and contains((occurrence.targets or {}).state, target)
                    then
                        return true
                    end
                end
                return false
            end
            assert(has_source_token("operand", "rax"),
                "mov memory-load destination rax lacks its own operand occurrence")
            assert(has_source_token("memory_component", "rbp"),
                "mov memory-load base rbp lacks its own memory-component occurrence")
            assert(has_source_token("memory_component", "rax"),
                "mov memory-load index rax lacks its own memory-component occurrence")
        end

        for _, register_name in ipairs(expected) do
            local target = "register:" .. register_name
            local found = false
            for _, occ in ipairs(occurrences) do
                if contains((occ.targets or {}).state, target) then
                    found = true
                    break
                end
            end
            assert(found, "missing source occurrence " .. target
                .. " on line " .. line_number)
            count = count + 1
        end
    end
    print("PASS ASM register source occurrence discovery (" ..
        count .. " target checks); if HUD still misses a focus, inspect "
        .. "selection/refresh rather than register definitions")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL ASM register focus regression: "
        .. tostring(err) .. "\n")
    error(err)
end
