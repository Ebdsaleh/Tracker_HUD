-- tests/cpp_lambda_scope_member_standard_compatibility_smoke.lua
--
-- C++11 lambda unavailability must extend to the Scope Members owned by
-- its syntax: Tree-sitter can recognize an unavailable lambda under cpp98,
-- but its 'n' parameter is not a valid semantic binding in that standard.
-- Ordinary function parameter 'amount' must remain discoverable. Check
-- direct collection and shared discovery without changing adapter metadata.

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

local function count_parameter(members, name)
    local count = 0
    for _, member in ipairs(members or {}) do
        if member.name == name and member.kind == "parameter" then
            count = count + 1
        end
    end
    return count
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local constructs = require("tracker_hud.construct_utils")
    local c = require("tracker_hud.adapters.c.init")
    local cpp = require("tracker_hud.adapters.cpp.init")

    registry.clear()
    local registered, err = registry.register(c)
    assert(registered, "C registration failed: " .. tostring(err))
    registered, err = registry.register(cpp)
    assert(registered, "C++ registration failed: " .. tostring(err))

    local lambda_spec = cpp.construct_specs.lambda_expression
    assert(
        type(lambda_spec) == "table"
            and type(lambda_spec.availability) == "table"
            and lambda_spec.availability.language == "cpp"
            and lambda_spec.availability.dimension == "standard"
            and lambda_spec.availability.since == "cpp11",
        "C++ lambda prerequisite availability is missing"
    )

    local fixture = vim.fn.readfile(
        "samples/cpp/cpp_adapter_validation.cpp"
    )
    assert(#fixture > 0, "C++ source fixture is missing")

    local cases = {
        {
            label = "cpp17 default",
            selected = "cpp17",
            available = true,
        },
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
            label = "cpp11 source overrides cpp98 config",
            source = "// standard=11;",
            config = { targets = { standard = "cpp98" } },
            selected = "cpp11",
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
        local lines = vim.deepcopy(fixture)
        table.insert(
            lines, 1,
            case.source or "// C++ lambda nested member compatibility"
        )

        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        vim.bo[bufnr].filetype = "cpp"

        local ok, parser = pcall(
            vim.treesitter.get_parser, bufnr, "cpp"
        )
        assert(
            ok and parser,
            "Missing C++ Tree-sitter parser: " .. tostring(parser)
        )
        local tree = parser:parse()[1]
        assert(
            tree and not tree:root():has_error(),
            "C++ lambda fixture contains parser ERROR nodes"
        )
        local root = tree:root()
        local lambda = find_first(root, "lambda_expression")
        assert(lambda ~= nil, "lambda node missing: " .. case.label)

        local configured, configure_err =
            registry.configure_adapter_for_buffer(
                "cpp", bufnr, case.config or {}
            )
        assert(
            configured,
            "configuration failed for " .. case.label
                .. ": " .. tostring(configure_err)
        )
        assert(
            cpp.active_targets.standard == case.selected,
            "active standard incorrect for " .. case.label
        )

        local selected_spec = constructs.get_construct_spec(
            lambda, cpp, "lambda_expression"
        )
        assert(
            (selected_spec == lambda_spec) == case.available,
            "lambda construct availability regressed: " .. case.label
        )

        local direct = collector.collect(
            bufnr, root, cpp, { cursor_line = #lines }
        )
        local discovery = collector.discover(bufnr, root, cpp)
        local shared = collector.select(
            discovery, { cursor_line = #lines }
        )

        local expected_count = case.available and 1 or 0
        assert(
            count_parameter(direct, "n") == expected_count,
            "direct collection leaked/lost lambda parameter 'n': "
                .. case.label .. " (observed "
                .. tostring(count_parameter(direct, "n")) .. ")"
        )
        assert(
            count_parameter(shared, "n") == expected_count,
            "shared discovery leaked/lost lambda parameter 'n': "
                .. case.label .. " (observed "
                .. tostring(count_parameter(shared, "n")) .. ")"
        )
        assert(
            count_parameter(direct, "amount") == 1
                and count_parameter(shared, "amount") == 1,
            "ordinary C++ function parameter 'amount' changed: "
                .. case.label
        )

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(
        c.construct_specs.lambda_expression == nil,
        "C adapter inherited C++ lambda semantics"
    )
    assert(
        cpp.construct_specs.lambda_expression == lambda_spec,
        "C++ lambda declaration identity changed"
    )

    print("PASS C++11+ lambda parameters appear in direct/shared Scope Members")
    print("PASS cpp98/cpp03 suppress unavailable lambda-owned parameters")
    print("PASS ordinary C++ function parameter remains visible in all targets")
    print("PASS C++ standard precedence and C adapter isolation")
    print("PASS Tracker_HUD C++ lambda Scope Member standard compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD C++ lambda Scope Member standard compatibility smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
