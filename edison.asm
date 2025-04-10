STDIN equ 0       ; Standard input
STDOUT equ 1       ; Standard output

SYS_read equ 0     ; syscall number for read
SYS_write equ 1    ; syscall number for write
SYS_exit equ 60

string_size equ 48

%include "get_res.inc"
extern isfloat
extern atof
extern tesla
extern ftoa

section .data
name_prompt db "Please enter your full name: ", 0
career_prompt db "Please enter the career path you are following: ", 0
thankyou0 db "Thank you. We appreciate all ", 0
thankyou db "s", 
newline db "", 10

enter_resist      db "Your circuit has 3 sub-circuits. ", 10
         db "Please enter the resistance in ohms on each of the three sub-circuits separated by ws.", 10, 0

total_resist db "Thank you.", 10
         db "The total resistance of the full circuit is computed to be ", 0
         
emf_msg db " ohms.", 10, 10
        db "EMF is constant on every branch of any circuit.", 10
        db "Please enter the EMF of this circuit in volts: ", 0

compute_current db "Thank you.", 10, 10
                db "The current flowing in this circuit has been computed: "
last_thanks db "amps", 10, 10
            db "Thank you "

prompt_input    db "The last input was invalid and not entered into the array. Try again:", 10, 0

float_format    db "%s", 0
decimal db ".", 0             


section .bss
user_name   resb string_size 
career_path resb string_size
; resist_format resb 128
arr         resq 3
total_resistance resb 20

section .text
global edison
edison:

    backupGPRs
    ; Print prompt for the user's full name
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, name_prompt        
    mov rdx, 28 
    syscall   

    ; Take name input 
    mov rax, SYS_read
    mov rdi, STDIN
    mov rsi, user_name 
    mov rdx, 28 ; read count
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
    mov rdx, string_size ; read count
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

; =========== TAKE INPUT ARRAY OF 3 RESISTANCES DONE ==============
    mov rax, 0 
    mov rdi, arr       ; array
    mov rsi, 3         ; count
    mov rdx, 32        ; string buffer size
    GET_ARRAY_INPUT rdi, rsi, rdx

    
; ; =========== CALL TESLA TO COMPUTE_RESISTANCE ==============
    mov rax, 0 
    mov rdi, arr
    mov rsi, 3
    call tesla      
    call ftoa                ; convert float to string


; =======================
    ; Print total resistance
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, total_resist        
    mov rdx, 72
    syscall  

     mov rax, 1                    
    mov rdi, 1                    
    mov rsi, r14                  
    mov rdx, 10                   
    syscall

    mov rax, 1                
    mov rdi, 1                   
    mov rsi, decimal                   
    mov rdx, 1                   
    syscall           

    mov rax, 1                
    mov rdi, 1                   
    mov rsi, r12                   
    mov rdx, 10                   
    syscall


; =========== PRINT TOTAL RESISTANCE ==============
    

    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, total_resistance       
    mov rdx, 25
    syscall 


;     ; Print prompt for user to enter the EMF
;     mov rax, SYS_write  
;     mov rdi, STDOUT     
;     mov rsi, emf_msg        
;     mov rdx, 103
;     syscall 

; ; =========== TAKE INPUT FOR EMF ==============

;     ; Print current
;     mov rax, SYS_write  
;     mov rdi, STDOUT     
;     mov rsi, compute_current        
;     mov rdx, 67 
;     syscall 

; =========== CALL TESLA TO COMPUTE_CURRENT ==============
; =========== PRINT COMPUTED VALUE ==============

    ; Print the last thanks
    ; mov rax, SYS_write  
    ; mov rdi, STDOUT     
    ; mov rsi, last_thanks        
    ; mov rdx, 16 
    ; syscall     

    ; ; Print the user's name
    ; mov rax, SYS_write  
    ; mov rdi, STDOUT     
    ; mov rsi, user_name        
    ; mov rdx, 16 
    ; syscall 
; =========== PRINT REST OF THE MESSAGE ==============
    restoreGPRs
    ret