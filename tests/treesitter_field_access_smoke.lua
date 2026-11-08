-- tests/treesitter_field_access_smoke.lua
-- Regression for Neovim TSNode:field(name), which returns TSNode[].
-- Run from the Tracker_HUD repository root:
--   nvim --headless -u NONE -c "luafile tests/treesitter_field_access_smoke.lua"
--
-- Does not require a parser or user configuration.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local ts = require("tracker_hud.treesitter_utils")

    local first, second = {}, {}
    local queried = {}
    local real_shape_node = {
        field = function(_, name)
            table.insert(queried, name)
            if name == "declarator" then
                return { first, second }
            end
            return {}
        end,
        child_by_field_name = function()
            error("legacy method must never be called when field() succeeds")
        end,
    }

    assert(ts.get_child_by_field_name(real_shape_node, "declarator") == first,
        "Neovim field(name) must return first matching node")
    assert(ts.get_child_by_field_name(real_shape_node, "absent") == nil,
        "an absent Neovim AST field must remain absent")
    assert(#queried == 2, "field() not queried as expected")

    local legacy = {
        child_by_field_name = function(_, name)
            if name == "name" then
                return second
            end
        end,
    }
    assert(ts.get_child_by_field_name(legacy, "name") == second,
        "existing mock-node legacy API compatibility changed")
    assert(ts.get_child_by_field_name(nil, "name") == nil,
        "nil node should be ignored")
    assert(ts.get_child_by_field_name(real_shape_node, "") == nil,
        "empty field name should be ignored")

    print("PASS Tree-sitter field(name) list API and old mock compatibility")
end

local ok, err = pcall(run)
if ok then
    vim.cmd("qa!")
else
    vim.api.nvim_err_writeln("FAIL Tree-sitter field smoke: " .. tostring(err))
    vim.cmd("cquit 1")
end
