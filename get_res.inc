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

;Declarations
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

;Print out author information and calculate the area using Huron's formula
%macro    authorInfo 0
  mov    rax, 0
  mov    rdi, author_info
  call    printf
%endmacro