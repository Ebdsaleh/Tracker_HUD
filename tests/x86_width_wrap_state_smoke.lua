-- tests/x86_width_wrap_state_smoke.lua
-- Parser-backed x86-64 target-width arithmetic wrapping regression.
-- Requires ERIDU's configured ASM Tree-sitter parser.
-- nvim --headless -c "luafile tests/x86_width_wrap_state_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua").use_working_tree()

    local source = {
        "bits 64",
        "mov rax, 0xFFFFFFFFFFFFFFFF",
        "inc rax",
        "dec rax",
        "add rax, 1",
        "sub rax, 1",
        "mov eax, 0xFFFFFFFF",
        "inc eax",
        "mov ax, 0xFFFF",
        "inc ax",
        "mov al, 0xFF",
        "inc al",
        "sub al, 1",
    }

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = "asm"

    local ok, parser = pcall(vim.treesitter.get_parser, buffer, "asm")
    assert(ok and parser, "ASM Tree-sitter parser unavailable: " .. tostring(parser))
    local trees = parser:parse()
    assert(trees and trees[1], "ASM parser produced no tree")
    local root = trees[1]:root()

    local adapter = require("tracker_hud.adapters.asm.init")
    local registry = require("tracker_hud.adapters.registry")
    local registered, register_err = registry.register(adapter)
    assert(registered, "cannot register ASM adapter: " .. tostring(register_err))

    local configured, config_err =
        registry.configure_adapter_for_buffer("asm", buffer, {})
    assert(configured, "cannot configure ASM adapter: " .. tostring(config_err))

    local engine = require("tracker_hud.context_engine")

    local function state_after(line_number, canonical_name)
        local facts = engine.collect_register_effects(
            { cursor = { line = line_number, column = 200 } },
            adapter,
            {
                bufnr = buffer,
                root_node = root,
                limit_position = {
                    line = line_number + 1,
                    column = 0,
                },
            }
        )

        local found

        for _, fact in ipairs(facts or {}) do
            local canonical = fact.metadata and fact.metadata.canonical_name

            if canonical == canonical_name or fact.name == canonical_name then
                assert(not found,
                    "canonical register family must reduce to one latest state fact")
                found = fact
            end
        end

        return assert(found,
            "missing " .. canonical_name .. " state after line "
                .. tostring(line_number))
    end

    local seed = state_after(2, "rax")
    assert(seed.value == "18446744073709551615"
        and seed.metadata.value_width_policy == nil,
        "MOV must retain exact UINT64_MAX without inheriting arithmetic wrapping")
    print("PASS x86 width policy: MOV remains outside arithmetic policy")

    local inc64 = state_after(3, "rax")
    assert(inc64.value == "0"
        and inc64.metadata.write_value == "0"
        and inc64.metadata.pre_width_write_value == "18446744073709551616"
        and inc64.metadata.value_width_policy == "wrap_unsigned_target"
        and inc64.metadata.value_width_bits == 64
        and inc64.metadata.value_wrapped == true,
        "64-bit INC must wrap UINT64_MAX to zero")
    print("PASS x86 width policy: 64-bit INC wraps modulo 2^64")

    local dec64 = state_after(4, "rax")
    assert(dec64.value == "18446744073709551615"
        and dec64.metadata.pre_width_write_value == "-1"
        and dec64.metadata.value_width_bits == 64
        and dec64.metadata.value_wrapped == true,
        "64-bit DEC must wrap zero to UINT64_MAX")
    print("PASS x86 width policy: 64-bit DEC wraps negative result")

    local add64 = state_after(5, "rax")
    assert(add64.value == "0"
        and add64.metadata.value_width_bits == 64
        and add64.metadata.value_wrapped == true,
        "64-bit ADD immediate must wrap at target width")
    print("PASS x86 width policy: ADD immediate wraps at target width")

    local sub64 = state_after(6, "rax")
    assert(sub64.value == "18446744073709551615"
        and sub64.metadata.value_width_bits == 64
        and sub64.metadata.value_wrapped == true,
        "64-bit SUB immediate must wrap at target width")
    print("PASS x86 width policy: SUB immediate wraps at target width")

    local inc32 = state_after(8, "rax")
    assert(inc32.name == "eax"
        and inc32.value == "0x0000000000000000"
        and inc32.metadata.write_value == "0"
        and inc32.metadata.value_width_bits == 32
        and inc32.metadata.value_wrapped == true,
        "EAX INC must wrap at 32 bits and preserve x86-64 zero extension")
    print("PASS x86 width policy: EAX wraps at 32 bits then zero-extends")

    local inc16 = state_after(10, "rax")
    assert(inc16.name == "ax"
        and inc16.value == "0x0000000000000000"
        and inc16.metadata.write_value == "0"
        and inc16.metadata.value_width_bits == 16
        and inc16.metadata.value_wrapped == true,
        "AX INC must wrap only its 16-bit destination")
    print("PASS x86 width policy: AX wraps at 16 bits")

    local inc8 = state_after(12, "rax")
    assert(inc8.name == "al"
        and inc8.value == "0x0000000000000000"
        and inc8.metadata.write_value == "0"
        and inc8.metadata.value_width_bits == 8
        and inc8.metadata.value_wrapped == true,
        "AL INC must wrap only its 8-bit destination")
    print("PASS x86 width policy: AL wraps at 8 bits")

    local sub8 = state_after(13, "rax")
    assert(sub8.name == "al"
        and sub8.value == "0x00000000000000FF"
        and sub8.metadata.write_value == "255"
        and sub8.metadata.pre_width_write_value == "-1"
        and sub8.metadata.value_width_bits == 8
        and sub8.metadata.value_wrapped == true,
        "AL SUB must wrap negative result to 0xFF")
    print("PASS x86 width policy: 8-bit SUB underflow wraps to 0xFF")

    print("PASS Tracker_HUD x86 target-width arithmetic smoke")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL x86 target-width arithmetic smoke: "
        .. tostring(err) .. "\n")
    error(err)
end
