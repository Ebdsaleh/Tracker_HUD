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
