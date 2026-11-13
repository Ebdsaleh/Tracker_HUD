-- tests/register_effect_collection_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_effect_collection_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local collection =
    require("tracker_hud.low_level.register_effect_collection")

local function fake_node(
    id,
    node_type,
    start_row,
    start_column,
    end_row,
    end_column
)
    return {
        id = id,
        type = function()
            return node_type
        end,
        range = function()
            return start_row,
                start_column,
                end_row,
                end_column
        end,
    }
end

local before = fake_node(
    "before",
    "instruction",
    0,
    8,
    0,
    12
)

local same_allowed = fake_node(
    "same-allowed",
    "instruction",
    1,
    4,
    1,
    9
)

local same_hidden = fake_node(
    "same-hidden",
    "instruction",
    1,
    20,
    1,
    24
)

local after = fake_node(
    "after",
    "instruction",
    2,
    0,
    2,
    4
)

local duplicate = fake_node(
    "duplicate",
    "instruction",
    0,
    8,
    0,
    12
)

local other_type = fake_node(
    "other",
    "special_instruction",
    0,
    2,
    0,
    6
)

local classify_inputs = {}

local function classify_position(
    start_column,
    end_column,
    source_column
)
    table.insert(
        classify_inputs,
        {
            start_column,
            end_column,
            source_column,
        }
    )

    if source_column < start_column then
        return "before_instruction"
    end

    if source_column >= end_column then
        return "after_instruction"
    end

    return "inside_instruction"
end

local function allows_position(
    config,
    position
)
    if position == "inside_instruction" then
        return true
    end

    if position == "before_instruction" then
        return config
            and config.allow_before
            == true
    end

    if position == "after_instruction" then
        return config
            and config.allow_after
            == true
    end

    return false
end

local function normalize_position(position)
    if type(position) ~= "table"
        or type(position.line) ~= "number"
        or type(position.column) ~= "number"
    then
        return nil
    end

    return {
        line = position.line,
        column = position.column,
    }
end

local function position_is_before(
    left,
    right
)
    if left.line ~= right.line then
        return left.line < right.line
    end

    return left.column < right.column
end

local by_type = {
    instruction = {
        after,
        same_hidden,
        duplicate,
        before,
        same_allowed,
    },
    special_instruction = {
        other_type,
    },
}

local requested_types = {}

local nodes = collection.collect({
    context = {
        cursor = {
            line = 2,
            column = 7,
        },
    },
    config = {
        allow_before = true,
        allow_after = false,
    },
    node_types = {
        instruction = true,
        special_instruction = true,
    },

    collect_nodes = function(node_type)
        requested_types[node_type] = true
        return by_type[node_type] or {}
    end,

    normalize_position = normalize_position,
    position_is_before = position_is_before,
    classify_position = classify_position,
    allows_position = allows_position,
})

assert(requested_types.instruction == true
    and requested_types.special_instruction == true,
    "all indexed node types must be requested")
print("PASS register effect collection: indexed node types traversed")

assert(#nodes == 3
    and nodes[1].node == other_type
    and nodes[1].line == 1
    and nodes[1].column == 2
    and nodes[2].node == duplicate
    and nodes[2].line == 1
    and nodes[2].column == 8
    and nodes[3].node == same_allowed
    and nodes[3].line == 2
    and nodes[3].column == 4,
    "visibility, deduplication or source ordering changed")
print("PASS register effect collection: visibility dedup and ordering preserved")

assert(#classify_inputs == 2
    and classify_inputs[1][3] == 6
    and classify_inputs[2][3] == 6,
    "cursor column must remain converted from one-based to zero-based")
print("PASS register effect collection: cursor column conversion preserved")

local limit_nodes = collection.collect({
    context = {
        cursor = {
            line = 1,
            column = 1,
        },
    },
    config = {
        allow_before = false,
        allow_after = false,
    },
    node_types = {
        instruction = true,
    },
    limit_position = {
        line = 3,
        column = 0,
    },

    collect_nodes = function()
        return {
            after,
            same_hidden,
            before,
        }
    end,
    normalize_position = normalize_position,
    position_is_before = position_is_before,
    classify_position = function()
        error("limit position must bypass cursor classification")
    end,
    allows_position = function()
        error("limit position must bypass line-summary visibility")
    end,
})

assert(#limit_nodes == 2
    and limit_nodes[1].node == before
    and limit_nodes[2].node == same_hidden,
    "explicit limit position must override cursor visibility")
print("PASS register effect collection: explicit limit position preserved")

local alias_limit_nodes = collection.collect({
    node_types = {
        instruction = true,
    },
    stop_before = {
        line = 2,
        column = 20,
    },
    collect_nodes = function()
        return {
            same_hidden,
            before,
        }
    end,
    normalize_position = normalize_position,
    position_is_before = position_is_before,
    classify_position = classify_position,
    allows_position = allows_position,
})

assert(#alias_limit_nodes == 1
    and alias_limit_nodes[1].node == before,
    "stop_before alias must preserve limit semantics")
print("PASS register effect collection: stop-before alias preserved")

assert(#collection.collect({
        node_types = {},
    }) == 0
    and #collection.collect({
        node_types = {},
        collect_nodes = function()
            return {}
        end,
    }) == 0,
    "incomplete dependencies must fail closed")
print("PASS register effect collection: incomplete dependencies fail closed")

print("PASS Tracker_HUD register-effect collection smoke")
