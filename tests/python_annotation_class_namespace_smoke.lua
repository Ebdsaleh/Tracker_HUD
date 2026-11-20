-- tests/python_annotation_class_namespace_smoke.lua
--
-- Parser-backed Scope Member visibility for Python's annotation-scope access
-- to an immediately enclosing class namespace.
--
-- This does not implement expression reference resolution. It verifies the
-- ownership/visibility representation that makes the class member available
-- at a class-local annotation scope while ordinary method lexical scope does
-- not inherit that class member as a local binding.

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
    for _, member in ipairs(
        members or {}
    ) do
        if member.name == name
            and member.line == line
        then
            return member
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
        .. "python_annotation_class_namespace_validation.py"

    local lines =
        vim.fn.readfile(
            source_path
        )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python annotation/class-namespace fixture missing"
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
        "Python annotation/class-namespace fixture contains parser ERROR nodes"
    )

    local aliases =
        collect_nodes_by_type(
            root,
            "type_alias_statement"
        )

    assert(
        #aliases == 1,
        "Python annotation/class-namespace fixture expected 1 type alias"
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

    local seed =
        find_member(
            all_members,
            "seed",
            2
        )

    assert(
        seed,
        "class-local seed member missing"
    )

    assert(
        seed.scope_depth == 2,
        "class-local seed owner depth changed"
    )

    local annotation_view =
        collector.select(
            discovery,
            {
                cursor_line = 3,
                scope_depth = 2,
            }
        )

    local method_view =
        collector.select(
            discovery,
            {
                cursor_line = 6,
                scope_depth = 3,
            }
        )

    local annotation_seed =
        find_member(
            annotation_view,
            "seed",
            2
        )

    local method_seed =
        find_member(
            method_view,
            "seed",
            2
        )

    print(
        "OBSERVED python annotation/class namespace: "
            .. "seed@2(lex="
            .. tostring(
                seed.scope_depth
            )
            .. ") alias@3-visible="
            .. tostring(
                annotation_seed ~= nil
            )
            .. " method@6-visible="
            .. tostring(
                method_seed ~= nil
            )
    )

    assert(
        annotation_seed,
        "class member was not visible from class-local annotation scope"
    )

    assert(
        not method_seed,
        "ordinary method lexical scope incorrectly inherited class member binding"
    )

    print(
        "PASS Python annotation scope preserves enclosing class namespace visibility"
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
        "FAIL Python annotation/class namespace smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
