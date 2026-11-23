-- tests/cpp_requires_clause_standard_compatibility_smoke.lua
--
-- A C++20 requires-clause can constrain a template or trail a function.
-- Tree-sitter syntax recognition is not permission to report this
-- construct in older C++ standards. This is semantic availability only:
-- no constraint evaluation, overload resolution, or compiler conformance.

local function collect_nodes(node, wanted, result)
    if node:type() == wanted then
        table.insert(result, node)
    end
    for child in node:iter_children() do
        collect_nodes(child, wanted, result)
    end
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

    local spec = cpp.construct_specs.requires_clause
    assert(
        type(spec) == "table"
            and type(spec.construct) == "table"
            and spec.construct.kind == "condition"
            and type(spec.syntax) == "table"
            and spec.syntax.node_type == "requires_clause"
            and type(spec.syntax.fields) == "table"
            and spec.syntax.fields.constraint == "constraint"
            and type(spec.availability) == "table"
            and spec.availability.language == "cpp"
            and spec.availability.dimension == "standard"
            and spec.availability.since == "cpp20",
        "C++20 requires_clause construct/availability declaration missing"
    )

    local cases = {
        {
            label = "cpp17 default",
            selected = "cpp17",
            available = false,
        },
        {
            label = "cpp98 directive overrides cpp23 config",
            directive = "// standard=cpp98;",
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
            label = "cpp20 directive overrides cpp17 config",
            directive = "// standard=20;",
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
        local lines = {
            case.directive or "// C++ requires-clause standard compatibility",
            "template <typename T>",
            "requires true",
            "T constrained(T value) { return value; }",
            "template <typename T>",
            "T trailing(T value) requires true { return value; }",
        }
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        vim.bo[bufnr].filetype = "cpp"

        local ok_parser, parser = pcall(
            vim.treesitter.get_parser, bufnr, "cpp"
        )
        assert(
            ok_parser and parser,
            "C++ Tree-sitter parser missing: " .. tostring(parser)
        )
        local tree = parser:parse()[1]
        assert(
            tree and not tree:root():has_error(),
            "C++ requires-clause fixture parser ERROR: " .. case.label
        )
        local root = tree:root()
        local nodes = {}
        collect_nodes(root, "requires_clause", nodes)
        assert(
            #nodes == 2,
            "expected template and trailing requires_clause syntax, got "
                .. tostring(#nodes) .. ": " .. case.label
        )
        assert(
            nodes[1]:start() ~= nodes[2]:start(),
            "requires-clause parser node locations collapsed: " .. case.label
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
        assert(
            cpp.active_targets.standard == case.selected,
            "wrong resolved standard: " .. case.label
        )

        for _, node in ipairs(nodes) do
            assert(
                (constructs.get_construct_spec(
                    node, cpp, "requires_clause"
                ) == spec) == case.available,
                "requires_clause lookup breached target: " .. case.label
            )
            assert(
                engine.match_node(cpp, node) == case.available,
                "requires_clause match breached target: " .. case.label
            )
            local parsed, parse_err = registry.parse_node(
                "cpp", node, bufnr
            )
            assert(
                parse_err == nil and (parsed ~= nil) == case.available,
                "requires_clause parse breached target: " .. case.label
                    .. ": " .. tostring(parse_err)
            )
            if case.available then
                assert(
                    parsed.construct
                        and parsed.construct.kind == "condition",
                    "requires_clause lost condition construct identity: "
                        .. case.label
                )
            end
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(
        c.construct_specs.requires_clause == nil,
        "C adapter inherited C++20 requires-clause semantics"
    )
    assert(
        cpp.construct_specs.requires_clause == spec,
        "requires_clause construct declaration identity changed"
    )

    print("PASS Tree-sitter parses template and trailing requires clauses")
    print("PASS cpp98/cpp03/cpp11/cpp14/cpp17 suppress requires clauses")
    print("PASS cpp20/cpp23 enable requires clauses in match and parse")
    print("PASS source/config/default precedence and C adapter isolation")
    print("PASS C++20 requires-clause standard compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic =
        "FAIL C++ requires-clause standard compatibility smoke: "
            .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
