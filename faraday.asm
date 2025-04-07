extern edison
%include "get_res.inc"  


STDOUT equ 1       ; Standard output
SYS_write equ 1    ; syscall number for write
SYS_exit equ 60



section .data
welcome_msg db "Welcome to Electricity brought to you by Michelle Pham.", 10
            db "This program will compute the resistance current flow in your direct circuit.", 10, 0
            db "", 10, 0
msgLen dq $ - welcome_msg 

driver_msg db "The driver received this number ", 0
driverLen dq $ - driver_msg 

zero_msg db "and will keep it until next semester.", 10
         db "A zero will be returned to the Operating System", 10, 0
zeroLen dq $ - zero_msg 


      ; Compute message length at assembly time

section .bss

section .text
global _start             ; Define the entry point

_start:

;     backupGPRs
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, welcome_msg        
    mov rdx, qword [msgLen] 
    syscall    

    ; ============== CALL EDISION =====================
    mov rax, 0
    call edison
    
    ; mov rax, SYS_write  
    ; mov rdi, STDOUT     
    ; mov rsi, driver_msg        
    ; mov rdx, qword [driverLen] 
    ; syscall  

    ; mov rax, SYS_write  
    ; mov rdi, STDOUT     
    ; mov rsi, zero_msg        
    ; mov rdx, qword [zeroLen] 
    ; syscall  
;     restoreGPRs

    mov rax, SYS_exit     ; syscall: exit
    xor rdi, rdi          ; status 0
    syscall               ; invoke kernel
