# Tracker_HUD ASM Roadmap

This document records the current ASM-adapter direction and the remaining work after the hex-width visual guide work.

Baseline before this note:

- `05b137c` — `feat: keep oversized hex digits uncolored`
- Branch: `main`
- Adapter focus: `asm` / `x86_64` / `linux_syscall` / `nasm`

## Current working areas

The current ASM work has these major systems in place:

- target directive detection for `arch`, `platform`, `syntax`, and ABI selection
- x86-64 register inventory and register-family display
- source-aware HUD sections for Scope, Registers, Events, Stack, Heap, and Warnings
- low-level inference modules for register, stack, boundary, heap, warning, and control-flow facts
- syscall boundary reads and non-returning syscall reporting
- stack push/pop/call/ret value flow and relative stack-depth tracking
- branch and loop event declarations for common x86-64 control-flow instructions
- plugin-wide hex-width color guides for 8-bit, 16-bit, 32-bit, 64-bit, and optional 128-bit ranges

## Main remaining work

### 1. Add a small validation suite

The most important next step is repeatable validation. The plugin needs a small set of ASM snippets that exercise expected HUD behavior, so regressions are caught before they reach the user.

Priority cases:

- directives load `arch=x86-64`, `platform=linux`, `syntax=nasm`, `abi=linux_syscall`
- `mov rax, 60` then `syscall` resolves syscall number before `rax` is overwritten
- `exit` / `exit_group` are shown as non-returning boundaries
- `push` then `pop` transfers known values through the stack
- bare `pop` warns about unknown stack values
- `call` records a synthetic return address
- `ret` reads the return address and warns when unknown
- `cmp` then `je` resolves condition flags
- bare `je` warns about unknown condition flags
- hex width colors preserve the low-byte anchor and leave overflow uncolored

### 2. Split `context_engine.lua`

`context_engine.lua` is now too large. The architecture is already moving toward separate low-level inferencers, so the next structural improvement is to split the engine into focused modules while keeping the public API stable.

Suggested module boundaries:

- target and adapter resolution
- source/cursor lookup glue
- instruction collection
- operand-role extraction
- register-effect application
- low-level inference coordination
- section payload assembly

This should be done as a refactor-only tranche with no intended HUD behavior changes.

### 3. Improve operand modeling

The ASM adapter should get stronger at explaining what the cursor is touching.

Important cases:

- immediate values vs symbols vs labels
- memory operands as containers
- base/index/scale/displacement roles inside memory operands
- RIP-relative addressing
- stack-relative addressing like `[rsp + 8]` and `[rbp - 16]`
- operand-size prefixes and explicit memory sizes

The user-facing goal is that `mov rax, [rbp + rax*4 - 8]` can explain both the focused token and the containing memory operand.

### 4. Tighten register and flag inference

Registers are mostly present, but state inference can keep improving.

Remaining work:

- partial-register write behavior and dependency notes
- zero-extension behavior for 32-bit writes into 64-bit registers
- better flag-producing instruction summaries
- better flag-consuming instruction summaries
- carry/borrow/overflow wording for branch conditions
- clearer caller-saved / callee-saved / syscall-not-preserved wording

### 5. Expand stack and ABI facts

The stack model now has a good foundation, but it can become more useful for real code.

Remaining work:

- x86-64 Linux calling-convention argument registers
- function prologue and epilogue recognition
- frame-pointer setup and teardown explanations
- red-zone notes for System V AMD64
- stack alignment warnings around calls
- better handling of `enter`, `leave`, `pushfq`, `popfq`, and interrupt-like control transfers

### 6. Expand boundary and syscall coverage

Boundary inference is useful already, but syscall coverage should become more complete over time.

Remaining work:

- broader syscall table coverage
- argument names and value sources for more syscalls
- return-value meaning, including negative errno ranges
- memory/resource effects for allocation, file descriptors, buffers, and process termination
- warnings for missing required syscall arguments when values are unknown

### 7. Improve warning policy and wording

Warnings should stay accessibility-first and should not become noisy.

Remaining work:

- warning severities and categories that match the visual-language spec
- de-duplication of repeated warnings
- clearer subject highlighting for the exact value/register/operand at risk
- wording that explains what is unknown without implying the code is wrong

### 8. Performance and rendering polish

As the plugin grows, the HUD should remain responsive.

Remaining work:

- throttle expensive refreshes
- cache per-buffer source scans where safe
- keep source-buffer hex highlighting bounded by configurable line limits
- avoid duplicated extmarks when buffers refresh often
- keep plain/marker/tag/rich visual modes consistent

## Suggested next tranche

The safest next implementation tranche is:

1. Add a lightweight validation harness or documented manual validation snippets.
2. Add sample ASM files for directive, syscall, stack, branch, and hex-width behavior.
3. Then split `context_engine.lua` once the validation snippets give us a safety net.

This keeps the project moving without risking another hidden loader breakage.
