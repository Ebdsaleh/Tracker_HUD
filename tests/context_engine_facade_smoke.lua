-- tests/context_engine_facade_smoke.lua
-- Stable public-facade contract for the completed context-engine split.
--
-- nvim --headless -u NONE -c "luafile tests/context_engine_facade_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

package.loaded[
    "tracker_hud.context_engine"
] = nil

local engine =
    require("tracker_hud.context_engine")

local expected_exports = {
    "make_global_context",
    "make_unavailable_context",
    "get_first_line_text",
    "build_signature",
    "extract_name_from_signature",
    "extract_name_from_syntax",
    "build_construct",
    "get_cursor_position",
    "get_cursor_location",
    "resolve_line_summary_options",
    "classify_instruction_cursor_position",
    "line_summary_allows_position",
    "get_compiled_line_instruction_range",
    "classify_compiled_line_cursor_position",
    "line_summary_allows_compiled_line_position",
    "format_branch_display_label",
    "node_matches_branch_alternative",
    "get_node_alternatives",
    "get_branch_alternative_label",
    "build_branch_display_label",
    "position_in_node",
    "get_node_type",
    "get_first_node_line",
    "build_scope_entry_from_construct",
    "build_context_from_scopes",
    "get_node_range",
    "match_node",
    "parse_node",
    "get_construct_spec",
    "validate_construct_spec",
    "collect_register_effects",
    "discover_memory_source_operands",
    "collect_memory_source_operands",
    "discover_register_source_occurrences",
    "collect_boundary_effects",
    "collect_instruction_events",
    "collect_stack_effects",
}

for _, name in ipairs(
    expected_exports
) do
    assert(
        type(engine[name]) == "function",
        "missing context-engine public function: "
            .. tostring(name)
    )
end

print(
    "PASS context engine facade: "
        .. "all 37 public callables preserved"
)

local options =
    engine.resolve_line_summary_options({})

assert(
    options.enabled == true
        and options
            .show_before_instruction
            == false
        and options
            .show_after_instruction
            == true,
    "line-summary facade defaults changed"
)

assert(
    engine.classify_instruction_cursor_position(
        4,
        10,
        3
    ) == "before_instruction"
        and engine
            .classify_instruction_cursor_position(
                4,
                10,
                7
            ) == "inside_instruction"
        and engine
            .classify_instruction_cursor_position(
                4,
                10,
                10
            ) == "after_instruction",
    "line-summary facade classification changed"
)

print(
    "PASS context engine facade: "
        .. "line-summary forwarding preserved"
)

local low_level_results = {
    engine.collect_register_effects(
        {},
        {},
        {}
    ),
    engine.discover_memory_source_operands(
        nil,
        nil,
        {},
        1,
        {}
    ),
    engine.collect_memory_source_operands(
        nil,
        nil,
        {},
        1,
        {}
    ),
    engine.discover_register_source_occurrences(
        nil,
        nil,
        {},
        1,
        {}
    ),
    engine.collect_boundary_effects(
        {},
        {},
        {}
    ),
    engine.collect_instruction_events(
        {},
        {},
        {}
    ),
    engine.collect_stack_effects(
        {},
        {},
        {}
    ),
}

for index, result in ipairs(
    low_level_results
) do
    assert(
        type(result) == "table"
            and #result == 0,
        "low-level facade fail-closed contract changed at entry "
            .. tostring(index)
    )
end

print(
    "PASS context engine facade: "
        .. "all low-level entry points fail closed"
)

assert(
    type(engine.match_node)
            == "function"
        and type(engine.parse_node)
            == "function"
        and type(engine.validate_construct_spec)
            == "function",
    "construct facade forwarding changed"
)

print(
    "PASS context engine facade: "
        .. "construct forwarding preserved"
)

print(
    "PASS Tracker_HUD context-engine facade smoke"
)
