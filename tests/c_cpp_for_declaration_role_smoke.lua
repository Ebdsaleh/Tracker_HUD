-- Checkpoint 242: distinguish the for initializer from ordinary declarations
-- in the body. Both C and C++ must declare exact role predicates; a broad
-- ancestor match is insufficient. Preserve the existing source member kinds.
local function find_first(node, wanted)
    if node:type() == wanted then return node end
    for child in node:iter_children() do
        local found = find_first(child, wanted)
        if found then return found end
    end
end

local function find_variable(members, name, label)
    local result
    for _, member in ipairs(members or {}) do
        if member.name == name and member.kind == "variable" then
            assert(not result, label .. ": duplicate variable " .. name)
            result = member
        end
    end
    return result
end

local function check_roles(adapter, failures)
    local wanted = {
        ["for declaration"] = {
            node = "declaration", key = "constraints",
            path = { "for_statement" },
        },
        ["declaration"] = {
            node = "declaration", key = "exclusions",
            path = { "for_statement" },
        },
        ["for initialized variable"] = {
            node = "init_declarator", key = "constraints",
            path = { "declaration", "for_statement" },
        },
        ["initialized variable"] = {
            node = "init_declarator", key = "exclusions",
            path = { "declaration", "for_statement" },
        },
    }
    local seen = {}
    for _, spec in ipairs(adapter.scope_members.symbols) do
        local term = spec.member.language_term
        local role = wanted[term]
        if role and spec.syntax.node_type == role.node then
            assert(not seen[term], adapter.name .. ": duplicate role " .. term)
            seen[term] = true
            local predicate = spec.syntax[role.key]
            if not predicate or not vim.deep_equal(predicate.parent_path, role.path)
                or predicate.ancestor_node_types ~= nil
            then
                failures[#failures + 1] = adapter.name .. ": " .. term
                    .. " missing exact " .. role.key .. ".parent_path"
            end
            local lifetime = spec.member.visibility and spec.member.visibility.range
            assert(lifetime == (role.key == "constraints" and "structural_scope" or nil),
                adapter.name .. ": incorrect declared lifetime " .. term)
        end
    end
    for term in pairs(wanted) do
        assert(seen[term], adapter.name .. ": missing rule " .. term)
    end
end

local function check_runtime(adapter, collector)
    local language = adapter.name
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
        "void example(void) {",
        "    int before = 7;",
        "    for (int index = 0; index < 2; ++index) {",
        "        int body_value = index;",
        "        consume(body_value);",
        "    }",
        "    int after = before;",
        "    consume(after);",
        "}",
    })
    vim.bo[buffer].filetype = language
    local ok, parser = pcall(vim.treesitter.get_parser, buffer, language)
    assert(ok and parser, language .. ": parser unavailable: " .. tostring(parser))
    local tree = parser:parse()[1]
    assert(tree and not tree:root():has_error(), language .. ": grammar ERROR")
    local root = tree:root()
    local loop = find_first(root, "for_statement")
    assert(loop, language .. ": for_statement missing")
    local initializer = loop:field("initializer")[1]
    local body = loop:field("body")[1]
    assert(initializer and initializer:type() == "declaration"
        and initializer:parent():type() == "for_statement"
        and body and body:type() == "compound_statement",
        language .. ": unexpected initializer/body grammar")
    local header_init = find_first(initializer, "init_declarator")
    local body_init = find_first(body, "init_declarator")
    assert(header_init and body_init
        and header_init:parent():type() == "declaration"
        and header_init:parent():parent():type() == "for_statement"
        and body_init:parent():parent():type() == "compound_statement",
        language .. ": unexpected declaration role paths")

    local discovery = collector.discover(buffer, root, adapter)
    local all = collector.select(discovery, {})
    local before = find_variable(all, "before", language)
    local index = find_variable(all, "index", language)
    local inner = find_variable(all, "body_value", language)
    local after = find_variable(all, "after", language)
    assert(before and index and inner and after, language .. ": missing variable")
    assert(index.visibility_start_line == 3 and index.visibility_end_line == 6,
        language .. ": initializer must have loop lifetime")
    for _, member in ipairs({ before, inner, after }) do
        assert(member.visibility_start_line == nil and member.visibility_end_line == nil,
            language .. ": ordinary declaration got loop lifetime: " .. member.name)
    end
    assert(inner.scope_start_line == 3 and inner.scope_end_line == 6
        and inner.scope_depth > before.scope_depth,
        language .. ": body declaration lost lexical owner")

    for _, line in ipairs({ 2, 3, 4, 5, 6, 7, 8 }) do
        local opts = { cursor_line = line }
        for _, members in ipairs({
            collector.collect(buffer, root, adapter, opts),
            collector.select(discovery, opts),
        }) do
            local visible = find_variable(members, "index", language)
            assert((visible ~= nil) == (line >= 3 and line <= 6),
                language .. ": initializer visibility mismatch at line " .. line)
        end
    end
    local opts = { cursor_line = 8, scope_depth = before.scope_depth }
    for _, members in ipairs({
        collector.collect(buffer, root, adapter, opts),
        collector.select(discovery, opts),
    }) do
        assert(find_variable(members, "before", language)
            and find_variable(members, "after", language)
            and not find_variable(members, "index", language)
            and not find_variable(members, "body_value", language),
            language .. ": outer lexical view mismatch")
    end
    vim.api.nvim_buf_delete(buffer, { force = true })
    print("PASS " .. language .. " initializer lifetime and body lexical ownership")
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local c = require("tracker_hud.adapters.c.init")
    local cpp = require("tracker_hud.adapters.cpp.init")
    registry.clear()
    local failures = {}
    for _, adapter in ipairs({ c, cpp }) do
        local ok, err = registry.register(adapter)
        assert(ok, tostring(err))
        check_roles(adapter, failures)
        check_runtime(adapter, collector)
    end
    assert(#failures == 0, "C-family exact declaration role predicates missing: "
        .. table.concat(failures, "; "))
    print("PASS exact C-family initializer/body declaration rule predicates")
    print("PASS Tracker_HUD C/C++ for declaration role smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL C/C++ for declaration role smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
