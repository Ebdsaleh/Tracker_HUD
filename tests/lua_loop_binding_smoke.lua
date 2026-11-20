-- tests/lua_loop_binding_smoke.lua
--
-- Real-parser Lua loop-variable binding baseline.
--
-- The Lua adapter already declares numeric and generic for-clause bindings.
-- This guardrail proves those high-level declarations survive real
-- Tree-sitter parsing and shared Scope Member discovery before richer member
-- semantics are built on top of them.

local function loop_members(members)
    local result = {}

    for _, member in ipairs(
        members or {}
    ) do
        if member.kind == "loop_variable" then
            table.insert(
                result,
                member
            )
        end
    end

    return result
end


local function find_loop(
    members,
    name,
    line
)
    for _, member in ipairs(
        loop_members(members)
    ) do
        if member.name == name
            and member.line == line
        then
            return member
        end
    end

    return nil
end


local function same_scope(
    left,
    right
)
    return left
        and right
        and left.scope_depth
            == right.scope_depth
        and left.scope_start_line
            == right.scope_start_line
        and left.scope_end_line
            == right.scope_end_line
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
            "tracker_hud.adapters.lua.init"
        )

    registry.clear()

    local registered, register_err =
        registry.register(adapter)

    assert(
        registered,
        "Lua adapter registration failed: "
            .. tostring(register_err)
    )

    local path =
        "samples/lua/"
        .. "lua_loop_bindings_validation.lua"

    local lines =
        vim.fn.readfile(
            path
        )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Lua loop-binding validation source missing"
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
        "lua"

    local parser_ok, parser_or_err =
        pcall(
            vim.treesitter.get_parser,
            buffer,
            "lua"
        )

    assert(
        parser_ok and parser_or_err,
        "Missing Tree-sitter 'lua' parser: "
            .. tostring(parser_or_err)
    )

    local tree =
        parser_or_err:parse()[1]

    assert(
        tree,
        "Lua parser yielded no tree"
    )

    local root =
        tree:root()

    assert(
        not root:has_error(),
        "Lua loop-binding fixture contains parser ERROR nodes"
    )

    local discovery =
        collector.discover(
            buffer,
            root,
            adapter,
            {}
        )

    local members =
        collector.select(
            discovery,
            {}
        )

    local loops =
        loop_members(
            members
        )

    local index =
        find_loop(
            members,
            "index",
            3
        )

    local key =
        find_loop(
            members,
            "key",
            7
        )

    local value =
        find_loop(
            members,
            "value",
            7
        )

    print(
        "OBSERVED lua loop bindings: "
            .. table.concat(
                vim.tbl_map(
                    function(member)
                        return tostring(
                            member.name
                                or "?"
                        )
                            .. "@"
                            .. tostring(
                                member.line
                                    or "?"
                            )
                            .. "(lex="
                            .. tostring(
                                member.scope_depth
                                    or "?"
                            )
                            .. ",range="
                            .. tostring(
                                member.scope_start_line
                                    or "?"
                            )
                            .. "-"
                            .. tostring(
                                member.scope_end_line
                                    or "?"
                            )
                            .. ",binding="
                            .. tostring(
                                member.is_binding
                                    == true
                            )
                            .. ")"
                    end,
                    loops
                ),
                ", "
            )
    )

    assert(
        #loops == 3,
        "Lua loop binding collection emitted unexpected member count: "
            .. tostring(#loops)
    )

    assert(
        index
            and key
            and value,
        "Lua numeric/generic loop variables missing"
    )

    assert(
        index.is_binding == true
            and key.is_binding == true
            and value.is_binding == true,
        "Lua loop variables must remain binding-capable Scope Members"
    )

    assert(
        index.scope_depth == 1
            and key.scope_depth == 1
            and value.scope_depth == 1,
        "Lua top-level loop variables must be owned by their depth-1 loop scopes"
    )

    assert(
        same_scope(
            key,
            value
        ),
        "Lua generic for variables must share one lexical owner"
    )

    assert(
        not same_scope(
            index,
            key
        ),
        "separate Lua for statements must retain distinct lexical owners"
    )

    local numeric_visible =
        collector.select(
            discovery,
            {
                cursor_line = 4,
                start_line =
                    index.scope_start_line,
                end_line =
                    index.scope_end_line,
            }
        )

    local generic_visible =
        collector.select(
            discovery,
            {
                cursor_line = 8,
                start_line =
                    key.scope_start_line,
                end_line =
                    key.scope_end_line,
            }
        )

    local after_loops =
        collector.select(
            discovery,
            {
                cursor_line = #lines,
                scope_depth = 0,
            }
        )

    assert(
        find_loop(
            numeric_visible,
            "index",
            3
        )
            and #loop_members(
                numeric_visible
            ) == 1,
        "Lua numeric loop variable must be visible only inside its lexical loop"
    )

    assert(
        find_loop(
            generic_visible,
            "key",
            7
        )
            and find_loop(
                generic_visible,
                "value",
                7
            )
            and #loop_members(
                generic_visible
            ) == 2,
        "Lua generic loop variables must be visible only inside their lexical loop"
    )

    assert(
        #loop_members(
            after_loops
        ) == 0,
        "Lua loop variables leaked past their lexical loop lifetime"
    )

    print(
        "PASS Lua parser-backed numeric/generic loop-variable ownership, selection, and lifetime semantics"
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
        "FAIL Lua loop-binding smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
