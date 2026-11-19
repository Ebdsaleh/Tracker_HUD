-- tests/python_structural_block_scope_smoke.lua
--
-- Real-parser Python structural-scope coverage for blocks that do not create
-- Python namespaces. The test locks both parsed construct policy and the
-- lexical depth of bindings nested inside those structural blocks.

local TARGET_TYPES = {
    "while_statement",
    "with_statement",
    "match_statement",
}


local function assignment_members(members)
    local result = {}

    for _, member in ipairs(members or {}) do
        if member.kind == "assignment" then
            table.insert(result, member)
        end
    end

    return result
end


local function printed_assignments(members)
    local result = {}

    for _, member in ipairs(
        assignment_members(members)
    ) do
        table.insert(
            result,
            tostring(member.name or "?")
                .. "@"
                .. tostring(member.line or "?")
                .. ":"
                .. tostring(
                    member.source_start_column
                    or "?"
                )
                .. "(depth="
                .. tostring(
                    member.scope_depth
                    or "?"
                )
                .. ")"
        )
    end

    return result
end


local function run()
    vim.opt.runtimepath:prepend(
        vim.fn.getcwd()
    )

    local registry =
        require(
            "tracker_hud.adapters.registry"
        )
    local collector =
        require(
            "tracker_hud.scope_members"
        )
    local ts_utils =
        require(
            "tracker_hud.treesitter_utils"
        )
    local adapter =
        require(
            "tracker_hud.adapters.python.init"
        )

    registry.clear()

    local registered, register_err =
        registry.register(adapter)

    assert(
        registered,
        "Python adapter registration failed: "
            .. tostring(register_err)
    )

    local path =
        "samples/python/"
        .. "python_structural_blocks_validation.py"

    local lines = vim.fn.readfile(path)

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python structural-block validation source missing"
    )

    local buffer =
        vim.api.nvim_create_buf(
            false,
            true
        )

    vim.api.nvim_buf_set_lines(
        buffer,
        0,
        -1,
        false,
        lines
    )

    vim.bo[buffer].filetype = "python"

    local parser_ok, parser_or_err =
        pcall(
            vim.treesitter.get_parser,
            buffer,
            "python"
        )

    assert(
        parser_ok and parser_or_err,
        "Missing Tree-sitter 'python' parser: "
            .. tostring(parser_or_err)
    )

    local tree =
        parser_or_err:parse()[1]

    assert(
        tree,
        "Python parser yielded no tree"
    )

    local root = tree:root()

    assert(
        not root:has_error(),
        "Python structural-block fixture contains parser ERROR nodes"
    )

    local parsed_scopes = {}

    for _, node_type in ipairs(
        TARGET_TYPES
    ) do
        local node =
            ts_utils.find_first_descendant_by_type(
                root,
                node_type
            )

        assert(
            node,
            "Python structural-block fixture missing "
                .. node_type
        )

        local construct, parse_err =
            registry.parse_node(
                "python",
                node,
                buffer
            )

        assert(
            construct,
            "Python "
                .. node_type
                .. " did not parse as a construct: "
                .. tostring(parse_err)
        )

        assert(
            construct.scope
                and construct.scope.kind
                    == "structural"
                and construct.scope
                    .affects_visibility
                    == true
                and construct.scope
                    .owns_members
                    == true,
            "Python "
                .. node_type
                .. " structural-member scope policy changed"
        )

        table.insert(
            parsed_scopes,
            node_type
                .. "="
                .. tostring(
                    construct.scope.kind
                )
        )
    end

    print(
        "PARSED python structural blocks: "
            .. table.concat(
                parsed_scopes,
                ", "
            )
    )

    local all =
        collector.collect(
            buffer,
            root,
            adapter,
            {
                cursor_line = #lines,
            }
        )

    local assignments =
        assignment_members(all)

    local printed =
        printed_assignments(all)

    print(
        "COLLECTED python structural assignments ("
            .. tostring(#assignments)
            .. "): "
            .. (
                #printed > 0
                and table.concat(
                    printed,
                    ", "
                )
                or "<empty collection>"
            )
    )

    local expected = {
        "loop_seen",
        "handle",
        "managed",
        "matched",
    }

    assert(
        #assignments == #expected,
        "python structural-block assignment collection emitted unexpected member count: "
            .. tostring(#assignments)
    )

    for index, expected_name in ipairs(
        expected
    ) do
        local actual =
            assignments[index]

        assert(
            actual
                and actual.name
                    == expected_name,
            "python structural-block binding order changed at position "
                .. tostring(index)
                .. ": expected "
                .. expected_name
                .. ", got "
                .. tostring(
                    actual
                    and actual.name
                    or nil
                )
        )

        -- Python module depth is 1 and this fixture's function depth is 2.
        -- Structural blocks must not create a third lexical namespace.
        assert(
            actual.scope_depth == 2,
            "python structural block changed lexical depth for "
                .. expected_name
                .. ": expected 2, got "
                .. tostring(
                    actual.scope_depth
                )
        )
    end

    print(
        "PASS Python parser-backed structural block scope semantics"
    )

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end


local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Python structural-block scope smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
