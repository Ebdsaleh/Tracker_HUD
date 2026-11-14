-- tests/register_state_write_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_state_write_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local writer =
    require("tracker_hud.low_level.register_state_write")

local family = {
    bits = 64,
    aliases = {
        rax = {},
        eax = {},
        ax = {},
        al = {},
        ah = {},
    },
}

local adapter = {
    register_alias_index = {
        rax = {
            canonical = "rax",
            family = family,
            alias = {
                bits = 64,
                offset = 0,
            },
        },

        eax = {
            canonical = "rax",
            family = family,
            alias = {
                bits = 32,
                offset = 0,
            },
        },

        ax = {
            canonical = "rax",
            family = family,
            alias = {
                bits = 16,
                offset = 0,
            },
        },

        al = {
            canonical = "rax",
            family = family,
            alias = {
                bits = 8,
                offset = 0,
            },
        },

        ah = {
            canonical = "rax",
            family = family,
            alias = {
                bits = 8,
                offset = 8,
            },
        },
    },
}

local facts_by_register = {
    rax = {
        value = "old-rax",
    },
    eax = {
        value = "old-eax",
    },
    ax = {
        value = "old-ax",
    },
    al = {
        value = "old-al",
    },
    ah = {
        value = "old-ah",
    },
}

local family_state = {}
local latest_state_facts = {}

local fact = {
    name = "eax",
    value = "0x0000000000000005",
    resolved = true,

    metadata = {
        write_value = "5",
        write_resolved = true,
        canonical_name = "rax",
    },
}

writer.publish(
    facts_by_register,
    family_state,
    latest_state_facts,
    adapter,
    fact
)

assert(
    latest_state_facts.rax == fact
        and family_state.rax == fact,
    "canonical latest/family publication changed"
)
print("PASS register state write: canonical latest and family state preserved")

assert(
    facts_by_register.ax == nil
        and facts_by_register.al == nil
        and facts_by_register.ah == nil,
    "sibling aliases were not invalidated"
)
print("PASS register state write: sibling alias invalidation preserved")

assert(
    facts_by_register.eax
        and facts_by_register.eax.name
            == "eax"
        and facts_by_register.eax.value
            == "5"
        and facts_by_register.eax.resolved
            == true
        and facts_by_register.eax.metadata
            == fact.metadata,
    "raw source-alias publication changed"
)
print("PASS register state write: raw write publication preserved")

assert(
    facts_by_register.rax
        and facts_by_register.rax.name
            == "rax"
        and facts_by_register.rax.value
            == "0x0000000000000005"
        and facts_by_register.rax.resolved
            == true,
    "reduced canonical publication changed"
)
print("PASS register state write: reduced canonical publication preserved")

local unknown_fact = {
    name = "eax",
    value = nil,
    resolved = false,

    metadata = {
        write_value = "rbx",
        write_resolved = false,
        canonical_name = "rax",
    },
}

writer.publish(
    facts_by_register,
    family_state,
    latest_state_facts,
    adapter,
    unknown_fact
)

assert(
    facts_by_register.eax.value
            == "rbx"
        and facts_by_register.eax.resolved
            == false
        and facts_by_register.rax.value
            == nil
        and facts_by_register.rax.resolved
            == false,
    "unknown write publication changed"
)
print("PASS register state write: unresolved raw/canonical publication preserved")

local canonical_fact = {
    name = "rax",
    value = "9",
    resolved = true,
    metadata = {
        write_value = "9",
        write_resolved = true,
    },
}

writer.publish(
    facts_by_register,
    family_state,
    latest_state_facts,
    adapter,
    canonical_fact
)

assert(
    latest_state_facts.rax
        == canonical_fact
        and family_state.rax
            == canonical_fact
        and facts_by_register.rax.value
            == "9"
        and facts_by_register.rax.resolved
            == true,
    "direct canonical publication changed"
)
print("PASS register state write: direct canonical publication preserved")

local before = facts_by_register.rax

writer.publish(
    nil,
    family_state,
    latest_state_facts,
    adapter,
    canonical_fact
)

assert(
    facts_by_register.rax == before,
    "invalid publication input must fail closed"
)
print("PASS register state write: invalid inputs fail closed")

print("PASS Tracker_HUD register-state write smoke")
