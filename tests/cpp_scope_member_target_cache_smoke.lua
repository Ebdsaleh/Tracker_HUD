-- Checkpoint 267: persistent Scope Member discovery must follow canonical
-- semantic target changes without source edits or adapter replacement.
-- Use the accepted checkpoint 266 fixture and uncached source oracle.
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

local cases = {
    { requested = "cpp17", standard = "cpp17", available = true },
    { requested = "cpp98", standard = "cpp98" },
    { requested = " C++98 ", standard = "cpp98" },
    { requested = "cpp11", standard = "cpp11", available = true },
    { requested = "cpp23", standard = "cpp23", available = true },
    { requested = "cpp03", standard = "cpp03" },
    { requested = " C++17 ", standard = "cpp17", available = true },
    { requested = "cpp17", standard = "cpp17", available = true },
}

local function check_fresh(members, case)
    local found, ids = {}, {}
    for _, member in ipairs(members) do
        if member.kind == "symbol" then
            assert(member.is_binding ~= true and member.shadows_member_id == nil,
                "generic summary gained binding provenance")
        elseif member.kind == "parameter"
            or (member.kind == "variable" and member.name == "item") then
            local line, record = member.line, records[member.line]
            assert(record and record.kind == member.kind and not found[line]
                and member.name == "item" and type(member.id) == "string"
                and member.id ~= "" and not ids[member.id],
                "fresh record identity drift @" .. line)
            assert((member.is_binding == true) == record.binding,
                "fresh binding drift @" .. line)
            if record.kind == "parameter" then
                assert(member.source_node_type == "parameter_declaration",
                    "fresh parameter source grammar drift @" .. line)
            end
            found[line], ids[member.id] = member, true
        end
    end
    for line, record in pairs(records) do
        local expected = (not record.gate or case.available == true)
            and (not record.rvalue or case.available == true)
        assert((found[line] ~= nil) == expected,
            case.standard .. ": uncached membership drift @" .. line)
        if expected then
            local target = record.target
            if line == 23 and not case.available then target = 2 end
            assert(not target or found[target], "fresh historical target missing")
            assert(found[line].shadows_member_id == (target and found[target].id or nil),
                case.standard .. ": uncached shadow drift @" .. line)
        end
    end
    return found
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local cpp = require("tracker_hud.adapters.cpp.init")
    local c = require("tracker_hud.adapters.c.init")
    local c_members = vim.deepcopy(c.scope_members)
    local specs, constructs = cpp.scope_members, cpp.construct_specs
    local spec_values, construct_values = vim.deepcopy(specs), vim.deepcopy(constructs)
    registry.clear()
    assert(registry.register(c))
    assert(registry.register(cpp))
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = "cpp"
    local parser = vim.treesitter.get_parser(buffer, "cpp")
    local tree = parser:parse()[1]
    assert(tree and not tree:root():has_error(), "fixture grammar ERROR")
    local root = tree:root()
    local revision = vim.api.nvim_buf_get_changedtick(buffer)
    local config = { targets = {} }
    local totals = { identity = 0, counters = 0, parity = 0 }
    local previous, previous_standard
    local retained = {}
    local projections = {
        {},
        { start_line = 8, end_line = 11, cursor_line = 10 },
        { start_line = 22, end_line = 24, cursor_line = 23 },
    }
    for cursor = 1, #source do
        projections[#projections + 1] = { cursor_line = cursor }
    end
    local function compare(discovery, fresh)
        for _, opts in ipairs(projections) do
            if not vim.deep_equal(collector.select(discovery, opts), collector.select(fresh, opts)) then
                totals.parity = totals.parity + 1
            end
        end
    end
    local function discover_cached()
        local counts = {}
        local result = collector.discover(buffer, root, cpp, {
            reuse_unchanged_source = true,
            profile_counter = function(key, delta)
                counts[key] = (counts[key] or 0) + delta
            end,
        })
        return result, counts
    end
    local function check_counters(counts, hit)
        local prefix = "context.scope_members."
        local expected_hit, expected_miss = hit and 1 or 0, hit and 0 or 1
        if (counts[prefix .. "cross_refresh_reuse_applied"] or 0) ~= expected_hit
            or (counts[prefix .. "cross_refresh_reuse_possible"] or 0) ~= expected_hit
            or (counts[prefix .. "cross_refresh_reuse_miss"] or 0) ~= expected_miss
        then
            totals.counters = totals.counters + 1
        end
    end

    for i, case in ipairs(cases) do
        config.targets.standard = case.requested
        local ok, err = registry.configure_adapter_for_buffer("cpp", buffer, config)
        assert(ok, tostring(err))
        assert(cpp.active_targets.standard == case.standard, "canonical target drift")
        assert(cpp.scope_members == specs and cpp.construct_specs == constructs
            and vim.deep_equal(specs, spec_values) and vim.deep_equal(constructs, construct_values),
            "configuration replaced or mutated semantic declarations")
        assert(vim.api.nvim_buf_get_changedtick(buffer) == revision
            and vim.deep_equal(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), source),
            "target-only fixture unexpectedly edited source")

        local fresh = collector.discover(buffer, root, cpp)
        local found = check_fresh(collector.select(fresh, {}), case)
        local cached, counts = discover_cached()
        local hit = previous ~= nil and previous_standard == case.standard
        if (cached == previous) ~= hit then totals.identity = totals.identity + 1 end
        check_counters(counts, hit)
        compare(cached, fresh)

        local repeated, repeat_counts = discover_cached()
        if repeated ~= cached then totals.identity = totals.identity + 1 end
        check_counters(repeat_counts, true)
        compare(repeated, fresh)

        for _, old in ipairs(retained) do
            assert(vim.deep_equal(old.discovery, old.snapshot),
                "previous discovery mutated during target switch")
        end
        retained[#retained + 1] = { discovery = cached, snapshot = vim.deepcopy(cached) }
        previous, previous_standard = cached, case.standard
        print("OBSERVED target cache case " .. i .. " " .. case.standard
            .. ": expected_hit=" .. tostring(hit)
            .. " actual_hit=" .. tostring((counts["context.scope_members.cross_refresh_reuse_applied"] or 0) == 1)
            .. " fresh_records=" .. vim.tbl_count(found))
    end
    assert(vim.deep_equal(c.scope_members, c_members), "C adapter isolation drift")
    vim.api.nvim_buf_delete(buffer, { force = true })
    print("PASS target-only configuration, fresh provenance and retained discovery immutability")
    assert(totals.identity == 0 and totals.counters == 0 and totals.parity == 0,
        "target-only Scope Member cache mismatch: identity=" .. totals.identity
        .. " counters=" .. totals.counters .. " projection_parity=" .. totals.parity)
    print("PASS canonical target changes invalidate discovery and equivalent aliases retain reuse")
    print("PASS Tracker_HUD C++ Scope Member target cache smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL C++ Scope Member target cache smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
