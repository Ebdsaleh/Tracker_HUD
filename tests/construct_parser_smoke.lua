-- tests/construct_parser_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/construct_parser_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local parser =
    require("tracker_hud.constructs.parser")

local original_get_node_text =
    vim.treesitter.get_node_text

local name_node = {
    id = "name",
}

local node = {
    id = "function",

    type = function()
        return "function_definition"
    end,

    range = function()
        return 0, 0, 2, 3
    end,

    field = function(_, field_name)
        if field_name == "name" then
            return {
                name_node,
            }
        end

        return {}
    end,
}

vim.treesitter.get_node_text =
    function(candidate, _bufnr)
        if candidate == node then
            return "local function alpha()\n  return 1\nend"
        end

        if candidate == name_node then
            return "alpha"
        end

        return nil
    end

local adapter = {
    name = "lua",

    construct_specs = {
        function_definition = {
            syntax = {
                node_type =
                    "function_definition",
                fields = {
                    name = "name",
                },
            },

            signature = {
                strategy =
                    "first_line",
                local_name_pattern =
                    "^local%s+function%s+([%w_]+)",
                name_pattern =
                    "^function%s+([%w_]+)",
            },

            construct = {
                kind = "function",
                language_term =
                    "function",
                label = "Function",
            },

            scope = {
                kind = "lexical",
                affects_visibility =
                    true,
                owns_members = true,
            },

            member = {
                kind = "function",
                owner_scope =
                    "parent_lexical",
            },

            value = {
                kind = "function",
            },
        },
    },
}

assert(
    parser.match_node(
        adapter,
        node
    ),
    "known construct node no longer matches"
)

assert(
    not parser.match_node(
        adapter,
        {
            type = function()
                return "unknown"
            end,
        }
    ),
    "unknown construct node unexpectedly matched"
)
print("PASS construct parser: node matching preserved")

local construct, err =
    parser.parse_node(
        adapter,
        node,
        1
    )

assert(
    construct
        and err == nil,
    "valid construct parse failed: "
        .. tostring(err)
)

assert(
    construct.node_type
        == "function_definition"
        and construct.name == "alpha"
        and construct.signature
            == "local function alpha()"
        and construct.range.start_line
            == 1
        and construct.range.end_line
            == 3,
    "construct source identity/range assembly changed"
)
print("PASS construct parser: source identity and range preserved")

assert(
    construct.construct.kind
        == "function"
        and construct.construct.label
            == "Function"
        and construct.scope.kind
            == "lexical"
        and construct.member.kind
            == "function"
        and construct.value.kind
            == "function"
        and construct.metadata.adapter
            == "lua",
    "construct semantic payload assembly changed"
)
print("PASS construct parser: canonical payload assembly preserved")

local no_adapter, no_adapter_error =
    parser.parse_node(
        nil,
        node,
        1
    )

assert(
    no_adapter == nil
        and no_adapter_error
            == "adapter must be a table",
    "invalid adapter error changed"
)

local no_specs, no_specs_error =
    parser.parse_node(
        {},
        node,
        1
    )

assert(
    no_specs == nil
        and no_specs_error
            == "adapter.construct_specs must be a table",
    "missing construct_specs error changed"
)

local missing, missing_error =
    parser.parse_node(
        adapter,
        {
            type = function()
                return "class_definition"
            end,
            range = function()
                return 0, 0, 0, 1
            end,
        },
        1
    )

assert(
    missing == nil
        and missing_error == nil,
    "missing construct-spec parse behavior changed"
)
print("PASS construct parser: invalid and missing inputs preserve contract")

vim.treesitter.get_node_text =
    original_get_node_text

print("PASS Tracker_HUD construct-parser smoke")
