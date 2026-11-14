-- tests/asm_adapter_configuration_cache_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/asm_adapter_configuration_cache_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

package.loaded[
    "tracker_hud.adapters.registry"
] = nil

package.loaded[
    "tracker_hud.adapters.asm.adapter"
] = nil

package.loaded[
    "tracker_hud.adapters.asm.init"
] = nil

local registry =
    require(
        "tracker_hud.adapters.registry"
    )

local adapter =
    require(
        "tracker_hud.adapters.asm.init"
    )

registry.clear()

local registered,
    register_error =
    registry.register(
        adapter
    )

assert(
    registered,
    tostring(
        register_error
    )
)

local config = {}

local buffer_linux =
    vim.api.nvim_create_buf(
        false,
        true
    )

vim.api.nvim_buf_set_lines(
    buffer_linux,
    0,
    -1,
    false,
    {
        "; arch=x86-64;",
        "; platform=linux;",
        "; syntax=nasm;",
        "bits 64",
        "mov rax, 1",
    }
)

local ok, err =
    registry.configure_adapter_for_buffer(
        "asm",
        buffer_linux,
        config
    )

assert(
    ok,
    tostring(err)
)

local linux_targets =
    adapter.active_targets

assert(
    linux_targets
        and linux_targets.platform
            == "linux"
        and linux_targets.abi
            == "linux_syscall",
    "initial Linux ASM targets changed"
)

ok, err =
    registry.configure_adapter_for_buffer(
        "asm",
        buffer_linux,
        config
    )

assert(
    ok
        and adapter.active_targets
            == linux_targets,
    "unchanged ASM buffer rebuilt active target state"
)

print(
    "PASS ASM configuration cache: "
        .. "unchanged target state is reused"
)

vim.api.nvim_buf_set_lines(
    buffer_linux,
    1,
    2,
    false,
    {
        "; platform=windows;",
    }
)

ok, err =
    registry.configure_adapter_for_buffer(
        "asm",
        buffer_linux,
        config
    )

assert(
    ok,
    tostring(err)
)

local windows_targets =
    adapter.active_targets

assert(
    windows_targets
        ~= linux_targets
        and windows_targets.platform
            == "windows"
        and windows_targets.abi
            == "windows_x64",
    "ASM directive edit did not rebuild Windows target state"
)

ok, err =
    registry.configure_adapter_for_buffer(
        "asm",
        buffer_linux,
        config
    )

assert(
    ok
        and adapter.active_targets
            == windows_targets,
    "stable post-edit ASM target state was not reused"
)

print(
    "PASS ASM configuration cache: "
        .. "directive edit invalidates then stabilizes"
)

local buffer_other =
    vim.api.nvim_create_buf(
        false,
        true
    )

vim.api.nvim_buf_set_lines(
    buffer_other,
    0,
    -1,
    false,
    {
        "; arch=x86-64;",
        "; platform=linux;",
        "; syntax=nasm;",
        "bits 64",
        "mov rbx, 2",
    }
)

ok, err =
    registry.configure_adapter_for_buffer(
        "asm",
        buffer_other,
        config
    )

assert(
    ok,
    tostring(err)
)

local other_targets =
    adapter.active_targets

assert(
    other_targets.platform
        == "linux"
        and other_targets
            ~= windows_targets,
    "ASM buffer switch did not rebuild active target state"
)

ok, err =
    registry.configure_adapter_for_buffer(
        "asm",
        buffer_linux,
        config
    )

assert(
    ok,
    tostring(err)
)

assert(
    adapter.active_targets.platform
        == "windows"
        and adapter.active_targets
            ~= other_targets,
    "switching back reused another buffer's mutable target state"
)

print(
    "PASS ASM configuration cache: "
        .. "buffer switches re-own mutable target state"
)

print(
    "PASS Tracker_HUD ASM "
        .. "adapter-configuration cache smoke"
)
