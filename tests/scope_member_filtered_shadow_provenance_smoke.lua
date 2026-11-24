-- Checkpoint 247: intersect lexical-depth, range and cursor projections
-- without changing the normalized declaration or historical relationships.
-- The fixture mirrors checkpoint 246, but independently pins each view.
local source = {
    "int index = 0;",                                   -- 1
    "void example(void) {",                             -- 2
    "    for (int index = 1; index < 2; ++index) {",     -- 3
    "        {",                                        -- 4
    "            int index = 2;",                       -- 5
    "            consume(index);",                      -- 6
    "        }",                                        -- 7
    "    }",                                            -- 8
    "    consume(0);",                                  -- 9
    "    consume(0);",                                  -- 10
    "}",                                                -- 11
}

local function make_adapter(c, schema, binding)
    local adapter = vim.deepcopy(c)
    local mutability = binding and "mutable" or nil
    adapter.scope_members = {
        symbols = {
            schema.named("init_declarator", "declarator", "variable", {
                fallback_node_type = "identifier",
                constraints = { parent_path = { "declaration", "for_statement" } },
                binding_mutability = mutability,
                visibility_range = "structural_scope",
            }),
            schema.named("init_declarator", "declarator", "variable", {
                fallback_node_type = "identifier",
                exclusions = { parent_path = { "declaration", "for_statement" } },
                binding_mutability = mutability,
            }),
        },
    }
    return adapter
end

local function inspect(members, expected, ids, binding, label)
    local by_line, used = {}, {}
    for _, member in ipairs(members) do
        local line = member.line
        assert(member.name == "index" and member.kind == "variable"
            and expected[line] and not by_line[line], label .. ": unexpected member")
        assert(type(member.id) == "string" and member.id ~= "" and not used[member.id],
            label .. ": invalid/duplicate identity")
        assert(not ids[line] or ids[line] == member.id, label .. ": identity changed")
        assert(member.is_binding == binding, label .. ": binding eligibility changed")
        assert(member.visibility_start_line == (line == 3 and 3 or nil)
            and member.visibility_end_line == (line == 3 and 8 or nil),
            label .. ": visibility changed at " .. line)
        ids[line], used[member.id], by_line[line] = member.id, true, member
    end
    for line in pairs(expected) do
        assert(by_line[line], label .. ": missing declaration " .. line)
    end
    return by_line
end

local function check_links(members, ids, binding, label, errors)
    local targets = { [3] = 1, [5] = 3 }
    for line, member in pairs(members) do
        local target = binding and targets[line] or nil
        local expected = target and ids[target] or nil
        if member.shadows_member_id ~= expected then
            errors[#errors + 1] = label .. " index@" .. line
                .. " expected " .. tostring(expected)
                .. ", observed " .. tostring(member.shadows_member_id)
        end
    end
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local schema = require("tracker_hud.adapters.scope_member_schema")
    local c = require("tracker_hud.adapters.c.init")
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = "c"
    local ok, parser = pcall(vim.treesitter.get_parser, buffer, "c")
    assert(ok and parser, "C parser unavailable: " .. tostring(parser))
    local tree = parser:parse()[1]
    assert(tree and not tree:root():has_error(), "C fixture grammar ERROR")
    local root = tree:root()
    local errors = {}
    for _, binding in ipairs({ false, true }) do
        local adapter = make_adapter(c, schema, binding)
        registry.clear()
        local registered, err = registry.register(adapter)
        assert(registered, tostring(err))
        local label = binding and "opt-in" or "non-binding"
        local ids = {}
        local discovery = collector.discover(buffer, root, adapter)
        local all = { [1] = true, [3] = true, [5] = true }
        local baseline = inspect(collector.select(discovery, {}), all, ids, binding,
            label .. " all-source shared")
        assert(baseline[1].scope_depth < baseline[3].scope_depth
            and baseline[3].scope_depth < baseline[5].scope_depth,
            "fixture requires nested lexical owners")
        assert(baseline[5].scope_start_line == 4 and baseline[5].scope_end_line == 7,
            "ordinary member lexical owner changed")
        check_links(baseline, ids, binding, label .. " all-source shared", errors)
        check_links(inspect(collector.collect(buffer, root, adapter, {}), all, ids,
            binding, label .. " all-source direct"), ids, binding,
            label .. " all-source direct", errors)
        -- Expected membership is computed independently of the collector.
        -- A missing target in a projection must never rewrite the source link.
        local cases = {
            { label = "inner depth", opts = { scope_depth = baseline[5].scope_depth },
                expected = { [5] = true } },
            { label = "loop depth", opts = { scope_depth = baseline[3].scope_depth },
                expected = { [3] = true } },
            { label = "module depth", opts = { scope_depth = baseline[1].scope_depth },
                expected = { [1] = true } },
            { label = "inner range", opts = { start_line = 5, end_line = 5 },
                expected = { [5] = true } },
            { label = "loop range", opts = { start_line = 3, end_line = 3 },
                expected = { [3] = true } },
            { label = "both nested", opts = { start_line = 3, end_line = 5 },
                expected = { [3] = true, [5] = true } },
            { label = "start only", opts = { start_line = 5 },
                expected = { [5] = true } },
            { label = "end only", opts = { end_line = 3 },
                expected = { [1] = true, [3] = true } },
            { label = "empty range", opts = { start_line = 6, end_line = 8 },
                expected = {} },
            { label = "depth plus range", opts = { start_line = 3, end_line = 5,
                scope_depth = baseline[5].scope_depth }, expected = { [5] = true } },
            { label = "before declaration", opts = { start_line = 5, end_line = 5,
                cursor_line = 4 }, expected = {} },
            { label = "on declaration", opts = { start_line = 5, end_line = 5,
                cursor_line = 5 }, expected = { [5] = true } },
            { label = "at lifetime endpoint", opts = { start_line = 3, end_line = 5,
                cursor_line = 8 }, expected = { [3] = true, [5] = true } },
            { label = "after expiry", opts = { start_line = 3, end_line = 5,
                cursor_line = 9 }, expected = { [5] = true } },
            { label = "expired loop only", opts = { scope_depth = baseline[3].scope_depth,
                start_line = 3, end_line = 5, cursor_line = 9 }, expected = {} },
            { label = "historic inner only", opts = { scope_depth = baseline[5].scope_depth,
                start_line = 3, end_line = 5, cursor_line = 9 }, expected = { [5] = true } },
        }
        for _, case in ipairs(cases) do
            local at = label .. " " .. case.label
            local selected = inspect(collector.select(discovery, case.opts),
                case.expected, ids, binding, at .. " shared")
            local direct = inspect(collector.collect(buffer, root, adapter, case.opts),
                case.expected, ids, binding, at .. " direct")
            check_links(selected, ids, binding, at .. " shared", errors)
            check_links(direct, ids, binding, at .. " direct", errors)
            for line, member in pairs(selected) do
                assert(vim.deep_equal(member, direct[line]),
                    at .. ": direct/shared record differs at " .. line)
                assert(vim.deep_equal(member, baseline[line]),
                    at .. ": projection changed source record at " .. line)
            end
        end
        local repeated = inspect(collector.select(discovery, {}), all, ids, binding,
            label .. " repeated all-source")
        check_links(repeated, ids, binding, label .. " repeated all-source", errors)
        print("PASS " .. label .. " range/depth/cursor intersection and source record parity")
    end
    vim.api.nvim_buf_delete(buffer, { force = true })
    assert(#errors == 0, "filtered shadow provenance mismatch: " .. table.concat(errors, "; "))
    print("PASS range and lexical depth filters preserve absent shadow targets")
    print("PASS mixed filters preserve lifetime boundaries and all-source links")
    print("PASS Tracker_HUD filtered shadow provenance smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL filtered shadow provenance smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
