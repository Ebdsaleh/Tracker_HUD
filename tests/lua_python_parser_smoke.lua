-- tests/lua_python_parser_smoke.lua
--
-- Parser-backed parity smoke for the high-level Lua/Python adapters.
-- This complements the C/C++ parser smoke: Adapter Contract tables are not
-- enough by themselves; real grammar nodes must map and emit real members.

local function normalize_members(
    members
)
    local result = {}

    for _, member in ipairs(
        members or {}
    ) do
        table.insert(
            result,
            table.concat({
                tostring(member.id or ""),
                tostring(member.name or ""),
                tostring(member.kind or ""),
                tostring(member.line or ""),
                tostring(member.scope_depth or ""),
                tostring(member.scope_start_line or ""),
                tostring(member.scope_end_line or ""),
                tostring(member.source_start_column or ""),
                tostring(member.source_end_column or ""),
                tostring(member.value_text or ""),
                tostring(member.value_kind or ""),
                tostring(member.type_label or ""),
            }, "|")
        )
    end

    return table.concat(
        result,
        "\n"
    )
end


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

    registry.clear()

    local fixtures = {
        {
            ft = "lua",
            path =
                "samples/lua/lua_adapter_validation.lua",
            nodes = {
                function_declaration =
                    "function",
                if_statement =
                    "branch",
                for_statement =
                    "loop",
                assignment_statement =
                    "assignment",
                function_call =
                    "call",
                table_constructor =
                    "table",
            },
            expected_member_names = {
                "START_VALUE",
                "update",
                "value",
                "total",
                "index",
                "record",
                "name",
                "count",
                "result",
            },
            visibility_name =
                "record",
            visibility_declaration_text =
                "local record =",
        },
        {
            ft = "python",
            path =
                "samples/python/python_adapter_validation.py",
            nodes = {
                class_definition =
                    "class",
                function_definition =
                    "function",
                if_statement =
                    "branch",
                for_statement =
                    "loop",
                try_statement =
                    "block",
                assignment =
                    "assignment",
                raise_statement =
                    "call",
                call =
                    "call",
            },
            expected_member_names = {
                "math",
                "Path",
                "DemoTracker",
                "__init__",
                "root",
                "update",
                "values",
                "value",
                "total",
                "make_tracker",
                "path",
                "tracker",
            },
            visibility_name =
                "path",
            visibility_declaration_text =
                "path = Path(path_text)",
        },
    }

    local failures = {}

    for _, fixture in ipairs(
        fixtures
    ) do
        local passed,
            failure =
            pcall(function()
                local adapter =
                    require(
                        "tracker_hud.adapters."
                            .. fixture.ft
                            .. ".init"
                    )

                local registered,
                    register_err =
                    registry.register(
                        adapter
                    )

                assert(
                    registered,
                    fixture.ft
                        .. " adapter registration failed: "
                        .. tostring(
                            register_err
                        )
                )

                local buffer =
                    vim.api.nvim_create_buf(
                        false,
                        true
                    )

                local lines =
                    vim.fn.readfile(
                        fixture.path
                    )

                assert(
                    type(lines) == "table"
                        and #lines > 0,
                    fixture.ft
                        .. " validation source missing: "
                        .. fixture.path
                )

                vim.api.nvim_buf_set_lines(
                    buffer,
                    0,
                    -1,
                    false,
                    lines
                )

                vim.bo[buffer].filetype =
                    fixture.ft

                local parser_ok,
                    parser_or_err =
                    pcall(
                        vim.treesitter
                            .get_parser,
                        buffer,
                        fixture.ft
                    )

                assert(
                    parser_ok
                        and parser_or_err,
                    "Missing Tree-sitter '"
                        .. fixture.ft
                        .. "' parser: "
                        .. tostring(
                            parser_or_err
                        )
                )

                local tree =
                    parser_or_err
                        :parse()[1]

                assert(
                    tree,
                    fixture.ft
                        .. " parser yielded no tree"
                )

                local root =
                    tree:root()

                assert(
                    not root:has_error(),
                    fixture.ft
                        .. " validation fixture contains parser ERROR nodes"
                )

                local observed = {}

                local function walk(
                    node
                )
                    local node_type =
                        node:type()

                    local expected_kind =
                        fixture.nodes[
                            node_type
                        ]

                    if expected_kind then
                        observed[
                            node_type
                        ] =
                            (
                                observed[
                                    node_type
                                ]
                                or 0
                            )
                            + 1

                        local parsed,
                            parse_err =
                            registry.parse_node(
                                fixture.ft,
                                node,
                                buffer
                            )

                        assert(
                            parsed
                                and not parse_err,
                            fixture.ft
                                .. " "
                                .. node_type
                                .. " runtime parsing failed: "
                                .. tostring(
                                    parse_err
                                )
                        )

                        assert(
                            parsed.kind
                                == expected_kind
                                or (
                                    type(
                                        parsed.construct
                                    )
                                        == "table"
                                    and parsed.construct
                                        .kind
                                        == expected_kind
                                ),
                            fixture.ft
                                .. " "
                                .. node_type
                                .. " yielded wrong construct kind"
                        )
                    end

                    for child in
                        node:iter_children()
                    do
                        walk(child)
                    end
                end

                walk(root)

                for node_type in pairs(
                    fixture.nodes
                ) do
                    assert(
                        observed[node_type]
                            and observed[
                                node_type
                            ] > 0,
                        fixture.ft
                            .. " expected Tree-sitter node missing: "
                            .. node_type
                    )
                end

                print(
                    "PASS "
                        .. fixture.ft
                        .. " parser constructs mapped from real syntax"
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

                local discovery =
                    collector.discover(
                        buffer,
                        root,
                        adapter
                    )

                assert(
                    normalize_members(
                        collector.select(
                            discovery,
                            {
                                cursor_line =
                                    #lines,
                            }
                        )
                    )
                        == normalize_members(
                            all
                        ),
                    fixture.ft
                        .. " shared discovery changed all-visible member semantics"
                )

                local collected_names = {}

                for _, member in ipairs(
                    all
                ) do
                    table.insert(
                        collected_names,
                        tostring(
                            member.kind
                                or "?"
                        )
                            .. ":"
                            .. tostring(
                                member.name
                                    or "?"
                            )
                            .. "@"
                            .. tostring(
                                member.line
                                    or "?"
                            )
                    )
                end

                print(
                    "COLLECTED "
                        .. fixture.ft
                        .. " ("
                        .. tostring(
                            #all
                        )
                        .. "): "
                        .. (
                            #collected_names > 0
                            and table.concat(
                                collected_names,
                                ", "
                            )
                            or "<empty collection>"
                        )
                )

                for _, expected_name in ipairs(
                    fixture.expected_member_names
                ) do
                    assert(
                        has_name(
                            all,
                            expected_name
                        ),
                        fixture.ft
                            .. " declared member missing from real syntax: "
                            .. expected_name
                    )
                end

                local declaration_line =
                    nil

                for line_number,
                    line_text in ipairs(
                        lines
                    )
                do
                    if line_text:find(
                        fixture
                            .visibility_declaration_text,
                        1,
                        true
                    ) then
                        declaration_line =
                            line_number
                        break
                    end
                end

                assert(
                    declaration_line
                        and declaration_line
                            > 1,
                    fixture.ft
                        .. " visibility declaration line missing"
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

                assert(
                    normalize_members(
                        collector.select(
                            discovery,
                            {
                                cursor_line =
                                    declaration_line
                                    - 1,
                            }
                        )
                    )
                        == normalize_members(
                            before
                        ),
                    fixture.ft
                        .. " shared discovery changed pre-cursor visibility"
                )

                assert(
                    normalize_members(
                        collector.select(
                            discovery,
                            {
                                cursor_line =
                                    declaration_line,
                            }
                        )
                    )
                        == normalize_members(
                            at
                        ),
                    fixture.ft
                        .. " shared discovery changed ON-cursor visibility"
                )

                assert(
                    not has_name(
                        before,
                        fixture.visibility_name
                    ),
                    fixture.ft
                        .. " future declaration leaked before its source line: "
                        .. fixture.visibility_name
                )

                assert(
                    has_name(
                        at,
                        fixture.visibility_name
                    ),
                    fixture.ft
                        .. " declaration not visible ON its source line: "
                        .. fixture.visibility_name
                )

                for _, member in ipairs(
                    at
                ) do
                    assert(
                        not member.line
                            or member.line
                                <= declaration_line,
                        fixture.ft
                            .. " member leaked from a future source line"
                    )
                end

                print(
                    "PASS "
                        .. fixture.ft
                        .. " source members + ON/PAST cursor discovery"
                )

                pcall(
                    vim.api.nvim_buf_delete,
                    buffer,
                    {
                        force = true,
                    }
                )
            end)

        if not passed then
            table.insert(
                failures,
                fixture.ft
                    .. ": "
                    .. tostring(
                        failure
                    )
            )

            print(
                "FAIL "
                    .. fixture.ft
                    .. " parser-backed fixture: "
                    .. tostring(
                        failure
                    )
            )
        end
    end

    assert(
        #failures == 0,
        "Lua/Python parser-backed failures:\n  "
            .. table.concat(
                failures,
                "\n  "
            )
    )

    print(
        "PASS Lua/Python parser-backed Tracker_HUD smoke"
    )
end


local ok,
    err =
    pcall(run)

if ok then
    vim.cmd("qa!")
else
    vim.api.nvim_err_writeln(
        "FAIL Lua/Python parser-backed smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
end
