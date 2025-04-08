STDIN equ 0       ; Standard input
STDOUT equ 1       ; Standard output

SYS_read equ 0     ; syscall number for read
SYS_write equ 1    ; syscall number for write
SYS_exit equ 60

string_size equ 48


%include "get_res.inc"
global tesla

section .data

section .bss
backup_storage    resb 832


; R0 = 1/R1 + 1/R2 + 1/R3
; total R = 1/R0

; formula I = E/R 

section .text

tesla:
    ; Back up
    backupGPRs
    backupNGPRs backup_storage

    ; Parameters
    mov     r15, rdi         ; An array of 3 inputted numbers
    ; use r8, r9, r10, r11, r12

    ; Find where the radix point is
    ; TODO: Add checks for non-float using isfloat
    xor     r14, r14            ; Index


    restoreNGPRs backup_storage
    restoreGPRs

