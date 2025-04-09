extern int_to_str

section .data
    precision dq 1000.0           ; Precision for multiplication
    decimal db ".", 0             ; Decimal point for float representation
    float_value dq 634.1234567 

section .bss

section .text
global ftoa

ftoa:
    movsd xmm0, [float_value]


    cvttsd2si rax, xmm0           ; 634.91 --> 634 TRUNCATE
    mov r10, rax                  ; r10 = 634
    call int_to_str               ; Convert 634 to string
    mov r14, rax                  ; rdi points to the string returned by int_to_str YOU ARE
                                  ; ACCIDENTIALLY PRINTING 6340000

    mov rax, 1                    ; SYS_write syscall number
    mov rdi, 1                    ; File descriptor 1 = STDOUT
    mov rsi, r14                  ; rsi points to the result string
    mov rdx, 10                   ; Set a maximum number of characters to print (adjust as needed)
    syscall

    mov r11, [precision]          ; r11 = 1000
    imul r10, r11                 ; r10 = 6340000                            

    movsd xmm1, [precision]       ; xmm1 = 1000.0
    movsd xmm2, xmm0              ; xmm2 = 634.91
    mulsd xmm2, xmm1              ; 6349100.0 * 1000
    cvttsd2si r9, xmm2            ; r9 = 6349100

    mov r8, r9                    ; r8 = 6349100
    sub r8, r10                   ; r8 = 9100
    mov rax, r8                   ; rax = 9100
    call int_to_str               ; Convert 9100 to string
    mov r12, rax


    mov rax, 1                ; SYS_write syscall number
    mov rdi, 1                   ; File descriptor 1 = STDOUT
    mov rsi, decimal                   ; rsi points to the result string
    mov rdx, 1                   ; Set a maximum number of characters to print (adjust as needed)
    syscall

    mov rax, 1                ; SYS_write syscall number
    mov rdi, 1                   ; File descriptor 1 = STDOUT
    mov rsi, r12                   ; rsi points to the result string
    mov rdx, 10                   ; Set a maximum number of characters to print (adjust as needed)
    syscall

    ret
