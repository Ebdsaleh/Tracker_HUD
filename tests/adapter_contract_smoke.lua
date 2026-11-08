-- tests/adapter_contract_smoke.lua
-- Run from the repository root:
--   nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
-- This validates adapter shapes/registration. Tree-sitter parser availability and
-- the interactive HUD must still be checked using the sample source files.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local contract = require("tracker_hud.adapters.contract")
    local registry = require("tracker_hud.adapters.registry")
    local adapters = {
        { filetype = "lua", module = "tracker_hud.adapters.lua.init" },
        { filetype = "python", module = "tracker_hud.adapters.python.init" },
        { filetype = "c", module = "tracker_hud.adapters.c.init" },
        { filetype = "cpp", module = "tracker_hud.adapters.cpp.init" },
    }

    registry.clear()

    for _, item in ipairs(adapters) do
        local adapter = require(item.module)
        local valid, validation_error = contract.validate_adapter(adapter)
        assert(valid, item.filetype .. " contract: " .. tostring(validation_error))

        local registered, registration_error = registry.register(adapter)
        assert(registered, item.filetype .. " registration: " .. tostring(registration_error))
        assert(registry.get_adapter(item.filetype) == adapter,
            item.filetype .. " registry lookup failed")

        print("PASS Adapter Contract v1 + registration: " .. item.filetype)
    end

    local c = registry.get_adapter("c")
    local cpp = registry.get_adapter("cpp")
    assert(c ~= cpp and c.name == "c" and cpp.name == "cpp",
        "C++ adapter must not mutate the C adapter")
    assert(c.construct_specs["class_specifier"] == nil,
        "C adapter must not inherit C++-only grammar rules")
    assert(cpp.construct_specs["class_specifier"] ~= nil,
        "C++ class grammar rule missing")
    assert(cpp.construct_specs["namespace_definition"] ~= nil,
        "C++ namespace grammar rule missing")
    assert(cpp.construct_specs["for_range_loop"] ~= nil,
        "C++ range-for grammar rule missing")
    -- Contract v1 allows arbitrary group keys, but the current member
    -- collector renders only these groups. Fail early on silently dead groups.
    local supported = {
        declarations = true, assignments = true, parameters = true,
        functions = true, loops = true, returns = true,
        fields = true, symbols = true,
    }
    for _, adapter in ipairs({ c, cpp }) do
        for group_name in pairs(adapter.scope_members or {}) do
            assert(supported[group_name],
                adapter.name .. " has unrendered member group: " .. group_name)
        end
        local parameter_spec = nil
        for _, spec in ipairs(adapter.scope_members.symbols or {}) do
            if spec.syntax.node_type == "parameter_declaration" then
                parameter_spec = spec
                break
            end
        end
        assert(parameter_spec
            and parameter_spec.syntax.fields.name == "declarator"
            and parameter_spec.member.kind == "parameter",
            adapter.name .. " must expose declared parameter names")
    end


    for _, node_type in ipairs({
        "optional_parameter_declaration",
        "variadic_parameter_declaration",
    }) do
        local found = false
        for _, spec in ipairs(cpp.scope_members.symbols or {}) do
            if spec.syntax.node_type == node_type
                and spec.syntax.fields.name == "declarator"
                and spec.member.kind == "parameter"
            then
                found = true
                break
            end
        end
        assert(found, "C++ missing parameter source binding: " .. node_type)
    end

    -- Explicit grammar-name fallbacks must be configured in each adapter.
    -- They are used only if the primary named-field lookup cannot resolve
    -- the declaration; never guess from arbitrary source text.
    local function expect_name_fallback(adapter, group, node_type, fallback)
        local found = false
        for _, spec in ipairs(adapter.scope_members[group] or {}) do
            if spec.syntax.node_type == node_type then
                local child = spec.syntax.children and spec.syntax.children.name
                assert(child and child.node_type == fallback,
                    adapter.name .. " " .. node_type
                        .. " missing AST name fallback " .. fallback)
                found = true
                break
            end
        end
        assert(found, adapter.name .. " missing " .. group .. " " .. node_type)
    end

    for _, adapter in ipairs({ c, cpp }) do
        expect_name_fallback(adapter, "functions",
            "function_definition", "identifier")
        expect_name_fallback(adapter, "symbols",
            "parameter_declaration", "identifier")
        expect_name_fallback(adapter, "symbols",
            "struct_specifier", "type_identifier")
        expect_name_fallback(adapter, "fields",
            "field_declaration", "field_identifier")
    end
    expect_name_fallback(cpp, "symbols",
        "class_specifier", "type_identifier")
    expect_name_fallback(cpp, "symbols",
        "namespace_definition", "namespace_identifier")
    expect_name_fallback(cpp, "symbols",
        "optional_parameter_declaration", "identifier")
    print("PASS C/C++ grammar-specific member fallback contracts")

    -- Permanent panels are presentation sections, not claims about a
    -- program's compiled architecture, live stack, or allocated objects.
    -- Both adapters must keep the ASM section order, including empty panels.
    local section_layout = require("tracker_hud.section_layout")
    local inspect_mode = require("tracker_hud.inspect_mode")
    local expected_order = {
        "scope", "scope_members", "registers", "events",
        "stack", "heap", "warnings",
    }
    -- The ASM master adapter applies base_presentation during variant
    -- configuration. Mirror that normal configured state in this headless
    -- section test without requiring a user buffer or mutating the master.
    local asm = vim.deepcopy(require("tracker_hud.adapters.asm.adapter"))
    asm.presentation = vim.deepcopy(asm.base_presentation)
    for _, adapter in ipairs({ c, cpp, asm }) do
        local layout = section_layout.resolve(adapter)
        local order = layout.order
        assert(#order == #expected_order,
            adapter.name .. " section count mismatch")
        for index, id in ipairs(expected_order) do
            assert(order[index] == id,
                adapter.name .. " section order differs at " .. index)
            assert(layout.by_id[id] and layout.by_id[id].id == id,
                adapter.name .. " missing permanent section " .. id)
        end

        assert(inspect_mode.set_modes(layout.order),
            adapter.name .. " Inspect Mode section cycle failed")
        local seen = {}
        for _ = 1, #expected_order do
            local mode = inspect_mode.get_mode()
            assert(not seen[mode], adapter.name .. " repeat in Inspect cycle")
            seen[mode] = true
            inspect_mode.cycle_mode()
        end
        for _, id in ipairs(expected_order) do
            assert(seen[id], adapter.name .. " Inspect Mode cannot reach " .. id)
        end
        print("PASS " .. adapter.name .. " persistent section order / Inspect cycle")
    end
    assert(not c.capabilities.registers and not c.capabilities.heap,
        "persistent C panels must not claim registers or heap inference")
    assert(not cpp.capabilities.registers and not cpp.capabilities.heap,
        "persistent C++ panels must not claim registers or heap inference")

    print("PASS C/C++ adapter isolation")
end

local ok, err = pcall(run)
if not ok then
    vim.api.nvim_err_writeln("FAIL Tracker_HUD adapter smoke: " .. tostring(err))
    vim.cmd("cquit 1")
else
    print("PASS Tracker_HUD adapter contract smoke")
    vim.cmd("qa!")
end
