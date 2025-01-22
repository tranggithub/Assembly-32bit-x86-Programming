global _main
; Định nghĩa điểm bắt đầu của chương trình, để trình liên kết biết nơi bắt đầu thực thi.

extern _GetStdHandle@4 			; Lấy handle của các luồng chuẩn như `stdin`, `stdout`.
extern _ReadFile@20 			; Đọc dữ liệu từ file hoặc thiết bị.
extern _WriteFile@20 			; Ghi dữ liệu ra file hoặc thiết bị.
extern _ExitProcess@4 			; Thoát chương trình.

section .bss
_input_buf: resb 20 			; Định nghĩa một vùng bộ nhớ để lưu trữ dữ liệu nhập từ người dùng.
_input_len: resb 1 				; Lưu độ dài đọc được
section .text
_main:
	mov ebp, esp				; Thiết lập khung stack, lưu giá trị của `esp` vào `ebp`.
	sub esp, 8					; Dành chỗ trên stack để lưu hai biến tạm thời (mỗi biến 4 byte).

	push -10					; Đẩy tham số `-10` lên stack (tương ứng với `STD_INPUT_HANDLE`), đại diện cho handle của `stdin`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdin`.
	mov ebx, eax				; Lưu handle của `stdin` vào thanh ghi `ebx` để dùng sau.

	; BOOL ReadFile(HANDLE hFile, LPVOID lpBuffer, DWORD nNumberOfBytesToRead, LPDWORD lpNumberOfBytesRead, LPOVERLAPPED lpOverlapped);
	push 0						; Đẩy tham số `lpOverlapped = 0` (không dùng overlapped I/O) lên stack.
	;lea ecx, [ebp - 4]			; Tạo địa chỉ trỏ đến biến tạm thời (4 byte) trên stack, nơi lưu số byte đã đọc.
	mov ecx, _input_len
	push ecx					; Đẩy địa chỉ này lên stack làm tham số.
	push 20						; Đẩy tham số `nNumberOfBytesToRead = 20` (số byte cần đọc) lên stack.
	lea eax, [_input_buf]		; Tạo địa chỉ trỏ đến buffer `_input_buf` để chứa dữ liệu nhập.
	push eax					; Đẩy địa chỉ buffer lên stack làm tham số.
	push ebx					; Đẩy handle của `stdin` (lưu trong `ebx`) lên stack làm tham số.
	call _ReadFile@20			; Gọi hàm `ReadFile` để đọc dữ liệu từ `stdin` và lưu vào `_input_buf`.

	push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov ebx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	push 0						; Đẩy tham số `lpOverlapped = 0` (không dùng overlapped I/O) lên stack.
	lea ecx, [ebp - 8]			; Tạo địa chỉ trỏ đến biến tạm thời (4 byte) trên stack, nơi lưu số byte đã ghi.
	push ecx					; Đẩy địa chỉ này lên stack làm tham số.
	;mov edx, [ebp - 4]			; Lấy số byte đã đọc từ biến tạm thời (lưu tại `[ebp - 4]`) vào thanh ghi `edx`.
	mov edx, [_input_len]
	push edx					; Đẩy số byte cần ghi (lấy từ `edx`) lên stack làm tham số.
	lea eax, [_input_buf]		; Tạo địa chỉ trỏ đến buffer `_input_buf` chứa dữ liệu cần ghi.
	push eax					; Đẩy địa chỉ buffer lên stack làm tham số.
	push ebx					; Đẩy handle của `stdout` (lưu trong `ebx`) lên stack làm tham số.
	call _WriteFile@20			; Gọi hàm `WriteFile` để ghi dữ liệu từ `_input_buf` ra `stdout`.

	push 0						; Đẩy tham số `uExitCode = 0` lên stack (trạng thái thoát của chương trình).
	call _ExitProcess@4			; Gọi hàm `ExitProcess` để kết thúc chương trình với mã thoát 0.