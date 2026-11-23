-- tests/cpp_module_declaration_standard_compatibility_smoke.lua
--
-- C++20 introduced named module declarations and module partitions.
-- Tree-sitter may recognize this syntax regardless of the configured
-- C++ standard. Semantic matching/parsing must remain target-gated.
-- This fixture checks syntax/metadata only, not compiler linkage.

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
    assert(registered, "C adapter registration: " .. tostring(err))
    registered, err = registry.register(cpp)
    assert(registered, "C++ adapter registration: " .. tostring(err))

    local spec = cpp.construct_specs.module_declaration
    assert(
        type(spec) == "table"
            and type(spec.construct) == "table"
            and spec.construct.kind == "module"
            and type(spec.syntax) == "table"
            and spec.syntax.node_type == "module_declaration"
            and type(spec.syntax.fields) == "table"
            and spec.syntax.fields.name == "name"
            and spec.syntax.fields.partition == "partition"
            and spec.scope == nil
            and type(spec.availability) == "table"
            and spec.availability.language == "cpp"
            and spec.availability.dimension == "standard"
            and spec.availability.since == "cpp20",
        "C++20 named module declaration is missing or incorrectly scoped"
    )

    local cases = {
        {
            label = "cpp98 source overrides cpp23 config",
            source = "// standard=cpp98;",
            config = { targets = { standard = "cpp23" } },
            selected = "cpp98",
            available = false,
            declaration = "export module atlas;",
        },
        {
            label = "cpp03 config",
            config = { targets = { standard = "cpp03" } },
            selected = "cpp03",
            available = false,
            declaration = "module atlas:detail;",
            partition = true,
        },
        {
            label = "cpp11 config",
            config = { targets = { standard = "cpp11" } },
            selected = "cpp11",
            available = false,
            declaration = "export module atlas;",
        },
        {
            label = "cpp14 config",
            config = { targets = { standard = "cpp14" } },
            selected = "cpp14",
            available = false,
            declaration = "module atlas:detail;",
            partition = true,
        },
        {
            label = "cpp17 default",
            selected = "cpp17",
            available = false,
            declaration = "export module atlas;",
        },
        {
            label = "cpp20 source overrides cpp17 config",
            source = "// standard=20;",
            config = { targets = { standard = "cpp17" } },
            selected = "cpp20",
            available = true,
            declaration = "export module atlas;",
        },
        {
            label = "cpp20 config partition",
            config = { targets = { standard = "cpp20" } },
            selected = "cpp20",
            available = true,
            declaration = "module atlas:detail;",
            partition = true,
        },
        {
            label = "cpp23 alias config",
            config = { targets = { standard = "c++23" } },
            selected = "cpp23",
            available = true,
            declaration = "export module atlas;",
        },
    }

    for _, case in ipairs(cases) do
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            case.source or "// C++20 named-module target test",
            case.declaration,
        })
        vim.bo[bufnr].filetype = "cpp"

        local parser_ok, parser =
            pcall(vim.treesitter.get_parser, bufnr, "cpp")
        assert(
            parser_ok and parser,
            "C++ Tree-sitter parser unavailable: " .. tostring(parser)
        )

        local tree = parser:parse()[1]
        assert(
            tree and not tree:root():has_error(),
            "C++ module grammar failed on " .. case.label
        )
        local module_node =
            find_first(tree:root(), "module_declaration")
        assert(
            module_node ~= nil,
            "module_declaration syntax unrecognized: " .. case.label
        )
        assert(
            module_node:field("name")[1] ~= nil,
            "Tree-sitter module name field absent: " .. case.label
        )
        assert(
            (module_node:field("partition")[1] ~= nil)
                == (case.partition == true),
            "Tree-sitter module partition field mismatch: " .. case.label
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
            "wrong C++ target resolution: " .. case.label
        )

        assert(
            (constructs.get_construct_spec(
                module_node, cpp, "module_declaration"
            ) == spec) == case.available,
            "module spec lookup crossed standard boundary: "
                .. case.label
        )
        assert(
            engine.match_node(cpp, module_node) == case.available,
            "module construct match crossed standard boundary: "
                .. case.label
        )
        local parsed, parse_err =
            registry.parse_node("cpp", module_node, bufnr)
        assert(
            parse_err == nil
                and (parsed ~= nil) == case.available,
            "module construct parse crossed standard boundary: "
                .. case.label .. ": " .. tostring(parse_err)
        )
        if case.available then
            assert(
                parsed.construct
                    and parsed.construct.kind == "module",
                "named module lost construct semantics: " .. case.label
            )
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(
        c.construct_specs.module_declaration == nil,
        "C adapter inherited C++ module semantics"
    )
    assert(
        cpp.construct_specs.module_declaration == spec,
        "C++ named-module declaration identity changed"
    )

    print("PASS Tree-sitter recognizes exported and partitioned C++ modules")
    print("PASS cpp98/cpp03/cpp11/cpp14/cpp17 hide named-module semantics")
    print("PASS cpp20/cpp23 expose named-module constructs without lexical scope")
    print("PASS source/config/default target precedence and C isolation")
    print("PASS Tracker_HUD C++20 named-module standard compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic =
        "FAIL C++20 named-module standard compatibility smoke: "
            .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
