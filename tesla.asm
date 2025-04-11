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
;  Name: tesla.asm
;  Language: x86-64 Assembly (Intel syntax)
;  Max page width: 130 columns
;  Assemble: nasm -f elf64 -l tesla.lis -o tesla.o tesla.asm
;  Function Prototype: void input_values(double arr[], long sz)
;
;================================================================================================================================

%include "get_res.inc"
global tesla

section .data
one dq 1.0

section .bss
backup_storage    resb 832

section .text

tesla:
    backupGPRs
    backupNGPRs backup_storage

    xorpd xmm0, xmm0
    xor r15, r15    ; index counter set to 0
.loop_start:
    cmp r15, rsi    
    jge .loop_finish

    ; Move current index value into xmm1
    movsd xmm1, [rdi + r15*8] 

    ; Divivde current resistance by 1.0
    movsd xmm2, [one]
    divsd xmm2, xmm1 ; xmm2 = 1/R

    ; Add to the total resistance
    addsd xmm0, xmm2    ; xmm0 += 1/R

    ; Increment the index counter
    inc r15
    jmp .loop_start

.loop_finish:
    movsd xmm3, [one] ; xmm3 holds 1.0
    divsd xmm3, xmm0 ; xmm3 now holds total resistance = 1/R
    movsd xmm0, xmm3

    ; Save the result in the stack
    push qword 0
    movsd [rsp], xmm0

    restoreNGPRs backup_storage

    movsd xmm0, [rsp]
    pop rax

    restoreGPRs

    ret







