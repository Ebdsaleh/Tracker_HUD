-- tests/architecture_register_roles_smoke.lua
-- Run from the repository root:
--   nvim --headless -u NONE -c "luafile tests/architecture_register_roles_smoke.lua" -c "qa!"
--
-- Third architecture migration tranche:
-- CPU register identity is separate from function-ABI register usage.

local function find_register(rows, name)
    for _, row in ipairs(rows or {}) do
        if row.name == name then
            return row
        end
    end

    return nil
end

local function find_static(rows, name)
    for _, row in ipairs(rows or {}) do
        if row.name == name then
            return row
        end
    end

    return nil
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local registry = require("tracker_hud.architectures.registry")
    local arch = assert(registry.get("x86-64"))

    -- Hardware identity must no longer claim one particular ABI.
    assert(arch.register_families.rax.role == "accumulator")
    assert(arch.register_families.rbx.role == "general register")
    assert(arch.register_families.rcx.role == "counter")
    assert(arch.register_families.rdx.role == "data")
    assert(arch.register_families.rsi.role == "source index")
    assert(arch.register_families.rdi.role == "destination index")
    assert(arch.register_families.rbp.role == "base pointer")
    assert(arch.register_families.r10.role == "general register")
    assert(arch.register_families.r12.role == "general register")

    local static_rax = assert(find_static(arch.registers.static, "rax"))
    local static_rdi = assert(find_static(arch.registers.static, "rdi"))
    local static_r12 = assert(find_static(arch.registers.static, "r12"))
    assert(static_rax.role == "accumulator")
    assert(static_rdi.role == "destination index")
    assert(static_r12.role == "general register")
    print("PASS architecture register roles contain hardware identity only")

    assert(arch.platforms.linux.function_abi == "sysv_amd64")
    assert(arch.platforms.darwin.function_abi == "sysv_amd64")
    assert(arch.platforms.windows.function_abi == "windows_x64")
    assert(arch.calling_conventions.sysv_amd64.kind == "function_call")

    local sysv = assert(arch.register_roles.sysv_amd64)
    assert(sysv.rax.role == "accumulator / return value"
        and sysv.rax.usage == "return_value")
    assert(sysv.rdi.role == "destination index / argument register"
        and sysv.rdi.usage == "argument")
    assert(sysv.rbx.role == "callee-saved general register"
        and sysv.rbx.usage == "callee_saved")
    assert(sysv.r10.role == "temporary general register"
        and sysv.r10.usage == "caller_saved")
    print("PASS SysV register usage lives in target overlay")

    local variant = require("tracker_hud.adapters.asm.arch.x86_64.init")
    assert(variant.register_roles == arch.register_roles,
        "ASM x86-64 variant must share target role tables")

    local asm = require("tracker_hud.adapters.asm.init")
    assert(asm.register_roles == arch.register_roles,
        "ASM master adapter must forward shared target role tables")
    assert(asm.platforms == arch.platforms,
        "ASM master adapter must forward shared platform tables")

    local registers = require("tracker_hud.sections.low_level.registers")
    local rows = registers.collect({}, asm, {})

    local rax = assert(find_register(rows, "rax"))
    local rbx = assert(find_register(rows, "rbx"))
    local rdi = assert(find_register(rows, "rdi"))
    local r10 = assert(find_register(rows, "r10"))
    local rbp = assert(find_register(rows, "rbp"))

    -- The supported Linux target retains the established user-facing wording.
    assert(rax.role == "accumulator / return value")
    assert(rbx.role == "callee-saved general register")
    assert(rdi.role == "destination index / argument register")
    assert(r10.role == "temporary general register")
    assert(rbp.role == "frame/base pointer")

    assert(rax.metadata.architecture_role == "accumulator")
    assert(rax.metadata.target_role == "accumulator / return value")
    assert(rax.metadata.target_role_profile == "sysv_amd64")
    assert(rax.metadata.target_role_spec == sysv.rax)
    print("PASS generic register collection composes Linux SysV roles without UI drift")

    -- Declared targets without a role overlay must degrade to architecture truth,
    -- never inherit SysV semantics accidentally.
    local previous_targets = asm.active_targets
    asm.active_targets = {
        architecture = "x86-64",
        platform = "windows",
        abi = "windows_x64",
        mode = "long64",
        diagnostics = {},
    }

    local windows_rows = registers.collect({}, asm, {})
    local windows_rax = assert(find_register(windows_rows, "rax"))
    local windows_rdi = assert(find_register(windows_rows, "rdi"))

    assert(windows_rax.role == "accumulator")
    assert(windows_rdi.role == "destination index")
    assert(windows_rax.metadata.target_role == nil)
    assert(windows_rax.metadata.architecture_role == "accumulator")

    asm.active_targets = previous_targets
    print("PASS undeclared role overlays fall back to hardware truth")
    print("PASS Tracker_HUD architecture register-role smoke")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL architecture register-role smoke: "
        .. tostring(err) .. "\n")
    error(err)
end
