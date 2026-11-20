-- tests/c_cpp_pointer_outer_assignment_scope_smoke.lua
--
-- Real-parser C/C++ direct pointer-lineage outer-declaration assignment baseline.
--
-- A pointer declared in an outer lexical scope may receive an allocation in a
-- nested block without becoming a new block-local binding. This remains direct
-- source identity only: no alias, ownership, liveness, release-success, path,
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
        language .. " outer-assignment fixture contains ERROR nodes"
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
        language .. " outer assignment must not invent runtime state"
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
        #facts == 2,
        fixture.language
            .. " expected exactly 2 source-memory observations, got "
            .. tostring(#facts)
    )

    local producer = facts[1]
    local release = facts[2]
    local producer_metadata = producer.metadata or {}
    local release_metadata = release.metadata or {}

    assert(
        producer.name == fixture.producer_name
            and producer_metadata.pointer_binding == "ptr",
        fixture.language
            .. " nested assignment must publish direct ptr producer"
    )

    assert(
        release.name == fixture.release_name
            and release_metadata.pointer_target == "ptr",
        fixture.language
            .. " release after nested block must observe direct ptr target"
    )

    assert(
        release_metadata.pointer_predecessor_id == producer.id,
        fixture.language
            .. " release after nested block expected predecessor "
            .. tostring(producer.id)
            .. ", got "
            .. tostring(release_metadata.pointer_predecessor_id)
    )

    assert(
        release_metadata.pointer_predecessor_relation
            == "direct_source_identity",
        fixture.language
            .. " release after nested block must retain direct_source_identity"
    )

    assert_runtime_unknown(fixture.language, producer)
    assert_runtime_unknown(fixture.language, release)

    print(
        "OBSERVED "
            .. fixture.language
            .. " outer-assignment pointer: "
            .. producer.name
            .. "@"
            .. tostring(producer.source_line)
            .. "(binding="
            .. tostring(producer_metadata.pointer_binding or "none")
            .. ") -> "
            .. release.name
            .. "@"
            .. tostring(release.source_line)
            .. "(target="
            .. tostring(release_metadata.pointer_target or "none")
            .. ",predecessor="
            .. tostring(release_metadata.pointer_predecessor_id or "none")
            .. ")"
    )

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
            producer_name = "malloc",
            release_name = "free",
            source = table.concat(
                {
                    "#include <stdlib.h>",
                    "#include <stddef.h>",
                    "",
                    "void assign_outer_c(size_t count) {",
                    "    void *ptr = NULL;",
                    "    {",
                    "        ptr = malloc(count);",
                    "    }",
                    "    free(ptr);",
                    "}",
                },
                "\n"
            ),
        }
    )

    run_fixture(
        observations,
        {
            language = "cpp",
            producer_name = "new",
            release_name = "delete",
            source = table.concat(
                {
                    "void assign_outer_cpp() {",
                    "    int *ptr = nullptr;",
                    "    {",
                    "        ptr = new int(1);",
                    "    }",
                    "    delete ptr;",
                    "}",
                },
                "\n"
            ),
        }
    )

    print(
        "PASS C/C++ assignment-produced pointer identity retains outer lexical binding scope"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL C/C++ pointer outer-assignment scope smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
