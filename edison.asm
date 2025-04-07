STDIN equ 0       ; Standard input
STDOUT equ 1       ; Standard output

SYS_read equ 0     ; syscall number for read
SYS_write equ 1    ; syscall number for write
SYS_exit equ 60

string_size equ 48

%include "get_res.inc"
extern isfloat
extern atof

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

float_format    db "%s", 0


section .bss
user_name   resb string_size 
career_path resb string_size
; resist_format resb 128
arr         resq 3
total_resistance resb 10

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

; =========== TAKE INPUT ARRAY OF 3 RESISTANCES ==============
    mov    rax, 0  
    mov    rdi, arr     ; rdi will hold the array
    mov    rsi, 3      ; rsi holds # of cells in array
    xor    r15, r15     ; set r15 = 0

    mov    r13, rdi
    mov    r14, rsi    ;r14 holds the number of cells in the array, r10

;===========
loop_start:
    cmp r15, r14
    jge loop_end ; jump if r15 is greater than rsi

    push    qword 0    ;need two pushes, two pops since extern functions like scanf needs 16bit
    push    qword 0
    mov    rax, SYS_read
    mov    rdi, STDIN
    mov    rsi, rsp
    mov rdx, string_size ; read count
    syscall

    ; Convert the inputted string into a real double.
    mov    rax, 0
    mov    rdi, rsp
    call    atof
    movsd    xmm15, xmm0

    movsd    qword[r13+8*r15], xmm15

    inc    r15

    pop    rax
    pop    rax

    jmp    loop_start

loop_end:
    mov    rax, r15
    mov    r15, rax
    
; =========== CALL TESLA TO COMPUTE_RESISTANCE ==============
    ; mov rax, 0 
    ; mov rdi, arr
    ; mov, rsi 3
    ; call tesla


; =======================
    ; Print total resistance
    mov rax, SYS_write  
    mov rdi, STDOUT     
    mov rsi, total_resist        
    mov rdx, 78
    syscall 


; =========== PRINT TOTAL RESISTANCE ==============


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