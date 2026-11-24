-- Guard the exact parent-path distinction introduced in checkpoint 239.
-- An ordinary structured binding inside a range-for body is not a header
-- binding. Test source discovery and lexical ownership, not runtime values.
local function collect_nodes(node, wanted, result)
    if node:type() == wanted then result[#result + 1] = node end
    for child in node:iter_children() do
        collect_nodes(child, wanted, result)
    end
end

local function check_members(members, expected, label)
    local counts = {}
    local details = {}
    for _, member in ipairs(members or {}) do
        local name = member.name
        if type(name) == "string" and
            (name:find("alpha", 1, true) or name:find("beta", 1, true)
            or name:find("gamma", 1, true) or name:find("delta", 1, true))
        then
            details[#details + 1] = name .. ":" .. tostring(member.kind)
            local spec = expected[name]
            assert(spec, label .. ": unexpected binding " .. name)
            assert(member.kind == spec.kind, label .. ": wrong kind for " .. name)
            assert(member.line == spec.line, label .. ": wrong source line for " .. name)
            assert(member.visibility_start_line == spec.first
                and member.visibility_end_line == spec.last,
                label .. ": incorrect explicit visibility for " .. name)
            if spec.owner then
                assert(member.scope_start_line == spec.owner[1]
                    and member.scope_end_line == spec.owner[2],
                    label .. ": incorrect lexical owner for " .. name)
            end
            counts[name] = (counts[name] or 0) + 1
        end
    end
    for name in pairs(expected) do
        assert(counts[name] == 1, label .. ": expected exactly one " .. name
            .. "; observed " .. table.concat(details, ", "))
    end
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local cpp = require("tracker_hud.adapters.cpp.init")
    registry.clear()
    local ok, err = registry.register(cpp)
    assert(ok, "C++ registration failed: " .. tostring(err))

    local cases = {
        { standard = "cpp17", available = true },
        { standard = "cpp14" },
        { standard = "cpp20", available = true },
        { standard = "cpp23", available = true },
        { standard = "cpp14", source = "// standard=14;", config = "cpp23" },
        { standard = "cpp17", source = "// standard=17;", config = "cpp14",
          available = true },
    }
    for index, case in ipairs(cases) do
        local buffer = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
            case.source or "// nested structured binding guardrail",
            "void example() {",
            "    int ordinary = 7;",
            "    for (auto [alpha, beta] : pairs) {",
            "        auto [gamma, delta] = make_pair();",
            "        consume(gamma, delta);",
            "    }",
            "    consume(ordinary);",
            "}",
        })
        vim.bo[buffer].filetype = "cpp"
        local parser_ok, parser = pcall(vim.treesitter.get_parser, buffer, "cpp")
        assert(parser_ok and parser, "C++ parser unavailable: " .. tostring(parser))
        local tree = parser:parse()[1]
        assert(tree and not tree:root():has_error(), "nested fixture grammar ERROR")
        local root = tree:root()
        local nodes = {}
        collect_nodes(root, "structured_binding_declarator", nodes)
        assert(#nodes == 2 and nodes[1]:parent():type() == "for_range_loop"
            and nodes[2]:parent():type() == "init_declarator",
            "unexpected nested structured binding grammar")
        for _, node in ipairs(nodes) do
            assert(node:named_child_count() == 2
                and node:named_child(0):type() == "identifier"
                and node:named_child(1):type() == "identifier",
                "expected two independent identifier children")
        end
        local config = index == 1 and {} or {
            targets = { standard = case.config or case.standard },
        }
        local configured, config_err = registry.configure_adapter_for_buffer(
            "cpp", buffer, config)
        assert(configured, tostring(config_err))
        assert(cpp.active_targets.standard == case.standard, "standard precedence mismatch")
        local discovery = collector.discover(buffer, root, cpp)
        local header = { kind = "loop_variable", line = 4, first = 4, last = 7 }
        local body = { kind = "variable", line = 5, owner = { 4, 7 } }
        for _, line in ipairs({ 3, 4, 5, 6, 7, 8 }) do
            -- Cursor-only view is a source-discovery view; lexical range
            -- filtering is checked separately below. Do not invent lifetime
            -- metadata for ordinary declarations.
            local expected = {}
            if case.available and line >= 4 and line <= 7 then
                expected.alpha, expected.beta = header, header
            end
            if case.available and line >= 5 then
                expected.gamma, expected.delta = body, body
            end
            local opts = { cursor_line = line }
            local label = case.standard .. " case " .. index .. " line " .. line
            check_members(collector.collect(buffer, root, cpp, opts), expected,
                label .. " direct")
            check_members(collector.select(discovery, opts), expected,
                label .. " shared")
        end
        if case.available then
            local body_depth
            local outer_depth
            for _, member in ipairs(collector.select(discovery, {})) do
                if member.name == "gamma" then body_depth = member.scope_depth end
                if member.name == "ordinary" and member.kind == "variable" then
                    outer_depth = member.scope_depth
                end
            end
            assert(body_depth and outer_depth and body_depth > outer_depth,
                "body binding must belong to a deeper lexical scope")
            local opts = { cursor_line = 8, scope_depth = outer_depth }
            check_members(collector.collect(buffer, root, cpp, opts), {},
                "direct outer lexical view")
            check_members(collector.select(discovery, opts), {},
                "shared outer lexical view")
        end
        vim.api.nvim_buf_delete(buffer, { force = true })
    end
    print("PASS range-for header and nested ordinary structured binding roles")
    print("PASS independent names, exact lexical owner and loop visibility")
    print("PASS standard gating and direct/shared lexical-view agreement")
    print("PASS Tracker_HUD nested structured binding Scope Member smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL nested structured binding Scope Member smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
