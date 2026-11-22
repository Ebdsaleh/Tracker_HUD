-- tests/cpp_alias_declaration_standard_compatibility_smoke.lua
--
-- C++ alias-declarations (using Name = Type) require C++11.
-- Tree-sitter may recognize the grammar regardless of selected standard.
-- Check that shared adapter compatibility hides semantic type declarations
-- in cpp98/cpp03, without affecting the parser, real adapters, or metadata.

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

    local spec = cpp.construct_specs.alias_declaration
    assert(
        type(spec) == "table"
            and type(spec.construct) == "table"
            and spec.construct.kind == "type",
        "C++ alias-declaration construct type is missing"
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
            label = "cpp11 source alias overrides cpp98 config",
            source = "// standard=11;",
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
            case.source or "// C++ alias semantic-standard smoke",
            "using SampleNumber = int;",
            "int read_number() {",
            "    SampleNumber value = 7;",
            "    return value;",
            "}",
        }

        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        vim.bo[bufnr].filetype = "cpp"

        local parser_ok, parser = pcall(
            vim.treesitter.get_parser,
            bufnr,
            "cpp"
        )
        assert(
            parser_ok and parser,
            "Missing C++ Tree-sitter parser: " .. tostring(parser)
        )

        local tree = parser:parse()[1]
        assert(
            tree and not tree:root():has_error(),
            "C++ alias parser fixture contains syntax errors"
        )

        local alias = find_first(
            tree:root(),
            "alias_declaration"
        )
        assert(
            alias ~= nil,
            "Tree-sitter missed alias_declaration in " .. case.label
        )

        local configured, configure_err =
            registry.configure_adapter_for_buffer(
                "cpp",
                bufnr,
                case.config or {}
            )
        assert(
            configured,
            "C++ configuration failed for " .. case.label
                .. ": " .. tostring(configure_err)
        )
        assert(
            cpp.active_targets.standard == case.selected,
            "wrong active C++ standard for " .. case.label
                .. ": " .. tostring(cpp.active_targets.standard)
        )

        local matched = engine.match_node(cpp, alias)
        assert(
            matched == case.available,
            "type-alias match breached C++ standard: " .. case.label
        )

        local parsed, parse_err =
            registry.parse_node("cpp", alias, bufnr)
        assert(
            parse_err == nil
                and (parsed ~= nil) == case.available,
            "type-alias parse breached C++ standard: "
                .. case.label .. ": " .. tostring(parse_err)
        )

        local resolved_spec =
            constructs.get_construct_spec(
                alias,
                cpp,
                "alias_declaration"
            )
        assert(
            (resolved_spec == spec) == case.available,
            "core alias spec lookup breached C++ standard: "
                .. case.label
        )

        if case.available then
            assert(
                parsed.construct
                    and parsed.construct.kind == "type",
                "compatible alias lost type semantics: "
                    .. case.label
            )
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(
        type(spec.availability) == "table"
            and spec.availability.language == "cpp"
            and spec.availability.dimension == "standard"
            and spec.availability.since == "cpp11",
        "C++ alias_declaration must declare cpp11 availability"
    )

    assert(
        c.construct_specs.alias_declaration == nil,
        "C adapter inherited C++ alias-declaration semantics"
    )
    assert(
        cpp.construct_specs.alias_declaration == spec,
        "C++ alias-declaration metadata identity changed"
    )

    print("PASS C++ parser recognizes aliases independent of standard")
    print("PASS cpp98/cpp03 exclude using-alias semantics")
    print("PASS cpp11/cpp17/cpp20/cpp23 expose using-alias types")
    print("PASS source/config/default precedence and C adapter isolation")
    print("PASS Tracker_HUD C++ alias-declaration compatibility smoke")
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD C++ alias-declaration compatibility smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
