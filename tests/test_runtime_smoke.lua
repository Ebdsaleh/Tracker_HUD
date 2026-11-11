-- tests/test_runtime_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/test_runtime_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

package.loaded["tracker_hud.low_level.memory_address"] = {
    stale_marker = true,
}

local runtime = dofile("tests/test_runtime.lua")
runtime.use_working_tree()

assert(
    package.loaded["tracker_hud.low_level.memory_address"] == nil,
    "working-tree isolation must evict preloaded Tracker_HUD modules"
)

local memory_address = require("tracker_hud.low_level.memory_address")

assert(
    type(memory_address) == "table"
        and memory_address.stale_marker == nil
        and type(memory_address.normalize) == "function",
    "working-tree isolation must reload the repository implementation"
)

print("PASS test runtime: preloaded Tracker_HUD module is evicted")
print("PASS test runtime: repository implementation reloads from working tree")
print("PASS Tracker_HUD test runtime isolation smoke")
