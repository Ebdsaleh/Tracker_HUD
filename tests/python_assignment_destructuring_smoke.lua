-- tests/python_assignment_destructuring_smoke.lua
--
-- Parser-backed Python assignment-target destructuring.
--
-- Destructuring containers may expose their terminal assignment targets, but
-- attributes/subscripts are terminal targets themselves and must never be
-- flattened into fake lexical identifiers.

local function collect_nodes_by_type(
    node,
    wanted,
    out
)
    out = out or {}

    if node:type() == wanted then
        table.insert(out, node)
    end

    for child in node:iter_children() do
        collect_nodes_by_type(
            child,
            wanted,
            out
        )
    end

    return out
end


local function expect_names(
    by_line,
    line,
    expected
)
    local actual =
        by_line[line]
        or {}

    assert(
        #actual == #expected,
        "assignment line "
            .. tostring(line)
            .. " member count mismatch: got "
            .. table.concat(
                actual,
                ","
            )
    )

    for index, name in ipairs(
        expected
    ) do
        assert(
            actual[index] == name,
            "assignment line "
                .. tostring(line)
                .. " member #"
                .. tostring(index)
                .. " mismatch: expected "
                .. tostring(name)
                .. ", got "
                .. tostring(
                    actual[index]
                )
        )
    end
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

    local source_path =
        "samples/python/"
        .. "python_assignment_destructuring_validation.py"

    local lines =
        vim.fn.readfile(
            source_path
        )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python assignment-destructuring fixture missing"
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
        "Python assignment-destructuring fixture contains parser ERROR nodes"
    )

    local assignments =
        collect_nodes_by_type(
            root,
            "assignment"
        )

    assert(
        #assignments == 8,
        "Python assignment fixture expected 8 assignment nodes, got "
            .. tostring(
                #assignments
            )
    )

    local expected_left_types = {
        [2] = "pattern_list",
        [3] = "pattern_list",
        [4] = "list_pattern",
        [5] = "pattern_list",
        [6] = "pattern_list",
        [7] = "identifier",
        [8] = "attribute",
        [9] = "subscript",
    }

    local parser_left_types = {}

    for _, node in ipairs(
        assignments
    ) do
        local range =
            ts_utils.get_node_range_fields(
                node
            )
        local left =
            ts_utils.get_child_by_field_name(
                node,
                "left"
            )

        assert(
            range
                and range.start_line
                and left,
            "assignment parser shape missing range/left"
        )

        parser_left_types[
            range.start_line
        ] =
            left:type()
    end

    for line, expected_type in pairs(
        expected_left_types
    ) do
        assert(
            parser_left_types[line]
                == expected_type,
            "assignment line "
                .. tostring(line)
                .. " left type changed: expected "
                .. expected_type
                .. ", got "
                .. tostring(
                    parser_left_types[
                        line
                    ]
                )
        )
    end

    local members =
        collector.collect(
            buffer,
            root,
            adapter,
            {
                cursor_line = #lines,
            }
        )

    local by_line = {}

    for _, member in ipairs(
        members
    ) do
        if member.kind == "assignment"
            and member.line
            and member.line >= 2
            and member.line <= 9
        then
            by_line[member.line] =
                by_line[member.line]
                or {}

            table.insert(
                by_line[member.line],
                member.name
            )
        end
    end

    expect_names(
        by_line,
        2,
        {
            "first",
            "second",
        }
    )

    expect_names(
        by_line,
        3,
        {
            "head",
            "middle",
            "tail",
        }
    )

    expect_names(
        by_line,
        4,
        {
            "left",
            "rest",
        }
    )

    expect_names(
        by_line,
        5,
        {
            "obj.root",
            "local_value",
        }
    )

    expect_names(
        by_line,
        6,
        {
            "items[0]",
            "final",
        }
    )

    expect_names(
        by_line,
        7,
        {
            "direct",
        }
    )

    expect_names(
        by_line,
        8,
        {
            "obj.direct",
        }
    )

    expect_names(
        by_line,
        9,
        {
            "items[1]",
        }
    )

    print(
        "PARSER python assignment targets: "
            .. "2=pattern_list "
            .. "3=pattern_list "
            .. "4=list_pattern "
            .. "5=pattern_list "
            .. "6=pattern_list "
            .. "7=identifier "
            .. "8=attribute "
            .. "9=subscript"
    )

    print(
        "COLLECTED python destructuring assignments: "
            .. "2=first,second | "
            .. "3=head,middle,tail | "
            .. "4=left,rest | "
            .. "5=obj.root,local_value | "
            .. "6=items[0],final | "
            .. "7=direct | "
            .. "8=obj.direct | "
            .. "9=items[1]"
    )

    print(
        "PASS Python assignment destructuring preserves terminal targets"
    )

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end


local ok, err =
    pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Python assignment destructuring smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
