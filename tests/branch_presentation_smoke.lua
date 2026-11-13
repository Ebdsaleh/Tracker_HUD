-- tests/branch_presentation_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/branch_presentation_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local branch =
    require("tracker_hud.constructs.branch_presentation")

vim.api.nvim_buf_set_lines(
    0,
    0,
    -1,
    false,
    {
        "if condition",
        "elseif condition",
        "else",
        "end",
    }
)

vim.api.nvim_win_set_cursor(
    0,
    { 2, 3 }
)

local function fake_node(
    node_type,
    start_row,
    start_col,
    end_row,
    end_col
)
    return {
        _type = node_type,
        _range = {
            start_row,
            start_col,
            end_row,
            end_col,
        },
        _fields = {},
        _named_children = {},

        type = function(self)
            return self._type
        end,

        range = function(self)
            return unpack(
                self._range
            )
        end,

        field = function(self, name)
            return self._fields[name]
                or {}
        end,

        named_child_count = function(self)
            return #self._named_children
        end,

        named_child = function(self, index)
            return self._named_children[
                index + 1
            ]
        end,
    }
end

local else_node =
    fake_node(
        "else_clause",
        2,
        0,
        2,
        4
    )

local elseif_node =
    fake_node(
        "elseif_clause",
        1,
        0,
        1,
        16
    )

local root =
    fake_node(
        "if_statement",
        0,
        0,
        3,
        3
    )

root._fields.alt = {
    else_node,
}

root._named_children = {
    elseif_node,
}

local spec = {
    syntax = {
        fields = {
            alternative = {
                field = "alt",
            },
        },
    },

    construct = {
        label = "If",
    },

    branch = {
        grouped = true,

        alternatives = {
            {
                syntax = {
                    node_type =
                        "else_clause",
                },
                label = "Else",
            },
            {
                node_match =
                    "^elseif_",
                label = "ElseIf",
            },
        },
    },
}

assert(
    branch.node_matches_alternative(
        else_node,
        spec
    )
        and branch.node_matches_alternative(
            elseif_node,
            spec
        )
        and not branch.node_matches_alternative(
            fake_node(
                "body",
                0,
                0,
                0,
                1
            ),
            spec
        ),
    "syntax or legacy branch matching changed"
)
print("PASS branch presentation: syntax and legacy alternative matching preserved")

local alternatives =
    branch.get_node_alternatives(
        root,
        spec
    )

assert(
    #alternatives == 2
        and alternatives[1]
            == else_node
        and alternatives[2]
            == elseif_node,
    "field/named-child alternative discovery changed"
)
print("PASS branch presentation: field and named-child discovery preserved")

assert(
    branch.get_alternative_label(
        else_node,
        spec
    ) == "Else"
        and branch.get_alternative_label(
            elseif_node,
            spec
        ) == "ElseIf",
    "alternative label lookup changed"
)
print("PASS branch presentation: alternative labels preserved")

assert(
    branch.format_display_label(
        1,
        "If",
        "Else",
        3,
        false
    ) == "[1] If : Else [3]"
        and branch.format_display_label(
            1,
            "If",
            "Else",
            3,
            true
        ) == "([1] If : Else [3])",
    "grouped/non-grouped branch formatting changed"
)
print("PASS branch presentation: grouped formatting preserved")

local display =
    branch.build_display_label(
        root,
        spec
    )

assert(
    display
        == "([1] If : ElseIf [2])",
    "cursor-selected branch display changed: "
        .. tostring(display)
)
print("PASS branch presentation: cursor-selected alternative preserved")

vim.api.nvim_win_set_cursor(
    0,
    { 1, 3 }
)

local base_display =
    branch.build_display_label(
        root,
        spec
    )

assert(
    base_display == "[1] If",
    "base branch display changed: "
        .. tostring(base_display)
)
print("PASS branch presentation: base label fallback preserved")

assert(
    not branch.node_matches_alternative(
        nil,
        spec
    )
        and #branch.get_node_alternatives(
            nil,
            spec
        ) == 0
        and branch.get_alternative_label(
            nil,
            spec
        ) == nil,
    "invalid branch inputs must fail closed"
)
print("PASS branch presentation: invalid inputs fail closed")

print("PASS Tracker_HUD branch-presentation smoke")
