-- tests/python_match_binding_smoke.lua
--
-- Real-parser Python structural-pattern matching binding semantics.
--
-- The fixture intentionally includes constructor names, keyword labels, and
-- dotted constants so the collector must identify actual capture positions
-- rather than treating every identifier below a case clause as a binding.

local function pattern_bindings(members)
    local result = {}

    for _, member in ipairs(members or {}) do
        if member.kind == "pattern_binding" then
            table.insert(result, member)
        end
    end

    return result
end


local function printed_bindings(members)
    local result = {}

    for _, member in ipairs(
        pattern_bindings(members)
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
        .. "python_match_bindings_validation.py"

    local lines = vim.fn.readfile(path)

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python match-binding validation source missing"
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
        "Python match-binding fixture contains parser ERROR nodes"
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

    local captures =
        pattern_bindings(all)

    local printed =
        printed_bindings(all)

    print(
        "COLLECTED python match bindings ("
            .. tostring(#captures)
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
        "payload",
        "head",
        "tail",
        "name",
        "rest",
        "x",
        "label",
        "point",
        "item",
    }

    assert(
        #captures == #expected,
        "python match binding collection emitted unexpected member count: "
            .. tostring(#captures)
    )

    for index, expected_name in ipairs(
        expected
    ) do
        local actual =
            captures[index]

        assert(
            actual
                and actual.name
                    == expected_name,
            "python match binding order changed at position "
                .. tostring(index)
                .. ": expected "
                .. expected_name
                .. ", got "
                .. tostring(
                    actual
                    and actual.name
                    or nil
                )
        )

        assert(
            actual.scope_depth == 2,
            "python match capture changed lexical depth for "
                .. expected_name
                .. ": expected 2, got "
                .. tostring(
                    actual.scope_depth
                )
        )
    end

    for _, forbidden in ipairs({
        "Point",
        "y",
        "Status",
        "OK",
    }) do
        for _, actual in ipairs(captures) do
            assert(
                actual.name ~= forbidden,
                "python match collector exposed non-binding pattern syntax: "
                    .. forbidden
            )
        end
    end

    local discovered =
        collector.discover(
            buffer,
            root,
            adapter,
            {
                cursor_line = #lines,
            }
        )

    local selected =
        collector.select(
            discovered,
            {
                cursor_line = #lines,
            }
        )

    local selected_captures =
        pattern_bindings(selected)

    assert(
        #selected_captures == #captures,
        "python match discover/select parity changed capture count"
    )

    for index, actual in ipairs(captures) do
        assert(
            selected_captures[index]
                and selected_captures[index].name
                    == actual.name,
            "python match discover/select parity changed at position "
                .. tostring(index)
        )
    end

    print(
        "PASS Python parser-backed match-pattern binding semantics"
    )

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end


local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Python match binding smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
