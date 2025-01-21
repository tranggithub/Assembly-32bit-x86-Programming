;  Set up inside Visual Studio: Properties in Project -> MASM

GetStdHandle            proto               ; Writes I/O handles
WriteConsoleA           proto               ; Writes to Command Window
ReadConsoleA            proto               ; Reads character input from the console input buffer and removes it from the buffer
ExitProcess             proto               ; Returns CPU Control to Windows
SetConsoleTextAttribute proto               ; Sets colors for text and background
EnumWindows             proto
GetWindowTextW          proto
Console                 equ     -11         ; The standard output device code
GetWindowThreadProcessId    proto
GetClassNameA           proto
PostMessageA            proto
Sleep                   proto
                                            ; https://docs.microsoft.com/en-us/windows/console/getstdhandle





.code                                       ; Marks the start of Code section
main        proc                            ; Start of procedure named 'main'
            sub         rbp, 40             ; Reserve 40 bytes of Shadow Space

main_loop:
            lea         rcx, FindAndCloseBrowser
            mov         rdx, 0
            call        EnumWindows


            ; Gets the STD output handle
            mov         rcx, Console        ; Dword nStdHandle:
            call        GetStdHandle        ; Returned handle is in RAX
            mov         stdout, rax         ; stores the handle for later use

            ; Welcome Message
            mov         rcx, stdout                 ; hConsoleOutput
            lea         rdx, waitMsg             ; *lpBuffer
            mov         r8, 12     ; nNumberOfCharsToWrite
            lea         r9, nBytesWritten           ; lpNumberOfCharsWritten
            call        WriteConsoleA

            mov         rcx, [sleep_time]
            call        Sleep

jmp         main_loop

            ; Exit process
            mov         rcx, 0              ; Set the Exit Code to 0
            add         rbp, 40             ; Release 40 bytes of Shadow Space
            call        ExitProcess         ; Hand back the CPU control to Windows
main        endp                            ; End of procedure named 'main'

FindAndCloseBrowser proc hwnd: QWORD, lParam: QWORD
            sub         rbp, 40             ; Reserve 40 bytes of Shadow Space

            push rax
            push rbx
            push rcx
            push rdx


            mov         rcx, hwnd
            lea         rdx, titleBuffer
            mov         r8d, 255
            
            call        GetClassNameA

            mov         len, rax

            lea         rbx, Browser_array

browser_loop:
            cmp         byte ptr [rbx],0
            je          browser_loop_end
            mov         rsi, [rbx]
            lea         rdi, titleBuffer

            mov         rcx, [rbx + 8]
            sub         rcx, rsi

            ; compare until equal:
            repe    cmpsb
            jnz     not_equal

            ; Gets the STD output handle
            mov         rcx, Console        ; Dword nStdHandle:
            call        GetStdHandle        ; Returned handle is in RAX
            mov         stdout, rax         ; stores the handle for later use

            ; Welcome Message
            mov         rcx, stdout                 ; hConsoleOutput
            lea         rdx, titleBuffer             ; *lpBuffer
            mov         r8, 256     ; nNumberOfCharsToWrite
            lea         r9, nBytesWritten           ; lpNumberOfCharsWritten
            call        WriteConsoleA

            ; New line
            mov         rcx, stdout                 ; hConsoleOutput
            lea         rdx, newline             ; *lpBuffer
            mov         r8, 2     ; nNumberOfCharsToWrite
            lea         r9, nBytesWritten           ; lpNumberOfCharsWritten
            call        WriteConsoleA

            mov         rcx, hwnd
            mov         rdx, 10h        ;WM_CLOSE
            mov         r8d, 0
            mov         r9d, 0
            call        PostMessageA
not_equal:
            add         rbx, 8
            jmp         browser_loop
browser_loop_end:
            ;xor rax, rax

            pop rdx
            pop rcx
            pop rbx
            pop rax

            add         rbp, 40
            ret
FindAndCloseBrowser endp

.data                                                   ; Marks the start of Data section
stdout              qword       ?                       ; Reserves space for handel to stdOut
nBytesWritten       qword       ?                       ; Reserved space for number of bytes written
waitMsg             byte        "Wait 5s... ", 0Ah, 0Dh     ; First message written to the screen
titleBuffer         db          256 dup (0)
newline             byte        0Ah, 0
len                 qword       ?
sleep_time          qword       5000
Chrome              db          "Chrome_WidgetWin_1"
Firefox             db          "MozillaWindowClass" ;Mozilla Firefox
Edge                db          "ApplicationFrameWindow" ; Microsoft Edge
Opera               db          "OperaWindowClass" ; Opera
Explorer            db          "IEFrame" ; Internet Explorer
end_browser         qword       0

Browser_array       qword       Chrome,Firefox,Edge,Opera,Explorer,end_browser
                                end                     ; End of program
