; Tracker_HUD ASM/x86-64 memory operand validation sample
; PRIVATE NOTE: this file is intentionally source-code sample material and is safe in-repo.
;
; Expected HUD behavior:
; - On the whole memory operand, show it as a source/destination memory operand.
; - On rbp/rsp/rip inside brackets, show focused token kind = register.
; - On rbp in [rbp + rax*4 - 8], show frame-pointer/base wording.
; - On rsp in [rsp + 8], show stack-pointer/base wording.
; - On rax inside [rbp + rax*4 - 8], show address role = index register.
; - On 4, show address role = scale.
; - On -8/+8, show address role = displacement.
; - On msg inside [rel msg], show a memory-symbol component.

; arch=x86-64;
; platform=linux;
; syntax=nasm;

section .data
msg:
    db "hello", 10

section .text
global _start

_start:
    mov rbp, rsp
    mov rax, [rbp + rax*4 - 8]
    mov [rsp + 8], rax
    lea rsi, [rel msg]
    mov rdx, 6
    mov rax, 1
    mov rdi, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall
