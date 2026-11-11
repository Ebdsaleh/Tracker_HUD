-- tests/test_runtime.lua
--
-- Headless test isolation for Tracker_HUD source-tree regressions.
--
-- A normal Neovim config may preload an installed/plugin-manager copy of
-- Tracker_HUD before a test prepends the current repository to runtimepath.
-- Lua's package.loaded cache would then keep serving that older copy.
--
-- Parser-backed repository tests must call use_working_tree() before requiring
-- tracker_hud modules so the freshly pulled checkout is the code under test.

local M = {}

function M.use_working_tree()
    local cwd = vim.fn.getcwd()

    vim.opt.runtimepath:prepend(cwd)

    local loaded = {}

    for name, _ in pairs(package.loaded) do
        if name == "tracker_hud"
            or name:match("^tracker_hud%.")
        then
            loaded[#loaded + 1] = name
        end
    end

    for _, name in ipairs(loaded) do
        package.loaded[name] = nil
    end

    return cwd
end

return M
