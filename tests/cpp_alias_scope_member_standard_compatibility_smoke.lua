-- tests/cpp_alias_scope_member_standard_compatibility_smoke.lua
--
-- Construct matching already gates C++11 'using Name = Type' aliases.
-- Scope Member discovery must honor that SAME construct availability: a
-- grammar-recognized alias under cpp98/cpp03 must not become a visible
-- symbol. This protects direct collection and shared discovery/selection
-- without changing C's adapter or the C++ declaration identity.

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

local function count_aliases(members)
    local count = 0
    for _, member in ipairs(members or {}) do
        if member.name == "VisibleAlias"
            and member.kind == "symbol"
        then
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

    local spec = cpp.construct_specs.alias_declaration
    assert(
        type(spec) == "table"
            and type(spec.availability) == "table"
            and spec.availability.language == "cpp"
            and spec.availability.dimension == "standard"
            and spec.availability.since == "cpp11",
        "C++11 alias construct availability prerequisite missing"
    )

    local cases = {
        {
            label = "cpp17 default emits alias",
            selected = "cpp17",
            visible = true,
        },
        {
            label = "cpp98 source overrides cpp23 config",
            source = "// standard=cpp98;",
            config = { targets = { standard = "cpp23" } },
            selected = "cpp98",
            visible = false,
        },
        {
            label = "cpp03 config hides alias",
            config = { targets = { standard = "cpp03" } },
            selected = "cpp03",
            visible = false,
        },
        {
            label = "cpp11 source overrides cpp98 config",
            source = "// standard=11;",
            config = { targets = { standard = "cpp98" } },
            selected = "cpp11",
            visible = true,
        },
        {
            label = "cpp20 config emits alias",
            config = { targets = { standard = "cpp20" } },
            selected = "cpp20",
            visible = true,
        },
        {
            label = "cpp23 config alias emits alias",
            config = { targets = { standard = "c++23" } },
            selected = "cpp23",
            visible = true,
        },
    }

    for _, case in ipairs(cases) do
        local lines = {
            case.source or "// C++ alias scope-member compatibility",
            "using VisibleAlias = int;",
            "int use_alias() {",
            "    VisibleAlias value = 7;",
            "    return value;",
            "}",
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
            "C++ alias fixture contains Tree-sitter ERROR nodes"
        )

        local root = tree:root()
        local alias = find_first(root, "alias_declaration")
        assert(
            alias,
            "Tree-sitter missed alias_declaration for " .. case.label
        )

        local configured, configure_err =
            registry.configure_adapter_for_buffer(
                "cpp", bufnr, case.config or {}
            )
        assert(
            configured,
            "C++ configuration failed for " .. case.label
                .. ": " .. tostring(configure_err)
        )
        assert(
            cpp.active_targets.standard == case.selected,
            "wrong active standard for " .. case.label
                .. ": " .. tostring(cpp.active_targets.standard)
        )

        -- The earlier C++11 construct gate is already correct.
        local selected_spec = constructs.get_construct_spec(
            alias, cpp, "alias_declaration"
        )
        assert(
            (selected_spec == spec) == case.visible,
            "construct compatibility regressed for " .. case.label
        )

        local directly_collected = collector.collect(
            bufnr,
            root,
            cpp,
            { cursor_line = #lines }
        )
        local direct_count = count_aliases(directly_collected)
        assert(
            direct_count == (case.visible and 1 or 0),
            "direct Scope Member collection exposed incorrect alias in "
                .. case.label .. "; observed " .. tostring(direct_count)
        )

        local discovery = collector.discover(bufnr, root, cpp)
        local selected = collector.select(
            discovery,
            { cursor_line = #lines }
        )
        local shared_count = count_aliases(selected)
        assert(
            shared_count == (case.visible and 1 or 0),
            "shared Scope Member discovery exposed incorrect alias in "
                .. case.label .. "; observed " .. tostring(shared_count)
        )

        assert(
            shared_count == direct_count,
            "direct and shared discovery disagree for " .. case.label
        )

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(
        c.construct_specs.alias_declaration == nil,
        "C adapter unexpectedly inherited C++ type-alias semantics"
    )
    assert(
        cpp.construct_specs.alias_declaration == spec,
        "C++ alias construct identity changed"
    )

    print("PASS cpp11+ using-alias visible in direct and shared collection")
    print("PASS cpp98/cpp03 using-alias hidden from Scope Members")
    print("PASS source/config/default C++ standard precedence")
    print("PASS C adapter isolation and stable C++ construct identity")
    print("PASS Tracker_HUD C++ alias Scope Member standard compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD C++ alias Scope Member standard compatibility smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
