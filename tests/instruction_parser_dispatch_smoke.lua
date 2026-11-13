-- tests/instruction_parser_dispatch_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/instruction_parser_dispatch_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local dispatch =
    require("tracker_hud.low_level.instruction_parser_dispatch")

assert(
    dispatch.parse(
        nil,
        1,
        {},
        {}
    ) == nil
        and dispatch.parse(
            {},
            1,
            {},
            {}
        ) == nil,
    "missing parser configuration must fail closed"
)
print("PASS instruction parser dispatch: missing configuration fails closed")

local default_module =
    "tracker_hud.tests.dispatch_default"

package.loaded[default_module] = nil

local seen = nil

package.preload[default_module] =
    function()
        return {
            parse_instruction = function(
                bufnr,
                node,
                effect_spec,
                adapter
            )
                seen = {
                    bufnr = bufnr,
                    node = node,
                    effect_spec =
                        effect_spec,
                    adapter = adapter,
                }

                return {
                    mnemonic = "mov",
                }
            end,
        }
    end

local adapter = {
    instruction_parser = {
        module = default_module,
    },
}

local node = {
    id = "node",
}

local effect_spec = {
    id = "effect",
}

local parsed =
    dispatch.parse(
        adapter,
        17,
        node,
        effect_spec
    )

assert(
    parsed
        and parsed.mnemonic == "mov"
        and seen
        and seen.bufnr == 17
        and seen.node == node
        and seen.effect_spec
            == effect_spec
        and seen.adapter
            == adapter,
    "default parser dispatch arguments changed"
)
print("PASS instruction parser dispatch: default function and arguments preserved")

local custom_module =
    "tracker_hud.tests.dispatch_custom"

package.loaded[custom_module] = nil

package.preload[custom_module] =
    function()
        return {
            custom_parse = function()
                return {
                    mnemonic = "lea",
                }
            end,
        }
    end

local custom =
    dispatch.parse(
        {
            instruction_parser = {
                module =
                    custom_module,
                function_name =
                    "custom_parse",
            },
        },
        1,
        {},
        {}
    )

assert(
    custom
        and custom.mnemonic == "lea",
    "custom parser function selection changed"
)
print("PASS instruction parser dispatch: custom function name preserved")

assert(
    dispatch.parse(
        {
            instruction_parser = {
                module =
                    "tracker_hud.tests.dispatch_missing_module",
            },
        },
        1,
        {},
        {}
    ) == nil,
    "missing parser module must fail closed"
)

local missing_function_module =
    "tracker_hud.tests.dispatch_missing_function"

package.loaded[
    missing_function_module
] = nil

package.preload[
    missing_function_module
] = function()
    return {}
end

assert(
    dispatch.parse(
        {
            instruction_parser = {
                module =
                    missing_function_module,
            },
        },
        1,
        {},
        {}
    ) == nil,
    "missing parser function must fail closed"
)
print("PASS instruction parser dispatch: load and function failures fail closed")

package.loaded[default_module] = nil
package.preload[default_module] = nil
package.loaded[custom_module] = nil
package.preload[custom_module] = nil
package.loaded[
    missing_function_module
] = nil
package.preload[
    missing_function_module
] = nil

print("PASS Tracker_HUD instruction-parser dispatch smoke")
