-- tests/python_import_binding_smoke.lua
--
-- Real-parser Python import-binding baseline.
--
-- This test intentionally starts from Python source semantics rather than
-- Adapter Contract tables. It should expose exactly which binding forms the
-- current collector still gets wrong before shared runtime behavior changes.

local function has_name(
    members,
    wanted
)
    for _, member in ipairs(
        members or {}
    ) do
        if member.name == wanted then
            return true
        end
    end

    return false
end


local function member_names(
    members
)
    local result = {}

    for _, member in ipairs(
        members or {}
    ) do
        table.insert(
            result,
            tostring(
                member.kind or "?"
            )
                .. ":"
                .. tostring(
                    member.name or "?"
                )
                .. "@"
                .. tostring(
                    member.line or "?"
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

    local registered,
        register_err =
        registry.register(
            adapter
        )

    assert(
        registered,
        "Python adapter registration failed: "
            .. tostring(
                register_err
            )
    )

    local path =
        "samples/python/python_import_bindings_validation.py"

    local lines =
        vim.fn.readfile(
            path
        )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python import-binding validation source missing"
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

    local parser_ok,
        parser_or_err =
        pcall(
            vim.treesitter.get_parser,
            buffer,
            "python"
        )

    assert(
        parser_ok
            and parser_or_err,
        "Missing Tree-sitter 'python' parser: "
            .. tostring(
                parser_or_err
            )
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
        "Python import-binding fixture contains parser ERROR nodes"
    )

    local all =
        collector.collect(
            buffer,
            root,
            adapter,
            {
                cursor_line =
                    #lines,
            }
        )

    local printed =
        member_names(
            all
        )

    print(
        "COLLECTED python imports ("
            .. tostring(
                #all
            )
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

    local expected_bindings = {
        "math",
        "jsonlib",
        "os",
        "sys",
        "xml",
        "Path",
        "Queue",
        "Counter",
    }

    for _, expected_name in ipairs(
        expected_bindings
    ) do
        assert(
            has_name(
                all,
                expected_name
            ),
            "python import binding missing from real syntax: "
                .. expected_name
        )
    end

    local forbidden_bindings = {
        "json",
        "json as jsonlib",
        "xml.etree",
        "pathlib",
        "deque",
        "deque as Queue",
        "collections",
    }

    for _, forbidden_name in ipairs(
        forbidden_bindings
    ) do
        assert(
            not has_name(
                all,
                forbidden_name
            ),
            "python import exposed source spelling instead of binding: "
                .. forbidden_name
        )
    end

    assert(
        #all == #expected_bindings,
        "python import binding collection emitted unexpected member count: "
            .. tostring(
                #all
            )
    )

    for index, expected_name in ipairs(
        expected_bindings
    ) do
        local actual =
            all[index]
            and all[index].name
            or nil

        assert(
            actual == expected_name,
            "python import binding order changed at position "
                .. tostring(index)
                .. ": expected "
                .. expected_name
                .. ", got "
                .. tostring(actual)
        )
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
                cursor_line =
                    #lines,
            }
        )

    assert(
        table.concat(
            member_names(
                selected
            ),
            "\n"
        )
            == table.concat(
                member_names(
                    all
                ),
                "\n"
            ),
        "python import shared discovery changed final binding set"
    )

    local visibility_cases = {
        {
            source =
                "import json as jsonlib",
            names = {
                "jsonlib",
            },
        },
        {
            source =
                "import os, sys",
            names = {
                "os",
                "sys",
            },
        },
        {
            source =
                "import xml.etree",
            names = {
                "xml",
            },
        },
        {
            source =
                "from collections import deque as Queue, Counter",
            names = {
                "Queue",
                "Counter",
            },
        },
    }

    for _, case in ipairs(
        visibility_cases
    ) do
        local declaration_line =
            nil

        for line_number,
            line_text in ipairs(
                lines
            )
        do
            if line_text == case.source then
                declaration_line =
                    line_number
                break
            end
        end

        assert(
            declaration_line
                and declaration_line
                    > 1,
            "python import visibility source line missing: "
                .. case.source
        )

        local before =
            collector.collect(
                buffer,
                root,
                adapter,
                {
                    cursor_line =
                        declaration_line
                        - 1,
                }
            )

        local at =
            collector.collect(
                buffer,
                root,
                adapter,
                {
                    cursor_line =
                        declaration_line,
                }
            )

        for _, expected_name in ipairs(
            case.names
        ) do
            assert(
                not has_name(
                    before,
                    expected_name
                ),
                "python import binding leaked before source line: "
                    .. expected_name
            )

            assert(
                has_name(
                    at,
                    expected_name
                ),
                "python import binding missing ON source line: "
                    .. expected_name
            )
        end
    end

    pcall(
        vim.api.nvim_buf_delete,
        buffer,
        {
            force = true,
        }
    )

    print(
        "PASS Python parser-backed import binding semantics"
    )
end


local ok,
    err =
    pcall(run)

if ok then
    vim.cmd("qa!")
else
    vim.api.nvim_err_writeln(
        "FAIL Python import-binding smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
end
