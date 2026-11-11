-- tests/memory_adapter_contract_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/memory_adapter_contract_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local contract = require("tracker_hud.adapters.contract")
local asm_source = require("tracker_hud.adapters.asm.init")

local function fresh_adapter()
    return vim.deepcopy(asm_source)
end

local function memory_spec(adapter)
    return assert(
        adapter.construct_specs
            and adapter.construct_specs.ptr
            and adapter.construct_specs.ptr.operand
            and adapter.construct_specs.ptr.operand.memory,
        "ASM ptr memory declaration missing"
    )
end

local valid, err = contract.validate_adapter(fresh_adapter())
assert(valid, "current ASM memory declaration must validate: " .. tostring(err))
print("PASS memory contract: current ASM memory declaration validates")

local bad_mode = fresh_adapter()
memory_spec(bad_mode).address_modes.rel.kind = ""
local ok, mode_err = contract.validate_adapter(bad_mode)
assert(not ok
    and tostring(mode_err):find("address_modes[rel]", 1, true),
    "empty address-mode kind must fail at adapter contract")
print("PASS memory contract: invalid address mode is rejected")

local bad_size = fresh_adapter()
memory_spec(bad_size).size_prefixes.qword.bits = 0
local size_ok, size_err = contract.validate_adapter(bad_size)
assert(not size_ok
    and tostring(size_err):find("size_prefixes[qword].bits", 1, true),
    "invalid memory size width must fail at adapter contract")
print("PASS memory contract: invalid size prefix is rejected")

local bad_bracket = fresh_adapter()
memory_spec(bad_bracket).brackets.close = ""
local bracket_ok, bracket_err = contract.validate_adapter(bad_bracket)
assert(not bracket_ok
    and tostring(bracket_err):find("brackets.close", 1, true),
    "empty memory bracket must fail at adapter contract")
print("PASS memory contract: invalid bracket declaration is rejected")

local bad_role = fresh_adapter()
memory_spec(bad_role).component_roles.base_register.kind = ""
local role_ok, role_err = contract.validate_adapter(bad_role)
assert(not role_ok
    and tostring(role_err):find("component_roles[base_register].kind", 1, true),
    "invalid component role kind must fail at adapter contract")
print("PASS memory contract: invalid component role is rejected")

local bad_override = fresh_adapter()
memory_spec(bad_override).register_role_overrides.rbp = ""
local override_ok, override_err = contract.validate_adapter(bad_override)
assert(not override_ok
    and tostring(override_err):find("register_role_overrides", 1, true),
    "empty register-role override must fail at adapter contract")
print("PASS memory contract: invalid role override is rejected")

local bad_access = fresh_adapter()
bad_access.memory_accesses.mov[1].access = "execute"
local access_ok, access_err = contract.validate_adapter(bad_access)
assert(not access_ok
    and tostring(access_err):find("memory_accesses[mov][1].access", 1, true),
    "invalid memory access kind must fail at adapter contract")
print("PASS memory contract: invalid access intent is rejected")

local duplicate_access = fresh_adapter()
duplicate_access.memory_accesses.mov[#duplicate_access.memory_accesses.mov + 1] = {
    operand_index = 1,
    operand_kind = "memory",
    access = "read",
}
local duplicate_ok, duplicate_err = contract.validate_adapter(duplicate_access)
assert(not duplicate_ok
    and tostring(duplicate_err):find("operand_index", 1, true),
    "duplicate memory access rule must fail at adapter contract")
print("PASS memory contract: duplicate operand access rule is rejected")

local bad_operand_index = fresh_adapter()
bad_operand_index.memory_accesses.mov[1].operand_index = 0
local index_ok, index_err = contract.validate_adapter(bad_operand_index)
assert(not index_ok
    and tostring(index_err):find("operand_index", 1, true),
    "invalid memory access operand index must fail at adapter contract")
print("PASS memory contract: invalid access operand index is rejected")

print("PASS Tracker_HUD memory adapter contract smoke")
