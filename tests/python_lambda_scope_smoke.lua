-- tests/python_lambda_scope_smoke.lua
--
-- Real-parser Python lambda lexical-scope + parameter baseline.
--
-- This deliberately checks both normalized parameter names and scope depth so
-- a future regression cannot keep the names while silently losing ownership.

local function parameter_members(members)
    local result = {}

    for _, member in ipairs(members or {}) do
        if member.kind == "parameter" then
            table.insert(result, member)
        end
    end

    return result
end


local function printed_parameters(members)
    local result = {}

    for _, member in ipairs(
        parameter_members(members)
    ) do
        table.insert(
            result,
            tostring(member.name or "?")
                .. "@"
                .. tostring(member.line or "?")
                .. ":"
                .. tostring(
                    member.source_start_column
                    or "?"
                )
                .. "(depth="
                .. tostring(
                    member.scope_depth
                    or "?"
                )
                .. ")"
        )
    end

    return result
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

    local path =
        "samples/python/"
        .. "python_lambda_scope_validation.py"

    local lines = vim.fn.readfile(path)

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python lambda validation source missing"
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
        "Python lambda fixture contains parser ERROR nodes"
    )

    local all =
        collector.collect(
            buffer,
            root,
            adapter,
            {
                cursor_line = #lines,
            }
        )

    local parameters =
        parameter_members(all)

    local printed =
        printed_parameters(all)

    print(
        "COLLECTED python lambda parameters ("
            .. tostring(#parameters)
            .. "): "
            .. (
                #printed > 0
                and table.concat(
                    printed,
                    ", "
                )
                or "<empty collection>"
            )
    )

    local expected = {
        { name = "value", depth = 1 },
        { name = "source", depth = 1 },
        { name = "count", depth = 1 },
        { name = "items", depth = 1 },
        { name = "enabled", depth = 1 },
        { name = "options", depth = 1 },
        { name = "outer", depth = 1 },
        { name = "inner", depth = 2 },
    }

    assert(
        #parameters == #expected,
        "python lambda parameter collection emitted unexpected member count: "
            .. tostring(#parameters)
    )

    for index, expected_member in ipairs(
        expected
    ) do
        local actual =
            parameters[index]

        assert(
            actual
                and actual.name
                    == expected_member.name,
            "python lambda parameter order changed at position "
                .. tostring(index)
                .. ": expected "
                .. expected_member.name
                .. ", got "
                .. tostring(
                    actual
                    and actual.name
                    or nil
                )
        )

        assert(
            actual.scope_depth
                == expected_member.depth,
            "python lambda parameter scope depth changed for "
                .. expected_member.name
                .. ": expected "
                .. tostring(
                    expected_member.depth
                )
                .. ", got "
                .. tostring(
                    actual.scope_depth
                )
        )
    end

    for _, forbidden in ipairs({
        "*items",
        "**options",
        "count=1",
        "enabled=True",
    }) do
        for _, actual in ipairs(
            parameters
        ) do
            assert(
                actual.name ~= forbidden,
                "python lambda parameter exposed syntax instead of binding: "
                    .. forbidden
            )
        end
    end

    print(
        "PASS Python parser-backed lambda lexical scope + parameter semantics"
    )

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end


local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Python lambda scope smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
