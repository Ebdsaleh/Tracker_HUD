-- tests/cpp_co_return_standard_compatibility_smoke.lua
--
-- co_return is a C++20 coroutine keyword. Tree-sitter may recognize its
-- syntax regardless of the selected C++ standard, but semantic matching,
-- parsing, and construct lookup must respect adapter-owned availability.
-- The small fixture is a parser fixture, not a compilable coroutine program.

local function find_first(node, wanted)
    if node:type() == wanted then
        return node
    end

    for child in node:iter_children() do
        local found = find_first(child, wanted)
        if found then
            return found
        end
    end

    return nil
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local registry = require("tracker_hud.adapters.registry")
    local engine = require("tracker_hud.context_engine")
    local constructs = require("tracker_hud.construct_utils")
    local c = require("tracker_hud.adapters.c.init")
    local cpp = require("tracker_hud.adapters.cpp.init")

    registry.clear()

    local registered, err = registry.register(c)
    assert(registered, "C registration failed: " .. tostring(err))
    registered, err = registry.register(cpp)
    assert(registered, "C++ registration failed: " .. tostring(err))

    local spec = cpp.construct_specs.co_return_statement
    assert(
        type(spec) == "table"
            and type(spec.construct) == "table"
            and spec.construct.kind == "return",
        "C++ co_return declaration is missing or is not a return"
    )

    local cases = {
        {
            label = "cpp98 source overrides cpp23 config",
            source = "// standard=cpp98;",
            config = { targets = { standard = "cpp23" } },
            selected = "cpp98",
            available = false,
        },
        {
            label = "cpp03 config",
            config = { targets = { standard = "cpp03" } },
            selected = "cpp03",
            available = false,
        },
        {
            label = "cpp17 default",
            selected = "cpp17",
            available = false,
        },
        {
            label = "cpp20 source alias overrides cpp17 config",
            source = "// standard=20;",
            config = { targets = { standard = "cpp17" } },
            selected = "cpp20",
            available = true,
        },
        {
            label = "cpp20 config",
            config = { targets = { standard = "cpp20" } },
            selected = "cpp20",
            available = true,
        },
        {
            label = "cpp23 config alias",
            config = { targets = { standard = "c++23" } },
            selected = "cpp23",
            available = true,
        },
    }

    for _, case in ipairs(cases) do
        local lines = {
            case.source or "// C++ co_return semantic-standard smoke",
            "int tracker_hud_co_return_probe() {",
            "    co_return 7;",
            "}",
        }

        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(
            bufnr,
            0,
            -1,
            false,
            lines
        )
        vim.bo[bufnr].filetype = "cpp"

        local parser_ok, parser = pcall(
            vim.treesitter.get_parser,
            bufnr,
            "cpp"
        )
        assert(
            parser_ok and parser,
            "Missing C++ Tree-sitter parser: " .. tostring(parser)
        )

        local tree = parser:parse()[1]
        assert(tree, "C++ Tree-sitter parser returned no tree")
        local co_return = find_first(
            tree:root(),
            "co_return_statement"
        )
        assert(
            co_return,
            "Tree-sitter did not recognize co_return in " .. case.label
        )

        local configured, configure_err =
            registry.configure_adapter_for_buffer(
                "cpp",
                bufnr,
                case.config or {}
            )
        assert(
            configured,
            "C++ configuration failed for " .. case.label
                .. ": " .. tostring(configure_err)
        )
        assert(
            cpp.active_targets.standard == case.selected,
            "incorrect selected standard for " .. case.label
                .. ": " .. tostring(cpp.active_targets.standard)
        )

        assert(
            engine.match_node(cpp, co_return) == case.available,
            "co_return match breached standard boundary in " .. case.label
        )

        local parsed, parse_err =
            registry.parse_node("cpp", co_return, bufnr)
        assert(
            parse_err == nil
                and (parsed ~= nil) == case.available,
            "co_return parse breached standard boundary in "
                .. case.label .. ": " .. tostring(parse_err)
        )

        local selected_spec = constructs.get_construct_spec(
            co_return,
            cpp,
            "co_return_statement"
        )
        assert(
            (selected_spec == spec) == case.available,
            "core co_return spec lookup breached standard boundary in "
                .. case.label
        )

        if case.available then
            assert(
                parsed.construct
                    and parsed.construct.kind == "return",
                "compatible co_return lost return semantics in "
                    .. case.label
            )
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(
        type(spec.availability) == "table"
            and spec.availability.language == "cpp"
            and spec.availability.dimension == "standard"
            and spec.availability.since == "cpp20",
        "C++ co_return must declare cpp20 availability in adapter data"
    )

    assert(
        c.construct_specs.co_return_statement == nil,
        "C adapter inherited C++ coroutine semantics"
    )
    assert(
        cpp.construct_specs.co_return_statement == spec,
        "C++ co_return declaration identity changed"
    )

    print("PASS Tree-sitter co_return recognition is independent of C++ standard")
    print("PASS cpp98/cpp03/cpp17 exclude co_return semantics")
    print("PASS cpp20/cpp23 expose co_return return semantics")
    print("PASS co_return source/config/default precedence and C isolation")
    print("PASS Tracker_HUD C++ co_return standard compatibility smoke")
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD C++ co_return standard compatibility smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
