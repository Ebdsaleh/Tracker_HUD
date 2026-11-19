-- tests/python_nested_structural_ownership_smoke.lua
--
-- Real-parser coverage for independent lexical and structural ownership.
--
-- Python while/with/match/case constructs do not add lexical namespaces, but
-- Tracker_HUD must retain their nested structural ownership for HUD hierarchy.

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
        .. "python_nested_structural_ownership_validation.py"

    local lines = vim.fn.readfile(path)

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python nested structural ownership source missing"
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
        "Python nested structural fixture contains parser ERROR nodes"
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

    local wanted_by_name = {
        outer_seen = {
            kind = "assignment",
            structural_depth = 1,
            structural_start_line = 11,
        },
        handle = {
            kind = "assignment",
            structural_depth = 2,
            structural_start_line = 13,
        },
        managed = {
            kind = "assignment",
            structural_depth = 2,
            structural_start_line = 13,
        },
        payload = {
            kind = "pattern_binding",
            structural_depth = 4,
            structural_start_line = 16,
        },
        nested = {
            kind = "assignment",
            structural_depth = 4,
            structural_start_line = 16,
        },
    }

    local expected_order = {
        "outer_seen",
        "handle",
        "managed",
        "payload",
        "nested",
    }

    local selected = {}

    for _, member in ipairs(all) do
        if wanted_by_name[member.name] then
            table.insert(
                selected,
                member
            )
        end
    end

    local printed = {}

    for _, member in ipairs(selected) do
        table.insert(
            printed,
            tostring(member.kind or "?")
                .. ":"
                .. tostring(member.name or "?")
                .. "@"
                .. tostring(member.line or "?")
                .. "(lex="
                .. tostring(
                    member.scope_depth
                    or "?"
                )
                .. ",struct="
                .. tostring(
                    member.structural_depth
                    or "?"
                )
                .. ",owner="
                .. tostring(
                    member.structural_scope_start_line
                    or "?"
                )
                .. ")"
        )
    end

    print(
        "COLLECTED python nested structural members ("
            .. tostring(#selected)
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

    assert(
        #selected == #expected_order,
        "python nested structural ownership emitted unexpected member count: "
            .. tostring(#selected)
    )

    for index, expected_name in ipairs(
        expected_order
    ) do
        local actual =
            selected[index]

        local wanted =
            wanted_by_name[
                expected_name
            ]

        assert(
            actual
                and actual.name
                    == expected_name,
            "python nested structural member order changed at position "
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
            actual.kind == wanted.kind,
            "python nested structural member kind changed for "
                .. expected_name
                .. ": expected "
                .. wanted.kind
                .. ", got "
                .. tostring(actual.kind)
        )

        assert(
            actual.scope_depth == 2,
            "python nested structural scope changed lexical depth for "
                .. expected_name
                .. ": expected 2, got "
                .. tostring(
                    actual.scope_depth
                )
        )

        assert(
            actual.structural_depth
                == wanted.structural_depth,
            "python nested structural depth changed for "
                .. expected_name
                .. ": expected "
                .. tostring(
                    wanted.structural_depth
                )
                .. ", got "
                .. tostring(
                    actual.structural_depth
                )
        )

        assert(
            actual.structural_scope_start_line
                == wanted.structural_start_line,
            "python nested structural owner changed for "
                .. expected_name
                .. ": expected line "
                .. tostring(
                    wanted.structural_start_line
                )
                .. ", got "
                .. tostring(
                    actual.structural_scope_start_line
                )
        )
    end

    print(
        "PASS Python parser-backed nested structural ownership semantics"
    )

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end


local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Python nested structural ownership smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
