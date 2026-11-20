-- tests/python_nested_annotation_class_namespace_smoke.lua
--
-- Parser-backed ownership/visibility proof for a generic type alias nested
-- immediately inside a Python class.
--
-- The alias owns an annotation-scoped type parameter while its lazily
-- evaluated value is another annotation scope. Tracker_HUD does not resolve
-- expression references here; it verifies the observable Scope Member model:
-- class-local members coexist with the alias annotation member at the alias
-- line, while neither leaks into an ordinary method lexical view.

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
    line,
    kind
)
    for _, member in ipairs(
        members or {}
    ) do
        if member.name == name
            and member.line == line
            and (
                kind == nil
                or member.kind == kind
            )
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
        .. "python_nested_annotation_class_namespace_validation.py"

    local lines =
        vim.fn.readfile(
            source_path
        )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python nested annotation/class fixture missing"
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
        "Python nested annotation/class fixture contains parser ERROR nodes"
    )

    local aliases =
        collect_nodes_by_type(
            root,
            "type_alias_statement"
        )
    local parameters =
        collect_nodes_by_type(
            root,
            "type_parameter"
        )

    assert(
        #aliases == 1,
        "Python nested annotation/class fixture expected 1 type alias"
    )

    assert(
        #parameters >= 1,
        "Python nested annotation/class fixture expected a type-parameter node"
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

    local type_t =
        find_member(
            all_members,
            "T",
            3,
            "type_parameter"
        )

    assert(
        seed
            and type_t,
        "Python nested annotation/class members missing"
    )

    assert(
        seed.scope_depth == 2,
        "class-local seed owner depth changed"
    )

    assert(
        type_t.scope_depth == 2
            and type_t.annotation_depth
                == 1,
        "generic alias T annotation ownership changed"
    )

    local alias_view =
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

    local alias_seed =
        find_member(
            alias_view,
            "seed",
            2
        )
    local alias_t =
        find_member(
            alias_view,
            "T",
            3,
            "type_parameter"
        )
    local method_seed =
        find_member(
            method_view,
            "seed",
            2
        )
    local method_t =
        find_member(
            method_view,
            "T",
            3,
            "type_parameter"
        )

    print(
        "OBSERVED python nested annotation/class namespace: "
            .. "seed@2(lex="
            .. tostring(
                seed.scope_depth
            )
            .. ") T@3(lex="
            .. tostring(
                type_t.scope_depth
            )
            .. ",annotation="
            .. tostring(
                type_t.annotation_depth
            )
            .. ") alias@3(seed="
            .. tostring(
                alias_seed ~= nil
            )
            .. ",T="
            .. tostring(
                alias_t ~= nil
            )
            .. ") method@6(seed="
            .. tostring(
                method_seed ~= nil
            )
            .. ",T="
            .. tostring(
                method_t ~= nil
            )
            .. ")"
    )

    assert(
        alias_seed
            and alias_t,
        "generic alias annotation view did not preserve class member + type parameter"
    )

    assert(
        not method_seed
            and not method_t,
        "class/generic-alias annotation members leaked into ordinary method lexical view"
    )

    print(
        "PASS Python nested annotation scope preserves class namespace without lexical leakage"
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
        "FAIL Python nested annotation/class namespace smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
