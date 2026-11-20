-- tests/python_scope_member_same_scope_rebinding_smoke.lua
--
-- Parser-backed guardrail proving same-owner rebinding is not lexical
-- shadowing. Shadow provenance describes a binding in a nested lexical owner
-- hiding an enclosing binding; another assignment in the same lexical owner
-- is not a new shadow relationship.

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
        .. "python_scope_member_same_scope_rebinding_validation.py"

    local lines =
        vim.fn.readfile(
            source_path
        )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python same-scope rebinding fixture missing"
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
        "Python same-scope rebinding fixture contains parser ERROR nodes"
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

    local first_value =
        find_member(
            members,
            "value",
            2,
            "assignment"
        )

    local second_value =
        find_member(
            members,
            "value",
            3,
            "assignment"
        )

    assert(
        first_value
            and second_value,
        "Python same-scope rebinding assignments missing"
    )

    assert(
        first_value.id
            and second_value.id
            and first_value.id
                ~= second_value.id,
        "same-scope rebinding records lost distinct source identities"
    )

    assert(
        same_scope(
            first_value,
            second_value
        ),
        "same-scope rebinding assignments resolved to different owners"
    )

    print(
        "OBSERVED python Scope Member same-scope rebinding: "
            .. "first=value@2(lex="
            .. tostring(
                first_value.scope_depth
            )
            .. ",shadows="
            .. tostring(
                first_value.shadows_member_id
                    or "none"
            )
            .. ") second=value@3(lex="
            .. tostring(
                second_value.scope_depth
            )
            .. ",shadows="
            .. tostring(
                second_value.shadows_member_id
                    or "none"
            )
            .. ")"
    )

    assert(
        first_value.shadows_member_id
            == nil
            and second_value.shadows_member_id
                == nil,
        "same-owner rebinding must not create lexical shadow provenance"
    )

    print(
        "PASS Same-scope Scope Member rebinding does not create lexical shadow provenance"
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
        "FAIL Python same-scope Scope Member rebinding smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
