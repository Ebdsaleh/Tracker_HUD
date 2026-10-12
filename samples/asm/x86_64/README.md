# Tracker_HUD x86-64 ASM Samples

These samples are manual validation fixtures for the ASM adapter.

They are intentionally small, readable, and stable. Their job is to make regressions visible before larger ASM adapter work continues.

## Files

- `linux_syscall_validation.asm` — checks target directives, syscall boundary reads, stack value flow, call/ret handling, branch condition reads, warnings, and hex-width coloring.

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

These samples are not assembler build targets yet. They are HUD validation fixtures.
