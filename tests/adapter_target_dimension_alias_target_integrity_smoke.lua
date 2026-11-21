-- tests/adapter_target_dimension_alias_target_integrity_smoke.lua
--
-- Adapter registration already rejects aliases with undeclared canonical
-- targets. Direct resolution must reject the *entire descriptor*, even when
-- the requested value would not visit the malformed alias.
--
-- Alias targets are canonical IDs: they must match a supported value exactly,
-- rather than relying on requested-token case folding or alias chaining.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local contract =
        require("tracker_hud.adapters.contract")
    local target_dimensions =
        require("tracker_hud.adapters.target_dimensions")
    local cpp =
        require("tracker_hud.adapters.cpp.adapter")

    local function descriptor(aliases)
        return {
            default = "v2",
            supported = { "v1", "v2", "v3" },
            aliases = aliases,
        }
    end

    local good = descriptor({
        old = "v1",
        current = "v2",
        latest = "v3",
    })

    local probe = vim.deepcopy(cpp)
    probe.target_dimensions.edition = vim.deepcopy(good)

    local registered, register_err =
        contract.validate_adapter(probe)

    assert(
        registered == true and register_err == nil,
        "valid alias-target declaration was rejected: "
            .. tostring(register_err)
    )

    for _, example in ipairs({
        { requested = nil, canonical = "v2" },
        { requested = " CURRENT ", canonical = "v2" },
        { requested = "latest", canonical = "v3" },
        { requested = "OLD", canonical = "v1" },
    }) do
        local value, err =
            target_dimensions.resolve_value(
                good,
                example.requested
            )

        assert(
            value == example.canonical and err == nil,
            "valid alias target failed: "
                .. tostring(example.requested)
                .. " => " .. tostring(value)
                .. " / " .. tostring(err)
        )
    end

    print(
        "PASS valid canonical alias targets preserve default and case-insensitive requests"
    )

    local invalid = {
        {
            label = "unsupported alias target",
            aliases = {
                old = "v1",
                future = "v9",
            },
        },
        {
            label = "non-string alias target",
            aliases = {
                old = "v1",
                future = 9,
            },
        },
        {
            label = "whitespace alias target",
            aliases = {
                old = "v1",
                future = "  ",
            },
        },
        {
            label = "alias-to-alias chain",
            aliases = {
                old = "v1",
                future = "old",
            },
        },
        {
            label = "case-folded noncanonical alias target",
            aliases = {
                old = "v1",
                future = "V3",
            },
        },
        {
            label = "padded noncanonical alias target",
            aliases = {
                old = "v1",
                future = " v3 ",
            },
        },
    }

    for _, case in ipairs(invalid) do
        local bad = descriptor(case.aliases)
        local candidate = vim.deepcopy(cpp)
        candidate.target_dimensions.edition =
            vim.deepcopy(bad)

        local ok, err =
            contract.validate_adapter(candidate)

        assert(
            ok == false
                and type(err) == "string"
                and err:find("target_dimensions", 1, true),
            "registration accepted "
                .. case.label .. ": " .. tostring(err)
        )

        -- Unvalidated callers must not receive even an otherwise valid
        -- canonical/default/alias while any target is malformed.
        for _, request in ipairs({
            "v2",
            "old",
        }) do
            local value, resolve_err =
                target_dimensions.resolve_value(
                    bad,
                    request
                )

            assert(
                value == nil
                    and type(resolve_err) == "string"
                    and #resolve_err > 0,
                "direct resolution accepted "
                    .. case.label
                    .. " for " .. request
                    .. ": " .. tostring(value)
                    .. " / " .. tostring(resolve_err)
            )
        end

        local default_value, default_err =
            target_dimensions.resolve_value(bad, nil)

        assert(
            default_value == nil
                and type(default_err) == "string"
                and #default_err > 0,
            "direct default resolution accepted "
                .. case.label
        )
    end

    assert(
        good.aliases.current == "v2"
            and good.aliases.latest == "v3"
            and cpp.target_dimensions.edition == nil,
        "alias-target checks mutated adapter-owned metadata"
    )

    print(
        "PASS registration and direct resolver reject every invalid alias target atomically"
    )
    print(
        "PASS invalid alias targets cannot activate unrelated canonical/default values"
    )
    print(
        "PASS Tracker_HUD alias-target integrity smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD alias-target integrity smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
