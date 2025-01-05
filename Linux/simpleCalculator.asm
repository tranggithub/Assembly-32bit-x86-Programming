section .data
    msg:    db " Chọn phép tính:", 0xA          ; Ký tự xuống dòng (\n) là 0xA
            db "1. Cộng", 0xA
            db "2. Trừ", 0xA
            db "3. Nhân", 0xA
            db "4. Chia", 0xA,     ; Kết thúc chuỗi bằng 0
            db "Nhập lựa chọn: "
    msgLen: equ $-msg
    msgFirstNum: db 'Nhập số thứ nhất: ',0xa
    msgFirstNumLen: equ $-msgFirstNum
    msgSecondNum: db 'Nhập số thứ hai: ',0xa
    msgSecondNumLen: equ $-msgSecondNum
    msgResult: db 'Kết quả: '
    msgResultLen: equ $-msgResult
    newline db 0xa
    minus db 0x2d
    msgRemain: db ' dư '
    msgRemainLen: equ $-msgRemain   
section .bss
    N resb 2
    res resb 5
    num1 resb 5
    num2 resb 5
    remainder resb 5
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
    mov edx, 2
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msgFirstNum
    mov edx, msgFirstNumLen
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, num1
    mov edx, 4
    int 0x80
    
    push num1
    call StringToDec
    mov [num1], eax
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msgSecondNum
    mov edx, msgSecondNumLen
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, num2
    mov edx, 4
    int 0x80
    
    push num2
    call StringToDec
    mov [num2], eax
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msgResult
    mov edx, msgResultLen
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    ;String to Dec
    push N
    call StringToDec
    
    mov [N], eax
    cmp eax, 1
    je Addition
    
    cmp eax, 2
    je Subtraction
    
    cmp eax, 3
    je Multiplication
    
    cmp eax, 4
    je Division

exit:
    ;Print newline
    mov edx, 1                               ; Length of the result (1 character)
    mov ecx, newline                         ; Address of the result
    mov ebx, 1                               ; File descriptor 1 (stdout)
    mov eax, 4                               ; syscall number for write
    int 0x80
       
    mov ebx, 0                               ; Exit status 0
    mov eax, 1                               ; syscall number for exit
    int 0x80                                 ; Make the syscall

Addition:
    mov eax, [num1]
    add eax, [num2]
    
    mov [res], eax
    call DecToString
    
    jmp exit
    
Subtraction:
    mov eax, [num1]
    cmp eax, [num2]
    jl .Num1Smaller
    
    sub eax, [num2]
    
    mov [res], eax
    call DecToString
    
    jmp exit
    
.Num1Smaller:
    mov edx, 1                               ; Length of the result (1 character)
    mov ecx, minus                           ; Address of the result
    mov ebx, 1                               ; File descriptor 1 (stdout)
    mov eax, 4                               ; syscall number for write
    int 0x80
    
    mov eax, [num2]
    sub eax, [num1]
    
    mov [res], eax
    call DecToString
    
    jmp exit
    
Multiplication:
    mov eax, 1
    imul eax,[num1]
    imul eax,[num2]
    
    mov [res], eax
    call DecToString
    
    jmp exit
    
Division:
    xor edx, edx
    mov eax, [num1]
    mov ecx, [num2]
    div ecx
    mov [res], eax
    mov [remainder], edx
    
    call DecToString
    
    mov edx, msgRemainLen                    ; Length of the result (1 character)
    mov ecx, msgRemain                       ; Address of the result
    mov ebx, 1                               ; File descriptor 1 (stdout)
    mov eax, 4                               ; syscall number for write
    int 0x80
    
    mov eax, [remainder]
    mov [res], eax
    call DecToString
    
    jmp exit
    
StringToDec:
    push ebp
    mov ebp, esp
    
    mov ecx, [ebp+8]
    xor eax, eax 				;result
    xor ebx, ebx				
    
.convert_to_dec:
    mov bl, byte [ecx]
    cmp bl, 0
    je .done
    cmp bl, '0'
    jl .done
    cmp bl, '9'
    jg .done
    sub bl, '0'
    imul eax,eax,10
    add eax, ebx
    inc ecx
    jmp .convert_to_dec
.done:
    pop ebp
    ret
DecToString:
    push ebp
    mov ebp, esp
    mov ebx, res + 5			                    ; Start from the end of the buffer
    mov byte [ebx], 0			                    ; Null-terminate the string
    dec ebx				                            ; Move one back
    mov eax, [res]                            ; dividend 
    mov ecx, 10                               ; divisor
.convert_result:	
    xor edx, edx                              ; remainder
    div ecx                                   ; eax:ecx -> eax:quotient edx:remainder
    add dl, '0'                               ; convert to string               
    mov byte [ebx], dl                        ; store value
    dec ebx                                   ; move one back
    cmp eax, 0                                ; compare to 0
    jne .convert_result                        ; if != 0 move to convert_result
    inc ebx
  
    ; Printing the result
    mov edx, 5                               ; Length of the result (1 character)
    mov ecx, ebx                             ; Address of the result
    mov ebx, 1                               ; File descriptor 1 (stdout)
    mov eax, 4                               ; syscall number for write
    int 0x80
    
    pop ebp
    ret
