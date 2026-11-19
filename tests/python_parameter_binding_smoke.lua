-- tests/python_parameter_binding_smoke.lua
--
-- Real-parser Python parameter-binding baseline.
--
-- Print parser-backed parameter members before semantic assertions so a RED
-- result identifies the actual grammar/collector gap before runtime changes.

local function parameter_members(members)
    local result = {}

    for _, member in ipairs(members or {}) do
        if member.kind == "parameter" then
            table.insert(result, member)
        end
    end

    return result
end


local function parameter_names(members)
    local result = {}

    for _, member in ipairs(parameter_members(members)) do
        table.insert(result, member.name)
    end

    return result
end


local function printed_parameters(members)
    local result = {}

    for _, member in ipairs(parameter_members(members)) do
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
        "samples/python/python_parameter_bindings_validation.py"

    local lines = vim.fn.readfile(path)

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python parameter-binding validation source missing"
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
        "Python parameter-binding fixture contains parser ERROR nodes"
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
        "COLLECTED python parameters ("
            .. tostring(#parameters)
            .. "): "
            .. (
                #printed > 0
                and table.concat(printed, ", ")
                or "<empty collection>"
            )
    )

    local expected = {
        "source",
        "count",
        "items",
        "enabled",
        "options",
        "primary",
        "mode",
        "retries",
    }

    assert(
        #parameters == #expected,
        "python parameter collection emitted unexpected member count: "
            .. tostring(#parameters)
    )

    for index, expected_name in ipairs(expected) do
        local actual =
            parameters[index]
            and parameters[index].name
            or nil

        assert(
            actual == expected_name,
            "python parameter binding order changed at position "
                .. tostring(index)
                .. ": expected "
                .. expected_name
                .. ", got "
                .. tostring(actual)
        )
    end

    for _, forbidden in ipairs({
        "/",
        "*",
        "*items",
        "**options",
        "count: int",
        "mode: str",
    }) do
        for _, actual in ipairs(
            parameter_names(all)
        ) do
            assert(
                actual ~= forbidden,
                "python parameter exposed syntax instead of binding: "
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
            parameter_names(selected),
            "\n"
        )
            == table.concat(
                expected,
                "\n"
            ),
        "python parameter discover/select parity changed"
    )

    print(
        "PASS Python parser-backed parameter binding semantics"
    )

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end


local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Python parameter-binding smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
