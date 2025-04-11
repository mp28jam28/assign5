;*******************************************************************************************************************
;Program name: "Electricity". This program computes missing electrical information from a circuit consisting of *
;three sub-circuits running on direct current (DC). Copyright (C) 2025 Michelle Pham                                
;                                                                                                                   
;This file is part of the software program "Electricity".                                                       
;Electricity is free software: you can redistribute it and/or modify it under the terms of the GNU General    
;Public License version 3 as published by the Free Software Foundation.                                                  
;Electricity is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the      
;implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
;more details. A copy of the GNU General Public License v3 is available here:  <https://www.gnu.org/licenses/>.               
;*******************************************************************************************************************

;====================================================================================================================
;
;Author Information
;  Name: Michelle Pham
;  Email: mp28jam@csu.fullerton.edu
;  CWID: 867434789
;
;Program Information
;  Name: Electricity
;  Programming Language: x86-64 (Pure Assembly)
;  Effective Date: April 11, 2025
;  Latest Update: April 11, 2025
;  Date open source license added: April 11, 2025
;  Files: atof.asm, edison.asm, faraday.asm, get_res.inc, int_to_str.asm, isfloat.asm, r.sh, tesla.asm
;  Status: Completed
;  References Consulted: Ed Jorgensen, "x86-64 Assembly Language Programming with Ubuntu"
;  Future Upgrades: Add support for alternating current (AC) and multi-loop circuits. Improve floating-point handling 
;  and input validation.
;
;Purpose
;  This program receives partial information about a DC electric circuit composed of three sub-circuits. Based on the 
;  input provided by the user, it calculates missing values such as voltage, current, or resistance using Ohm’s Law 
;  and basic circuit rules. This project was designed not only to apply problem-solving to electrical engineering 
;  concepts, but also to provide the programmer with experience in developing a **pure assembly** program.
;
;Pure Assembly Philosophy
;  The program is intentionally built using **pure assembly language**, meaning it uses only the native x86-64 assembly
;  without relying on supporting languages like C or C++. This contrasts with hybrid assembly programs that interface
;  with high-level languages. The objective is to give the programmer a deeper understanding of low-level operations 
;  and direct hardware interaction by avoiding abstraction layers.
;
;Development Information
;  OS: Ubuntu 22.04.4 LTS
;  Text Editor: Github Codespaces
;  Tools: NASM assembler, LD linker
;
;Current File Information
;  Name: atof.asm
;  Language: x86-64 Assembly (Intel syntax)
;  Max page width: 130 columns
;  Assemble: nasm -f elf64 -l atof.lis -o atof.o atof.asm
;  Function Prototype: void input_values(double arr[], long sz)
;
;================================================================================================================================

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
