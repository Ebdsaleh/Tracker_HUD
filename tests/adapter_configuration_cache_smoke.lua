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
    construct_specs = true,
    scope_members = true,
    presentation = true,
    instruction_parser = true,
    memory_accesses = true,
    boundary_effects = true,
    register_effects = true,
    instruction_events = true,
    stack_effects = true,
}
adapter.instruction_parser = {
    module = "tracker_hud.tests.synthetic_parser",
    function_name = "parse",
}
adapter.memory_accesses = {}
adapter.boundary_effects = {}
adapter.register_effects = {}
adapter.instruction_events = {}
adapter.stack_effects = {}

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
        ] == nil
        and profile_counts[
            "context.configure.validate.instruction_events_reuse"
        ] == 1
        and profile_counts[
            "context.configure.validate.instruction_events"
        ] == nil
        and profile_counts[
            "context.configure.validate.stack_effects_reuse"
        ] == 1
        and profile_counts[
            "context.configure.validate.stack_effects"
        ] == nil
        and profile_counts[
            "context.configure.validate.construct_specs_reuse"
        ] == 1
        and profile_counts[
            "context.configure.validate.construct_specs"
        ] == nil
        and profile_counts[
            "context.configure.validate.scope_members_reuse"
        ] == 1
        and profile_counts[
            "context.configure.validate.scope_members"
        ] == nil
        and profile_counts[
            "context.configure.validate.presentation_reuse"
        ] == 1
        and profile_counts[
            "context.configure.validate.presentation"
        ] == nil
        and profile_counts[
            "context.configure.validate.instruction_parser_reuse"
        ] == 1
        and profile_counts[
            "context.configure.validate.instruction_parser"
        ] == nil
        and profile_counts[
            "context.configure.validate.memory_accesses_reuse"
        ] == 1
        and profile_counts[
            "context.configure.validate.memory_accesses"
        ] == nil
        and profile_counts[
            "context.configure.validate.boundary_effects_reuse"
        ] == 1
        and profile_counts[
            "context.configure.validate.boundary_effects"
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
        ] == 1
        and profile_counts[
            "context.configure.validate.instruction_events"
        ] == 1
        and profile_counts[
            "context.configure.validate.stack_effects"
        ] == 1
        and profile_counts[
            "context.configure.validate.construct_specs"
        ] == 1
        and profile_counts[
            "context.configure.validate.scope_members"
        ] == 1
        and profile_counts[
            "context.configure.validate.presentation"
        ] == 1
        and profile_counts[
            "context.configure.validate.instruction_parser"
        ] == 1
        and profile_counts[
            "context.configure.validate.memory_accesses"
        ] == 1
        and profile_counts[
            "context.configure.validate.boundary_effects"
        ] == 1,
    "revoked stable-component declaration still reused validation"
)

print(
    "PASS adapter validation reuse: "
        .. "revoking declaration restores full validation"
)

adapter.validation_stable_components = {
    register_effects = true,
    instruction_events = true,
    stack_effects = true,
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

adapter.register_effects = {}
adapter.instruction_events = {}

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

adapter.instruction_events = {
    call = {},
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
            "instruction_events.call",
            1,
            true
        ) ~= nil
        and profile_counts[
            "context.configure.validate.instruction_events"
        ] == 1
        and profile_counts[
            "context.configure.validate.instruction_events_reuse"
        ] == nil,
    "replacement stable instruction-event component did not force full validation"
)

print(
    "PASS adapter validation reuse: "
        .. "instruction-event replacement identity forces contract validation"
)


adapter.register_effects = {}
adapter.instruction_events = {}
adapter.stack_effects = {}

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

adapter.stack_effects = {
    push = {},
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
            "stack_effects.push",
            1,
            true
        ) ~= nil
        and profile_counts[
            "context.configure.validate.stack_effects"
        ] == 1
        and profile_counts[
            "context.configure.validate.stack_effects_reuse"
        ] == nil,
    "replacement stable stack-effect component did not force full validation"
)

print(
    "PASS adapter validation reuse: "
        .. "stack-effect replacement identity forces contract validation"
)

adapter.stack_effects = {}

local reusable_validation_baseline = {
    construct_specs = adapter.construct_specs,
    scope_members = adapter.scope_members,
    presentation = adapter.presentation,
    instruction_parser = adapter.instruction_parser,
    memory_accesses = adapter.memory_accesses,
    boundary_effects = adapter.boundary_effects,
}

local reusable_validation_replacements = {
    {
        component = "construct_specs",
        invalid = {},
    },
    {
        component = "scope_members",
        invalid = "invalid",
    },
    {
        component = "presentation",
        invalid = "invalid",
    },
    {
        component = "instruction_parser",
        invalid = {},
    },
    {
        component = "memory_accesses",
        invalid = "invalid",
    },
    {
        component = "boundary_effects",
        invalid = "invalid",
    },
}

adapter.validation_stable_components = {
    construct_specs = true,
    scope_members = true,
    presentation = true,
    instruction_parser = true,
    memory_accesses = true,
    boundary_effects = true,
}

for _, case in ipairs(
    reusable_validation_replacements
) do
    for component, value in pairs(
        reusable_validation_baseline
    ) do
        adapter[component] = value
    end

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

    adapter[case.component] =
        case.invalid

    ok, err =
        registry.configure_adapter_for_buffer(
            "lua",
            buffer_a,
            config_b,
            profile_opts
        )

    local phase =
        "context.configure.validate."
        .. case.component

    assert(
        ok == false
            and profile_counts[phase]
                == 1
            and profile_counts[
                phase .. "_reuse"
            ] == nil,
        "replacement stable component did not force full validation: "
            .. case.component
    )
end

print(
    "PASS adapter validation reuse: "
        .. "extended replacement identities force contract validation"
)


print(
    "PASS Tracker_HUD adapter-configuration cache smoke"
)
