extern int_to_str

section .data
    precision dq 1000.0           ; Precision for multiplication
    decimal db ".", 0             ; Decimal point for float representation
    float_value dq 634.91         ; TEST VALUE

section .bss

section .text
global ftoa

ftoa:
    ; movsd xmm0, [float_value]  IGNORE
    cvttsd2si rax, xmm0           ; 634.91 --> 634 TRUNCATE
    mov r10, rax                  ; LHS of decimal = r10 
    call int_to_str               ; Convert LHS to string
    mov r14, rax                 

    movsd xmm1, [precision]       ; xmm1 = 1000.0
    movsd xmm2, xmm0              ; xmm2 = 634.91
    mulsd xmm2, xmm1              ; 634.91 * 1000 = 634910
    cvttsd2si r9, xmm2            ; r9 = 634910

    mov r11, [precision]          ; r11 = 1000
    imul r10, r11                 ; 634 * 1000 = 634000

    mov r8, r9                    ; r8 = 634910
    sub r8, r10                   ; 634910 - 634000 = 910 Subtract to get RHS of decimal
    mov rax, r8                   ; rax = 9100
    call int_to_str               ; Convert 9100 to string
    mov r12, rax

    ret
