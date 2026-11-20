-- tests/c_cpp_pointer_identity_smoke.lua
--
-- Real-parser C/C++ source-memory pointer identity baseline.
--
-- This proves syntax-backed identity only. It does NOT claim allocation
-- success, unique ownership, alias freedom, release success, or leak status.

local function run_fixture(observations, fixture)
    local lines = vim.fn.readfile(fixture.path)
    assert(
        type(lines) == "table" and #lines > 0,
        "fixture missing: " .. fixture.path
    )

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.bo[buffer].filetype = fixture.language

    local parser_ok, parser =
        pcall(
            vim.treesitter.get_parser,
            buffer,
            fixture.language
        )

    assert(
        parser_ok and parser,
        "Tree-sitter parser not installed for " .. fixture.language
    )

    local tree = parser:parse()[1]
    assert(tree, "parser yielded no tree")

    local root = tree:root()
    assert(
        not root:has_error(),
        fixture.language .. " pointer identity fixture contains ERROR nodes"
    )

    local facts =
        observations.collect(
            buffer,
            root,
            fixture.language,
            #lines
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
        local fact = facts[index]
        local metadata = fact.metadata or {}

        assert(
            fact.name == expected.name,
            fixture.language
                .. " fact "
                .. tostring(index)
                .. " expected "
                .. expected.name
                .. ", got "
                .. tostring(fact.name)
        )

        assert(
            metadata.pointer_binding == expected.binding,
            fixture.language
                .. " "
                .. expected.name
                .. " pointer_binding expected "
                .. tostring(expected.binding)
                .. ", got "
                .. tostring(metadata.pointer_binding)
        )

        assert(
            metadata.pointer_target == expected.target,
            fixture.language
                .. " "
                .. expected.name
                .. " pointer_target expected "
                .. tostring(expected.target)
                .. ", got "
                .. tostring(metadata.pointer_target)
        )

        assert(
            metadata.allocation_success == "unknown"
                and metadata.ownership == "unknown"
                and metadata.leak_status == "not analyzed",
            fixture.language
                .. " pointer identity must not invent runtime allocation/ownership/leak state"
        )

        print(
            "OBSERVED "
                .. fixture.language
                .. " pointer identity: "
                .. fact.name
                .. "@"
                .. tostring(fact.source_line)
                .. "(binding="
                .. tostring(metadata.pointer_binding or "none")
                .. ",target="
                .. tostring(metadata.pointer_target or "none")
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
            path = "samples/c/c_memory_observation_validation.c",
            expected = {
                {
                    name = "malloc",
                    binding = "block",
                    target = nil,
                },
                {
                    name = "calloc",
                    binding = "zeroed",
                    target = nil,
                },
                {
                    name = "realloc",
                    binding = "resized",
                    target = "block",
                },
                {
                    name = "free",
                    binding = nil,
                    target = "zeroed",
                },
                {
                    name = "free",
                    binding = nil,
                    target = "block",
                },
            },
        },
        {
            language = "cpp",
            path = "samples/cpp/cpp_memory_observation_validation.cpp",
            expected = {
                {
                    name = "new",
                    binding = "single",
                    target = nil,
                },
                {
                    name = "delete",
                    binding = nil,
                    target = "single",
                },
                {
                    name = "new",
                    binding = "array",
                    target = nil,
                },
                {
                    name = "delete",
                    binding = nil,
                    target = "array",
                },
            },
        },
    }

    for _, fixture in ipairs(fixtures) do
        run_fixture(observations, fixture)
    end

    print(
        "PASS C/C++ source-memory pointer identity semantics without runtime-state inference"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL C/C++ pointer identity smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
