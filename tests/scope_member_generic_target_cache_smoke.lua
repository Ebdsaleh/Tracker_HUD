-- Checkpoint 268: generic target-coordinate cache certification.
-- C grammar is a test vehicle, not a new production C language policy.
local source = {
    "int baseline;",
    "int *edition_name;",
    "void profile_fn(void) {",
    "    int profile_name;",
    "}",
}
local names = { [1] = "baseline", [2] = "edition_name", [4] = "profile_name" }
-- Each expected set and first-call reuse decision is independently declared.
local cases = {
    { label = "initial", edition = "legacy", profile = "basic", expected = { 1 }, hit = false },
    { label = "edition only", edition = "modern", profile = "basic", expected = { 1, 2 }, hit = false },
    { label = "profile only", edition = "modern", profile = "extended", expected = { 1, 2, 4 }, hit = false },
    { label = "edition backward", edition = "legacy", profile = "extended", expected = { 1, 4 }, hit = false },
    { label = "equivalent replacement", edition = "legacy", profile = "extended", expected = { 1, 4 }, hit = true, replace = true },
    { label = "undeclared metadata", edition = "legacy", profile = "extended", expected = { 1, 4 }, hit = true, metadata = true },
    { label = "edition restored", edition = "modern", profile = "extended", expected = { 1, 2, 4 }, hit = false },
    { label = "profile backward", edition = "modern", profile = "basic", expected = { 1, 2 }, hit = false },
    { label = "missing selection", profile = "basic", expected = { 1 }, hit = false },
    { label = "non-string unavailable selection", edition = 42, profile = "basic", expected = { 1 }, hit = true },
    { label = "unsupported string", edition = "unlisted", profile = "basic", expected = { 1 }, hit = false },
    { label = "valid selection restored", edition = "modern", profile = "basic", expected = { 1, 2 }, hit = false },
    { label = "both dimensions changed", edition = "legacy", profile = "extended", expected = { 1, 4 }, hit = false },
    { label = "unchanged selections", edition = "legacy", profile = "extended", expected = { 1, 4 }, hit = true },
}

local function inspect_grammar(root, buffer)
    local found = {}
    local function visit(node)
        if node:type() == "declaration" then
            local row = node:range()
            local line = row + 1
            local fields = node:field("declarator")
            assert(names[line] and not found[line] and #fields == 1,
                "declaration grammar drift @" .. line)
            local terminal = fields[1]
            if line == 2 then
                assert(terminal:type() == "pointer_declarator", "pointer wrapper drift")
                local tokens = 0
                for child in terminal:iter_children() do
                    if not child:named() and child:type() == "*" then tokens = tokens + 1 end
                end
                assert(tokens == 1, "anonymous pointer token drift")
                local nested = terminal:field("declarator")
                assert(#nested == 1, "pointer field cardinality drift")
                terminal = nested[1]
            end
            assert(terminal:type() == "identifier"
                and vim.treesitter.get_node_text(terminal, buffer) == names[line],
                "terminal grammar drift @" .. line)
            if line == 4 then
                local parent = node:parent()
                assert(parent:type() == "compound_statement"
                    and parent:parent():type() == "function_definition", "profile owner grammar drift")
            else
                assert(node:parent():type() == "translation_unit", "global grammar drift")
            end
            found[line] = true
        end
        for child in node:iter_children() do visit(child) end
    end
    visit(root)
    assert(vim.tbl_count(found) == 3, "fixture declaration count drift")
end

local function check(members, expected, opts, label)
    local wanted, found, ids = {}, {}, {}
    for _, line in ipairs(expected) do
        if (not opts.cursor_line or line <= opts.cursor_line)
            and (not opts.start_line or line >= opts.start_line)
            and (not opts.end_line or line <= opts.end_line) then wanted[line] = true end
    end
    for _, member in ipairs(members) do
        local line = member.line
        assert(wanted[line] and not found[line] and member.name == names[line]
            and member.kind == "symbol" and member.source_node_type == "declaration",
            label .. ": unexpected/duplicate record @" .. line)
        assert(member.is_binding == false and member.shadows_member_id == nil,
            label .. ": nonbinding observation drift")
        assert(type(member.id) == "string" and member.id ~= "" and not ids[member.id],
            label .. ": source identity drift")
        found[line], ids[member.id] = true, true
    end
    assert(vim.tbl_count(found) == vim.tbl_count(wanted), label .. ": missing record")
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local schema = require("tracker_hud.adapters.scope_member_schema")
    local collector = require("tracker_hud.scope_members")
    local c = require("tracker_hud.adapters.c.init")
    local original = vim.deepcopy(c)
    local adapter = vim.deepcopy(c)
    adapter.target_dimensions = {
        edition = { default = "legacy", supported = { "legacy", "modern" } },
        profile = { default = "basic", supported = { "basic", "extended" } },
    }
    adapter.active_targets.edition = "legacy"
    adapter.active_targets.profile = "basic"
    adapter.construct_specs.function_definition.availability = {
        language = adapter.name, dimension = "profile", values = { "extended" },
    }
    adapter.scope_members = { symbols = {
        schema.named("declaration", {
            field = "declarator",
            recursive = { field = "declarator", terminal_node_types = { "identifier" },
                container_node_types = { "pointer_declarator" } },
        }, "symbol", {
            exclusions = { field_paths = {{
                fields = { "declarator" }, node_types = { "pointer_declarator" },
                anonymous_child_type = "*",
                unless_available = { language = adapter.name, dimension = "edition", since = "modern" },
            }} },
        }),
    } }
    registry.clear()
    local registered, err = registry.register(adapter)
    assert(registered, "synthetic adapter contract: " .. tostring(err))
    -- Do not invoke the inherited C configuration closure. This test isolates
    -- already-selected target coordinates; real configuration is covered by 267.
    local specs, constructs, dimensions = adapter.scope_members, adapter.construct_specs, adapter.target_dimensions
    local spec_values, construct_values, dimension_values = vim.deepcopy(specs), vim.deepcopy(constructs), vim.deepcopy(dimensions)
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = "c"
    local tree = vim.treesitter.get_parser(buffer, "c"):parse()[1]
    assert(tree and not tree:root():has_error(), "fixture grammar ERROR")
    local root = tree:root()
    inspect_grammar(root, buffer)
    local revision = vim.api.nvim_buf_get_changedtick(buffer)
    local projections = { {}, { start_line = 2, end_line = 4, cursor_line = 4 },
        { start_line = 4, end_line = 5, cursor_line = 5 }, { start_line = 5, end_line = 5 } }
    for cursor = 1, #source do projections[#projections + 1] = { cursor_line = cursor } end
    local retained, previous = {}, nil

    local function cached(expected_hit, label)
        local counters = {}
        local result = collector.discover(buffer, root, adapter, {
            reuse_unchanged_source = true,
            profile_counter = function(key, delta) counters[key] = (counters[key] or 0) + delta end,
        })
        local prefix = "context.scope_members."
        local hit, miss = expected_hit and 1 or 0, expected_hit and 0 or 1
        assert((counters[prefix .. "cross_refresh_reuse_applied"] or 0) == hit
            and (counters[prefix .. "cross_refresh_reuse_possible"] or 0) == hit
            and (counters[prefix .. "cross_refresh_reuse_miss"] or 0) == miss,
            label .. ": cache counter mismatch")
        return result
    end

    for _, case in ipairs(cases) do
        local active = adapter.active_targets
        if case.replace then adapter.active_targets = vim.deepcopy(active) end
        assert((adapter.active_targets ~= active) == (case.replace == true), "target table identity drift")
        adapter.active_targets.edition = case.edition
        adapter.active_targets.profile = case.profile
        if case.metadata then adapter.active_targets.unrelated_probe = "changed" end
        local target_values = vim.deepcopy(adapter.active_targets)
        local fresh = collector.discover(buffer, root, adapter)
        check(collector.select(fresh, {}), case.expected, {}, case.label .. " fresh")
        local result = cached(case.hit, case.label)
        assert((result == previous) == case.hit, case.label .. ": cache identity mismatch")
        local repeated = cached(true, case.label .. " repeat")
        assert(repeated == result, case.label .. ": repeat identity mismatch")
        for _, opts in ipairs(projections) do
            local expected = collector.select(fresh, opts)
            local direct = collector.collect(buffer, root, adapter, opts)
            check(expected, case.expected, opts, case.label .. " projected fresh")
            assert(vim.deep_equal(expected, direct)
                and vim.deep_equal(expected, collector.select(result, opts))
                and vim.deep_equal(expected, collector.select(repeated, opts)),
                case.label .. ": projection parity mismatch")
        end
        for _, old in ipairs(retained) do
            assert(vim.deep_equal(old.discovery, old.snapshot), "retained discovery mutated")
        end
        retained[#retained + 1] = { discovery = result, snapshot = vim.deepcopy(result) }
        previous = result
        assert(adapter.scope_members == specs and adapter.construct_specs == constructs
            and adapter.target_dimensions == dimensions
            and vim.deep_equal(specs, spec_values) and vim.deep_equal(constructs, construct_values)
            and vim.deep_equal(dimensions, dimension_values)
            and vim.deep_equal(adapter.active_targets, target_values),
            "discovery mutated declarations or active targets")
        assert(vim.api.nvim_buf_get_changedtick(buffer) == revision
            and vim.deep_equal(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), source),
            "source revision drift")
        print("PASS generic target cache: " .. case.label)
    end
    assert(vim.deep_equal(c, original), "synthetic adapter mutated production C")
    vim.api.nvim_buf_delete(buffer, { force = true })
    print("PASS independent dimensions, token and construct availability, immutable cache snapshots")
    print("PASS Tracker_HUD generic Scope Member target cache smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL generic Scope Member target cache smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
