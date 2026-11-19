-- lua/tracker_hud/low_level/register_effect_pipeline.lua
--
-- Register-effect pipeline coordination.
--
-- This module owns architecture-neutral register-effect indexing, visibility
-- collection, instruction-state preparation, effect application and reduction.
-- Adapter instruction parsing remains injected so parsing ownership stays with
-- the adapter/outer source bridge.

local core = require("tracker_hud.core")
local inference =
    require("tracker_hud.low_level.inference")
local instruction_source =
    require("tracker_hud.low_level.instruction_source")
local line_summary =
    require("tracker_hud.low_level.line_summary")
local register_effect_apply =
    require("tracker_hud.low_level.register_effect_apply")
local register_effect_collection =
    require("tracker_hud.low_level.register_effect_collection")
local register_effect_index =
    require("tracker_hud.low_level.register_effect_index")
local register_effect_processing =
    require("tracker_hud.low_level.register_effect_processing")
local register_infer =
    require("tracker_hud.low_level.register_infer")
local register_state_read =
    require("tracker_hud.low_level.register_state_read")
local register_value_policy =
    require("tracker_hud.low_level.register_value_policy")
local rule_syntax =
    require("tracker_hud.low_level.rule_syntax")
local stack_infer =
    require("tracker_hud.low_level.stack_infer")

local M = {}


local function profile_name(
    opts,
    suffix
)
    local prefix =
        opts
        and opts.profile_prefix
        or "context.registers"

    return prefix
        .. ".dynamic."
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
        return
    end

    opts.profile_counter(
        profile_name(
            opts,
            suffix
        ),
        delta
    )
end


function M.get_index(adapter)
    return register_effect_index.get(
        adapter,
        rule_syntax.index_options()
    )
end


function M.prepare_instruction_state(
    low_level_state,
    facts_by_register,
    instruction,
    effect_specs,
    adapter
)
    return stack_infer.prepare_instruction_state(
        low_level_state,
        instruction,
        effect_specs,
        {
            parse_numeric_value =
                register_value_policy
                    .parse_numeric_value,
            parse_numeric_number =
                register_value_policy
                    .parse_numeric_number,

            resolve_operand_value = function(
                operand
            )
                return register_infer
                    .resolve_operand_value(
                        facts_by_register,
                        instruction,
                        operand,
                        {
                            parse_numeric_value =
                                register_value_policy
                                    .parse_numeric_value,

                            resolve_register_fact =
                                function(
                                    register_facts,
                                    register_name
                                )
                                    return register_state_read
                                        .get_fact_for_read(
                                            register_facts,
                                            adapter,
                                            register_name
                                        )
                                end,
                        }
                    )
            end,
        }
    )
end


function M.apply_effect(
    facts_by_register,
    family_state,
    latest_state_facts,
    adapter,
    instruction,
    effect_spec,
    instruction_state,
    opts
)
    opts = opts or {}
    return register_effect_apply.apply(
        facts_by_register,
        family_state,
        latest_state_facts,
        adapter,
        instruction,
        effect_spec,
        instruction_state,
        {
            get_mnemonic =
                rule_syntax.get_mnemonic,
            normalize_mnemonic =
                rule_syntax.normalize_mnemonic,
            profile_prefix =
                opts.apply_profile_prefix
                or profile_name(
                    opts,
                    "process.apply"
                ),
            profile_begin =
                opts.profile_begin,
            profile_end =
                opts.profile_end,
        }
    )
end


local function collect_nodes(
    context,
    opts,
    effect_index
)
    return register_effect_collection.collect({
        context = context,
        config = opts.config,
        node_types =
            effect_index.node_types
            or {},
        limit_position =
            opts.limit_position,
        stop_before =
            opts.stop_before,
        before_position =
            opts.before_position,

        collect_nodes = function(
            node_type
        )
            profile_counter(
                opts,
                "prepare_source.collect_nodes.full_tree_scans",
                1
            )

            local nodes =
                instruction_source
                    .collect_nodes_by_type(
                        opts.root_node,
                        node_type
                    )

            profile_counter(
                opts,
                "prepare_source.collect_nodes.nodes_matched",
                #nodes
            )

            return nodes
        end,

        normalize_position =
            inference.normalize_position,
        position_is_before =
            inference.position_is_before,
        classify_position =
            line_summary
                .classify_instruction_position,
        allows_position =
            line_summary.allows_position,
    })
end


local function copy_session_options(
    opts
)
    local result = {}

    for key, value in pairs(
        opts or {}
    ) do
        result[key] = value
    end

    result.limit_position = nil
    result.stop_before = nil
    result.before_position = nil

    return result
end


local function copy_fact_list(
    facts
)
    local result = {}

    for index, fact in ipairs(
        facts or {}
    ) do
        result[index] = fact
    end

    return result
end


local function prepared_source_is_valid(
    prepared_source,
    adapter,
    opts
)
    return core.is_table(prepared_source)
        and prepared_source.adapter
            == adapter
        and prepared_source.root_node
            == opts.root_node
        and core.is_table(
            prepared_source.effect_index
        )
        and core.is_table(
            prepared_source.nodes
        )
end


local function filter_prepared_nodes(
    prepared_source,
    context,
    opts
)
    local result = {}

    local cursor_line =
        context
        and context.cursor
        and context.cursor.line

    local limit_position =
        inference.normalize_position(
            opts.limit_position
            or opts.stop_before
            or opts.before_position
        )

    for _, entry in ipairs(
        prepared_source.nodes
    ) do
        local should_collect = false

        if limit_position then
            should_collect =
                inference.position_is_before(
                    {
                        line = entry.line,
                        column =
                            entry.column,
                    },
                    limit_position
                )
        elseif not cursor_line
            or entry.line < cursor_line
        then
            should_collect = true
        elseif entry.line == cursor_line then
            local cursor_column =
                context
                and context.cursor
                and context.cursor.column

            if core.is_number(
                cursor_column
            ) then
                cursor_column =
                    math.max(
                        0,
                        cursor_column - 1
                    )
            end

            local _start_row,
                _start_column,
                _end_row,
                end_column =
                entry.node:range()

            local cursor_position =
                line_summary
                    .classify_instruction_position(
                        entry.column,
                        end_column,
                        cursor_column
                    )

            should_collect =
                line_summary.allows_position(
                    opts.config,
                    cursor_position
                )
        end

        if should_collect then
            result[#result + 1] =
                entry
        end
    end

    return result
end


function M.prepare_source(
    adapter,
    opts
)
    opts = opts or {}

    if not opts.root_node
        or not core.is_table(adapter)
        or not core.is_table(
            adapter.register_effects
        )
    then
        return nil
    end

    local phase =
        profile_begin(
            opts,
            "prepare_source.index"
        )

    local effect_index =
        M.get_index(adapter)

    profile_end(
        opts,
        "prepare_source.index",
        phase
    )

    local source_opts =
        copy_session_options(opts)

    phase =
        profile_begin(
            opts,
            "prepare_source.collect_nodes"
        )

    local nodes =
        collect_nodes(
            {},
            source_opts,
            effect_index
        )

    profile_end(
        opts,
        "prepare_source.collect_nodes",
        phase
    )

    return {
        adapter = adapter,
        root_node = opts.root_node,
        effect_index =
            effect_index,
        nodes = nodes,
    }
end


function M.new_replay_session(
    context,
    adapter,
    opts,
    deps
)
    opts = opts or {}
    deps = deps or {}

    if not opts.bufnr
        or not opts.root_node
        or not core.is_table(adapter)
        or not core.is_table(
            adapter.register_effects
        )
        or type(deps.parse_instruction)
            ~= "function"
    then
        return nil
    end

    local prepared_source =
        opts.prepared_source

    if not prepared_source_is_valid(
        prepared_source,
        adapter,
        opts
    )
    then
        prepared_source =
            M.prepare_source(
                adapter,
                opts
            )
    end

    if not prepared_source then
        return nil
    end

    local effect_index =
        prepared_source.effect_index

    local session_opts =
        copy_session_options(opts)

    local timeline_checkpoints =
        session_opts.capture_timeline == true
        and {}
        or nil

    local function capture_timeline_checkpoint(
        entry,
        latest_state_facts
    )
        if not timeline_checkpoints then
            return
        end

        timeline_checkpoints[
            #timeline_checkpoints + 1
        ] = {
            line = entry.line,
            column = entry.column,
            facts =
                register_infer
                    .to_fact_list(
                        latest_state_facts
                    ),
        }
    end

    -- Replay sessions share immutable source indexing when supplied, while
    -- retaining independent mutable reduction state.
    local nodes =
        prepared_source.nodes

    local processing_session =
        register_effect_processing
            .new_session({
                nodes = nodes,
                effect_index =
                    effect_index,

                parse_instruction =
                    deps.parse_instruction,

                normalize_mnemonic =
                    rule_syntax
                        .normalize_mnemonic,

                new_low_level_state =
                    inference.new_state,

                prepare_instruction_state =
                    function(
                        low_level_state,
                        facts_by_register,
                        instruction,
                        effect_specs
                    )
                        return M.prepare_instruction_state(
                            low_level_state,
                            facts_by_register,
                            instruction,
                            effect_specs,
                            adapter
                        )
                    end,

                apply_effect = function(
                    facts_by_register,
                    family_state,
                    latest_state_facts,
                    instruction,
                    effect_spec,
                    instruction_state
                )
                    return M.apply_effect(
                        facts_by_register,
                        family_state,
                        latest_state_facts,
                        adapter,
                        instruction,
                        effect_spec,
                        instruction_state,
                        {
                            apply_profile_prefix =
                                session_opts
                                    .profile_prefix
                                and (
                                    session_opts
                                        .profile_prefix
                                    .. ".apply"
                                )
                                or nil,
                            profile_begin =
                                session_opts
                                    .profile_begin,
                            profile_end =
                                session_opts
                                    .profile_end,
                        }
                    )
                end,

                to_fact_list =
                    register_infer
                        .to_fact_list,

                profile_prefix =
                    session_opts
                        .profile_prefix,
                profile_begin =
                    session_opts
                        .profile_begin,
                profile_end =
                    session_opts
                        .profile_end,
                profile_counter =
                    session_opts
                        .profile_counter,
                after_entry =
                    timeline_checkpoints
                    and capture_timeline_checkpoint
                    or nil,
            })

    if not processing_session then
        return nil
    end

    local last_position = nil

    local session = {
        processed_count = 0,
        query_count = 0,
        fallback_count = 0,
    }

    function session:collect_before(
        position
    )
        local normalized =
            inference.normalize_position(
                position
            )

        if not normalized then
            return {}
        end

        self.query_count =
            self.query_count + 1

        if last_position
            and inference
                .position_is_before(
                    normalized,
                    last_position
                )
        then
            self.fallback_count =
                self.fallback_count + 1

            local fallback_opts =
                copy_session_options(opts)

            fallback_opts
                .prepared_source =
                prepared_source

            fallback_opts
                .limit_position =
                normalized

            return M.collect(
                context,
                adapter,
                fallback_opts,
                deps
            )
        end

        local advanced =
            register_effect_processing
                .advance_while(
                    processing_session,
                    function(entry)
                        return inference
                            .position_is_before(
                                {
                                    line =
                                        entry.line,
                                    column =
                                        entry.column,
                                },
                                normalized
                            )
                    end
                )

        self.processed_count =
            self.processed_count
                + advanced

        last_position =
            normalized

        return register_effect_processing
            .snapshot(
                processing_session
            )
    end

    function session:collect_visible(
        visible_context,
        visible_opts
    )
        visible_opts =
            visible_opts or {}

        local target_opts =
            copy_session_options(opts)

        target_opts.limit_position = nil
        target_opts.stop_before = nil
        target_opts.before_position = nil

        if visible_opts.config ~= nil then
            target_opts.config =
                visible_opts.config
        end

        local visible_nodes =
            filter_prepared_nodes(
                prepared_source,
                visible_context,
                target_opts
            )

        local target_count =
            #visible_nodes

        if target_count
            < processing_session
                .processed_count
        then
            self.fallback_count =
                self.fallback_count + 1

            target_opts.prepared_source =
                prepared_source

            return M.collect(
                visible_context,
                adapter,
                target_opts,
                deps
            )
        end

        local advanced =
            register_effect_processing
                .advance_while(
                    processing_session,
                    function()
                        return processing_session
                            .processed_count
                            < target_count
                    end
                )

        self.processed_count =
            self.processed_count
                + advanced

        return register_effect_processing
            .snapshot(
                processing_session
            )
    end

    function session:collect_before_and_visible(
        position,
        visible_context,
        visible_opts
    )
        local before =
            self:collect_before(
                position
            )

        local visible =
            self:collect_visible(
                visible_context,
                visible_opts
            )

        return before, visible
    end

    function session:get_timeline()
        if not timeline_checkpoints then
            return nil
        end

        local timeline = {}

        function timeline:snapshot_before(
            position
        )
            local normalized =
                inference.normalize_position(
                    position
                )

            if not normalized then
                return nil
            end

            -- A checkpoint timeline may answer only when the reducer has
            -- already processed every source entry strictly before the query.
            local next_entry =
                nodes[
                    processing_session
                        .processed_count
                    + 1
                ]

            if next_entry
                and inference
                    .position_is_before(
                        {
                            line =
                                next_entry.line,
                            column =
                                next_entry.column,
                        },
                        normalized
                    )
            then
                return nil
            end

            local selected = {}

            for index =
                #timeline_checkpoints,
                1,
                -1
            do
                local checkpoint =
                    timeline_checkpoints[index]

                if inference
                    .position_is_before(
                        {
                            line =
                                checkpoint.line,
                            column =
                                checkpoint.column,
                        },
                        normalized
                    )
                then
                    selected =
                        checkpoint.facts
                    break
                end
            end

            return copy_fact_list(
                selected
            )
        end

        function timeline:snapshot_visible(
            visible_context,
            visible_opts
        )
            visible_opts =
                visible_opts or {}

            local target_opts =
                copy_session_options(opts)

            target_opts.limit_position = nil
            target_opts.stop_before = nil
            target_opts.before_position = nil

            if visible_opts.config ~= nil then
                target_opts.config =
                    visible_opts.config
            end

            local visible_nodes =
                filter_prepared_nodes(
                    prepared_source,
                    visible_context,
                    target_opts
                )

            local target_count =
                #visible_nodes

            if target_count
                > processing_session
                    .processed_count
            then
                return nil
            end

            if target_count == 0 then
                return {}
            end

            local checkpoint =
                timeline_checkpoints[
                    target_count
                ]

            if not checkpoint then
                return nil
            end

            return copy_fact_list(
                checkpoint.facts
            )
        end

        function timeline:stats()
            return {
                captured_count =
                    #timeline_checkpoints,
                processed_count =
                    processing_session
                        .processed_count,
                source_node_count =
                    #nodes,
            }
        end

        return timeline
    end

    function session:stats()
        return {
            processed_count =
                self.processed_count,
            query_count =
                self.query_count,
            fallback_count =
                self.fallback_count,
            source_node_count =
                #nodes,
        }
    end

    return session
end


function M.collect(
    context,
    adapter,
    opts,
    deps
)
    opts = opts or {}
    deps = deps or {}

    if not opts.bufnr
        or not opts.root_node
        or not core.is_table(adapter)
        or not core.is_table(
            adapter.register_effects
        )
        or type(deps.parse_instruction)
            ~= "function"
    then
        return {}
    end

    local prepared_source =
        opts.prepared_source

    local effect_index = nil
    local nodes = nil

    local phase =
        profile_begin(
            opts,
            "source_select"
        )

    if prepared_source_is_valid(
        prepared_source,
        adapter,
        opts
    )
    then
        effect_index =
            prepared_source.effect_index

        nodes =
            filter_prepared_nodes(
                prepared_source,
                context,
                opts
            )
    else
        effect_index =
            M.get_index(adapter)

        nodes =
            collect_nodes(
                context,
                opts,
                effect_index
            )
    end

    profile_end(
        opts,
        "source_select",
        phase
    )

    phase =
        profile_begin(
            opts,
            "process"
        )

    local result =
        register_effect_processing.process({
        nodes = nodes,
        effect_index = effect_index,

        parse_instruction = function(
            node,
            representative_effect_spec
        )
            return deps.parse_instruction(
                node,
                representative_effect_spec
            )
        end,

        normalize_mnemonic =
            rule_syntax.normalize_mnemonic,

        new_low_level_state =
            inference.new_state,

        prepare_instruction_state = function(
            low_level_state,
            facts_by_register,
            instruction,
            effect_specs
        )
            return M.prepare_instruction_state(
                low_level_state,
                facts_by_register,
                instruction,
                effect_specs,
                adapter
            )
        end,

        apply_effect = function(
            facts_by_register,
            family_state,
            latest_state_facts,
            instruction,
            effect_spec,
            instruction_state
        )
            return M.apply_effect(
                facts_by_register,
                family_state,
                latest_state_facts,
                adapter,
                instruction,
                effect_spec,
                instruction_state,
                opts
            )
        end,

        to_fact_list =
            register_infer.to_fact_list,

        profile_prefix =
            profile_name(
                opts,
                "process"
            ),
        profile_begin =
            opts.profile_begin,
        profile_end =
            opts.profile_end,
        profile_counter =
            opts.profile_counter,
    })

    profile_end(
        opts,
        "process",
        phase
    )

    return result
end


return M
