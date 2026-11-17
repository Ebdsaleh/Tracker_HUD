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

local replay_work_counters = {}

local session =
    pipeline.new_replay_session(
        {},
        adapter,
        {
            bufnr = 1,
            root_node = root,
            prepared_source =
                prepared,
            profile_prefix =
                "context.boundary.read_context.register_replay",
            profile_counter =
                function(name, delta)
                    replay_work_counters[name] =
                        (replay_work_counters[name] or 0)
                        + delta
                end,
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

assert(
    replay_work_counters[
        "context.boundary.read_context.register_replay.processed_entries"
    ] == 2,
    "prepared replay session did not forward processed-entry work counter"
)

print(
    "PASS register prepared source: "
        .. "independent replay session reuses immutable index"
)

print(
    "PASS register prepared source: "
        .. "replay work counter reaches processing layer"
)


local before_expected =
    pipeline.collect(
        {
            cursor = {
                line = 2,
                column = 200,
            },
        },
        adapter,
        {
            bufnr = 1,
            root_node = root,
            limit_position = {
                line = 2,
                column = 0,
            },
            prepared_source =
                prepared,
        },
        {
            parse_instruction =
                parse_instruction,
        }
    )

local visible_expected =
    pipeline.collect(
        {
            cursor = {
                line = 2,
                column = 200,
            },
        },
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

local paired_work_counters = {}

local paired_session =
    pipeline.new_replay_session(
        {},
        adapter,
        {
            bufnr = 1,
            root_node = root,
            prepared_source =
                prepared,
            profile_prefix =
                "context.register_pair",
            profile_counter =
                function(name, delta)
                    paired_work_counters[name] =
                        (paired_work_counters[name] or 0)
                        + delta
                end,
        },
        {
            parse_instruction =
                parse_instruction,
        }
    )

assert(
    paired_session,
    "paired register replay session was not created"
)

local before_paired,
    visible_paired =
    paired_session
        :collect_before_and_visible(
            {
                line = 2,
                column = 0,
            },
            {
                cursor = {
                    line = 2,
                    column = 200,
                },
            }
        )

assert(
    normalize(before_paired)
        == normalize(before_expected),
    "paired replay changed before-line register snapshot"
)

assert(
    normalize(visible_paired)
        == normalize(visible_expected),
    "paired replay changed cursor-visible register snapshot"
)

assert(
    normalize(before_paired)
        == normalize(before_expected),
    "paired replay mutated the earlier before-line snapshot"
)

local paired_stats =
    paired_session:stats()

assert(
    paired_stats.processed_count == 2
        and paired_work_counters[
            "context.register_pair.processed_entries"
        ] == 2,
    "paired replay did not reduce the shared prefix exactly once"
)

print(
    "PASS register prepared source: "
        .. "paired before/visible snapshots preserve independent semantics"
)

print(
    "PASS register prepared source: "
        .. "paired replay reduces shared prefix exactly once"
)



local timeline_session =
    pipeline.new_replay_session(
        {},
        adapter,
        {
            bufnr = 1,
            root_node = root,
            prepared_source =
                prepared,
            capture_timeline = true,
        },
        {
            parse_instruction =
                parse_instruction,
        }
    )

assert(
    timeline_session,
    "timeline register replay session was not created"
)

local timeline =
    timeline_session:get_timeline()

assert(
    timeline,
    "timeline replay session did not expose checkpoints"
)

assert(
    timeline:snapshot_before({
        line = 3,
        column = 0,
    }) == nil,
    "incomplete timeline answered beyond processed coverage"
)

timeline_session:collect_before({
    line = 2,
    column = 0,
})

local timeline_before_second =
    timeline:snapshot_before({
        line = 2,
        column = 0,
    })

assert(
    normalize(timeline_before_second)
        == normalize(before_expected),
    "timeline checkpoint changed pre-instruction register semantics"
)

assert(
    timeline:snapshot_before({
        line = 3,
        column = 0,
    }) == nil,
    "partially advanced timeline answered past its safe coverage"
)

local preserved_before_second =
    normalize(timeline_before_second)

timeline_before_second[1] = nil

assert(
    normalize(
        timeline:snapshot_before({
            line = 2,
            column = 0,
        })
    ) == preserved_before_second,
    "timeline lookup exposed mutable checkpoint list ownership"
)

timeline_session:collect_visible(
    {
        cursor = {
            line = 2,
            column = 200,
        },
    }
)

assert(
    normalize(
        timeline:snapshot_before({
            line = 2,
            column = 0,
        })
    ) == preserved_before_second,
    "advancing timeline mutated earlier pre-instruction checkpoint"
)

assert(
    normalize(
        timeline:snapshot_before({
            line = 3,
            column = 0,
        })
    ) == normalize(visible_expected),
    "completed timeline changed visible register semantics"
)

local timeline_stats =
    timeline:stats()

assert(
    timeline_stats.captured_count == 2
        and timeline_stats.processed_count == 2
        and timeline_stats.source_node_count == 2,
    "timeline checkpoint coverage statistics changed"
)

print(
    "PASS register prepared source: "
        .. "timeline lookup matches independent pre-instruction replay"
)

print(
    "PASS register prepared source: "
        .. "timeline fails closed beyond processed coverage"
)

print(
    "PASS register prepared source: "
        .. "timeline checkpoints remain immutable across forward replay"
)


print(
    "PASS Tracker_HUD register-effect "
        .. "prepared-source smoke"
)
