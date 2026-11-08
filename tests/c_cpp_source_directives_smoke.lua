-- C/C++ source target directives (no parser required).
-- Run from the repository root:
--   nvim --headless -u NONE -c "luafile tests/c_cpp_source_directives_smoke.lua"
--
-- Mirrors ASM's strict comment directive parser. Source targets are
-- metadata, not actual compiler/ABI detection or parser selection.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local registry = require("tracker_hud.adapters.registry")
    local c = require("tracker_hud.adapters.c.init")
    local cpp = require("tracker_hud.adapters.cpp.init")
    registry.clear()
    assert(registry.register(c), "C adapter registration failed")
    assert(registry.register(cpp), "C++ adapter registration failed")

    local function buffer(ft, lines)
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        vim.bo[bufnr].filetype = ft
        return bufnr
    end

    local function configured(ft, lines, config)
        local bufnr = buffer(ft, lines)
        local ok, err = registry.configure_adapter_for_buffer(
            ft, bufnr, config or {})
        assert(ok, ft .. " configure failed: " .. tostring(err))
        local targets = vim.deepcopy(registry.get_adapter(ft).active_targets)
        vim.api.nvim_buf_delete(bufnr, { force = true })
        return targets
    end

    for _, ft in ipairs({ "c", "cpp" }) do
        local defaults = configured(ft, {
            "// An ordinary source comment.",
            "int count = 0;",
        })
        assert(defaults.architecture == "unknown"
            and defaults.platform == "unknown"
            and defaults.abi == "unknown"
            and defaults.syntax == ft and defaults.mode == "compiled",
            ft .. " should preserve unknown target defaults")
        assert(#defaults.diagnostics == 0, "unexpected default diagnostics")

        local targets = configured(ft, {
            "// arch=x64;",
            "// platform=windows;",
            "// abi=win64;",
            "// syntax=" .. ft .. ";",
            "// mode=compiled;",
            "int x = 0;",
        }, { targets = {
            architecture = "aarch64",
            platform = "linux",
            abi = "sysv",
            mode = "source",
        } })
        assert(targets.architecture == "x86-64",
            ft .. " must normalize x64 alias from source")
        assert(targets.platform == "windows" and targets.abi == "win64",
            ft .. " source directives must override config")
        assert(targets.syntax == ft and targets.mode == "compiled",
            ft .. " source syntax/mode not resolved")
        assert(#targets.diagnostics == 0, ft .. " valid directives warned")

        local config_only = configured(ft,
            { "int x = 0;" }, { targets = {
                architecture = "aarch64",
                platform = "linux",
                abi = "aapcs64",
                mode = "custom",
            } })
        assert(config_only.architecture == "aarch64"
            and config_only.platform == "linux"
            and config_only.abi == "aapcs64"
            and config_only.mode == "custom"
            and config_only.syntax == ft,
            ft .. " config fallback/grammar identity incorrect")

        local mismatch = ft == "c" and "cpp" or "c"
        local wrong = configured(ft, {
            "// syntax=" .. mismatch .. ";",
            "int x = 0;",
        })
        assert(wrong.syntax == ft,
            ft .. " syntax directive must not replace Tree-sitter grammar")
        assert(#wrong.diagnostics == 1
            and wrong.diagnostics[1].key == "syntax"
            and wrong.diagnostics[1].line == 1,
            ft .. " incompatible syntax directive needs line warning")

        local malformed = configured(ft, {
            "// arch =x86-64;",
            "// abi=win64",
            "const char *text = \"// platform=windows;\";",
        })
        assert(malformed.architecture == "unknown"
            and malformed.platform == "unknown"
            and malformed.abi == "unknown",
            ft .. " malformed/string-literal comments must not set targets")
        assert(#malformed.diagnostics >= 2,
            ft .. " missing malformed directive diagnostics")

        local beyond = {}
        for index = 1, 20 do
            beyond[index] = "// filler " .. index
        end
        beyond[21] = "// arch=x86-64;"
        local limited = configured(ft, beyond)
        assert(limited.architecture == "unknown",
            ft .. " directives must be limited to first 20 lines")

        print("PASS " .. ft
            .. " source directives: precedence, 20-line limit, strict syntax,"
            .. " diagnostics, grammar identity")
    end

    -- Deep-copy inheritance MUST NOT leave C++ using C's configuration
    -- closure or mutate the C adapter's active targets.
    local c_targets = configured("c", { "// arch=x86-64;", "// syntax=c;" })
    assert(c_targets.architecture == "x86-64")
    local cpp_targets = configured("cpp",
        { "// arch=aarch64;", "// syntax=cpp;" })
    assert(cpp_targets.architecture == "aarch64"
        and cpp_targets.syntax == "cpp",
        "C++ configuration did not use its own adapter")
    assert(c.active_targets.architecture == "x86-64"
        and c.active_targets.syntax == "c",
        "configuring C++ unexpectedly mutated C's active targets")
    print("PASS C/C++ source directive adapter isolation")
    print("PASS C/C++ source target directives")
end

local ok, err = pcall(run)
if ok then
    vim.cmd("qa!")
else
    vim.api.nvim_err_writeln("FAIL C/C++ source directive smoke: "
        .. tostring(err))
    vim.cmd("cquit 1")
end
