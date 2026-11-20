-- tests/cpp_range_for_lifetime_smoke.lua
--
-- Real-parser C++ range-for loop-variable lifetime baseline.
--
-- C++ already discovers the range-for variable as a Scope Member. This
-- guardrail requires that its visibility be bounded by the structural
-- range-for scope rather than leaking through the remainder of the enclosing
-- function.

local function find_member(
    members,
    name,
    kind
)
    for _, member in ipairs(
        members or {}
    ) do
        if member.name == name
            and member.kind == kind
        then
            return member
        end
    end

    return nil
end


local function has_member(
    members,
    name,
    kind
)
    return find_member(
        members,
        name,
        kind
    ) ~= nil
end


local function find_line(
    lines,
    needle
)
    for index, line in ipairs(
        lines or {}
    ) do
        if line:find(
            needle,
            1,
            true
        )
        then
            return index
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
            "tracker_hud.adapters.cpp.init"
        )

    registry.clear()

    local registered, register_err =
        registry.register(adapter)

    assert(
        registered,
        "C++ adapter registration failed: "
            .. tostring(register_err)
    )

    local path =
        "samples/cpp/cpp_adapter_validation.cpp"

    local lines =
        vim.fn.readfile(path)

    assert(
        type(lines) == "table"
            and #lines > 0,
        "C++ validation source missing"
    )

    local loop_line =
        find_line(
            lines,
            "for (int item : items)"
        )
    local body_line =
        loop_line
            and loop_line + 1
            or nil
    local after_line =
        find_line(
            lines,
            "Record record{ counter.value() };"
        )

    assert(
        loop_line
            and body_line
            and after_line,
        "C++ range-for validation lines missing"
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
        "cpp"

    local parser_ok, parser_or_err =
        pcall(
            vim.treesitter.get_parser,
            buffer,
            "cpp"
        )

    assert(
        parser_ok and parser_or_err,
        "Missing Tree-sitter 'cpp' parser: "
            .. tostring(parser_or_err)
    )

    local tree =
        parser_or_err:parse()[1]

    assert(
        tree,
        "C++ parser yielded no tree"
    )

    local root =
        tree:root()

    assert(
        not root:has_error(),
        "C++ range-for fixture contains parser ERROR nodes"
    )

    local discovery =
        collector.discover(
            buffer,
            root,
            adapter
        )

    local all =
        collector.select(
            discovery,
            {}
        )

    local item =
        find_member(
            all,
            "item",
            "loop_variable"
        )

    assert(
        item,
        "C++ range-for loop variable 'item' missing"
    )

    print(
        "OBSERVED cpp range-for binding: "
            .. tostring(
                item.name
                    or "?"
            )
            .. "@"
            .. tostring(
                item.line
                    or "?"
            )
            .. "(lex="
            .. tostring(
                item.scope_depth
                    or "?"
            )
            .. ",owner="
            .. tostring(
                item.scope_start_line
                    or "?"
            )
            .. "-"
            .. tostring(
                item.scope_end_line
                    or "?"
            )
            .. ",visible="
            .. tostring(
                item.visibility_start_line
                    or "none"
            )
            .. "-"
            .. tostring(
                item.visibility_end_line
                    or "none"
            )
            .. ")"
    )

    assert(
        item.visibility_start_line
            == loop_line
            and item.visibility_end_line
                == after_line - 2,
        "C++ range-for loop variable must use the loop structural range as its visibility lifetime"
    )

    local inside =
        collector.select(
            discovery,
            {
                cursor_line =
                    body_line,
                start_line =
                    item.scope_start_line,
                end_line =
                    item.scope_end_line,
            }
        )

    local after =
        collector.select(
            discovery,
            {
                cursor_line =
                    after_line,
                start_line =
                    item.scope_start_line,
                end_line =
                    item.scope_end_line,
            }
        )

    assert(
        has_member(
            inside,
            "item",
            "loop_variable"
        ),
        "C++ range-for loop variable must be visible inside the loop body"
    )

    assert(
        not has_member(
            after,
            "item",
            "loop_variable"
        ),
        "C++ range-for loop variable leaked past the loop lifetime"
    )

    print(
        "PASS C++ parser-backed range-for loop-variable lifetime semantics"
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
        "FAIL C++ range-for lifetime smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
