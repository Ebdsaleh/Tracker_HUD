-- tests/cpp_private_module_fragment_standard_compatibility_smoke.lua
--
-- C++20's private module fragment (module : private;) is a distinct grammar node
-- from a named module declaration. Parsing it is not permission to
-- expose its semantics in a pre-C++20 target. This is a parser-backed
-- syntax/contract check, not compilation or linkage of a module unit.

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

    local spec = cpp.construct_specs.private_module_fragment_declaration
    assert(
        type(spec) == "table"
            and type(spec.construct) == "table"
            and spec.construct.kind == "module"
            and type(spec.syntax) == "table"
            and spec.syntax.node_type
                == "private_module_fragment_declaration"
            and spec.scope == nil
            and type(spec.availability) == "table"
            and spec.availability.language == "cpp"
            and spec.availability.dimension == "standard"
            and spec.availability.since == "cpp20",
        "C++20 private module fragment syntax/availability missing"
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
            label = "cpp20 source overrides cpp17 config",
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
            label = "cpp23 alias config",
            config = { targets = { standard = "c++23" } },
            selected = "cpp23",
            available = true,
        },
    }

    for _, case in ipairs(cases) do
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            case.source or "// private module fragment target fixture",
            "export module atlas;",
            "module : private;",
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
            "private module fixture grammar ERROR: " .. case.label)
        local node = find_first(
            tree:root(), "private_module_fragment_declaration"
        )
        assert(node, "Tree-sitter missed private module fragment: "
            .. case.label)
        assert(
            find_first(tree:root(), "module_declaration") ~= nil,
            "fixture lost its separate named module: " .. case.label
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
                node, cpp, "private_module_fragment_declaration"
            ) == spec) == case.available,
            "private module spec crossed standard boundary: "
                .. case.label
        )
        assert(
            engine.match_node(cpp, node) == case.available,
            "private module match crossed standard boundary: "
                .. case.label
        )
        local parsed, parse_err =
            registry.parse_node("cpp", node, bufnr)
        assert(
            parse_err == nil and (parsed ~= nil) == case.available,
            "private module parse crossed standard boundary: "
                .. case.label .. ": " .. tostring(parse_err)
        )
        if case.available then
            assert(parsed.construct
                and parsed.construct.kind == "module",
                "private module lost construct identity: " .. case.label)
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(c.construct_specs.private_module_fragment_declaration == nil,
        "C adapter inherited C++ private module fragment semantics")
    assert(cpp.construct_specs.private_module_fragment_declaration == spec,
        "C++ private module fragment spec changed identity")

    print("PASS Tree-sitter separates private and named module declarations")
    print("PASS cpp98/cpp03/cpp11/cpp14/cpp17 hide private fragment semantics")
    print("PASS cpp20/cpp23 enable private fragments in lookup/match/parse")
    print("PASS target precedence and C adapter isolation")
    print("PASS Tracker_HUD private module fragment compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic =
        "FAIL C++20 private module fragment compatibility smoke: "
            .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
