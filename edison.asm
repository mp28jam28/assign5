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
;  Name: edison.asm
;  Language: x86-64 Assembly (Intel syntax)
;  Max page width: 130 columns
;  Assemble: nasm -f elf64 -l edison.lis -o edison.o edison.asm
;  Function Prototype: void input_values(double arr[], long sz)
;
;================================================================================================================================

STDIN equ 0       ; Standard input
STDOUT equ 1       ; Standard output
SYS_read equ 0     ; syscall number for read
SYS_write equ 1    ; syscall number for write

string_size equ 48

%include "get_res.inc"
extern isfloat
extern atof
extern tesla
extern int_to_str


section .data
name_prompt db "Please enter your full name: ", 0
career_prompt db "Please enter the career path you are following: ", 0
thankyou0 db "Thank you. We appreciate all ", 0
thankyou db "s", 
newline db "", 10
decimal db ".", 0
precision dq 100000000.0              ; For floating-point math
precision_int dq 100000000            ; Integer version for integer math

enter_resist      db "Your circuit has 3 sub-circuits. ", 10
         db "Please enter the resistance in ohms on each of the three sub-circuits separated by ws.", 10, 0

total_resist db "Thank you.", 10
         db "The total resistance of the full circuit is computed to be ", 0
         
emf_msg db " ohms.", 10, 10
        db "EMF is constant on every branch of any circuit.", 10
        db "Please enter the EMF of this circuit in volts: ", 0

compute_current db "Thank you.", 10, 10
                db "The current flowing in this circuit has been computed: "
last_thanks db " amps", 10
            db "Thank you ", 0

electricity db "for using this program Electricity.", 10
prompt_input    db "The last input was invalid and not entered into the array. Try again:", 10, 0

section .bss
user_name   resb string_size 
career_path resb string_size
arr resq 3
emf resq 1

section .text
global edison
edison:

    backupGPRs

    ; Print prompt for the user's full name
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, name_prompt        
    mov rdx, 30
    syscall   

    ; Take name input 
    mov rax, SYS_read
    mov rdi, STDIN
    mov rsi, user_name 
    mov rdx, 28 
    syscall

    ; Print prompt for the career path
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, career_prompt        
    mov rdx, 48 
    syscall 

    ; Take career path input 
    mov rax, SYS_read
    mov rdi, STDIN
    mov rsi, career_path 
    mov rdx, string_size 
    syscall

    ; Print prompt the first thank you
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, thankyou0        
    mov rdx, 30 
    syscall 

    ; Print career path
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, career_path        
    mov rdx, 20 
    syscall 

    ; Print newline
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, newline        
    mov rdx, 1 
    syscall 

    ; Print prompt for 3 resistance inputs
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, enter_resist        
    mov rdx, 121 
    syscall 

    ; Take input array of 3 resistances
    mov rax, 0 
    mov rdi, arr       ; array
    mov rsi, 3         ; count
    mov rdx, 32        ; string buffer size
    GET_INPUT rdi, rsi, rdx

    ; Call the tesla function to compute the resistance
    mov rax, 0 
    mov rdi, arr
    mov rsi, 3
    call tesla      
           
    ; Print the output message
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, total_resist        
    mov rdx, 70
    syscall  

    ; Convert the value from float to string and print the total resistance
    FTOA_PRINT

    ; Print prompt for user to enter the EMF
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, emf_msg        
    mov rdx, 103
    syscall 

    ; Take input for emf 
emf_loop: 
    mov rax, 0 
    mov rdi, emf       ; array
    mov rsi, 1         ; count
    mov rdx, 32        ; string buffer size
    GET_INPUT rdi, rsi, rdx

    ; Print that the current is being calculated
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, compute_current        
    mov rdx, 67 
    syscall 

    ; Compute the current
    movsd xmm10, [emf] ; Load EMF value into xmm10 e/r
    divsd xmm10, xmm5
    movsd xmm0, xmm10
    ; Convert the value from float to string and print the current
    FTOA_PRINT
    
    ; Print the last thanks
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, last_thanks        
    mov rdx, 17
    syscall     

    ; Print the user's name
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, user_name        
    mov rdx, 16 
    syscall 

    ; Print the final output
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, electricity        
    mov rdx, 36
    syscall 

    restoreGPRs
    ret