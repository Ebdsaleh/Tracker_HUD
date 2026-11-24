-- Checkpoint 250: opt-in provenance for the two C++ structured-binding
-- identifier roles. Ordinary initializer control follows the explicit staged/final policy.
-- This tests source relationships, not runtime values or complete lookup.
local declaration_lines = { 2, 5, 7, 11, 15 }
local ranges = { [5] = 10, [11] = 13 }
local targets = { [5] = 2, [7] = 5, [11] = 2, [15] = 2 }
local names = { "alpha", "beta" }

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local cpp = require("tracker_hud.adapters.cpp.init")
    registry.clear()
    local ok, err = registry.register(cpp)
    assert(ok, tostring(err))
    -- Checkpoint 252 deliberately transitions the inherited initializer policy.
    -- Preserve the distinct-name control; the new gate requires final opt-in.
    local ordinary_rule, ordinary_count = nil, 0
    for _, spec in ipairs(cpp.scope_members.symbols) do
        if spec.syntax.node_type == "init_declarator" and spec.member.kind == "variable"
            and spec.member.language_term == "initialized variable" then
            ordinary_rule, ordinary_count = spec, ordinary_count + 1
        end
    end
    assert(ordinary_count == 1, "missing or duplicate ordinary initializer rule")
    local ordinary_policy = ordinary_rule.member.mutability
    assert(ordinary_policy == nil or ordinary_policy.binding == "unknown",
        "unsupported ordinary initializer policy")
    local ordinary_binding = ordinary_policy ~= nil
    local cases = {
        { standard = "cpp17", available = true },
        { standard = "cpp98" },
        { standard = "cpp03" },
        { standard = "cpp11" },
        { standard = "cpp14" },
        { standard = "cpp20", available = true },
        { standard = "cpp23", available = true },
        { standard = "cpp14", directive = "// standard=14;", config = "cpp23" },
        { standard = "cpp17", directive = "// standard=17;", config = "cpp14", available = true },
    }
    local missing_binding, wrong_links, errors = 0, 0, {}
    local function record(message)
        if #errors < 16 then errors[#errors + 1] = message end
    end
    for index, case in ipairs(cases) do
        local buffer = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
            case.directive or "// structured binding provenance", -- 1
            "auto [alpha, beta] = make_pair();",                   -- 2
            "void example() {",                                  -- 3
            "    int ordinary = 7;",                               -- 4
            "    for (auto [alpha, beta] : pairs) {",               -- 5
            "        {",                                          -- 6
            "            auto [alpha, beta] = make_pair();",       -- 7
            "            consume(alpha, beta);",                   -- 8
            "        }",                                          -- 9
            "    }",                                              -- 10
            "    for (auto [alpha, beta] : pairs) {",               -- 11
            "        consume(alpha, beta);",                       -- 12
            "    }",                                              -- 13
            "    {",                                              -- 14
            "        auto [alpha, beta] = make_pair();",           -- 15
            "        consume(alpha, beta);",                       -- 16
            "    }",                                              -- 17
            "}",                                                  -- 18
        })
        vim.bo[buffer].filetype = "cpp"
        local parser_ok, parser = pcall(vim.treesitter.get_parser, buffer, "cpp")
        assert(parser_ok and parser, "C++ parser unavailable: " .. tostring(parser))
        local tree = parser:parse()[1]
        assert(tree and not tree:root():has_error(), "fixture grammar ERROR")
        local root = tree:root()
        local seen_nodes = {}
        local function inspect(node)
            if node:type() == "structured_binding_declarator" then
                local row = node:range()
                local line = row + 1
                assert(vim.tbl_contains(declaration_lines, line) and not seen_nodes[line],
                    "unexpected structured declaration grammar")
                assert(node:parent():type() == (ranges[line] and "for_range_loop" or "init_declarator")
                    and node:named_child_count() == 2
                    and node:named_child(0):type() == "identifier"
                    and node:named_child(1):type() == "identifier", "structured identifier grammar drift")
                seen_nodes[line] = true
            end
            for child in node:iter_children() do inspect(child) end
        end
        inspect(root)
        assert(vim.tbl_count(seen_nodes) == #declaration_lines, "missing structured declarations")
        local config = index == 1 and {} or { targets = { standard = case.config or case.standard } }
        local configured, config_err = registry.configure_adapter_for_buffer("cpp", buffer, config)
        assert(configured, tostring(config_err))
        assert(cpp.active_targets.standard == case.standard, "standard precedence mismatch")
        local discovery = collector.discover(buffer, root, cpp)
        local ids = {}
        local function key(line, name) return line .. ":" .. name end
        local function check(members, cursor, label)
            local found, used, ordinary = {}, {}, 0
            for _, member in ipairs(members) do
                local name, line = member.name, member.line
                if type(name) == "string" and (name:find("alpha", 1, true)
                    or name:find("beta", 1, true)) then
                    assert(case.available and vim.tbl_contains(names, name)
                        and vim.tbl_contains(declaration_lines, line),
                        label .. ": unavailable/composite/unexpected structured member " .. name)
                    local k = key(line, name)
                    assert(not found[k] and member.kind == (ranges[line] and "loop_variable" or "variable"),
                        label .. ": duplicate or wrong role " .. k)
                    assert(type(member.id) == "string" and member.id ~= "" and not used[member.id],
                        label .. ": missing or collapsed identity " .. k)
                    assert(not ids[k] or ids[k] == member.id, label .. ": unstable identity " .. k)
                    ids[k], found[k], used[member.id] = member.id, member, true
                    assert(member.visibility_start_line == (ranges[line] and line or nil)
                        and member.visibility_end_line == ranges[line], label .. ": lifetime drift " .. k)
                    if member.is_binding ~= true then
                        missing_binding = missing_binding + 1
                        record(label .. ": missing binding " .. k)
                    end
                elseif name == "ordinary" and member.kind == "variable" then
                    ordinary = ordinary + 1
                    assert((member.is_binding == true) == ordinary_binding and member.shadows_member_id == nil,
                        label .. ": inherited ordinary initializer policy changed")
                elseif member.kind == "symbol" then
                    assert(member.is_binding ~= true and member.shadows_member_id == nil,
                        label .. ": generic summary became a binding")
                end
            end
            assert(ordinary == ((not cursor or cursor >= 4) and 1 or 0),
                label .. ": ordinary initializer membership changed")
            for _, line in ipairs(declaration_lines) do
                for _, name in ipairs(names) do
                    local k = key(line, name)
                    local expected = case.available and (not cursor or
                        (line <= cursor and (not ranges[line] or cursor <= ranges[line])))
                    assert((found[k] ~= nil) == (expected == true), label .. ": membership mismatch " .. k)
                    if found[k] then
                        local target = targets[line] and ids[key(targets[line], name)] or nil
                        if targets[line] then assert(target, "missing historical target identity") end
                        if found[k].shadows_member_id ~= target then
                            wrong_links = wrong_links + 1
                            record(label .. ": incorrect shadow target " .. k)
                        end
                    end
                end
            end
            return found
        end
        local label = case.standard .. " case " .. index
        local all = check(collector.select(discovery, {}), nil, label .. " all shared")
        check(collector.collect(buffer, root, cpp, {}), nil, label .. " all direct")
        if case.available then
            for _, name in ipairs(names) do
                local global, first, nested, sibling, after = all[key(2, name)],
                    all[key(5, name)], all[key(7, name)], all[key(11, name)], all[key(15, name)]
                assert(first.scope_depth > global.scope_depth
                    and nested.scope_depth > first.scope_depth and after.scope_depth > first.scope_depth,
                    label .. ": lexical nesting missing")
                assert(first.scope_depth == sibling.scope_depth
                    and first.scope_start_line == sibling.scope_start_line
                    and first.scope_end_line == sibling.scope_end_line
                    and first.scope_start_column == sibling.scope_start_column
                    and first.scope_end_column == sibling.scope_end_column,
                    label .. ": sibling header owner mismatch")
            end
        end
        for cursor = 1, 18 do
            local opts = { cursor_line = cursor }
            check(collector.select(discovery, opts), cursor, label .. " shared@" .. cursor)
            check(collector.collect(buffer, root, cpp, opts), cursor, label .. " direct@" .. cursor)
        end
        vim.api.nvim_buf_delete(buffer, { force = true })
    end
    print("PASS structured source identities, standard gating, lifetimes and ordinary initializer isolation")
    local count, wrong_policy = 0, 0
    for _, spec in ipairs(cpp.scope_members.symbols) do
        local term = spec.member.language_term
        if spec.syntax.node_type == "identifier" and
            (term == "structured binding" or term == "structured range-for binding") then
            count = count + 1
            if not spec.member.mutability or spec.member.mutability.binding ~= "unknown" then
                wrong_policy = wrong_policy + 1
                record("structured rule must declare unknown binding mutability: " .. term)
            end
        end
    end
    assert(count == 2, "expected two structured identifier rules")
    assert(missing_binding == 0 and wrong_links == 0 and wrong_policy == 0,
        "structured binding provenance mismatch: missing_binding=" .. missing_binding
        .. " wrong_links=" .. wrong_links .. " wrong_policy=" .. wrong_policy
        .. "; " .. table.concat(errors, "; "))
    print("PASS separate same-name shadow links and expired-header fallback")
    print("PASS Tracker_HUD C++ structured binding provenance smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL C++ structured binding provenance smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
