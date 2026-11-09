-- tests/architecture_alias_benchmark.lua
-- Optional non-gating microbenchmark (from repository root):
--   nvim --headless -u NONE -c "luafile tests/architecture_alias_benchmark.lua"
--
-- Measures one hot path ONLY: architecture register-alias lookups.
-- Does not measure HUD redraw, Tree-sitter, instruction replay or memory use.
-- Keep results on ERIDU as evidence; do not turn wall-clock results into CI
-- assertions or claim end-to-end speed gains from this microbenchmark.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local arch = require("tracker_hud.architectures.registry").get("x86-64")
    local model = require("tracker_hud.sections.low_level.register_model")

    local indexed = {
        register_families = arch.register_families,
        register_alias_index = arch.register_alias_index,
    }
    local legacy = { register_families = arch.register_families }
    local samples = {
        "rax", "eax", "ah", "rdi", "r8d", "rsp",
        "zmm0", "ymm11", "xmm31",
    }
    for _, alias in ipairs(samples) do
        assert(model.resolve_alias(indexed, alias)
            and model.resolve_alias(legacy, alias),
            "benchmark alias unexpectedly missing: " .. alias)
    end

    local clock = (vim.uv or vim.loop).hrtime
    local iterations = 80000
    local checksum = 0
    local function measure(adapter)
        local begin = clock()
        for i = 1, iterations do
            local alias = samples[((i - 1) % #samples) + 1]
            local resolved = model.resolve_alias(adapter, alias)
            if resolved and resolved.canonical then
                checksum = checksum + 1
            end
        end
        return (clock() - begin) / 1000000
    end

    -- Warm both paths once to reduce first-use/JIT bias.
    measure(indexed)
    measure(legacy)

    local legacy_ms = measure(legacy)
    local indexed_ms = measure(indexed)
    assert(checksum == iterations * 4,
        "lookup comparison did not exercise equivalent name coverage")
    print(string.format("Alias lookups: %d per measured path", iterations))
    print(string.format("Legacy family scan: %.3f ms", legacy_ms))
    print(string.format("Shared indexed path: %.3f ms", indexed_ms))
    print("Microbenchmark only: full ASM cursor performance is NOT measured")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL alias benchmark: " .. tostring(err) .. "\n")
    error(err)
end
