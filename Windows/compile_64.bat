@echo off
if "%~1"=="" (
    echo "Vui lòng cung cấp tên chương trình (không cần đuôi)"
    echo "Sử dụng: compile64.bat <ten_chuong_trinh>"
    pause
    exit /b 1
)

set PROGRAM_NAME=%~1

rem Biên dịch assembly bằng NASM (64-bit)
nasm -f win64 %PROGRAM_NAME%.asm -o %PROGRAM_NAME%.obj
if %ERRORLEVEL% neq 0 (
    echo Lỗi trong quá trình biên dịch assembly!
    pause
    exit /b %ERRORLEVEL%
)

rem Liên kết bằng GCC để tạo file .exe (64-bit)
gcc %PROGRAM_NAME%.obj -o %PROGRAM_NAME%.exe
if %ERRORLEVEL% neq 0 (
    echo Lỗi trong quá trình liên kết!
    pause
    exit /b %ERRORLEVEL%
)

echo Success: %PROGRAM_NAME%.exe
pause