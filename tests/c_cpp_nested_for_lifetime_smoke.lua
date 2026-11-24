-- Checkpoint 243: nested standard for statements must independently bound
-- their initializers. Test both C-family grammars and both collector paths.
local function collect_loops(node, result)
    if node:type() == "for_statement" then result[#result + 1] = node end
    for child in node:iter_children() do
        collect_loops(child, result)
    end
end

local function check_members(members, expected, label)
    local counts = {}
    local ranges = {
        outer_index = { 3, 10 },
        inner_index = { 5, 7 },
        sibling_index = { 12, 14 },
    }
    for _, member in ipairs(members or {}) do
        local range = ranges[member.name]
        if range and member.kind == "variable" then
            local name = member.name
            counts[name] = (counts[name] or 0) + 1
            assert(member.line == range[1]
                and member.visibility_start_line == range[1]
                and member.visibility_end_line == range[2],
                label .. ": incorrect lifetime for " .. name
                .. "; expected " .. range[1] .. "-" .. range[2]
                .. ", observed " .. tostring(member.visibility_start_line)
                .. "-" .. tostring(member.visibility_end_line))
        end
    end
    for name in pairs(ranges) do
        assert((counts[name] or 0) == (expected[name] and 1 or 0),
            label .. ": incorrect visible count for " .. name
            .. ": " .. tostring(counts[name] or 0))
    end
end

local function run_case(adapter, collector)
    local language = adapter.name
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
        "void example(void) {",                                      -- 1
        "    int before = 0;",                                       -- 2
        "    for (int outer_index = 0; outer_index < 2; ++outer_index) {", -- 3
        "        int body_value = outer_index;",                     -- 4
        "        for (int inner_index = 0; inner_index < 2; ++inner_index) {", -- 5
        "            consume(inner_index);",                        -- 6
        "        }",                                                 -- 7
        "        consume(outer_index);",                             -- 8
        "        consume(body_value);",                              -- 9
        "    }",                                                     -- 10
        "    consume(before);",                                      -- 11
        "    for (int sibling_index = 0; sibling_index < 2; ++sibling_index) {", -- 12
        "        consume(sibling_index);",                           -- 13
        "    }",                                                     -- 14
        "    consume(before);",                                      -- 15
        "}",                                                         -- 16
    })
    vim.bo[buffer].filetype = language
    local ok, parser = pcall(vim.treesitter.get_parser, buffer, language)
    assert(ok and parser, language .. ": parser unavailable: " .. tostring(parser))
    local tree = parser:parse()[1]
    assert(tree and not tree:root():has_error(), language .. ": grammar ERROR")
    local root = tree:root()
    local loops = {}
    collect_loops(root, loops)
    assert(#loops == 3, language .. ": expected three standard for statements")
    local ts_utils = require("tracker_hud.treesitter_utils")
    for i, expected in ipairs({ {3, 10}, {5, 7}, {12, 14} }) do
        local range = ts_utils.get_node_range_fields(loops[i])
        local declaration = loops[i]:field("initializer")[1]
        assert(range.start_line == expected[1] and range.end_line == expected[2]
            and declaration and declaration:type() == "declaration",
            language .. ": unexpected loop grammar/range")
    end

    local discovery = collector.discover(buffer, root, adapter)
    local all = collector.select(discovery, {})
    check_members(all, { outer_index = true, inner_index = true, sibling_index = true },
        language .. " all-source discovery")
    local body_count = 0
    for _, member in ipairs(all) do
        if member.name == "body_value" and member.kind == "variable" then
            body_count = body_count + 1
            assert(member.scope_start_line == 3 and member.scope_end_line == 10
                and member.visibility_start_line == nil
                and member.visibility_end_line == nil,
                language .. ": ordinary body declaration lost lexical ownership")
        end
    end
    assert(body_count == 1, language .. ": ordinary body declaration count")

    -- A cursor-only view checks explicit source visibility; ordinary lexical
    -- members are not claimed to have a structural lifetime.
    for line = 2, 15 do
        local opts = { cursor_line = line }
        local expected = {
            outer_index = line >= 3 and line <= 10,
            inner_index = line >= 5 and line <= 7,
            sibling_index = line >= 12 and line <= 14,
        }
        local label = language .. " line " .. line
        check_members(collector.collect(buffer, root, adapter, opts), expected, label .. " direct")
        check_members(collector.select(discovery, opts), expected, label .. " shared")
    end

    vim.api.nvim_buf_delete(buffer, { force = true })
    print("PASS " .. language .. " nested and sibling initializer lifetimes")
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
    print("PASS direct/shared nested loop visibility agreement")
    print("PASS Tracker_HUD C/C++ nested for lifetime smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL C/C++ nested for lifetime smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
