-- tests/cpp_concept_scope_member_standard_compatibility_smoke.lua
--
-- The C++20 concept_definition construct is already gated by the selected
-- standard. Scope Member discovery must publish its name as a source symbol
-- only when that construct is available. Tree-sitter syntax recognition is
-- not compiler conformance checking or concept constraint evaluation.

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

local function count_named(members, name, kind)
    local count = 0
    for _, member in ipairs(members or {}) do
        if member.name == name and member.kind == kind then
            count = count + 1
        end
    end
    return count
end

local function has_concept_member_rule(adapter)
    for _, rule in ipairs(adapter.scope_members.symbols or {}) do
        if rule.syntax
            and rule.syntax.node_type == "concept_definition"
            and rule.member
            and rule.member.kind == "symbol"
        then
            return true
        end
    end
    return false
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
    assert(registered, "C adapter registration failed: " .. tostring(err))
    registered, err = registry.register(cpp)
    assert(registered, "C++ adapter registration failed: " .. tostring(err))

    local spec = cpp.construct_specs.concept_definition
    assert(
        type(spec) == "table"
            and type(spec.availability) == "table"
            and spec.availability.language == "cpp"
            and spec.availability.dimension == "standard"
            and spec.availability.since == "cpp20",
        "C++20 concept construct availability prerequisite missing"
    )

    local cases = {
        {
            label = "cpp17 default hides concept",
            selected = "cpp17",
            visible = false,
        },
        {
            label = "cpp98 source overrides cpp23 config",
            source = "// standard=cpp98;",
            config = { targets = { standard = "cpp23" } },
            selected = "cpp98",
            visible = false,
        },
        {
            label = "cpp03 config hides concept",
            config = { targets = { standard = "cpp03" } },
            selected = "cpp03",
            visible = false,
        },
        {
            label = "cpp11 config hides concept",
            config = { targets = { standard = "cpp11" } },
            selected = "cpp11",
            visible = false,
        },
        {
            label = "cpp20 source overrides cpp17 config",
            source = "// standard=20;",
            config = { targets = { standard = "cpp17" } },
            selected = "cpp20",
            visible = true,
        },
        {
            label = "cpp20 config emits concept",
            config = { targets = { standard = "cpp20" } },
            selected = "cpp20",
            visible = true,
        },
        {
            label = "cpp23 config alias emits concept",
            config = { targets = { standard = "c++23" } },
            selected = "cpp23",
            visible = true,
        },
    }

    for _, case in ipairs(cases) do
        local lines = {
            case.source or "// C++20 concept Scope Member compatibility",
            "template <typename T>",
            "concept VisibleConcept = true;",
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
            "C++ concept fixture has parser ERROR nodes: " .. case.label
        )
        local root = tree:root()
        local concept = find_first(root, "concept_definition")
        assert(
            concept,
            "Tree-sitter missed concept_definition: " .. case.label
        )

        local configured, configure_err =
            registry.configure_adapter_for_buffer(
                "cpp", bufnr, case.config or {}
            )
        assert(
            configured,
            "C++ standard config failed in " .. case.label
                .. ": " .. tostring(configure_err)
        )
        assert(
            cpp.active_targets.standard == case.selected,
            "unexpected selected C++ standard in " .. case.label
        )

        assert(
            (constructs.get_construct_spec(
                concept, cpp, "concept_definition"
            ) == spec) == case.visible,
            "C++20 concept availability regressed: " .. case.label
        )

        local direct = collector.collect(
            bufnr, root, cpp, { cursor_line = #lines }
        )
        local discovery = collector.discover(bufnr, root, cpp)
        local selected = collector.select(
            discovery, { cursor_line = #lines }
        )

        local expected_count = case.visible and 1 or 0
        local direct_count = count_named(
            direct, "VisibleConcept", "symbol"
        )
        local shared_count = count_named(
            selected, "VisibleConcept", "symbol"
        )

        assert(
            direct_count == expected_count,
            "direct Scope Members exposed wrong concept symbol in "
                .. case.label .. ": observed " .. tostring(direct_count)
        )
        assert(
            shared_count == expected_count,
            "shared Scope Members exposed wrong concept symbol in "
                .. case.label .. ": observed " .. tostring(shared_count)
        )
        assert(
            count_named(direct, "amount", "parameter") == 1
                and count_named(selected, "amount", "parameter") == 1,
            "ordinary C++ function parameter changed in " .. case.label
        )

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(
        has_concept_member_rule(cpp),
        "C++ adapter lacks concept_definition Scope Member rule"
    )
    assert(
        not has_concept_member_rule(c),
        "C adapter inherited a C++ concept Scope Member rule"
    )
    assert(
        c.construct_specs.concept_definition == nil,
        "C adapter inherited C++ concept construct semantics"
    )
    assert(
        cpp.construct_specs.concept_definition == spec,
        "C++ concept construct identity changed"
    )

    print("PASS cpp20/cpp23 concept symbols in direct/shared Scope Members")
    print("PASS cpp98/cpp03/cpp11/cpp17 hide concept-owned symbols")
    print("PASS ordinary function parameters and C adapter remain unchanged")
    print("PASS C++ standard precedence and construct identity preserved")
    print("PASS Tracker_HUD C++ concept Scope Member compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD C++ concept Scope Member compatibility smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
