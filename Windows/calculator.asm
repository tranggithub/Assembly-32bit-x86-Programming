global _main
; Định nghĩa điểm bắt đầu của chương trình, để trình liên kết biết nơi bắt đầu thực thi.

extern _GetStdHandle@4 			; Lấy handle của các luồng chuẩn như `stdin`, `stdout`.
extern _ReadFile@20 			; Đọc dữ liệu từ file hoặc thiết bị.
extern _WriteFile@20 			; Ghi dữ liệu ra file hoặc thiết bị.
extern _ExitProcess@4 			; Thoát chương trình.

section .data
    msg:    db " Selections:", 0xA          ; Ký tự xuống dòng (\n) là 0xA
            db "1. Addition", 0xA
            db "2. Subtraction", 0xA
            db "3. Multiplication", 0xA
            db "4. Division", 0xA,     ; Kết thúc chuỗi bằng 0
            db "Your choice: "
    msgLen: equ $-msg
    msgFirstNum: db 'First num: ',0xa
    msgFirstNumLen: equ $-msgFirstNum
    msgSecondNum: db 'Second Num: ',0xa
    msgSecondNumLen: equ $-msgSecondNum
    msgResult: db 'Result: '
    msgResultLen: equ $-msgResult
    newline db 0xa
    minus db 0x2d
    msgRemain: db ' remain '
    msgRemainLen: equ $-msgRemain

section .bss
    N resb 3
    res resb 5
    num1 resb 5
    num2 resb 5
    remainder resb 5

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

    ;Read the value of N
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

    ;Print the first prompt message
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov ebx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    msgFirstNumLen
    push    msgFirstNum
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
	push 5						; Đẩy tham số `nNumberOfBytesToRead = 20` (số byte cần đọc) lên stack.
	mov eax, num1
	push eax					; Đẩy địa chỉ buffer lên stack làm tham số.
	push ebx					; Đẩy handle của `stdin` (lưu trong `ebx`) lên stack làm tham số.
	call _ReadFile@20			; Gọi hàm `ReadFile` để đọc dữ liệu từ `stdin` và lưu vào `_input_buf`.

    push num1
    call StringToDec
    mov [num1], eax

    ;Print the 2nd prompt message
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov ebx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    msgSecondNumLen
    push    msgSecondNum
    push    ebx
    call    _WriteFile@20

    ;Read the value of second num
    push -10					; Đẩy tham số `-10` lên stack (tương ứng với `STD_INPUT_HANDLE`), đại diện cho handle của `stdin`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdin`.
	mov ebx, eax				; Lưu handle của `stdin` vào thanh ghi `ebx` để dùng sau.

	; BOOL ReadFile(HANDLE hFile, LPVOID lpBuffer, DWORD nNumberOfBytesToRead, LPDWORD lpNumberOfBytesRead, LPOVERLAPPED lpOverlapped);
	push 0						; Đẩy tham số `lpOverlapped = 0` (không dùng overlapped I/O) lên stack.
	lea ecx, [ebp - 4]			; Tạo địa chỉ trỏ đến biến tạm thời (4 byte) trên stack, nơi lưu số byte đã đọc.
	push ecx					; Đẩy địa chỉ này lên stack làm tham số.
	push 5						; Đẩy tham số `nNumberOfBytesToRead = 20` (số byte cần đọc) lên stack.
	mov eax, num2
	push eax					; Đẩy địa chỉ buffer lên stack làm tham số.
	push ebx					; Đẩy handle của `stdin` (lưu trong `ebx`) lên stack làm tham số.
	call _ReadFile@20			; Gọi hàm `ReadFile` để đọc dữ liệu từ `stdin` và lưu vào `_input_buf`.

    push num2
    call StringToDec
    mov [num2], eax

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
	push 0						; Đẩy tham số `uExitCode = 0` lên stack (trạng thái thoát của chương trình).
	call _ExitProcess@4			; Gọi hàm `ExitProcess` để kết thúc chương trình với mã thoát 0.
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
    ;Print the first prompt message
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov edx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    1
    push    minus
    push    edx
    call    _WriteFile@20
    
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
    
    ;Print the first prompt message
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov edx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    msgRemainLen
    push    msgRemain
    push    edx
    call    _WriteFile@20
    
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
  
    ;Print the first prompt message
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov edx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    4
    push    ebx
    push    edx
    call    _WriteFile@20
    
    pop ebp
    ret
