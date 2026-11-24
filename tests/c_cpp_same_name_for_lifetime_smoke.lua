-- Checkpoint 244: same-name loop declarations must retain independent source
-- identities and visibility. This is a discovery/selection test, not a name
-- lookup engine: during overlap both declarations are retained. Explicit
-- shadows_member_id provenance is a separate binding-contract concern.
local ranges = { [3] = 9, [5] = 7, [11] = 13 }

local function check_members(members, expected, ids, label)
    local counts = {}
    local found_ids = {}
    for _, member in ipairs(members or {}) do
        if member.name == "index" and member.kind == "variable" then
            local line = member.line
            assert(expected[line], label .. ": unexpected declaration at " .. tostring(line))
            assert(member.visibility_start_line == line
                and member.visibility_end_line == ranges[line],
                label .. ": incorrect lifetime at " .. line
                .. "; observed " .. tostring(member.visibility_start_line)
                .. "-" .. tostring(member.visibility_end_line))
            assert(type(member.id) == "string" and member.id ~= "",
                label .. ": missing declaration identity")
            assert(not found_ids[member.id], label .. ": collapsed declaration identity")
            found_ids[member.id] = true
            if ids[line] then
                assert(ids[line] == member.id, label .. ": unstable identity at " .. line)
            else
                ids[line] = member.id
            end
            counts[line] = (counts[line] or 0) + 1
        end
    end
    for line in pairs(ranges) do
        assert((counts[line] or 0) == (expected[line] and 1 or 0),
            label .. ": incorrect declaration count at " .. line
            .. ": " .. tostring(counts[line] or 0))
    end
end

local function run_case(adapter, collector)
    local language = adapter.name
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
        "void example(void) {",                               -- 1
        "    consume(0);",                                    -- 2
        "    for (int index = 0; index < 2; ++index) {",        -- 3
        "        consume(index);",                            -- 4
        "        for (int index = 1; index < 3; ++index) {",    -- 5
        "            consume(index);",                        -- 6
        "        }",                                          -- 7
        "        consume(index);",                            -- 8
        "    }",                                              -- 9
        "    consume(0);",                                    -- 10
        "    for (int index = 2; index < 4; ++index) {",        -- 11
        "        consume(index);",                            -- 12
        "    }",                                              -- 13
        "    consume(0);",                                    -- 14
        "}",                                                  -- 15
    })
    vim.bo[buffer].filetype = language
    local ok, parser = pcall(vim.treesitter.get_parser, buffer, language)
    assert(ok and parser, language .. ": parser unavailable: " .. tostring(parser))
    local tree = parser:parse()[1]
    assert(tree and not tree:root():has_error(), language .. ": grammar ERROR")
    local root = tree:root()

    local grammar_count = 0
    local function inspect(node)
        if node:type() == "for_statement" then
            local start_row, _, end_row = node:range()
            local line = start_row + 1
            assert(ranges[line] == end_row + 1, language .. ": unexpected loop range")
            local declaration = node:field("initializer")[1]
            assert(declaration and declaration:type() == "declaration",
                language .. ": missing initializer declaration")
            grammar_count = grammar_count + 1
        end
        for child in node:iter_children() do inspect(child) end
    end
    inspect(root)
    assert(grammar_count == 3, language .. ": expected three loops")

    local discovery = collector.discover(buffer, root, adapter)
    local ids = {}
    local all = { [3] = true, [5] = true, [11] = true }
    check_members(collector.select(discovery, {}), all, ids, language .. " all-source shared")
    check_members(collector.collect(buffer, root, adapter, {}), all, ids,
        language .. " all-source direct")
    assert(ids[3] ~= ids[5] and ids[3] ~= ids[11] and ids[5] ~= ids[11],
        language .. ": distinct source identities required")

    for line = 2, 14 do
        local expected = {}
        for first, last in pairs(ranges) do
            expected[first] = line >= first and line <= last
        end
        local opts = { cursor_line = line }
        local label = language .. " line " .. line
        check_members(collector.collect(buffer, root, adapter, opts), expected, ids,
            label .. " direct")
        check_members(collector.select(discovery, opts), expected, ids,
            label .. " shared")
    end

    vim.api.nvim_buf_delete(buffer, { force = true })
    print("PASS " .. language .. " same-name initializer identities and independent visibility")
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local c = require("tracker_hud.adapters.c.init")
    local cpp = require("tracker_hud.adapters.cpp.init")
    registry.clear()
    for _, adapter in ipairs({ c, cpp }) do
        local ok, err = registry.register(adapter)
        assert(ok, tostring(err))
        run_case(adapter, collector)
    end
    print("PASS direct/shared same-name declaration identity agreement")
    print("PASS Tracker_HUD C/C++ same-name for lifetime smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL C/C++ same-name for lifetime smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
