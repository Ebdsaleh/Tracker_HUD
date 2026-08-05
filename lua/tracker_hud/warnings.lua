-- lua/tracker_hud/warnings.lua
--
-- Warning collection for Tracker HUD.
--
-- Warnings are derived from already-collected context facts.
-- This module should not parse source directly and should not hard-code
-- architecture-specific parsing behavior.
--
-- Adapters describe warning rules.
-- This module interprets those rules generically.

local core = require("tracker_hud.core")

local M = {}


local function make_warning(message, opts)
    opts = opts or {}

    return {
        message = message,
        kind = opts.kind or "warning",
        severity = opts.severity or "warning",
        category = opts.category or "state",
        source = opts.source or "analysis",

        source_line = opts.source_line,
        source_column = opts.source_column,

        source_start_line = opts.source_start_line,
        source_start_column = opts.source_start_column,
        source_end_line = opts.source_end_line,
        source_end_column = opts.source_end_column,

        metadata = opts.metadata or {},
    }
end


local function fact_matches(fact, match_spec)
    if not core.is_table(match_spec) then
        return true
    end

    if not core.is_table(fact) then
        return false
    end

    for key, expected in pairs(match_spec) do
        if fact[key] ~= expected then
            return false
        end
    end

    return true
end


local function get_context_source(context, source_name)
    if not core.is_table(context) or not core.is_non_empty_string(source_name) then
        return {}
    end

    local source = context[source_name]

    if core.is_table(source) then
        return source
    end

    return {}
end


local function read_matches(read, read_spec)
    if not core.is_table(read_spec) then
        return true
    end

    if not core.is_table(read) then
        return false
    end

    for key, expected in pairs(read_spec) do
        if read[key] ~= expected then
            return false
        end
    end

    return true
end


local function find_first_read(reads, read_spec)
    if not core.is_table(reads) then
        return nil
    end

    for _, read in ipairs(reads) do
        if read_matches(read, read_spec) then
            return read
        end
    end

    return nil
end


local function collect_matching_reads(reads, read_spec)
    local matches = {}

    if not core.is_table(reads) then
        return matches
    end

    for _, read in ipairs(reads) do
        if read_matches(read, read_spec) then
            table.insert(matches, read)
        end
    end

    return matches
end


local function build_message_context(fact, read)
    local values = {}

    if core.is_table(fact) then
        for key, value in pairs(fact) do
            if type(value) ~= "table" then
                values[key] = value
            end
        end
    end

    if core.is_table(read) then
        for key, value in pairs(read) do
            if type(value) ~= "table" then
                values[key] = value
            end
        end
    end

    return values
end


local function interpolate_message(template, values)
    if not core.is_non_empty_string(template) then
        return "warning"
    end

    values = values or {}

    return (template:gsub("{([%w_]+)}", function(key)
        local value = values[key]

        if value == nil then
            return "<unknown>"
        end

        return tostring(value)
    end))
end


local function make_warning_from_rule(rule, fact, read)
    local values = build_message_context(fact, read)
    local message = interpolate_message(rule.message, values)

    return make_warning(message, {
        severity = rule.severity or "warning",
        category = rule.category or fact.category or "state",

        source_line = fact.source_line,
        source_column = fact.source_column,

        source_start_line = fact.source_start_line,
        source_start_column = fact.source_start_column,
        source_end_line = fact.source_end_line,
        source_end_column = fact.source_end_column,

        metadata = {
            rule_check = rule.check,
            rule_source = rule.source,

            boundary_kind = fact.kind,
            boundary_name = fact.name,

            argument_index = read and read.index,
            register = read and read.register,
            value = read and read.value,
        },
    })
end


local function apply_missing_read_value_rule(warnings, rule, fact)
    local read = find_first_read(fact.reads, rule.read)

    if not core.is_table(read) then
        return
    end

    if read.value ~= nil and read.resolved ~= false then
        return
    end

    table.insert(warnings, make_warning_from_rule(rule, fact, read))
end


local function apply_missing_read_values_rule(warnings, rule, fact)
    local reads = collect_matching_reads(fact.reads, rule.read)

    for _, read in ipairs(reads) do
        if core.is_table(read)
            and (read.value == nil or read.resolved == false)
        then
            table.insert(warnings, make_warning_from_rule(rule, fact, read))
        end
    end
end


local function apply_missing_known_effect_rule(warnings, rule, fact)
    if core.is_table(fact.known_effect) then
        return
    end

    local read = find_first_read(fact.reads, rule.value_read)

    if not core.is_table(read) then
        return
    end

    if read.value == nil or read.resolved == false then
        return
    end

    table.insert(warnings, make_warning_from_rule(rule, fact, read))
end


local function apply_warning_rule(warnings, context, rule)
    if not core.is_table(rule) or not core.is_non_empty_string(rule.source) then
        return
    end

    local facts = get_context_source(context, rule.source)

    for _, fact in ipairs(facts) do
        if fact_matches(fact, rule.match) then
            if rule.check == "missing_read_value" then
                apply_missing_read_value_rule(warnings, rule, fact)
            elseif rule.check == "missing_read_values" then
                apply_missing_read_values_rule(warnings, rule, fact)
            elseif rule.check == "missing_known_effect" then
                apply_missing_known_effect_rule(warnings, rule, fact)
            end
        end
    end
end


function M.collect(context, adapter, _opts)
    local warnings = {}

    if not core.is_table(context) or not core.is_table(adapter) then
        return warnings
    end

    for _, rule in ipairs(adapter.warning_rules or {}) do
        apply_warning_rule(warnings, context, rule)
    end

    return warnings
end


return M
