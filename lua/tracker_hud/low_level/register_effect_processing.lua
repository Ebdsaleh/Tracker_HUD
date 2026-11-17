-- lua/tracker_hud/low_level/register_effect_processing.lua
--
-- Register-effect processing orchestration.
--
-- This module owns temporary state containers and the ordered processing loop
-- over already-collected instruction nodes. Register semantics remain in the
-- injected callbacks.
--
-- The session API preserves the same processing semantics while allowing a
-- caller to advance monotonically through source order and snapshot the current
-- reduced register state without replaying the prefix from the beginning.

local M = {}


local function profile_name(
    opts,
    suffix
)
    local prefix =
        opts
        and opts.profile_prefix
        or "context.registers.dynamic.process"

    return prefix
        .. "."
        .. suffix
end


local function profile_begin(
    opts,
    suffix
)
    if type(opts) ~= "table"
        or type(opts.profile_begin)
            ~= "function"
    then
        return nil
    end

    return opts.profile_begin(
        profile_name(
            opts,
            suffix
        )
    )
end


local function profile_end(
    opts,
    suffix,
    started
)
    if type(opts) ~= "table"
        or type(opts.profile_end)
            ~= "function"
    then
        return nil
    end

    return opts.profile_end(
        profile_name(
            opts,
            suffix
        ),
        started
    )
end


local function profile_counter(
    opts,
    suffix,
    delta
)
    if type(opts) ~= "table"
        or type(opts.profile_counter)
            ~= "function"
    then
        return nil
    end

    return opts.profile_counter(
        profile_name(
            opts,
            suffix
        ),
        delta
    )
end


local function dependencies_are_valid(
    opts
)
    return type(opts) == "table"
        and type(opts.effect_index)
            == "table"
        and type(opts.effect_index.by_node_type)
            == "table"
        and type(opts.parse_instruction)
            == "function"
        and type(opts.normalize_mnemonic)
            == "function"
        and type(opts.new_low_level_state)
            == "function"
        and type(opts.prepare_instruction_state)
            == "function"
        and type(opts.apply_effect)
            == "function"
        and type(opts.to_fact_list)
            == "function"
end


local function process_entry(
    session,
    entry
)
    local node =
        entry and entry.node
        or nil

    if not node then
        return
    end

    local node_type =
        node:type()

    local node_bucket =
        session.opts.effect_index
            .by_node_type[
                node_type
            ]

    if not node_bucket then
        return
    end

    local representative_effect_spec =
        node_bucket.__first

    local phase =
        profile_begin(
            session.opts,
            "parse"
        )

    local instruction =
        session.opts.parse_instruction(
            node,
            representative_effect_spec
        )

    profile_end(
        session.opts,
        "parse",
        phase
    )

    local mnemonic =
        instruction
        and session.opts
            .normalize_mnemonic(
                instruction.mnemonic
            )
        or nil

    local effect_specs =
        mnemonic
        and node_bucket[mnemonic]
        or nil

    phase =
        profile_begin(
            session.opts,
            "prepare_state"
        )

    local instruction_state =
        session.opts
            .prepare_instruction_state(
                session.low_level_state,
                session.facts_by_register,
                instruction,
                effect_specs
            )

    profile_end(
        session.opts,
        "prepare_state",
        phase
    )

    phase =
        profile_begin(
            session.opts,
            "apply"
        )

    for _, effect_spec in ipairs(
        effect_specs or {}
    ) do
        session.opts.apply_effect(
            session.facts_by_register,
            session.family_state,
            session.latest_state_facts,
            instruction,
            effect_spec,
            instruction_state
        )
    end

    profile_end(
        session.opts,
        "apply",
        phase
    )
end


function M.new_session(opts)
    opts = opts or {}

    if not dependencies_are_valid(
        opts
    ) then
        return nil
    end

    return {
        opts = opts,
        nodes = opts.nodes or {},
        next_index = 1,

        facts_by_register = {},
        family_state = {},
        latest_state_facts = {},

        low_level_state =
            opts.new_low_level_state(),

        processed_count = 0,
    }
end


function M.advance_while(
    session,
    should_process
)
    if type(session) ~= "table"
        or type(should_process)
            ~= "function"
    then
        return 0
    end

    local advanced = 0

    while session.next_index
        <= #session.nodes
    do
        local entry =
            session.nodes[
                session.next_index
            ]

        if not should_process(entry) then
            break
        end

        process_entry(
            session,
            entry
        )

        if type(
            session.opts.after_entry
        ) == "function"
        then
            local timeline_phase =
                profile_begin(
                    session.opts,
                    "timeline_capture"
                )

            session.opts.after_entry(
                entry,
                session.latest_state_facts
            )

            profile_end(
                session.opts,
                "timeline_capture",
                timeline_phase
            )

            profile_counter(
                session.opts,
                "timeline_checkpoints",
                1
            )
        end

        session.next_index =
            session.next_index + 1

        session.processed_count =
            session.processed_count + 1

        advanced = advanced + 1
    end

    profile_counter(
        session.opts,
        "processed_entries",
        advanced
    )

    return advanced
end


function M.advance_all(session)
    return M.advance_while(
        session,
        function()
            return true
        end
    )
end


function M.snapshot(session)
    if type(session) ~= "table"
        or not dependencies_are_valid(
            session.opts
        )
    then
        return {}
    end

    local phase =
        profile_begin(
            session.opts,
            "snapshot"
        )

    local result =
        session.opts.to_fact_list(
            session.latest_state_facts
        )

    profile_end(
        session.opts,
        "snapshot",
        phase
    )

    return result
end


function M.process(opts)
    local session =
        M.new_session(opts)

    if not session then
        return {}
    end

    M.advance_all(session)

    return M.snapshot(session)
end


return M
