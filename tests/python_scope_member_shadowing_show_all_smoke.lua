-- tests/python_scope_member_shadowing_show_all_smoke.lua
--
-- Parser-backed guardrail for Show All preservation of shadow provenance.
--
-- Show All must expose both same-name lexical bindings without collapsing
-- identity or rewriting the inner binding's shadow target.

local function find_member(
    members,
    name,
    line,
    kind
)
    for _, member in ipairs(
        members or {}
    ) do
        if member.name == name
            and member.line == line
            and member.kind == kind
        then
            return member
        end
    end

    return nil
end


local function count_members(
    members,
    name,
    kind
)
    local count = 0

    for _, member in ipairs(
        members or {}
    ) do
        if member.name == name
            and member.kind == kind
        then
            count = count + 1
        end
    end

    return count
end


local function count_lines(
    lines,
    needle
)
    local count = 0

    for _, line in ipairs(
        lines or {}
    ) do
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


local function find_section(
    sections,
    wanted_id
)
    for _, section in ipairs(
        sections or {}
    ) do
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
    for _, section in ipairs(
        sections or {}
    ) do
        if type(section) == "table"
            and section.kind == "control"
            and section.id == wanted_id
        then
            return section
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
        .. "python_scope_member_shadowing_validation.py"

    local lines =
        vim.fn.readfile(
            source_path
        )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python shadowing Show All fixture missing"
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
        "Python shadowing Show All fixture contains parser ERROR nodes"
    )

    local discovery =
        collector.discover(
            buffer,
            root,
            adapter,
            {}
        )

    local current_members =
        collector.select(
            discovery,
            {
                cursor_line = 2,
                scope_depth = 3,
            }
        )

    local all_members =
        collector.select(
            discovery,
            {}
        )

    local current_outer =
        find_member(
            current_members,
            "value",
            1,
            "parameter"
        )

    local current_inner =
        find_member(
            current_members,
            "value",
            2,
            "parameter"
        )

    local outer_value =
        find_member(
            all_members,
            "value",
            1,
            "parameter"
        )

    local inner_value =
        find_member(
            all_members,
            "value",
            2,
            "parameter"
        )

    assert(
        current_outer == nil
            and current_inner,
        "current shadowing view no longer isolates inner lexical binding"
    )

    assert(
        outer_value
            and inner_value
            and count_members(
                all_members,
                "value",
                "parameter"
            ) == 2,
        "Show All model did not preserve both same-name parameter records"
    )

    assert(
        outer_value.id
            and inner_value.id
            and outer_value.id
                ~= inner_value.id,
        "Show All collapsed shadowing member identities"
    )

    assert(
        outer_value.shadows_member_id
            == nil
            and inner_value.shadows_member_id
                == outer_value.id,
        "Show All rewrote lexical shadow provenance"
    )

    assert(
        current_inner.id
            == inner_value.id
            and current_inner.shadows_member_id
                == outer_value.id,
        "current/all views disagree on inner shadow identity"
    )

    local context = {
        scope_members = current_members,
        all_scope_members = all_members,

        cursor = {
            line = 2,
            column = 15,
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
            "Show All shadowing workflow missing"
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
        count_lines(
            current_render.lines,
            inner_value.label
        ) == 1,
        "current shadowing render should contain one value binding"
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

    assert(
        count_lines(
            all_render.lines,
            outer_value.label
        ) == 1
            and count_lines(
                all_render.lines,
                inner_value.label
            ) == 1,
        "Show All render collapsed same-name shadowing bindings"
    )

    print(
        "OBSERVED python Scope Member Show All shadowing: "
            .. "current=value@2(id="
            .. tostring(
                current_inner.id
            )
            .. ",shadows="
            .. tostring(
                current_inner.shadows_member_id
                    or "none"
            )
            .. ") all=value@1(id="
            .. tostring(
                outer_value.id
            )
            .. ")+value@2(id="
            .. tostring(
                inner_value.id
            )
            .. ",shadows="
            .. tostring(
                inner_value.shadows_member_id
                    or "none"
            )
            .. ")"
    )

    print(
        "PASS Show All preserves same-name Scope Member identities and shadow provenance"
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
        "FAIL Python Scope Member shadowing Show All smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
