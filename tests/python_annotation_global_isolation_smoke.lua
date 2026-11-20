-- tests/python_annotation_global_isolation_smoke.lua
--
-- Parser-backed interaction between annotation-owned type parameters and
-- ordinary global binding redirection.
--
-- A nested global declaration must target the module namespace even when an
-- enclosing generic function exposes a type parameter with the same name.

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
    name,
    line
)
    for _, member in ipairs(members or {}) do
        if member.name == name
            and member.line == line
        then
            return member
        end
    end

    return nil
end


local function same_scope(
    left,
    right
)
    return left
        and right
        and left.scope_depth
            == right.scope_depth
        and left.scope_start_line
            == right.scope_start_line
        and left.scope_end_line
            == right.scope_end_line
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
        .. "python_annotation_global_validation.py"

    local lines =
        vim.fn.readfile(
            source_path
        )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python annotation/global fixture missing"
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
        "Python annotation/global fixture contains parser ERROR nodes"
    )

    local globals =
        collect_nodes_by_type(
            root,
            "global_statement"
        )

    assert(
        #globals == 1,
        "Python annotation/global fixture expected 1 global statement"
    )

    local discovery =
        collector.discover(
            buffer,
            root,
            adapter,
            {}
        )

    local members =
        collector.select(
            discovery,
            {}
        )

    local module_seed =
        find_member(
            members,
            "T",
            1
        )

    local type_t =
        find_member(
            members,
            "T",
            3
        )

    local inner_assignment =
        find_member(
            members,
            "T",
            6
        )

    assert(
        module_seed
            and type_t
            and inner_assignment,
        "Python annotation/global fixture members missing"
    )

    assert(
        type_t.kind
            == "type_parameter"
            and type_t.annotation_depth
                == 1,
        "generic function type parameter baseline changed"
    )

    print(
        "OBSERVED python annotation/global isolation: "
            .. "module=T@1(lex="
            .. tostring(
                module_seed.scope_depth
            )
            .. ") type=T@3(lex="
            .. tostring(
                type_t.scope_depth
            )
            .. ",annotation="
            .. tostring(
                type_t.annotation_depth
            )
            .. ") T@6->lex="
            .. tostring(
                inner_assignment.scope_depth
            )
    )

    assert(
        same_scope(
            inner_assignment,
            module_seed
        ),
        "global binding did not redirect past annotation ownership to module scope"
    )

    assert(
        not same_scope(
            inner_assignment,
            type_t
        ),
        "annotation-owned type parameter intercepted global binding"
    )

    print(
        "PASS Python global binding bypasses annotation ownership"
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
        "FAIL Python annotation/global isolation smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
