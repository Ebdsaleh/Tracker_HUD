-- C++17 structured bindings in a range-for must expose two loop
-- variables, not a composite name or ordinary function-scope variables.
-- Keep the C++11 ordinary range-for compatibility and lifetime intact.
local function find_first(node, wanted)
    if node:type() == wanted then return node end
    for child in node:iter_children() do
        local found = find_first(child, wanted)
        if found then return found end
    end
end

local function check_bindings(members, expected, label)
    local counts = { alpha = 0, beta = 0 }
    local details = {}
    local invalid = 0
    for _, member in ipairs(members or {}) do
        local name = member.name
        if type(name) == "string"
            and (name:find("alpha", 1, true) or name:find("beta", 1, true))
        then
            details[#details + 1] = name .. ":" .. tostring(member.kind)
                .. "@" .. tostring(member.visibility_start_line)
                .. "-" .. tostring(member.visibility_end_line)
            if counts[name] ~= nil and member.kind == "loop_variable"
                and member.visibility_start_line == 4
                and member.visibility_end_line == 6
            then
                counts[name] = counts[name] + 1
            else
                invalid = invalid + 1
            end
        end
    end
    assert(counts.alpha == expected and counts.beta == expected and invalid == 0,
        label .. ": structured range-for bindings mismatch; expected "
        .. expected .. " of each with loop lifetime; observed "
        .. table.concat(details, ", "))
end

local function check_ordinary(members, expected, label)
    local count = 0
    for _, member in ipairs(members or {}) do
        if member.name == "item" then
            assert(member.kind == "loop_variable"
                and member.visibility_start_line == 8
                and member.visibility_end_line == 10,
                label .. ": ordinary loop binding changed")
            count = count + 1
        end
    end
    assert(count == expected, label .. ": ordinary loop binding count " .. count)
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local constructs = require("tracker_hud.construct_utils")
    local cpp = require("tracker_hud.adapters.cpp.init")
    registry.clear()
    local ok, err = registry.register(cpp)
    assert(ok, "C++ registration failed: " .. tostring(err))
    local spec = cpp.construct_specs.structured_binding_declarator
    local range_spec = cpp.construct_specs.for_range_loop
    assert(spec and spec.availability and spec.availability.since == "cpp17"
        and range_spec and range_spec.availability.since == "cpp11",
        "existing standard gates missing")

    local cases = {
        { standard = "cpp17", binding = true, loop = true },
        { standard = "cpp98" },
        { standard = "cpp03" },
        { standard = "cpp11", loop = true },
        { standard = "cpp14", loop = true },
        { standard = "cpp20", binding = true, loop = true },
        { standard = "cpp23", binding = true, loop = true },
        { standard = "cpp14", directive = "// standard=14;",
          config = "cpp23", loop = true },
        { standard = "cpp17", directive = "// standard=17;",
          config = "cpp14", binding = true, loop = true },
    }
    for index, case in ipairs(cases) do
        local buffer = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
            case.directive or "// range-for binding fixture",
            "void example() {",
            "    int ordinary = 7;",
            "    for (auto [alpha, beta] : pairs) {",
            "        consume(alpha, beta);",
            "    }",
            "    int after = 9;",
            "    for (int item : items) {",
            "        consume(item);",
            "    }",
            "    consume(after);",
            "}",
        })
        vim.bo[buffer].filetype = "cpp"
        local parser_ok, parser = pcall(vim.treesitter.get_parser, buffer, "cpp")
        assert(parser_ok and parser, "C++ parser unavailable: " .. tostring(parser))
        local tree = parser:parse()[1]
        assert(tree and not tree:root():has_error(), "range-for fixture grammar ERROR")
        local root = tree:root()
        local loop = find_first(root, "for_range_loop")
        local node = loop and find_first(loop, "structured_binding_declarator")
        assert(node and node:named_child_count() == 2
            and node:named_child(0):type() == "identifier"
            and node:named_child(1):type() == "identifier",
            "range-for structured binding grammar missing")
        local config = index == 1 and {} or {
            targets = { standard = case.config or case.standard },
        }
        local configured, config_err = registry.configure_adapter_for_buffer(
            "cpp", buffer, config)
        assert(configured, tostring(config_err))
        assert(cpp.active_targets.standard == case.standard, "standard precedence mismatch")
        assert((constructs.get_construct_spec(node, cpp,
            "structured_binding_declarator") == spec) == (case.binding == true),
            "structured binding gate regressed")
        assert((constructs.get_construct_spec(loop, cpp,
            "for_range_loop") == range_spec) == (case.loop == true),
            "ordinary range-for gate regressed")

        local discovery = collector.discover(buffer, root, cpp)
        for _, line in ipairs({ 3, 4, 5, 6, 7, 8, 9, 10, 11 }) do
            local members = collector.select(discovery, { cursor_line = line })
            local label = case.standard .. " case " .. index .. " line " .. line
            check_bindings(members,
                case.binding and line >= 4 and line <= 6 and 1 or 0, label)
            check_ordinary(members,
                case.loop and line >= 8 and line <= 10 and 1 or 0, label)
        end
        vim.api.nvim_buf_delete(buffer, { force = true })
    end
    print("PASS independent structured range-for loop variables")
    print("PASS C++17+ standard gate and loop-bounded visibility")
    print("PASS C++11 ordinary range-for control and source precedence")
    print("PASS Tracker_HUD structured binding range-for Scope Member smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL structured binding range-for Scope Member smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
