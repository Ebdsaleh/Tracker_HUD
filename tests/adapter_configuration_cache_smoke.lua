-- tests/adapter_configuration_cache_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/adapter_configuration_cache_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

package.loaded[
    "tracker_hud.adapters.registry"
] = nil

local registry =
    require(
        "tracker_hud.adapters.registry"
    )

registry.clear()

local adapter =
    vim.deepcopy(
        require(
            "tracker_hud.adapters.lua.adapter"
        )
    )

local configure_calls = 0

adapter.configure_adapter_for_buffer =
    function(
        bufnr,
        config
    )
        configure_calls =
            configure_calls + 1

        if config
            and config.fail == true
        then
            error(
                "synthetic configuration failure"
            )
        end

        adapter.active_targets = {
            buffer = bufnr,
            marker =
                config
                and config.marker
                or nil,
        }
    end

local registered,
    register_error =
    registry.register(
        adapter
    )

assert(
    registered,
    "cannot register cache-test adapter: "
        .. tostring(
            register_error
        )
)

local buffer_a =
    vim.api.nvim_create_buf(
        false,
        true
    )

vim.api.nvim_buf_set_lines(
    buffer_a,
    0,
    -1,
    false,
    {
        "local value = 1",
    }
)

local config_a = {
    marker = "a",
}

local ok, err =
    registry.configure_adapter_for_buffer(
        "lua",
        buffer_a,
        config_a
    )

assert(
    ok,
    tostring(err)
)

ok, err =
    registry.configure_adapter_for_buffer(
        "lua",
        buffer_a,
        config_a
    )

assert(
    ok
        and configure_calls == 1,
    "unchanged buffer/config did not reuse configuration"
)

print(
    "PASS adapter configuration cache: "
        .. "unchanged active buffer reuses success"
)

vim.api.nvim_buf_set_lines(
    buffer_a,
    0,
    1,
    false,
    {
        "local value = 2",
    }
)

ok, err =
    registry.configure_adapter_for_buffer(
        "lua",
        buffer_a,
        config_a
    )

assert(
    ok
        and configure_calls == 2,
    "buffer edit did not invalidate configuration cache"
)

ok, err =
    registry.configure_adapter_for_buffer(
        "lua",
        buffer_a,
        config_a
    )

assert(
    ok
        and configure_calls == 2,
    "post-edit stable buffer did not reuse configuration"
)

print(
    "PASS adapter configuration cache: "
        .. "changedtick invalidates then stabilizes"
)

local config_b = {
    marker = "b",
}

ok, err =
    registry.configure_adapter_for_buffer(
        "lua",
        buffer_a,
        config_b
    )

assert(
    ok
        and configure_calls == 3
        and adapter.active_targets.marker
            == "b",
    "config-object change did not invalidate cache"
)

print(
    "PASS adapter configuration cache: "
        .. "runtime config identity invalidates"
)

local buffer_b =
    vim.api.nvim_create_buf(
        false,
        true
    )

vim.api.nvim_buf_set_lines(
    buffer_b,
    0,
    -1,
    false,
    {
        "local other = 3",
    }
)

ok, err =
    registry.configure_adapter_for_buffer(
        "lua",
        buffer_b,
        config_b
    )

assert(
    ok
        and configure_calls == 4
        and adapter.active_targets.buffer
            == buffer_b,
    "buffer switch did not reconfigure active adapter"
)

ok, err =
    registry.configure_adapter_for_buffer(
        "lua",
        buffer_a,
        config_b
    )

assert(
    ok
        and configure_calls == 5
        and adapter.active_targets.buffer
            == buffer_a,
    "switching back reused stale mutable adapter state"
)

print(
    "PASS adapter configuration cache: "
        .. "buffer switches preserve active-state ownership"
)

registry.clear()

registered,
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

ok, err =
    registry.configure_adapter_for_buffer(
        "lua",
        buffer_a,
        config_b
    )

assert(
    ok
        and configure_calls == 6,
    "registry clear/register did not invalidate configuration cache"
)

print(
    "PASS adapter configuration cache: "
        .. "registry mutation invalidates"
)

local failing_config = {
    fail = true,
}

local failed_one =
    registry.configure_adapter_for_buffer(
        "lua",
        buffer_a,
        failing_config
    )

local failed_two =
    registry.configure_adapter_for_buffer(
        "lua",
        buffer_a,
        failing_config
    )

assert(
    failed_one == false
        and failed_two == false
        and configure_calls == 8,
    "failed configuration was incorrectly cached"
)

print(
    "PASS adapter configuration cache: "
        .. "failures never become reusable successes"
)

registry.clear()

adapter.validation_stable_components = {
    register_effects = true,
}
adapter.register_effects = {}

registered,
    register_error =
    registry.register(
        adapter
    )

assert(
    registered,
    tostring(register_error)
)

local profile_counts = {}

local profile_opts = {
    profile_begin =
        function(name)
            profile_counts[name] =
                (profile_counts[name] or 0)
                + 1
            return 0
        end,
    profile_end =
        function()
        end,
}

ok, err =
    registry.configure_adapter_for_buffer(
        "lua",
        buffer_a,
        config_a,
        profile_opts
    )

assert(
    ok
        and profile_counts[
            "context.configure.validate.register_effects_reuse"
        ] == 1
        and profile_counts[
            "context.configure.validate.register_effects"
        ] == nil,
    "stable component identity did not reuse prior successful validation"
)

print(
    "PASS adapter validation reuse: "
        .. "declared stable identity reuses registration proof"
)

adapter.validation_stable_components = {}

ok, err =
    registry.configure_adapter_for_buffer(
        "lua",
        buffer_a,
        config_b,
        profile_opts
    )

assert(
    ok
        and profile_counts[
            "context.configure.validate.register_effects"
        ] == 1,
    "revoked stable-component declaration still reused validation"
)

print(
    "PASS adapter validation reuse: "
        .. "revoking declaration restores full validation"
)

adapter.validation_stable_components = {
    register_effects = true,
}

registry.clear()

registered,
    register_error =
    registry.register(
        adapter
    )

assert(
    registered,
    tostring(register_error)
)

profile_counts = {}

adapter.register_effects = {
    mov = {},
}

ok, err =
    registry.configure_adapter_for_buffer(
        "lua",
        buffer_a,
        config_b,
        profile_opts
    )

assert(
    ok == false
        and tostring(err):find(
            "register_effects.mov",
            1,
            true
        ) ~= nil
        and profile_counts[
            "context.configure.validate.register_effects"
        ] == 1,
    "replacement stable component did not force full validation"
)

print(
    "PASS adapter validation reuse: "
        .. "replacement identity forces contract validation"
)

print(
    "PASS Tracker_HUD adapter-configuration cache smoke"
)