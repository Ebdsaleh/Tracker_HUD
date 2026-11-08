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
        events = { style = "events_section_title", link = "Special" },
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
            and selected.style == "inspect_header"
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

    assert(visual.section_title_style("registers", "inspect_mode") == "inspect_mode",
        "unmapped Inspect Mode must preserve existing style")
    assert(visual.section_title_style("registers") == "section_title",
        "unmapped section must preserve generic title style")
    assert(visual.section_title_style("events") == "events_section_title",
        "Events must use its established event colour family")

    -- Inspect Mode selection must not inherit a potentially bright IncSearch
    -- background or override theme-provided section title foreground hues.
    local band = visual.default_style_definitions.inspect_header
    assert(type(band) == "table" and band.bg == "#2D3138"
        and band.ctermbg == 236 and band.fg == nil,
        "Inspect header band must be muted charcoal with no foreground")
    assert(visual.default_links.active == "IncSearch",
        "existing IncSearch semantics must remain available outside headers")
    local band_group = highlights.group_name(config, "inspect_header")
    assert(band_group == "HudSmokeInspectHeader",
        "Inspect header should have a dedicated namespaced group")
    local installed_band = vim.api.nvim_get_hl(0, {
        name = band_group, link = false,
    })
    assert(installed_band.bg == tonumber(band.bg:sub(2), 16),
        "Inspect header group background does not match muted charcoal")
    assert(installed_band.fg == nil,
        "Inspect header background must not override semantic foreground")
    -- The HUD actually requests inspect_header + current relevance, which
    -- resolves to this composite rather than the unmodified base group.
    local current_group = "HudSmokeInspectHeaderCurrent"
    local current = vim.api.nvim_get_hl(0, {
        name = current_group, link = false,
    })
    assert(current.bg == tonumber(band.bg:sub(2), 16),
        "current Inspect header composite must retain muted background")
    assert(current.fg == nil,
        "current Inspect header composite must keep source title colours")
    print("PASS selected heading uses its own subdued background")

    local plain = config_module.resolve({ visual_language = { mode = "plain" } })
    assert(visual.resolve_visual_mode(plain) == "plain",
        "plain mode resolution failed")
    assert(visual.colors_enabled(plain) == false,
        "plain visual mode must disable semantic colors")

    assert(visual.plain_style_for(plain, "inspect_header", "current", "line") == nil,
        "plain mode must not gain a colored heading background")
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
