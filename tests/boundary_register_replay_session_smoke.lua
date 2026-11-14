-- tests/boundary_register_replay_session_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/boundary_register_replay_session_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local pipeline =
    require(
        "tracker_hud.low_level.boundary_effect_pipeline"
    )

local function fake_node(
    id,
    mnemonic,
    line
)
    return {
        id = id,
        mnemonic = mnemonic,

        type = function()
            return "instruction"
        end,

        range = function()
            return line - 1,
                0,
                line - 1,
                8
        end,

        iter_children = function()
            return function()
                return nil
            end
        end,
    }
end

local matched =
    fake_node(
        "matched",
        "syscall",
        2
    )

local unmatched =
    fake_node(
        "unmatched",
        "mov",
        1
    )

local root = {
    type = function()
        return "program"
    end,

    range = function()
        return 0, 0, 2, 0
    end,

    iter_children = function()
        local nodes = {
            unmatched,
            matched,
        }

        local index = 0

        return function()
            index = index + 1
            return nodes[index]
        end
    end,
}

local effect = {
    syntax = {
        node_type = "instruction",
    },

    kind = "syscall",
    category = "system",

    reads = {
        number_register = "rax",
    },

    known_effects = {
        ["1"] = {
            name = "write",
            category = "io",
        },
    },
}

local adapter = {
    name = "asm",
    boundary_effects = {
        syscall = {
            effect,
        },
    },
}

local replay_queries = {}
local fallback_calls = 0
local creator_calls = 0

local facts =
    pipeline.collect(
        {
            cursor = {
                line = 2,
                column = 20,
            },
        },
        adapter,
        {
            bufnr = 7,
            root_node = root,
        },
        {
            parse_instruction = function(
                node
            )
                return {
                    mnemonic =
                        node.mnemonic,
                    source_line =
                        node == matched
                        and 2
                        or 1,
                    source_start_line =
                        node == matched
                        and 2
                        or 1,
                    source_start_column = 0,
                    source_column = 0,
                    operands = {},
                }
            end,

            collect_register_effects =
                function()
                    fallback_calls =
                        fallback_calls + 1

                    return {}
                end,

            create_register_replay_session =
                function()
                    creator_calls =
                        creator_calls + 1

                    return {
                        collect_before =
                            function(
                                _self,
                                position
                            )
                                replay_queries[
                                    #replay_queries
                                        + 1
                                ] = {
                                    line =
                                        position.line,
                                    column =
                                        position.column,
                                }

                                return {
                                    {
                                        name = "rax",
                                        value = "1",
                                        resolved = true,
                                    },
                                }
                            end,
                    }
                end,
        }
    )

assert(
    creator_calls == 1,
    "boundary replay session must be created once per collection"
)

assert(
    #replay_queries == 2
        and replay_queries[1].line
            == 1
        and replay_queries[2].line
            == 2,
    "boundary read-context query ordering changed"
)

assert(
    fallback_calls == 0,
    "incremental boundary replay unexpectedly used full fallback"
)

print(
    "PASS boundary register replay: "
        .. "one session serves ordered read contexts"
)

assert(
    #facts == 1
        and facts[1].kind
            == "syscall"
        and facts[1].name
            == "write"
        and facts[1].effect_key
            == "1",
    "boundary fact semantics changed under replay session"
)

print(
    "PASS boundary register replay: "
        .. "known boundary fact preserved"
)

print(
    "PASS Tracker_HUD boundary register-replay session smoke"
)
