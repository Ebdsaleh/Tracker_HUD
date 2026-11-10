; Tracker_HUD x86-64 alias-write validation sample.
; Source inference only: no execution is required.
bits 64

global _start
_start:
    mov ah, 0x3C
    mov rax, 0x12345678
    mov ah, 0xAA
    mov al, 0xBB
    mov ax, 0xCCDD
    mov eax, 0x12345678
    mov ah, bl
    mov eax, ebx
