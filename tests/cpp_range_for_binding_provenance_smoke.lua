-- Checkpoint 251: ordinary C++ range-for binding provenance.
-- The header's explicit visibility range is source evidence, not runtime state.
-- Preserve the structured-binding gate and the staged initializer isolation.
local ranges = { [5] = 10, [6] = 8, [11] = 13 }
local cases = {
    { standard = "cpp17", range = true, structured = true },
    { standard = "cpp98" },
    { standard = "cpp03" },
    { standard = "cpp11", range = true },
    { standard = "cpp14", range = true },
    { standard = "cpp20", range = true, structured = true },
    { standard = "cpp23", range = true, structured = true },
    { standard = "cpp03", config = "cpp23", directive = "// standard=03;" },
    { standard = "cpp11", config = "cpp98", directive = "// standard=11;", range = true },
}

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local cpp = require("tracker_hud.adapters.cpp.init")
    registry.clear()
    local ok, err = registry.register(cpp)
    assert(ok, tostring(err))
    local missing_binding, wrong_links, errors = 0, 0, {}
    local function record(message)
        if #errors < 16 then errors[#errors + 1] = message end
    end
    for index, case in ipairs(cases) do
        local buffer = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
            case.directive or "// ordinary range-for provenance", -- 1
            "auto [item, companion] = make_pair();",               -- 2
            "void example() {",                                    -- 3
            "    int ordinary = 7;",                               -- 4
            "    for (int item : items) {",                        -- 5
            "        for (int item : items) {",                    -- 6
            "            consume(item);",                          -- 7
            "        }",                                           -- 8
            "        consume(item);",                              -- 9
            "    }",                                               -- 10
            "    for (int item : items) {",                        -- 11
            "        consume(item);",                              -- 12
            "    }",                                               -- 13
            "}",                                                   -- 14
        })
        vim.bo[buffer].filetype = "cpp"
        local parser_ok, parser = pcall(vim.treesitter.get_parser, buffer, "cpp")
        assert(parser_ok and parser, "C++ parser unavailable: " .. tostring(parser))
        local tree = parser:parse()[1]
        assert(tree and not tree:root():has_error(), "fixture grammar ERROR")
        local root = tree:root()
        local seen = {}
        local function inspect(node)
            if node:type() == "for_range_loop" then
                local row = node:range()
                local line = row + 1
                local declarator = node:field("declarator")[1]
                assert(ranges[line] and not seen[line] and declarator
                    and declarator:type() == "identifier"
                    and vim.treesitter.get_node_text(declarator, buffer) == "item",
                    "ordinary range-for grammar drift")
                seen[line] = true
            end
            for child in node:iter_children() do inspect(child) end
        end
        inspect(root)
        assert(vim.tbl_count(seen) == 3, "missing range-for grammar nodes")
        local config = index == 1 and {} or { targets = { standard = case.config or case.standard } }
        local configured, config_err = registry.configure_adapter_for_buffer("cpp", buffer, config)
        assert(configured, tostring(config_err))
        assert(cpp.active_targets.standard == case.standard, "standard precedence mismatch")
        local discovery = collector.discover(buffer, root, cpp)
        local ids = {}
        local function check(members, cursor, label)
            local found, used, controls = {}, {}, {}
            for _, member in ipairs(members) do
                local name, line = member.name, member.line
                if name == "item" and member.kind == "loop_variable" then
                    assert(case.range and ranges[line] and not found[line],
                        label .. ": unavailable, unexpected or duplicate range binding")
                    assert(type(member.id) == "string" and member.id ~= ""
                        and not used[member.id], label .. ": collapsed identity")
                    assert(not ids[line] or ids[line] == member.id, label .. ": unstable identity")
                    ids[line], found[line], used[member.id] = member.id, member, true
                    assert(member.visibility_start_line == line
                        and member.visibility_end_line == ranges[line], label .. ": lifetime drift")
                    if member.is_binding ~= true then
                        missing_binding = missing_binding + 1
                        record(label .. ": missing binding at " .. line)
                    end
                elseif member.kind == "variable" and (name == "item" or name == "companion") then
                    assert(case.structured and line == 2 and not controls[name]
                        and member.is_binding == true and member.shadows_member_id == nil,
                        label .. ": structured binding control drift")
                    assert(type(member.id) == "string" and member.id ~= ""
                        and not used[member.id], label .. ": structured identity drift")
                    if name == "item" then
                        assert(not ids[2] or ids[2] == member.id, label .. ": unstable global identity")
                        ids[2] = member.id
                    end
                    controls[name], used[member.id] = member, true
                elseif name == "ordinary" and member.kind == "variable" then
                    assert(line == 4 and not controls.ordinary and member.is_binding ~= true
                        and member.shadows_member_id == nil, label .. ": initializer policy drift")
                    controls.ordinary = member
                elseif member.kind == "symbol" then
                    assert(member.is_binding ~= true and member.shadows_member_id == nil,
                        label .. ": generic summary became binding")
                end
            end
            for _, name in ipairs({ "item", "companion" }) do
                assert((controls[name] ~= nil) == (case.structured == true and
                    (not cursor or cursor >= 2)), label .. ": structured control membership")
            end
            assert((controls.ordinary ~= nil) == (not cursor or cursor >= 4),
                label .. ": ordinary initializer membership")
            for _, line in ipairs({ 5, 6, 11 }) do
                local expected = case.range == true and
                    (not cursor or (line <= cursor and cursor <= ranges[line]))
                assert((found[line] ~= nil) == expected, label .. ": membership at " .. line)
                if found[line] then
                    local target_line = line == 6 and 5 or (case.structured and 2 or nil)
                    local target = target_line and ids[target_line] or nil
                    if target_line then assert(target, label .. ": historical target missing") end
                    if found[line].shadows_member_id ~= target then
                        wrong_links = wrong_links + 1
                        record(label .. ": wrong shadow target at " .. line)
                    end
                end
            end
            return found, controls
        end
        local label = case.standard .. " case " .. index
        local all, controls = check(collector.select(discovery, {}), nil, label .. " all shared")
        check(collector.collect(buffer, root, cpp, {}), nil, label .. " all direct")
        if case.range then
            assert(all[6].scope_depth > all[5].scope_depth
                and all[5].scope_depth == all[11].scope_depth
                and all[5].scope_start_line == all[11].scope_start_line
                and all[5].scope_end_line == all[11].scope_end_line,
                label .. ": nested/sibling lexical ownership drift")
            if case.structured then
                assert(all[5].scope_depth > controls.item.scope_depth,
                    label .. ": global lexical owner drift")
            end
        end
        for cursor = 1, 14 do
            local opts = { cursor_line = cursor }
            check(collector.select(discovery, opts), cursor, label .. " shared@" .. cursor)
            check(collector.collect(buffer, root, cpp, opts), cursor, label .. " direct@" .. cursor)
        end
        vim.api.nvim_buf_delete(buffer, { force = true })
    end
    print("PASS ordinary range-for identities, standard gating, lifetimes and staged controls")
    local count, wrong_policy = 0, 0
    for _, spec in ipairs(cpp.scope_members.loops) do
        if spec.syntax.node_type == "for_range_loop" and spec.member.kind == "loop_variable" then
            count = count + 1
            assert(spec.member.language_term == "range-for variable", "range-for role drift")
            if not spec.member.mutability or spec.member.mutability.binding ~= "unknown" then
                wrong_policy = wrong_policy + 1
                record("ordinary range-for rule must declare unknown binding mutability")
            end
        end
    end
    assert(count == 1, "expected exactly one ordinary range-for rule")
    assert(missing_binding == 0 and wrong_links == 0 and wrong_policy == 0,
        "ordinary range-for provenance mismatch: missing_binding=" .. missing_binding
        .. " wrong_links=" .. wrong_links .. " wrong_policy=" .. wrong_policy
        .. "; " .. table.concat(errors, "; "))
    print("PASS live nested range binding and expired sibling fallback")
    print("PASS Tracker_HUD C++ ordinary range-for provenance smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL C++ ordinary range-for provenance smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
