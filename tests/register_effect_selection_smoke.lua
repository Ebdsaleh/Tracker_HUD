-- tests/register_effect_selection_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_effect_selection_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local selection =
    require("tracker_hud.low_level.register_effect_selection")

local good = {
    id = "good",
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
}

local wrong_kind = {
    id = "wrong-kind",
    operands = {
        {
            index = 1,
            kind = "register",
        },
        {
            index = 2,
            kind = "register",
        },
    },
}

local wrong_condition = {
    id = "wrong-condition",
    operands = good.operands,
    condition = {
        operands_equal = {
            1,
            2,
        },
    },
}

local index = {
    by_node_type = {
        instruction = {
            __first = good,
            mov = {
                good,
                wrong_kind,
                wrong_condition,
            },
        },
    },
}

local node = {
    type = function()
        return "instruction"
    end,
}

local instruction = {
    mnemonic = "MOV",
    operands = {
        {
            kind = "register",
            text = "rax",
        },
        {
            kind = "integer",
            text = "42",
        },
    },
}

local opts = {
    normalize_mnemonic = function(value)
        return type(value) == "string"
            and value:lower()
            or nil
    end,
}

local matching =
    selection.match_instruction(
        index,
        node,
        instruction,
        opts
    )

assert(
    #matching == 1
        and matching[1] == good,
    "operand/condition candidate filtering changed"
)
print("PASS register effect selection: candidate filtering preserved")

local parsed_representative = nil

local parsed,
    parsed_matching =
    selection.match_node(
        index,
        node,
        {
            normalize_mnemonic =
                opts.normalize_mnemonic,

            parse_instruction = function(
                seen_node,
                representative
            )
                assert(
                    seen_node == node,
                    "selection parser received wrong node"
                )

                parsed_representative =
                    representative

                return instruction
            end,
        }
    )

assert(
    parsed == instruction
        and parsed_representative
            == good
        and #parsed_matching == 1
        and parsed_matching[1] == good,
    "node parse/selection dispatch changed"
)
print("PASS register effect selection: representative parse dispatch preserved")

local none =
    selection.match_instruction(
        index,
        {
            type = function()
                return "other"
            end,
        },
        instruction,
        opts
    )

assert(
    #none == 0,
    "unknown node type must produce no matches"
)

local invalid_instruction,
    invalid_matches =
    selection.match_node(
        index,
        node,
        {}
    )

assert(
    invalid_instruction == nil
        and #invalid_matches == 0,
    "missing selection dependencies must fail closed"
)
print("PASS register effect selection: invalid inputs fail closed")

print("PASS Tracker_HUD register-effect selection smoke")
