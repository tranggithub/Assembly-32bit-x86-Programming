section .data
msg1 db "Enter the first number : ",0xa    ; Message to prompt the user for the first number (0xa is newline)
len1 equ $ - msg1                          ; Length of the first message
msg2 db "Enter the 2nd number : ",0xa      ; Message to prompt the user for the second number
len2 equ $ - msg2                          ; Length of the second message
msg3 db "The sum is: "                     ; Message to display before printing the sum
len3 equ $- msg3                           ; Length of the third message
newline db 0xa                             ; Newline character
len_newline equ $ - newline

section .bss
num1 resb 12                                ; Reserve 2 bytes to store the first number (input as ASCII)
num2 resb 12                                ; Reserve 2 bytes to store the second number (input as ASCII)
res resb 12                                 ; Reserve 1 byte to store the result (sum as ASCII)

section .text
global _start                              ; Define the entry point (_start)
_start :
  ; Printing the first prompt message
  mov edx, len1                            ; Length of the message
  mov ecx, msg1                            ; Address of the message
  mov ebx, 1                               ; File descriptor 1 (stdout)
  mov eax, 4                               ; syscall number for write
  int 0x80                                 ; Make the syscall
  
  ; Reading user input for the first number
  mov edx, 11                               ; Number of bytes to read
  mov ecx, num1                            ; Address to store the input
  mov ebx, 0                               ; File descriptor 0 (stdin)
  mov eax, 3                               ; syscall number for read
  int 0x80                                 ; Make the syscall
    
  ; Printing the second prompt message
  mov edx, len2                            ; Length of the message
  mov ecx, msg2                            ; Address of the message
  mov ebx, 1                               ; File descriptor 1 (stdout)
  mov eax, 4                               ; syscall number for write
  int 0x80                                 ; Make the syscall
  
  ; Reading user input for the second number
  mov edx, 11                               ; Number of bytes to read
  mov ecx, num2                            ; Address to store the input
  mov ebx, 0                               ; File descriptor 0 (stdin)
  mov eax, 3                               ; syscall number for read
  int 0x80                                 ; Make the syscall
  
  ; Printing the result message
  mov edx, len3                            ; Length of the message
  mov ecx, msg3                            ; Address of the message
  mov ebx, 1                               ; File descriptor 1 (stdout)
  mov eax, 4                               ; syscall number for write
  int 0x80                                 ; Make the syscall
  
  ;Convert num1 from string to decimal
  mov ecx, num1                             ;store address of num1
  xor eax, eax                               ; store result
  xor ebx, ebx                              ;store the last digit
convert_num1_loop:
  mov bl, byte [ecx]                        ; store value of lowwer byte of ecx
  cmp bl, '0'                                 ; compare to '0'
  jl  convert_num2                          ; if <'0' move to convert_num2
  cmp bl, '9'                                 ; compare to '9'
  jg  convert_num2                          ; if >'9' move to convert_num2
  sub bl,'0'                                ; convert to decimal
  imul eax, eax, 10                      ; Multiply current result by 10
  add eax, ebx                            ;add last digit
  add ecx, 1                              ; move one next
  jmp convert_num1_loop

  ;Convert convert_num2 from string to decimal
convert_num2:
  mov [res], eax                           ; store value of fisrt number
  
  mov ecx, num2
  xor eax, eax                               
  xor ebx, ebx      
convert_num2_loop:
  mov bl, byte [ecx]                    
  cmp bl, '0'                
  jl  sum                                  
  cmp bl, '9'                                 
  jg  sum                                  
  sub bl,'0'                               
  imul eax, eax, 10                      
  add eax, ebx
  inc ecx
  jmp convert_num2_loop
  
sum:
  add [res], eax                            ;num1 + num2
  
  ;Convert the result to string
  mov ebx, res + 11			                    ; Start from the end of the buffer
  mov byte [ebx], 0			                    ; Null-terminate the string
  dec ebx				                            ; Move one back
  mov eax, [res]                            ; dividend 
  mov ecx, 10                               ; divisor
convert_result:	
  xor edx, edx                              ; remainder
  div ecx                                   ; eax:ecx -> eax:quotient edx:remainder
  add dl, '0'                               ; convert to string               
  mov byte [ebx], dl                        ; store value
  dec ebx                                   ; move one back
  cmp eax, 0                                ; compare to 0
  jne convert_result                        ; if != 0 move to convert_result
  inc ebx
  
  ; Printing the sum
  mov edx, 11                               ; Length of the result (1 character)
  mov ecx, ebx                             ; Address of the result
  mov ebx, 1                               ; File descriptor 1 (stdout)
  mov eax, 4                               ; syscall number for write
  int 0x80                                 ; Make the syscall
  
  ; Printing newline
  mov edx, 1                               ; Length of the result (1 character)
  mov ecx, newline                             ; Address of the result
  mov ebx, 1                               ; File descriptor 1 (stdout)
  mov eax, 4                               ; syscall number for write
  int 0x80                                 ; Make the syscall
  
  ; Exiting the program
  mov ebx, 0                               ; Exit status 0
  mov eax, 1                               ; syscall number for exit
  int 0x80
