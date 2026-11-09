-- tests/architecture_registry_smoke.lua
-- Run from the repository root:
--   nvim --headless -u NONE -c "luafile tests/architecture_registry_smoke.lua"
--
-- First drip-feed migration: x86-64 hardware register descriptions have
-- exactly one shared source, while the ASM-facing adapter shape stays stable.
-- This test deliberately requires no Tree-sitter parser or sample compilation.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local registry = require("tracker_hud.architectures.registry")
    assert(registry.get(nil) == nil, "missing architecture must not guess host")
    assert(registry.get("aarch64") == nil,
        "unknown profile must not quietly fall back to x86-64")
    assert(registry.normalize("x64") == "x86-64")
    assert(registry.normalize("AMD64") == "x86-64")

    local arch = registry.get("x86-64")
    assert(type(arch) == "table" and arch.name == "x86-64")
    assert(arch.metadata.bits == 64 and arch.metadata.endian == "little")
    assert(registry.get("x86_64") == arch
        and registry.get("x64") == arch,
        "aliases must identify the same cached architecture profile")
    assert(package.loaded["tracker_hud.adapters.asm.arch.x86_64.adapter"] == nil,
        "architecture registry must not eagerly load ASM adapter")
    print("PASS architecture profile is language-independent and lazy")

    local variant = require("tracker_hud.adapters.asm.arch.x86_64.init")
    local asm = require("tracker_hud.adapters.asm.init")
    local register_model = require("tracker_hud.sections.low_level.register_model")

    assert(variant.register_families == arch.register_families,
        "ASM variant must use shared register families, not a second copy")
    assert(variant.registers == arch.registers,
        "ASM variant must use shared static register descriptions")
    assert(variant.register_alias_index == arch.register_alias_index,
        "ASM variant must expose shared alias lookup")
    assert(asm.registers == arch.registers
        and asm.register_families == arch.register_families
        and asm.register_alias_index == arch.register_alias_index,
        "ASM master adapter compatibility fields must be retained")

    local old_shape = { register_families = arch.register_families }
    local checked = 0
    for canonical, family in pairs(arch.register_families) do
        for alias_name, alias in pairs(family.aliases or {}) do
            local fast = register_model.resolve_alias(asm, alias_name)
            local fallback = register_model.resolve_alias(old_shape, alias_name)
            assert(fast ~= nil and fallback ~= nil,
                "missing alias: " .. tostring(alias_name))
            assert(fast.canonical == fallback.canonical
                and fast.canonical == (family.canonical or canonical)
                and fast.family == fallback.family
                and fast.family == family
                and fast.alias == fallback.alias
                and fast.alias == alias
                and fast.alias_name == fallback.alias_name,
                "new and legacy alias facts differ: " .. alias_name)
            checked = checked + 1
        end
    end
    assert(checked >= 100, "unexpectedly few register aliases checked")

    for _, name in ipairs({ "eax", "rdi", "rsp", "ah", "xmm31", "zmm31" }) do
        assert(register_model.resolve_alias(asm, name:upper()).canonical
            == register_model.resolve_alias(asm, name).canonical,
            "alias matching must remain case insensitive: " .. name)
    end
    local eax = register_model.resolve_alias(asm, "eax")
    local eax_again = register_model.resolve_alias(asm, "eax")
    assert(eax ~= eax_again,
        "indexed alias lookup must return fresh wrappers, as the old scan did")
    eax_again.alias_name = "deliberately_changed"
    assert(register_model.resolve_alias(asm, "eax").alias_name == "eax",
        "one caller must not mutate future indexed alias results")
    assert(eax.canonical == "rax"
        and eax.alias.bits == 32
        and eax.alias.offset == 0
        and eax.alias.write_mode == "zero_extend_64",
        "EAX zero-extend semantics changed")
    local ah = register_model.resolve_alias(asm, "ah")
    assert(ah.canonical == "rax"
        and ah.alias.bits == 8
        and ah.alias.offset == 8
        and ah.alias.write_mode == "partial",
        "AH partial high-byte alias changed")
    assert(register_model.resolve_alias(asm, "not_a_real_register") == nil)
    assert(register_model.resolve_alias(old_shape, "not_a_real_register") == nil)
    assert(register_model.family_for_register(asm, "eax")
        == arch.register_families.rax,
        "register family lookup must work through prebuilt index")

    assert(#arch.registers.static == 50,
        "extraction must retain original 50 static register rows")
    assert(arch.registers.static[1].name == "rax",
        "static row order must be preserved for presentation")
    assert(arch.registers.static[#arch.registers.static].name == "zmm31",
        "static vector register rows lost in migration")
    print("PASS ASM register contract remains identical (" .. checked
        .. " aliases, 50 static rows)")
    print("PASS indexed alias lookup matches legacy scan semantics")
    print("PASS shared architecture first-tranche smoke")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL shared architecture smoke: " .. tostring(err) .. "\n")
    error(err)
end
