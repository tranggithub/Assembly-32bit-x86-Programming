; Import các thư viện cần thiết
include \masm32\include\masm32rt.inc
include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\comctl32.inc
include \masm32\include\msvcrt.inc

; Import các file macro và thư viện liên kết
include \masm32\macros\macros.asm
includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\comctl32.lib

.data
    ClassName db "Reverse text with WINAPI", 0          ; Tên lớp cửa sổ
    edit db "Edit", 0                        ; Tên cửa sổ chỉnh sửa
    button db "Button", 0                    ; Tên nút

.data?
    hInstance HINSTANCE ?                    ; Handle của instance
    lpCmdLine LPSTR ?                        ; Dòng lệnh được truyền vào
    inputEditHandle HWND ?                     ; Handle cho ô nhập liệu
    outputEditHandle HWND ?                    ; Handle cho ô hiển thị kết quả
    Buffer db 256 dup(?)                     ; Bộ đệm chứa chuỗi

.code

; Hàm WinMain: Entry point của ứng dụng
WinMain proc hInstan: HINSTANCE, hPrevInstance: HINSTANCE, CmdLine: LPSTR, nCmdShow: DWORD
    LOCAL wc: WNDCLASSEX                    ; Cấu trúc lớp cửa sổ
    LOCAL hwnd: HWND                        ; Handle của cửa sổ chính
    LOCAL Msg: MSG                          ; Cấu trúc thông điệp

    ; Cấu hình lớp cửa sổ
    mov wc.cbSize, sizeof WNDCLASSEX
    mov wc.style, 0
    mov eax, WndProc
    mov wc.lpfnWndProc, eax                 ; Hàm xử lý thông điệp
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    mov eax, hInstan
    mov wc.hInstance, eax                   ; Instance hiện tại
    push IDI_APPLICATION
    push NULL
    call LoadIcon                           ; Biểu tượng mặc định
    mov wc.hIcon, eax
    push IDC_ARROW
    push NULL
    call LoadCursor                         ; Con trỏ chuột mặc định
    mov wc.hCursor, eax
    mov wc.hbrBackground, COLOR_WINDOW+1    ; Màu nền cửa sổ
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, offset ClassName  ; Tên lớp cửa sổ
    push IDI_APPLICATION
    push NULL
    call LoadIcon
    mov wc.hIconSm, eax

    ; Đăng ký lớp cửa sổ
    lea eax, wc
    push eax
    call RegisterClassEx
    cmp eax, 0                              ; Nếu thất bại thì thoát
    je error

    ; Tạo cửa sổ chính
    push NULL
    push hInstance
    push NULL
    push NULL
    push 120                                ; Chiều cao cửa sổ
    push 560                                ; Chiều rộng cửa sổ
    push CW_USEDEFAULT                      ; Tọa độ X mặc định
    push CW_USEDEFAULT                      ; Tọa độ Y mặc định
    push WS_OVERLAPPEDWINDOW                ; Kiểu cửa sổ
    push offset ClassName                   ; Tên lớp cửa sổ
    push offset ClassName                   ; Tên cửa sổ
    push WS_EX_CLIENTEDGE                   ; Kiểu mở rộng
    call CreateWindowEx
    mov hwnd, eax
    cmp hwnd, NULL                          ; Nếu thất bại thì thoát
    jne showWindow
    jmp error

showWindow: ; Hiển thị cửa sổ
    push nCmdShow
    push hwnd
    call ShowWindow
    push hwnd
    call UpdateWindow

; Vòng lặp xử lý thông điệp
handleMessage:
    push 0
    push 0
    push NULL
    lea eax, Msg
    push eax
    call GetMessage
    cmp eax, 0
    jbe errorCode
    lea eax, Msg
    push eax
    call TranslateMessage
    lea eax, Msg
    push eax
    call DispatchMessage
    jmp handleMessage

errorCode:
    mov eax, Msg.wParam                    ; Trả về mã thoát
    ret

error:
    mov eax, 0                              ; Thoát với mã lỗi
    ret
WinMain endp

; Hàm reverse: Đảo ngược chuỗi
reverse proc data: LPSTR
    mov esi, data                          ; Con trỏ đầu chuỗi
    lea edi, [esi+len(esi)]                ; Con trỏ cuối chuỗi
    push esi
reverse_loop:
    mov al, [esi]                          ; Lấy ký tự đầu
    dec edi                                ; Lùi con trỏ cuối
    mov dl, [edi]                          ; Lấy ký tự cuối
    mov [esi], dl                          ; Đổi chỗ 2 ký tự
    mov [edi], al
    inc esi
    cmp esi, edi
    jb reverse_loop                                 ; Tiếp tục nếu chưa gặp nhau
    pop esi
    ret
reverse endp

; Hàm WndProc: Xử lý thông điệp của cửa sổ
WndProc proc hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM
    cmp msg, WM_CREATE
    jne handleMessage

    ; Tạo ô nhập liệu
    push NULL
    push NULL
    push 1
    push hwnd
    push 30
    push 500
    push 0
    push 20
    push WS_CHILD or WS_VISIBLE or WS_BORDER
    push NULL
    push offset edit
    push WS_EX_CLIENTEDGE
    call CreateWindowEx
    mov inputEditHandle, eax

    ; Tạo ô hiển thị kết quả
    push NULL
    push NULL
    push 2
    push hwnd
    push 30
    push 500
    push 20
    push 20
    push WS_CHILD or WS_VISIBLE or WS_BORDER or ES_READONLY
    push NULL
    push offset edit
    push WS_EX_CLIENTEDGE
    call CreateWindowEx
    mov outputEditHandle, eax
    ret

handleMessage:
    cmp msg, WM_COMMAND
    jne showWindow

    xor eax, eax
    mov eax, wParam
    cmp al, 01                             ; Nút nhấn "Button"
    jne error

    ; Lấy chuỗi từ ô nhập liệu
    lea eax, Buffer
    push eax
    mov eax, sizeof Buffer
    push eax
    push WM_GETTEXT
    push inputEditHandle
    call SendMessage

    ; Đảo ngược chuỗi và hiển thị
    lea eax, Buffer
    push eax
    call reverse
    push esi
    push NULL
    push WM_SETTEXT
    push outputEditHandle
    call SendMessage
    mov Buffer, 0
error:
    ret

showWindow:
    cmp msg, WM_CLOSE
    jne handleDestroyMess
    push hwnd
    call DestroyWindow
    ret

handleDestroyMess:
    cmp msg, WM_DESTROY
    jne handleOtherMess
    call PostQuitMessage
    ret

handleOtherMess:
    push lParam
    push wParam
    push msg
    push hwnd
    call DefWindowProc
    ret
WndProc endp

; Điểm bắt đầu của chương trình
start:
    push NULL
    call GetModuleHandle                   ; Lấy handle của instance
    mov hInstance, eax
    call GetCommandLine                    ; Lấy dòng lệnh
    mov lpCmdLine, eax
    push SW_SHOWDEFAULT
    push lpCmdLine
    push NULL
    push hInstance
    call WinMain                           ; Gọi hàm WinMain
    push eax
    call ExitProcess                       ; Thoát chương trình
end start