-- tests/cpp_explicit_object_parameter_standard_compatibility_smoke.lua
--
-- C++23 explicit object parameters ("this Probe const& self") have a
-- dedicated Tree-sitter node wrapping an ordinary parameter_declaration.
-- Grammar recognition is independent of the selected language standard;
-- semantic lookup, matching, and parsing must enforce C++23 availability.
-- This is a parser/contract fixture, not a compiler compatibility test.

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
    local ok, err = registry.register(c)
    assert(ok, "C registration failed: " .. tostring(err))
    ok, err = registry.register(cpp)
    assert(ok, "C++ registration failed: " .. tostring(err))

    local spec =
        cpp.construct_specs.explicit_object_parameter_declaration
    assert(
        type(spec) == "table"
            and type(spec.construct) == "table"
            and spec.construct.kind == "parameter"
            and type(spec.syntax) == "table"
            and spec.syntax.node_type
                == "explicit_object_parameter_declaration"
            and spec.scope == nil
            and type(spec.availability) == "table"
            and spec.availability.language == "cpp"
            and spec.availability.dimension == "standard"
            and spec.availability.since == "cpp23",
        "C++23 explicit object parameter syntax/availability missing"
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
            label = "cpp11 config",
            config = { targets = { standard = "cpp11" } },
            selected = "cpp11",
            available = false,
        },
        {
            label = "cpp14 config",
            config = { targets = { standard = "cpp14" } },
            selected = "cpp14",
            available = false,
        },
        {
            label = "cpp17 default",
            selected = "cpp17",
            available = false,
        },
        {
            label = "cpp20 config",
            config = { targets = { standard = "cpp20" } },
            selected = "cpp20",
            available = false,
        },
        {
            label = "cpp20 source overrides cpp23 config",
            source = "// standard=20;",
            config = { targets = { standard = "cpp23" } },
            selected = "cpp20",
            available = false,
        },
        {
            label = "cpp23 config alias",
            config = { targets = { standard = "c++23" } },
            selected = "cpp23",
            available = true,
        },
        {
            label = "cpp23 source overrides cpp17 config",
            source = "// standard=23;",
            config = { targets = { standard = "cpp17" } },
            selected = "cpp23",
            available = true,
        },
    }

    for _, case in ipairs(cases) do
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            case.source or "// explicit object parameter target fixture",
            "struct Probe {",
            "    int get(this Probe const& self);",
            "};",
        })
        vim.bo[bufnr].filetype = "cpp"

        local parser_ok, parser =
            pcall(vim.treesitter.get_parser, bufnr, "cpp")
        assert(
            parser_ok and parser,
            "C++ Tree-sitter parser unavailable: " .. tostring(parser)
        )
        local tree = parser:parse()[1]
        assert(tree and not tree:root():has_error(),
            "explicit object parameter grammar ERROR: " .. case.label)
        local node = find_first(
            tree:root(), "explicit_object_parameter_declaration"
        )
        assert(node, "Tree-sitter missed explicit object parameter: "
            .. case.label)
        assert(
            find_first(node, "parameter_declaration") ~= nil,
            "explicit object parameter lost wrapped parameter: "
                .. case.label
        )
        assert(
            find_first(node, "this") ~= nil,
            "explicit object parameter lost this marker: "
                .. case.label
        )

        local configured, config_err =
            registry.configure_adapter_for_buffer(
                "cpp", bufnr, case.config or {}
            )
        assert(
            configured,
            "C++ target configuration failed: " .. case.label
                .. ": " .. tostring(config_err)
        )
        assert(cpp.active_targets.standard == case.selected,
            "C++ standard precedence mismatch: " .. case.label)

        assert(
            (constructs.get_construct_spec(
                node, cpp, "explicit_object_parameter_declaration"
            ) == spec) == case.available,
            "object parameter spec crossed standard boundary: "
                .. case.label
        )
        assert(
            engine.match_node(cpp, node) == case.available,
            "object parameter match crossed standard boundary: "
                .. case.label
        )
        local parsed, parse_err =
            registry.parse_node("cpp", node, bufnr)
        assert(
            parse_err == nil and (parsed ~= nil) == case.available,
            "object parameter parse crossed standard boundary: "
                .. case.label .. ": " .. tostring(parse_err)
        )
        if case.available then
            assert(
                parsed.construct and parsed.construct.kind == "parameter",
                "object parameter lost semantic kind: " .. case.label
            )
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(c.construct_specs.explicit_object_parameter_declaration == nil,
        "C adapter inherited C++23 explicit object parameter")
    assert(cpp.construct_specs.explicit_object_parameter_declaration == spec,
        "C++ explicit object parameter spec changed identity")

    print("PASS Tree-sitter recognizes explicit object parameter wrapper")
    print("PASS cpp98/cpp03/cpp11/cpp14/cpp17/cpp20 suppress semantics")
    print("PASS cpp23 enables construct lookup, matching and parsing")
    print("PASS standard precedence and C adapter isolation")
    print("PASS Tracker_HUD C++23 explicit object parameter smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic =
        "FAIL C++23 explicit object parameter compatibility smoke: "
            .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
