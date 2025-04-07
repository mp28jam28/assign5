STDIN equ 0       ; Standard input
STDOUT equ 1       ; Standard output

SYS_read equ 0     ; syscall number for read
SYS_write equ 1    ; syscall number for write
SYS_exit equ 60

string_size equ 48

%include "get_res.inc"

section .data

section .bss

; R0 = 1/R1 + 1/R2 + 1/R3
; total R = 1/R0

; formula I = E/R 

section .text



atof:
    ; Back up
    backupGPRs
    backupNGPRs
 

    ; Parameters
    mov     r15, rdi            ; An array of char with null termination expected

    ; Find where the radix point is
    ; TODO: Add checks for non-float using isfloat
    xor     r14, r14            ; Index


    restoreNGPRs
    restoreGPRs
global tesla
tesla: