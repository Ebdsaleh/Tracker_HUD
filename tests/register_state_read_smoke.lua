-- tests/register_state_read_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_state_read_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local read =
    require("tracker_hud.low_level.register_state_read")

local adapter = {
    registers = {
        static = {
            {
                name = "rax",
                kind = "general",
                bits = 64,
            },
        },
    },

    register_alias_index = {
        rax = {
            canonical = "rax",
            alias = {
                bits = 64,
                offset = 0,
            },
        },

        eax = {
            canonical = "rax",
            alias = {
                bits = 32,
                offset = 0,
            },
        },
    },
}

local rax_spec =
    read.get_static_spec(
        adapter,
        "RAX"
    )

assert(
    rax_spec
        and rax_spec.bits == 64
        and read.get_static_spec(
            adapter,
            "rbx"
        ) == nil,
    "static register lookup changed"
)
print("PASS register state read: static register lookup preserved")

local facts = {
    rax = {
        name = "rax",
        value = "42",
        resolved = true,
        metadata = {
            source = "canonical",
        },
    },
}

assert(
    read.get_fact(
        facts,
        "RAX"
    ) == facts.rax
        and read.get_fact(
            facts,
            ""
        ) == nil,
    "register fact map lookup changed"
)
print("PASS register state read: fact lookup preserved")

local alias =
    read.resolve_alias(
        adapter,
        "EAX"
    )

assert(
    alias
        and alias.canonical == "rax"
        and read.state_key(
            adapter,
            "eax"
        ) == "rax"
        and read.state_key(
            {},
            "RDX"
        ) == "rdx",
    "alias resolution or canonical state key changed"
)
print("PASS register state read: alias resolution and state key preserved")

local projected =
    read.get_fact_for_read(
        facts,
        adapter,
        "eax"
    )

assert(
    projected
        and projected.name == "eax"
        and projected.resolved == true
        and tostring(
            projected.value
        ) == "42"
        and projected.metadata
            == facts.rax.metadata,
    "canonical-to-alias read projection changed"
)
print("PASS register state read: canonical alias projection preserved")

assert(
    read.get_value_width(
        adapter,
        "eax"
    ) == 32
        and read.get_value_width(
            adapter,
            "rax"
        ) == 64
        and read.get_value_width(
            adapter,
            "rbx"
        ) == nil,
    "register width lookup changed"
)
print("PASS register state read: register width lookup preserved")

assert(
    read.fact_is_resolved(
        facts.rax
    )
        and not read.fact_is_resolved({
            value = nil,
            resolved = false,
        })
        and not read.fact_is_resolved(
            nil
        ),
    "resolved-fact classification changed"
)
print("PASS register state read: resolved-fact classification preserved")

local direct = {
    eax = {
        name = "eax",
        value = "7",
        resolved = true,
    },
    rax = facts.rax,
}

assert(
    read.get_fact_for_read(
        direct,
        adapter,
        "eax"
    ) == direct.eax,
    "direct resolved alias fact must take precedence"
)
print("PASS register state read: direct fact precedence preserved")

print("PASS Tracker_HUD register-state read smoke")
