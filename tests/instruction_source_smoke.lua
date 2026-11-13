-- tests/instruction_source_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/instruction_source_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local instruction_source =
    require("tracker_hud.low_level.instruction_source")

local function fake_node(
    id,
    node_type,
    start_row,
    start_column,
    end_row,
    end_column,
    children
)
    local node = {
        id = id,
        _type = node_type,
        _children = children or {},
        _parent = nil,
    }

    for _, child in ipairs(node._children) do
        child._parent = node
    end

    function node:type()
        return self._type
    end

    function node:range()
        return start_row,
            start_column,
            end_row,
            end_column
    end

    function node:start()
        return start_row,
            start_column
    end

    function node:parent()
        return self._parent
    end

    function node:iter_children()
        local index = 0

        return function()
            index = index + 1
            return self._children[index]
        end
    end

    return node
end

local mnemonic = fake_node(
    "mnemonic",
    "word",
    0,
    0,
    0,
    3
)

local register = fake_node(
    "register",
    "reg",
    0,
    4,
    0,
    7
)

local integer = fake_node(
    "integer",
    "int",
    0,
    9,
    0,
    11
)

local instruction = fake_node(
    "instruction",
    "instruction",
    0,
    0,
    0,
    11,
    {
        mnemonic,
        register,
        integer,
    }
)

local text_by_id = {
    mnemonic = " MOV ",
    register = " RAX ",
    integer = " 42 ",
}

local opts = {
    get_node_text = function(node)
        return text_by_id[node.id]
    end,
}

local parsed =
    instruction_source.collect_instruction(
        {},
        instruction,
        1,
        {
            node_type = "instruction",
        },
        opts
    )

assert(
    parsed
        and parsed.mnemonic == "mov"
        and parsed.source_line == 1
        and #parsed.operands == 2,
    "fallback instruction reconstruction changed"
)
print("PASS instruction source: fallback mnemonic and operands preserved")

assert(
    parsed.operands[1].text == "RAX"
        and parsed.operands[1].kind
            == "register"
        and parsed.operands[1]
            .source_column == 4
        and parsed.operands[2].text
            == "42"
        and parsed.operands[2].kind
            == "integer"
        and parsed.operands[2]
            .source_end_column == 11,
    "fallback operand kinds or source ranges changed"
)
print("PASS instruction source: operand kinds and ranges preserved")

local nested_ident = fake_node(
    "nested-ident",
    "ident",
    1,
    5,
    1,
    8
)

local reg_parent = fake_node(
    "reg-parent",
    "reg",
    1,
    4,
    1,
    8,
    {
        nested_ident,
    }
)

assert(
    instruction_source.infer_operand_kind(
        nested_ident,
        {
            node_type = "instruction",
        }
    ) == "register",
    "register ancestor inference changed"
)

local reg_child = fake_node(
    "reg-child",
    "reg",
    2,
    5,
    2,
    8
)

local wrapper = fake_node(
    "wrapper",
    "operand",
    2,
    4,
    2,
    8,
    {
        reg_child,
    }
)

assert(
    instruction_source.infer_operand_kind(
        wrapper,
        {
            node_type = "instruction",
        }
    ) == "register",
    "register descendant inference changed"
)
print("PASS instruction source: ancestor and descendant register inference preserved")

local adapter_result = {
    mnemonic = "adapter",
    operands = {},
}

local adapter_calls = 0

local preferred =
    instruction_source.collect_instruction(
        {},
        instruction,
        1,
        {
            node_type = "instruction",
        },
        {
            parse_with_adapter = function()
                adapter_calls =
                    adapter_calls + 1
                return adapter_result
            end,
            get_node_text = function()
                error(
                    "fallback text must not run when adapter parser succeeds"
                )
            end,
        }
    )

assert(
    preferred == adapter_result
        and adapter_calls == 1,
    "adapter parser must retain first refusal"
)
print("PASS instruction source: adapter parser precedence preserved")

local nested_instruction = fake_node(
    "nested-instruction",
    "instruction",
    3,
    0,
    3,
    4
)

local root = fake_node(
    "root",
    "program",
    0,
    0,
    4,
    0,
    {
        instruction,
        fake_node(
            "container",
            "section",
            3,
            0,
            4,
            0,
            {
                nested_instruction,
            }
        ),
    }
)

local collected =
    instruction_source.collect_nodes_by_type(
        root,
        "instruction"
    )

assert(
    #collected == 2
        and collected[1] == instruction
        and collected[2]
            == nested_instruction,
    "recursive node collection changed"
)
print("PASS instruction source: recursive node collection preserved")

assert(
    instruction_source.normalize_text(
        "   "
    ) == nil
        and #instruction_source
            .collect_nodes_by_type(
                nil,
                "instruction"
            ) == 0
        and instruction_source
            .collect_instruction(
                {},
                nil,
                1,
                {
                    node_type =
                        "instruction",
                },
                {}
            ) == nil,
    "invalid input behavior changed"
)
print("PASS instruction source: invalid inputs preserve contract")

print("PASS Tracker_HUD instruction-source smoke")
