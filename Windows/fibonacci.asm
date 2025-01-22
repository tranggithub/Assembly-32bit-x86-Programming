global _main
; Định nghĩa điểm bắt đầu của chương trình, để trình liên kết biết nơi bắt đầu thực thi.

extern _GetStdHandle@4 			; Lấy handle của các luồng chuẩn như `stdin`, `stdout`.
extern _ReadFile@20 			; Đọc dữ liệu từ file hoặc thiết bị.
extern _WriteFile@20 			; Ghi dữ liệu ra file hoặc thiết bị.
extern _ExitProcess@4 			; Thoát chương trình.

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
    temp_N_1 resb 72                                ; Reserve 1 byte to store the result (sum as ASCII)

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
    push    msgLen
    push    msg
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
	push 3						; Đẩy tham số `nNumberOfBytesToRead = 20` (số byte cần đọc) lên stack.
	mov eax, N
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
    push    msgResultLen
    push    msgResult
    push    ebx
    call    _WriteFile@20

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
	push 0						; Đẩy tham số `uExitCode = 0` lên stack (trạng thái thoát của chương trình).
	call _ExitProcess@4			; Gọi hàm `ExitProcess` để kết thúc chương trình với mã thoát 0.

.fibonacci:
    push ebp
    mov ebp, esp 
    mov ecx, [ebp+8]
    
    call init
    
    push ecx
    call .convert_to_string
    pop ecx
    
    cmp ecx, 0
    je .done
    
    mov byte [temp_N_1], 0
    mov byte [temp_N], 1
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

    mov ebx, 1
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

    ;Print the second prompt message
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov edx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    72
    push    ebx
    push    edx
    call    _WriteFile@20
    
    ;Print the second prompt message
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov ebx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    1
    push    newline
    push    ebx
    call    _WriteFile@20
    
    pop ebp
    ret
init:
    push ebp
    mov ebp, esp
    
    mov esi, 72
.init_loop:
    cmp esi, 0
    je .init_end
    mov byte [temp_N + esi], 0
    mov byte [temp_N_1 + esi], 0
    dec esi
    jmp .init_loop
.init_end:

    pop ebp
    ret