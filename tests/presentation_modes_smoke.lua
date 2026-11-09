-- tests/presentation_modes_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local modes = require("tracker_hud.presentation_mode")
local learning = require("tracker_hud.presenters.learning")
local inspect = require("tracker_hud.inspect_mode")
local defaults = require("tracker_hud.config").defaults

assert(defaults.presentation.mode == "standard")
assert(modes.resolve(defaults) == "standard")

local config = vim.deepcopy(defaults)
inspect.set_modes({ "scope", "registers", "events", "warnings" })
assert(inspect.set_mode("registers"))
local starting_inspect = inspect.get_mode()
local starting_visual = config.visual_language.mode
local starting_cache_limit = config.analysis.cache_line_limit

assert(modes.set_mode(config, "learning") == "learning")
assert(modes.resolve(config) == "learning")
assert(inspect.get_mode() == starting_inspect)
assert(config.visual_language.mode == starting_visual)
assert(config.analysis.cache_line_limit == starting_cache_limit)
assert(modes.set_mode(config, "cycle") == "diagram")
assert(modes.set_mode(config, "cycle") == "standard")
assert(modes.set_mode(config, "cycle") == "learning")
assert(modes.set_mode(config, "standard") == "standard")
assert(modes.resolve(config) == "standard")

local previous = config.presentation.mode
assert(modes.set_mode(config, "visual") == nil,
    "unfinished graphical mode must not be selectable")
assert(modes.resolve(config) == previous,
    "invalid selection must not change the prior mode")
assert(modes.set_mode(config, "diagram") == "diagram")
assert(modes.resolve(config) == "diagram")
assert(modes.set_mode(config, "standard") == "standard")
assert(vim.tbl_contains(modes.mode_names(), "diagram"))
print("PASS presentation switching: independent of Inspect, colours, cache")

local context = {
    cursor = { line = 12, column = 10 },
    targets = { architecture = "x86-64" },
    registers = {
        {
            name = "rax", source = "instruction",
            source_line = 12, source_start_column = 5,
            role = "destination", value = 60, resolved = true,
            metadata = { family = { canonical = "rax", bits = 64 } },
        },
        {
            name = "rsp", source = "adapter", value = nil,
        },
    },
}
local lines = learning.lines(context)
local rendered = table.concat(lines, "\n")
assert(rendered:find("RAX = 60", 1, true))
assert(rendered:find("inferred from source", 1, true))
assert(rendered:find("destination", 1, true))
assert(not rendered:find("RSP", 1, true),
    "static register profiles must not be claimed as source effects")

-- ASM/Tree-sitter token begins at 0-based column 5: Neovim cursor
-- column 5 is before it, column 6 is ON its first character.
context.cursor.column = 5
local before = table.concat(learning.lines(context), "\n")
assert(not before:find("RAX = 60", 1, true),
    "learning view leaked an undiscovered source effect")
context.cursor.column = 6
assert(table.concat(learning.lines(context), "\n"):find(
    "RAX = 60", 1, true
), "learning view must reveal facts exactly ON the token")
context.cursor.column = 10

context.registers[1].value = nil
local unknown = table.concat(learning.lines(context), "\n")
assert(unknown:find("not have a confirmed value", 1, true),
    "unknown value was displayed as known")

context.registers[1].value = "[rbp + rax*4 - 8]"
local symbolic = table.concat(learning.lines(context), "\n")
assert(symbolic:find("not a confirmed number", 1, true),
    "symbolic memory expression was treated as a known numerical value")

context.registers[1].value = 60
context.registers[1].resolved = false
assert(table.concat(learning.lines(context), "\n"):find(
    "not have a confirmed value", 1, true
), "unresolved numeric-looking value must not be presented as known")
context.registers[1].resolved = true
context.registers[1].value = 0
assert(table.concat(learning.lines(context), "\n"):find("RAX = 0", 1, true))
context.registers[1].value = false
assert(table.concat(learning.lines(context), "\n"):find("RAX = false", 1, true))

local register_model = require("tracker_hud.sections.low_level.register_model")
local unresolved_record = assert(register_model.new({
    name = "rax", value = 60, resolved = false,
}))
assert(unresolved_record.resolved == false,
    "register model must not lose the inference engine's resolved flag")
print("PASS learning lens: source-based, cursor gated, unknown and zero distinct")

local hud_plugin = require("tracker_hud")
hud_plugin.setup({})
local commands = vim.api.nvim_get_commands({})
assert(commands.HudPresentation, "HudPresentation command is not registered")

-- Command must re-render the old context, without calling source analysis,
-- moving the cursor or changing Inspect/section expansion state.
local hud = require("tracker_hud.hud")
local state = require("tracker_hud.state")
local sections = require("tracker_hud.hud_sections")
sections.sync_sections({ by_id = {
    scope = {}, scope_members = {}, registers = {},
    events = {}, warnings = {},
}})
assert(sections.set_expanded("registers", true))
state.source_context = context
state.source_cursor = { 12, 9 }
state.source_winid = vim.api.nvim_get_current_win()

local updates = 0
local real_update = hud.update_panel
hud.update_panel = function()
    updates = updates + 1
    return true
end
local old_cursor = state.source_cursor
local old_inspect = inspect.get_mode()
vim.cmd("HudPresentation learning")
vim.cmd("HudPresentation cycle") -- learning -> diagram
vim.cmd("HudPresentation cycle") -- diagram -> standard
vim.cmd("HudPresentation diagram")
vim.cmd("HudPresentation standard")
vim.cmd("HudPresentation")
assert(updates == 5, "presentation commands must rerender cached context")
assert(state.source_cursor == old_cursor and inspect.get_mode() == old_inspect)
assert(sections.is_expanded("registers"),
    "presentation switch collapsed the user's Registers section")
hud.update_panel = real_update
state.reset_source()

hud_plugin.setup({ namespace = { prefix = "Tutor" } })
local namespaced = vim.api.nvim_get_commands({})
assert(namespaced.TutorPresentation, "namespace prefix not applied")
assert(not namespaced.HudPresentation, "old presentation command leaked")
print("PASS runtime commands: re-render only, preserve state, namespace-safe")
print("PASS presentation modes smoke")
