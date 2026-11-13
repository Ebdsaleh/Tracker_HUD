-- tests/line_summary_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/line_summary_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local line_summary =
    require("tracker_hud.low_level.line_summary")

local defaults = line_summary.resolve_options(nil)

assert(defaults.enabled == true
    and defaults.show_before_instruction == false
    and defaults.show_after_instruction == true,
    "default line-summary options changed")
print("PASS line summary: default options preserved")

local disabled = line_summary.resolve_options({
    line_summary = {
        enabled = false,
        show_before_instruction = true,
        show_after_instruction = true,
    },
})

assert(disabled.enabled == false
    and disabled.show_before_instruction == false
    and disabled.show_after_instruction == false,
    "disabled line-summary options changed")
print("PASS line summary: disabled options suppress before/after")

local explicit = line_summary.resolve_options({
    line_summary = {
        enabled = true,
        show_before_instruction = true,
        show_after_instruction = false,
    },
})

assert(explicit.enabled == true
    and explicit.show_before_instruction == true
    and explicit.show_after_instruction == false,
    "explicit line-summary options changed")
print("PASS line summary: explicit options preserved")

assert(line_summary.classify_instruction_position(
        4,
        12,
        3
    ) == "before_instruction"
    and line_summary.classify_instruction_position(
        4,
        12,
        4
    ) == "inside_instruction"
    and line_summary.classify_instruction_position(
        4,
        12,
        11
    ) == "inside_instruction"
    and line_summary.classify_instruction_position(
        4,
        12,
        12
    ) == "after_instruction"
    and line_summary.classify_instruction_position(
        nil,
        12,
        4
    ) == nil,
    "instruction position boundaries changed")
print("PASS line summary: instruction position boundaries preserved")

assert(line_summary.allows_position(
        nil,
        "inside_instruction"
    ) == true
    and line_summary.allows_position(
        nil,
        "before_instruction"
    ) == false
    and line_summary.allows_position(
        nil,
        "after_instruction"
    ) == true
    and line_summary.allows_position(
        {
            line_summary = {
                show_before_instruction = true,
                show_after_instruction = false,
            },
        },
        "before_instruction"
    ) == true
    and line_summary.allows_position(
        {
            line_summary = {
                show_before_instruction = true,
                show_after_instruction = false,
            },
        },
        "after_instruction"
    ) == false
    and line_summary.allows_position(
        {
            line_summary = {
                enabled = false,
            },
        },
        "inside_instruction"
    ) == true,
    "line-summary visibility policy changed")
print("PASS line summary: visibility policy preserved")

local compiled_line = {
    occurrences = {
        {
            start_column = 20,
            end_column = 24,
            metadata = {
                instruction_start_column = 8,
                instruction_end_column = 18,
            },
        },
        {
            start_column = 30,
            end_column = 35,
        },
        {
            start_column = 5,
            end_column = 7,
            metadata = {
                instruction_start_column = 10,
                instruction_end_column = 16,
            },
        },
        {
            start_column = "not-a-number",
            end_column = 99,
        },
    },
}

local start_column,
    end_column =
    line_summary.get_compiled_line_instruction_range(
        compiled_line
    )

assert(start_column == 8
    and end_column == 35,
    "compiled-line instruction range changed")
print("PASS line summary: compiled-line range preserved")

assert(line_summary.classify_compiled_line_position(
        compiled_line,
        7
    ) == "before_instruction"
    and line_summary.classify_compiled_line_position(
        compiled_line,
        8
    ) == "inside_instruction"
    and line_summary.classify_compiled_line_position(
        compiled_line,
        34
    ) == "inside_instruction"
    and line_summary.classify_compiled_line_position(
        compiled_line,
        35
    ) == "after_instruction",
    "compiled-line position classification changed")
print("PASS line summary: compiled-line classification preserved")

assert(line_summary.allows_compiled_line_position(
        {
            line_summary = {
                show_before_instruction = true,
                show_after_instruction = false,
            },
        },
        compiled_line,
        7
    ) == true
    and line_summary.allows_compiled_line_position(
        {
            line_summary = {
                show_before_instruction = true,
                show_after_instruction = false,
            },
        },
        compiled_line,
        35
    ) == false,
    "compiled-line visibility policy changed")
print("PASS line summary: compiled-line visibility preserved")

local no_start,
    no_end =
    line_summary.get_compiled_line_instruction_range(
        {}
    )

assert(no_start == nil
    and no_end == nil
    and line_summary.classify_compiled_line_position(
        {},
        1
    ) == nil
    and line_summary.allows_compiled_line_position(
        nil,
        {},
        1
    ) == false,
    "invalid compiled-line inputs must fail closed")
print("PASS line summary: invalid inputs fail closed")

print("PASS Tracker_HUD line-summary smoke")
