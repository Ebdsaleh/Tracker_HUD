-- tests/cpp_requires_expression_standard_compatibility_smoke.lua
--
-- A C++20 requires-expression is a syntax-bounded requirement block.
-- Tree-sitter grammar recognition alone does not authorize its C++ semantics.
-- Check adapter-owned C++20 availability on the construct, scope lifetime
-- metadata, matching/parsing, source/config precedence, and C isolation.
-- This test does not evaluate requirements or assert compiler conformance.

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
    assert(registered, "C adapter registration failed: " .. tostring(err))
    registered, err = registry.register(cpp)
    assert(registered, "C++ adapter registration failed: " .. tostring(err))

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
            label = "cpp20 source alias overrides cpp17 config",
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
            label = "cpp23 alias",
            config = { targets = { standard = "c++23" } },
            selected = "cpp23",
            available = true,
        },
    }

    local reference_spec = nil

    for _, case in ipairs(cases) do
        local lines = {
            case.directive or "// requires-expression semantic compatibility",
            "template <typename T>",
            "concept Addable = requires (T candidate) {",
            "    candidate + candidate;",
            "};",
            "int ordinary(int amount) { return amount; }",
        }

        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        vim.bo[bufnr].filetype = "cpp"

        local parser_ok, parser = pcall(
            vim.treesitter.get_parser, bufnr, "cpp"
        )
        assert(
            parser_ok and parser,
            "Missing C++ Tree-sitter parser: " .. tostring(parser)
        )

        local tree = parser:parse()[1]
        assert(tree, "C++ parser returned no tree: " .. case.label)
        local root = tree:root()
        assert(
            not root:has_error(),
            "C++ requires-expression fixture has parser errors: "
                .. case.label
        )
        local requires_node = find_first(root, "requires_expression")
        assert(
            requires_node,
            "Tree-sitter missed requires_expression: " .. case.label
        )
        assert(
            find_first(root, "concept_definition"),
            "Tree-sitter missed enclosing C++20 concept: " .. case.label
        )

        local configured, configure_err =
            registry.configure_adapter_for_buffer(
                "cpp", bufnr, case.config or {}
            )
        assert(
            configured,
            "C++ target configuration failed: " .. case.label
                .. ": " .. tostring(configure_err)
        )
        assert(
            cpp.active_targets.standard == case.selected,
            "incorrect selected standard for " .. case.label
        )

        local spec = cpp.construct_specs.requires_expression
        assert(
            type(spec) == "table"
                and type(spec.construct) == "table"
                and spec.construct.kind == "block",
            "C++ requires_expression must declare its requirement block"
        )
        reference_spec = reference_spec or spec
        assert(
            spec == reference_spec,
            "requires_expression construct identity changed: "
                .. case.label
        )
        assert(
            type(spec.scope) == "table"
                and spec.scope.kind == "lexical"
                and spec.scope.affects_visibility == true
                and spec.scope.owns_members == true,
            "requires-expression parameter scope metadata missing"
        )
        assert(
            type(spec.availability) == "table"
                and spec.availability.language == "cpp"
                and spec.availability.dimension == "standard"
                and spec.availability.since == "cpp20",
            "C++20 requires-expression availability metadata missing"
        )

        assert(
            engine.match_node(cpp, requires_node) == case.available,
            "requires_expression match breached C++ standard: "
                .. case.label
        )

        local parsed, parse_err = registry.parse_node(
            "cpp", requires_node, bufnr
        )
        assert(
            parse_err == nil
                and (parsed ~= nil) == case.available,
            "requires_expression parse breached C++ standard: "
                .. case.label .. ": " .. tostring(parse_err)
        )

        local selected_spec = constructs.get_construct_spec(
            requires_node, cpp, "requires_expression"
        )
        assert(
            (selected_spec == spec) == case.available,
            "requires_expression lookup breached C++ standard: "
                .. case.label
        )
        if case.available then
            assert(
                parsed.construct and parsed.construct.kind == "block",
                "compatible requires_expression lost its block identity: "
                    .. case.label
            )
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(
        c.construct_specs.requires_expression == nil,
        "C adapter inherited C++ requires-expression semantics"
    )
    assert(
        cpp.construct_specs.requires_expression == reference_spec,
        "C++ requires-expression construct identity was replaced"
    )

    print("PASS requires_expression parsed by Tree-sitter independent of C++ standard")
    print("PASS cpp98/cpp03/cpp11/cpp17 suppress requires-expression semantics")
    print("PASS cpp20/cpp23 expose scoped C++ requirement block")
    print("PASS C++ standard precedence and C adapter isolation")
    print("PASS Tracker_HUD C++ requires-expression standard compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD C++ requires-expression standard compatibility smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
