global _main
; Định nghĩa điểm bắt đầu của chương trình, để trình liên kết biết nơi bắt đầu thực thi.

extern _GetStdHandle@4 			; Lấy handle của các luồng chuẩn như `stdin`, `stdout`.
extern _ReadFile@20 			; Đọc dữ liệu từ file hoặc thiết bị.
extern _WriteFile@20 			; Ghi dữ liệu ra file hoặc thiết bị.
extern _ExitProcess@4 			; Thoát chương trình.

section .data
    msg:     db 'Enter a string (max 256 characters): ', 10    ; 'Hello, World!' plus a linefeed character
	msgLen:  equ $-msg             ; Length of the 'Hello world!' string
    result: db "Reversed string: ", 10
    resultLen: equ $-result
    newline db 0xA, 10

section .bss
    input resb 257              ; Lưu chiều dài xâu nhập vào
    len resb 1              ; Lưu chiều dài xâu nhập vào

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
	push 256						; Đẩy tham số `nNumberOfBytesToRead = 20` (số byte cần đọc) lên stack.
	mov eax, input
	push eax					; Đẩy địa chỉ buffer lên stack làm tham số.
	push ebx					; Đẩy handle của `stdin` (lưu trong `ebx`) lên stack làm tham số.
	call _ReadFile@20			; Gọi hàm `ReadFile` để đọc dữ liệu từ `stdin` và lưu vào `_input_buf`.

    ; Lưu chiều dài xâu (trừ ký tự xuống dòng nếu có)
    mov ecx, [ebp - 4]            ; eax chứa số ký tự đọc được
    mov [len], cl
    dec byte [len]          ; bỏ ký tự xuống dòng nếu có

    ; Gọi procedure đảo ngược xâu
    push input          ; địa chỉ xâu
    call reverse

    ;Print the result prompt message
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov ebx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    resultLen
    push    result
    push    ebx
    call    _WriteFile@20

    ;Print the result
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov ebx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    mov     ecx, [len]
    push    ecx
    push    input
    push    ebx
    call    _WriteFile@20

	push 0						; Đẩy tham số `uExitCode = 0` lên stack (trạng thái thoát của chương trình).
	call _ExitProcess@4			; Gọi hàm `ExitProcess` để kết thúc chương trình với mã thoát 0.

; Procedure để đảo ngược xâu
reverse:
    push ebp                ; lưu lại base pointer
    mov ebp, esp            ; thiết lập stack frame

    mov esi, [ebp+8]        ; địa chỉ xâu truyền vào
    mov ecx, [len]          ; chiều dài xâu
    dec ecx                 ; last index
    xor edi, edi            ; index bắt đầu

.loop:
    cmp edi, ecx            ; nếu gặp ở giữa thì dừng
    jge .done
    ; Đổi chỗ str[edi] và str[ecx]
    mov al, [esi + edi]     ; al = str[edi]
    mov bl, [esi + ecx]     ; bl = str[ecx]
    mov [esi + edi], bl     ; str[edi] = str[ecx]
    mov [esi + ecx], al     ; str[ecx] = str[edi]
    ; Cập nhật chỉ số
    inc edi
    dec ecx
    jmp .loop

.done:
    pop ebp                 ; khôi phục base pointer
    ret