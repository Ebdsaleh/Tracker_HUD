-- Checkpoint 261: certify the shared alternative ancestry predicates
-- independently of their production C++ caller. Real C grammar is a test
-- vehicle only; synthetic rules do not redefine production C semantics.
local source = {
    "int global_name;",            -- 1
    "void example(void) {",        -- 2
    "    int body_name;",          -- 3
    "    {",                       -- 4
    "        int nested_name;",    -- 5
    "    }",                       -- 6
    "    if (1) {",                -- 7
    "        int branch_name;",    -- 8
    "    }",                       -- 9
    "}",                           -- 10
}
local global = { "translation_unit" }
local body = { "compound_statement", "function_definition" }
local nested = { "compound_statement", "compound_statement", "function_definition" }
local branch = { "compound_statement", "if_statement", "compound_statement" }
local prefix = { "compound_statement" }
local reversed = { "function_definition", "compound_statement" }
local gap = { "compound_statement", "translation_unit" }
local absent = { "unmatched_owner" }
local records = {
    [1] = { name = "global_name", path = global },
    [3] = { name = "body_name", path = body },
    [5] = { name = "nested_name", path = nested },
    [8] = { name = "branch_name", path = branch },
}
local cases = {
    { label = "unrestricted legacy", expected = { 1, 3, 5, 8 } },
    { label = "first and later alternatives", constraints = { parent_paths = { global, nested } }, expected = { 1, 5 } },
    { label = "reordered alternatives", constraints = { parent_paths = { nested, global } }, expected = { 1, 5 } },
    { label = "later match after miss", constraints = { parent_paths = { absent, branch } }, expected = { 8 } },
    { label = "ordered contiguous only", constraints = { parent_paths = { reversed, gap } }, expected = {} },
    { label = "all alternatives miss", constraints = { parent_paths = { absent, reversed } }, expected = {} },
    { label = "overlapping prefix matches once", constraints = { parent_paths = { prefix, nested } }, expected = { 3, 5, 8 } },
    { label = "exclude either alternative", exclusions = { parent_paths = { global, nested } }, expected = { 3, 8 } },
    { label = "exclusion misses retain all", exclusions = { parent_paths = { reversed, gap } }, expected = { 1, 3, 5, 8 } },
    { label = "constraint with alternative exclusion", constraints = { parent_paths = { body, nested, branch } },
        exclusions = { parent_paths = { absent, nested } }, expected = { 3, 8 } },
    { label = "parent type intersection", constraints = { parent_paths = { global, body }, parent_node_types = { "compound_statement" } }, expected = { 3 } },
    { label = "ancestor constraint intersection", constraints = { parent_paths = { global, branch }, ancestor_node_types = { "function_definition" } }, expected = { 8 } },
    { label = "ancestor exclusion union", exclusions = { parent_paths = { global, absent }, ancestor_node_types = { "if_statement" } }, expected = { 3, 5 } },
    { label = "legacy singular constraint", constraints = { parent_path = nested }, expected = { 5 } },
    { label = "legacy singular exclusion", exclusions = { parent_path = body }, expected = { 1, 5, 8 } },
    { label = "singular with alternative exclusion", constraints = { parent_path = prefix },
        exclusions = { parent_paths = { body, branch } }, expected = { 5 } },
    { label = "alternative with singular exclusion", constraints = { parent_paths = { global, body } },
        exclusions = { parent_path = global }, expected = { 3 } },
}

local function inspect_grammar(root, buffer)
    local found = {}
    local function visit(node)
        if node:type() == "declaration" then
            local row = node:range()
            local line = row + 1
            local record = records[line]
            local names = node:field("declarator")
            assert(record and not found[line] and #names == 1
                and names[1]:type() == "identifier"
                and vim.treesitter.get_node_text(names[1], buffer) == record.name,
                "declaration grammar drift @" .. line)
            local parent = node
            for _, kind in ipairs(record.path) do
                parent = parent:parent()
                assert(parent and parent:type() == kind,
                    "contiguous parent grammar drift @" .. line .. " expected " .. kind)
            end
            found[line] = true
        end
        for child in node:iter_children() do visit(child) end
    end
    visit(root)
    assert(vim.tbl_count(found) == 4, "declaration grammar count drift")
end

local function check(members, expected, opts, label, all_by_line)
    local wanted, found, ids = {}, {}, {}
    for _, line in ipairs(expected) do
        if (not opts.cursor_line or line <= opts.cursor_line)
            and (not opts.start_line or line >= opts.start_line)
            and (not opts.end_line or line <= opts.end_line) then
            wanted[line] = true
        end
    end
    for _, member in ipairs(members) do
        local line = member.line
        assert(wanted[line] and not found[line] and member.name == records[line].name
            and member.kind == "symbol", label .. ": unexpected/duplicate member @" .. line)
        assert(member.is_binding == false and member.shadows_member_id == nil,
            label .. ": synthetic observations became binding")
        assert(type(member.id) == "string" and member.id ~= "" and not ids[member.id],
            label .. ": missing/duplicate source identity")
        if all_by_line then
            assert(vim.deep_equal(member, all_by_line[line]), label .. ": projection altered source record")
        end
        ids[member.id], found[line] = true, member
    end
    assert(vim.tbl_count(found) == vim.tbl_count(wanted), label .. ": missing expected members")
    return found
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local schema = require("tracker_hud.adapters.scope_member_schema")
    local collector = require("tracker_hud.scope_members")
    local c = require("tracker_hud.adapters.c.init")
    local original_members = vim.deepcopy(c.scope_members)
    local original_cases = vim.deepcopy(cases)
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = "c"
    local ok, parser = pcall(vim.treesitter.get_parser, buffer, "c")
    assert(ok and parser, "C parser unavailable: " .. tostring(parser))
    local tree = parser:parse()[1]
    assert(tree and not tree:root():has_error(), "fixture grammar ERROR")
    local root = tree:root()
    inspect_grammar(root, buffer)
    for _, case in ipairs(cases) do
        local options = vim.deepcopy({ constraints = case.constraints, exclusions = case.exclusions })
        local before = vim.deepcopy(options)
        local named = schema.named("declaration", "declarator", "symbol", options)
        local explicit = vim.deepcopy(options)
        explicit.fields = { name = "declarator" }
        assert(vim.deep_equal(named, schema.rule("declaration", "symbol", explicit)),
            case.label .. ": named/rule expansion drift")
        assert(vim.deep_equal(options, before), case.label .. ": builder mutated options")
        local adapter = vim.deepcopy(c)
        adapter.scope_members = { symbols = { named } }
        registry.clear()
        local registered, err = registry.register(adapter)
        assert(registered, case.label .. ": adapter contract " .. tostring(err))
        local discovery = collector.discover(buffer, root, adapter)
        local all = collector.select(discovery, {})
        local all_by_line = check(all, case.expected, {}, case.label .. " all")
        local projections = { {}, { start_line = 3, end_line = 8, cursor_line = 5 },
            { start_line = 5, end_line = 8, cursor_line = 8 },
            { start_line = 10, end_line = 10 } }
        for cursor = 1, #source do projections[#projections + 1] = { cursor_line = cursor } end
        for _, opts in ipairs(projections) do
            local selected = collector.select(discovery, opts)
            local direct = collector.collect(buffer, root, adapter, opts)
            check(selected, case.expected, opts, case.label .. " shared", all_by_line)
            check(direct, case.expected, opts, case.label .. " direct", all_by_line)
            assert(vim.deep_equal(selected, direct), case.label .. ": direct/shared record drift")
        end
        assert(vim.deep_equal(collector.select(discovery, {}), all), case.label .. ": repeated selection drift")
        assert(vim.deep_equal(options, before), case.label .. ": collector mutated declaration")
        print("PASS shared parent paths: " .. case.label)
    end
    assert(vim.deep_equal(c.scope_members, original_members), "test-local adapter mutated production C")
    assert(vim.deep_equal(cases, original_cases), "fixture declarations mutated")
    vim.api.nvim_buf_delete(buffer, { force = true })
    print("PASS Tracker_HUD shared alternative parent paths and singular compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL shared alternative parent paths smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
