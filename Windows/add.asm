global _main
; Định nghĩa điểm bắt đầu của chương trình, để trình liên kết biết nơi bắt đầu thực thi.

extern _GetStdHandle@4 			; Lấy handle của các luồng chuẩn như `stdin`, `stdout`.
extern _ReadFile@20 			; Đọc dữ liệu từ file hoặc thiết bị.
extern _WriteFile@20 			; Ghi dữ liệu ra file hoặc thiết bị.
extern _ExitProcess@4 			; Thoát chương trình.

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
_main:
	mov ebp, esp				; Thiết lập khung stack, lưu giá trị của `esp` vào `ebp`.
	sub esp, 8					; Dành chỗ trên stack để lưu hai biến tạm thời (mỗi biến 4 byte).

    ;Print the first prompt message
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov ebx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    len1
    push    msg1
    push    ebx
    call    _WriteFile@20

    ;Read the value of fisrt num
    push -10					; Đẩy tham số `-10` lên stack (tương ứng với `STD_INPUT_HANDLE`), đại diện cho handle của `stdin`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdin`.
	mov ebx, eax				; Lưu handle của `stdin` vào thanh ghi `ebx` để dùng sau.

	; BOOL ReadFile(HANDLE hFile, LPVOID lpBuffer, DWORD nNumberOfBytesToRead, LPDWORD lpNumberOfBytesRead, LPOVERLAPPED lpOverlapped);
	push 0						; Đẩy tham số `lpOverlapped = 0` (không dùng overlapped I/O) lên stack.
	lea ecx, [ebp - 4]			; Tạo địa chỉ trỏ đến biến tạm thời (4 byte) trên stack, nơi lưu số byte đã đọc.
	push ecx					; Đẩy địa chỉ này lên stack làm tham số.
	push 12						; Đẩy tham số `nNumberOfBytesToRead = 20` (số byte cần đọc) lên stack.
	mov eax, num1
	push eax					; Đẩy địa chỉ buffer lên stack làm tham số.
	push ebx					; Đẩy handle của `stdin` (lưu trong `ebx`) lên stack làm tham số.
	call _ReadFile@20			; Gọi hàm `ReadFile` để đọc dữ liệu từ `stdin` và lưu vào `_input_buf`.

    ;Print the second prompt message
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov ebx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    len2
    push    msg2
    push    ebx
    call    _WriteFile@20

    ;Read the value of 2nd num
    push -10					; Đẩy tham số `-10` lên stack (tương ứng với `STD_INPUT_HANDLE`), đại diện cho handle của `stdin`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdin`.
	mov ebx, eax				; Lưu handle của `stdin` vào thanh ghi `ebx` để dùng sau.

	; BOOL ReadFile(HANDLE hFile, LPVOID lpBuffer, DWORD nNumberOfBytesToRead, LPDWORD lpNumberOfBytesRead, LPOVERLAPPED lpOverlapped);
	push 0						; Đẩy tham số `lpOverlapped = 0` (không dùng overlapped I/O) lên stack.
	lea ecx, [ebp - 4]			; Tạo địa chỉ trỏ đến biến tạm thời (4 byte) trên stack, nơi lưu số byte đã đọc.
	push ecx					; Đẩy địa chỉ này lên stack làm tham số.
	push 12						; Đẩy tham số `nNumberOfBytesToRead = 20` (số byte cần đọc) lên stack.
	mov eax, num2
	push eax					; Đẩy địa chỉ buffer lên stack làm tham số.
	push ebx					; Đẩy handle của `stdin` (lưu trong `ebx`) lên stack làm tham số.
	call _ReadFile@20			; Gọi hàm `ReadFile` để đọc dữ liệu từ `stdin` và lưu vào `_input_buf`.

    ;Print the result prompt message
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov ebx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    len3
    push    msg3
    push    ebx
    call    _WriteFile@20

    ;Convert num1 from string to decimal
    mov ecx, num1                             ;store address of num1
    xor eax, eax                               ; store result
    xor ebx, ebx                              ;store the last digit
convert_num1_loop:
    mov bl, byte [ecx]                         ; store value of lowwer byte of ecx
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

    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov edx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

    ;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    12
    push    ebx
    push    edx
    call    _WriteFile@20

	push 0						; Đẩy tham số `uExitCode = 0` lên stack (trạng thái thoát của chương trình).
	call _ExitProcess@4			; Gọi hàm `ExitProcess` để kết thúc chương trình với mã thoát 0.