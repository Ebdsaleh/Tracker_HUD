-- tests/cpp_structured_binding_scope_member_standard_compatibility_smoke.lua
--
-- The C++17 structural construct is already gated. Scope Members must
-- expose the two real bindings independently, not a bracketed pseudo-name,
-- and must not expose them before the declaration or in earlier standards.
-- This fixture covers simple initialized declarations, not range-for,
-- destructuring values, reference semantics, or lifetime inference.

local function find_first(node, wanted)
    if node:type() == wanted then
        return node
    end
    for child in node:iter_children() do
        local found = find_first(child, wanted)
        if found then
            return found
        end
    end
    return nil
end

local function check_members(members, expected, label)
    local counts = { alpha = 0, beta = 0 }
    local ordinary = 0
    local composite = 0
    local details = {}
    for _, member in ipairs(members or {}) do
        local name = member.name
        if counts[name] ~= nil then
            counts[name] = counts[name] + 1
            assert(member.kind == "variable",
                label .. ": binding has incorrect kind: " .. tostring(member.kind))
        elseif name == "ordinary" then
            ordinary = ordinary + 1
        elseif type(name) == "string"
            and (name:find("alpha", 1, true) or name:find("beta", 1, true))
        then
            composite = composite + 1
        end
        details[#details + 1] = tostring(name) .. ":" .. tostring(member.kind)
    end
    assert(ordinary > 0, label .. ": ordinary declaration disappeared")
    assert(counts.alpha == expected and counts.beta == expected
            and composite == 0,
        label .. ": structured binding members mismatch; expected "
            .. tostring(expected) .. " of each, no composite; observed "
            .. table.concat(details, ", "))
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local constructs = require("tracker_hud.construct_utils")
    local c = require("tracker_hud.adapters.c.init")
    local cpp = require("tracker_hud.adapters.cpp.init")

    registry.clear()
    local ok, err = registry.register(c)
    assert(ok, "C registration failed: " .. tostring(err))
    ok, err = registry.register(cpp)
    assert(ok, "C++ registration failed: " .. tostring(err))

    local spec = cpp.construct_specs.structured_binding_declarator
    assert(spec and spec.availability and spec.availability.since == "cpp17",
        "Checkpoint 237 construct gate missing")

    local cases = {
        { label = "cpp17 default", selected = "cpp17", available = true },
        { label = "cpp98 source override", source = "// standard=cpp98;",
          config = { targets = { standard = "cpp23" } }, selected = "cpp98" },
        { label = "cpp03", config = { targets = { standard = "cpp03" } },
          selected = "cpp03" },
        { label = "cpp11", config = { targets = { standard = "cpp11" } },
          selected = "cpp11" },
        { label = "cpp14", config = { targets = { standard = "cpp14" } },
          selected = "cpp14" },
        { label = "cpp14 source override", source = "// standard=14;",
          config = { targets = { standard = "cpp23" } }, selected = "cpp14" },
        { label = "cpp17 source override", source = "// standard=17;",
          config = { targets = { standard = "cpp14" } },
          selected = "cpp17", available = true },
        { label = "cpp20", config = { targets = { standard = "cpp20" } },
          selected = "cpp20", available = true },
        { label = "cpp23 alias", config = { targets = { standard = "c++23" } },
          selected = "cpp23", available = true },
    }

    for _, case in ipairs(cases) do
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            case.source or "// structured binding scope member fixture",
            "int ordinary = 7;",
            "auto [alpha, beta] = make_pair();",
            "int after = 9;",
        })
        vim.bo[bufnr].filetype = "cpp"

        local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr, "cpp")
        assert(parser_ok and parser, "C++ parser unavailable: " .. tostring(parser))
        local tree = parser:parse()[1]
        assert(tree and not tree:root():has_error(),
            case.label .. ": grammar ERROR")
        local root = tree:root()
        local node = find_first(root, "structured_binding_declarator")
        assert(node and node:named_child_count() == 2
            and node:named_child(0):type() == "identifier"
            and node:named_child(1):type() == "identifier",
            case.label .. ": structured binding grammar changed")

        local configured, config_err = registry.configure_adapter_for_buffer(
            "cpp", bufnr, case.config or {})
        assert(configured, case.label .. ": " .. tostring(config_err))
        assert(cpp.active_targets.standard == case.selected,
            case.label .. ": standard precedence mismatch")
        assert((constructs.get_construct_spec(node, cpp,
            "structured_binding_declarator") == spec) == (case.available == true),
            case.label .. ": construct gate regressed")

        local discovery = collector.discover(bufnr, root, cpp)
        for _, line in ipairs({ 2, 3, 4 }) do
            local expected = case.available and line >= 3 and 1 or 0
            local opts = { cursor_line = line }
            check_members(collector.collect(bufnr, root, cpp, opts),
                expected, case.label .. " direct line " .. line)
            check_members(collector.select(discovery, opts),
                expected, case.label .. " shared line " .. line)
        end
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    assert(c.construct_specs.structured_binding_declarator == nil,
        "C adapter inherited C++ binding construct")
    assert(cpp.construct_specs.structured_binding_declarator == spec,
        "C++ construct identity changed")
    print("PASS C++17+ discovers two independent structured binding variables")
    print("PASS earlier standards suppress structured binding members")
    print("PASS before/on/past cursor boundaries and no composite name")
    print("PASS ordinary declarations and direct/shared collector agreement")
    print("PASS Tracker_HUD C++ structured binding Scope Member compatibility smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL C++ structured binding Scope Member compatibility smoke: "
        .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
