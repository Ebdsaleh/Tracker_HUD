-- tests/c_cpp_parser_smoke.lua
--
-- Parser-backed smoke test for the experimental C/C++ adapters.
-- Run from the Tracker_HUD repository root with Tree-sitter's C and C++
-- language parsers installed in THIS Neovim environment:
--
--   nvim --headless -u YOUR_INIT_PATH -c "luafile tests/c_cpp_parser_smoke.lua"
--
-- Important: -u NONE is suitable only if Neovim can already find its
-- Tree-sitter C and C++ parsers without the user's plugin initialization.
-- This test doesn't mutate project source files or the user's config.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    registry.clear()

    local fixtures = {
        {
            ft = "c",
            path = "samples/c/c_adapter_validation.c",
            nodes = {
                struct_specifier = "struct",
                function_definition = "function",
                if_statement = "branch",
                assignment_expression = "assignment",
            },
            expected_member_names = { "Counter", "amount", "previous", "value" },
            visibility_name = "previous",
            visibility_declaration_text = "int previous",
        },
        {
            ft = "cpp",
            path = "samples/cpp/cpp_adapter_validation.cpp",
            nodes = {
                namespace_definition = "namespace",
                class_specifier = "class",
                template_declaration = "declaration",
                function_definition = "function",
                lambda_expression = "function",
                for_range_loop = "loop",
                optional_parameter_declaration = false, -- member-only syntax
            },
            expected_member_names = {
                "tracker_hud_sample", "Counter", "amount", "fallback",
                "value_", "id",
            },
            visibility_name = "fallback",
            visibility_declaration_text = "int with_default(",
        },
    }

    for _, fixture in ipairs(fixtures) do
        local adapter = require("tracker_hud.adapters." .. fixture.ft .. ".init")
        local registered, err = registry.register(adapter)
        assert(registered, fixture.ft .. " adapter registration: " .. tostring(err))

        local buffer = vim.api.nvim_create_buf(false, true)
        local lines = vim.fn.readfile(fixture.path)
        assert(type(lines) == "table" and #lines > 0,
            fixture.ft .. " validation source missing: " .. fixture.path)
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
        vim.bo[buffer].filetype = fixture.ft

        local ok, parser = pcall(vim.treesitter.get_parser, buffer, fixture.ft)
        assert(ok and parser,
            "Missing Tree-sitter '" .. fixture.ft .. "' parser. "
            .. "Install it in your Neovim configuration before running "
            .. "this parser-backed test. Error: " .. tostring(parser))

        local tree = parser:parse()[1]
        assert(tree, fixture.ft .. " parser yielded no tree")
        local root = tree:root()
        assert(not root:has_error(), fixture.ft .. " fixture contains parser ERROR nodes")

        local observed = {}
        local function walk(node)
            local ntype = node:type()
            if fixture.nodes[ntype] ~= nil then
                observed[ntype] = (observed[ntype] or 0) + 1
                local kind = fixture.nodes[ntype]
                if kind then
                    local parsed, parse_err = registry.parse_node(fixture.ft, node, buffer)
                    assert(parsed and not parse_err,
                        fixture.ft .. " " .. ntype
                        .. " runtime parsing failed: " .. tostring(parse_err))
                    assert(parsed.kind == kind or
                           (type(parsed.construct) == "table"
                            and parsed.construct.kind == kind),
                        fixture.ft .. " " .. ntype .. " yielded wrong construct kind")
                end
            end
            for child in node:iter_children() do
                walk(child)
            end
        end
        walk(root)

        for node_type in pairs(fixture.nodes) do
            assert(observed[node_type] and observed[node_type] > 0,
                fixture.ft .. " expected Tree-sitter node missing: " .. node_type)
        end
        print("PASS " .. fixture.ft .. " parser constructs mapped from real syntax")

        local all = collector.collect(buffer, root, adapter, {
            cursor_line = #lines,
        })
        local by_name = {}
        for _, item in ipairs(all) do
            by_name[item.name] = by_name[item.name] or {}
            table.insert(by_name[item.name], item)
        end
        for _, name in ipairs(fixture.expected_member_names) do
            assert(by_name[name],
                fixture.ft .. " declared member missing from collector: " .. name)
        end

        local declaration_line = nil
        for i, line in ipairs(lines) do
            if line:find(fixture.visibility_declaration_text, 1, true) then
                declaration_line = i
                break
            end
        end
        assert(declaration_line and declaration_line > 1,
            fixture.ft .. " expected declaration line missing from fixture")

        local before = collector.collect(buffer, root, adapter, {
            cursor_line = declaration_line - 1,
        })
        local at = collector.collect(buffer, root, adapter, {
            cursor_line = declaration_line,
        })
        local function has_name(members, wanted)
            for _, item in ipairs(members) do
                if item.name == wanted then
                    return true
                end
            end
            return false
        end

        assert(not has_name(before, fixture.visibility_name),
            fixture.ft .. " future declaration leaked before the cursor")
        -- C++ defaulted parameter is on the function header line. C 'previous'
        -- is on its own declaration line. Both must appear ON the line.
        assert(has_name(at, fixture.visibility_name),
            fixture.ft .. " declaration not visible ON its source line")

        for _, member in ipairs(at) do
            assert(not member.line or member.line <= declaration_line,
                fixture.ft .. " scope member future source-line leak")
        end
        print("PASS " .. fixture.ft .. " source members + ON/PAST cursor discovery")

        pcall(vim.api.nvim_buf_delete, buffer, { force = true })
    end
    print("PASS C/C++ parser-backed Tracker_HUD smoke")
end

local ok, err = pcall(run)
if ok then
    vim.cmd("qa!")
else
    vim.api.nvim_err_writeln("FAIL C/C++ parser-backed smoke: " .. tostring(err))
    vim.cmd("cquit 1")
end
