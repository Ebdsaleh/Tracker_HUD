-- tests/cpp_export_declaration_standard_compatibility_smoke.lua
--
-- C++20 module export-declarations wrap a declaration or a declaration
-- block. Syntax recognition is not semantic availability in older
-- standards. These are parser fixtures, not complete module units.
-- Historical C++98 'export template' is outside this C++20 node gate.

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
    local ok, err = registry.register(c)
    assert(ok, "C registration failed: " .. tostring(err))
    ok, err = registry.register(cpp)
    assert(ok, "C++ registration failed: " .. tostring(err))

    local spec = cpp.construct_specs.export_declaration
    assert(
        type(spec) == "table"
            and type(spec.construct) == "table"
            and spec.construct.kind == "declaration"
            and type(spec.syntax) == "table"
            and spec.syntax.node_type == "export_declaration"
            and spec.scope == nil
            and type(spec.availability) == "table"
            and spec.availability.language == "cpp"
            and spec.availability.dimension == "standard"
            and spec.availability.since == "cpp20",
        "C++20 export-declaration semantic/availability gate missing"
    )

    local cases = {
        {
            label = "cpp98 directive overrides cpp23 config",
            source = "// standard=cpp98;",
            config = { targets = { standard = "cpp23" } },
            selected = "cpp98",
            available = false,
            declaration = "export int api();",
        },
        {
            label = "cpp03 config",
            config = { targets = { standard = "cpp03" } },
            selected = "cpp03",
            available = false,
            declaration = "export int api();",
        },
        {
            label = "cpp11 config",
            config = { targets = { standard = "cpp11" } },
            selected = "cpp11",
            available = false,
            declaration = "export int api();",
        },
        {
            label = "cpp14 config",
            config = { targets = { standard = "cpp14" } },
            selected = "cpp14",
            available = false,
            declaration = "export int api();",
        },
        {
            label = "cpp17 default",
            selected = "cpp17",
            available = false,
            declaration = "export int api();",
        },
        {
            label = "cpp20 directive overrides cpp17 config",
            source = "// standard=20;",
            config = { targets = { standard = "cpp17" } },
            selected = "cpp20",
            available = true,
            declaration = "export int api();",
        },
        {
            label = "cpp20 export block",
            config = { targets = { standard = "cpp20" } },
            selected = "cpp20",
            available = true,
            declaration = "export { int api(); }",
            has_block = true,
        },
        {
            label = "cpp23 alias config",
            config = { targets = { standard = "c++23" } },
            selected = "cpp23",
            available = true,
            declaration = "export int api();",
        },
    }

    for _, case in ipairs(cases) do
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            case.source or "// C++20 export-declaration target test",
            case.declaration,
        })
        vim.bo[bufnr].filetype = "cpp"

        local parser_ok, parser =
            pcall(vim.treesitter.get_parser, bufnr, "cpp")
        assert(
            parser_ok and parser,
            "C++ Tree-sitter parser missing: " .. tostring(parser)
        )
        local tree = parser:parse()[1]
        assert(tree and not tree:root():has_error(),
            "C++ export parser ERROR: " .. case.label)

        local node = find_first(tree:root(), "export_declaration")
        assert(node, "Tree-sitter missed export_declaration: " .. case.label)

        if case.has_block then
            assert(
                find_first(node, "declaration_list") ~= nil,
                "export declaration block missing: " .. case.label
            )
        else
            assert(
                find_first(node, "function_declarator") ~= nil,
                "exported function declaration missing: " .. case.label
            )
        end

        local configured, configure_err =
            registry.configure_adapter_for_buffer(
                "cpp", bufnr, case.config or {}
            )
        assert(configured, "C++ standard configuration failed: "
            .. case.label .. ": " .. tostring(configure_err))
        assert(cpp.active_targets.standard == case.selected,
            "selected C++ standard mismatch: " .. case.label)

        assert(
            (constructs.get_construct_spec(
                node, cpp, "export_declaration"
            ) == spec) == case.available,
            "export spec lookup breached C++ standard: " .. case.label
        )
        assert(
            engine.match_node(cpp, node) == case.available,
            "export match breached C++ standard: " .. case.label
        )

        local parsed, parse_err =
            registry.parse_node("cpp", node, bufnr)
        assert(
            parse_err == nil and (parsed ~= nil) == case.available,
            "export parse breached C++ standard: "
                .. case.label .. ": " .. tostring(parse_err)
        )
        if case.available then
            assert(
                parsed.construct
                    and parsed.construct.kind == "declaration",
                "export declaration lost semantics: " .. case.label
            )
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(c.construct_specs.export_declaration == nil,
        "C adapter inherited C++20 module-export semantics")
    assert(cpp.construct_specs.export_declaration == spec,
        "C++ export-declaration construct identity changed")

    print("PASS Tree-sitter recognizes single and block export declarations")
    print("PASS cpp98/cpp03/cpp11/cpp14/cpp17 suppress export semantics")
    print("PASS cpp20/cpp23 permit export matching, parsing and lookup")
    print("PASS standard precedence and C adapter isolation")
    print("PASS Tracker_HUD C++20 export-declaration compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic =
        "FAIL C++20 export-declaration compatibility smoke: "
            .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
