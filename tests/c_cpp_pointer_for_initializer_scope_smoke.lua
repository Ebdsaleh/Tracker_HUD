-- tests/c_cpp_pointer_for_initializer_scope_smoke.lua
--
-- Real-parser C/C++ direct pointer-lineage for-initializer shadow baseline.
--
-- A pointer declared in a for initializer shadows an outer same-name binding
-- only for the loop's source lifetime. Leaving the loop must restore the outer
-- direct source identity. No alias, ownership, liveness, release-success, path,
-- escape, RAII, or leak inference is permitted.

local function make_buffer(language, source)
    local lines = vim.split(source, "\n", { plain = true })
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.bo[buffer].filetype = language

    local parser_ok, parser =
        pcall(vim.treesitter.get_parser, buffer, language)

    assert(
        parser_ok and parser,
        "Tree-sitter parser not installed for " .. language
    )

    local tree = parser:parse()[1]
    assert(tree, "parser yielded no tree for " .. language)

    local root = tree:root()
    assert(
        not root:has_error(),
        language .. " for-initializer pointer fixture contains ERROR nodes"
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
        language .. " for-initializer shadow must not invent runtime state"
    )
end

local function assert_fact(language, fact, expected, facts)
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
            .. "@"
            .. tostring(fact.source_line)
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
        language
            .. " "
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
        language
            .. " "
            .. expected.name
            .. "@"
            .. tostring(fact.source_line)
            .. " predecessor relation expected "
            .. tostring(expected_relation)
            .. ", got "
            .. tostring(metadata.pointer_predecessor_relation)
    )

    assert_runtime_unknown(language, fact)

    print(
        "OBSERVED "
            .. language
            .. " for-initializer pointer: "
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

local function run_fixture(observations, fixture)
    local buffer, root, line_count =
        make_buffer(fixture.language, fixture.source)

    local facts =
        observations.collect(
            buffer,
            root,
            fixture.language,
            line_count
        )

    assert(
        #facts == 4,
        fixture.language
            .. " expected exactly 4 source-memory observations, got "
            .. tostring(#facts)
    )

    for index, expected in ipairs(fixture.expected) do
        assert_fact(
            fixture.language,
            facts[index],
            expected,
            facts
        )
    end

    vim.api.nvim_buf_delete(buffer, { force = true })
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local observations =
        require("tracker_hud.adapters.c.memory_facts")

    run_fixture(
        observations,
        {
            language = "c",
            source = table.concat(
                {
                    "#include <stdlib.h>",
                    "#include <stddef.h>",
                    "",
                    "void for_shadow_c(size_t count) {",
                    "    void *ptr = malloc(count);",
                    "    for (void *ptr = malloc(count * 2); ptr != NULL; ) {",
                    "        free(ptr);",
                    "        break;",
                    "    }",
                    "    free(ptr);",
                    "}",
                },
                "\n"
            ),
            expected = {
                { name = "malloc", binding = "ptr" },
                { name = "malloc", binding = "ptr" },
                { name = "free", target = "ptr", predecessor = 2 },
                { name = "free", target = "ptr", predecessor = 1 },
            },
        }
    )

    run_fixture(
        observations,
        {
            language = "cpp",
            source = table.concat(
                {
                    "void for_shadow_cpp() {",
                    "    int *ptr = new int(1);",
                    "    for (int *ptr = new int(2); ptr != nullptr; ) {",
                    "        delete ptr;",
                    "        break;",
                    "    }",
                    "    delete ptr;",
                    "}",
                },
                "\n"
            ),
            expected = {
                { name = "new", binding = "ptr" },
                { name = "new", binding = "ptr" },
                { name = "delete", target = "ptr", predecessor = 2 },
                { name = "delete", target = "ptr", predecessor = 1 },
            },
        }
    )

    print(
        "PASS C/C++ direct pointer lineage respects for-initializer shadow lifetime"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL C/C++ pointer for-initializer scope smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
