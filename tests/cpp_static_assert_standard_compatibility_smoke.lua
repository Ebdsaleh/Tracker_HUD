-- tests/cpp_static_assert_standard_compatibility_smoke.lua
--
-- static_assert declarations entered C++ in C++11. The Tree-sitter grammar
-- recognizes the syntax independently of the adapter's selected target.
-- Verify that semantics are suppressed in C++98/C++03 and exposed from
-- C++11 onward. This tests parser/adapter behavior, not compilation.
-- The fixture uses the C++11 two-argument form; C++17's omitted-message
-- form is deliberately outside this checkpoint.

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
    local constructs = require("tracker_hud.construct_utils")
    local engine = require("tracker_hud.context_engine")
    local c = require("tracker_hud.adapters.c.init")
    local cpp = require("tracker_hud.adapters.cpp.init")

    registry.clear()
    local registered, err = registry.register(c)
    assert(registered, "C registration failed: " .. tostring(err))
    registered, err = registry.register(cpp)
    assert(registered, "C++ registration failed: " .. tostring(err))

    local spec = cpp.construct_specs.static_assert_declaration
    assert(
        type(spec) == "table"
            and type(spec.construct) == "table"
            and spec.construct.kind == "declaration"
            and type(spec.syntax) == "table"
            and spec.syntax.node_type == "static_assert_declaration"
            and spec.scope == nil
            and type(spec.availability) == "table"
            and spec.availability.language == "cpp"
            and spec.availability.dimension == "standard"
            and spec.availability.since == "cpp11",
        "C++11 static_assert syntax/availability missing"
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
            label = "cpp03 source overrides cpp23 config",
            source = "// standard=cpp03;",
            config = { targets = { standard = "cpp23" } },
            selected = "cpp03",
            available = false,
        },
        {
            label = "cpp11 source overrides cpp98 config",
            source = "// standard=11;",
            config = { targets = { standard = "cpp98" } },
            selected = "cpp11",
            available = true,
        },
        {
            label = "cpp11 config",
            config = { targets = { standard = "cpp11" } },
            selected = "cpp11",
            available = true,
        },
        {
            label = "cpp14 config",
            config = { targets = { standard = "cpp14" } },
            selected = "cpp14",
            available = true,
        },
        {
            label = "cpp17 default",
            selected = "cpp17",
            available = true,
        },
        {
            label = "cpp20 config",
            config = { targets = { standard = "cpp20" } },
            selected = "cpp20",
            available = true,
        },
        {
            label = "cpp23 alias config",
            config = { targets = { standard = "c++23" } },
            selected = "cpp23",
            available = true,
        },
    }

    for _, case in ipairs(cases) do
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            case.source or "// static_assert target fixture",
            'static_assert(sizeof(int) > 0, "integer required");',
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
            "static_assert fixture grammar ERROR: " .. case.label)
        local node = find_first(tree:root(), "static_assert_declaration")
        assert(node, "Tree-sitter missed static_assert: " .. case.label)
        assert(
            #node:field("condition") == 1
                and #node:field("message") == 1,
            "static_assert lost condition/message fields: " .. case.label
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
                node, cpp, "static_assert_declaration"
            ) == spec) == case.available,
            "static_assert spec crossed standard boundary: "
                .. case.label
        )
        assert(
            engine.match_node(cpp, node) == case.available,
            "static_assert match crossed standard boundary: "
                .. case.label
        )
        local parsed, parse_err =
            registry.parse_node("cpp", node, bufnr)
        assert(
            parse_err == nil and (parsed ~= nil) == case.available,
            "static_assert parse crossed standard boundary: "
                .. case.label .. ": " .. tostring(parse_err)
        )
        if case.available then
            assert(
                parsed.construct
                    and parsed.construct.kind == "declaration",
                "static_assert lost declaration kind: " .. case.label
            )
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(c.construct_specs.static_assert_declaration == nil,
        "C adapter inherited C++ static_assert semantics")
    assert(cpp.construct_specs.static_assert_declaration == spec,
        "C++ static_assert spec changed identity")

    print("PASS Tree-sitter recognizes C++11 static_assert fields")
    print("PASS cpp98/cpp03 hide static_assert semantics")
    print("PASS cpp11/cpp14/cpp17/cpp20/cpp23 enable declaration semantics")
    print("PASS standard precedence and C adapter isolation")
    print("PASS Tracker_HUD C++11 static_assert compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic =
        "FAIL C++11 static_assert compatibility smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
