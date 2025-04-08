section .text
global ftoa

; Converts an integer in rax to a null-terminated string in the buffer pointed by rbx.
ftoa:
    push    rbx         ; Save rbx (buffer pointer) because we will use it.
    push    rcx         ; Save rcx as a counter.
    push    rdx         ; Save rdx as a divisor.

    mov     rcx, 10     ; Divisor for extracting digits (base 10)
    xor     rdx, rdx    ; Clear rdx for division (quotient will go into rax)
    mov     rsi, rbx    ; rsi points to the buffer for storing digits.

    ; Check for zero case
    cmp     rax, 0
    je      handle_zero

convert_loop:
    ; Divide the number by 10 to get the next digit.
    div     rcx          ; rax = rax / 10, rdx = rax % 10
    add     dl, '0'      ; Convert the digit in rdx to ASCII
    mov     [rsi], dl    ; Store the digit in the buffer
    inc     rsi          ; Move buffer pointer

    ; Keep dividing, this will go until the number is zero
    mov     rax, rdx     ; Move remainder into rax for the next division
    xor     rdx, rdx     ; Clear rdx to prepare for the next division

    ; At this point the loop doesn't check if it's done, so it continues.

handle_zero:
    ; Special case for zero (since zero is not handled by the loop above).
    mov     byte [rsi], '0'
    inc     rsi

    ; Null-terminate the string.
    mov     byte [rsi], 0

    ; Restore registers and return.
    pop     rdx
    pop     rcx
    pop     rbx
    ret
