-- tests/cpp_lambda_standard_compatibility_smoke.lua
--
-- First real C++ semantic compatibility consumer: lambda_expression.
--
-- Tree-sitter may recognize lambda syntax in any parsed C++ source, but
-- the selected C++ standard determines whether the adapter may expose
-- its semantic construct/scope. This is not compiler conformance checking.

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

    local registered, err =
        registry.register(c)
    assert(registered, "C registration failed: " .. tostring(err))

    registered, err =
        registry.register(cpp)
    assert(registered, "C++ registration failed: " .. tostring(err))

    local lambda_spec =
        cpp.construct_specs.lambda_expression
    assert(
        type(lambda_spec) == "table",
        "C++ lambda construct declaration missing"
    )

    local fixture =
        vim.fn.readfile(
            "samples/cpp/cpp_adapter_validation.cpp"
        )

    assert(
        #fixture > 0,
        "C++ lambda source fixture missing"
    )

    local cases = {
        {
            label = "cpp98 source overrides cpp20 config",
            directive = "// standard=cpp98;",
            config = { targets = { standard = "cpp20" } },
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
            label = "cpp11 source alias overrides cpp98 config",
            directive = "// standard=11;",
            config = { targets = { standard = "cpp98" } },
            selected = "cpp11",
            available = true,
        },
        {
            label = "cpp17 default",
            selected = "cpp17",
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
        local lines = vim.deepcopy(fixture)
        table.insert(
            lines,
            1,
            case.directive
                or "// lambda semantic-standard smoke"
        )

        local bufnr =
            vim.api.nvim_create_buf(false, true)

        vim.api.nvim_buf_set_lines(
            bufnr,
            0,
            -1,
            false,
            lines
        )
        vim.bo[bufnr].filetype = "cpp"

        local parser_ok, parser =
            pcall(
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
        assert(tree, "C++ parser returned no tree")
        local root = tree:root()

        assert(
            not root:has_error(),
            "C++ validation fixture has parser ERROR nodes"
        )

        local lambda =
            find_first(root, "lambda_expression")

        assert(
            lambda ~= nil,
            "Tree-sitter did not recognize lambda in "
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
            "C++ standard configuration failed for "
                .. case.label
                .. ": "
                .. tostring(configure_err)
        )

        assert(
            cpp.active_targets.standard
                == case.selected,
            "wrong active C++ standard for "
                .. case.label
                .. ": "
                .. tostring(
                    cpp.active_targets.standard
                )
        )

        local expected = case.available
        local matched =
            context_engine.match_node(
                cpp,
                lambda
            )

        assert(
            matched == expected,
            "semantic lambda match incorrect for "
                .. case.label
        )

        local parsed, parse_err =
            registry.parse_node(
                "cpp",
                lambda,
                bufnr
            )

        assert(
            parse_err == nil,
            "unexpected lambda parse error for "
                .. case.label
                .. ": "
                .. tostring(parse_err)
        )

        assert(
            (parsed ~= nil) == expected,
            "semantic lambda parse incorrect for "
                .. case.label
        )

        local construct_spec =
            construct_utils.get_construct_spec(
                lambda,
                cpp,
                "lambda_expression"
            )

        assert(
            (construct_spec == lambda_spec)
                == expected,
            "core construct lookup incorrect for "
                .. case.label
        )

        assert(
            construct_utils.node_creates_lexical_scope(
                lambda,
                cpp
            ) == expected,
            "lambda lexical scope compatibility incorrect for "
                .. case.label
        )

        if expected then
            assert(
                parsed.construct
                    and parsed.construct.kind
                        == "function",
                "compatible lambda lost function semantics for "
                    .. case.label
            )
        end

        vim.api.nvim_buf_delete(
            bufnr,
            { force = true }
        )
    end

    assert(
        type(lambda_spec.availability)
            == "table"
            and lambda_spec.availability.language
                == "cpp"
            and lambda_spec.availability.dimension
                == "standard"
            and lambda_spec.availability.since
                == "cpp11",
        "C++ lambda must declare cpp11 semantic availability in adapter data"
    )

    assert(
        c.target_dimensions == nil
            or c.target_dimensions.standard
                == nil,
        "C adapter inherited the C++ standard dimension"
    )

    assert(
        c.construct_specs.lambda_expression
            == nil,
        "C adapter inherited the C++ lambda construct"
    )

    assert(
        cpp.construct_specs.lambda_expression
            == lambda_spec,
        "C++ lambda compatibility replaced its construct declaration"
    )

    print(
        "PASS C++ lambda Tree-sitter recognition is independent of semantic standard"
    )
    print(
        "PASS C++ lambda semantics hidden in cpp98/cpp03 and active from cpp11"
    )
    print(
        "PASS C++ standard source/config/default selection controls semantic availability"
    )
    print(
        "PASS C adapter isolation and lambda declaration identity"
    )
    print(
        "PASS Tracker_HUD C++ lambda standard compatibility smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD C++ lambda standard compatibility smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
