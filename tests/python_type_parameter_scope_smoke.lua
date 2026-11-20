-- tests/python_type_parameter_scope_smoke.lua
--
-- Parser-backed PEP 695 annotation-scope baseline.
--
-- Type parameters are not ordinary runtime lexical bindings. They belong to
-- annotation scopes that overlay the containing declaration and remain visible
-- through nested lexical scopes inside a generic function/class.

local function collect_nodes_by_type(node, wanted, out)
    out = out or {}

    if node:type() == wanted then
        table.insert(out, node)
    end

    for child in node:iter_children() do
        collect_nodes_by_type(child, wanted, out)
    end

    return out
end


local function named_children(node)
    local result = {}

    if not node then
        return result
    end

    for child in node:iter_children() do
        if child:named() then
            table.insert(result, child)
        end
    end

    return result
end


local function same_node_range(left, right)
    if not left or not right then
        return false
    end

    local left_range =
        require("tracker_hud.treesitter_utils")
            .get_node_range_fields(left)
    local right_range =
        require("tracker_hud.treesitter_utils")
            .get_node_range_fields(right)

    return left_range.start_line
            == right_range.start_line
        and left_range.start_column
            == right_range.start_column
        and left_range.end_line
            == right_range.end_line
        and left_range.end_column
            == right_range.end_column
end


local function parser_parameter_text(node, bufnr)
    local result = {}

    for _, child in ipairs(
        named_children(node)
    ) do
        table.insert(
            result,
            child:type()
                .. ":"
                .. tostring(
                    vim.treesitter.get_node_text(
                        child,
                        bufnr
                    )
                )
        )
    end

    return table.concat(result, ",")
end


local function type_parameter_members(members)
    local result = {}

    for _, member in ipairs(members or {}) do
        if member.kind == "type_parameter" then
            table.insert(result, member)
        end
    end

    return result
end


local function find_type_parameter(
    members,
    name,
    line
)
    for _, member in ipairs(
        type_parameter_members(members)
    ) do
        if member.name == name
            and member.line == line
        then
            return member
        end
    end

    return nil
end


local function member_text(member)
    if not member then
        return "missing"
    end

    return tostring(member.name or "?")
        .. "@"
        .. tostring(member.line or "?")
        .. "(lex="
        .. tostring(member.scope_depth or "?")
        .. ",annotation="
        .. tostring(
            member.annotation_depth
            or "?"
        )
        .. ")"
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
        .. "python_type_parameter_scope_validation.py"

    local lines = vim.fn.readfile(
        source_path
    )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python type-parameter fixture missing"
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
        "Python type-parameter fixture contains parser ERROR nodes"
    )

    local raw_parameter_nodes =
        collect_nodes_by_type(
            root,
            "type_parameter"
        )

    local parameter_nodes = {}
    local raw_shapes = {}

    for _, node in ipairs(
        raw_parameter_nodes
    ) do
        local range =
            ts_utils
                .get_node_range_fields(
                    node
                )
        local parent = node:parent()
        local parent_type =
            parent
            and parent:type()
            or "none"
        local parent_text =
            parent
            and vim.treesitter
                .get_node_text(
                    parent,
                    buffer
                )
            or "none"

        table.insert(
            raw_shapes,
            tostring(
                range.start_line
            )
                .. "="
                .. parent_type
                .. ":"
                .. tostring(
                    parent_text
                )
                .. "["
                .. parser_parameter_text(
                    node,
                    buffer
                )
                .. "]"
        )

        local is_declaration =
            parent_type
                == "function_definition"
            or parent_type
                == "class_definition"

        if not is_declaration
            and parent_type
                == "generic_type"
        then
            local grandparent =
                parent:parent()

            if grandparent
                and grandparent:type()
                    == "type_alias_statement"
            then
                local alias_left =
                    ts_utils
                        .get_child_by_field_name(
                            grandparent,
                            "left"
                        )

                is_declaration =
                    same_node_range(
                        alias_left,
                        parent
                    )
            end
        end

        if is_declaration then
            table.insert(
                parameter_nodes,
                node
            )
        end
    end

    print(
        "PARSER python raw type-parameter nodes: "
            .. table.concat(
                raw_shapes,
                " | "
            )
    )

    print(
        "PARSER python type-parameter scopes: raw="
            .. tostring(
                #raw_parameter_nodes
            )
            .. " declaration="
            .. tostring(
                #parameter_nodes
            )
    )

    assert(
        #raw_parameter_nodes == 5,
        "Python type-parameter fixture expected 5 raw type_parameter nodes, got "
            .. tostring(
                #raw_parameter_nodes
            )
    )

    assert(
        #parameter_nodes == 3,
        "Python type-parameter fixture expected 3 declaration type_parameter nodes, got "
            .. tostring(
                #parameter_nodes
            )
    )

    local parser_by_line = {}

    for _, node in ipairs(
        parameter_nodes
    ) do
        local range =
            ts_utils
                .get_node_range_fields(
                    node
                )
        local parent = node:parent()

        parser_by_line[
            range.start_line
        ] = {
            parent_type =
                parent
                and parent:type()
                or "none",
            parameters =
                parser_parameter_text(
                    node,
                    buffer
                ),
        }
    end

    print(
        "PARSER python type parameters: "
            .. "alias@1="
            .. tostring(
                parser_by_line[1]
                and (
                    parser_by_line[1]
                        .parent_type
                    .. "["
                    .. parser_by_line[1]
                        .parameters
                    .. "]"
                )
                or "none"
            )
            .. " function@3="
            .. tostring(
                parser_by_line[3]
                and (
                    parser_by_line[3]
                        .parent_type
                    .. "["
                    .. parser_by_line[3]
                        .parameters
                    .. "]"
                )
                or "none"
            )
            .. " class@8="
            .. tostring(
                parser_by_line[8]
                and (
                    parser_by_line[8]
                        .parent_type
                    .. "["
                    .. parser_by_line[8]
                        .parameters
                    .. "]"
                )
                or "none"
            )
    )

    assert(
        parser_by_line[1]
            and parser_by_line[1]
                .parent_type
                == "generic_type"
            and parser_by_line[1]
                .parameters
                == "identifier:T",
        "generic type-alias parameter parser shape changed"
    )

    assert(
        parser_by_line[3]
            and parser_by_line[3]
                .parent_type
                == "function_definition"
            and parser_by_line[3]
                .parameters
                == "identifier:T,constrained_type:U: str",
        "generic function parameter parser shape changed"
    )

    assert(
        parser_by_line[8]
            and parser_by_line[8]
                .parent_type
                == "class_definition"
            and parser_by_line[8]
                .parameters
                == "identifier:T,splat_type:*Ts,splat_type:**P",
        "generic class parameter parser shape changed"
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

    local alias_t =
        find_type_parameter(
            all_members,
            "T",
            1
        )
    local function_t =
        find_type_parameter(
            all_members,
            "T",
            3
        )
    local function_u =
        find_type_parameter(
            all_members,
            "U",
            3
        )
    local class_t =
        find_type_parameter(
            all_members,
            "T",
            8
        )
    local class_ts =
        find_type_parameter(
            all_members,
            "Ts",
            8
        )
    local class_p =
        find_type_parameter(
            all_members,
            "P",
            8
        )

    print(
        "OBSERVED python type parameters: "
            .. "alias="
            .. member_text(alias_t)
            .. " function="
            .. member_text(function_t)
            .. ","
            .. member_text(function_u)
            .. " class="
            .. member_text(class_t)
            .. ","
            .. member_text(class_ts)
            .. ","
            .. member_text(class_p)
    )

    assert(
        #type_parameter_members(
            all_members
        ) == 6,
        "Python PEP 695 type parameters are not modeled as annotation-scope members"
    )

    assert(
        alias_t
            and alias_t.scope_depth == 1
            and alias_t.annotation_depth
                == 1,
        "generic type-alias T ownership changed"
    )

    assert(
        function_t
            and function_t.scope_depth
                == 2
            and function_t
                .annotation_depth
                == 1
            and function_u
            and function_u.scope_depth
                == 2
            and function_u
                .annotation_depth
                == 1,
        "generic function type-parameter ownership changed"
    )

    assert(
        class_t
            and class_t.scope_depth == 2
            and class_t.annotation_depth
                == 1
            and class_ts
            and class_ts.scope_depth
                == 2
            and class_ts.annotation_depth
                == 1
            and class_p
            and class_p.scope_depth
                == 2
            and class_p.annotation_depth
                == 1,
        "generic class type-parameter ownership changed"
    )

    local inside_nested_function =
        collector.select(
            discovery,
            {
                cursor_line = 5,
                scope_depth = 3,
            }
        )

    assert(
        find_type_parameter(
            inside_nested_function,
            "T",
            3
        )
            and find_type_parameter(
                inside_nested_function,
                "U",
                3
            ),
        "generic function annotation scope did not survive nested lexical scope"
    )

    local inside_method =
        collector.select(
            discovery,
            {
                cursor_line = 12,
                scope_depth = 3,
            }
        )

    assert(
        find_type_parameter(
            inside_method,
            "T",
            8
        )
            and find_type_parameter(
                inside_method,
                "Ts",
                8
            )
            and find_type_parameter(
                inside_method,
                "P",
                8
            ),
        "generic class annotation scope did not survive method lexical scope"
    )

    local after_generic_scopes =
        collector.select(
            discovery,
            {
                cursor_line = 14,
                scope_depth = 1,
            }
        )

    assert(
        not find_type_parameter(
            after_generic_scopes,
            "T",
            3
        )
            and not find_type_parameter(
                after_generic_scopes,
                "U",
                3
            )
            and not find_type_parameter(
                after_generic_scopes,
                "T",
                8
            )
            and not find_type_parameter(
                after_generic_scopes,
                "Ts",
                8
            )
            and not find_type_parameter(
                after_generic_scopes,
                "P",
                8
            ),
        "type parameter leaked outside its annotation scope"
    )

    print(
        "PASS Python PEP 695 annotation-scope ownership semantics"
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
        "FAIL Python type-parameter scope smoke: "
            .. tostring(err)
            .. string.char(10)
    )

    error(
        err,
        0
    )
else
    vim.cmd("qa!")
end
