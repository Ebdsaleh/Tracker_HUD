-- Checkpoint 255: pointer parameter declarators must resolve their terminal
-- identifier, while definition/prototype eligibility and ownership stay intact.
-- Source provenance only, not pointer runtime state or full language lookup.
local source = {
    "void prototype(int *item);",               -- 1
    "int item = 0;",                           -- 2
    "void example(int *item) {",                -- 3
    "    void local_proto(int *item);",         -- 4
    "    {",                                   -- 5
    "        int item = 1;",                   -- 6
    "        consume(item);",                  -- 7
    "    }",                                   -- 8
    "    consume(item);",                      -- 9
    "}",                                       -- 10
    "void sibling(int **item) {",                -- 11
    "    {",                                   -- 12
    "        int item = 2;",                   -- 13
    "    }",                                   -- 14
    "}",                                       -- 15
    "void accepts(void (*callback)(int hidden));", -- 16
}
local pointer_depth = { [1] = 1, [3] = 1, [4] = 1, [11] = 2 }
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
            local row = node:range()
            local line = row + 1
            if pointer_depth[line] then
                for _ = 1, pointer_depth[line] do
                    assert(decl and decl:type() == "pointer_declarator",
                        label .. ": pointer grammar drift @" .. line)
                    decl = decl:field("declarator")[1]
                end
                assert(decl and decl:type() == "identifier"
                    and vim.treesitter.get_node_text(decl, buffer) == "item"
                    and not seen[line], label .. ": terminal pointer name drift @" .. line)
                assert(matches_path(node, definition_path) == records[line].binding,
                    label .. ": pointer ownership grammar drift @" .. line)
                seen[line] = true
            elseif decl and decl:type() == "identifier" then
                assert(line == 16 and vim.treesitter.get_node_text(decl, buffer) == "hidden"
                    and not seen[line] and not matches_path(node, definition_path),
                    label .. ": nested callback prototype grammar drift")
                seen[line] = true
            end
        end
        for child in node:iter_children() do inspect(child) end
    end
    inspect(root)
    assert(vim.tbl_count(seen) == 5, label .. ": expected four pointer parameters and one callback prototype identifier")
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
                local line = member.line
                -- Recognize only the exact legacy decorated spelling so that
                -- the intended RED reports name/provenance rather than a
                -- misleading missing-member failure. Never accept it as GREEN.
                local legacy = pointer_depth[line] and (string.rep("*", pointer_depth[line]) .. "item")
                if member.name == "item" or member.name == "hidden"
                    or (legacy and member.name == legacy) then
                    local record = records[line]
                    assert(record and record.kind == member.kind and not found[line],
                        where .. ": unexpected or duplicate named record @" .. line)
                    local canonical = record.name or "item"
                    if member.name ~= canonical then
                        assert(member.kind == "parameter" and member.name == legacy,
                            where .. ": unexpected parameter name @" .. line)
                        totals.names = totals.names + 1
                    end
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
                elseif member.kind == "parameter" and (member.name == "item"
                    or member.name == "*item" or member.name == "**item") then
                    error(label .. ": out-of-range parameter leaked")
                end
            end
            assert(count == 1, label .. ": nested filtered variable missing")
        end
    end
    vim.api.nvim_buf_delete(buffer, { force = true })
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local cpp = require("tracker_hud.adapters.cpp.init")
    local c = require("tracker_hud.adapters.c.init")
    registry.clear()
    local totals = { names = 0, missing = 0, false_binding = 0, links = 0 }
    for _, adapter in ipairs({ c, cpp }) do
        local ok, err = registry.register(adapter)
        assert(ok, tostring(err))
    end
    run_case(registry, collector, c, nil, {}, totals)
    for i, standard in ipairs({ "cpp17", "cpp98", "cpp03", "cpp11", "cpp14", "cpp20", "cpp23" }) do
        run_case(registry, collector, cpp, standard,
            i == 1 and {} or { targets = { standard = standard } }, totals)
    end
    print("PASS C/C++ pointer parameter grammar, identity, ownership and filtered membership")
    assert(totals.names == 0 and totals.missing == 0 and totals.false_binding == 0 and totals.links == 0,
        "pointer parameter provenance mismatch: noncanonical_names=" .. totals.names
        .. " missing_binding=" .. totals.missing .. " false_binding=" .. totals.false_binding
        .. " wrong_links=" .. totals.links)
    print("PASS pointer parameters use terminal names and retain definition shadow provenance")
    print("PASS pointer prototype observations remain non-binding")
    print("PASS Tracker_HUD C/C++ pointer parameter provenance smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL C/C++ pointer parameter provenance smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
