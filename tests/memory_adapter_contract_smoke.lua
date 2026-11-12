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

local bad_symbol_kinds = fresh_adapter()
memory_spec(bad_symbol_kinds).symbol_resolution.member_kinds = {}
local symbol_kinds_ok, symbol_kinds_err =
    contract.validate_adapter(bad_symbol_kinds)
assert(not symbol_kinds_ok
    and tostring(symbol_kinds_err):find("symbol_resolution.member_kinds", 1, true),
    "empty symbol member-kind policy must fail")
print("PASS memory contract: empty symbol member kinds are rejected")

local duplicate_symbol_kind = fresh_adapter()
memory_spec(duplicate_symbol_kind).symbol_resolution.member_kinds = {
    "label",
    "label",
}
local duplicate_symbol_ok, duplicate_symbol_err =
    contract.validate_adapter(duplicate_symbol_kind)
assert(not duplicate_symbol_ok
    and tostring(duplicate_symbol_err):find("member_kinds", 1, true),
    "duplicate symbol member kind must fail")
print("PASS memory contract: duplicate symbol member kind is rejected")

local bad_forward_policy = fresh_adapter()
memory_spec(bad_forward_policy).symbol_resolution.allow_forward = "yes"
local forward_ok, forward_err =
    contract.validate_adapter(bad_forward_policy)
assert(not forward_ok
    and tostring(forward_err):find("allow_forward", 1, true),
    "non-boolean forward-reference policy must fail")
print("PASS memory contract: invalid forward-reference policy is rejected")

local bad_address_default = fresh_adapter()
memory_spec(bad_address_default).address_size_policy.default_bits = 16
local default_ok, default_err = contract.validate_adapter(bad_address_default)
assert(not default_ok
    and tostring(default_err):find("address_size_policy.default_bits", 1, true),
    "address-size default outside allowed widths must fail at adapter contract")
print("PASS memory contract: invalid address-size default is rejected")

local bad_address_map = fresh_adapter()
memory_spec(bad_address_map).address_size_policy.register_width_map[32] = 16
local map_ok, map_err = contract.validate_adapter(bad_address_map)
assert(not map_ok
    and tostring(map_err):find("register_width_map[32]", 1, true),
    "address-size register map outside allowed widths must fail")
print("PASS memory contract: invalid address-size register map is rejected")

local bad_address_prefix = fresh_adapter()
memory_spec(bad_address_prefix).address_size_policy.prefixes.a32 = 16
local prefix_ok, prefix_err = contract.validate_adapter(bad_address_prefix)
assert(not prefix_ok
    and tostring(prefix_err):find("prefixes[a32]", 1, true),
    "address-size prefix outside allowed widths must fail")
print("PASS memory contract: invalid address-size prefix is rejected")

local duplicate_address_width = fresh_adapter()
memory_spec(duplicate_address_width).address_size_policy.allowed_bits = {
    32,
    64,
    64,
}
local duplicate_width_ok, duplicate_width_err =
    contract.validate_adapter(duplicate_address_width)
assert(not duplicate_width_ok
    and tostring(duplicate_width_err):find("allowed_bits", 1, true),
    "duplicate address-size width must fail at adapter contract")
print("PASS memory contract: duplicate address-size width is rejected")

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
