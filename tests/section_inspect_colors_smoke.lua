-- tests/section_inspect_colors_smoke.lua
-- Run from the Tracker_HUD repository root:
--   nvim --headless -u NONE -c "luafile tests/section_inspect_colors_smoke.lua"
--
-- This tests the shared visual styles and highlight-group registration,
-- not a screenshot of the interactive HUD.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local config_module = require("tracker_hud.config")
    local palette = require("tracker_hud.visual_language")
    local highlights = require("tracker_hud.highlights")

    local expected = {
        scope = { style = "scope_section_title", fg = "#7AA2F7", ctermfg = 12 },
        scope_members = { style = "scope_members_section_title", fg = "#9ECE6A", ctermfg = 10 },
        warnings = { style = "warning_section_title", fg = "#E0AF68", ctermfg = 11 },
    }

    local config = config_module.resolve({
        highlights = { enabled = true },
        namespace = { prefix = "HudSmoke" },
        visual_language = { mode = "rich", colors = { enabled = true } },
    })
    assert(highlights.setup(config), "highlight setup failed")

    for section_id, check in pairs(expected) do
        local style = palette.section_title_style(section_id)
        assert(style == check.style, section_id .. " style mismatch")

        local definition = palette.default_style_definitions[style]
        assert(definition, style .. " highlight definition missing")
        assert(definition.fg == check.fg, style .. " expected color mismatch")
        assert(definition.ctermfg == check.ctermfg,
            style .. " cterm fallback mismatch")
        assert(definition.bold == true, style .. " should use bold headings")

        local group_name = highlights.group_name(config, style)
        assert(group_name == "HudSmoke" .. palette.style_suffixes[style],
            style .. " namespaced group mismatch")

        local hl = vim.api.nvim_get_hl(0, { name = group_name, link = false })
        assert(hl.fg == tonumber(check.fg:sub(2), 16),
            style .. " installed RGB highlight mismatch")

        print("PASS " .. section_id .. " = " .. check.fg .. " / ANSI " .. check.ctermfg)
    end

    assert(palette.section_title_style("registers", "inspect_mode") == "inspect_mode",
        "non-core Inspect Mode should preserve existing style")
    assert(palette.section_title_style("events") == "section_title",
        "non-core section title should preserve generic style")

    local plain = config_module.resolve({
        visual_language = { mode = "plain" },
    })
    assert(palette.resolve_visual_mode(plain) == "plain",
        "plain visual mode resolution failed")
    assert(palette.colors_enabled(plain) == false,
        "plain mode must disable semantic color")
    for _, check in pairs(expected) do
        assert(palette.plain_style_for(plain, check.style, "current", "span")
                == "plain_active_section_title",
            check.style .. " must retain plain active title underline")
        assert(palette.plain_style_for(plain, check.style, "contextual", "span") == nil,
            check.style .. " must not tint inactive plain titles")
    end
    print("PASS plain mode core titles remain colorless with active underline")
end

local ok, err = pcall(run)
if ok then
    print("PASS Tracker_HUD section/Inspect color smoke")
    vim.cmd("qa!")
else
    vim.api.nvim_err_writeln("FAIL Tracker_HUD section/Inspect colors: " .. tostring(err))
    vim.cmd("cquit 1")
end
