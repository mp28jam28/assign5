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
;  Name: faraday.asm
;  Language: x86-64 Assembly (Intel syntax)
;  Max page width: 130 columns
;  Assemble: nasm -f elf64 -l faraday.lis -o faraday.o faraday.asm
;  Function Prototype: void input_values(double arr[], long sz)
;
;================================================================================================================================

extern edison
extern int_to_str
%include "get_res.inc"  

STDOUT equ 1       ; Standard output
SYS_write equ 1    ; syscall number for write
SYS_exit equ 60

section .data
welcome_msg db "Welcome to Electricity brought to you by Michelle Pham.", 10
            db "This program will compute the resistance current flow in your direct circuit.", 10, 0
            db "", 10, 0

driver_msg db "The driver received this number ", 0

zero_msg db ", and will keep it until next semester.", 10
         db "A zero will be returned to the Operating System", 10, 0
decimal db ".", 0
precision dq 100000000.0              ; For floating-point math
precision_int dq 100000000

section .bss

section .text
global _start             ; Define the entry point

_start:

    backupGPRs

    ; Display the welcome message
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, welcome_msg        
    mov rdx, 137
    syscall    

    ; Call the edison function
    mov rax, 0
    call edison
    
    ; Display the driver message
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, driver_msg        
    mov rdx, 32
    syscall  

    ; Print the returned valaue
    FTOA_PRINT

    ; Display the final output message
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, zero_msg        
    mov rdx, 70 
    syscall  

    restoreGPRs
    mov rax, SYS_exit     ; syscall: exit
    xor rdi, rdi          ; status 0
    syscall               ; invoke kernel
