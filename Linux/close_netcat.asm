;    nasm -felf64 close_netcat.asm && gcc -no-pie close_netcat.o && ./a.out
;
    extern strstr
    extern printf
    extern atoi
section .data
    path db "/proc", 0                 ; Đường dẫn thư mục
    buf  times 10240 db 0               ; Bộ đệm để đọc nội dung thư mục
    msg_name db "Name: ", 0
    newline db 10, 0
    cmd_path times 50 db 0		; duong dan den /proc/<pid>/cmd
    cmd_buf  times 256 db 0               ; Bộ đệm để đọc nội dung cmdline
    nc db "nc", 0
    found_tx db "Found",10
    
    msg db "Loop after 10s...", 0xA, 0 ; Thông báo cho mỗi vòng lặp
    msg_len equ $ - msg                       ; Độ dài của thông báo

    delay_time:
    		dq 10                       ; 10 giây (giây)
    		dq 0                        ; 0 nano giây

section .bss
    fd resq 1                          ; File descriptor của thư mục
    bytes_read resq 1                  ; Số byte đọc được
    len resb 8
    cmd_addr resb 8
    pid resq 1

section .text
    global main
main:
.loop:
    
    call scan_and_kill_nc
    
    ; Chờ 10 giây
    mov rax, 35                 ; syscall: nanosleep
    lea rdi, [rel delay_time]   ; Cấu trúc chỉ định thời gian chờ
    xor rsi, rsi                ; Null pointer (không cần xử lý lỗi)
    syscall                     ; Gọi hệ thống
    
    ; Ghi thông báo ra màn hình
    mov rax, 1                  ; syscall: write
    mov rdi, 1                  ; file descriptor: stdout
    mov rsi, msg            ; Địa chỉ thông báo
    mov rdx, msg_len        ; Độ dài thông báo
    syscall                     ; Gọi hệ thống

    ; Quay lại vòng lặp
    jmp .loop
    
    ; Thoát chương trình
    mov rax, 60                       ; syscall: exit
    xor rdi, rdi                      ; Exit code 0
    syscall

scan_and_kill_nc:
    push rbp
    mov rbp, rsp
    
    ; Mở thư mục bằng syscall openat
    mov rax, 257                      ; syscall: openat
    mov rdi, -100                     ; AT_FDCWD
    lea rsi, [rel path]               ; Đường dẫn thư mục
    xor rdx, rdx                      ; O_RDONLY
    xor r10, r10                      ; flags
    syscall                           ; Thực thi syscall
    mov [fd], rax                     ; Lưu file descriptor

    ; Kiểm tra lỗi khi mở thư mục
    cmp rax, 0
    jl exit                          ; Nếu lỗi thì thoát

read_dir:
    ; Gọi syscall getdents64
    mov rax, 217                      ; syscall: getdents64
    mov rdi, [fd]                     ; File descriptor
    lea rsi, [rel buf]                ; Bộ đệm
    mov rdx, 10240                     ; Kích thước bộ đệm
    syscall                           ; Thực thi syscall
    mov [bytes_read], rax             ; Lưu số byte đọc được

    ; Kiểm tra lỗi hoặc kết thúc
    cmp rax, 0
    jle close_fd                      ; Nếu lỗi hoặc kết thúc thì đóng file descriptor

    ; Lặp qua các entry trong thư mục
    lea rsi, [rel buf]                ; Con trỏ tới đầu bộ đệm
next_entry:
    push rsi
    
    ; In tên của entry
    mov rax, 1                        ; syscall: write
    mov rdi, 1                        ; stdout
    lea rsi, [rel msg_name]           ; In chuỗi "Name: "
    mov rdx, 6
    syscall                           ; Thực thi syscall
    
    pop rsi
    push rsi
    ; In d_name
    mov rax, 1                        ; syscall: write
    mov rdi, 1                        ; stdout
    movzx rdx, word [rsi + 16]        ; d_reclen (2 bytes tại offset 4)
    sub rdx, 19			      ; Sử dụng d_reclen để xác định độ dài
    mov [len], rdx
    mov rcx, rsi
    add rcx, 19
    lea rsi, [rsi + 19]               ; d_name bắt đầu tại offset 19    
    mov qword [cmd_addr], rcx
    syscall                           ; Thực thi syscall
    
    mov cl, byte [rsi]	      ;Kiem tra xem co phai so khong
    cmp cl, 0x30
    jl skip_pid
    cmp cl, 0x39
    jg skip_pid
    
    ; Xuống dòng
    mov rax, 1                        ; syscall: write
    mov rdi, 1                        ; stdout
    lea rsi, [rel newline]            ; In newline
    mov rdx, 1
    syscall 
    
    call cal_cmd_path
    ; cmd
    mov rax, 1                        ; syscall: write
    mov rdi, 1                        ; stdout
    mov rsi, cmd_path                 ; In newline
    mov rdx, 20
    syscall                           ; Thực thi syscall
    
    call check_nc

skip_pid:
    ; Xuống dòng
    mov rax, 1                        ; syscall: write
    mov rdi, 1                        ; stdout
    lea rsi, [rel newline]            ; In newline
    mov rdx, 1
    syscall                           ; Thực thi syscall

    
    pop rsi
    ; Đọc d_reclen (kích thước entry)
    movzx rdx, word [rsi + 16]         ; d_reclen (2 bytes tại offset 4)
    add rsi, rdx                      ; Di chuyển đến entry tiếp theo
    
    ; Kiểm tra xem đã đến cuối bộ đệm chưa
    mov rax, buf
    add rax, [bytes_read]  
    cmp rsi, rax
    jl next_entry                     ; Nếu chưa thì tiếp tục

    ; Đọc tiếp nội dung thư mục
    ;jmp read_dir

close_fd:
    ; Đóng file descriptor
    mov rax, 3                        ; syscall: close
    mov rdi, [fd]                     ; File descriptor
    syscall                           ; Thực thi syscall

exit:
    pop rbp
    ret


cal_cmd_path: 
    push rbp
    mov rbp, rsp
    
    ;push cmd_addr
    ;push qword [len]
    ;call little_to_big_endian
    ;pop rbx
    ;pop rbx
    
    ;push rax
    ;push qword [len]
    ;call StringToDec
    ;pop rbx
    ;pop rbx
    
    mov rdi, qword [cmd_addr]
    call atoi
    
    mov qword [pid], rax
   
    mov byte [cmd_path], 0x2f		; /
    mov byte [cmd_path + 1], 0x70	; p
    mov byte [cmd_path + 2], 0x72	; r
    mov byte [cmd_path + 3], 0x6f	; o
    mov byte [cmd_path + 4], 0x63	; c
    mov byte [cmd_path + 5], 0x2f	; /
    
    xor rsi, rsi  
pid_loop:    
    cmp rsi, qword [len]
    je pid_loop_exit
    
    mov rax, rsi
    add rax, 6
    
    mov rcx, [cmd_addr]
    add rcx, rsi
    mov bl, byte [rcx]	
    mov byte [cmd_path + rax], bl
    
    mov bl, byte [rcx - 1]
    cmp bl, 0
    je pid_loop_exit
        
    inc rsi
    jmp pid_loop
pid_loop_exit:
    add rsi, 5
    mov byte [cmd_path + rsi], 0x2f	; /
    mov byte [cmd_path + rsi + 1], 0x63	; c
    mov byte [cmd_path + rsi + 2], 0x6d	; m
    mov byte [cmd_path + rsi + 3], 0x64	; d
    mov byte [cmd_path + rsi + 4], 0x6c	; l
    mov byte [cmd_path + rsi + 5], 0x69	; i
    mov byte [cmd_path + rsi + 6], 0x6e	; n
    mov byte [cmd_path + rsi + 7], 0x65	; e

    pop rbp
    ret
    
StringToDec:
    push rbp
    mov rbp, rsp
    
    mov rcx, [rbp + 16]		;len
    mov rdx, [rbp + 24]		;addr
    
    dec rcx
    xor rax, rax
stringtodec_loop:
    cmp rcx, 0
    jl stringtodec_exit
    
    imul rax,rax,10
    xor rbx, rbx
    mov bl, byte [rdx + rcx]
    
    cmp bl, 0
    je stringtodec_skip
    
    sub bl, '0'
    add rax, rbx
    
stringtodec_skip:    
    dec rcx
    jmp stringtodec_loop
stringtodec_exit:   
    
.done:
    pop rbp
    ret

little_to_big_endian:
    push rbp
    mov rbp, rsp

    ;dia chi cua chuoi
    mov rbx, [rbp + 24]
    ;kich thuoc muon chuyen sang little endian
    mov rsi, [rbp + 16]
    dec rsi             
    xor rax, rax

little_to_big_endian_loop:
    
    cmp rsi, 0
    jl little_to_big_endian_exit

    shl rax, 8
    mov al, byte [rbx + rsi]

    dec rsi
    jmp little_to_big_endian_loop

little_to_big_endian_exit:
    pop rbp
    ret

    
check_nc:
    push rbp
    mov rbp, rsp
    
    ; Mở file cmdline
    mov rax, 2                  ; syscall open
    lea rdi, [rel cmd_path]  ; Đường dẫn /proc/<pid>/cmdline
    xor rsi, rsi                ; O_RDONLY = 0
    xor rdx, rdx                ; flags = 0
    syscall
    mov rdi, rax                ; Lưu file descriptor
    push rdi

    ; Đọc nội dung cmdline
    mov rax, 0                  ; syscall read
    lea rsi, [rel cmd_buf]  ; Buffer đọc cmdline
    mov rdx, 256                ; Số byte đọc tối đa
    syscall
    test rax, rax
    jle close_file              ; Nếu không đọc được, đóng file
            
    lea rdi, [rel cmd_buf]
    lea rsi, [rel nc]         ; rsi = "nc"
    call strstr
    test rax, rax
    jz not_found
found:
    ; Xuống dòng
    mov rax, 1                        ; syscall: write
    mov rdi, 1                        ; stdout
    lea rsi, [rel newline]            ; In newline
    mov rdx, 1
    syscall 

    ;In danh dau tim thay
    mov rax, 1                        ; syscall: write
    mov rdi, 1                        ; stdout
    lea rsi, [rel found_tx]           ; In chuỗi "Found"
    mov rdx, 6
    syscall                           ; Thực thi syscall
    
    call kill_pid
    
    mov rax, 1
    jmp check_done
not_found:
    xor rax, rax
check_done:


close_file:
    ; Đóng file
    pop rdi
    mov rax, 3                  ; syscall close
    mov rdi, rdi                ; File descriptor
    syscall
    
    pop rbp
    ret

kill_pid:
    push rbp
    mov rbp, rsp
    
    ; Gửi tín hiệu SIGKILL (9) đến tiến trình
    mov rdi, qword [pid]
   
    mov rax, 62                               ; syscall: kill
    mov rsi, 9                                ; SIGKILL
    syscall
    
    pop rbp
    ret
