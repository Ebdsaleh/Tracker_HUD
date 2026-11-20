-- tests/python_exception_alias_lifetime_smoke.lua
--
-- Parser-backed Python exception-alias lifetime semantics.
--
-- Python clears an exception alias after its handler. Tracker_HUD must retain
-- the source-declared alias in the all-members view while limiting the current
-- view to the structural except-clause lifetime.

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


local function find_member(
    members,
    name
)
    for _, member in ipairs(
        members or {}
    ) do
        if member.name == name then
            return member
        end
    end

    return nil
end


local function has_member(
    members,
    name
)
    return find_member(
        members,
        name
    ) ~= nil
end


local function structural_path_text(
    member
)
    local parts = {}

    for _, frame in ipairs(
        member
            and member.structural_path
            or {}
    ) do
        table.insert(
            parts,
            tostring(
                frame.label
                or frame.node_type
                or "?"
            )
        )
    end

    return table.concat(
        parts,
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
        .. "python_exception_alias_lifetime_validation.py"

    local lines =
        vim.fn.readfile(
            source_path
        )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python exception-alias fixture missing"
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
        "Python exception-alias fixture contains parser ERROR nodes"
    )

    local clauses =
        collect_nodes_by_type(
            root,
            "except_clause"
        )

    assert(
        #clauses == 3,
        "Python exception fixture expected 3 except_clause nodes, got "
            .. tostring(
                #clauses
            )
    )

    local parser_aliases = {}

    for _, clause in ipairs(
        clauses
    ) do
        local range =
            ts_utils.get_node_range_fields(
                clause
            )
        local value =
            ts_utils.get_child_by_field_name(
                clause,
                "value"
            )
        local alias =
            value
            and value:type()
                == "as_pattern"
            and ts_utils.get_child_by_field_name(
                value,
                "alias"
            )
            or nil

        parser_aliases[
            range.start_line
        ] =
            alias
            and {
                value_node_type =
                    value:type(),
                node_type =
                    alias:type(),
                text =
                    ts_utils.get_node_text(
                        alias,
                        buffer
                    ),
            }
            or false
    end

    print(
        "OBSERVED parser exception aliases: "
            .. "5="
            .. tostring(
                parser_aliases[5]
                    and (
                        parser_aliases[5].value_node_type
                        .. ">"
                        .. parser_aliases[5].node_type
                        .. ":"
                        .. tostring(
                            parser_aliases[5].text
                        )
                    )
                    or "none"
            )
            .. " 12="
            .. tostring(
                parser_aliases[12]
                    and (
                        parser_aliases[12].value_node_type
                        .. ">"
                        .. parser_aliases[12].node_type
                        .. ":"
                        .. tostring(
                            parser_aliases[12].text
                        )
                    )
                    or "none"
            )
            .. " 18="
            .. tostring(
                parser_aliases[18]
                    and (
                        parser_aliases[18].value_node_type
                        .. ">"
                        .. parser_aliases[18].node_type
                        .. ":"
                        .. tostring(
                            parser_aliases[18].text
                        )
                    )
                    or "none"
            )
    )

    assert(
        parser_aliases[5]
            and parser_aliases[5].value_node_type
                == "as_pattern"
            and parser_aliases[5].node_type
                == "as_pattern_target"
            and parser_aliases[5].text
                == "err",
        "Python ordinary except alias parser shape changed"
    )

    assert(
        parser_aliases[12]
            and parser_aliases[12].value_node_type
                == "as_pattern"
            and parser_aliases[12].node_type
                == "as_pattern_target"
            and parser_aliases[12].text
                == "group",
        "Python except* alias parser shape changed"
    )

    assert(
        parser_aliases[18] == false,
        "bare except unexpectedly exposed an alias field"
    )

    local discovery =
        collector.discover(
            buffer,
            root,
            adapter,
            {}
        )

    local all_members =
        collector.select(
            discovery,
            {}
        )

    local first_inside =
        collector.select(
            discovery,
            {
                cursor_line = 6,
            }
        )

    local after_first =
        collector.select(
            discovery,
            {
                cursor_line = 8,
            }
        )

    local group_inside =
        collector.select(
            discovery,
            {
                cursor_line = 13,
            }
        )

    local after_group =
        collector.select(
            discovery,
            {
                cursor_line = 14,
            }
        )

    local err =
        find_member(
            all_members,
            "err"
        )

    local group =
        find_member(
            all_members,
            "group"
        )

    print(
        "OBSERVED exception members: "
            .. "err="
            .. tostring(
                err
                and (
                    "line="
                    .. tostring(err.line)
                    .. ",lex="
                    .. tostring(
                        err.scope_depth
                    )
                    .. ",struct="
                    .. tostring(
                        err.structural_depth
                    )
                    .. ",path="
                    .. structural_path_text(
                        err
                    )
                    .. ",visible="
                    .. tostring(
                        err.visibility_start_line
                    )
                    .. "-"
                    .. tostring(
                        err.visibility_end_line
                    )
                )
                or "missing"
            )
            .. " group="
            .. tostring(
                group
                and (
                    "line="
                    .. tostring(group.line)
                    .. ",lex="
                    .. tostring(
                        group.scope_depth
                    )
                    .. ",struct="
                    .. tostring(
                        group.structural_depth
                    )
                    .. ",path="
                    .. structural_path_text(
                        group
                    )
                    .. ",visible="
                    .. tostring(
                        group.visibility_start_line
                    )
                    .. "-"
                    .. tostring(
                        group.visibility_end_line
                    )
                )
                or "missing"
            )
    )

    print(
        "OBSERVED exception visibility: "
            .. "line6(err="
            .. tostring(
                has_member(
                    first_inside,
                    "err"
                )
            )
            .. ",group="
            .. tostring(
                has_member(
                    first_inside,
                    "group"
                )
            )
            .. ") line8(err="
            .. tostring(
                has_member(
                    after_first,
                    "err"
                )
            )
            .. ",group="
            .. tostring(
                has_member(
                    after_first,
                    "group"
                )
            )
            .. ") line13(err="
            .. tostring(
                has_member(
                    group_inside,
                    "err"
                )
            )
            .. ",group="
            .. tostring(
                has_member(
                    group_inside,
                    "group"
                )
            )
            .. ") line14(err="
            .. tostring(
                has_member(
                    after_group,
                    "err"
                )
            )
            .. ",group="
            .. tostring(
                has_member(
                    after_group,
                    "group"
                )
            )
            .. ")"
    )

    assert(
        err and group,
        "Python exception aliases missing from all-members discovery"
    )

    assert(
        err.kind == "assignment"
            and err.line == 5
            and err.scope_depth == 2,
        "ordinary exception alias lexical/member semantics changed"
    )

    assert(
        group.kind == "assignment"
            and group.line == 12
            and group.scope_depth == 2,
        "except* alias lexical/member semantics changed"
    )

    assert(
        err.structural_depth == 2
            and structural_path_text(err)
                == "Try>Except",
        "ordinary exception alias structural ownership changed"
    )

    assert(
        group.structural_depth == 2
            and structural_path_text(group)
                == "Try>Except",
        "except* alias structural ownership changed"
    )

    assert(
        err.visibility_start_line == 5
            and err.visibility_end_line == 7,
        "ordinary exception alias lifetime range changed"
    )

    assert(
        group.visibility_start_line == 12
            and group.visibility_end_line == 13,
        "except* alias lifetime range changed"
    )

    assert(
        has_member(
            first_inside,
            "err"
        )
            and not has_member(
                first_inside,
                "group"
            ),
        "ordinary exception alias not visible only inside first handler"
    )

    assert(
        not has_member(
            after_first,
            "err"
        )
            and not has_member(
                after_first,
                "group"
            ),
        "ordinary exception alias leaked after first handler"
    )

    assert(
        not has_member(
            group_inside,
            "err"
        )
            and has_member(
                group_inside,
                "group"
            ),
        "except* alias lifetime did not isolate second handler"
    )

    assert(
        not has_member(
            after_group,
            "err"
        )
            and not has_member(
                after_group,
                "group"
            ),
        "exception alias leaked after handler lifetime"
    )

    assert(
        not has_member(
            all_members,
            "ValueError"
        )
            and not has_member(
                all_members,
                "Exception"
            ),
        "exception type was mistaken for an alias binding"
    )

    print(
        "PARSER python exception aliases: "
            .. "except@5=as_pattern>as_pattern_target:err "
            .. "except*@12=as_pattern>as_pattern_target:group "
            .. "bare@18=no-alias"
    )

    print(
        "LIFETIME python exception aliases: "
            .. "err@5=5-7(path=Try>Except,lex=2) "
            .. "group@12=12-13(path=Try>Except,lex=2)"
    )

    print(
        "VISIBILITY python exception aliases: "
            .. "line6=err "
            .. "line8=none "
            .. "line13=group "
            .. "line14=none "
            .. "all=err,group"
    )

    print(
        "PASS Python exception aliases respect structural lifetime"
    )

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end


local ok, err =
    xpcall(
        run,
        debug.traceback
    )

if not ok then
    io.stderr:write(
        "FAIL Python exception alias lifetime smoke: "
            .. tostring(err)
            .. string.char(10)
    )

    -- Propagate to the outer test harness so its redirected stderr captures the
    -- real assertion instead of terminating here before the temp log flushes.
    error(
        err,
        0
    )
else
    vim.cmd("qa!")
end
