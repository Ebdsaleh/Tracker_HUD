-- tests/cpp_import_declaration_standard_compatibility_smoke.lua
--
-- C++20 import-declarations can name a module, a module partition, or
-- a header unit. Tree-sitter syntax recognition alone cannot authorize
-- their semantics in earlier target standards.
-- Parser fixtures exercise syntax/fields, not C++ compilation/linkage.

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
    assert(registered, "C registration failed: " .. tostring(err))
    registered, err = registry.register(cpp)
    assert(registered, "C++ registration failed: " .. tostring(err))

    local spec = cpp.construct_specs.import_declaration
    assert(
        type(spec) == "table"
            and type(spec.construct) == "table"
            and spec.construct.kind == "declaration"
            and type(spec.syntax) == "table"
            and spec.syntax.node_type == "import_declaration"
            and type(spec.syntax.fields) == "table"
            and spec.syntax.fields.name == "name"
            and spec.syntax.fields.partition == "partition"
            and spec.syntax.fields.header == "header"
            and spec.scope == nil
            and type(spec.availability) == "table"
            and spec.availability.language == "cpp"
            and spec.availability.dimension == "standard"
            and spec.availability.since == "cpp20",
        "C++20 import-declaration syntax/availability contract missing"
    )

    local cases = {
        {
            label = "cpp98 directive overrides cpp23 config",
            source = "// standard=cpp98;",
            config = { targets = { standard = "cpp23" } },
            selected = "cpp98",
            available = false,
            source_code = "import atlas;",
            field = "name",
        },
        {
            label = "cpp03 config",
            config = { targets = { standard = "cpp03" } },
            selected = "cpp03",
            available = false,
            source_code = "import atlas;",
            field = "name",
        },
        {
            label = "cpp11 config",
            config = { targets = { standard = "cpp11" } },
            selected = "cpp11",
            available = false,
            source_code = "import atlas;",
            field = "name",
        },
        {
            label = "cpp14 config",
            config = { targets = { standard = "cpp14" } },
            selected = "cpp14",
            available = false,
            source_code = "import atlas;",
            field = "name",
        },
        {
            label = "cpp17 default",
            selected = "cpp17",
            available = false,
            source_code = "import atlas;",
            field = "name",
        },
        {
            label = "cpp20 source alias overrides cpp17 config",
            source = "// standard=20;",
            config = { targets = { standard = "cpp17" } },
            selected = "cpp20",
            available = true,
            source_code = "import atlas;",
            field = "name",
        },
        {
            label = "cpp20 partition import",
            config = { targets = { standard = "cpp20" } },
            selected = "cpp20",
            available = true,
            source_code = "import :detail;",
            field = "partition",
        },
        {
            label = "cpp23 header unit",
            config = { targets = { standard = "c++23" } },
            selected = "cpp23",
            available = true,
            source_code = "import <vector>;",
            field = "header",
        },
    }

    for _, case in ipairs(cases) do
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            case.source or "// C++20 module import target test",
            case.source_code,
        })
        vim.bo[bufnr].filetype = "cpp"

        local parser_ok, parser =
            pcall(vim.treesitter.get_parser, bufnr, "cpp")
        assert(
            parser_ok and parser,
            "C++ parser unavailable: " .. tostring(parser)
        )
        local tree = parser:parse()[1]
        assert(
            tree and not tree:root():has_error(),
            "C++ import fixture parser ERROR: " .. case.label
        )
        local node = find_first(tree:root(), "import_declaration")
        assert(
            node,
            "Tree-sitter missed import_declaration: " .. case.label
        )
        for _, field in ipairs({ "name", "partition", "header" }) do
            assert(
                (node:field(field)[1] ~= nil) == (field == case.field),
                "C++ import field mismatch (" .. field .. "): "
                    .. case.label
            )
        end

        local configured, config_err =
            registry.configure_adapter_for_buffer(
                "cpp", bufnr, case.config or {}
            )
        assert(
            configured,
            "C++ target configuration failed: " .. case.label
                .. ": " .. tostring(config_err)
        )
        assert(
            cpp.active_targets.standard == case.selected,
            "C++ selected standard mismatch: " .. case.label
        )
        assert(
            (constructs.get_construct_spec(
                node, cpp, "import_declaration"
            ) == spec) == case.available,
            "C++ import lookup breached target: " .. case.label
        )
        assert(
            engine.match_node(cpp, node) == case.available,
            "C++ import match breached target: " .. case.label
        )
        local parsed, parse_err =
            registry.parse_node("cpp", node, bufnr)
        assert(
            parse_err == nil and (parsed ~= nil) == case.available,
            "C++ import parse breached target: " .. case.label
                .. ": " .. tostring(parse_err)
        )
        if case.available then
            assert(
                parsed.construct
                    and parsed.construct.kind == "declaration",
                "C++ import lost declaration identity: " .. case.label
            )
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(
        c.construct_specs.import_declaration == nil,
        "C adapter inherited C++20 module import semantics"
    )
    assert(
        cpp.construct_specs.import_declaration == spec,
        "C++ import construct identity changed"
    )

    print("PASS named/partition/header C++ import syntax fields")
    print("PASS cpp98/cpp03/cpp11/cpp14/cpp17 suppress import semantics")
    print("PASS cpp20/cpp23 admit imports in match/parse/lookup")
    print("PASS source/config/default target precedence and C isolation")
    print("PASS Tracker_HUD C++20 import-declaration compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic =
        "FAIL C++20 import-declaration compatibility smoke: "
            .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
