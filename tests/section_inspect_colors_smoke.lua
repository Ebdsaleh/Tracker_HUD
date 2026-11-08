-- tests/section_inspect_colors_smoke.lua
-- Run from the Tracker_HUD repository root:
--   nvim --headless -u NONE -c "luafile tests/section_inspect_colors_smoke.lua"
--
-- Verify the visual-language contract without depending on a specific scheme.
-- Interactive HUD/statusline selection still needs a real Neovim session.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local config_module = require("tracker_hud.config")
    local visual = require("tracker_hud.visual_language")
    local highlights = require("tracker_hud.highlights")

    local expected = {
        scope = { style = "scope_section_title", link = "Function" },
        scope_members = { style = "scope_members_section_title", link = "String" },
        warnings = { style = "warning_section_title", link = "DiagnosticWarn" },
    }

    local config = config_module.resolve({
        highlights = { enabled = true },
        namespace = { prefix = "HudSmoke" },
        visual_language = { mode = "rich", colors = { enabled = true } },
    })
    assert(highlights.setup(config), "highlight setup failed")

    for id, check in pairs(expected) do
        local style = visual.section_title_style(id)
        assert(style == check.style, id .. " visual style mismatch")
        assert(visual.default_links[style] == check.link,
            style .. " must reuse the original colorscheme group")
        assert(visual.default_style_definitions[style] == nil,
            style .. " must not enforce a hard-coded hue")
        local name = highlights.group_name(config, style)
        assert(name == "HudSmoke" .. visual.style_suffixes[style],
            style .. " namespaced group mismatch")
        local installed = vim.api.nvim_get_hl(0, { name = name, link = true })
        assert(installed.link == check.link,
            style .. " should link to " .. check.link)
        print("PASS " .. id .. " inherits Neovim " .. check.link)
    end

    -- One panel heading is selected at a time. Source-relevance remains
    -- independently free to mark an owning Scope Members node with "*".
    -- Never let that source "active" state pin the header background.
    for section_id in pairs(expected) do
        local selected = visual.inspect_header_line_style(section_id, section_id)
        assert(type(selected) == "table"
            and selected.style == "active"
            and selected.relevance == "current",
            section_id .. " selected header not highlighted")
        for other_id in pairs(expected) do
            if other_id ~= section_id then
                assert(visual.inspect_header_line_style(other_id, section_id) == nil,
                    other_id .. " remains highlighted while inspecting " .. section_id)
            end
        end
    end
    assert(visual.inspect_header_line_style("events", "warnings") == nil,
        "unselected Events must not acquire a root background")
    assert(visual.inspect_header_line_style("scope_members", "scope") == nil,
        "Scope Members must not retain background when inspecting Scope")
    print("PASS root header focus follows Inspect Mode, not cursor-affected section")

    local focus = visual.relevance_definitions.inspecting
    assert(focus and focus.bold == true and focus.underline == true,
        "selected root title must use bold + underline")
    local focus_name = highlights.group_name(config, "inspecting")
    assert(focus_name ~= nil, "Inspecting relevance highlight must exist")
    local installed_focus = vim.api.nvim_get_hl(0, { name = focus_name, link = false })
    assert(installed_focus.bold == true and installed_focus.underline == true,
        "Inspecting focus highlight missing")
    assert(visual.relevance_definitions.current.underline == nil,
        "do not underline every current descendant")
    print("PASS Inspecting emphasis is separate from source relevance")

    assert(visual.section_title_style("events", "inspect_mode") == "inspect_mode",
        "non-core Inspect Mode must preserve existing style")
    assert(visual.section_title_style("events") == "section_title",
        "non-core section title must preserve generic style")

    local plain = config_module.resolve({ visual_language = { mode = "plain" } })
    assert(visual.resolve_visual_mode(plain) == "plain",
        "plain mode resolution failed")
    assert(visual.colors_enabled(plain) == false,
        "plain visual mode must disable semantic colors")

    for _, check in pairs(expected) do
        assert(visual.plain_style_for(plain, check.style, "inspecting", "span")
            == "plain_active_section_title",
            check.style .. " must have a plain active underline")
        assert(visual.plain_style_for(plain, check.style, "contextual", "span") == nil,
            check.style .. " must not color inactive plain headings")
    end
    print("PASS plain selected headings stay neutral/underlined")
end

local ok, err = pcall(run)
if ok then
    print("PASS Tracker_HUD theme-linked section/Inspect smoke")
    vim.cmd("qa!")
else
    vim.api.nvim_err_writeln("FAIL Tracker_HUD theme-linked section/Inspect smoke: " .. tostring(err))
    vim.cmd("cquit 1")
end
