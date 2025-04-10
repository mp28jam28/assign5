extern int_to_str

section .data
    precision dq 100000000.0              ; For floating-point math
    precision_int dq 100000000            ; Integer version for integer math
    decimal db ".", 0
    float_value dq 634.91

section .bss

section .text
global ftoa

ftoa:
    ; movsd xmm0, [float_value]  
    cvttsd2si rax, xmm0           ; 634.91 --> 634 TRUNCATE
    mov r10, rax                  ; LHS of decimal = r10 
    call int_to_str               ; Convert LHS to string
    ; mov r14, rax     

    mov rsi, rax                 
    mov rax, 1                    
    mov rdi, 1                    
    mov rdx, 10                   
    syscall
            

    movsd xmm1, [precision]       ; xmm1 = 1000.0
    movsd xmm2, xmm0              ; xmm2 = 634.91
    mulsd xmm2, xmm1              ; 634.91 * 1000 = 634910
    cvttsd2si r9, xmm2            ; r9 = 634910

    mov r11, [precision_int]          ; r11 = 1000
    imul r10, r11                 ; 634 * 1000 = 634000

    mov r8, r9                    ; r8 = 634910
    sub r8, r10                   ; 634910 - 634000 = 910 Subtract to get RHS of decimal
    mov rax, r8                   ; rax = 9100
    call int_to_str               ; Convert 9100 to string
    mov r12, rax


    mov rax, 1                
    mov rdi, 1                   
    mov rsi, decimal                   
    mov rdx, 1                   
    syscall           

    mov rax, 1                
    mov rdi, 1                   
    mov rsi, r12                   
    mov rdx, 10                   
    syscall


    ret
