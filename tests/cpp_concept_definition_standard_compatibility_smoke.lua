-- tests/cpp_concept_definition_standard_compatibility_smoke.lua
--
-- C++20 concepts are a semantic feature, not a Tree-sitter parser switch.
-- A parsed concept_definition must be a C++ construct only from C++20.
-- Test source/config/default precedence, C isolation, construct identity,
-- and the common parse/match/spec contract without compiler conformance.
-- No concept binding or requires-expression semantics are claimed here.

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

    local reference_spec = nil

    local cases = {
        {
            label = "cpp98 source overrides cpp23 config",
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
            label = "cpp17 default",
            selected = "cpp17",
            available = false,
        },
        {
            label = "cpp20 source overrides cpp17 config",
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
            label = "cpp23 config alias",
            config = { targets = { standard = "c++23" } },
            selected = "cpp23",
            available = true,
        },
    }

    for _, case in ipairs(cases) do
        local lines = {
            case.directive or "// C++20 concept definition compatibility",
            "template <typename T>",
            "concept SampleConcept = true;",
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
        assert(tree, "C++ parser returned no syntax tree")
        local root = tree:root()
        assert(
            not root:has_error(),
            "C++ concept fixture contains Tree-sitter ERROR nodes: "
                .. case.label
        )
        local concept = find_first(root, "concept_definition")
        assert(
            concept,
            "Tree-sitter did not recognize concept_definition: "
                .. case.label
        )

        local configured, configure_err =
            registry.configure_adapter_for_buffer(
                "cpp", bufnr, case.config or {}
            )
        assert(
            configured,
            "C++ configuration failed in " .. case.label
                .. ": " .. tostring(configure_err)
        )
        assert(
            cpp.active_targets.standard == case.selected,
            "incorrect selected standard for " .. case.label
                .. ": " .. tostring(cpp.active_targets.standard)
        )

        local spec = cpp.construct_specs.concept_definition
        assert(
            type(spec) == "table"
                and type(spec.construct) == "table"
                and spec.construct.kind == "declaration",
            "C++ concept_definition must declare a concept declaration"
        )
        reference_spec = reference_spec or spec
        assert(
            spec == reference_spec,
            "C++ concept declaration identity changed: " .. case.label
        )
        assert(
            type(spec.availability) == "table"
                and spec.availability.language == "cpp"
                and spec.availability.dimension == "standard"
                and spec.availability.since == "cpp20",
            "C++ concept_definition must declare cpp20 availability"
        )

        assert(
            engine.match_node(cpp, concept) == case.available,
            "concept match breached standard boundary in " .. case.label
        )

        local parsed, parse_err = registry.parse_node(
            "cpp", concept, bufnr
        )
        assert(
            parse_err == nil
                and (parsed ~= nil) == case.available,
            "concept parsing breached standard boundary in "
                .. case.label .. ": " .. tostring(parse_err)
        )

        local selected_spec = constructs.get_construct_spec(
            concept, cpp, "concept_definition"
        )
        assert(
            (selected_spec == spec) == case.available,
            "core concept lookup breached standard boundary in "
                .. case.label
        )
        if case.available then
            assert(
                parsed.construct and parsed.construct.kind == "declaration",
                "available concept lost declaration semantics: " .. case.label
            )
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(
        c.construct_specs.concept_definition == nil,
        "C adapter unexpectedly inherited C++ concept semantics"
    )
    assert(
        cpp.construct_specs.concept_definition == reference_spec,
        "C++ concept construct identity became unstable"
    )

    print("PASS concept_definition parses regardless of selected C++ standard")
    print("PASS cpp98/cpp03/cpp11/cpp17 exclude C++20 concept semantics")
    print("PASS cpp20/cpp23 expose concept declaration semantics")
    print("PASS C++ source/config/default selection and C isolation")
    print("PASS Tracker_HUD C++ concept-definition standard compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD C++ concept-definition standard compatibility smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
