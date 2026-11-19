-- tests/python_structural_member_tree_smoke.lua
--
-- Parser-backed Scope Members tree coverage for nested Python structural
-- ownership. Lexical scope remains the semantic root while the persisted
-- structural path becomes nested display hierarchy beneath it.

local function find_member_path(
    nodes,
    member_name,
    path
)
    path = path or {}

    for _, node in ipairs(nodes or {}) do
        if type(node) == "table" then
            local current_path =
                vim.deepcopy(path)

            table.insert(
                current_path,
                node
            )

            if type(node.member) == "table"
                and node.member.name
                    == member_name
            then
                return current_path
            end

            local nested =
                find_member_path(
                    node.children,
                    member_name,
                    current_path
                )

            if nested then
                return nested
            end
        end
    end

    return nil
end


local function assert_member_path(
    tree_nodes,
    member_name,
    expected_structural
)
    local path =
        find_member_path(
            tree_nodes,
            member_name
        )

    assert(
        type(path) == "table"
            and #path >= 2,
        "missing Scope Members tree path for "
            .. member_name
    )

    local lexical_scope = path[1]

    assert(
        lexical_scope.kind == "scope"
            and lexical_scope.scope_kind
                ~= "structural",
        "member "
            .. member_name
            .. " lost lexical scope root"
    )

    local member_node =
        path[#path]

    assert(
        member_node.kind == "member"
            and type(member_node.member)
                == "table"
            and member_node.member.name
                == member_name,
        "member "
            .. member_name
            .. " tree leaf changed"
    )

    assert(
        lexical_scope.scope_start_line
            == member_node.member.scope_start_line
            and lexical_scope.scope_end_line
                == member_node.member.scope_end_line,
        "member "
            .. member_name
            .. " lexical root range changed"
    )

    local structural_count =
        #path - 2

    assert(
        structural_count
            == #expected_structural,
        "member "
            .. member_name
            .. " structural tree depth changed: expected "
            .. tostring(
                #expected_structural
            )
            .. ", got "
            .. tostring(
                structural_count
            )
    )

    for index, expected in ipairs(
        expected_structural
    ) do
        local node =
            path[index + 1]

        assert(
            node.kind == "scope"
                and node.scope_kind
                    == "structural"
                and node.structural_depth
                    == index
                and node.node_type
                    == expected.node_type
                and node.label
                    == expected.label
                and node.scope_start_line
                    == expected.start_line,
            "member "
                .. member_name
                .. " structural tree frame changed at depth "
                .. tostring(index)
                .. ": expected "
                .. expected.node_type
                .. "@"
                .. tostring(
                    expected.start_line
                )
                .. ", got "
                .. tostring(
                    node
                    and node.node_type
                    or nil
                )
                .. "@"
                .. tostring(
                    node
                    and node.scope_start_line
                    or nil
                )
        )
    end

    local printed = {
        "lexical@"
            .. tostring(
                lexical_scope.scope_start_line
                or "?"
            ),
    }

    for index = 2, #path - 1 do
        local node = path[index]

        table.insert(
            printed,
            tostring(node.label or "?")
                .. "@"
                .. tostring(
                    node.scope_start_line
                    or "?"
                )
        )
    end

    table.insert(
        printed,
        "member:"
            .. member_name
    )

    return table.concat(
        printed,
        ">"
    )
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
    local tree_builder =
        require(
            "tracker_hud.scope_member_tree"
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
        .. "python_nested_structural_ownership_validation.py"

    local lines = vim.fn.readfile(path)

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python nested structural ownership source missing"
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
        "Python structural tree fixture contains parser ERROR nodes"
    )

    local members =
        collector.collect(
            buffer,
            root,
            adapter,
            {
                cursor_line = #lines,
            }
        )

    local tree_nodes =
        tree_builder.build(
            members,
            {}
        )

    local while_frame = {
        node_type = "while_statement",
        label = "While",
        start_line = 11,
    }

    local with_frame = {
        node_type = "with_statement",
        label = "With",
        start_line = 13,
    }

    local match_frame = {
        node_type = "match_statement",
        label = "Match",
        start_line = 15,
    }

    local case_frame = {
        node_type = "case_clause",
        label = "Case",
        start_line = 16,
    }

    local printed = {
        assert_member_path(
            tree_nodes,
            "source",
            {}
        ),
        assert_member_path(
            tree_nodes,
            "outer_seen",
            {
                while_frame,
            }
        ),
        assert_member_path(
            tree_nodes,
            "handle",
            {
                while_frame,
                with_frame,
            }
        ),
        assert_member_path(
            tree_nodes,
            "payload",
            {
                while_frame,
                with_frame,
                match_frame,
                case_frame,
            }
        ),
        assert_member_path(
            tree_nodes,
            "nested",
            {
                while_frame,
                with_frame,
                match_frame,
                case_frame,
            }
        ),
    }

    print(
        "TREE python structural members: "
            .. table.concat(
                printed,
                " | "
            )
    )

    print(
        "PASS Python Scope Members lexical-root structural hierarchy"
    )

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end


local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Python structural Scope Members tree smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
