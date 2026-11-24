-- Checkpoint 252: production C++ initialized declarations participate in
-- shared source binding provenance without classifying const as mutable.
-- Generic declaration summaries remain non-binding; no runtime lookup.
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
    "        const int index = 5;",                              -- 14
    "        consume(index);",                             -- 15
    "    }",                                               -- 16
    "}",                                                   -- 17
}
local declaration_lines = { 1, 3, 4, 8, 9, 14 }
local ranges = { [3] = 7, [4] = 6, [8] = 12, [9] = 11 }
local targets = { [3] = 1, [4] = 3, [8] = 1, [9] = 8, [14] = 1 }

local function check_members(members, cursor, ids, label, errors)
    local by_line, used_ids = {}, {}
    local expected = {}
    for _, line in ipairs(declaration_lines) do
        if not cursor or (line <= cursor
            and (not ranges[line] or cursor <= ranges[line])) then
            expected[line] = true
        end
    end
    for _, member in ipairs(members or {}) do
        if member.kind == "variable" and member.name == "index" then
        local line = member.line
        assert(expected[line] and not by_line[line],
            label .. ": duplicate/unexpected declaration " .. tostring(line))
        if member.is_binding ~= true then
            errors[#errors + 1] = label .. ": missing binding eligibility at " .. line
        end
        assert(member.visibility_start_line == (ranges[line] and line or nil)
            and member.visibility_end_line == ranges[line],
            label .. ": incorrect visibility at " .. line)
        assert(type(member.id) == "string" and member.id ~= ""
            and not used_ids[member.id], label .. ": missing/duplicate identity")
        assert(not ids[line] or ids[line] == member.id,
            label .. ": unstable identity at " .. line)
        ids[line], used_ids[member.id], by_line[line] = member.id, true, member
        elseif member.kind == "symbol" then
            assert(member.is_binding ~= true and member.shadows_member_id == nil,
                label .. ": declaration summary must not participate in shadowing")
        end
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

local function check_links(by_line, ids, label, errors)
    for _, line in ipairs(declaration_lines) do
        local member = by_line[line]
        if member then
            local target = targets[line]
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

local function run_case(registry, collector, cpp, standard, config, errors)
    local prefix = standard .. " "
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = "cpp"
    local ok, parser = pcall(vim.treesitter.get_parser, buffer, "cpp")
    assert(ok and parser, "C++ parser unavailable: " .. tostring(parser))
    local tree = parser:parse()[1]
    assert(tree and not tree:root():has_error(), "C++ fixture grammar ERROR")
    local root = tree:root()
    local seen = {}
    local function inspect(node)
        if node:type() == "init_declarator" then
            local row = node:range()
            local line = row + 1
            local declarator = node:field("declarator")[1]
            assert(vim.tbl_contains(declaration_lines, line) and not seen[line]
                and declarator and declarator:type() == "identifier"
                and vim.treesitter.get_node_text(declarator, buffer) == "index",
                prefix .. "initializer grammar drift")
            seen[line] = true
        end
        for child in node:iter_children() do inspect(child) end
    end
    inspect(root)
    assert(vim.tbl_count(seen) == #declaration_lines, prefix .. "missing grammar declarations")
    local configured, err = registry.configure_adapter_for_buffer("cpp", buffer, config)
    assert(configured, tostring(err))
    assert(cpp.active_targets.standard == standard, prefix .. "standard selection mismatch")
    local ids = {}
    local discovery = collector.discover(buffer, root, cpp)
    local shared = check_members(collector.select(discovery, {}), nil, ids,
        prefix .. "all-source shared", errors)
    local direct = check_members(collector.collect(buffer, root, cpp, {}), nil, ids,
        prefix .. "all-source direct", errors)
    assert(same_owner(shared[3], shared[8]),
        "fixture must have disjoint lifetimes in the same lexical owner")
    assert(shared[4].scope_depth > shared[3].scope_depth
        and shared[9].scope_depth > shared[8].scope_depth
        and shared[14].scope_depth > shared[8].scope_depth,
        "nested lexical owners missing")
    assert(shared[1].scope_depth < shared[3].scope_depth,
        "module fallback owner missing")
    check_links(shared, ids, prefix .. "all-source shared", errors)
    check_links(direct, ids, prefix .. "all-source direct", errors)
    for cursor = 1, #source do
        local opts = { cursor_line = cursor }
        local label = prefix .. "cursor " .. cursor
        local selected = check_members(collector.select(discovery, opts),
            cursor, ids, label .. " shared", errors)
        local collected = check_members(collector.collect(buffer, root, cpp, opts),
            cursor, ids, label .. " direct", errors)
        check_links(selected, ids, label .. " shared", errors)
        check_links(collected, ids, label .. " direct", errors)
    end
    vim.api.nvim_buf_delete(buffer, { force = true })
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local cpp = require("tracker_hud.adapters.cpp.init")
    registry.clear()
    local registered, err = registry.register(cpp)
    assert(registered, "production C++ contract: " .. tostring(err))
    local errors = {}
    for i, standard in ipairs({ "cpp17", "cpp98", "cpp03", "cpp11", "cpp14", "cpp20", "cpp23" }) do
        run_case(registry, collector, cpp, standard,
            i == 1 and {} or { targets = { standard = standard } }, errors)
    end
    print("PASS production C++ source identities, standard selection, owners, lifetimes and non-binding summaries")
    -- Eligibility is not proof of mutability: the rules cover const and
    -- non-const initializers alike. Require conservative declaration policy.
    local count, terms = 0, {}
    for _, spec in ipairs(cpp.scope_members.symbols) do
        if spec.syntax.node_type == "init_declarator"
            and spec.member.kind == "variable" then
            count = count + 1
            local term = spec.member.language_term
            assert(not terms[term], "duplicate initializer role")
            terms[term] = true
            local mutability = spec.member.mutability
            if not mutability or mutability.binding ~= "unknown" then
                errors[#errors + 1] = "initialized variable rule must declare unknown binding mutability"
            end
        end
    end
    assert(count == 2 and terms["initialized variable"] and terms["for initialized variable"],
        "expected two complementary C++ initializer rules")
    local missing_binding, wrong_links, wrong_policy = 0, 0, 0
    for _, message in ipairs(errors) do
        if message:find("missing binding eligibility", 1, true) then
            missing_binding = missing_binding + 1
        elseif message:find("expected target", 1, true) then
            wrong_links = wrong_links + 1
        else
            wrong_policy = wrong_policy + 1
        end
    end
    assert(#errors == 0, "production C++ binding provenance mismatch: missing_binding="
        .. missing_binding .. " wrong_links=" .. wrong_links .. " wrong_policy=" .. wrong_policy
        .. "; " .. table.concat(errors, "; ", 1, math.min(#errors, 16)))
    print("PASS live enclosing binding wins over expired sibling")
    print("PASS expired frame candidates permit outer-owner fallback")
    print("PASS Tracker_HUD production C++ initialized binding provenance smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL production C++ initialized binding provenance smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
