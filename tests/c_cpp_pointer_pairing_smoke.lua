-- tests/c_cpp_pointer_pairing_smoke.lua
--
-- Real-parser C/C++ direct pointer predecessor baseline.
--
-- This records source-order identity lineage only. It does NOT prove
-- allocation success, liveness, unique ownership, release success, path
-- execution, alias equivalence, or leak status.

local function make_buffer(language, source)
    local lines = vim.split(source, "\n", { plain = true })
    local buffer = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.bo[buffer].filetype = language

    local parser_ok, parser =
        pcall(
            vim.treesitter.get_parser,
            buffer,
            language
        )

    assert(
        parser_ok and parser,
        "Tree-sitter parser not installed for " .. language
    )

    local tree = parser:parse()[1]
    assert(tree, "parser yielded no tree for " .. language)

    local root = tree:root()
    assert(
        not root:has_error(),
        language .. " pointer pairing fixture contains ERROR nodes"
    )

    return buffer, root, #lines
end

local function assert_runtime_unknown(language, fact)
    local metadata = fact.metadata or {}

    assert(
        metadata.allocation_success == "unknown"
            and metadata.ownership == "unknown"
            and metadata.live_pointer == "unknown"
            and metadata.leak_status == "not analyzed",
        language
            .. " direct pointer pairing must not invent runtime state"
    )
end

local function assert_fact_shape(language, fact, expected)
    local metadata = fact.metadata or {}

    assert(
        fact.name == expected.name,
        language
            .. " expected "
            .. expected.name
            .. ", got "
            .. tostring(fact.name)
    )

    assert(
        metadata.pointer_binding == expected.binding,
        language
            .. " "
            .. expected.name
            .. " binding expected "
            .. tostring(expected.binding)
            .. ", got "
            .. tostring(metadata.pointer_binding)
    )

    assert(
        metadata.pointer_target == expected.target,
        language
            .. " "
            .. expected.name
            .. " target expected "
            .. tostring(expected.target)
            .. ", got "
            .. tostring(metadata.pointer_target)
    )

    assert_runtime_unknown(language, fact)
end

local function run_fixture(observations, fixture)
    local buffer, root, line_count =
        make_buffer(
            fixture.language,
            fixture.source
        )

    local facts =
        observations.collect(
            buffer,
            root,
            fixture.language,
            line_count
        )

    assert(
        #facts == #fixture.expected,
        fixture.language
            .. " expected "
            .. tostring(#fixture.expected)
            .. " memory observations, got "
            .. tostring(#facts)
    )

    for index, expected in ipairs(fixture.expected) do
        assert_fact_shape(
            fixture.language,
            facts[index],
            expected
        )
    end

    for index, expected in ipairs(fixture.expected) do
        local fact = facts[index]
        local metadata = fact.metadata or {}
        local predecessor_id

        if expected.predecessor then
            predecessor_id =
                facts[expected.predecessor].id
        end

        assert(
            metadata.pointer_predecessor_id
                == predecessor_id,
            fixture.language
                .. " "
                .. fact.name
                .. "@"
                .. tostring(fact.source_line)
                .. " predecessor expected "
                .. tostring(predecessor_id)
                .. ", got "
                .. tostring(metadata.pointer_predecessor_id)
        )

        local expected_relation =
            predecessor_id
                and "direct_source_identity"
                or nil

        assert(
            metadata.pointer_predecessor_relation
                == expected_relation,
            fixture.language
                .. " "
                .. fact.name
                .. "@"
                .. tostring(fact.source_line)
                .. " predecessor relation expected "
                .. tostring(expected_relation)
                .. ", got "
                .. tostring(metadata.pointer_predecessor_relation)
        )

        print(
            "OBSERVED "
                .. fixture.language
                .. " pointer predecessor: "
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

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local observations =
        require("tracker_hud.adapters.c.memory_facts")

    local fixtures = {
        {
            language = "c",
            source = table.concat(
                {
                    "#include <stdlib.h>",
                    "#include <stddef.h>",
                    "",
                    "void pair_c(size_t count) {",
                    "    void *block = malloc(count);",
                    "    free(block);",
                    "    void *zeroed = calloc(2, count);",
                    "    free(zeroed);",
                    "    void *original = malloc(count);",
                    "    void *resized = realloc(original, count * 2);",
                    "    free(resized);",
                    "    void *owned = malloc(count);",
                    "    void *alias = owned;",
                    "    free(alias);",
                    "}",
                },
                "\n"
            ),
            expected = {
                { name = "malloc", binding = "block" },
                { name = "free", target = "block", predecessor = 1 },
                { name = "calloc", binding = "zeroed" },
                { name = "free", target = "zeroed", predecessor = 3 },
                { name = "malloc", binding = "original" },
                {
                    name = "realloc",
                    binding = "resized",
                    target = "original",
                    predecessor = 5,
                },
                { name = "free", target = "resized", predecessor = 6 },
                { name = "malloc", binding = "owned" },
                {
                    name = "free",
                    target = "alias",
                    predecessor = nil,
                },
            },
        },
        {
            language = "cpp",
            source = table.concat(
                {
                    "void pair_cpp() {",
                    "    int *single = new int(9);",
                    "    delete single;",
                    "    int *array = new int[2];",
                    "    delete[] array;",
                    "    int *owned = new int(3);",
                    "    int *alias = owned;",
                    "    delete alias;",
                    "}",
                },
                "\n"
            ),
            expected = {
                { name = "new", binding = "single" },
                { name = "delete", target = "single", predecessor = 1 },
                { name = "new", binding = "array" },
                { name = "delete", target = "array", predecessor = 3 },
                { name = "new", binding = "owned" },
                {
                    name = "delete",
                    target = "alias",
                    predecessor = nil,
                },
            },
        },
    }

    for _, fixture in ipairs(fixtures) do
        run_fixture(observations, fixture)
    end

    print(
        "PASS C/C++ direct pointer predecessor pairing without runtime-state inference"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL C/C++ pointer pairing smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
