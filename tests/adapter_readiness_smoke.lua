-- tests/adapter_readiness_smoke.lua
--
-- Proves the on-demand adapter readiness diagnostic covers the author-facing
-- filetype -> parser -> root -> registry -> Contract chain without entering the
-- normal cursor-refresh hot path.

local function run()
    vim.opt.runtimepath:prepend(
        vim.fn.getcwd()
    )

    local readiness =
        require(
            "tracker_hud.adapters.readiness"
        )
    local registry =
        require(
            "tracker_hud.adapters.registry"
        )
    local lua_adapter =
        require(
            "tracker_hud.adapters.lua"
        )

    registry.clear()

    local registered,
        register_err =
        registry.register(
            lua_adapter
        )

    assert(
        registered,
        "Lua adapter fixture failed registration: "
            .. tostring(register_err)
    )

    local original_buffer =
        vim.api.nvim_get_current_buf()

    local lua_buffer =
        vim.api.nvim_create_buf(
            false,
            true
        )

    vim.bo[lua_buffer].filetype =
        "lua"

    vim.api.nvim_buf_set_lines(
        lua_buffer,
        0,
        -1,
        false,
        {
            "local function greet(name)",
            "    return name",
            "end",
        }
    )

    local status =
        readiness.inspect(
            lua_buffer
        )

    assert(
        status.ready
            == true
            and status.filetype
                == "lua"
            and status.language
                == "lua"
            and status.parser_available
                == true
            and status.root_available
                == true
            and type(status.root_type)
                == "string"
            and status.adapter_registered
                == true
            and status.adapter_name
                == "lua"
            and status.adapter_valid
                == true,
        "healthy Lua buffer did not report adapter readiness"
    )

    local message =
        readiness.message(
            status
        )

    assert(
        message:find(
            "[OK] filetype: lua",
            1,
            true
        )
            and message:find(
                "[OK] parser: available",
                1,
                true
            )
            and message:find(
                "[OK] adapter: lua",
                1,
                true
            )
            and message:find(
                "[READY] adapter pipeline is ready",
                1,
                true
            ),
        "healthy readiness report lost author-facing status details"
    )

    print(
        "PASS adapter readiness reports healthy filetype/parser/root/contract chain"
    )


    local original_kind =
        lua_adapter.construct_specs
            .function_declaration
            .construct.kind

    lua_adapter.construct_specs
        .function_declaration
        .construct.kind =
            "not_a_construct_kind"

    local invalid_status =
        readiness.inspect(
            lua_buffer
        )

    lua_adapter.construct_specs
        .function_declaration
        .construct.kind =
            original_kind

    assert(
        invalid_status.ready
            == false
            and invalid_status.adapter_registered
                == true
            and invalid_status.adapter_valid
                == false
            and invalid_status.adapter_error
                == "adapter.construct_specs[function_declaration].construct.kind is invalid or missing",
        "readiness diagnostic did not surface exact registered-adapter contract failure"
    )


    local missing_buffer =
        vim.api.nvim_create_buf(
            false,
            true
        )

    vim.bo[missing_buffer].filetype =
        "tracker_hud_missing_parser_zzzz"

    local missing_status =
        readiness.inspect(
            missing_buffer
        )

    assert(
        missing_status.filetype_known
            == true
            and missing_status.parser_available
                == false
            and missing_status.root_available
                == false
            and missing_status.adapter_registered
                == false
            and missing_status.ready
                == false,
        "readiness diagnostic failed closed incorrectly for missing parser/adapter"
    )

    print(
        "PASS adapter readiness isolates parser/registration/contract failures"
    )


    vim.api.nvim_set_current_buf(
        lua_buffer
    )

    local notices = {}
    local original_notify =
        vim.notify

    vim.notify = function(
        notification,
        level
    )
        table.insert(
            notices,
            {
                message =
                    tostring(
                        notification
                    ),
                level = level,
            }
        )
    end

    local tracker_hud =
        require("tracker_hud")

    local setup_ok,
        setup_err =
        pcall(
            tracker_hud.setup,
            {}
        )

    local command_ok,
        command_err =
        pcall(
            vim.cmd,
            "HudAdapterStatus"
        )

    vim.notify =
        original_notify

    assert(
        setup_ok,
        "Tracker_HUD setup failed in readiness smoke: "
            .. tostring(setup_err)
    )

    assert(
        command_ok,
        "HudAdapterStatus command failed: "
            .. tostring(command_err)
    )

    local commands =
        vim.api.nvim_get_commands({})

    assert(
        commands.HudAdapterStatus,
        "HudAdapterStatus command was not registered"
    )

    local command_reported_ready =
        false

    for _, notice in ipairs(notices) do
        if notice.message:find(
            "Tracker_HUD adapter readiness",
            1,
            true
        )
            and notice.message:find(
                "[READY] adapter pipeline is ready",
                1,
                true
            )
        then
            command_reported_ready =
                true
            break
        end
    end

    assert(
        command_reported_ready,
        "HudAdapterStatus did not report healthy current-buffer readiness"
    )

    print(
        "PASS HudAdapterStatus exposes on-demand namespaced readiness report"
    )

    vim.api.nvim_set_current_buf(
        original_buffer
    )

    pcall(
        vim.api.nvim_buf_delete,
        lua_buffer,
        { force = true }
    )

    pcall(
        vim.api.nvim_buf_delete,
        missing_buffer,
        { force = true }
    )
end


run()
