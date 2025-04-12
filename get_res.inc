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
;  Name: get_res.inc
;  Language: x86-64 Assembly (Intel syntax)
;  Max page width: 130 columns
;================================================================================================================================

;Back-up GPRs
%macro    backupGPRs 0
  push    rbp
  mov    rbp, rsp
  push    rbx
  push    rcx
  push    rdx
  push    rsi
  push    rdi
  push    r8
  push    r9
  push    r10
  push    r11
  push    r12
  push    r13
  push    r14
  push    r15
  pushf
%endmacro

;Restore GPRs
%macro    restoreGPRs 0
  popf
  pop    r15
  pop    r14
  pop    r13
  pop    r12
  pop    r11
  pop    r10
  pop    r9
  pop    r8
  pop    rsi
  pop    rdi
  pop    rdx
  pop    rcx
  pop    rbx
  pop    rbp
%endmacro

%macro    backupNGPRs 1
  mov    rax, 7
  mov    rdx, 0
  xsave    [%1]
%endmacro

%macro    restoreNGPRs 1
  mov    rax, 7
  mov    rdx, 0
  xrstor    [%1]
%endmacro


%macro GET_INPUT 3
    ; %1 = destination array (e.g., arr)
    ; %2 = number of elements (e.g., 3)
    ; %3 = string buffer size (e.g., 32)

    xor    r15, r15             ; r15 = index
    mov    r13, %1              ; r13 = base address of array
    mov    r14, %2              ; r14 = number of elements

.loop_start:
    cmp    r15, r14
    jge    .loop_end

.loop_input:
    xor    rax, rax             ; clear rax
    push   qword 0              ; align stack (16-byte)
    push   qword 0

    mov    rax, 0               ; syscall: SYS_read
    mov    rdi, 0               ; STDIN
    mov    rsi, rsp             ; buffer (top of stack)
    mov    rdx, 32              ; buffer size (e.g., 32)
    syscall

    cmp    eax, -1
    je     .ctrl_d


    mov     rcx, 0
.loop_trim:
    mov     al, byte [rsp + rcx]
    cmp     al, 0
    je      .done_trim
    cmp     al, 10             ; newline?
    jne     .not_newline
    mov     byte [rsp + rcx], 0
    jmp     .done_trim
.not_newline:
    inc     rcx
    jmp     .loop_trim
.done_trim:

    xor    rax, rax
    mov    rdi, rsp
    call   isfloat
    cmp    rax, 0
    je     .invalid_input

    ; Convert input string to float
    xor    rax, rax
    mov    rdi, rsp
    call   atof
    movsd  xmm15, xmm0

    ; Store into array
    movsd [r13 + r15*8], xmm15

    inc    r15

    pop    rax
    pop    rax

    jmp    .loop_start

.invalid_input:
    pop    rax
    pop    rax

    xor    rax, rax
    mov    rax, 1               ; syscall: SYS_write
    mov    rdi, 1               ; STDOUT
    mov    rsi, prompt_input    ; prompt message address
    mov    rdx, 27              ; length of prompt message
    syscall

    jmp    .loop_input          ; retry input for the same index

.ctrl_d:
    pop    rax
    pop    rax

.loop_end:
    mov    rax, r15   
%endmacro

%macro FTOA_PRINT 0
    ; Save original float value
    movsd xmm5, xmm0

    ; Extract integer part from float
    cvttsd2si rax, xmm0
    mov r10, rax

    ; Convert integer part to string and print
    call int_to_str
    mov rsi, rax
    mov rax, 1
    mov rdi, 1
    mov rdx, 10
    syscall

    ; Multiply to shift decimal portion
    movsd xmm1, [precision]
    movsd xmm2, xmm0
    mulsd xmm2, xmm1
    cvttsd2si r9, xmm2

    ; Calculate scaled integer part for subtraction
    mov r11, [precision_int]
    imul r10, r11

    ; Extract decimal digits
    mov r8, r9
    sub r8, r10
    mov rax, r8
    call int_to_str
    mov r12, rax

    ; Print the decimal point
    mov rax, 1
    mov rdi, 1
    mov rsi, decimal
    mov rdx, 1
    syscall

    ; Print right-hand side of the decimal
    mov rax, 1
    mov rdi, 1
    mov rsi, r12
    mov rdx, 10
    syscall
%endmacro

%macro remove_newline 1
    ; %1 = buffer address (e.g., user_name)
    xor rcx, rcx
.strip_loop_%1:
    mov al, [%1 + rcx]
    cmp al, 0
    je .done_strip_%1
    cmp al, 10             ; newline character?
    jne .not_newline_%1
    mov byte [%1 + rcx], 0 ; replace newline with null terminator
    jmp .done_strip_%1
.not_newline_%1:
    inc rcx
    jmp .strip_loop_%1
.done_strip_%1:
%endmacro


