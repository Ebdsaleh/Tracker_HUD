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

local scan_counters = {}

local configure_profile_opts = {
    profile_counter =
        function(name, delta)
            scan_counters[name] =
                (
                    scan_counters[name]
                    or 0
                )
                + (delta or 0)
        end,
}

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
        config,
        configure_profile_opts
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
        config,
        configure_profile_opts
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
        config,
        configure_profile_opts
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
        config,
        configure_profile_opts
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
        config,
        configure_profile_opts
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
        config,
        configure_profile_opts
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

local buffer_prefix =
    vim.api.nvim_create_buf(
        false,
        true
    )

vim.api.nvim_buf_set_lines(
    buffer_prefix,
    0,
    -1,
    false,
    {
        "; arch=x86-64;",
        "# platform=linux;",
        "; syntax=nasm;",
        "mov rcx, 3",
    }
)

ok, err =
    registry.configure_adapter_for_buffer(
        "asm",
        buffer_prefix,
        config,
        configure_profile_opts
    )

assert(
    ok,
    tostring(err)
)

local prefix_targets =
    adapter.active_targets

local prefix_diagnostic = false

for _, diagnostic in ipairs(
    prefix_targets.diagnostics
        or {}
) do
    if diagnostic.key == "platform"
        and tostring(
            diagnostic.message
        ):find(
            "directive uses '#'",
            1,
            true
        )
    then
        prefix_diagnostic = true
        break
    end
end

assert(
    prefix_targets.platform
        == "linux"
        and prefix_targets.abi
            == "linux_syscall"
        and prefix_diagnostic,
    "shared ASM directive scan lost syntax-prefix target diagnostics"
)

local buffer_malformed =
    vim.api.nvim_create_buf(
        false,
        true
    )

vim.api.nvim_buf_set_lines(
    buffer_malformed,
    0,
    -1,
    false,
    {
        "; arch=x86-64;",
        "; platform =linux;",
        "; syntax=nasm;",
        "mov rdx, 4",
    }
)

ok, err =
    registry.configure_adapter_for_buffer(
        "asm",
        buffer_malformed,
        config,
        configure_profile_opts
    )

assert(
    ok,
    tostring(err)
)

local malformed_targets =
    adapter.active_targets

local malformed_diagnostic = false

for _, diagnostic in ipairs(
    malformed_targets.diagnostics
        or {}
) do
    if diagnostic.key == "platform"
        and diagnostic.reason
            == "spaces_around_assignment"
    then
        malformed_diagnostic = true
        break
    end
end

assert(
    malformed_diagnostic,
    "shared ASM directive scan lost malformed-assignment diagnostics"
)

print(
    "PASS ASM configuration cache: "
        .. "shared scan preserves source diagnostics"
)

assert(
    scan_counters[
        "context.configure.adapter.directive_scans"
    ] == 6
        and scan_counters[
            "context.configure.adapter.directive_scans.shared"
        ] == 6
        and scan_counters[
            "context.configure.adapter.directive_scans.variant"
        ] == nil
        and scan_counters[
            "context.configure.adapter.directive_scans.targets"
        ] == nil,
    "ASM configuration did not use exactly one shared directive scan per cache miss"
)

print(
    "PASS ASM configuration cache: "
        .. "one shared directive scan per cache miss"
)

assert(
    scan_counters[
        "context.configure.adapter.variant.identity_checks"
    ] == 6
        and scan_counters[
            "context.configure.adapter.variant.same_identity"
        ] == 6
        and scan_counters[
            "context.configure.adapter.variant.changed_identity"
        ] == nil
        and scan_counters[
            "context.configure.adapter.variant.apply_calls"
        ] == nil
        and scan_counters[
            "context.configure.adapter.variant.presentation_rebuilds"
        ] == nil,
    "same-identity ASM configuration reapplied static variant state"
)

print(
    "PASS ASM configuration cache: "
        .. "same variant skips static reapplication"
)

local canonical_variant =
    require(
        "tracker_hud.adapters.asm.arch.x86_64"
    )

adapter.active_variant = {
    name = "sentinel",
}

adapter.presentation = {
    sentinel = true,
}

ok, err =
    registry.configure_adapter_for_buffer(
        "asm",
        buffer_linux,
        config,
        configure_profile_opts
    )

assert(
    ok,
    tostring(err)
)

assert(
    adapter.active_variant
        == canonical_variant
        and adapter.presentation.sentinel
            == nil
        and adapter.active_targets.platform
            == "windows",
    "variant identity mismatch did not restore canonical ASM variant state"
)

assert(
    scan_counters[
        "context.configure.adapter.directive_scans"
    ] == 7
        and scan_counters[
            "context.configure.adapter.directive_scans.shared"
        ] == 7
        and scan_counters[
            "context.configure.adapter.variant.identity_checks"
        ] == 7
        and scan_counters[
            "context.configure.adapter.variant.same_identity"
        ] == 6
        and scan_counters[
            "context.configure.adapter.variant.changed_identity"
        ] == 1
        and scan_counters[
            "context.configure.adapter.variant.apply_calls"
        ] == 1
        and scan_counters[
            "context.configure.adapter.variant.presentation_rebuilds"
        ] == 1,
    "variant identity mismatch did not trigger exactly one static reapplication"
)

print(
    "PASS ASM configuration cache: "
        .. "identity mismatch reapplies static variant state"
)

print(
    "PASS Tracker_HUD ASM "
        .. "adapter-configuration cache smoke"
)
