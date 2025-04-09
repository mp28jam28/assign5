section .bss
    int_buffer resb 21         ; 20 digits max for 64-bit + null terminator

section .text
global int_to_str

int_to_str:
    push rbx
    push rcx
    push rdx

    mov rcx, 10                ; Base 10
    mov rbx, int_buffer
    add rbx, 20                ; Point to end of buffer
    mov byte [rbx], 0          ; Null-terminate

.next_digit:
    xor rdx, rdx
    div rcx                    ; RAX ÷ 10, quotient in RAX, remainder in RDX
    sub rbx, 1
    add dl, '0'                ; Convert digit to ASCII
    mov [rbx], dl

    cmp rax, 0
    jne .next_digit            ; Continue loop if RAX > 0

    mov rax, rbx               ; Return pointer to result string in RAX

    pop rdx
    pop rcx
    pop rbx
    ret
