; Tracker_HUD ASM x86-64 Linux syscall validation sample
;
; Purpose:
;   Manual validation fixture for the ASM adapter / low-level inference HUD.
;
; Expected target selection:
;   arch     = x86-64
;   platform = linux
;   syntax   = nasm
;   abi      = linux_syscall
;
; This file is intentionally small and stable. Use it after ASM adapter changes
; to check that directives, syscall boundary reads, stack value flow,
; control-flow events, warnings, and hex-width coloring still behave.

; tracker-hud: arch=x86-64
; tracker-hud: platform=linux
; tracker-hud: syntax=nasm
; tracker-hud: abi=linux_syscall

section .text
global _start

_start:
    ; Hex width coloring validation:
    ; 0x7FFF00000000000F should display as [MMMMMMMM][OOOO][GG][BB].
    ; Digits beyond the configured width should fall back to normal text.
    mov r8, 0x7FFF00000000000F
    mov r9, 0x123456789ABCDEF00000000000000000

    ; Register and syscall boundary validation:
    ; The syscall number must be read from the pre-syscall state before
    ; Linux overwrites rax with the return value.
    mov rax, 1                  ; write
    mov rdi, 1                  ; fd = stdout
    lea rsi, [rel message]      ; buffer
    mov rdx, message_len        ; length
    syscall

    ; Stack value-flow validation:
    ; The value 123 should flow rcx -> stack -> rax.
    mov rcx, 123
    push rcx
    pop rax

    ; Unknown stack read validation:
    ; This pop should warn that the stack value is unknown.
    pop r10

    ; Call/return validation:
    ; call records a synthetic return address; ret reads it.
    call local_function

    ; Flag and branch validation:
    ; cmp produces condition flags; je consumes them.
    cmp rax, 123
    je matched_value

    ; Unknown condition validation:
    ; This is only meaningful when inspected without a nearby flag producer.
unknown_condition_probe:
    je matched_value

matched_value:
    mov rax, 60                 ; exit
    xor rdi, rdi                ; status = 0
    syscall                     ; non-returning boundary

local_function:
    ret

section .data
message:
    db "Tracker_HUD validation", 10
message_len equ $ - message
