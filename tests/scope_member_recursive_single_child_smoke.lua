-- Checkpoint 259: exercise adapter-declared traversal cardinality via the
-- shared public collectors. C syntax is only a test vehicle; no production
-- C adapter semantics or compiler validity is asserted by this fixture.
local cases = {
    { label = "single child", source = "int item[];", wrapper = "array_declarator",
        text = "item[]", children = 1, mode = "single", name = "item", bindings = { "item" } },
    { label = "multiple children one terminal", source = "int item[3];", wrapper = "array_declarator",
        text = "item[3]", children = 2, mode = "single", name = "item[3]", bindings = {} },
    { label = "multiple children two terminals", source = "int item[extent];", wrapper = "array_declarator",
        text = "item[extent]", children = 2, mode = "single", name = "item[extent]", bindings = {} },
    { label = "zero named children", source = "int item = 7;", node = "init_declarator", field = "value",
        wrapper = "number_literal", text = "7", children = 0, mode = "single", name = "7", bindings = {} },
    { label = "field array", source = "int item[extent];", wrapper = "array_declarator",
        text = "item[extent]", children = 2, mode = "field", name = "item", bindings = { "item" } },
    { label = "field pointer chain", source = "int **item;", wrapper = "pointer_declarator",
        text = "**item", children = 1, mode = "field", name = "item", bindings = { "item" } },
    { label = "legacy unique terminal", source = "int item[3];", wrapper = "array_declarator",
        text = "item[3]", children = 2, mode = "legacy", name = "item", bindings = { "item" } },
    { label = "legacy multiple terminals", source = "int item[extent];", wrapper = "array_declarator",
        text = "item[extent]", children = 2, mode = "legacy", name = "item[extent]",
        bindings = { "item", "extent" } },
    { label = "undeclared wrapper", source = "int item[3];", wrapper = "array_declarator",
        text = "item[3]", children = 2, mode = "unsupported", name = "item[3]", bindings = {} },
}

local function find_nodes(node, kind, found)
    if node:type() == kind then found[#found + 1] = node end
    for i = 0, node:named_child_count() - 1 do
        find_nodes(node:named_child(i), kind, found)
    end
end

local function inspect(members, expected, label)
    assert(#members == #expected, label .. ": expected " .. #expected
        .. " members, got " .. #members)
    local ids = {}
    for i, member in ipairs(members) do
        assert(member.name == expected[i] and member.kind == "symbol" and member.line == 1,
            label .. ": unexpected source member " .. tostring(member.name))
        assert(member.is_binding == false and member.shadows_member_id == nil,
            label .. ": synthetic observations must remain non-binding")
        assert(type(member.id) == "string" and member.id ~= "" and not ids[member.id],
            label .. ": missing/duplicate identity")
        ids[member.id] = true
    end
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local schema = require("tracker_hud.adapters.scope_member_schema")
    local collector = require("tracker_hud.scope_members")
    local c = require("tracker_hud.adapters.c.init")
    local original_members = vim.deepcopy(c.scope_members)
    for _, case in ipairs(cases) do
        local buffer = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { case.source, "" })
        vim.bo[buffer].filetype = "c"
        local ok, parser = pcall(vim.treesitter.get_parser, buffer, "c")
        assert(ok and parser, "C parser unavailable: " .. tostring(parser))
        local tree = parser:parse()[1]
        assert(tree and not tree:root():has_error(), case.label .. ": grammar ERROR")
        local root = tree:root()
        local node_type, field = case.node or "declaration", case.field or "declarator"
        local found = {}
        find_nodes(root, node_type, found)
        assert(#found == 1, case.label .. ": unexpected declaration count")
        local fields = found[1]:field(field)
        assert(#fields == 1, case.label .. ": outer field cardinality drift")
        local wrapper = fields[1]
        assert(wrapper:type() == case.wrapper
            and vim.treesitter.get_node_text(wrapper, buffer) == case.text
            and wrapper:named_child_count() == case.children,
            case.label .. ": wrapper grammar/cardinality drift")
        for _, semantic in ipairs({ "name", "bindings" }) do
            local recursive = {
                terminal_node_types = { "identifier" },
                container_node_types = { case.mode == "unsupported" and "pointer_declarator" or case.wrapper },
            }
            if case.mode ~= "legacy" then recursive.field = "declarator" end
            if case.mode == "single" then
                recursive.single_named_child_node_types = { case.wrapper }
            end
            local descriptor = { field = field, recursive = recursive }
            local adapter = vim.deepcopy(c)
            adapter.scope_members = { symbols = {
                schema.rule(node_type, "symbol", { fields = { [semantic] = descriptor } }),
            } }
            registry.clear()
            local registered, err = registry.register(adapter)
            assert(registered, case.label .. ": adapter contract: " .. tostring(err))
            local expected = semantic == "name" and { case.name } or case.bindings
            local label = case.label .. " / " .. semantic
            local discovery = collector.discover(buffer, root, adapter)
            local all = collector.select(discovery, {})
            inspect(all, expected, label .. " all")
            for _, opts in ipairs({ {}, { cursor_line = 1 },
                { cursor_line = 2, start_line = 1, end_line = 1 },
                { start_line = 2, end_line = 2 } }) do
                local selected = collector.select(discovery, opts)
                local direct = collector.collect(buffer, root, adapter, opts)
                local wanted = opts.start_line == 2 and {} or expected
                inspect(selected, wanted, label .. " shared")
                inspect(direct, wanted, label .. " direct")
                assert(vim.deep_equal(selected, direct), label .. ": direct/shared record drift")
                if opts.start_line ~= 2 then
                    assert(vim.deep_equal(selected, all), label .. ": selection altered source records")
                end
            end
        end
        vim.api.nvim_buf_delete(buffer, { force = true })
        print("PASS shared recursive traversal: " .. case.label)
    end
    assert(vim.deep_equal(c.scope_members, original_members), "test-local adapter mutated production C")
    print("PASS Tracker_HUD shared single named child traversal cardinality and compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL shared single named child traversal smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
