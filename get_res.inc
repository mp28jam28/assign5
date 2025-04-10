;****************************************************************************************************************************
; Program name: Non-deterministic Random Numbers
; This program generates up to 100 random numbers using the non-deterministic random number generator found inside modern 
; x86 microprocessors. The generated numbers are then normalized to the range 1.0 to 2.0 and sorted. 
; Copyright (C) 2025 Michelle Pham
;                                                                                                                         
; This file is part of the software program "Non-deterministic Random Numbers".                                    
; "Non-deterministic Random Numbers" is free software: you can redistribute it and/or modify it under the terms of    
; the GNU General Public License version 3 as published by the Free Software Foundation.                                  
; "Non-deterministic Random Numbers" is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;     
; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public     
; License for more details. A copy of the GNU General Public License v3 is available here: <https://www.gnu.org/licenses/>.
;****************************************************************************************************************************

;================================================================================================================================
;
; Author Information
;  Name: Michelle Pham
;  Email: mp28jam@csu.fullerton.edu
;  CWID: 867434789
;  Course: CPSC 240-03
;
; Program Information
;  Name: Non-deterministic Random Numbers
;  Programming Languages: x86-64 Assembly, C++
;  Effective Date: March 25, 2025
;  Latest Update: March 25, 2025
;  Date open source license added: March 25, 2025
;  Files: main.cpp, executive.asm, fill_random_array.asm, isnan.asm
;  Status: Incomplete
;  References Consulted: Ed Jorgensen, "x86-64 Assembly Language Programming with Ubuntu"
;  Future Upgrades: Implement advanced sorting algorithms and parallel number generation.
;
; Purpose
;  This program generates up to 100 random numbers using the non-deterministic random number generator (RDRAND) in modern x86 
;  microprocessors. The generated numbers are normalized to the range 1.0 to 2.0 and then sorted to produce an ordered list. The 
;  goal is to practice techniques for handling random number generation, normalization, and sorting in x86-64 assembly.
;
; Development Information
;  OS: Ubuntu 22.04.4 LTS
;  Text Editor: Visual Studio Code
;  Tools: NASM, G++ compiler, GDB
;
; Current File Information
;  Name: utilities.inc
;  Language: x86-64 Assembly with Intel syntax
;  An include file to store macros for this program.
;
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


%macro GET_ARRAY_INPUT 3
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
    mov [arr], r13
    mov    rax, r15   
%endmacro


