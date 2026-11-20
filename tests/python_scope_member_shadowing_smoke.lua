-- tests/python_scope_member_shadowing_smoke.lua
--
-- Parser-backed first tranche for shared Scope Member lexical shadowing.
--
-- The model should preserve every declaration while annotating the inner
-- lexical binding with the nearest enclosing ordinary lexical binding that it
-- shadows. This is model provenance only; no HUD decoration is required here.

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
        .. "python_scope_member_shadowing_validation.py"

    local lines =
        vim.fn.readfile(
            source_path
        )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python shadowing fixture missing"
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
        "Python shadowing fixture contains parser ERROR nodes"
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

    local outer_value =
        find_member(
            members,
            "value",
            1,
            "parameter"
        )

    local inner_value =
        find_member(
            members,
            "value",
            2,
            "parameter"
        )

    assert(
        outer_value
            and inner_value,
        "Python shadowing fixture parameter members missing"
    )

    assert(
        outer_value.scope_depth == 2
            and inner_value.scope_depth == 3,
        "Python shadowing fixture lexical depths changed"
    )

    assert(
        outer_value.id
            and inner_value.id
            and outer_value.id
                ~= inner_value.id,
        "Python shadowing fixture member identities collapsed"
    )

    print(
        "OBSERVED python Scope Member shadowing: "
            .. "outer=value@1(lex="
            .. tostring(
                outer_value.scope_depth
            )
            .. ",shadows="
            .. tostring(
                outer_value.shadows_member_id
                    or "none"
            )
            .. ") inner=value@2(lex="
            .. tostring(
                inner_value.scope_depth
            )
            .. ",shadows="
            .. tostring(
                inner_value.shadows_member_id
                    or "none"
            )
            .. ")"
    )

    assert(
        outer_value.shadows_member_id
            == nil,
        "outer binding must not report a shadow target"
    )

    assert(
        inner_value.shadows_member_id
            == outer_value.id,
        "inner binding did not identify nearest enclosing lexical binding as its shadow target"
    )

    print(
        "PASS Scope Member model records nearest enclosing lexical shadow target"
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
        "FAIL Python Scope Member shadowing smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
