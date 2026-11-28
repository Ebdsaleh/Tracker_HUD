-- Checkpoint 254: function-definition parameters are distinct from
-- prototype parameter observations. Source provenance only, not runtime lookup.
local source = {
    "void prototype(int item);",               -- 1
    "int item = 0;",                           -- 2
    "void example(int item) {",                -- 3
    "    void local_proto(int item);",         -- 4
    "    {",                                   -- 5
    "        int item = 1;",                   -- 6
    "        consume(item);",                  -- 7
    "    }",                                   -- 8
    "    consume(item);",                      -- 9
    "}",                                       -- 10
    "void sibling(int item) {",                -- 11
    "    {",                                   -- 12
    "        int item = 2;",                   -- 13
    "    }",                                   -- 14
    "}",                                       -- 15
    "void accepts(void (*callback)(int hidden));", -- 16
}
local definition_path = { "parameter_list", "function_declarator", "function_definition" }
local records = {
    [1] = { kind = "parameter", binding = false },
    [2] = { kind = "variable", binding = true },
    [3] = { kind = "parameter", binding = true, target = 2 },
    [4] = { kind = "parameter", binding = false },
    [6] = { kind = "variable", binding = true, target = 3 },
    [11] = { kind = "parameter", binding = true, target = 2 },
    [13] = { kind = "variable", binding = true, target = 11 },
    [16] = { kind = "parameter", binding = false, name = "hidden" },
}
local function matches_path(node, path)
    for _, kind in ipairs(path) do
        node = node:parent()
        if not node or node:type() ~= kind then return false end
    end
    return true
end

local function run_case(registry, collector, adapter, standard, config, totals)
    local label = adapter.name .. " " .. tostring(standard or "default")
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = adapter.name
    local ok, parser = pcall(vim.treesitter.get_parser, buffer, adapter.name)
    assert(ok and parser, label .. ": parser unavailable " .. tostring(parser))
    local tree = parser:parse()[1]
    assert(tree and not tree:root():has_error(), label .. ": fixture grammar ERROR")
    local root, seen = tree:root(), {}
    local function inspect(node)
        if node:type() == "parameter_declaration" then
            local decl = node:field("declarator")[1]
            if decl and decl:type() == "identifier" then
                local name = vim.treesitter.get_node_text(decl, buffer)
                local row = node:range()
                local line = row + 1
                local record = records[line]
                assert(record and record.kind == "parameter"
                    and name == (record.name or "item") and not seen[line],
                    label .. ": parameter grammar drift @" .. line)
                assert(matches_path(node, definition_path) == record.binding,
                    label .. ": parameter ownership grammar drift @" .. line)
                seen[line] = true
            end
        end
        for child in node:iter_children() do inspect(child) end
    end
    inspect(root)
    assert(vim.tbl_count(seen) == 5, label .. ": expected five direct identifier parameters")
    local configured, err = registry.configure_adapter_for_buffer(adapter.name, buffer, config)
    assert(configured, label .. ": " .. tostring(err))
    if standard then
        assert(adapter.active_targets.standard == standard, label .. ": target mismatch")
    end
    local discovery = collector.discover(buffer, root, adapter)
    local ids = {}
    local function check(members, cursor, mode)
        local where = label .. " " .. mode .. " @" .. tostring(cursor or "all")
        local found, used = {}, {}
        for _, member in ipairs(members) do
            if member.kind == "symbol" then
                assert(member.is_binding ~= true and member.shadows_member_id == nil,
                    where .. ": generic declaration summary became binding")
            elseif member.kind == "parameter" or member.kind == "variable" then
                if member.name == "item" or member.name == "hidden" then
                    local line = member.line
                    local record = records[line]
                    assert(record and record.kind == member.kind
                        and member.name == (record.name or "item") and not found[line],
                        where .. ": unexpected or duplicate named record @" .. line)
                    assert(type(member.id) == "string" and member.id ~= "" and not used[member.id],
                        where .. ": missing or collapsed identity @" .. line)
                    assert(not ids[line] or ids[line] == member.id, where .. ": unstable identity @" .. line)
                    ids[line], used[member.id], found[line] = member.id, true, member
                    assert(member.visibility_start_line == nil and member.visibility_end_line == nil,
                        where .. ": parameter or ordinary variable gained explicit lifetime")
                    if (member.is_binding == true) ~= record.binding then
                        if record.binding then totals.missing = totals.missing + 1
                        else totals.false_binding = totals.false_binding + 1 end
                    end
                end
            end
        end
        for line, record in pairs(records) do
            assert((found[line] ~= nil) == (not cursor or line <= cursor),
                where .. ": membership drift @" .. line)
            if found[line] then
                local expected = record.target and ids[record.target] or nil
                if record.target then assert(expected, where .. ": historical target missing") end
                if found[line].shadows_member_id ~= expected then
                    totals.links = totals.links + 1
                end
            end
        end
        return found
    end
    local all = check(collector.select(discovery, {}), nil, "shared")
    check(collector.collect(buffer, root, adapter, {}), nil, "direct")
    assert(all[3].scope_start_line == 3 and all[3].scope_end_line == 10
        and all[11].scope_start_line == 11 and all[11].scope_end_line == 15
        and all[3].scope_depth == all[11].scope_depth
        and all[3].scope_depth > all[2].scope_depth
        and all[6].scope_depth > all[3].scope_depth
        and all[13].scope_depth > all[11].scope_depth,
        label .. ": definition parameter lexical owners drift")
    for cursor = 1, #source do
        local opts = { cursor_line = cursor }
        check(collector.select(discovery, opts), cursor, "shared")
        check(collector.collect(buffer, root, adapter, opts), cursor, "direct")
    end
    -- Source-range selection may omit the original parameter declaration
    -- without changing the nested variable's historical provenance.
    for _, opts in ipairs({
        { cursor_line = 7, start_line = 5, end_line = 8 },
        { cursor_line = 14, start_line = 12, end_line = 14 },
    }) do
        local nested = opts.start_line == 5 and 6 or 13
        for _, members in ipairs({
            collector.select(discovery, opts),
            collector.collect(buffer, root, adapter, opts),
        }) do
            local count = 0
            for _, member in ipairs(members) do
                if member.name == "item" and member.kind == "variable" then
                    assert(member.line == nested and member.id == ids[nested],
                        label .. ": filtered identity drift")
                    count = count + 1
                    if member.shadows_member_id ~= ids[records[nested].target] then
                        totals.links = totals.links + 1
                    end
                elseif member.name == "item" and member.kind == "parameter" then
                    error(label .. ": out-of-range parameter leaked")
                end
            end
            assert(count == 1, label .. ": nested filtered variable missing")
        end
    end
    vim.api.nvim_buf_delete(buffer, { force = true })
end

local function policy(adapter, totals)
    local rules, definition, fallback = {}, nil, nil
    local callable_paths = {
        definition_path,
        { "parameter_list", "lambda_declarator", "lambda_expression" },
    }
    local function matches_role(role)
        if adapter.name == "cpp" then
            return role.parent_path == nil
                and vim.deep_equal(role.parent_paths, callable_paths)
        end
        return role.parent_paths == nil and vim.deep_equal(role.parent_path, definition_path)
    end
    for _, spec in ipairs(adapter.scope_members.symbols) do
        if spec.syntax.node_type == "parameter_declaration" and spec.member.kind == "parameter" then
            rules[#rules + 1] = spec
            local constraints, exclusions = spec.syntax.constraints or {}, spec.syntax.exclusions or {}
            if matches_role(constraints) then
                assert(not definition, adapter.name .. ": duplicate definition parameter rule")
                definition = spec
            elseif matches_role(exclusions) then
                assert(not fallback, adapter.name .. ": duplicate fallback parameter rule")
                fallback = spec
            end
        end
    end
    if #rules ~= 2 then totals.policy = totals.policy + 1 end
    if not definition or not definition.member.mutability
        or definition.member.mutability.binding ~= "unknown" then
        totals.policy = totals.policy + 1
    end
    if not fallback or fallback.member.mutability ~= nil then
        totals.policy = totals.policy + 1
    end
    return rules
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local cpp = require("tracker_hud.adapters.cpp.init")
    local c = require("tracker_hud.adapters.c.init")
    registry.clear()
    local totals = { missing = 0, false_binding = 0, links = 0, policy = 0 }
    for _, adapter in ipairs({ c, cpp }) do
        local ok, err = registry.register(adapter)
        assert(ok, tostring(err))
    end
    run_case(registry, collector, c, nil, {}, totals)
    for i, standard in ipairs({ "cpp17", "cpp98", "cpp03", "cpp11", "cpp14", "cpp20", "cpp23" }) do
        run_case(registry, collector, cpp, standard,
            i == 1 and {} or { targets = { standard = standard } }, totals)
    end
    print("PASS C/C++ definition and prototype grammar, identity, ownership and filtered membership")
    local cr, cppr = policy(c, totals), policy(cpp, totals)
    -- Require exact inherited rules after only the declared C++ grammar
    -- and callable ancestry extensions. C retains its singular paths.
    assert(#cr == 2 and #cppr == 2, "both complementary parameter roles must remain")
    local expected_c_name = {
        field = "declarator",
        recursive = {
            field = "declarator",
            terminal_node_types = { "identifier" },
            container_node_types = { "pointer_declarator", "array_declarator" },
        },
    }
    local expected_cpp = vim.deepcopy(cr)
    for i, rule in ipairs(cr) do
        assert(vim.deep_equal(rule.syntax.fields.name, expected_c_name),
            "C parameter grammar must remain unchanged")
        local recursive = expected_cpp[i].syntax.fields.name.recursive
        table.insert(recursive.container_node_types, "reference_declarator")
        recursive.single_named_child_node_types = { "reference_declarator" }
        local expected_role = expected_cpp[i].syntax.constraints
            or expected_cpp[i].syntax.exclusions
        expected_role.parent_paths = {
            expected_role.parent_path,
            { "parameter_list", "lambda_declarator", "lambda_expression" },
        }
        expected_role.parent_path = nil
        local cpp_rule = cppr[i]
        local c_role = rule.syntax.constraints or rule.syntax.exclusions
        local cpp_role = cpp_rule.syntax.constraints or cpp_rule.syntax.exclusions
        assert(c_role ~= cpp_role and c_role.parent_path ~= cpp_role.parent_paths[1],
            "inherited callable paths must remain independent")
        assert(rule ~= cpp_rule and rule.syntax ~= cpp_rule.syntax
            and rule.syntax.fields ~= cpp_rule.syntax.fields
            and rule.syntax.fields.name ~= cpp_rule.syntax.fields.name
            and rule.syntax.fields.name.recursive ~= cpp_rule.syntax.fields.name.recursive
            and rule.syntax.fields.name.recursive.container_node_types
                ~= cpp_rule.syntax.fields.name.recursive.container_node_types
            and rule.syntax.fields.name.recursive.terminal_node_types
                ~= cpp_rule.syntax.fields.name.recursive.terminal_node_types
            and rule.member ~= cpp_rule.member,
            "inherited parameter rule tables must remain independent")
    end
    assert(vim.deep_equal(expected_cpp, cppr),
        "C++ parameter rules must differ only by declared reference and callable paths")
    assert(cppr[1].syntax.constraints.parent_paths ~= cppr[2].syntax.exclusions.parent_paths
        and cppr[1].syntax.constraints.parent_paths[1] ~= cppr[2].syntax.exclusions.parent_paths[1]
        and cppr[1].syntax.constraints.parent_paths[2] ~= cppr[2].syntax.exclusions.parent_paths[2],
        "C++ callable and fallback paths must remain independent")
    assert(totals.missing == 0 and totals.false_binding == 0 and totals.links == 0 and totals.policy == 0,
        "definition parameter provenance mismatch: missing_binding=" .. totals.missing
        .. " false_binding=" .. totals.false_binding .. " wrong_links=" .. totals.links
        .. " wrong_policy=" .. totals.policy)
    print("PASS definition parameters shadow global variables and nested declarations shadow parameters")
    print("PASS prototype parameter observations remain non-binding")
    print("PASS Tracker_HUD C/C++ definition parameter provenance smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL C/C++ definition parameter provenance smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
