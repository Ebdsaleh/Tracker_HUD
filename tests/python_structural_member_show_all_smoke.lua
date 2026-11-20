-- tests/python_structural_member_show_all_smoke.lua
--
-- Parser-backed Show All Scope Members coverage after structural ownership
-- paths became intermediary HUD tree nodes.

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


local function find_control(
    sections,
    wanted_id
)
    for _, section in ipairs(sections or {}) do
        if type(section) == "table"
            and section.kind == "control"
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


local function count_lines(
    lines,
    needle
)
    local count = 0

    for _, line in ipairs(lines or {}) do
        if type(line) == "string"
            and line:find(
                needle,
                1,
                true
            )
        then
            count = count + 1
        end
    end

    return count
end


local function leading_spaces(
    line
)
    local prefix =
        type(line) == "string"
        and line:match("^(%s*)")
        or ""

    return #prefix
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
    local hud_controls =
        require(
            "tracker_hud.hud_controls"
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

    assert(
        not hud_controls.is_enabled(
            "show_all_scope_members"
        ),
        "Show All Scope Members must begin disabled"
    )

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
        "Python structural Show All source missing"
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
        "Python structural Show All fixture contains parser ERROR nodes"
    )

    local all_members =
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
            all_members,
            "payload"
        )

    assert(
        payload
            and payload.source_start_line
            and payload.source_start_column,
        "parser-backed payload member missing"
    )

    local current_members =
        collector.collect(
            buffer,
            root,
            adapter,
            {
                cursor_line =
                    payload.source_start_line,
            }
        )

    assert(
        collect_member(
            current_members,
            "payload"
        ),
        "payload must be visible on its source line"
    )

    assert(
        not collect_member(
            current_members,
            "nested"
        )
            and collect_member(
                all_members,
                "nested"
            ),
        "Show All fixture must contain one future nested member"
    )

    local context = {
        scope_members = current_members,
        all_scope_members = all_members,

        cursor = {
            line = payload.source_start_line,
            column =
                payload.source_start_column
                + 1,
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

        local control =
            find_control(
                sections,
                "show_all_scope_members"
            )

        assert(
            scope_members and control,
            "Show All Scope Members rendered workflow missing"
        )

        return scope_members, control
    end

    local current_render,
        current_control =
        render()

    assert(
        current_control.title
            == "[ ] Show All Scope Members",
        "disabled Show All control title changed"
    )

    assert(
        find_line(
            current_render.lines,
            "payload"
        )
            and not find_line(
                current_render.lines,
                "nested"
            ),
        "future nested member leaked before Show All"
    )

    assert(
        count_lines(
            current_render.lines,
            "Case"
        ) == 1,
        "current structural Case grouping changed"
    )

    assert(
        hud_controls.toggle(
            "show_all_scope_members"
        ),
        "Show All Scope Members toggle failed"
    )

    local all_render,
        all_control =
        render()

    assert(
        all_control.title
            == "[+] Show All Scope Members",
        "enabled Show All control title changed"
    )

    local payload_index,
        payload_line =
        find_line(
            all_render.lines,
            "payload"
        )

    local nested_index,
        nested_line =
        find_line(
            all_render.lines,
            "nested"
        )

    local case_index =
        find_line(
            all_render.lines,
            "Case"
        )

    assert(
        case_index
            and payload_index
            and nested_index
            and case_index < payload_index
            and payload_index < nested_index,
        "Show All changed structural source ordering"
    )

    assert(
        count_lines(
            all_render.lines,
            "Case"
        ) == 1,
        "Show All duplicated structural Case grouping"
    )

    assert(
        leading_spaces(payload_line) == 10
            and leading_spaces(nested_line)
                == 11,
        "Show All changed structural member nesting"
    )

    print(
        "SHOW ALL python structural members: "
            .. "current=payload,no-nested"
            .. " all=Case>payload+nested"
    )

    print(
        "PASS Python Show All Scope Members preserves structural grouping"
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
        "FAIL Python structural Show All Scope Members smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
