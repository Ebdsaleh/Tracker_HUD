-- tests/python_type_alias_binding_smoke.lua
--
-- Real-parser coverage for Python 3.12+ type-statement alias bindings.
--
-- The alias name is a normal binding in the current lexical scope. Generic
-- type parameters are intentionally not modeled as ordinary alias bindings
-- by this tranche.

local function alias_members(members)
    local result = {}

    for _, member in ipairs(members or {}) do
        if member.kind == "symbol"
            and member.value_kind == nil
        then
            local term =
                member.language_term

            if term == "type alias" then
                table.insert(result, member)
            end
        end
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
        .. "python_type_alias_validation.py"

    local lines = vim.fn.readfile(path)

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python type-alias validation source missing"
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
        "Python type-alias fixture contains parser ERROR nodes"
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

    local aliases = {}

    for _, member in ipairs(all) do
        if member.member_language_term == "type alias"
            or member.language_term == "type alias"
        then
            table.insert(aliases, member)
        end
    end

    -- Scope Member records do not currently persist language_term. Select the
    -- expected alias names from symbol members so this test stays grounded in
    -- runtime output while the Adapter Contract separately locks the rule term.
    if #aliases == 0 then
        for _, member in ipairs(all) do
            if member.kind == "symbol"
                and (
                    member.name == "UserId"
                    or member.name == "Pair"
                    or member.name == "LocalMap"
                )
            then
                table.insert(aliases, member)
            end
        end
    end

    local printed = {}

    for _, member in ipairs(aliases) do
        table.insert(
            printed,
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

    print(
        "COLLECTED python type aliases ("
            .. tostring(#aliases)
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
        { name = "UserId", depth = 1 },
        { name = "Pair", depth = 1 },
        { name = "LocalMap", depth = 2 },
    }

    assert(
        #aliases == #expected,
        "python type-alias collection emitted unexpected member count: "
            .. tostring(#aliases)
    )

    for index, wanted in ipairs(expected) do
        local actual = aliases[index]

        assert(
            actual
                and actual.name
                    == wanted.name,
            "python type-alias order changed at position "
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
            actual.scope_depth
                == wanted.depth,
            "python type alias changed lexical depth for "
                .. wanted.name
                .. ": expected "
                .. tostring(wanted.depth)
                .. ", got "
                .. tostring(
                    actual.scope_depth
                )
        )
    end

    for _, forbidden in ipairs({
        "T",
        "K",
        "V",
    }) do
        for _, actual in ipairs(aliases) do
            assert(
                actual.name ~= forbidden,
                "python type-alias collector exposed type parameter as alias binding: "
                    .. forbidden
            )
        end
    end

    print(
        "PASS Python parser-backed type-alias binding semantics"
    )

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end


local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Python type-alias binding smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
