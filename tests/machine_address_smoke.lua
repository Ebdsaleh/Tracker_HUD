-- tests/machine_address_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/machine_address_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local machine_address =
    require("tracker_hud.low_level.machine_address")

local function provider(id, kind, fn)
    return {
        id = id,
        kind = kind,
        resolve = fn,
    }
end

local result = machine_address.resolve(
    {},
    {
        kind = "instruction",
        source_line = 4096,
    },
    {
        bits = 64,
    }
)

assert(result.status == "unknown"
    and result.reason == "machine address unavailable"
    and result.value == nil,
    "source line must never become a machine address without provider evidence")
print("PASS machine address: source location is not an address")

result = machine_address.resolve(
    {
        provider(
            "listing",
            "assembler_listing",
            function(query)
                assert(query.kind == "symbol"
                    and query.name == "msg",
                    "provider received wrong query")

                return {
                    status = "known",
                    value = "0xFFFFFFFFFFFFFFFF",
                    provenance = {
                        source = "fixture listing",
                    },
                }
            end
        ),
    },
    {
        kind = "symbol",
        name = "msg",
        source_line = 12,
    },
    {
        bits = 64,
    }
)

assert(result.status == "known"
    and result.value == "18446744073709551615"
    and result.bits == 64
    and #result.provenance == 1
    and result.provenance[1].provider_id == "listing"
    and result.provenance[1].provider_kind == "assembler_listing"
    and result.provenance[1].source == "fixture listing",
    "provider address must remain exact with provenance")
print("PASS machine address: exact 64-bit provider value + provenance")

result = machine_address.resolve(
    {
        provider(
            "listing",
            "assembler_listing",
            function()
                return {
                    status = "known",
                    value = "4096",
                }
            end
        ),
        provider(
            "debug",
            "debug_symbols",
            function()
                return {
                    status = "known",
                    value = "0x1000",
                }
            end
        ),
    },
    {
        kind = "instruction",
        source_line = 3,
        source_column = 0,
    },
    {
        bits = 64,
    }
)

assert(result.status == "known"
    and result.value == "4096"
    and #result.provenance == 2,
    "agreeing providers must corroborate one exact address")
print("PASS machine address: agreeing providers corroborate")

result = machine_address.resolve(
    {
        provider(
            "listing",
            "assembler_listing",
            function()
                return {
                    status = "known",
                    value = "4096",
                }
            end
        ),
        provider(
            "debug",
            "debug_symbols",
            function()
                return {
                    status = "known",
                    value = "8192",
                }
            end
        ),
    },
    {
        kind = "symbol",
        name = "msg",
    },
    {
        bits = 64,
    }
)

assert(result.status == "unknown"
    and result.reason == "machine address conflict"
    and result.details
    and #result.details.candidates == 2,
    "conflicting known providers must fail closed")
print("PASS machine address: conflicting providers fail closed")

result = machine_address.resolve(
    {
        provider(
            "bad",
            "fixture",
            function()
                error("provider exploded")
            end
        ),
        provider(
            "good",
            "fixture",
            function()
                return {
                    status = "known",
                    value = "1234",
                }
            end
        ),
    },
    {
        kind = "instruction",
        source_line = 7,
    },
    {
        bits = 64,
    }
)

assert(result.status == "known"
    and result.value == "1234"
    and #result.evidence == 2,
    "one provider failure must not erase independent known evidence")
print("PASS machine address: provider failure stays separate from known evidence")

result = machine_address.resolve(
    {
        provider(
            "too-wide",
            "fixture",
            function()
                return {
                    status = "known",
                    value = "0x100000000",
                }
            end
        ),
    },
    {
        kind = "instruction",
        source_line = 1,
    },
    {
        bits = 32,
    }
)

assert(result.status == "unknown"
    and result.reason == "machine address unavailable"
    and result.details.evidence[1].reason
        == "machine address does not fit address width",
    "out-of-width address claims must be rejected, not wrapped")
print("PASS machine address: out-of-width provider value is rejected")

result = machine_address.resolve(
    {
        provider(
            "unsafe-number",
            "fixture",
            function()
                return {
                    status = "known",
                    value = 9007199254740992,
                }
            end
        ),
    },
    {
        kind = "instruction",
        source_line = 1,
    },
    {
        bits = 64,
    }
)

assert(result.status == "unknown"
    and result.reason == "machine address unavailable",
    "unsafe Lua numeric address must not become an exact machine address")
print("PASS machine address: unsafe numeric provider value is rejected")

result = machine_address.resolve(
    {
        provider("same", "one", function()
            return { status = "known", value = "1" }
        end),
        provider("same", "two", function()
            return { status = "known", value = "1" }
        end),
    },
    {
        kind = "instruction",
        source_line = 1,
    }
)

assert(result.status == "unknown"
    and result.reason == "duplicate machine-address provider id",
    "duplicate provider IDs must fail closed")
print("PASS machine address: duplicate provider IDs are rejected")

result = machine_address.resolve(
    {},
    {
        kind = "symbol",
    }
)

assert(result.status == "unknown"
    and result.reason == "symbol query requires a name",
    "symbol query without a name must fail contract validation")
print("PASS machine address: invalid symbol query fails closed")

result = machine_address.resolve(
    {},
    {
        kind = "source_line",
        source_line = 12,
    }
)

assert(result.status == "unknown"
    and result.reason == "unsupported machine-address query kind",
    "source-line pseudo-address query must not be supported")
print("PASS machine address: source-line pseudo-address kind is rejected")

print("PASS Tracker_HUD machine-address provider smoke")
