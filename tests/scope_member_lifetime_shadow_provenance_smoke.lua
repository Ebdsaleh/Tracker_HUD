-- Checkpoint 245: shared shadow provenance must respect explicit visibility
-- at the declaration site. A test-local C-shaped adapter opts in to the
-- existing binding contract; production language adapters remain unchanged.
local source = {
    "int index = 0;",                                      -- 1
    "void example(void) {",                                -- 2
    "    for (int index = 1; index < 2; ++index) {",        -- 3
    "        for (int index = 2; index < 3; ++index) {",    -- 4
    "            consume(index);",                         -- 5
    "        }",                                           -- 6
    "    }",                                               -- 7
    "    for (int index = 3; index < 4; ++index) {",        -- 8
    "        for (int index = 4; index < 5; ++index) {",    -- 9
    "            consume(index);",                         -- 10
    "        }",                                           -- 11
    "    }",                                               -- 12
    "    {",                                               -- 13
    "        int index = 5;",                              -- 14
    "        consume(index);",                             -- 15
    "    }",                                               -- 16
    "}",                                                   -- 17
}
local declaration_lines = { 1, 3, 4, 8, 9, 14 }
local ranges = { [3] = 7, [4] = 6, [8] = 12, [9] = 11 }
local targets = { [3] = 1, [4] = 3, [8] = 1, [9] = 8, [14] = 1 }

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

local function check_members(members, cursor, binding, ids, label)
    local by_line, used_ids = {}, {}
    local expected = {}
    for _, line in ipairs(declaration_lines) do
        if not cursor or (line <= cursor
            and (not ranges[line] or cursor <= ranges[line])) then
            expected[line] = true
        end
    end
    for _, member in ipairs(members or {}) do
        assert(member.kind == "variable" and member.name == "index",
            label .. ": unexpected member")
        local line = member.line
        assert(expected[line] and not by_line[line],
            label .. ": duplicate/unexpected declaration " .. tostring(line))
        assert(member.is_binding == binding, label .. ": binding opt-in mismatch")
        assert(member.visibility_start_line == (ranges[line] and line or nil)
            and member.visibility_end_line == ranges[line],
            label .. ": incorrect visibility at " .. line)
        assert(type(member.id) == "string" and member.id ~= ""
            and not used_ids[member.id], label .. ": missing/duplicate identity")
        assert(not ids[line] or ids[line] == member.id,
            label .. ": unstable identity at " .. line)
        ids[line], used_ids[member.id], by_line[line] = member.id, true, member
    end
    for line in pairs(expected) do
        assert(by_line[line], label .. ": missing declaration " .. line)
    end
    return by_line
end

local function same_owner(a, b)
    return a.scope_depth == b.scope_depth
        and a.scope_start_line == b.scope_start_line
        and a.scope_end_line == b.scope_end_line
        and a.scope_start_column == b.scope_start_column
        and a.scope_end_column == b.scope_end_column
end

local function check_links(by_line, ids, binding, label, errors)
    for _, line in ipairs(declaration_lines) do
        local member = by_line[line]
        if member then
            local target = binding and targets[line] or nil
            local expected = target and ids[target] or nil
            if member.shadows_member_id ~= expected then
                errors[#errors + 1] = label .. " index@" .. line
                    .. " expected target " .. tostring(target or "none")
                    .. " (" .. tostring(expected) .. "), observed "
                    .. tostring(member.shadows_member_id)
            end
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
        assert(registered, "test adapter contract: " .. tostring(err))
        local ids = {}
        local label = binding and "opt-in" or "non-binding"
        local discovery = collector.discover(buffer, root, adapter)
        local shared = check_members(collector.select(discovery, {}), nil,
            binding, ids, label .. " all-source shared")
        local direct = check_members(collector.collect(buffer, root, adapter, {}),
            nil, binding, ids, label .. " all-source direct")
        assert(same_owner(shared[3], shared[8]),
            "fixture must have disjoint lifetimes in the same lexical owner")
        assert(shared[4].scope_depth > shared[3].scope_depth
            and shared[9].scope_depth > shared[8].scope_depth
            and shared[14].scope_depth > shared[8].scope_depth,
            "fixture nested lexical owners missing")
        assert(shared[1].scope_depth < shared[3].scope_depth,
            "fixture module fallback owner missing")
        check_links(shared, ids, binding, label .. " all-source shared", errors)
        check_links(direct, ids, binding, label .. " all-source direct", errors)
        -- Check only at declaration sites for direct/shared parity. This does
        -- not define how filtered views retain historic links after expiry.
        for _, cursor in ipairs(declaration_lines) do
            local opts = { cursor_line = cursor }
            local label_at = label .. " declaration line " .. cursor
            local selected = check_members(collector.select(discovery, opts),
                cursor, binding, ids, label_at .. " shared")
            local collected = check_members(collector.collect(buffer, root, adapter, opts),
                cursor, binding, ids, label_at .. " direct")
            local target = binding and targets[cursor] or nil
            local expected = target and ids[target] or nil
            for _, entry in ipairs({
                { name = "shared", member = selected[cursor] },
                { name = "direct", member = collected[cursor] },
            }) do
                if entry.member.shadows_member_id ~= expected then
                    errors[#errors + 1] = label_at .. " " .. entry.name
                        .. " expected target " .. tostring(target or "none")
                        .. ", observed " .. tostring(entry.member.shadows_member_id)
                end
            end
        end
        print("PASS " .. label .. " source identities, ownership and independent visibility")
    end
    vim.api.nvim_buf_delete(buffer, { force = true })
    assert(#errors == 0, "lifetime-aware shadow provenance mismatch: "
        .. table.concat(errors, "; "))
    print("PASS live enclosing binding wins over expired sibling")
    print("PASS expired frame candidates permit outer-owner fallback")
    print("PASS Tracker_HUD shared lifetime-aware shadow provenance smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL shared lifetime-aware shadow provenance smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
