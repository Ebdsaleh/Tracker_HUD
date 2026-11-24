-- Checkpoint 249: guard the staged C initializer provenance migration.
-- Checkpoint 252: retain inheritance isolation through the deliberate migration.
-- Both C++ roles must use one consistent staged or final policy; gate 252
-- independently requires final eligibility and provenance.
local source = {
    "int index = 0;",
    "void example(void) {",
    "    for (int index = 1; index < 2; ++index) {",
    "        int body = index;",
    "        consume(body);",
    "    }",
    "    {",
    "        const int index = 3;",
    "        consume(index);",
    "    }",
    "}",
}
local expected_lines = { [1] = "index", [3] = "index",
    [4] = "body", [8] = "index" }
local function initializer_rules(adapter)
    local rules = {}
    for _, spec in ipairs(adapter.scope_members.symbols) do
        if spec.syntax.node_type == "init_declarator"
            and spec.member.kind == "variable" then
            local term = spec.member.language_term
            assert(not rules[term], adapter.name .. ": duplicate initializer role")
            rules[term] = spec
        end
    end
    assert(vim.tbl_count(rules) == 2 and rules["for initialized variable"]
        and rules["initialized variable"], adapter.name .. ": missing initializer roles")
    return rules
end

local function check_policy(c, cpp)
    local c_rules, cpp_rules = initializer_rules(c), initializer_rules(cpp)
    local cpp_opted_in = cpp_rules["initialized variable"].member.mutability ~= nil
    for term, c_rule in pairs(c_rules) do
        local cpp_rule = cpp_rules[term]
        assert(c_rule ~= cpp_rule and c_rule.member ~= cpp_rule.member
            and c_rule.syntax ~= cpp_rule.syntax, "shared mutable adapter rule: " .. term)
        assert(c_rule.member.mutability and c_rule.member.mutability.binding == "unknown",
            "C must retain unknown binding mutability: " .. term)
        assert((cpp_opted_in and vim.deep_equal(cpp_rule.member.mutability, c_rule.member.mutability))
            or (not cpp_opted_in and cpp_rule.member.mutability == nil),
            "C++ mixed or unsupported initializer policy: " .. term)
        local syntax = vim.deepcopy(cpp_rule.syntax)
        assert(syntax.exclusions and syntax.exclusions.field_paths
            and vim.deep_equal(syntax.exclusions.field_paths, {
                { fields = { "declarator" }, node_types = { "structured_binding_declarator" } },
            }), "C++ lost structured binding exclusion: " .. term)
        syntax.exclusions.field_paths = nil
        if next(syntax.exclusions) == nil then syntax.exclusions = nil end
        assert(vim.deep_equal(syntax, c_rule.syntax),
            "inherited initializer syntax/lifetime role drift: " .. term)
        local member = vim.deepcopy(c_rule.member)
        if not cpp_opted_in then member.mutability = nil end
        assert(vim.deep_equal(member, cpp_rule.member),
            "unexpected initializer member policy drift: " .. term)
    end
    return cpp_opted_in
end

local function run_case(adapter, collector, cpp_opted_in)
    local expects_binding = adapter.name == "c" or cpp_opted_in
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = adapter.name
    local ok, parser = pcall(vim.treesitter.get_parser, buffer, adapter.name)
    assert(ok and parser, adapter.name .. ": parser unavailable: " .. tostring(parser))
    local tree = parser:parse()[1]
    assert(tree and not tree:root():has_error(), adapter.name .. ": fixture grammar ERROR")
    local root = tree:root()
    local discovery = collector.discover(buffer, root, adapter)
    local ids = {}
    local function check(members, cursor, label)
        local found, used = {}, {}
        for _, member in ipairs(members) do
            if member.kind == "variable" then
                local line = member.line
                assert(expected_lines[line] == member.name and not found[line],
                    label .. ": unexpected or duplicate variable")
                assert(type(member.id) == "string" and member.id ~= "" and not used[member.id],
                    label .. ": missing or duplicate identity")
                assert(not ids[line] or ids[line] == member.id, label .. ": identity drift")
                ids[line], found[line], used[member.id] = member.id, member, true
                assert((member.is_binding == true) == expects_binding,
                    label .. ": incorrect binding eligibility at " .. line)
                assert(member.visibility_start_line == (line == 3 and 3 or nil)
                    and member.visibility_end_line == (line == 3 and 6 or nil),
                    label .. ": incorrect explicit lifetime")
            elseif member.kind == "symbol" then
                assert(member.is_binding ~= true and member.shadows_member_id == nil,
                    label .. ": generic symbol became a binding")
            end
        end
        for line in pairs(expected_lines) do
            local expected = cursor == nil or (line <= cursor and (line ~= 3 or cursor <= 6))
            assert((found[line] ~= nil) == expected, label .. ": membership mismatch at " .. line)
            if found[line] then
                local target = expects_binding and (line == 3 or line == 8) and ids[1] or nil
                assert(found[line].shadows_member_id == target,
                    label .. ": incorrect shadow provenance at " .. line)
            end
        end
        return found
    end
    local all = check(collector.select(discovery, {}), nil, adapter.name .. " all shared")
    assert(all[3].scope_depth > all[1].scope_depth and all[8].scope_depth > all[3].scope_depth,
        adapter.name .. ": expected nested lexical owners")
    check(collector.collect(buffer, root, adapter, {}), nil, adapter.name .. " all direct")
    for cursor = 1, #source do
        local opts = { cursor_line = cursor }
        local label = adapter.name .. " cursor " .. cursor
        check(collector.collect(buffer, root, adapter, opts), cursor, label .. " direct")
        check(collector.select(discovery, opts), cursor, label .. " shared")
    end
    vim.api.nvim_buf_delete(buffer, { force = true })
    print("PASS " .. adapter.name .. " initializer eligibility, identities and provenance")
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    -- Load C++ first to exercise its actual C adapter inheritance path.
    local cpp = require("tracker_hud.adapters.cpp.init")
    local c = require("tracker_hud.adapters.c.init")
    registry.clear()
    local cpp_opted_in = check_policy(c, cpp)
    for _, adapter in ipairs({ cpp, c }) do
        local ok, err = registry.register(adapter)
        assert(ok, tostring(err))
        run_case(adapter, collector, cpp_opted_in)
    end
    assert(check_policy(c, cpp) == cpp_opted_in, "initializer policy changed during registration")
    print("PASS inherited initializer policy isolation and structured binding exclusions")
    print("PASS Tracker_HUD C/C++ initialized binding isolation smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL C/C++ initialized binding isolation smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
