%include "get_res.inc"
global tesla

section .data
one dq 1.0

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

    xorpd xmm0, xmm0
    xor r15, r15    ; index counter set to 0
.loop_start:
    cmp r15, rsi    
    jge .loop_finish

    movsd xmm1, [rdi + r15*8] ; move current index value into xmm1

    movsd xmm2, [one]
    divsd xmm2, xmm1 ; xmm2 = 1/R

    addsd xmm0, xmm2    ; xmm0 += 1/R

    inc r15
    jmp .loop_start

.loop_finish:
    movsd xmm3, [one] ; xmm3 holds 1.0
    divsd xmm3, xmm0 ; xmm3 now holds total resistance = 1/R
    movsd xmm0, xmm3

    push qword 0
    movsd [rsp], xmm0

    restoreNGPRs backup_storage

    movsd xmm0, [rsp]
    pop rax

    restoreGPRs

    ret







