-- tests/python_for_binding_smoke.lua
--
-- Real-parser Python for-target binding baseline.
--
-- This intentionally starts from real Tree-sitter syntax. The collection is
-- printed before assertions so a RED run identifies the exact missing binding
-- semantics before production code changes.

local function loop_members(members)
    local result = {}

    for _, member in ipairs(members or {}) do
        if member.kind == "loop_variable" then
            table.insert(result, member)
        end
    end

    return result
end


local function loop_names(members)
    local result = {}

    for _, member in ipairs(loop_members(members)) do
        table.insert(result, member.name)
    end

    return result
end


local function printed_loops(members)
    local result = {}

    for _, member in ipairs(loop_members(members)) do
        table.insert(
            result,
            tostring(member.name or "?")
                .. "@"
                .. tostring(member.line or "?")
                .. ":"
                .. tostring(member.source_start_column or "?")
        )
    end

    return result
end


local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local adapter = require("tracker_hud.adapters.python.init")

    registry.clear()

    local registered, register_err =
        registry.register(adapter)

    assert(
        registered,
        "Python adapter registration failed: "
            .. tostring(register_err)
    )

    local path =
        "samples/python/python_for_bindings_validation.py"

    local lines = vim.fn.readfile(path)

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python for-binding validation source missing"
    )

    local buffer =
        vim.api.nvim_create_buf(false, true)

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

    local tree = parser_or_err:parse()[1]

    assert(
        tree,
        "Python parser yielded no tree"
    )

    local root = tree:root()

    assert(
        not root:has_error(),
        "Python for-binding fixture contains parser ERROR nodes"
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

    local loops = loop_members(all)
    local printed = printed_loops(all)

    print(
        "COLLECTED python for bindings ("
            .. tostring(#loops)
            .. "): "
            .. (
                #printed > 0
                and table.concat(printed, ", ")
                or "<empty collection>"
            )
    )

    local expected = {
        "key",
        "value",
        "head",
        "tail",
    }

    assert(
        #loops == #expected,
        "python for binding collection emitted unexpected member count: "
            .. tostring(#loops)
    )

    for index, expected_name in ipairs(expected) do
        local actual =
            loops[index]
            and loops[index].name
            or nil

        assert(
            actual == expected_name,
            "python for binding order changed at position "
                .. tostring(index)
                .. ": expected "
                .. expected_name
                .. ", got "
                .. tostring(actual)
        )
    end

    for _, forbidden in ipairs({
        "key, value",
        "head, *tail",
        "*tail",
    }) do
        for _, actual in ipairs(loop_names(all)) do
            assert(
                actual ~= forbidden,
                "python for target exposed syntax instead of binding: "
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
        table.concat(loop_names(selected), "\n")
            == table.concat(expected, "\n"),
        "python for binding discover/select parity changed"
    )

    print(
        "PASS Python parser-backed for-target binding semantics"
    )

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end


local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Python for-binding smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
