-- Checkpoint 266: certify plain rvalue reference parameter identity and availability.
-- Rvalue references require C++11; lvalue references remain available earlier.
-- Source provenance only; no reference collapsing, referent or runtime lookup claims.
local source = {
    "// rvalue reference parameter provenance",               -- 1
    "int item = 0;",                                -- 2
    "void prototype(int &&item);",                    -- 3
    "void example(int &&item) {",                      -- 4
    "    auto outer = [](int *item[3]) {",               -- 5
    "        void local_proto(const int &item);",           -- 6
    "        auto inner = [](int &&item) {",           -- 7
    "            {",                                -- 8
    "                int item = 1;",                -- 9
    "                consume(item);",                -- 10
    "            }",                                -- 11
    "        };",                                   -- 12
    "        {",                                    -- 13
    "            int item = 2;",                    -- 14
    "        }",                                    -- 15
    "    };",                                       -- 16
    "    auto sibling = [](int item[2][3]) {",             -- 17
    "        {",                                    -- 18
    "            int item = 3;",                    -- 19
    "        }",                                    -- 20
    "    };",                                       -- 21
    "    {",                                        -- 22
    "        int item = 4;",                        -- 23
    "    }",                                        -- 24
    "}",                                            -- 25
    "void lvalue_control(int &item);",              -- 26
}
local records = {
    [2] = { kind = "variable", binding = true },
    [3] = { kind = "parameter", binding = false, rvalue = true },
    [4] = { kind = "parameter", binding = true, target = 2, rvalue = true },
    [5] = { kind = "parameter", binding = true, target = 4, gate = true },
    [6] = { kind = "parameter", binding = false, gate = true },
    [7] = { kind = "parameter", binding = true, target = 5, gate = true, rvalue = true },
    [9] = { kind = "variable", binding = true, target = 7, gate = true },
    [14] = { kind = "variable", binding = true, target = 5, gate = true },
    [17] = { kind = "parameter", binding = true, target = 4, gate = true },
    [19] = { kind = "variable", binding = true, target = 17, gate = true },
    [23] = { kind = "variable", binding = true, target = 4 },
    [26] = { kind = "parameter", binding = false },
}
-- Outer-to-inner grammar wrappers; array bounds follow the exact AST fields.
local shapes = {
    [3] = { text = "&&item", chain = { "reference_declarator" }, token = "&&" },
    [4] = { text = "&&item", chain = { "reference_declarator" }, token = "&&" },
    [5] = { text = "*item[3]", chain = { "pointer_declarator", "array_declarator" }, bounds = { "3" } },
    [6] = { text = "&item", chain = { "reference_declarator" } },
    [7] = { text = "&&item", chain = { "reference_declarator" }, token = "&&" },
    [17] = { text = "item[2][3]", chain = { "array_declarator", "array_declarator" }, bounds = { "3", "2" } },
    [26] = { text = "&item", chain = { "reference_declarator" } },
}
local lambda_ends = { [5] = 16, [7] = 12, [17] = 21 }
local cases = {
    { standard = "cpp17", available = true },
    { standard = "cpp98" },
    { standard = "cpp03" },
    { standard = "cpp11", available = true },
    { standard = "cpp14", available = true },
    { standard = "cpp20", available = true },
    { standard = "cpp23", available = true },
    { standard = "cpp03", config = "cpp23", directive = "// standard=03;" },
    { standard = "cpp11", config = "cpp98", directive = "// standard=11;", available = true },
}

local function same_node(a, b)
    return a and b and a:type() == b:type()
        and vim.deep_equal({ a:range() }, { b:range() })
end

local function inspect_declarator(node, buffer, label, line)
    local shape = shapes[line]
    assert(shape and vim.treesitter.get_node_text(node, buffer) == shape.text,
        label .. ": declarator spelling drift @" .. line)
    local bound_index = 0
    for _, kind in ipairs(shape.chain) do
        assert(node and node:type() == kind, label .. ": wrapper grammar drift @" .. line
            .. " expected " .. kind .. " got " .. tostring(node and node:type()))
        if kind == "reference_declarator" then
            assert(#node:field("declarator") == 0 and node:named_child_count() == 1,
                label .. ": reference field/cardinality drift @" .. line)
            local tokens = 0
            for child in node:iter_children() do
                if child:type() == "&" or child:type() == "&&" then
                    assert(not child:named() and child:type() == (shape.token or "&"),
                        label .. ": wrong reference token @" .. line)
                    tokens = tokens + 1
                end
            end
            assert(tokens == 1, label .. ": reference token cardinality drift @" .. line)
            node = node:named_child(0)
        else
            if kind == "array_declarator" then
                bound_index = bound_index + 1
                local sizes = node:field("size")
                assert(#sizes == 1 and sizes[1]:type() == "number_literal"
                    and vim.treesitter.get_node_text(sizes[1], buffer) == shape.bounds[bound_index],
                    label .. ": array bound drift @" .. line)
            end
            local children = node:field("declarator")
            assert(#children == 1, label .. ": declarator field cardinality drift @" .. line)
            node = children[1]
        end
    end
    assert(bound_index == #(shape.bounds or {}) and node and node:type() == "identifier"
        and vim.treesitter.get_node_text(node, buffer) == "item",
        label .. ": terminal parameter name drift @" .. line)
end

local function inspect_grammar(root, buffer, label)
    local seen, wrappers, lambdas = {}, {}, {}
    local function visit(node)
        local row, _, finish = node:range()
        local line = row + 1
        if node:type() == "lambda_expression" then
            assert(lambda_ends[line] == finish + 1 and not lambdas[line],
                label .. ": lambda range drift @" .. line)
            lambdas[line] = true
        elseif node:type() == "parameter_declaration" then
            local record = records[line]
            local field = node:field("declarator")
            assert(record and record.kind == "parameter" and not seen[line]
                and #field == 1,
                label .. ": parameter grammar drift @" .. line)
            inspect_declarator(field[1], buffer, label, line)
            local list = node:parent()
            local wrapper = list and list:parent()
            local owner = wrapper and wrapper:parent()
            assert(list and list:type() == "parameter_list" and wrapper and owner,
                label .. ": missing parameter ancestry @" .. line)
            if lambda_ends[line] then
                assert((wrapper:type() == "abstract_function_declarator"
                        or wrapper:type() == "lambda_declarator")
                    and owner:type() == "lambda_expression"
                    and same_node(owner:field("declarator")[1], wrapper)
                    and same_node(wrapper:field("parameters")[1], list),
                    label .. ": lambda parameter direct ancestry/field drift @" .. line
                    .. " wrapper=" .. wrapper:type())
                wrappers[wrapper:type()] = true
            else
                assert(wrapper:type() == "function_declarator"
                    and owner:type() == (line == 4 and "function_definition" or "declaration"),
                    label .. ": ordinary definition/prototype ancestry drift @" .. line)
            end
            seen[line] = true
        end
        for child in node:iter_children() do visit(child) end
    end
    visit(root)
    assert(vim.tbl_count(seen) == 7 and vim.tbl_count(lambdas) == 3,
        label .. ": parameter/lambda grammar count drift")
    local types = vim.tbl_keys(wrappers)
    table.sort(types)
    print("OBSERVED lambda parameter wrapper(s) " .. label .. ": " .. table.concat(types, ","))
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local c = require("tracker_hud.adapters.c.init")
    local cpp = require("tracker_hud.adapters.cpp.init")
    local c_members = vim.deepcopy(c.scope_members)
    local lambda_spec = cpp.construct_specs.lambda_expression
    registry.clear()
    for _, adapter in ipairs({ c, cpp }) do
        local ok, err = registry.register(adapter)
        assert(ok, tostring(err))
    end
    local totals = { names = 0, missing = 0, false_binding = 0, links = 0, unavailable = 0 }
    for i, case in ipairs(cases) do
        local label = case.standard .. " case " .. i
        local lines = vim.deepcopy(source)
        lines[1] = case.directive or lines[1]
        local buffer = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
        vim.bo[buffer].filetype = "cpp"
        local ok, parser = pcall(vim.treesitter.get_parser, buffer, "cpp")
        assert(ok and parser, label .. ": parser unavailable " .. tostring(parser))
        local tree = parser:parse()[1]
        assert(tree and not tree:root():has_error(), label .. ": fixture grammar ERROR")
        local root = tree:root()
        inspect_grammar(root, buffer, label)
        local configured, err = registry.configure_adapter_for_buffer("cpp", buffer,
            i == 1 and {} or { targets = { standard = case.config or case.standard } })
        assert(configured, tostring(err))
        assert(cpp.active_targets.standard == case.standard, label .. ": target drift")
        local discovery = collector.discover(buffer, root, cpp)
        local ids = {}
        local function check(members, opts, mode)
            local where = label .. " " .. mode
            local found, used = {}, {}
            for _, member in ipairs(members) do
                if member.kind == "symbol" then
                    assert(member.is_binding ~= true and member.shadows_member_id == nil,
                        where .. ": generic declaration summary became binding")
                elseif member.kind == "parameter"
                    or (member.kind == "variable" and member.name == "item") then
                    local line, record = member.line, records[member.line]
                    assert(record and member.kind == record.kind
                        and not found[line], where .. ": unexpected/duplicate named member @" .. line)
                    if member.kind == "parameter" then
                        assert(member.source_node_type == "parameter_declaration",
                            where .. ": parameter source node type drift @" .. line)
                    end
                    if member.name ~= "item" then
                        assert(member.kind == "parameter" and shapes[line]
                            and member.name == shapes[line].text,
                            where .. ": unexpected parameter name @" .. line)
                        totals.names = totals.names + 1
                    end
                    assert(type(member.id) == "string" and member.id ~= "" and not used[member.id],
                        where .. ": missing/collapsed identity @" .. line)
                    assert(not ids[line] or ids[line] == member.id, where .. ": unstable identity @" .. line)
                    ids[line], used[member.id], found[line] = member.id, true, member
                    assert(member.visibility_start_line == nil and member.visibility_end_line == nil,
                        where .. ": ordinary source member gained explicit lifetime @" .. line)
                    if (member.is_binding == true) ~= record.binding then
                        if record.binding then totals.missing = totals.missing + 1
                        else totals.false_binding = totals.false_binding + 1 end
                    end
                end
            end
            for line, record in pairs(records) do
                local in_projection = (not opts.cursor_line or line <= opts.cursor_line)
                    and (not opts.start_line or line >= opts.start_line)
                    and (not opts.end_line or line <= opts.end_line)
                local expected = (not record.gate or case.available == true)
                    and (not record.rvalue or case.available == true)
                    and in_projection
                -- Only the two ordinary rvalue declarations may accumulate
                -- an availability diagnostic instead of failing membership early.
                -- The enclosing lambda's existing gate must remain strict.
                if found[line] and not expected and in_projection
                    and record.rvalue and not record.gate and not case.available then
                    totals.unavailable = totals.unavailable + 1
                else
                    assert((found[line] ~= nil) == expected, where .. ": membership drift @" .. line)
                end
                if found[line] and expected then
                    local target_line = record.target
                    if line == 23 and not case.available then target_line = 2 end
                    local target = target_line and ids[target_line] or nil
                    if target_line then assert(target, where .. ": historical target missing @" .. line) end
                    if found[line].shadows_member_id ~= target then totals.links = totals.links + 1 end
                end
            end
            return found
        end
        local all = check(collector.select(discovery, {}), {}, "all shared")
        local all_direct = check(collector.collect(buffer, root, cpp, {}), {}, "all direct")
        assert(vim.deep_equal(all, all_direct), label .. ": all-source record drift")
        assert(all[23].scope_depth > all[2].scope_depth,
            label .. ": ordinary body owner drift")
        if all[4] then
            assert(all[4].scope_start_line == 4 and all[4].scope_end_line == 25
                and all[4].scope_depth > all[2].scope_depth
                and all[23].scope_depth > all[4].scope_depth,
                label .. ": ordinary definition owner drift")
        end
        if case.available then
            for line, finish in pairs(lambda_ends) do
                assert(all[line].scope_start_line == line and all[line].scope_end_line == finish,
                    label .. ": lambda parameter owner drift @" .. line)
            end
            assert(all[5].scope_depth > all[4].scope_depth
                and all[7].scope_depth > all[5].scope_depth
                and all[17].scope_depth == all[5].scope_depth
                and all[9].scope_depth > all[7].scope_depth
                and all[14].scope_depth > all[5].scope_depth
                and all[19].scope_depth > all[17].scope_depth,
                label .. ": lambda lexical nesting drift")
        end
        local projections = {
            { start_line = 8, end_line = 11, cursor_line = 10 },
            { start_line = 13, end_line = 15, cursor_line = 14 },
            { start_line = 18, end_line = 20, cursor_line = 19 },
            { start_line = 22, end_line = 24, cursor_line = 23 },
        }
        for cursor = 1, #lines do projections[#projections + 1] = { cursor_line = cursor } end
        for _, opts in ipairs(projections) do
            local shared = check(collector.select(discovery, opts), opts, "shared projection")
            local direct = check(collector.collect(buffer, root, cpp, opts), opts, "direct projection")
            assert(vim.deep_equal(shared, direct), label .. ": direct/shared record drift")
            for line, member in pairs(shared) do
                assert(vim.deep_equal(member, all[line]), label .. ": projection altered source record")
            end
        end
        vim.api.nvim_buf_delete(buffer, { force = true })
    end
    assert(vim.deep_equal(c.scope_members, c_members)
        and c.construct_specs.lambda_expression == nil
        and cpp.construct_specs.lambda_expression == lambda_spec,
        "C isolation or C++ lambda declaration identity drift")
    print("PASS C++ rvalue reference grammar, ownership, lambda gating and filtered membership controls")
    assert(totals.names == 0 and totals.missing == 0 and totals.false_binding == 0
        and totals.links == 0 and totals.unavailable == 0,
        "rvalue reference parameter provenance mismatch: noncanonical_names=" .. totals.names
        .. " missing_binding=" .. totals.missing
        .. " false_binding=" .. totals.false_binding .. " wrong_links=" .. totals.links
        .. " unavailable_members=" .. totals.unavailable)
    print("PASS rvalue reference parameters obey C++11 availability and retain terminal name provenance")
    print("PASS lvalue controls remain available in their grammatical roles and prototypes remain non-binding")
    print("PASS Tracker_HUD C++ rvalue reference parameter provenance smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL C++ rvalue reference parameter provenance smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
