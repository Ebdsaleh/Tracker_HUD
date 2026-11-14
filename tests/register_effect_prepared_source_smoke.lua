-- tests/register_effect_prepared_source_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_effect_prepared_source_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local pipeline =
    require(
        "tracker_hud.low_level.register_effect_pipeline"
    )

local function fake_node(
    id,
    row,
    column
)
    return {
        id = id,
        type = function()
            return "instruction"
        end,
        range = function()
            return row,
                column,
                row,
                column + 12
        end,
        iter_children = function()
            return function()
                return nil
            end
        end,
    }
end

local first =
    fake_node(
        "first",
        0,
        0
    )

local second =
    fake_node(
        "second",
        1,
        0
    )

local scan_calls = 0
local forbid_scan = false

local root = {
    type = function()
        return "program"
    end,

    range = function()
        return 0, 0, 2, 0
    end,

    iter_children = function()
        scan_calls =
            scan_calls + 1

        assert(
            not forbid_scan,
            "prepared source unexpectedly rescanned root"
        )

        local nodes = {
            first,
            second,
        }

        local index = 0

        return function()
            index = index + 1
            return nodes[index]
        end
    end,
}

local rule = {
    syntax = {
        node_type = "instruction",
        fields = {
            kind = {
                field = "kind",
                node_type = "word",
                text = "mov",
            },
        },
    },

    operands = {
        {
            index = 1,
            kind = "register",
        },
        {
            index = 2,
            kind = "integer",
        },
    },

    effect = {
        name = "mov_register_immediate",
        target_operand = 1,
        value_operand = 2,
    },
}

local adapter = {
    name = "asm",
    architecture = "test",
    active_variant_name = "test",

    registers = {
        static = {
            {
                name = "rax",
                bits = 64,
            },
            {
                name = "rbx",
                bits = 64,
            },
        },
    },

    register_effects = {
        mov = {
            rule,
        },
    },
}

local function parse_instruction(node)
    if node == first then
        return {
            mnemonic = "mov",
            source_line = 1,
            operands = {
                {
                    kind = "register",
                    text = "rax",
                    source_line = 1,
                },
                {
                    kind = "integer",
                    text = "41",
                    source_line = 1,
                },
            },
        }
    end

    assert(
        node == second,
        "unexpected prepared-source node"
    )

    return {
        mnemonic = "mov",
        source_line = 2,
        operands = {
            {
                kind = "register",
                text = "rbx",
                source_line = 2,
            },
            {
                kind = "integer",
                text = "42",
                source_line = 2,
            },
        },
    }
end

local opts = {
    bufnr = 1,
    root_node = root,
    limit_position = {
        line = 3,
        column = 0,
    },
}

local legacy =
    pipeline.collect(
        {
            cursor = {
                line = 2,
                column = 200,
            },
        },
        adapter,
        opts,
        {
            parse_instruction =
                parse_instruction,
        }
    )

local prepared =
    pipeline.prepare_source(
        adapter,
        {
            root_node = root,
        }
    )

assert(
    prepared
        and #prepared.nodes == 2,
    "prepared register source was not built"
)

local scans_after_prepare =
    scan_calls

forbid_scan = true

local prepared_opts = {
    bufnr = 1,
    root_node = root,
    limit_position = {
        line = 3,
        column = 0,
    },
    prepared_source = prepared,
}

local reused =
    pipeline.collect(
        {
            cursor = {
                line = 2,
                column = 200,
            },
        },
        adapter,
        prepared_opts,
        {
            parse_instruction =
                parse_instruction,
        }
    )

assert(
    scan_calls
        == scans_after_prepare,
    "prepared collect rescanned source tree"
)

local function normalize(facts)
    local rows = {}

    for _, fact in ipairs(
        facts or {}
    ) do
        rows[#rows + 1] =
            table.concat({
                tostring(fact.name),
                tostring(fact.value),
                tostring(fact.resolved),
                tostring(
                    fact.metadata
                        and fact.metadata.effect
                ),
            }, "|")
    end

    table.sort(rows)

    return table.concat(
        rows,
        "\n"
    )
end

assert(
    normalize(reused)
        == normalize(legacy),
    "prepared register source changed full-reduction semantics"
)

print(
    "PASS register prepared source: "
        .. "filtered collection matches legacy without rescanning"
)

local session =
    pipeline.new_replay_session(
        {},
        adapter,
        {
            bufnr = 1,
            root_node = root,
            prepared_source =
                prepared,
        },
        {
            parse_instruction =
                parse_instruction,
        }
    )

assert(
    session,
    "prepared-source replay session was not created"
)

local prefix =
    session:collect_before({
        line = 3,
        column = 0,
    })

assert(
    scan_calls
        == scans_after_prepare
        and normalize(prefix)
            == normalize(legacy),
    "prepared replay session changed semantics or rescanned"
)

print(
    "PASS register prepared source: "
        .. "independent replay session reuses immutable index"
)

print(
    "PASS Tracker_HUD register-effect "
        .. "prepared-source smoke"
)
