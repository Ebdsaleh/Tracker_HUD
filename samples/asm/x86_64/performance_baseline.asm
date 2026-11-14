; Tracker_HUD repeatable ASM performance-baseline sample
; Synthetic source fixture for profiler measurements only.
; It is intentionally long enough for >=50-line cursor jumps.
; Do not treat wall-clock values from this file as CI thresholds.
;
; Profile procedure:
;   :HudProfile reset
;   :HudProfile on
;   visit PROFILE MARKER A, step one line, jump to PROFILE MARKER C,
;   edit/undo near the top, toggle platform=linux/windows and undo,
;   then :HudProfile

; arch=x86-64;
; platform=linux;
; syntax=nasm;
bits 64

section .data
msg:
    db "tracker_hud", 10
scratch:
    dq 0, 0, 0, 0

section .text
global _start

_start:
    mov rbp, rsp
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    xor rdx, rdx

; PROFILE MARKER A
    mov rax, 4
    add rbx, 7
    sub rcx, 1
    inc rdx
    dec rsi
    xor rdi, rdi
    mov r8, 22
    mov r9, 25
    add rax, 28
    sub rbx, 1
    inc rcx
    dec rdx
    xor rsi, rsi
    mov rdi, 43
    mov r8, 46
    add r9, 49
    sub rax, 1
    inc rbx
    dec rcx
    xor rdx, rdx
    mov rsi, 64
    mov rdi, 67
    add r8, 70
    sub r9, 1
    inc rax
    dec rbx
    xor rcx, rcx
    mov rdx, 85
    mov [rsp + 8], rax
    mov r10, [rsp + 8]
    lea rsi, [rel msg]

; PROFILE MARKER B
    mov rdx, 6
    push rsi
    pop rdi
    add r8, 2
    sub r9, 1
    cmp rax, 31
    xor rbx, rbx
    mov rcx, 41
    mov rdx, 46
    push rsi
    pop rdi
    add r8, 2
    sub r9, 1
    cmp rax, 71
    xor rbx, rbx
    mov rcx, 81
    mov rdx, 86
    push rsi
    pop rdi
    add r8, 2
    sub r9, 1
    cmp rax, 111
    xor rbx, rbx
    mov rcx, 8
    mov rdx, 13
    push rsi
    pop rdi
    add r8, 2
    sub r9, 1
    cmp rax, 38
    xor rbx, rbx
    mov rcx, 48
    call helper_one
    call helper_two

; PROFILE MARKER C
    mov rdi, 8
    add r8, 4
    sub r9, 2
    inc rax
    dec rbx
    mov [rsp + 16], rcx
    mov rdx, [rsp + 16]
    xor rsi, rsi
    mov rdi, 64
    add r8, 4
    sub r9, 2
    inc rax
    dec rbx
    mov [rsp + 16], rcx
    mov rdx, [rsp + 16]
    xor rsi, rsi
    mov rdi, 120
    add r8, 4
    sub r9, 2
    inc rax
    dec rbx
    mov [rsp + 16], rcx
    mov rdx, [rsp + 16]
    xor rsi, rsi
    mov rdi, 49
    add r8, 4
    sub r9, 2
    inc rax
    dec rbx
    mov [rsp + 16], rcx
    mov rdx, [rsp + 16]
    xor rsi, rsi

; Linux syscall boundary near the tail.
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg]
    mov rdx, 12
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

helper_one:
    push rbp
    mov rbp, rsp
    mov rax, 42
    mov rbx, rax
    pop rbp
    ret

helper_two:
    push rbp
    mov rbp, rsp
    mov eax, 1
    mov rbx, rax
    pop rbp
    ret
