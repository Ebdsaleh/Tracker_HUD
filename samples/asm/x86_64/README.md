# Tracker_HUD x86-64 ASM Samples

These samples are manual validation fixtures for the ASM adapter.

They are intentionally small, readable, and stable. Their job is to make regressions visible before larger ASM adapter work continues.

## Files

- `linux_syscall_validation.asm` — checks target directives, syscall boundary reads, stack value flow, call/ret handling, branch condition reads, warnings, and hex-width coloring.
- `memory_operand_validation.asm` — checks spec-based memory operand modeling, focused-token inspection, base/index/scale/displacement roles, memory addressing-mode wording, and LEA address-value inference.

## How to use

Open a sample in Neovim with Tracker_HUD enabled, then move the cursor over the interesting instruction operands and read the HUD sections.

Recommended checks for `linux_syscall_validation.asm`:

1. The target should resolve as:
   - `arch=x86-64`
   - `platform=linux`
   - `syntax=nasm`
   - `abi=linux_syscall`
2. `mov rax, 1` followed by `syscall` should let the Events section read the syscall number from the pre-syscall state.
3. The final `mov rax, 60` / `syscall` should be shown as a non-returning process-exit boundary.
4. `mov rcx, 123`, `push rcx`, `pop rax` should show value flow through the stack.
5. Bare `pop r10` should warn about an unknown stack value.
6. `call local_function` should record a synthetic return address.
7. `ret` should read a return address from the stack.
8. `cmp rax, 123` followed by `je matched_value` should show a conditional branch reading flags.
9. The hex literal `0x7FFF00000000000F` should show the 64-bit width bands.
10. The oversized hex literal should leave overflow digits in the normal text color.

Recommended checks for `memory_operand_validation.asm`:

1. On `[rbp + rax*4 - 8]`, the containing operand should be reported as a memory operand.
2. On `rbp`, the focused token should be a register with frame-pointer/base wording and address mode `frame-pointer-relative memory address`.
3. On the inner `rax`, the focused token should be a register with address role `index register` and address mode `base/index memory address`.
4. On `4`, the address role should be `scale`.
5. On `-8`, the address role should be `displacement`.
6. On `[rsp + 8]`, the `rsp` token should show stack-pointer/base wording and address mode `stack-pointer-relative memory address`.
7. On `[rel msg]`, `msg` should be identified as a symbol component inside the memory/address expression.
8. After `lea rsi, [rel msg]`, the later `write` syscall should not warn that required argument 2 / `rsi` is unknown.

These samples are not assembler build targets yet. They are HUD validation fixtures.
