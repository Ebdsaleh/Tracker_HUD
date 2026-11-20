-- tests/python_structural_member_render_smoke.lua
--
-- Parser-backed rendered Scope Members coverage for Python structural
-- ownership. This exercises the actual HUD section renderer rather than a
-- test-only representation of the tree.

local function find_section(
    sections,
    wanted_id
)
    for _, section in ipairs(
        sections or {}
    ) do
        if type(section) == "table"
            and section.id == wanted_id
        then
            return section
        end
    end

    return nil
end


local function find_line(
    lines,
    needle
)
    for index, line in ipairs(
        lines or {}
    ) do
        if type(line) == "string"
            and line:find(
                needle,
                1,
                true
            )
        then
            return index, line
        end
    end

    return nil, nil
end


local function leading_spaces(
    line
)
    local prefix =
        type(line) == "string"
        and line:match("^(%s*)")
        or ""

    return #prefix
end


local function find_scope_node(
    nodes,
    label
)
    for _, node in ipairs(nodes or {}) do
        if type(node) == "table" then
            if node.kind == "scope"
                and node.label == label
            then
                return node
            end

            local nested =
                find_scope_node(
                    node.children,
                    label
                )

            if nested then
                return nested
            end
        end
    end

    return nil
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
    local hud_sections =
        require(
            "tracker_hud.hud_sections"
        )
    local hud_nodes =
        require(
            "tracker_hud.hud_nodes"
        )
    local config_module =
        require(
            "tracker_hud.config"
        )
    local adapter =
        require(
            "tracker_hud.adapters.python.init"
        )

    registry.clear()
    hud_nodes.reset()

    local registered, register_err =
        registry.register(adapter)

    assert(
        registered,
        "Python adapter registration failed: "
            .. tostring(register_err)
    )

    local source_path =
        "samples/python/"
        .. "python_nested_structural_ownership_validation.py"

    local lines =
        vim.fn.readfile(
            source_path
        )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python structural render source missing"
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

    vim.bo[buffer].filetype =
        "python"

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

    local root =
        tree:root()

    assert(
        not root:has_error(),
        "Python structural render fixture contains parser ERROR nodes"
    )

    local members =
        collector.collect(
            buffer,
            root,
            adapter,
            {
                cursor_line =
                    #lines,
            }
        )

    local payload_member = nil

    for _, member in ipairs(members) do
        if member.name == "payload" then
            payload_member = member
            break
        end
    end

    assert(
        payload_member
            and payload_member.source_start_line
            and payload_member.source_start_column
            and payload_member.scope_start_line
            and payload_member.scope_end_line,
        "parser-backed payload member range missing"
    )

    local context = {
        scope_members = members,
        all_scope_members = members,

        -- HUD context columns are one-based before rendering normalizes them.
        cursor = {
            line =
                payload_member.source_start_line,
            column =
                payload_member.source_start_column
                + 1,
        },

        section_order = {
            "scope_members",
        },
    }

    local config =
        config_module.resolve({
            visual_language = {
                mode = "plain",
            },
        })

    local function render()
        local sections =
            hud_sections.build(
                context,
                {
                    panel_width = 200,
                    config = config,
                }
            )

        local scope_members =
            find_section(
                sections,
                "scope_members"
            )

        assert(
            type(scope_members)
                == "table",
            "rendered Scope Members section missing"
        )

        return scope_members
    end

    local rendered =
        render()

    assert(
        rendered.active == true,
        "payload cursor must activate Scope Members section"
    )

    local expected_lexical_range =
        "[scope "
        .. tostring(
            payload_member.scope_start_line
        )
        .. " - "
        .. tostring(
            payload_member.scope_end_line
        )
        .. "]"

    local lexical_index,
        lexical_line =
        find_line(
            rendered.lines,
            expected_lexical_range
        )

    local source_index,
        source_line =
        find_line(
            rendered.lines,
            "(param) source"
        )

    local while_index,
        while_line =
        find_line(
            rendered.lines,
            "While"
        )

    local with_index,
        with_line =
        find_line(
            rendered.lines,
            "With"
        )

    local match_index,
        match_line =
        find_line(
            rendered.lines,
            "Match"
        )

    local case_index,
        case_line =
        find_line(
            rendered.lines,
            "Case"
        )

    local payload_index,
        payload_line =
        find_line(
            rendered.lines,
            "payload"
        )

    assert(
        lexical_index
            and source_index
            and while_index
            and with_index
            and match_index
            and case_index
            and payload_index,
        "rendered structural Scope Members hierarchy is incomplete"
    )

    assert(
        source_index < while_index
            and while_index < with_index
            and with_index < match_index
            and match_index < case_index
            and case_index < payload_index,
        "rendered structural Scope Members order changed"
    )

    assert(
        leading_spaces(source_line) == 3,
        "direct lexical member indentation changed"
    )

    assert(
        leading_spaces(while_line) == 2
            and leading_spaces(with_line) == 4
            and leading_spaces(match_line) == 6
            and leading_spaces(case_line) == 8
            and leading_spaces(payload_line) == 10,
        "rendered structural Scope Members indentation changed"
    )

    assert(
        lexical_line:find(
            "*[-]",
            1,
            true
        )
            and while_line:find(
                "*[-]",
                1,
                true
            )
            and with_line:find(
                "*[-]",
                1,
                true
            )
            and match_line:find(
                "*[-]",
                1,
                true
            )
            and case_line:find(
                "*[-]",
                1,
                true
            )
            and payload_line:find(
                "*[+]",
                1,
                true
            ),
        "payload cursor active path did not propagate through structural scopes"
    )

    print(
        "RENDER python structural members: "
            .. "cursor="
            .. tostring(
                context.cursor.line
            )
            .. ":"
            .. tostring(
                context.cursor.column
            )
            .. ", lexical="
            .. expected_lexical_range
            .. " | "
            .. table.concat({
                source_line,
                while_line,
                with_line,
                match_line,
                case_line,
                payload_line,
            }, " | ")
    )

    local tree_nodes =
        tree_builder.build(
            members,
            {}
        )

    local case_node =
        find_scope_node(
            tree_nodes,
            "Case"
        )

    assert(
        case_node
            and case_node.id,
        "Case structural node missing before collapse"
    )

    hud_nodes.collapse(
        case_node.id
    )

    local collapsed =
        render()

    local collapsed_case_index,
        collapsed_case_line =
        find_line(
            collapsed.lines,
            "Case"
        )

    local collapsed_payload_index =
        find_line(
            collapsed.lines,
            "payload"
        )

    assert(
        collapsed_case_index
            and collapsed_case_line:find(
                "*[+]",
                1,
                true
            ),
        "collapsed Case structural node must remain visible and active"
    )

    assert(
        collapsed_payload_index == nil,
        "collapsed Case structural node must hide descendant payload member"
    )

    print(
        "PASS Python rendered structural hierarchy + active path + collapse"
    )

    hud_nodes.reset()

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end


local ok, err =
    pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Python structural Scope Members render smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
