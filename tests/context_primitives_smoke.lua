-- tests/context_primitives_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/context_primitives_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local primitives =
    require("tracker_hud.constructs.context_primitives")

vim.api.nvim_buf_set_lines(
    0,
    0,
    -1,
    false,
    {
        "zero",
        "one",
        "two",
    }
)

vim.api.nvim_win_set_cursor(
    0,
    { 2, 2 }
)

local cursor_position =
    primitives.get_cursor_position()

local cursor_location =
    primitives.get_cursor_location()

assert(
    cursor_position.row == 1
        and cursor_position.col == 2
        and cursor_location.line == 2
        and cursor_location.column == 3,
    "cursor coordinate conversion changed"
)
print("PASS context primitives: cursor coordinate conventions preserved")

local node = {
    type = function()
        return "function_definition"
    end,

    range = function()
        return 4, 2, 7, 12
    end,
}

assert(
    primitives.get_node_type(node)
        == "function_definition"
        and primitives.get_first_node_line(node)
            == 5,
    "node identity or first-line conversion changed"
)

local range =
    primitives.get_node_range(node)

assert(
    range
        and range.start_line == 5
        and range.end_line == 8,
    "node range conversion changed"
)

assert(
    primitives.position_in_node(
        4,
        2,
        node
    )
        and primitives.position_in_node(
            7,
            12,
            node
        )
        and not primitives.position_in_node(
            4,
            1,
            node
        )
        and not primitives.position_in_node(
            8,
            0,
            node
        ),
    "node position inclusivity changed"
)
print("PASS context primitives: node identity range and containment preserved")

local construct = {
    node_type = "function_definition",
    signature = "fn inner()",
    range = {
        start_line = 10,
        end_line = 20,
    },
    construct = {
        kind = "function",
        label = "Function",
    },
    scope = {
        kind = "lexical",
    },
    value = {
        kind = "callable",
    },
    metadata = {
        display_label = "[10] Inner",
    },
}

local entry =
    primitives.build_scope_entry_from_construct(
        construct
    )

assert(
    entry
        and entry.label == "[10] Inner"
        and entry.raw_label
            == "fn inner()"
        and entry.node_type
            == "function_definition"
        and entry.kind == "function"
        and entry.start_line == 10
        and entry.end_line == 20
        and entry.construct == construct,
    "scope-entry construction changed"
)
print("PASS context primitives: scope entry contract preserved")

local scopes = {
    {
        label = "Inner",
        node_type = "inner",
        start_line = 10,
        end_line = 20,
    },
    {
        label = "Outer",
        node_type = "outer",
        start_line = 1,
        end_line = 30,
    },
}

local context =
    primitives.build_context_from_scopes(
        scopes,
        {
            separator = " / ",
        }
    )

assert(
    context.label
        == "Scope: Outer / Inner"
        and context.node_type == "inner"
        and context.start_line == 10
        and context.end_line == 20
        and context.depth == 2
        and context.path[1] == "Outer"
        and context.path[2] == "Inner"
        and context.scopes == scopes
        and #context.scope_members == 0,
    "scope-context assembly changed"
)
print("PASS context primitives: scope ordering and context assembly preserved")

local global =
    primitives.make_global_context()

assert(
    global.label == "Global Scope"
        and global.depth == 0
        and #global.path == 0
        and #global.scopes == 0
        and #global.scope_members == 0
        and global.cursor.line == 2
        and global.cursor.column == 3,
    "global context defaults changed"
)

local unavailable =
    primitives.make_unavailable_context(
        "No parser",
        "asm"
    )

assert(
    unavailable.unavailable == true
        and unavailable.label
            == "No parser"
        and unavailable.filetype
            == "asm"
        and unavailable.cursor.line
            == 2,
    "unavailable context defaults changed"
)
print("PASS context primitives: global and unavailable contexts preserved")

assert(
    primitives.get_node_type(nil) == nil
        and primitives.get_first_node_line(nil)
            == nil
        and primitives.get_node_range(nil)
            == nil
        and not primitives.position_in_node(
            0,
            0,
            nil
        )
        and primitives
            .build_scope_entry_from_construct(
                nil
            ) == nil,
    "invalid node/construct inputs must fail closed"
)
print("PASS context primitives: invalid inputs fail closed")

print("PASS Tracker_HUD construct context-primitives smoke")
