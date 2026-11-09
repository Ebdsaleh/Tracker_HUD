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
assert(modes.set_mode(config, "cycle") == "standard")
assert(modes.set_mode(config, "cycle") == "learning")
assert(modes.set_mode(config, "standard") == "standard")
assert(modes.resolve(config) == "standard")

local previous = config.presentation.mode
assert(modes.set_mode(config, "visual") == nil,
    "unfinished graphical mode must not be selectable")
assert(modes.resolve(config) == previous,
    "invalid selection must not change the prior mode")
print("PASS presentation switching: independent of Inspect, colours, cache")

local context = {
    cursor = { line = 12, column = 10 },
    targets = { architecture = "x86-64" },
    registers = {
        {
            name = "rax", source = "instruction",
            source_line = 12, source_start_column = 5,
            role = "destination", value = 60, resolved = true,
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

context.cursor.column = 2
local before = table.concat(learning.lines(context), "\n")
assert(not before:find("RAX = 60", 1, true),
    "learning view leaked an undiscovered source effect")
context.cursor.column = 10

context.registers[1].value = nil
local unknown = table.concat(learning.lines(context), "\n")
assert(unknown:find("not have a confirmed value", 1, true),
    "unknown value was displayed as known")

context.registers[1].value = "[rbp + rax*4 - 8]"
local symbolic = table.concat(learning.lines(context), "\n")
assert(symbolic:find("not a confirmed number", 1, true),
    "symbolic memory expression was treated as a known numerical value")

context.registers[1].value = 0
assert(table.concat(learning.lines(context), "\n"):find("RAX = 0", 1, true))
context.registers[1].value = false
assert(table.concat(learning.lines(context), "\n"):find("RAX = false", 1, true))
print("PASS learning lens: source-based, cursor gated, unknown and zero distinct")

local hud_plugin = require("tracker_hud")
hud_plugin.setup({})
local commands = vim.api.nvim_get_commands({})
assert(commands.HudPresentation, "HudPresentation command is not registered")
vim.cmd("HudPresentation learning")
vim.cmd("HudPresentation cycle")
vim.cmd("HudPresentation")
print("PASS runtime command registration: standard/learning/cycle")
print("PASS presentation modes smoke")
