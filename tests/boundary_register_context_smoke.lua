-- tests/boundary_register_context_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/boundary_register_context_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local boundary_context =
    require("tracker_hud.low_level.boundary_register_context")

local context = {
    cursor = {
        line = 20,
        column = 4,
    },
}

local adapter = {
    name = "asm",
}

local root_node = {}

local captured = nil

local result =
    boundary_context.collect(
        context,
        adapter,
        {
            bufnr = 7,
            root_node = root_node,
        },
        {
            source_line = 12,
            source_column = 9,
            source_start_line = 10,
            source_start_column = 3,
        },
        {
            collect_register_effects = function(
                seen_context,
                seen_adapter,
                seen_opts
            )
                captured = {
                    context = seen_context,
                    adapter = seen_adapter,
                    opts = seen_opts,
                }

                return {
                    {
                        name = "rax",
                        value = "1",
                    },
                }
            end,
        }
    )

assert(
    captured
        and captured.context == context
        and captured.adapter == adapter
        and captured.opts
        and captured.opts.bufnr == 7
        and captured.opts.root_node
            == root_node
        and captured.opts.limit_position
        and captured.opts.limit_position.line
            == 10
        and captured.opts.limit_position.column
            == 3,
    "pre-boundary register collection position changed"
)
print("PASS boundary register context: pre-instruction limit preserved")

assert(
    result ~= context
        and result.cursor == context.cursor
        and result.registers
        and #result.registers == 1
        and result.registers[1].name
            == "rax"
        and context.registers == nil,
    "boundary register section construction changed"
)
print("PASS boundary register context: register section publication preserved")

local fallback =
    boundary_context.collect(
        context,
        adapter,
        {},
        {
            source_line = 2,
        },
        {}
    )

assert(
    fallback == context,
    "missing register collector must fail closed"
)

local missing_position =
    boundary_context.collect(
        context,
        adapter,
        {},
        {},
        {
            collect_register_effects = function()
                error("must not collect without instruction position")
            end,
        }
    )

assert(
    missing_position == context,
    "missing instruction position must preserve context"
)
print("PASS boundary register context: invalid dependencies fail closed")

print("PASS Tracker_HUD boundary-register context smoke")
