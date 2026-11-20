-- tests/scope_member_structural_value_regression.lua
--
-- The new per-member structural ownership hierarchy must coexist with the
-- older Scope Members feature that attaches a lexical scope beneath a member
-- whose structural value range owns that scope.

local function find_child(
    children,
    predicate
)
    for _, child in ipairs(children or {}) do
        if type(child) == "table"
            and predicate(child)
        then
            return child
        end
    end

    return nil
end


local function run()
    vim.opt.runtimepath:prepend(
        vim.fn.getcwd()
    )

    local tree_builder =
        require(
            "tracker_hud.scope_member_tree"
        )

    local container = {
        id =
            "member:global:container",
        name = "container",
        kind = "assignment",
        label =
            "[1] (assignment) container",
        line = 1,

        scope_depth = 0,

        source_start_line = 1,
        source_start_column = 0,
        source_end_line = 1,
        source_end_column = 9,

        value_kind = "structural",
        value_start_line = 2,
        value_start_column = 0,
        value_end_line = 8,
        value_end_column = 1,
    }

    local inside = {
        id =
            "member:2:8:5:assignment:inside",
        name = "inside",
        kind = "assignment",
        label =
            "[5] (assignment) inside",
        line = 5,

        scope_depth = 1,
        scope_start_line = 2,
        scope_start_column = 0,
        scope_end_line = 8,
        scope_end_column = 1,

        source_start_line = 5,
        source_start_column = 4,
        source_end_line = 5,
        source_end_column = 10,

        structural_depth = 1,
        structural_scope_start_line = 4,
        structural_scope_start_column = 4,
        structural_scope_end_line = 6,
        structural_scope_end_column = 12,

        structural_path = {
            {
                depth = 1,
                node_type =
                    "synthetic_structural",
                construct_kind =
                    "branch",
                language_term =
                    "structural",
                label = "Structural",
                start_line = 4,
                start_column = 4,
                end_line = 6,
                end_column = 12,
            },
        },
    }

    local nodes =
        tree_builder.build(
            {
                container,
                inside,
            },
            {}
        )

    assert(
        #nodes == 1,
        "structural-value child lexical scope must not remain a top-level duplicate"
    )

    local global_scope =
        nodes[1]

    assert(
        global_scope.kind == "scope"
            and global_scope.id
                == "scope:global",
        "structural-value regression lost global lexical root"
    )

    local container_node =
        find_child(
            global_scope.children,
            function(node)
                return type(node.member)
                    == "table"
                    and node.member.name
                        == "container"
            end
        )

    assert(
        container_node,
        "structural-value container member missing"
    )

    local attached_lexical_scope =
        find_child(
            container_node.children,
            function(node)
                return node.kind == "scope"
                    and node.scope_kind
                        ~= "structural"
                    and node.scope_start_line
                        == 2
                    and node.scope_end_line
                        == 8
            end
        )

    assert(
        attached_lexical_scope,
        "structural-value member no longer owns matching lexical scope"
    )

    local structural_node =
        find_child(
            attached_lexical_scope.children,
            function(node)
                return node.kind == "scope"
                    and node.scope_kind
                        == "structural"
                    and node.label
                        == "Structural"
                    and node.structural_depth
                        == 1
            end
        )

    assert(
        structural_node,
        "new structural ownership path did not nest inside attached lexical scope"
    )

    local inside_node =
        find_child(
            structural_node.children,
            function(node)
                return type(node.member)
                    == "table"
                    and node.member.name
                        == "inside"
            end
        )

    assert(
        inside_node,
        "member inside structural-value lexical scope was lost"
    )

    print(
        "TREE structural-value compatibility: "
            .. "global>member:container>lexical@2"
            .. ">Structural@4>member:inside"
    )

    print(
        "PASS structural-value attachment coexists with structural ownership hierarchy"
    )
end


local ok, err =
    pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL structural-value Scope Members regression: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
