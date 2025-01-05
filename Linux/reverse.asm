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
	global _start

_start:
  ; In thông báo yêu cầu nhập xâu
  mov eax, 4              ; syscall: write
  mov ebx, 1              ; stdout
  mov ecx, msg            ; địa chỉ thông báo
  mov edx, msgLen             ; chiều dài thông báo
  int 0x80

  ; Đọc xâu từ người dùng
  mov eax, 3              ; syscall: read
  mov ebx, 0              ; stdin
  mov ecx, input          ; nơi lưu xâu nhập vào
  mov edx, 256            ; số lượng byte tối đa để đọc
  int 0x80
  
  ; Lưu chiều dài xâu (trừ ký tự xuống dòng nếu có)
  mov ecx, eax            ; eax chứa số ký tự đọc được
  mov [len], cl
  dec byte [len]          ; bỏ ký tự xuống dòng nếu có

  ; Gọi procedure đảo ngược xâu
  push input          ; địa chỉ xâu
  call reverse

  ; In kết quả
  mov eax, 4              ; syscall: write
  mov ebx, 1              ; stdout
  mov ecx, result         ; thông báo kết quả
  mov edx, resultLen             ; chiều dài thông báo
  int 0x80

  mov eax, 4              ; syscall: write
  mov ebx, 1              ; stdout
  mov ecx, input          ; địa chỉ xâu đảo ngược
  mov edx, [len]          ; chiều dài xâu đã nhập
  int 0x80

  ; In newline
  mov eax, 4              ; syscall: write
  mov ebx, 1              ; stdout
  mov ecx, newline        ; xuống dòng
  mov edx, 1              ; 1 ký tự
  int 0x80

  ; Thoát chương trình
  mov eax, 1              ; syscall: exit
  xor ebx, ebx            ; trả về 0
  int 0x80

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
