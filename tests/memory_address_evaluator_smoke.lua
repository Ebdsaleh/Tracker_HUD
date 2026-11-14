-- tests/memory_address_evaluator_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/memory_address_evaluator_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local evaluator =
    require("tracker_hud.low_level.memory_address_evaluator")

local adapter = {
    metadata = {
        bits = 64,
    },
}

local root_node = {}

local instruction = {
    source_line = 9,
    source_column = 7,
    source_start_line = 8,
    source_start_column = 3,
}

local address = {
    base = {
        name = "rax",
    },
    displacement = {
        value = "8",
    },
    address_size_bits = 64,
    address_size_status = "known",
}

local captured = nil

local result =
    evaluator.evaluate(
        12,
        root_node,
        adapter,
        instruction,
        address,
        nil,
        nil,
        {
            collect_register_effects = function(
                context,
                seen_adapter,
                opts
            )
                captured = {
                    context = context,
                    adapter = seen_adapter,
                    opts = opts,
                }

                return {
                    {
                        name = "rax",
                        value = "4096",
                        resolved = true,
                        metadata = {
                            canonical_name =
                                "rax",
                        },
                    },
                }
            end,
        }
    )

assert(
    captured
        and captured.adapter == adapter
        and captured.context
        and captured.context.cursor
        and captured.context.cursor.line
            == 8
        and captured.context.cursor.column
            == 4
        and captured.opts
        and captured.opts.bufnr == 12
        and captured.opts.root_node
            == root_node
        and captured.opts.limit_position
        and captured.opts.limit_position.line
            == 8
        and captured.opts.limit_position.column
            == 3,
    "pre-instruction register replay position changed"
)
print("PASS memory address evaluator: pre-instruction replay limit preserved")

assert(
    result.status == "known"
        and result.value == "4104"
        and result.bits == 64
        and result.components
        and result.components.base
        and result.components.base.value
            == "4096"
        and result.components.displacement
            == "8",
    "register-based effective address changed"
)
print("PASS memory address evaluator: register arithmetic preserved")

local partial =
    evaluator.evaluate(
        12,
        root_node,
        adapter,
        instruction,
        address,
        nil,
        nil,
        {
            collect_register_effects = function()
                return {
                    {
                        name = "rax",
                        resolved = false,
                        metadata = {
                            partial_value =
                                "known-low-bits",
                        },
                    },
                }
            end,
        }
    )

assert(
    partial.status == "unknown"
        and partial.reason
            == "base register unresolved"
        and partial.details
        and partial.details.metadata
        and partial.details.metadata.status
            == "partial",
    "partial register certainty must fail closed"
)
print("PASS memory address evaluator: partial register state fails closed")

local unavailable =
    evaluator.evaluate(
        12,
        root_node,
        adapter,
        instruction,
        address,
        nil,
        nil,
        {}
    )

assert(
    unavailable.status == "unknown"
        and unavailable.reason
            == "register collection unavailable",
    "missing register collector must fail closed"
)
print("PASS memory address evaluator: invalid dependencies fail closed")

print("PASS Tracker_HUD memory-address evaluator smoke")
