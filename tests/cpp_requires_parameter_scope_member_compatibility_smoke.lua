-- tests/cpp_requires_parameter_scope_member_compatibility_smoke.lua
--
-- C++20 requires-expression parameter bindings are local to the requirement
-- expression. Tree-sitter recognition does not authorize an older standard
-- to publish those bindings. This test checks direct and shared Scope Member
-- discovery and cursor selection, not compiler constraint satisfaction.

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

local function find_members(members, name, kind)
    local found = {}
    for _, member in ipairs(members or {}) do
        if member.name == name and member.kind == kind then
            table.insert(found, member)
        end
    end
    return found
end

local function check_members(members, name, kind, expected, description)
    local found = find_members(members, name, kind)
    assert(
        #found == expected,
        description .. " expected " .. tostring(expected)
            .. ", observed " .. tostring(#found)
    )
    return found[1]
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

    local spec = cpp.construct_specs.requires_expression
    assert(
        type(spec) == "table"
            and type(spec.scope) == "table"
            and spec.scope.kind == "lexical"
            and spec.scope.affects_visibility == true
            and spec.scope.owns_members == true
            and type(spec.availability) == "table"
            and spec.availability.since == "cpp20",
        "requires-expression construct/scope prerequisite missing"
    )

    local cases = {
        {
            label = "cpp17 default",
            selected = "cpp17",
            available = false,
        },
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
            label = "cpp23 alias config",
            config = { targets = { standard = "c++23" } },
            selected = "cpp23",
            available = true,
        },
    }

    for _, case in ipairs(cases) do
        local lines = {
            case.directive or "// requires-parameter Scope Member compatibility",
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
        assert(
            tree and not tree:root():has_error(),
            "requires-expression fixture parser ERROR: " .. case.label
        )
        local root = tree:root()
        local requires_node = find_first(root, "requires_expression")
        assert(
            requires_node and find_first(root, "concept_definition"),
            "Tree-sitter missed requires/concept syntax: " .. case.label
        )
        assert(
            find_first(requires_node, "parameter_declaration"),
            "requires-expression parameter syntax is missing: " .. case.label
        )

        local configured, config_err =
            registry.configure_adapter_for_buffer(
                "cpp", bufnr, case.config or {}
            )
        assert(
            configured,
            "C++ config failed: " .. case.label
                .. ": " .. tostring(config_err)
        )
        assert(
            cpp.active_targets.standard == case.selected,
            "unexpected C++ standard: " .. case.label
        )

        assert(
            (constructs.get_construct_spec(
                requires_node, cpp, "requires_expression"
            ) == spec) == case.available,
            "requires-expression availability regressed: " .. case.label
        )

        local raw = collector.collect(bufnr, root, cpp)
        local discovery = collector.discover(bufnr, root, cpp)

        local inside = { cursor_line = 4 }
        local after = { cursor_line = 6 }

        local direct_inside = collector.select(
            { members = raw }, inside
        )
        local shared_inside = collector.select(discovery, inside)
        local direct_after = collector.select(
            { members = raw }, after
        )
        local shared_after = collector.select(discovery, after)

        local expected = case.available and 1 or 0
        local raw_binding = check_members(
            raw, "candidate", "parameter", expected,
            "direct raw binding: " .. case.label
        )
        check_members(
            discovery.members, "candidate", "parameter", expected,
            "shared raw binding: " .. case.label
        )
        check_members(
            direct_inside, "candidate", "parameter", expected,
            "direct inside: " .. case.label
        )
        check_members(
            shared_inside, "candidate", "parameter", expected,
            "shared inside: " .. case.label
        )
        check_members(
            direct_after, "candidate", "parameter", 0,
            "direct after: " .. case.label
        )
        check_members(
            shared_after, "candidate", "parameter", 0,
            "shared after: " .. case.label
        )

        if case.available then
            assert(
                type(raw_binding.scope_start_line) == "number"
                    and raw_binding.scope_start_line <= 4
                    and type(raw_binding.scope_end_line) == "number"
                    and raw_binding.scope_end_line < 6,
                "requires parameter must belong to its own lexical range: "
                    .. case.label
            )
        end

        check_members(
            direct_inside, "amount", "parameter", 0,
            "direct before ordinary function: " .. case.label
        )
        check_members(
            shared_inside, "amount", "parameter", 0,
            "shared before ordinary function: " .. case.label
        )
        check_members(
            direct_after, "amount", "parameter", 1,
            "direct ordinary parameter: " .. case.label
        )
        check_members(
            shared_after, "amount", "parameter", 1,
            "shared ordinary parameter: " .. case.label
        )

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(
        c.construct_specs.requires_expression == nil,
        "C adapter inherited C++20 requires-expression semantics"
    )
    assert(
        cpp.construct_specs.requires_expression == spec,
        "C++ requires-expression identity changed"
    )

    print("PASS C++20+ requires parameters visible inside lexical scope")
    print("PASS requires parameters do not leak beyond requirement block")
    print("PASS cpp98/cpp03/cpp11/cpp17 suppress unavailable bindings")
    print("PASS ordinary function parameters and C adapter isolation")
    print("PASS source/config/default C++ standard precedence")
    print("PASS Tracker_HUD C++ requires-parameter Scope Member compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD requires-parameter Scope Member smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
