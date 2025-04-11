extern int_to_str
%include "get_res.inc"

section .data
    precision dq 100000000.0              ; For floating-point math
    precision_int dq 100000000            ; Integer version for integer math
    decimal db ".", 0

section .bss

section .text
global ftoa

ftoa:
    ; Save the float double value for future use 
    movsd xmm5, xmm0

    ; Extract integer part from float by truncating (LHS)
    cvttsd2si rax, xmm0           
    mov r10, rax  

    ; Convert Integer part to string & print
    call int_to_str            

    ; Print the left side of the decimal   
    mov rsi, rax                 
    mov rax, 1                    
    mov rdi, 1                    
    mov rdx, 10                   
    syscall

    ; Multiply float to isolate decimal part
    movsd xmm1, [precision]       ; xmm1 = 1000.0
    movsd xmm2, xmm0             
    mulsd xmm2, xmm1              
    cvttsd2si r9, xmm2            

    ; Calculate the scaled integer part
    mov r11, [precision_int]      ; r11 = 1000
    imul r10, r11                 

    ; Extract the decimal part of the float (RHS)
    mov r8, r9                    ; r8 = 634910
    sub r8, r10                   ; 634910 - 634000 = 910 Subtract to get RHS of decimal
    mov rax, r8                   ; rax = 9100
    call int_to_str               ; Convert 9100 to string
    mov r12, rax

    ; Print the decimal part
    mov rax, 1                
    mov rdi, 1                   
    mov rsi, decimal                   
    mov rdx, 1                   
    syscall           

    ; Print the right side of the decimal
    mov rax, 1                
    mov rdi, 1                   
    mov rsi, r12                   
    mov rdx, 10                   
    syscall

    ret
