-- tests/python_structural_member_controls_smoke.lua
--
-- Parser-backed coverage for Scope Members expand/collapse-all controls after
-- structural ownership paths became intermediary HUD tree nodes.

local function find_section(
    sections,
    wanted_id
)
    for _, section in ipairs(sections or {}) do
        if type(section) == "table"
            and section.id == wanted_id
        then
            return section
        end
    end

    return nil
end


local function find_line(
    lines,
    needle
)
    for index, line in ipairs(lines or {}) do
        if type(line) == "string"
            and line:find(
                needle,
                1,
                true
            )
        then
            return index, line
        end
    end

    return nil, nil
end


local function collect_member(
    members,
    wanted_name
)
    for _, member in ipairs(members or {}) do
        if member.name == wanted_name then
            return member
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
    local hud_sections =
        require(
            "tracker_hud.hud_sections"
        )
    local hud_inspect =
        require(
            "tracker_hud.hud_inspect"
        )
    local hud_nodes =
        require(
            "tracker_hud.hud_nodes"
        )
    local config_module =
        require(
            "tracker_hud.config"
        )
    local adapter =
        require(
            "tracker_hud.adapters.python.init"
        )

    registry.clear()
    hud_nodes.reset()

    local registered, register_err =
        registry.register(adapter)

    assert(
        registered,
        "Python adapter registration failed: "
            .. tostring(register_err)
    )

    local source_path =
        "samples/python/"
        .. "python_nested_structural_ownership_validation.py"

    local lines =
        vim.fn.readfile(
            source_path
        )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python structural control source missing"
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

    local root =
        tree:root()

    assert(
        not root:has_error(),
        "Python structural control fixture contains parser ERROR nodes"
    )

    local members =
        collector.collect(
            buffer,
            root,
            adapter,
            {
                cursor_line = #lines,
            }
        )

    local payload =
        collect_member(
            members,
            "payload"
        )

    assert(
        payload
            and payload.source_start_line
            and payload.source_start_column
            and payload.scope_start_line
            and payload.scope_end_line,
        "parser-backed payload member scope missing"
    )

    local context = {
        scope_members = members,
        all_scope_members = members,

        cursor = {
            line = payload.source_start_line,
            column =
                payload.source_start_column
                + 1,
        },

        member_scope = {
            start_line =
                payload.scope_start_line,
            end_line =
                payload.scope_end_line,
        },

        section_order = {
            "scope_members",
        },
    }

    local config =
        config_module.resolve({
            visual_language = {
                mode = "plain",
            },
        })

    local request = {
        line =
            payload.source_start_line,
        column =
            payload.source_start_column,
        context = context,
    }

    local function render()
        local sections =
            hud_sections.build(
                context,
                {
                    panel_width = 200,
                    config = config,
                }
            )

        local scope_members =
            find_section(
                sections,
                "scope_members"
            )

        assert(
            scope_members,
            "Scope Members section missing"
        )

        return scope_members
    end

    local expanded =
        hud_inspect.expand_all(
            "scope_members",
            request
        )

    assert(
        expanded
            and expanded.ok == true,
        "expand-all Scope Members failed"
    )

    local expected_scope_id =
        "scope:"
        .. tostring(
            payload.scope_start_line
        )
        .. ":"
        .. tostring(
            payload.scope_end_line
        )

    assert(
        expanded.target_node_id
            == expected_scope_id,
        "expand-all targeted wrong lexical scope"
    )

    local expanded_render =
        render()

    local _, while_expanded =
        find_line(
            expanded_render.lines,
            "While"
        )

    local _, with_expanded =
        find_line(
            expanded_render.lines,
            "With"
        )

    local _, match_expanded =
        find_line(
            expanded_render.lines,
            "Match"
        )

    local _, case_expanded =
        find_line(
            expanded_render.lines,
            "Case"
        )

    local _, payload_expanded =
        find_line(
            expanded_render.lines,
            "payload"
        )

    assert(
        while_expanded
            and while_expanded:find(
                "*[-]",
                1,
                true
            )
            and with_expanded
            and with_expanded:find(
                "*[-]",
                1,
                true
            )
            and match_expanded
            and match_expanded:find(
                "*[-]",
                1,
                true
            )
            and case_expanded
            and case_expanded:find(
                "*[-]",
                1,
                true
            )
            and payload_expanded
            and payload_expanded:find(
                "*[-]",
                1,
                true
            ),
        "expand-all did not traverse structural intermediary nodes"
    )

    local collapsed =
        hud_inspect.collapse_all(
            "scope_members",
            request
        )

    assert(
        collapsed
            and collapsed.ok == true
            and collapsed.target_node_id
                == expected_scope_id,
        "collapse-all targeted wrong lexical scope"
    )

    local collapsed_render =
        render()

    local _, while_collapsed =
        find_line(
            collapsed_render.lines,
            "While"
        )

    local with_collapsed =
        find_line(
            collapsed_render.lines,
            "With"
        )

    local payload_collapsed =
        find_line(
            collapsed_render.lines,
            "payload"
        )

    assert(
        while_collapsed
            and while_collapsed:find(
                "*[+]",
                1,
                true
            ),
        "collapse-all must keep immediate structural owner visible and collapsed"
    )

    assert(
        with_collapsed == nil
            and payload_collapsed == nil,
        "collapse-all must hide structural descendants"
    )

    print(
        "CONTROLS python structural members: "
            .. "scope="
            .. expected_scope_id
            .. " expand=While>With>Match>Case>payload"
            .. " collapse=While-only"
    )

    print(
        "PASS Python Scope Members expand/collapse-all traverses structural hierarchy"
    )

    hud_nodes.reset()

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end


local ok, err =
    pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Python structural Scope Members controls smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
