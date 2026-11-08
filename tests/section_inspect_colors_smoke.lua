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
        events = { style = "events_section_title", link = "Keyword" },
        warnings = { style = "warning_section_title", link = "DiagnosticWarn" },
    }

    -- Shared low-level section IDENTITY colours (not underlying fact styles).
    -- ASM, C and C++ must all inherit the same mapping for title + Inspect.
    local low_level = {
        registers = { style = "registers_section_title", fg = "#D68187" },
        stack = { style = "stack_section_title", fg = "#D7B45D" },
        heap = { style = "heap_section_title", fg = "#CE906A" },
    }

    -- Ensure muted garnet remains readable on the selected charcoal band,
    -- where a literal dark blood-red would be difficult to discern.
    local function luminance(hex)
        local channels = {}
        for position = 2, 6, 2 do
            local value = tonumber(hex:sub(position, position + 1), 16) / 255
            channels[#channels + 1] = value <= 0.04045
                and value / 12.92
                or ((value + 0.055) / 1.055) ^ 2.4
        end
        return channels[1] * 0.2126
            + channels[2] * 0.7152
            + channels[3] * 0.0722
    end

    local function contrast(a, b)
        local a_luma, b_luma = luminance(a), luminance(b)
        return (math.max(a_luma, b_luma) + 0.05)
            / (math.min(a_luma, b_luma) + 0.05)
    end

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

    local seen_low_level_colors = {}
    for id, check in pairs(low_level) do
        local style = visual.section_title_style(id)
        assert(style == check.style, id .. " title style mismatch")
        assert(visual.default_low_level_section_colors[id] == check.fg,
            id .. " palette default mismatch")
        local definition = visual.default_style_definitions[style]
        assert(type(definition) == "table"
            and definition.fg == check.fg
            and definition.bg == nil,
            id .. " heading must have its own foreground without a background")
        assert(visual.default_links[style] == nil,
            id .. " custom semantic palette must not be masked by theme link")

        local group = highlights.group_name(config, style)
        assert(group == "HudSmoke" .. visual.style_suffixes[style],
            id .. " missing namespaced title group")
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        assert(hl.fg == tonumber(check.fg:sub(2), 16),
            id .. " installed heading color mismatch")

        local segment = highlights.statusline_segment_group(config, style)
        local segment_hl = vim.api.nvim_get_hl(0, {
            name = segment, link = false,
        })
        assert(segment_hl.fg == hl.fg,
            "Inspect: " .. id .. " should match its heading color")
        assert(contrast(check.fg, "#2D3138") >= 4.5,
            id .. " section title contrast is too low on Inspect charcoal")
        -- The inactive title should be only subtly dimmed, not treated
        -- as historical source data (which would wash out its identity).
        local idle_name = group .. visual.style_suffixes.section_idle
        local idle = vim.api.nvim_get_hl(0, {
            name = idle_name, link = false,
        })
        local original = tonumber(check.fg:sub(2), 16)
        assert(idle.fg ~= nil and idle.fg ~= original,
            id .. " inactive heading should be a softer version of its colour")
        local function rgb(value, shift)
            return math.floor(value / (256 ^ shift)) % 256
        end
        for shift = 0, 2 do
            assert(math.abs(rgb(idle.fg, shift) - rgb(original, shift)) <= 20,
                id .. " inactive heading colour should remain near its identity")
        end
        assert(not idle.bold and not idle.italic and not idle.underline,
            id .. " inactive heading must not look selected or historical")
        assert(not seen_low_level_colors[check.fg],
            "low-level headings should have distinct accents")
        seen_low_level_colors[check.fg] = true

        print("PASS " .. id .. " retains its hue when not selected: " .. check.fg)
    end

    assert(visual.relevance_color_mixes.section_idle == 0.12,
        "inactive section headings must keep a restrained colour mix")
    assert(visual.relevance_definitions.section_idle
        and visual.relevance_definitions.section_idle.italic == nil
        and visual.relevance_definitions.section_idle.underline == nil,
        "inactive headings may not be styled as historical or inspected")
    local sections_to_test = {}
    for id in pairs(expected) do
        sections_to_test[id] = true
    end
    for id in pairs(low_level) do
        sections_to_test[id] = true
    end

    -- One panel heading is selected at a time. Source-relevance remains
    -- independently free to mark an owning Scope Members node with "*".
    -- Never let that source "active" state pin the header background.
    for section_id in pairs(sections_to_test) do
        assert(visual.section_heading_relevance(section_id, section_id)
            == "inspecting",
            section_id .. " selected title must receive Inspect emphasis")
        local selected = visual.inspect_header_line_style(section_id, section_id)
        assert(type(selected) == "table"
            and selected.style == "inspect_header"
            and selected.relevance == "current",
            section_id .. " selected header not highlighted")
        for other_id in pairs(sections_to_test) do
            if other_id ~= section_id then
                assert(visual.section_heading_relevance(other_id, section_id)
                    == "section_idle",
                    other_id .. " unselected heading must retain its identity")
                assert(visual.inspect_header_line_style(other_id, section_id) == nil,
                    other_id .. " remains highlighted while inspecting " .. section_id)
            end
        end
    end
    assert(visual.inspect_header_line_style("events", "warnings") == nil,
        "unselected Events must not acquire a root background")
    assert(visual.inspect_header_line_style("scope_members", "scope") == nil,
        "Scope Members must not retain background when inspecting Scope")
    assert(visual.section_heading_relevance(nil, "scope") == nil,
        "invalid heading IDs should not select anything")
    print("PASS root headings preserve section identity independent of source relevance")

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

    assert(visual.section_title_style("custom_section", "inspect_mode") == "inspect_mode",
        "unmapped Inspect Mode must preserve existing style")
    assert(visual.section_title_style("custom_section") == "section_title",
        "unmapped section must preserve generic title style")
    assert(visual.section_title_style("events") == "events_section_title",
        "Events must use its own section-title style")
    -- The default Events heading/mode name must match the Target: label.
    -- Compare default links, not hardcoded RGB values: actual purple hue
    -- remains controlled by the user's Neovim colorscheme.
    assert(visual.default_links.events_section_title == visual.default_links.target_label,
        "Events and Target: must share the default theme colour")
    assert(visual.default_links.target_label == "Keyword",
        "Target: default accent should remain Keyword")

    local events_group = highlights.group_name(config, "events_section_title")
    local target_group = highlights.group_name(config, "target_label")
    local events_hl = vim.api.nvim_get_hl(0, {
        name = events_group, link = false,
    })
    local target_hl = vim.api.nvim_get_hl(0, {
        name = target_group, link = false,
    })
    if target_hl.fg ~= nil then
        assert(events_hl.fg == target_hl.fg,
            "Events heading hue must match Target: text")
        local status_events = highlights.statusline_segment_group(
            config, "events_section_title"
        )
        local status_hl = vim.api.nvim_get_hl(0, {
            name = status_events, link = false,
        })
        assert(status_hl.fg == target_hl.fg,
            "Inspect: Events must have the same hue as Target:")
    end
    print("PASS Events heading and Inspect name match Target: default accent")

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

    -- The panel's bottom StatusLine must use the exact same charcoal as the
    -- highlighted Inspect heading, even when the panel window is inactive.
    -- Segment highlights are explicit to prevent %#...# resets flashing grey.
    -- The regular Neovim StatusLine highlight must remain unchanged.
    local original_statusline = vim.api.nvim_get_hl(0, {
        name = "StatusLine", link = false,
    })
    local surface_group = highlights.statusline_background_group(config)
    assert(type(surface_group) == "string" and surface_group ~= "",
        "HUD statusline surface group was not created")

    local surface = vim.api.nvim_get_hl(0, {
        name = surface_group, link = false,
    })
    assert(surface.bg == tonumber(band.bg:sub(2), 16),
        "HUD statusline background must match Inspect heading")
    assert(surface.ctermbg == band.ctermbg,
        "HUD statusline terminal fallback must match Inspect heading")

    for _, style in ipairs({
        "status_title", "status_marker", "scope_section_title",
        "scope_members_section_title", "events_section_title",
        "registers_section_title", "stack_section_title", "heap_section_title",
        "warning_section_title",
    }) do
        local group = highlights.statusline_segment_group(config, style)
        assert(type(group) == "string" and group ~= "",
            style .. " statusline segment group missing")
        local hl = vim.api.nvim_get_hl(0, {
            name = group, link = false,
        })
        assert(hl.bg == surface.bg and hl.ctermbg == band.ctermbg,
            style .. " segment must stay on charcoal background")
        assert(hl.fg ~= nil, style .. " segment must have readable text")

        if style ~= "status_title" then
            local theme_group = highlights.group_name(config, style)
            local theme_hl = vim.api.nvim_get_hl(0, {
                name = theme_group, link = false,
            })
            if theme_hl.fg ~= nil then
                assert(hl.fg == theme_hl.fg,
                    style .. " must preserve its theme foreground")
            end
        end
    end

    assert(vim.deep_equal(original_statusline, vim.api.nvim_get_hl(0, {
        name = "StatusLine", link = false,
    })), "normal editor StatusLine highlight must remain unchanged")
    print("PASS bottom HUD statusline surface matches selected heading")

    local plain = config_module.resolve({ visual_language = { mode = "plain" } })
    assert(visual.resolve_visual_mode(plain) == "plain",
        "plain mode resolution failed")
    assert(visual.colors_enabled(plain) == false,
        "plain visual mode must disable semantic colors")

    assert(visual.plain_style_for(plain, "inspect_header", "current", "line") == nil,
        "plain mode must not gain a colored heading background")
    for _, check in pairs(low_level) do
        assert(visual.plain_style_for(plain, check.style, "inspecting", "span")
            == "plain_active_section_title",
            check.style .. " should use plain focus underline")
        assert(visual.plain_style_for(plain, check.style, "contextual", "span") == nil,
            check.style .. " should not tint inactive plain headings")
        assert(visual.plain_style_for(plain, check.style, "section_idle", "span") == nil,
            check.style .. " should not tint inactive plain headings")
    end
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
