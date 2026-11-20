-- tests/python_scope_member_shadowing_global_redirect_smoke.lua
--
-- Parser-backed guardrail for global ownership redirection and shadow
-- provenance.
--
-- A binding assignment redirected to module ownership by global must not be
-- described as shadowing an enclosing function parameter merely because the
-- assignment is textually nested inside that function.

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
            and member.kind == kind
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
        .. "python_scope_member_shadowing_global_redirect_validation.py"

    local lines =
        vim.fn.readfile(
            source_path
        )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python global-shadow redirect fixture missing"
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
        "Python global-shadow redirect fixture contains parser ERROR nodes"
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

    local module_value =
        find_member(
            members,
            "value",
            1,
            "assignment"
        )

    local outer_value =
        find_member(
            members,
            "value",
            3,
            "parameter"
        )

    local redirected_value =
        find_member(
            members,
            "value",
            6,
            "assignment"
        )

    assert(
        module_value
            and outer_value
            and redirected_value,
        "Python global-shadow redirect members missing"
    )

    assert(
        module_value.scope_depth == 1
            and outer_value.scope_depth == 2,
        "Python global-shadow baseline ownership changed"
    )

    assert(
        same_scope(
            redirected_value,
            module_value
        ),
        "global assignment did not resolve to module ownership"
    )

    print(
        "OBSERVED python Scope Member global redirect shadowing: "
            .. "module=value@1->"
            .. tostring(
                module_value.shadows_member_id
                    or "none"
            )
            .. " outer=value@3->"
            .. tostring(
                outer_value.shadows_member_id
                    or "none"
            )
            .. " global=value@6(lex="
            .. tostring(
                redirected_value.scope_depth
            )
            .. ")->"
            .. tostring(
                redirected_value.shadows_member_id
                    or "none"
            )
    )

    assert(
        module_value.shadows_member_id
            == nil,
        "module binding must not report a shadow target"
    )

    assert(
        outer_value.shadows_member_id
            == module_value.id,
        "ordinary nested parameter stopped shadowing module binding"
    )

    assert(
        redirected_value.shadows_member_id
            == nil,
        "global-redirected assignment acquired false shadow provenance"
    )

    print(
        "PASS Python global redirect does not create lexical shadow provenance"
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
        "FAIL Python global redirect Scope Member shadowing smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
