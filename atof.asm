global atof

%include "get_res.inc"

section .data
    neg_mask dq 0x8000000000000000

section .bss
    align 64
    storedata resb 832

section .text

atof:
    ; Save registers and SIMD state
    backupGPRs
    mov     rax, 7
    mov     rdx, 0
    xsave   [storedata]

    mov     r15, rdi            ; r15 = pointer to input string
    xor     r14, r14            ; r14 = index to find decimal point

search_dot:
    cmp     byte [r15 + r14], '.'
    je      dot_found
    inc     r14
    jmp     search_dot

dot_found:
    xor     r13, r13            ; r13 = parsed integer value
    mov     r12, 1              ; r12 = multiplier for digit place
    mov     r11, r14            ; r11 = index before the dot
    dec     r11
    xor     r10, r10            ; r10 = flag for negative number

parse_whole:
    mov     al, byte [r15 + r11]
    cmp     al, '+'
    je      end_whole
    cmp     al, '-'
    je      set_negative

    sub     al, '0'
    imul    rax, r12
    add     r13, rax
    imul    r12, 10
    dec     r11
    cmp     r11, 0
    jge     parse_whole
    jmp     end_whole

set_negative:
    mov     r10, 1

end_whole:
    mov     rax, 10
    cvtsi2sd xmm11, rax         ; xmm11 = 10.0
    pxor    xmm13, xmm13        ; xmm13 = decimal accumulator
    movsd   xmm12, xmm11        ; xmm12 = initial divisor (10.0)

    inc     r14                 ; Move past the '.'

parse_frac:
    mov     al, byte [r15 + r14]
    sub     al, '0'
    cvtsi2sd xmm0, rax
    divsd   xmm0, xmm12
    addsd   xmm13, xmm0
    mulsd   xmm12, xmm11
    inc     r14
    cmp     byte [r15 + r14], 0
    jne     parse_frac

    cvtsi2sd xmm0, r13
    addsd   xmm0, xmm13         ; xmm0 = full float value

    cmp     r10, 0
    je      finish

    ; If negative, apply negation by flipping sign bit
    movsd   xmm1, [neg_mask]
    xorps   xmm0, xmm1

finish:
    push    qword 0
    movsd   [rsp], xmm0

    ; Restore SIMD state and registers
    mov     rax, 7
    mov     rdx, 0
    xrstor  [storedata]
    movsd   xmm0, [rsp]
    pop     rax

    restoreGPRs
    ret
