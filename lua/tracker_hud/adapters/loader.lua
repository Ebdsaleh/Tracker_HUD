-- lua/tracker_hud/adapters/loader.lua
--
-- Adapter discovery/loader.
--
-- Users should not edit this file.
--
-- Users can add adapter search paths through:
--
-- require("tracker_hud").setup({
--     adapter_paths = {
--         "tracker_hud/adapters",
--         "my_custom_tracker_adapters",
--     },
-- })
--
-- Each path maps to Lua files under runtimepath:
--
-- lua/tracker_hud/adapters/*_adapter.lua
-- lua/my_custom_tracker_adapters/*_adapter.lua


local registry = require("tracker_hud.adapters.registry")

local M = {}

local loaded_modules = {}

local function is_table(value)
    return type(value) == "table"
end

local function is_string(value)
    return type(value) == "string"
end


local function normalize_adapter_paths(adapter_paths)
    if is_string(adapter_paths) then
        return { adapter_paths }
    end

    if is_table(adapter_paths) then
        return adapter_paths 
    end

    return {}
end


local function path_to_runtime_glob(adapter_path)
    -- "tracker_hud/adapters"
    -- becomes:
    -- "lua/tracker_hud/adapters/*_adapter.lua"
    return "lua/" .. adapter_path .. "/*_adapter.lua"
end


local function file_to_module_name(file)
    -- Convert runtimepath file path to require() module name.
    --
    -- Example:
    -- /home/user/.config/nvim/lua/tracker_hud/adapters/lua_adapter.lua
    -- becomes:
    -- tracker_hud.adapters.lua_adapter

    local module_path = file:match("[/\\]lua[/\\](.+)%.lua$")

    if not module_path then
        return nil
    end

    module_path = module_path:gsub("[/\\]", ".")

    return module_path
end


local function load_adapter_module(module_name)
    if loaded_modules[module_name] then
        return true, nil
    end

    local ok, adapter_or_err = pcall(require, module_name)

    if not ok then
        return false, adapter_or_err
    end


    local registered, register_err = registry.register(adapter_or_err)

    if not registered then
        return false, register_err
    end

    loaded_modules[module_name] = true


    return true, nil
end


function M.load_from_paths(adapter_paths)
    local paths = normalize_adapter_paths(adapter_paths)
    local loaded_count = 0
    local errors = {}


    for _, adapter_path in ipairs(paths) do
        if is_string(adapter_path) and adapter_path ~= "" then
            local glob = path_to_runtime_glob(adapter_path)
            local files = vim.api.nvim_get_runtime_file(glob, true)

            for _, file in ipairs(files) do
                local module_name = file_to_module_name(file)

                if module_name then
                    local ok, err = load_adapter_module(module_name)

                    if ok then
                        loaded_count = loaded_count + 1
                    else
                        table.insert(errors, {
                            module = module_name,
                            error = tostring(err),
                        })
                    end
                end
            end
        end
    end


    return {
        loaded_count = loaded_count,
        errors = errors,
    }
end



function M.reload(adapter_paths)
    registry.clear()
    loaded_modules = {}
    
    return M.load_from_paths(adapter_paths)
end


return M
