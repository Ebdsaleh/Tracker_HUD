-- tests/cpp_structured_binding_standard_compatibility_smoke.lua
--
-- C++17 structured bindings have a dedicated Tree-sitter declarator.
-- Declare the structural construct as a declaration, not a fabricated
-- single-name variable or a lexical scope. Extracting individual bound
-- identifiers into Scope Members is intentionally outside this checkpoint.
-- Syntax recognition is independent of the selected semantic standard.

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

    local spec = cpp.construct_specs.structured_binding_declarator
    assert(
        type(spec) == "table"
            and type(spec.construct) == "table"
            and spec.construct.kind == "declaration"
            and type(spec.syntax) == "table"
            and spec.syntax.node_type == "structured_binding_declarator"
            and spec.scope == nil
            and spec.fields == nil
            and type(spec.availability) == "table"
            and spec.availability.language == "cpp"
            and spec.availability.dimension == "standard"
            and spec.availability.since == "cpp17",
        "C++17 structured binding construct/availability missing"
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
            label = "cpp14 source overrides cpp23 config",
            source = "// standard=14;",
            config = { targets = { standard = "cpp23" } },
            selected = "cpp14",
            available = false,
        },
        {
            label = "cpp17 default",
            selected = "cpp17",
            available = true,
        },
        {
            label = "cpp17 source overrides cpp14 config",
            source = "// standard=cpp17;",
            config = { targets = { standard = "cpp14" } },
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
            label = "cpp23 config alias",
            config = { targets = { standard = "c++23" } },
            selected = "cpp23",
            available = true,
        },
    }

    for _, case in ipairs(cases) do
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            case.source or "// structured binding target fixture",
            "auto [alpha, beta] = make_pair();",
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
            "structured binding fixture grammar ERROR: " .. case.label)
        local node = find_first(
            tree:root(), "structured_binding_declarator"
        )
        assert(node, "Tree-sitter missed structured binding: "
            .. case.label)
        assert(node:named_child_count() == 2,
            "structured binding did not retain both identifiers: "
                .. case.label)
        assert(
            node:named_child(0):type() == "identifier"
                and node:named_child(1):type() == "identifier"
                and vim.treesitter.get_node_text(
                    node:named_child(0), bufnr
                ) == "alpha"
                and vim.treesitter.get_node_text(
                    node:named_child(1), bufnr
                ) == "beta",
            "structured binding identifier identity lost: "
                .. case.label
        )

        local configured, config_err =
            registry.configure_adapter_for_buffer(
                "cpp", bufnr, case.config or {}
            )
        assert(configured,
            "C++ configuration failed: " .. case.label
                .. ": " .. tostring(config_err))
        assert(cpp.active_targets.standard == case.selected,
            "C++ standard precedence mismatch: " .. case.label)

        assert(
            (constructs.get_construct_spec(
                node, cpp, "structured_binding_declarator"
            ) == spec) == case.available,
            "structured binding lookup breached standard: "
                .. case.label
        )
        assert(engine.match_node(cpp, node) == case.available,
            "structured binding match breached standard: "
                .. case.label)
        local parsed, parse_err =
            registry.parse_node("cpp", node, bufnr)
        assert(
            parse_err == nil and (parsed ~= nil) == case.available,
            "structured binding parse breached standard: "
                .. case.label .. ": " .. tostring(parse_err)
        )
        if case.available then
            assert(
                parsed.construct
                    and parsed.construct.kind == "declaration",
                "structured binding lost declaration semantics: "
                    .. case.label
            )
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(c.construct_specs.structured_binding_declarator == nil,
        "C adapter inherited C++ structured binding semantics")
    assert(cpp.construct_specs.structured_binding_declarator == spec,
        "C++ structured binding spec changed identity")

    print("PASS Tree-sitter identifies both structured binding names")
    print("PASS cpp98/cpp03/cpp11/cpp14 exclude binding semantics")
    print("PASS cpp17/cpp20/cpp23 expose declaration semantics")
    print("PASS target precedence and C adapter isolation")
    print("PASS Tracker_HUD C++17 structured binding compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic =
        "FAIL C++17 structured binding compatibility smoke: "
            .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
