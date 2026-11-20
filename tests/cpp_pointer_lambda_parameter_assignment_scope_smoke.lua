-- tests/cpp_pointer_lambda_parameter_assignment_scope_smoke.lua
--
-- Real-parser C++ direct pointer-lineage lambda-parameter assignment baseline.
--
-- A lambda pointer parameter is a lambda-callable binding. Assigning an
-- allocation to it inside a nested block must not shorten that binding to the
-- nested block. This remains direct source identity only: no alias, ownership,
-- liveness, release-success, path, escape, RAII, or leak inference.

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
        "cpp lambda-parameter fixture contains ERROR nodes"
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
        "cpp lambda parameter assignment must not invent runtime state"
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
                    "void run_lambda_scope() {",
                    "    auto fn = [](int *ptr) {",
                    "        {",
                    "            ptr = new int(1);",
                    "        }",
                    "        delete ptr;",
                    "    };",
                    "    (void)fn;",
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
        #facts == 2,
        "cpp expected exactly 2 lambda source-memory observations, got "
            .. tostring(#facts)
    )

    local producer = facts[1]
    local release = facts[2]
    local producer_metadata = producer.metadata or {}
    local release_metadata = release.metadata or {}

    assert(
        producer.name == "new"
            and producer_metadata.pointer_binding == "ptr",
        "cpp nested lambda assignment must publish direct ptr producer"
    )

    assert(
        release.name == "delete"
            and release_metadata.pointer_target == "ptr",
        "cpp post-block lambda delete must observe direct ptr target"
    )

    assert(
        release_metadata.pointer_predecessor_id == producer.id,
        "cpp post-block lambda delete expected predecessor "
            .. tostring(producer.id)
            .. ", got "
            .. tostring(release_metadata.pointer_predecessor_id)
    )

    assert(
        release_metadata.pointer_predecessor_relation
            == "direct_source_identity",
        "cpp lambda parameter assignment must retain direct_source_identity"
    )

    assert_runtime_unknown(producer)
    assert_runtime_unknown(release)

    print(
        "OBSERVED cpp lambda-parameter pointer: "
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

    print(
        "PASS C++ assignment-produced pointer identity retains lambda parameter binding scope"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL C++ pointer lambda-parameter assignment scope smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
