-- tests/cpp_pointer_range_for_initializer_scope_smoke.lua
--
-- Real-parser C++ range-for init-statement pointer-shadow baseline.
--
-- A pointer declared by a C++20 range-for init-statement is visible through
-- that range-for and must not leak into the remainder of the enclosing block.
-- This is direct source identity only: no execution, alias, ownership,
-- liveness, release-success, escape, RAII, path, or leak inference.

local function make_buffer(source)
    local lines = vim.split(source, "\n", { plain = true })
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.bo[buffer].filetype = "cpp"

    local parser_ok, parser =
        pcall(vim.treesitter.get_parser, buffer, "cpp")

    assert(
        parser_ok and parser,
        "Tree-sitter parser not installed for cpp"
    )

    local tree = parser:parse()[1]
    assert(tree, "parser yielded no tree for cpp")

    local root = tree:root()
    assert(
        not root:has_error(),
        "cpp range-for init-statement fixture contains ERROR nodes"
    )

    return buffer, root, #lines
end

local function assert_runtime_unknown(fact)
    local metadata = fact.metadata or {}

    assert(
        metadata.allocation_success == "unknown"
            and metadata.ownership == "unknown"
            and metadata.live_pointer == "unknown"
            and metadata.leak_status == "not analyzed",
        "cpp range-for init-statement shadow must not invent runtime state"
    )
end

local function assert_fact(fact, expected, facts)
    local metadata = fact.metadata or {}

    assert(
        fact.name == expected.name,
        "cpp expected "
            .. expected.name
            .. ", got "
            .. tostring(fact.name)
    )

    assert(
        metadata.pointer_binding == expected.binding,
        "cpp "
            .. expected.name
            .. "@"
            .. tostring(fact.source_line)
            .. " binding expected "
            .. tostring(expected.binding)
            .. ", got "
            .. tostring(metadata.pointer_binding)
    )

    assert(
        metadata.pointer_target == expected.target,
        "cpp "
            .. expected.name
            .. "@"
            .. tostring(fact.source_line)
            .. " target expected "
            .. tostring(expected.target)
            .. ", got "
            .. tostring(metadata.pointer_target)
    )

    local predecessor_id =
        expected.predecessor
            and facts[expected.predecessor].id
            or nil

    assert(
        metadata.pointer_predecessor_id == predecessor_id,
        "cpp "
            .. expected.name
            .. "@"
            .. tostring(fact.source_line)
            .. " predecessor expected "
            .. tostring(predecessor_id)
            .. ", got "
            .. tostring(metadata.pointer_predecessor_id)
    )

    local expected_relation =
        predecessor_id and "direct_source_identity" or nil

    assert(
        metadata.pointer_predecessor_relation == expected_relation,
        "cpp "
            .. expected.name
            .. "@"
            .. tostring(fact.source_line)
            .. " predecessor relation expected "
            .. tostring(expected_relation)
            .. ", got "
            .. tostring(metadata.pointer_predecessor_relation)
    )

    assert_runtime_unknown(fact)

    print(
        "OBSERVED cpp range-for init pointer: "
            .. fact.name
            .. "@"
            .. tostring(fact.source_line)
            .. "(binding="
            .. tostring(metadata.pointer_binding or "none")
            .. ",target="
            .. tostring(metadata.pointer_target or "none")
            .. ",predecessor="
            .. tostring(metadata.pointer_predecessor_id or "none")
            .. ")"
    )
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local observations =
        require("tracker_hud.adapters.c.memory_facts")

    local buffer, root, line_count =
        make_buffer(
            table.concat(
                {
                    "void range_init_shadow_cpp() {",
                    "    int *ptr = new int(1);",
                    "    int values[1] = { 1 };",
                    "    for (int *ptr = new int(2); int item : values) {",
                    "        (void)item;",
                    "        delete ptr;",
                    "        break;",
                    "    }",
                    "    delete ptr;",
                    "}",
                },
                "\n"
            )
        )

    local facts =
        observations.collect(
            buffer,
            root,
            "cpp",
            line_count
        )

    assert(
        #facts == 4,
        "cpp expected exactly 4 range-for init source-memory observations, got "
            .. tostring(#facts)
    )

    local expected = {
        { name = "new", binding = "ptr" },
        { name = "new", binding = "ptr" },
        { name = "delete", target = "ptr", predecessor = 2 },
        { name = "delete", target = "ptr", predecessor = 1 },
    }

    for index, spec in ipairs(expected) do
        assert_fact(facts[index], spec, facts)
    end

    vim.api.nvim_buf_delete(buffer, { force = true })

    print(
        "PASS C++ direct pointer lineage respects range-for init-statement shadow lifetime"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL C++ pointer range-for init-statement scope smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
