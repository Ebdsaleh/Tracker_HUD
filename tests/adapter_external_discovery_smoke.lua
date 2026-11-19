-- tests/adapter_external_discovery_smoke.lua
--
-- Proves adapter #5 can live outside Tracker_HUD and that discovery failures
-- are surfaced with module identity plus exact Contract v1 paths.

local function run()
    vim.opt.runtimepath:prepend(
        vim.fn.getcwd()
    )

    local fixture_runtime =
        vim.fn.getcwd()
        .. "/tests/fixtures/adapter_runtime"

    vim.opt.runtimepath:prepend(
        fixture_runtime
    )

    local loader =
        require(
            "tracker_hud.adapters.loader"
        )
    local registry =
        require(
            "tracker_hud.adapters.registry"
        )

    local result =
        loader.reload({
            "test_tracker_adapters",
        })

    assert(
        result.loaded_count == 1,
        "external loader expected exactly one valid adapter; got "
            .. tostring(result.loaded_count)
    )

    assert(
        #result.errors == 1,
        "external loader expected exactly one invalid adapter error; got "
            .. tostring(#result.errors)
    )

    local adapter =
        registry.get_adapter(
            "external_example"
        )

    assert(
        adapter
            and adapter.name
                == "external_example"
            and adapter.construct_specs
                .source_file.scope.kind
                == "lexical",
        "external adapter was not discovered and registered by filetype"
    )

    local expected_fragment =
        "adapter.construct_specs[source_file].construct.kind is invalid or missing"

    assert(
        result.errors[1]:find(
            "test_tracker_adapters.broken.init",
            1,
            true
        )
            and result.errors[1]:find(
                expected_fragment,
                1,
                true
            ),
        "external adapter error lost module identity or exact contract path: "
            .. tostring(result.errors[1])
    )

    print(
        "PASS external adapter path discovery + filetype registration"
    )


    local notices = {}
    local original_notify =
        vim.notify

    vim.notify = function(
        message,
        level
    )
        table.insert(
            notices,
            {
                message = tostring(message),
                level = level,
            }
        )
    end

    local tracker_hud =
        require("tracker_hud")

    local setup_ok,
        setup_result_or_err =
        pcall(
            tracker_hud.setup,
            {
                adapter_paths = {
                    "test_tracker_adapters",
                },
            }
        )

    vim.notify =
        original_notify

    assert(
        setup_ok,
        "Tracker_HUD setup failed while loading external adapters: "
            .. tostring(setup_result_or_err)
    )

    local setup_result =
        setup_result_or_err

    assert(
        type(setup_result) == "table"
            and setup_result.loaded_count
                == 1
            and #setup_result.errors
                == 1,
        "setup did not return external adapter load status"
    )

    local warning_found = false

    for _, notice in ipairs(notices) do
        if notice.message:find(
            "tracker_hud adapter load error:",
            1,
            true
        )
            and notice.message:find(
                "test_tracker_adapters.broken.init",
                1,
                true
            )
            and notice.message:find(
                expected_fragment,
                1,
                true
            )
        then
            warning_found = true
            break
        end
    end

    assert(
        warning_found,
        "setup silently discarded external adapter validation failure"
    )

    assert(
        registry.get_adapter(
            "external_example"
        ) ~= nil,
        "valid external adapter was lost when another discovered adapter failed"
    )

    print(
        "PASS setup reports broken external adapter without blocking valid peers"
    )
end


run()
