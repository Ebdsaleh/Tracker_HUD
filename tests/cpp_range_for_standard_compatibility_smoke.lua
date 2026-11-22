-- tests/cpp_range_for_standard_compatibility_smoke.lua
--
-- C++ range-based for is a C++11 construct. Tree-sitter recognizing its
-- syntax does not authorize semantic matching under cpp98/cpp03.
-- Test the shared compatibility boundary across parse/match/spec/scope,
-- preserving the real C++ fixture, adapter identity, and C isolation.
--
-- This checkpoint covers ordinary range-for only. C++20 range-for with
-- an init-statement requires a separate, node-sensitive availability rule.

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

    local registry =
        require("tracker_hud.adapters.registry")
    local context_engine =
        require("tracker_hud.context_engine")
    local construct_utils =
        require("tracker_hud.construct_utils")
    local c =
        require("tracker_hud.adapters.c.init")
    local cpp =
        require("tracker_hud.adapters.cpp.init")

    registry.clear()

    local registered, err = registry.register(c)
    assert(registered, "C adapter registration failed: " .. tostring(err))

    registered, err = registry.register(cpp)
    assert(registered, "C++ adapter registration failed: " .. tostring(err))

    local range_spec = cpp.construct_specs.for_range_loop
    assert(
        type(range_spec) == "table"
            and range_spec.construct
            and range_spec.construct.kind == "loop",
        "real C++ range-for construct spec is missing"
    )

    local fixture = vim.fn.readfile(
        "samples/cpp/cpp_adapter_validation.cpp"
    )
    assert(#fixture > 0, "C++ validation fixture missing")

    local cases = {
        {
            label = "cpp98 source overrides cpp20 config",
            directive = "// standard=cpp98;",
            config = { targets = { standard = "cpp20" } },
            standard = "cpp98",
            available = false,
        },
        {
            label = "cpp03 config",
            config = { targets = { standard = "cpp03" } },
            standard = "cpp03",
            available = false,
        },
        {
            label = "cpp11 source alias overrides cpp98 config",
            directive = "// standard=11;",
            config = { targets = { standard = "cpp98" } },
            standard = "cpp11",
            available = true,
        },
        {
            label = "cpp17 default",
            standard = "cpp17",
            available = true,
        },
        {
            label = "cpp23 config alias",
            config = { targets = { standard = "c++23" } },
            standard = "cpp23",
            available = true,
        },
    }

    for _, case in ipairs(cases) do
        local lines = vim.deepcopy(fixture)
        table.insert(
            lines,
            1,
            case.directive
                or "// range-for semantic-standard smoke"
        )

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
            "Missing C++ Tree-sitter parser: "
                .. tostring(parser)
        )

        local tree = parser:parse()[1]
        assert(tree and not tree:root():has_error(),
            "C++ validation fixture has parser errors"
        )

        local loop = find_first(tree:root(), "for_range_loop")
        assert(
            loop ~= nil,
            "Tree-sitter did not recognize range-for in "
                .. case.label
        )

        local configured, configure_err =
            registry.configure_adapter_for_buffer(
                "cpp",
                bufnr,
                case.config or {}
            )

        assert(
            configured,
            "C++ adapter failed to configure "
                .. case.label
                .. ": "
                .. tostring(configure_err)
        )
        assert(
            cpp.active_targets.standard == case.standard,
            "unexpected C++ standard for "
                .. case.label
                .. ": "
                .. tostring(cpp.active_targets.standard)
        )

        local expected = case.available
        assert(
            context_engine.match_node(cpp, loop) == expected,
            "range-for match leaked incompatible semantics: "
                .. case.label
        )

        local parsed, parse_err =
            registry.parse_node("cpp", loop, bufnr)

        assert(
            parse_err == nil
                and (parsed ~= nil) == expected,
            "range-for parse compatibility incorrect for "
                .. case.label
                .. ": "
                .. tostring(parse_err)
        )

        local selected_spec =
            construct_utils.get_construct_spec(
                loop,
                cpp,
                "for_range_loop"
            )

        assert(
            (selected_spec == range_spec) == expected,
            "core range-for spec lookup violated standard: "
                .. case.label
        )

        -- Range-for carries structural metadata but does not own members.
        -- Its semantic exposure is tested through the matched construct spec.
        if expected then
            assert(
                selected_spec.scope
                    and selected_spec.scope.kind == "structural"
                    and selected_spec.scope.owns_members == false,
                "compatible range-for lost structural metadata: "
                    .. case.label
            )
            assert(
                parsed.construct
                    and parsed.construct.kind == "loop",
                "compatible range-for lost loop semantics: "
                    .. case.label
            )
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(
        type(range_spec.availability) == "table"
            and range_spec.availability.language == "cpp"
            and range_spec.availability.dimension == "standard"
            and range_spec.availability.since == "cpp11",
        "C++ range-for must declare cpp11 availability in adapter data"
    )

    assert(
        c.construct_specs.for_range_loop == nil,
        "C adapter unexpectedly inherited C++ range-for semantics"
    )
    assert(
        cpp.construct_specs.for_range_loop == range_spec,
        "range-for compatibility replaced its adapter declaration"
    )

    print(
        "PASS Tree-sitter range-for parsing does not authorize older C++ semantics"
    )
    print(
        "PASS cpp98/cpp03 hide range-for and cpp11+ expose loop semantics"
    )
    print(
        "PASS range-for compatibility honors source/config/default standard precedence"
    )
    print(
        "PASS C isolation and C++ range-for declaration identity preserved"
    )
    print(
        "PASS Tracker_HUD C++ range-for standard compatibility smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD C++ range-for standard compatibility smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
