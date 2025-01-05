section .data
    msg:    db 'Enter N: ',10
    msgLen: equ $-msg
    msgNotValid: db 'invalid N', 10
    msgNotValidLen: equ $-msgNotValid
    msgResult: db 'Fibonacci: ',10
    msgResultLen: equ $-msgResult
    newline db 0xa  
section .bss
    N resb 4
    fib_dec resb 72
    temp_N resb 72
    temp_N_1 resb 72
    ; fib resd 100   ; Mảng chứa tối đa 100 số Fibonacci
section .text
    global _start
_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, msgLen
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, N
    mov edx, 3
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msgResult
    mov edx, msgResultLen
    int 0x80
    
    mov ecx, N
    xor eax, eax
    xor ebx, ebx
.convert_to_dec:
    mov bl, byte [ecx]
    cmp bl, 0
    je .check
    cmp bl,'0'
    jl .check
    cmp bl,'9'
    jg .check
    sub bl,'0'
    imul eax,eax,10
    add eax, ebx
    inc ecx
    jmp .convert_to_dec
    
.check:
    cmp eax, 100
    jg .not_valid
    cmp eax, 0
    jl .not_valid
    push eax
    call .fibonacci
    jmp .exit
    
.not_valid:
    mov eax, 4
    mov ebx, 1
    mov ecx, msgNotValid
    mov edx, msgNotValidLen
    int 0x80
    jmp .exit
    
.exit: 
    mov ebx, 0                               ; Exit status 0
    mov eax, 1                               ; syscall number for exit
    int 0x80                                 ; Make the syscall

.fibonacci:
    push ebp
    mov ebp, esp 
    mov ecx, [ebp+8]
    
    mov dword [temp_N], 0
    
    push ecx
    call .convert_to_string
    pop ecx
    
    cmp ecx, 0
    je .done
    
    mov dword [temp_N_1], 0
    mov dword [temp_N], 1
    mov eax, 1
    mov ebx, 0
    
    push ecx
    call .convert_to_string
    pop ecx
    
    sub ecx, 1
    cmp ecx, 0
    je .done
    
    push ecx
    call .convert_to_string
    pop ecx
    
    sub ecx, 1
.fibonacci_loop:
    cmp ecx, 0
    je .done
    mov edx, eax
    add eax, ebx
    mov ebx, edx
    sub ecx, 1
    mov [temp_N], eax
    push eax
    push ebx
    push ecx
    push edx
    call .convert_to_string
    pop edx
    pop ecx
    pop ebx
    pop eax
    jmp .fibonacci_loop
.done:
    pop ebp
    ret
.convert_to_string:
    push ebp
    mov ebp, esp
    mov ebx, temp_N + 72			        ; Start from the end of the buffer
    mov byte [ebx], 0			            ; Null-terminate the string
    dec ebx				                    ; Move one back
    mov eax, [temp_N]                       ; dividend 
    mov ecx, 10                             ; divisor
.convert_result:	
    xor edx, edx                              ; remainder
    div ecx                                   ; eax:ecx -> eax:quotient edx:remainder
    add dl, '0'                               ; convert to string               
    mov byte [ebx], dl                        ; store value
    dec ebx                                   ; move one back
    cmp eax, 0                                ; compare to 0
    jne .convert_result                        ; if != 0 move to convert_result
    inc ebx

    mov eax, 4
    mov ecx, ebx
    mov ebx, 1
    mov edx, 72
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    pop ebp
    ret
