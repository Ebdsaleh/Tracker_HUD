-- lua/tracker_hud/architectures/registry.lua
--
-- Shared, lazy architecture profile resolver. The profile describes target
-- hardware independently of the language (ASM/C/C++/etc.) used to produce it.
-- Unknown targets deliberately return nil; never infer one from the host.
-- Register profiles are the first extracted capability, not a promise of
-- compiler-generated machine state.

local M = {}

local modules = {
    ["x86-64"] = "tracker_hud.architectures.x86_64",
}

local aliases = {
    ["x86-64"] = "x86-64",
    ["x86_64"] = "x86-64",
    amd64 = "x86-64",
    x64 = "x86-64",
}

function M.normalize(name)
    if type(name) ~= "string" then
        return nil
    end

    return aliases[name:lower()]
end

function M.get(name)
    local canonical = M.normalize(name)
    local module = canonical and modules[canonical]

    if not module then
        return nil
    end

    -- Only load the selected profile. Nothing from adapters/asm is required.
    return require(module)
end

return M
