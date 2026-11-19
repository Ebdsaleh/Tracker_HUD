-- tests/python_named_expression_binding_smoke.lua
--
-- Real-parser Python assignment-expression binding baseline.
--
-- The fixture covers named expressions in if, while, and return contexts so
-- the adapter must model the binding itself rather than one enclosing syntax
-- form.

local function named_assignments(members)
    local result = {}

    for _, member in ipairs(members or {}) do
        if member.kind == "assignment" then
            table.insert(result, member)
        end
    end

    return result
end


local function assignment_names(members)
    local result = {}

    for _, member in ipairs(
        named_assignments(members)
    ) do
        table.insert(
            result,
            member.name
        )
    end

    return result
end


local function printed_assignments(members)
    local result = {}

    for _, member in ipairs(
        named_assignments(members)
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
        .. "python_named_expression_bindings_validation.py"

    local lines = vim.fn.readfile(path)

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python named-expression validation source missing"
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
        "Python named-expression fixture contains parser ERROR nodes"
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

    local assignments =
        named_assignments(all)

    local printed =
        printed_assignments(all)

    print(
        "COLLECTED python named-expression bindings ("
            .. tostring(#assignments)
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
        "captured",
        "chunk",
        "final",
    }

    assert(
        #assignments == #expected,
        "python named-expression binding collection emitted unexpected member count: "
            .. tostring(#assignments)
    )

    for index, expected_name in ipairs(
        expected
    ) do
        local actual =
            assignments[index]
            and assignments[index].name
            or nil

        assert(
            actual == expected_name,
            "python named-expression binding order changed at position "
                .. tostring(index)
                .. ": expected "
                .. expected_name
                .. ", got "
                .. tostring(actual)
        )
    end

    for _, forbidden in ipairs({
        "captured := source",
        "chunk := reader()",
        "final := captured",
    }) do
        for _, actual in ipairs(
            assignment_names(all)
        ) do
            assert(
                actual ~= forbidden,
                "python named expression exposed syntax instead of binding: "
                    .. forbidden
            )
        end
    end

    local discovery =
        collector.discover(
            buffer,
            root,
            adapter
        )

    local selected =
        collector.select(
            discovery,
            {
                cursor_line = #lines,
            }
        )

    assert(
        table.concat(
            assignment_names(selected),
            "\n"
        )
            == table.concat(
                expected,
                "\n"
            ),
        "python named-expression discover/select parity changed"
    )

    print(
        "PASS Python parser-backed named-expression binding semantics"
    )

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end


local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Python named-expression binding smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
