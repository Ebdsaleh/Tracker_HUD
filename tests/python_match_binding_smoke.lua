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
                .. ",struct="
                .. tostring(
                    member.structural_depth
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
    local ts_utils =
        require(
            "tracker_hud.treesitter_utils"
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

    local case_node =
        ts_utils.find_first_descendant_by_type(
            root,
            "case_clause"
        )

    assert(
        case_node,
        "Python match-binding fixture missing case_clause"
    )

    local case_construct, case_err =
        registry.parse_node(
            "python",
            case_node,
            buffer
        )

    assert(
        case_construct
            and case_construct.scope
            and case_construct.scope.kind
                == "structural"
            and case_construct.scope.affects_visibility
                == true
            and case_construct.scope.owns_members
                == true,
        "Python case_clause structural scope policy changed: "
            .. tostring(case_err)
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
        { name = "payload", case_line = 12 },
        { name = "head", case_line = 15 },
        { name = "tail", case_line = 15 },
        { name = "name", case_line = 18 },
        { name = "rest", case_line = 18 },
        { name = "x", case_line = 21 },
        { name = "label", case_line = 21 },
        { name = "point", case_line = 21 },
        { name = "item", case_line = 27 },
    }

    assert(
        #captures == #expected,
        "python match binding collection emitted unexpected member count: "
            .. tostring(#captures)
    )

    for index, wanted in ipairs(
        expected
    ) do
        local actual =
            captures[index]

        assert(
            actual
                and actual.name
                    == wanted.name,
            "python match binding order changed at position "
                .. tostring(index)
                .. ": expected "
                .. wanted.name
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
                .. wanted.name
                .. ": expected 2, got "
                .. tostring(
                    actual.scope_depth
                )
        )

        assert(
            actual.structural_depth == 2,
            "python match capture changed structural depth for "
                .. wanted.name
                .. ": expected 2, got "
                .. tostring(
                    actual.structural_depth
                )
        )

        assert(
            actual.structural_scope_start_line
                == wanted.case_line,
            "python match capture lost case-clause ownership for "
                .. wanted.name
                .. ": expected structural start line "
                .. tostring(wanted.case_line)
                .. ", got "
                .. tostring(
                    actual.structural_scope_start_line
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
