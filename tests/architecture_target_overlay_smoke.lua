-- tests/architecture_target_overlay_smoke.lua
-- Run from the repository root:
--   nvim --headless -u NONE -c "luafile tests/architecture_target_overlay_smoke.lua"
--
-- Second architecture migration tranche:
-- x86-64 platform/ABI overlays are shared target facts, not ASM-owned facts.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    package.loaded["tracker_hud.adapters.asm.arch.x86_64.adapter"] = nil
    package.loaded["tracker_hud.adapters.asm.arch.x86_64.init"] = nil
    package.loaded["tracker_hud.adapters.asm.adapter"] = nil
    package.loaded["tracker_hud.adapters.asm.init"] = nil

    local registry = require("tracker_hud.architectures.registry")
    local arch = assert(registry.get("x86-64"),
        "x86-64 architecture profile must resolve")

    assert(package.loaded["tracker_hud.adapters.asm.arch.x86_64.adapter"] == nil
        and package.loaded["tracker_hud.adapters.asm.adapter"] == nil,
        "shared target profile must not load ASM")

    assert(type(arch.platforms) == "table"
        and arch.default_platform == "linux",
        "architecture profile must expose shared platform overlays")
    assert(arch.platforms.linux
        and arch.platforms.linux.abi == "linux_syscall"
        and arch.platforms.linux.status == "supported",
        "Linux target overlay changed")
    assert(arch.platforms.windows
        and arch.platforms.windows.abi == "windows_x64"
        and arch.platforms.windows.status == "declared",
        "Windows x64 target declaration changed")
    assert(arch.platforms.darwin
        and arch.platforms.darwin.abi == "darwin_x86_64"
        and arch.platforms.darwin.status == "declared",
        "Darwin x86-64 target declaration changed")

    assert(arch.platform_aliases.win64 == "windows"
        and arch.platform_aliases.macos == "darwin"
        and arch.platform_aliases.mac == "darwin",
        "platform aliases changed during extraction")

    local linux = assert(arch.calling_conventions.linux_syscall,
        "Linux syscall ABI must remain declared")
    assert(linux.kind == "syscall"
        and linux.platform == "linux"
        and linux.number_register == "rax"
        and linux.return_register == "rax",
        "Linux syscall ABI scalar register contract changed")

    local expected_args = { "rdi", "rsi", "rdx", "r10", "r8", "r9" }
    assert(#linux.argument_registers == #expected_args,
        "Linux syscall argument count changed")
    for index, name in ipairs(expected_args) do
        assert(linux.argument_registers[index] == name,
            "Linux syscall argument register changed at position "
                .. tostring(index))
    end

    assert(#linux.clobbers == 2
        and linux.clobbers[1] == "rcx"
        and linux.clobbers[2] == "r11",
        "Linux syscall clobber contract changed")

    local variant = require("tracker_hud.adapters.asm.arch.x86_64.init")
    assert(variant.metadata == arch.metadata,
        "ASM must share architecture metadata")
    assert(variant.platforms == arch.platforms,
        "ASM must share platform target facts")
    assert(variant.platform_aliases == arch.platform_aliases,
        "ASM must share platform aliases")
    assert(variant.calling_conventions == arch.calling_conventions,
        "ASM must share ABI/calling-convention facts")
    assert(variant.default_platform == arch.default_platform,
        "ASM default platform must come from shared target profile")

    local asm = require("tracker_hud.adapters.asm.init")
    assert(asm.active_targets.platform == "linux"
        and asm.active_targets.abi == "linux_syscall",
        "default ASM target resolution changed after overlay extraction")

    print("PASS x86-64 target overlays load without ASM")
    print("PASS ASM consumes shared platform/ABI tables by identity")
    print("PASS Linux syscall target contract preserved")
    print("PASS Tracker_HUD architecture target-overlay smoke")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL architecture target-overlay smoke: "
        .. tostring(err) .. "\n")
    error(err)
end
