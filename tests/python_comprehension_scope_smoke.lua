-- tests/python_comprehension_scope_smoke.lua
--
-- Parser-backed Python comprehension ownership baseline.
--
-- Python comprehensions create implicit scopes for iteration targets, but
-- assignment expressions inside a comprehension bind in the containing
-- non-comprehension scope. The nested fixture makes that distinction explicit:
-- deep must skip both comprehension scopes rather than stopping at the nearest
-- lexical frame.

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


local function find_member(members, name, kind)
    for _, member in ipairs(members or {}) do
        if member.name == name
            and (kind == nil or member.kind == kind)
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
        .. "(kind="
        .. tostring(member.kind or "?")
        .. ",lex="
        .. tostring(member.scope_depth or "?")
        .. ")"
end


local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local registry =
        require("tracker_hud.adapters.registry")
    local collector =
        require("tracker_hud.scope_members")
    local ts_utils =
        require("tracker_hud.treesitter_utils")
    local adapter =
        require("tracker_hud.adapters.python.init")

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
        .. "python_comprehension_scope_validation.py"

    local lines = vim.fn.readfile(source_path)

    assert(
        type(lines) == "table" and #lines > 0,
        "Python comprehension fixture missing"
    )

    local buffer =
        vim.api.nvim_create_buf(false, true)

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

    local tree = parser_or_err:parse()[1]

    assert(
        tree,
        "Python parser yielded no tree"
    )

    local root = tree:root()

    assert(
        not root:has_error(),
        "Python comprehension fixture contains parser ERROR nodes"
    )

    local comprehensions =
        collect_nodes_by_type(
            root,
            "list_comprehension"
        )
    local clauses =
        collect_nodes_by_type(
            root,
            "for_in_clause"
        )

    print(
        "PARSER python comprehensions: list="
            .. tostring(#comprehensions)
            .. " for_in="
            .. tostring(#clauses)
    )

    assert(
        #comprehensions == 3,
        "Python comprehension fixture expected 3 list_comprehension nodes, got "
            .. tostring(#comprehensions)
    )

    assert(
        #clauses == 3,
        "Python comprehension fixture expected 3 for_in_clause nodes, got "
            .. tostring(#clauses)
    )

    local parser_targets = {}

    for _, clause in ipairs(clauses) do
        local range =
            ts_utils.get_node_range_fields(clause)
        local left =
            ts_utils.get_child_by_field_name(
                clause,
                "left"
            )

        parser_targets[range.start_line] =
            left
            and {
                node_type = left:type(),
                text = ts_utils.get_node_text(
                    left,
                    buffer
                ),
            }
            or false
    end

    print(
        "PARSER python comprehension targets: "
            .. "5="
            .. tostring(
                parser_targets[5]
                and (
                    parser_targets[5].node_type
                    .. ":"
                    .. parser_targets[5].text
                )
                or "none"
            )
            .. " 11="
            .. tostring(
                parser_targets[11]
                and (
                    parser_targets[11].node_type
                    .. ":"
                    .. parser_targets[11].text
                )
                or "none"
            )
            .. " 13="
            .. tostring(
                parser_targets[13]
                and (
                    parser_targets[13].node_type
                    .. ":"
                    .. parser_targets[13].text
                )
                or "none"
            )
    )

    assert(
        parser_targets[5]
            and parser_targets[5].node_type == "identifier"
            and parser_targets[5].text == "item",
        "outer comprehension target parser shape changed"
    )

    assert(
        parser_targets[11]
            and parser_targets[11].node_type == "identifier"
            and parser_targets[11].text == "inner",
        "nested comprehension target parser shape changed"
    )

    assert(
        parser_targets[13]
            and parser_targets[13].node_type == "identifier"
            and parser_targets[13].text == "outer_item",
        "outer nested comprehension target parser shape changed"
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

    local item =
        find_member(all_members, "item", "loop_variable")
    local inner =
        find_member(all_members, "inner", "loop_variable")
    local outer_item =
        find_member(all_members, "outer_item", "loop_variable")
    local captured =
        find_member(all_members, "captured", "assignment")
    local seen =
        find_member(all_members, "seen", "assignment")
    local deep =
        find_member(all_members, "deep", "assignment")

    print(
        "OBSERVED python comprehension targets: "
            .. "item=" .. member_text(item)
            .. " inner=" .. member_text(inner)
            .. " outer_item=" .. member_text(outer_item)
    )

    print(
        "OBSERVED python comprehension walrus: "
            .. "captured=" .. member_text(captured)
            .. " seen=" .. member_text(seen)
            .. " deep=" .. member_text(deep)
    )

    assert(
        item and item.line == 5 and item.scope_depth == 3,
        "outer comprehension target must belong to implicit comprehension scope"
    )

    assert(
        outer_item
            and outer_item.line == 13
            and outer_item.scope_depth == 3,
        "outer nested comprehension target must belong to outer implicit comprehension scope"
    )

    assert(
        inner and inner.line == 11 and inner.scope_depth == 4,
        "inner comprehension target must belong to nested implicit comprehension scope"
    )

    assert(
        captured
            and captured.line == 4
            and captured.scope_depth == 2,
        "comprehension body walrus must bind in containing function scope"
    )

    assert(
        seen and seen.line == 6 and seen.scope_depth == 2,
        "comprehension filter walrus must bind in containing function scope"
    )

    assert(
        deep and deep.line == 10 and deep.scope_depth == 2,
        "nested comprehension walrus must skip every comprehension scope"
    )

    local function_scope =
        collector.select(
            discovery,
            {
                cursor_line = 15,
                scope_depth = 2,
            }
        )

    assert(
        find_member(function_scope, "captured", "assignment")
            and find_member(function_scope, "seen", "assignment")
            and find_member(function_scope, "deep", "assignment"),
        "comprehension walrus bindings missing from containing function view"
    )

    assert(
        not find_member(function_scope, "item", "loop_variable")
            and not find_member(
                function_scope,
                "outer_item",
                "loop_variable"
            )
            and not find_member(
                function_scope,
                "inner",
                "loop_variable"
            ),
        "comprehension iteration target leaked into containing function scope"
    )

    print(
        "PASS Python comprehension target + walrus ownership semantics"
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
        "FAIL Python comprehension scope smoke: "
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
