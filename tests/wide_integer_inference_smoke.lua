-- tests/wide_integer_inference_smoke.lua
-- Parser-backed exact x86-64 immediate and delta regression.
-- Requires ERIDU's configured ASM Tree-sitter parser.
-- nvim --headless -c "luafile tests/wide_integer_inference_smoke.lua" -c "qa!"

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local source = {
        "bits 64",
        "mov rax, 0x123456789ABCDEF0",
        "inc rax",
        "sub rax, 0x10",
        "mov rbx, 18446744073709551615",
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
    local value_mask = require("tracker_hud.low_level.register_value_mask")

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

        for _, fact in ipairs(facts or {}) do
            local canonical = fact.metadata and fact.metadata.canonical_name
            if canonical == canonical_name or fact.name == canonical_name then
                return fact
            end
        end

        error("missing " .. canonical_name .. " state after line "
            .. tostring(line_number))
    end

    local seed = state_after(2, "rax")
    assert(seed.resolved ~= false
        and seed.value == "1311768467463790320",
        "wide hexadecimal MOV must remain exact above 2^53")
    assert(seed.metadata.write_value == "1311768467463790320",
        "write metadata must retain exact canonical integer")
    assert(value_mask.hex_for_bytes(
        assert(value_mask.bytes_for_integer(seed.value))
    ) == "0x123456789ABCDEF0",
        "exact register value must round-trip to its 64-bit bytes")
    print("PASS wide integer inference: 64-bit MOV immediate stays exact")

    local incremented = state_after(3, "rax")
    assert(incremented.resolved ~= false
        and incremented.value == "1311768467463790321",
        "INC must use exact arithmetic above 2^53")
    print("PASS wide integer inference: INC remains exact above 2^53")

    local subtracted = state_after(4, "rax")
    assert(subtracted.resolved ~= false
        and subtracted.value == "1311768467463790305",
        "SUB immediate must use exact signed delta arithmetic")
    print("PASS wide integer inference: SUB delta remains exact above 2^53")

    local max_u64 = state_after(5, "rbx")
    assert(max_u64.resolved ~= false
        and max_u64.value == "18446744073709551615",
        "maximum unsigned 64-bit decimal immediate must not round")
    assert(value_mask.hex_for_bytes(
        assert(value_mask.bytes_for_integer(max_u64.value))
    ) == "0xFFFFFFFFFFFFFFFF",
        "maximum unsigned 64-bit decimal must preserve all bits")
    print("PASS wide integer inference: UINT64_MAX decimal stays exact")

    print("PASS Tracker_HUD wide integer inference smoke")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL wide integer inference smoke: "
        .. tostring(err) .. "\n")
    error(err)
end
