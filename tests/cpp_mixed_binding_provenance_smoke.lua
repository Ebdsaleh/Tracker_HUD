-- Checkpoint 253: already-enabled C++ binding roles compose in one
-- source history. No new declaration rules, runtime lookup or value claims.
local source = {
    "// mixed C++ binding provenance",                  -- 1
    "int item = 0;",                                    -- 2
    "int companion = 0;",                               -- 3
    "void example() {",                                 -- 4
    "    for (int item = 1; item < 2; ++item) {",        -- 5
    "        {",                                        -- 6
    "            auto [item, companion] = make_pair();", -- 7
    "            {",                                    -- 8
    "                for (int item : items) {",         -- 9
    "                    {",                            -- 10
    "                        int item = 7;",             -- 11
    "                        consume(item);",            -- 12
    "                    }",                            -- 13
    "                }",                                -- 14
    "                for (auto [item, companion] : pairs) {", -- 15
    "                    {",                            -- 16
    "                        int item = 8;",             -- 17
    "                        int companion = 9;",        -- 18
    "                        consume(item, companion);", -- 19
    "                    }",                            -- 20
    "                }",                                -- 21
    "            }",                                    -- 22
    "        }",                                        -- 23
    "    }",                                            -- 24
    "    for (int item : items) {",                      -- 25
    "        consume(item);",                            -- 26
    "    }",                                            -- 27
    "    {",                                            -- 28
    "        const int item = 11;",                      -- 29
    "    }",                                            -- 30
    "}",                                                -- 31
}
local cases = {
    { standard = "cpp17", range = true, structured = true },
    { standard = "cpp98" },
    { standard = "cpp03" },
    { standard = "cpp11", range = true },
    { standard = "cpp14", range = true },
    { standard = "cpp20", range = true, structured = true },
    { standard = "cpp23", range = true, structured = true },
    { standard = "cpp03", config = "cpp23", directive = "// standard=03;" },
    { standard = "cpp17", config = "cpp11", directive = "// standard=17;", range = true, structured = true },
}
-- Explicit expectations for each emitted name, including the second name
-- of each structured binding. Targets refer to declaration identity, not
-- the current cursor's filtered list or merely a matching display name.
local records = {
    { line = 2, name = "item" },
    { line = 3, name = "companion" },
    { line = 5, name = "item", finish = 24, target = 2 },
    { line = 7, name = "item", gate = "structured", target = 5 },
    { line = 7, name = "companion", gate = "structured", target = 3 },
    { line = 9, name = "item", kind = "loop_variable", finish = 14,
        gate = "range", target = 7, fallback = 5 },
    { line = 11, name = "item", gate = "range", target = 9 },
    { line = 15, name = "item", kind = "loop_variable", finish = 21,
        gate = "structured", target = 7 },
    { line = 15, name = "companion", kind = "loop_variable", finish = 21,
        gate = "structured", target = 7 },
    -- Before C++17 the structured declarator is unavailable, but the
    -- C++11 range-loop body remains discoverable; its ordinary declarations
    -- must bypass both unavailable and expired header candidates.
    { line = 17, name = "item", gate = "range", target = 15, fallback = 5 },
    { line = 18, name = "companion", gate = "range", target = 15, fallback = 3 },
    { line = 25, name = "item", kind = "loop_variable", finish = 27,
        gate = "range", target = 2 },
    { line = 29, name = "item", target = 2 },
}
local function key(line, name)
    return tostring(line) .. ":" .. name
end

local function same_owner(a, b)
    return a.scope_depth == b.scope_depth
        and a.scope_start_line == b.scope_start_line
        and a.scope_end_line == b.scope_end_line
        and a.scope_start_column == b.scope_start_column
        and a.scope_end_column == b.scope_end_column
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local cpp = require("tracker_hud.adapters.cpp.init")
    registry.clear()
    local registered, err = registry.register(cpp)
    assert(registered, tostring(err))
    local expected_by_key = {}
    for _, record in ipairs(records) do
        expected_by_key[key(record.line, record.name)] = record
    end
    for i, case in ipairs(cases) do
        local label = case.standard .. " case " .. i
        local buffer = vim.api.nvim_create_buf(false, true)
        local lines = vim.deepcopy(source)
        lines[1] = case.directive or lines[1]
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
        vim.bo[buffer].filetype = "cpp"
        local ok, parser = pcall(vim.treesitter.get_parser, buffer, "cpp")
        assert(ok and parser, "C++ parser unavailable: " .. tostring(parser))
        local tree = parser:parse()[1]
        assert(tree and not tree:root():has_error(), label .. ": fixture grammar ERROR")
        local root = tree:root()
        local syntax = {
            init_declarator = { [2] = "identifier", [3] = "identifier",
                [5] = "identifier", [7] = "structured_binding_declarator",
                [11] = "identifier", [17] = "identifier", [18] = "identifier",
                [29] = "identifier" },
            for_range_loop = { [9] = "identifier",
                [15] = "structured_binding_declarator", [25] = "identifier" },
        }
        local seen = {}
        local function inspect(node)
            local expected = syntax[node:type()]
            if expected then
                local row = node:range()
                local line = row + 1
                local declarator = node:field("declarator")[1]
                assert(expected[line] and not seen[line] and declarator
                    and declarator:type() == expected[line], label .. ": grammar drift @" .. line)
                if expected[line] == "structured_binding_declarator" then
                    assert(declarator:named_child_count() == 2
                        and vim.treesitter.get_node_text(declarator:named_child(0), buffer) == "item"
                        and vim.treesitter.get_node_text(declarator:named_child(1), buffer) == "companion",
                        label .. ": structured names drift")
                end
                seen[line] = true
            end
            for child in node:iter_children() do inspect(child) end
        end
        inspect(root)
        assert(vim.tbl_count(seen) == 11, label .. ": missing grammar nodes")
        local config = i == 1 and {} or { targets = { standard = case.config or case.standard } }
        local configured, config_err = registry.configure_adapter_for_buffer("cpp", buffer, config)
        assert(configured, tostring(config_err))
        assert(cpp.active_targets.standard == case.standard, label .. ": target drift")
        local discovery = collector.discover(buffer, root, cpp)
        local ids = {}
        local function check(members, cursor, mode)
            local where = label .. " " .. mode .. " @" .. tostring(cursor or "all")
            local found, used = {}, {}
            for _, member in ipairs(members) do
                if member.kind == "symbol" then
                    assert(member.is_binding ~= true and member.shadows_member_id == nil,
                        where .. ": generic declaration summary became binding")
                elseif member.kind == "variable" or member.kind == "loop_variable" then
                    local k = key(member.line, member.name)
                    local record = expected_by_key[k]
                    assert(record and not found[k], where .. ": unexpected/composite/duplicate " .. k)
                    assert(member.kind == (record.kind or "variable") and member.is_binding == true,
                        where .. ": role or eligibility drift " .. k)
                    assert(type(member.id) == "string" and member.id ~= "" and not used[member.id],
                        where .. ": collapsed identity " .. k)
                    assert(not ids[k] or ids[k] == member.id, where .. ": unstable identity " .. k)
                    assert(member.visibility_start_line == (record.finish and record.line or nil)
                        and member.visibility_end_line == record.finish, where .. ": lifetime drift " .. k)
                    ids[k], used[member.id], found[k] = member.id, true, member
                end
            end
            for _, record in ipairs(records) do
                local k = key(record.line, record.name)
                local expected = (not record.gate or case[record.gate] == true)
                    and (not cursor or (record.line <= cursor
                        and (not record.finish or cursor <= record.finish)))
                assert((found[k] ~= nil) == expected, where .. ": membership drift " .. k)
                if found[k] then
                    local target = record.fallback and not case.structured and record.fallback or record.target
                    local expected_id = target and ids[key(target, record.name)] or nil
                    if target then assert(expected_id, where .. ": historical target missing " .. k) end
                    assert(found[k].shadows_member_id == expected_id,
                        where .. ": wrong shadow link " .. k .. " -> " .. tostring(target)
                        .. " observed " .. tostring(found[k].shadows_member_id))
                end
            end
            return found
        end
        local all = check(collector.select(discovery, {}), nil, "shared")
        check(collector.collect(buffer, root, cpp, {}), nil, "direct")
        assert(all["5:item"].scope_depth > all["2:item"].scope_depth
            and all["29:item"].scope_depth > all["5:item"].scope_depth,
            label .. ": outer fallback ownership drift")
        if case.range then
            assert(same_owner(all["5:item"], all["25:item"])
                and all["9:item"].scope_depth > all["5:item"].scope_depth
                and all["11:item"].scope_depth > all["9:item"].scope_depth,
                label .. ": traditional/range nesting or sibling owner drift")
        end
        if case.structured then
            assert(all["7:item"].scope_depth > all["5:item"].scope_depth
                and all["9:item"].scope_depth > all["7:item"].scope_depth
                and same_owner(all["9:item"], all["15:item"])
                and same_owner(all["7:item"], all["7:companion"])
                and same_owner(all["15:item"], all["15:companion"])
                and all["17:item"].scope_depth > all["15:item"].scope_depth,
                label .. ": structured nesting or owner drift")
        end
        for cursor = 1, #lines do
            local opts = { cursor_line = cursor }
            check(collector.select(discovery, opts), cursor, "shared")
            check(collector.collect(buffer, root, cpp, opts), cursor, "direct")
        end
        check(collector.select(discovery, {}), nil, "shared repeat")
        vim.api.nvim_buf_delete(buffer, { force = true })
    end
    print("PASS mixed C++ binding identities and cross-role historical shadow links")
    print("PASS mixed C++ standard gating, nested ownership and expired sibling fallback")
    print("PASS Tracker_HUD C++ mixed binding provenance smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL C++ mixed binding provenance smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
