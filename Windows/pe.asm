global _main
; Định nghĩa điểm bắt đầu của chương trình, để trình liên kết biết nơi bắt đầu thực thi.

extern _GetStdHandle@4 			; Lấy handle của các luồng chuẩn như `stdin`, `stdout`.
extern _ReadFile@20 			; Đọc dữ liệu từ file hoặc thiết bị.
extern _WriteFile@20 			; Ghi dữ liệu ra file hoặc thiết bị.
extern _ExitProcess@4 			; Thoát chương trình.
extern _CreateFileA@28
extern _printf

section .data
    msg:     db 'Enter a string file path: ', 10    ; 'Hello, World!' plus a linefeed character
	msgLen:  equ $-msg             ; Length of the 'Hello world!' string
    ;filePath db "C:\Windows\notepad.exe" ; Đường dẫn file PE
    ;filePath db "C:\Windows\System32\msvcrt.dll" ; Đường dẫn file PE
    filePath db "C:\Windows\System32\calc.exe" ; Đường dẫn file PE
    
	fileHandle dd 0

	err_not_pe db "Error: Not PE file", 10, 0
    err_open db "Error: Cannot open file", 10, 0
    err_read db "Error: Cannot read file", 10, 0

	GENERIC_READ equ 0x80000000
	OPEN_EXISTING equ 3
	FILE_ATTRIBUTE_NORMAL equ 0x80
	INVALID_HANDLE_VALUE equ -1
	;bytesRead dd 0

	hex_table db "0123456789ABCDEF"

	dosHeaderLabel db "DOS Header:", 10
    dosHeaderLabelFirstLine db 9,"Member",9,9,9,"Offset",9,9,"Size",9,9,"Value",10
    ntHeaderLabel db "NT Header:", 0
    fileHeaderLabel db "File Header:",10
    optionalHeaderLabel db "Optional Header:",10
    dataDirectoryLabel db "Data Directories:",10
    sectionHeaderLabel db "Section Headers:", 10
    sectionHeaderFirstLine db 9,"Name",9,9,"Virtual Size",9,9,"Virtual Address",9,9,"Raw Size",9,9,"Raw Address",9,9,"Reloc Address",10
                           db 9,9,9,"Linenumbers",9,9,"Relocations Number",9,"Linenumbers Number",9,"Characteristics",10
                           db 9,"Byte[8]",9,9,"Dword",9,9,9,"Dword",9,9,9,"Dword",9,9,9,"Dword",9,9,9,"Dword",10
                           db 9,9,9,"Dword",9,9,9,"Word",9,9,9,"Word",9,9,9,"Dword",10
    importDirectoryLable db "Import Directory:",10
    importDirectoryFirstLine db 9,"Module Name",9,9,9,9,"OFTs",9,9,"TimeDateStamp",9,9,"ForwarderChain",9,9,"NameRVA",9,9,"FTs (IAT)",10
                             db 9,"szAnsi",9,9,9,9,9,"Dword",9,9,"Dword",9,9,9,"Dword",9,9,9,"Dword",9,9,"Dword",10
    importFunctFirstLine db 9,"OFTs",9,9,9,9,"FTs",9,9,9,9,"Hint",9,9,"Name",10
    exportDirectoryLable db "Export Directory:",10
    

    string_address dd 0
    string_size dd 0
    offset_value dd 0

    dtab db 9,9
    newline db 10
    sizeWord db "Word"
    sizeDword db "Dword"
    sizeByte db "Byte"
    sizeQword db "Qword"
;DOS Header
    DOS_magic db "e_magic",9,9,9
    DOS_cblp db "e_cblp",9,9,9
    DOS_cp db "e_cp",9,9,9
    DOS_crlc db "e_crlc",9,9,9
    DOS_cparhdr db "e_cparhdr",9,9
    DOS_minalloc db "e_minalloc",9,9
    DOS_maxalloc db "e_maxalloc",9,9
    DOS_ss db "e_ss",9,9,9
    DOS_sp db "e_sp",9,9,9
    DOS_csum db "e_csum",9,9,9
    DOS_ip db "e_ip",9,9,9
    DOS_cs db "e_cs",9,9,9
    DOS_lfarlc db "e_lfarlc",9,9
    DOS_ovno db "e_ovno",9,9,9
    DOS_res db "e_res",9,9,9
    DOS_null db 9,9,9
    DOS_null_1 db 9,9,9
    DOS_null_2 db 9,9,9
    DOS_oemid db "e_oemid",9,9,9
    DOS_oeminfo db "e_oeminfo",9,9
    DOS_res2 db "e_res2",9,9,9
    DOS_null_4 db 9,9,9
    DOS_null_5 db 9,9,9
    DOS_null_6 db 9,9,9
    DOS_null_7 db 9,9,9
    DOS_null_8 db 9,9,9
    DOS_null_9 db 9,9,9
    DOS_null_10 db 9,9,9
    DOS_null_11 db 9,9,9
    DOS_null_12 db 9,9,9
    DOS_lfanew db "e_lfanew",9,9
    DOS_endmem:

    DOS_Array dd DOS_magic,DOS_cblp,DOS_cp,DOS_crlc,DOS_cparhdr,DOS_minalloc,DOS_maxalloc,DOS_ss,DOS_sp,DOS_csum,DOS_ip,DOS_cs,DOS_lfarlc,DOS_ovno,DOS_res,DOS_null,DOS_null_1,DOS_null_2,DOS_oemid,DOS_oeminfo,DOS_res2,DOS_null_4,DOS_null_5,DOS_null_6,DOS_null_7,DOS_null_8,DOS_null_9,DOS_null_10,DOS_null_11,DOS_null_12,DOS_lfanew
; NT Header
    optional_address dd 0
    nt_header_offset_value dd 0
    nt_signatur db "Signature",9,9

    ;File Header
    ;fileHeader
    File_Machine db "Machine",9,9,9
    File_NumSec db "NumberofSections",9
    File_TimeStamp db "TimeDateStamp",9,9
    File_PointertoSymbolTable db "PointerToSymbolTable",9
    File_NumOfSymbols db "NumberOfSymbols",9,9
    File_SizeOfOptionaHeader db "SizeOfOptionalHeader",9
    File_Characteristics db "Characteristics",9,9
    File_end db 0

    File_Array dd File_Machine,File_NumSec,File_TimeStamp,File_PointertoSymbolTable,File_NumOfSymbols,File_SizeOfOptionaHeader,File_Characteristics,File_end

;Optional Header
    Optional_Magic db "Magic",9,9,9
    Optional_MajorLinkerVersion db "MajorLinkerVersion",9
    Optional_MinorLinkerVersion db "MinorLinkerVersion",9
    Optional_SizeofCode db "SizeOfCode",9,9
    Optional_SizeOfInitializedData db "SizeOfInitializedData",9
    Optional_SizeOfUninitializedData db "SizeOfUninitializedData",9
    Optional_AddressOfEntryPoint db "AddressOfEntryPoint",9
    Optional_BaseOfCode db "BaseOfCode",9,9
    Optional_ImageBase db "ImageBase",9,9
    Optional_SectionAlignment db "SectionAlignment",9
    Optional_FileAlignment db "FileAlignment",9,9
    Optional_MajorOperatingSystemVersion db "MajorOperatingSystemVersion"
    Optional_MinorOperatingSystemVersion db "MinorOperatingSystemVersion"
    Optional_MajorImageVersion db "MajorImageVersion",9
    Optional_MinorImageVersion db "MinorImageVersion",9
    Optional_MajorSubsystemVersion db "MajorSubsystemVersion",9
    Optional_MinorSubsystemVersion db "MinorSubsystemVersion",9
    Optional_Win32VersionValue db "Win32VersionValue",9
    Optional_SizeOfImage db "SizeOfImage",9,9
    Optional_SizeOfHeader db "SizeOfHeaders",9,9
    Optional_Checksum db "Checksum",9,9
    Optional_Subsystem db "Subsystem",9,9
    Optional_DllChracteristics db "DllChracteristics",9
    Optional_SizeOfStackReverse db "SizeOfStackReverse",9
    Optional_SizeOfStackCommit db "SizeOfStackCommit",9
    Optional_SizeOfHeapReverse db "SizeOfHeapReverse",9
    Optional_SizeOfHeapCommit db "SizeOfHeapCommit",9
    Optional_LoaderFlags db "LoaderFlags",9,9
    Optional_NumberOfRvaAndSizes db "NumberOfRvaAndSizes",9
    Optional_end db 0

    Optional_Array dd Optional_Magic,Optional_MajorLinkerVersion,Optional_MinorLinkerVersion,Optional_SizeofCode,Optional_SizeOfInitializedData,Optional_SizeOfUninitializedData,Optional_AddressOfEntryPoint,Optional_BaseOfCode,Optional_ImageBase,Optional_SectionAlignment,Optional_FileAlignment,Optional_MajorOperatingSystemVersion,Optional_MinorOperatingSystemVersion,Optional_MajorImageVersion,Optional_MinorImageVersion,Optional_MajorSubsystemVersion,Optional_MinorSubsystemVersion,Optional_Win32VersionValue,Optional_SizeOfImage,Optional_SizeOfHeader,Optional_Checksum,Optional_Subsystem,Optional_DllChracteristics,Optional_SizeOfStackReverse,Optional_SizeOfStackCommit,Optional_SizeOfHeapReverse,Optional_SizeOfHeapCommit,Optional_LoaderFlags,Optional_NumberOfRvaAndSizes,Optional_end
    optional_header_size dd 0
    file_numofsec dd 0
;Data Directories
    Data_ExportDirRVA db "ExportDirectoryRVA",9
    Data_ExportDirSize db "ExportDirectorySize",9
    Data_ImportDirRVA db "ImportDirectoryRVA",9
    Data_ImportDirSize db "ImportDirectorySize",9
    Data_ResourceDirRVA db "ResourceDirectoryRVA",9
    Data_ResourceDirSize db "ResourceDirectorySize",9
    Data_ExceptionDirRVA db "ExceptionDirectoryRVA",9
    Data_ExceptionDirSize db "ExceptionDirectorySize",9
    Data_SecurityDirRVA db "SecurityDirectoryRVA",9
    Data_SecurityDirSize db "SecurityDirecorySize",9
    Data_RelocationDirRVA db "RelocationDirectoryRVA",9
    Data_RelocationDirSize db "RelocationDirectorySize",9
    Data_DebugDirRVA db "DebugDirectoryRVA",9
    Data_DebugDirSize db "DebugDirectorySize",9
    Data_ArchitectureDirRVA db "ArchitectureDirRVA",9
    Data_ArchitectureDirSize db "ArchitectureDirSize",9
    Data_Reserved db "Reserved",9,9
    Data_Reserved_1 db "Reserved",9,9
    Data_TLSDirRVA db "TLSDirectoryRVA",9,9
    Data_TLSDirSize db "TLSDirectorySize",9
    Data_ConfigurationDirRVA db "ConfigurationDirRVA",9
    Data_ConfigurationDirSize db "ConfigurationDirSize",9
    Data_BoundImportRVA db "BoundImportDirectoryRVA",9
    Data_BoundImportSize db "BoundImportDiectorySize",9
    Data_ImportAddrTableDirRVA db "ImportAddrTableDirRVA",9
    Data_ImportAddrTableDirSize db "ImportAddrTableDirSize",9
    Data_DelayImportDirRVA db "DelayImportDirRVA",9
    Data_DelayImportDirSize db "DelayImportDirSize",9
    Data_.NETMetaDataDirRVA db ".NETMetaDataDirRVA",9
    Data_.NETMetaDataDirSize db ".NETMetaDataDirSize",9
    Data_end db 0

    Data_Array dd Data_ExportDirRVA,Data_ExportDirSize,Data_ImportDirRVA,Data_ImportDirSize,Data_ResourceDirRVA,Data_ResourceDirSize,Data_ExceptionDirRVA,Data_ExceptionDirSize,Data_SecurityDirRVA,Data_SecurityDirSize,Data_RelocationDirRVA,Data_RelocationDirSize,Data_DebugDirRVA,Data_DebugDirSize,Data_ArchitectureDirRVA,Data_ArchitectureDirSize,Data_Reserved,Data_Reserved_1,Data_TLSDirRVA,Data_TLSDirSize,Data_ConfigurationDirRVA,Data_ConfigurationDirSize,Data_BoundImportRVA,Data_BoundImportSize,Data_ImportAddrTableDirRVA,Data_ImportAddrTableDirSize,Data_DelayImportDirRVA,Data_DelayImportDirSize,Data_.NETMetaDataDirRVA,Data_.NETMetaDataDirSize,Data_end
; Section
    section_address dd 0

;Import Directories
    import_rva dd 0
    export_rva dd 0
    section_import_rva dd 0
    section_import_rawaddr dd 0

    rva dd 0
    section_rva dd 0
    section_rawaddr dd 0
    oft_value dd 0

    impfunc_oft dd 0
    impfunc_hint dd 0
    impfunc_name dd 0
    

section .bss
    input resb 257              ; Lưu chiều dài đường dẫn nhập vào
    len resb 1              ; Lưu chiều dài xâu nhập vào
	buffer resb 5000000
    bytesRead resb 5000000


section .text
_main:
	mov ebp, esp				; Thiết lập khung stack, lưu giá trị của `esp` vào `ebp`.
	sub esp, 8					; Dành chỗ trên stack để lưu hai biến tạm thời (mỗi biến 4 byte).

;Input
    mov DWORD [string_size], msgLen
    mov eax, msg
    mov DWORD [string_address], eax
    call print_string

    ;prompt to enter file path
    push -10					; Đẩy tham số `-10` lên stack (tương ứng với `STD_INPUT_HANDLE`), đại diện cho handle của `stdin`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdin`.
	mov ebx, eax				; Lưu handle của `stdin` vào thanh ghi `ebx` để dùng sau.

	; BOOL ReadFile(HANDLE hFile, LPVOID lpBuffer, DWORD nNumberOfBytesToRead, LPDWORD lpNumberOfBytesRead, LPOVERLAPPED lpOverlapped);
	push 0						; Đẩy tham số `lpOverlapped = 0` (không dùng overlapped I/O) lên stack.
	lea ecx, [ebp - 4]			; Tạo địa chỉ trỏ đến biến tạm thời (4 byte) trên stack, nơi lưu số byte đã đọc.
	push ecx					; Đẩy địa chỉ này lên stack làm tham số.
	push 255						; Đẩy tham số `nNumberOfBytesToRead = 20` (số byte cần đọc) lên stack.
	mov eax, input
	push eax					; Đẩy địa chỉ buffer lên stack làm tham số.
	push ebx					; Đẩy handle của `stdin` (lưu trong `ebx`) lên stack làm tham số.
	call _ReadFile@20			; Gọi hàm `ReadFile` để đọc dữ liệu từ `stdin` và lưu vào `_input_buf`.

    ; Lưu chiều dài xâu (trừ ký tự xuống dòng nếu có)
    mov ecx, [ebp - 4]            ; eax chứa số ký tự đọc được
    mov [len], cl
    ;dec byte [len]          ; bỏ ký tự xuống dòng nếu có

    mov ecx, [len]            ; Lấy chiều dài xâu đã nhập
    mov al, [input + ecx - 1]   ; Kiểm tra ký tự cuối cùng
    cmp al, 0x0A              ; So sánh với ký tự xuống dòng '\n'
    mov Word [input + ecx - 2], 0 ; Thay '\n' bằng NULL
    dec ecx                   ; Giảm chiều dài xâu 
    mov [len], cl ; Lưu lại chiều dài

	;Read file into buffer
	; Open with CreateFile
    push dword 0                ; hTemplateFile
    push dword FILE_ATTRIBUTE_NORMAL ; FILE_ATTRIBUTE_NORMAL
    push dword OPEN_EXISTING    ; OPEN_EXISTING
    push dword 0                ; lpSecurityAttributes
    push dword 0                ; FILE_SHARE_READ
    push dword GENERIC_READ     ; GENERIC_READ
    push dword input         ; lpFileName
    call _CreateFileA@28
    mov [fileHandle], eax
    cmp eax, INVALID_HANDLE_VALUE
    je .error_open

	; Fill buffer
    push dword 0                ; lpOverlapped
    push dword bytesRead        ; lpNumberOfBytesRead
    push dword 5000000          ; nNumberOfBytesToRead
    push dword buffer           ; lpBuffer
    push dword [fileHandle]     ; hFile
    call _ReadFile@20
    cmp eax, INVALID_HANDLE_VALUE
    je .err_read

	; Lấy e_magic trong DOS Header
    ; Hiển thị chữ ký NT Header (Signature)
    mov ax, WORD [buffer]     ; Signature
	cmp ax, 0x5A4D
	jne .err_not_pe

;DOS Header
    mov     DWORD [string_size], 12
    mov     eax, dosHeaderLabel
    mov     DWORD [string_address], eax
    call    print_string

    mov     DWORD [string_size], (ntHeaderLabel - dosHeaderLabelFirstLine)
    mov     eax, dosHeaderLabelFirstLine
    mov     DWORD [string_address], eax
    call    print_string

    ;e_magic - DOS_null_1
    mov esi, 0
    mov eax, 0
    mov dword [offset_value], eax
.dos_header_loop:
    cmp esi, 30
    je .dos_header_loop_exit
    push esi
    
    mov DWORD [string_size], 1
    mov eax, dtab
    mov [string_address], eax
    call print_string

    ;member
    pop esi
    push esi

    shl esi, 2
    mov eax, [DOS_Array + esi]
    mov [string_address], eax
    mov ebx, [DOS_Array + esi + 4]
    sub ebx, eax
    mov dword [string_size], ebx
    call print_string

    call print_offset

    mov DWORD [string_size], 1
    mov eax, dtab
    mov [string_address], eax
    call print_string

    mov DWORD [string_size], 4
    mov eax, sizeWord
    mov [string_address], eax
    call print_string

    mov DWORD [string_size], 2
    mov eax, dtab
    mov [string_address], eax
    call print_string

    push dword [offset_value]
    push 2
    call printxb
    pop ebx
    pop ebx

    add dword [offset_value], 2

    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string

    pop esi
    inc esi
    jmp .dos_header_loop
.dos_header_loop_exit:

    ;print e_lfanew
    mov DWORD [string_size], 1
    mov eax, dtab
    mov [string_address], eax
    call print_string

    mov eax, DOS_lfanew
    mov dword [string_address], eax
    mov ebx, DOS_endmem
    sub ebx, eax
    mov dword [string_size], ebx
    call print_string

    call print_offset

    mov DWORD [string_size], 1
    mov eax, dtab
    mov [string_address], eax
    call print_string

    mov DWORD [string_size], 5
    mov eax, sizeDword
    mov [string_address], eax
    call print_string

    mov DWORD [string_size], 2
    mov eax, dtab
    mov [string_address], eax
    call print_string

    push dword [offset_value]
    push 4
    call printxb
    pop ebx
    pop ebx

    mov eax, dword [offset_value]
    add eax, buffer
    push eax
    push 4
    call little_to_big_endian
    pop ebx
    pop ebx

    mov dword [nt_header_offset_value], eax

    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string

    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string
    
;NT Header
    mov eax, dword [offset_value]

    mov dword [string_address], ntHeaderLabel
    mov ebx, fileHeaderLabel
    sub ebx, ntHeaderLabel
    mov dword [string_size], ebx
    call print_string
    
    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string

    mov     DWORD [string_size], (ntHeaderLabel - dosHeaderLabelFirstLine)
    mov     eax, dosHeaderLabelFirstLine
    mov     DWORD [string_address], eax
    call    print_string

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    mov dword [string_address], nt_signatur
    mov dword [string_size], 11
    call print_string

    mov eax, [nt_header_offset_value]
    mov [offset_value], eax
    call print_offset

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    mov dword [string_address], sizeDword
    mov dword [string_size], 5
    call print_string

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    push dword [offset_value]
    push 4
    call printxb
    pop ebx
    pop ebx

    ;update offset Value
    add dword [offset_value], 4

    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string
    
    mov dword [string_address], fileHeaderLabel
    mov dword [string_size], (optionalHeaderLabel - fileHeaderLabel)
    call print_string

    ;File Header

    mov eax, dword [offset_value]
    add eax, 2                      ;offset of numofsection from file_header
    add eax, buffer
    push eax
    push 2
    call little_to_big_endian
    pop ebx
    pop ebx

    mov dword [file_numofsec], eax

    mov esi, 0
.file_header_loop:
    cmp esi, 7
    je .file_header_loop_exit
    push esi

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    mov eax, esi
    shl eax, 2
    
    mov ebx, dword [File_Array + eax]
    mov dword [string_address], ebx
    mov ebx, dword [File_Array + eax + 4]
    sub ebx, dword [File_Array + eax]
    mov [string_size], ebx
    call print_string

    call print_offset
    
    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    pop esi
    push esi

    cmp esi,2
    jl .File_size_word
    cmp esi,4
    jg .File_size_word

    mov dword [string_address], sizeDword
    mov dword [string_size], 5
    call print_string
    
    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    push dword [offset_value]
    push 4
    call printxb
    pop ebx
    pop ebx

    add dword [offset_value], 4

    jmp .File_size_dword

.File_size_word:
    mov dword [string_address], sizeWord
    mov dword [string_size], 4
    call print_string

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    mov eax, dword [offset_value]
    push dword [offset_value]
    push 2
    call printxb
    pop ebx
    pop ebx

    pop esi
    push esi
    cmp esi, 5
    jne .not_size_of_header

    mov eax, dword [offset_value]
    add eax, buffer
    push eax
    push 2
    call little_to_big_endian
    pop ebx
    pop ebx

    mov dword [optional_header_size], eax

.not_size_of_header:

    add dword [offset_value], 2

.File_size_dword:
    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string

    pop esi
    inc esi
    jmp .file_header_loop
.file_header_loop_exit:

    ;Optional Header
    mov dword [string_address], optionalHeaderLabel
    mov dword [string_size], (dataDirectoryLabel - optionalHeaderLabel)
    call print_string

    mov     DWORD [string_size], (ntHeaderLabel - dosHeaderLabelFirstLine)
    mov     eax, dosHeaderLabelFirstLine
    mov     DWORD [string_address], eax
    call    print_string

    mov eax, offset_value
    push eax
    push 4
    call little_to_big_endian
    pop ebx
    pop ebx

    mov dword [optional_address], eax

    mov esi,0
.optional_header_loop:
    cmp esi, 29
    je .optional_header_loop_exit
    push esi

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    mov eax, esi
    shl eax, 2

    mov ebx, dword [Optional_Array + eax]
    mov dword [string_address], ebx
    mov ebx, dword [Optional_Array + eax + 4]
    sub ebx, dword [Optional_Array + eax]
    mov [string_size], ebx
    call print_string

    push dword [offset_value]
    push 4
    call print_offset
    pop ebx
    pop ebx

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    pop esi
    push esi
    cmp esi, 0
    je .optional_is_word
    cmp esi, 11
    je .optional_is_word
    cmp esi, 12
    je .optional_is_word
    cmp esi, 13
    je .optional_is_word
    cmp esi, 14
    je .optional_is_word
    cmp esi, 15
    je .optional_is_word
    cmp esi, 16
    je .optional_is_word
    cmp esi, 21
    je .optional_is_word
    cmp esi, 22
    je .optional_is_word

    jmp .optional_check_byte

.optional_is_word:
    mov dword [string_address], sizeWord
    mov dword [string_size], 4
    call print_string

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    push dword [offset_value]
    push 2
    call printxb
    pop ebx
    pop ebx

    add dword [offset_value], 2

    jmp .optional_check_end

.optional_check_byte:
    pop esi
    push esi
    cmp esi, 1
    je .optional_is_byte
    cmp esi, 2
    je .optional_is_byte

    jmp .optional_check_qword

.optional_is_byte:
    mov dword [string_address], sizeByte
    mov dword [string_size], 4
    call print_string

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    push dword [offset_value]
    push 1
    call printxb
    pop ebx
    pop ebx

    add dword [offset_value], 1

    jmp .optional_check_end

.optional_check_qword:
    pop esi
    push esi
    cmp esi, 8
    je .optional_is_qword
    cmp esi, 23
    je .optional_is_qword
    cmp esi, 24
    je .optional_is_qword
    cmp esi, 25
    je .optional_is_qword
    cmp esi, 26
    je .optional_is_qword

    jmp .optional_is_dword

.optional_is_qword:

    mov dword [string_address], sizeQword
    mov dword [string_size], 5
    call print_string

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    push dword [offset_value]
    push 8
    call printxb
    pop ebx
    pop ebx

    add dword [offset_value], 8

    jmp .optional_check_end

.optional_is_dword:
    mov dword [string_address], sizeDword
    mov dword [string_size], 5
    call print_string

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    push dword [offset_value]
    push 4
    call printxb
    pop ebx
    pop ebx

    add dword [offset_value], 4

.optional_check_end:
    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string

    pop esi
    inc esi
    jmp .optional_header_loop

.optional_header_loop_exit:

;Data Directories
    mov dword [string_address], dataDirectoryLabel
    mov dword [string_size], (sectionHeaderLabel - dataDirectoryLabel)
    call print_string

    mov     DWORD [string_size], (ntHeaderLabel - dosHeaderLabelFirstLine)
    mov     eax, dosHeaderLabelFirstLine
    mov     DWORD [string_address], eax
    call    print_string

    mov esi, 0
.data_directory_loop:
    cmp esi, 30
    je .data_directory_loop_exit
    push esi

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    ;member
    pop esi
    push esi

    shl esi, 2
    mov eax, [Data_Array + esi]
    mov [string_address], eax
    mov ebx, [Data_Array + esi + 4]
    sub ebx, eax
    mov dword [string_size], ebx
    call print_string

    call print_offset

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string
    
    mov dword [string_address], sizeDword
    mov dword [string_size], 5
    call print_string

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    push dword [offset_value]
    push 4
    call printxb
    pop ebx
    pop ebx

    pop esi
    push esi
    cmp esi, 2
    jne .not_import_rva

    mov eax, dword [offset_value]
    add eax, buffer
    push eax
    push 4
    call little_to_big_endian
    pop ebx
    pop ebx

    mov dword [import_rva], eax

.not_import_rva:

    pop esi
    push esi
    cmp esi, 0
    jne .not_export_rva

    mov eax, dword [offset_value]
    add eax, buffer
    push eax
    push 4
    call little_to_big_endian
    pop ebx
    pop ebx

    mov dword [export_rva], eax

.not_export_rva:

    add dword [offset_value], 4

    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string

    pop esi
    inc esi
    jmp .data_directory_loop
.data_directory_loop_exit:

    mov dword [string_address], sectionHeaderLabel
    mov dword [string_size], (sectionHeaderFirstLine - sectionHeaderLabel)
    call print_string

    mov dword [string_address], sectionHeaderFirstLine
    mov dword [string_size], (importDirectoryLable - sectionHeaderFirstLine)
    call print_string

    mov eax, dword [optional_address]
    add eax, dword [optional_header_size]
    mov dword [offset_value], eax
    
    xor esi, esi
.section_loop:
    cmp esi, dword [file_numofsec]
    je .section_loop_exit
    push esi

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    mov eax, dword [offset_value]
    add eax, buffer
    mov dword [string_address], eax
    mov dword [string_size], 8
    call print_string

    ;name
    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    mov eax, dword [offset_value]
    add eax, 8
    mov dword [offset_value], eax

    ;vir size
    push dword [offset_value]
    push 4
    call printxb
    pop ebx
    pop ebx

    mov eax, dword [offset_value]
    add eax, 4
    mov dword [offset_value], eax

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    ;vir addr
    push dword [offset_value]
    push 4
    call printxb
    pop ebx
    pop ebx

    ;find import in which section
    mov eax, dword [offset_value]
    add eax, buffer
    push eax
    push 4
    call little_to_big_endian
    pop ebx
    pop ebx

    cmp eax, dword [import_rva]
    jg .not_this_section

    mov dword [section_import_rva], eax

    mov eax, dword [offset_value]
    add eax, 8                      ;offset of raw addr
    add eax, buffer
    push eax
    push 4
    call little_to_big_endian
    pop ebx
    pop ebx

    mov dword [section_import_rawaddr], eax

.not_this_section:

    mov eax, dword [offset_value]
    add eax, 4
    mov dword [offset_value], eax

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    ;raw size
    push dword [offset_value]
    push 4
    call printxb
    pop ebx
    pop ebx

    mov eax, dword [offset_value]
    add eax, 4
    mov dword [offset_value], eax

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    ;raw addr
    push dword [offset_value]
    push 4
    call printxb
    pop ebx
    pop ebx

    mov eax, dword [offset_value]
    add eax, 4
    mov dword [offset_value], eax

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    ;reloc addr
    push dword [offset_value]
    push 4
    call printxb
    pop ebx
    pop ebx

    mov eax, dword [offset_value]
    add eax, 4
    mov dword [offset_value], eax

    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string
    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    ;Linenumbers
    push dword [offset_value]
    push 4
    call printxb
    pop ebx
    pop ebx

    mov eax, dword [offset_value]
    add eax, 4
    mov dword [offset_value], eax

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    push dword [offset_value]
    push 2
    call printxb
    pop ebx
    pop ebx

    mov eax, dword [offset_value]
    add eax, 2
    mov dword [offset_value], eax

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string
    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    push dword [offset_value]
    push 2
    call printxb
    pop ebx
    pop ebx

    mov eax, dword [offset_value]
    add eax, 2
    mov dword [offset_value], eax

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string
    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    push dword [offset_value]
    push 4
    call printxb
    pop ebx
    pop ebx

    mov eax, dword [offset_value]
    add eax, 4
    mov dword [offset_value], eax

    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string

    pop esi
    inc esi
    jmp .section_loop
.section_loop_exit:
    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string

    mov dword [string_address], importDirectoryLable
    mov dword [string_size], (importDirectoryFirstLine - importDirectoryLable)
    call print_string
    
    mov dword [string_address], importDirectoryFirstLine
    mov dword [string_size], (importFunctFirstLine - importDirectoryFirstLine)
    call print_string

    mov eax, dword [import_rva]
    mov dword [rva], eax

    mov eax, dword [section_import_rva]
    mov dword [section_rva], eax
    mov eax, dword [section_import_rawaddr]
    mov dword [section_rawaddr], eax
    call calculate_file_offset

    ;offset_value = start of import header
    mov [offset_value], eax
    
.import_loop:
    mov eax, dword [offset_value]
    add eax, buffer
    push eax
    push 4
    call little_to_big_endian
    pop ebx
    pop ebx

    cmp eax, 0
    je .import_loop_exit


    ;mov to 0xC (RVA of Name)
    mov eax, dword [offset_value]
    add eax, 0xC
    add eax, buffer
    push eax
    push 4
    call little_to_big_endian
    pop ebx
    pop ebx

    mov dword [rva], eax
    mov eax, dword [section_import_rva]
    mov dword [section_rva], eax 
    mov eax, dword [section_import_rawaddr]
    mov dword [section_rawaddr], eax
    call calculate_file_offset


    ;eax store offset of name
    add eax, buffer
    push eax
    call print_string_before_null_uncut
    pop eax

    ;OFTs
    mov eax, dword [offset_value]
    push eax
    push 4
    call printxb
    pop ebx
    pop ebx

    ;offset of funct oft
    mov eax, dword [offset_value]
    add eax, buffer
    push eax
    push 4
    call little_to_big_endian
    pop ebx
    pop ebx

    mov dword [rva], eax
    mov eax, dword [section_import_rva]
    mov dword [section_rva], eax
    mov eax, dword [section_import_rawaddr]
    mov dword [section_rawaddr], eax
    call calculate_file_offset

    mov dword [impfunc_oft], eax

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    ;TimeDateStamp
    mov eax, dword [offset_value]
    add eax, 4
    push eax
    push 4
    call printxb
    pop ebx
    pop ebx

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    ;ForwarderChain
    mov eax, dword [offset_value]
    add eax, 8
    push eax
    push 4
    call printxb
    pop ebx
    pop ebx

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    ;NameRVA

    mov eax, dword [offset_value]
    add eax, 12
    push eax
    push 4
    call printxb
    pop ebx
    pop ebx

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    ;FTs
    mov eax, dword [offset_value]
    add eax, 16
    push eax
    push 4
    call printxb
    pop ebx
    pop ebx

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string

    ;Print import funct
    call print_import_funct
    

    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string

    mov eax, dword [offset_value]
    add eax, 0x14
    mov dword [offset_value], eax

    jmp .import_loop

.import_loop_exit:

    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string

    mov dword [string_address], exportDirectoryLable
    mov dword [string_size], 17
    call print_string

	jmp .exit
.err_not_pe:
	;Print
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov ebx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    20
    push    err_not_pe
    push    ebx
    call    _WriteFile@20

	jmp .exit

.err_read:
	;Print
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov ebx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    25
    push    err_open
    push    ebx
    call    _WriteFile@20

	jmp .exit
.error_open:
	;Print
    push -11					; Đẩy tham số `-11` lên stack (tương ứng với `STD_OUTPUT_HANDLE`), đại diện cho handle của `stdout`.
	call _GetStdHandle@4		; Gọi hàm `GetStdHandle` để lấy handle của `stdout`.
	mov ebx, eax				; Lưu handle của `stdout` vào thanh ghi `ebx` để dùng sau.

	;BOOL WriteFile(HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
	; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea     eax, [ebp-4]
    push    eax
    push    (err_read - err_open)
    push    err_open
    push    ebx
    call    _WriteFile@20

.exit:
	push 0						; Đẩy tham số `uExitCode = 0` lên stack (trạng thái thoát của chương trình).
	call _ExitProcess@4			; Gọi hàm `ExitProcess` để kết thúc chương trình với mã thoát 0.

	
print_string:
    push ebp
    mov ebp, esp
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
    push    DWORD [string_size]
    push    DWORD [string_address]              ;addresss of string
    push    ebx
    call    _WriteFile@20

    add esp, 8              
    mov esp, ebp
    pop ebp
    ret

bin_to_hex:
    push ebp
    mov ebp, esp
    
    mov al, byte [ebp + 8]
    xor ebx, ebx
    xor ecx, ecx

    ; Tách nibble cao
    mov ah, al                       ; Copy byte vào AH                   ah = 0x0086
    shr ah, 4                        ; Dịch phải 4 bit để lấy nibble cao  
    mov cl, ah
    and cl, 0x0F
    
    lea ecx, [hex_table + ecx]                
    mov dword [string_address], ecx
    mov DWORD [string_size], 1
    call print_string
    
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    ; Tách nibble thấp
    mov al, [ebp + 8]                 
    mov cl, al
    and cl, 0x0F		      ; Lấy 4 bit thấp nhất của byte

    lea ecx, [hex_table + ecx]          
    mov dword [string_address], ecx
    mov DWORD [string_size], 1
    call print_string

    pop ebp
    ret

printxb:                ;printxb(address,numofbyte)
    push ebp
    mov ebp, esp

    mov ebx, [esp + 12]                 ;0x000000F0
    mov esi, [esp + 8]                  ;2
    
    dec esi                             ;1
.printxb_loop:
    cmp esi, 0                          
    jl .printxb_loop_exit       
    xor eax, eax                        ;0
    mov ebx, [esp + 12]                 ;0x000000F0
    add ebx, esi                        ;0x000000F1
    mov al, byte [buffer + ebx]

    push eax
    call bin_to_hex
    pop eax

    dec esi
    jmp .printxb_loop

.printxb_loop_exit:
    mov esp, ebp
    pop ebp
    ret

print_offset:
    push ebp
    mov ebp, esp

    mov esi, 3

.print_offset_loop:
    cmp esi, 0
    jl .print_offset_loop_exit
    xor eax, eax
    mov al, byte [offset_value + esi]
    push eax
    call bin_to_hex

    dec esi
    jmp .print_offset_loop

.print_offset_loop_exit:
    mov esp, ebp
    pop ebp
    ret

little_to_big_endian:
    push ebp
    mov ebp, esp

    ;dia chi cua chuoi
    mov ebx, [ebp + 12]
    ;kich thuoc muon chuyen sang little endian
    mov esi, [ebp + 8]
    dec esi             
    xor eax, eax

little_to_big_endian_loop:
    
    cmp esi, 0
    jl little_to_big_endian_exit

    shl eax, 8
    mov al, byte [ebx + esi]

    dec esi
    jmp little_to_big_endian_loop

little_to_big_endian_exit:
    pop ebp
    ret

calculate_file_offset:          ; (RVA, Virtual section address, raw section address)
    push ebp
    mov ebp, esp

    mov eax, dword [rva]
    sub eax, dword [section_rva]
    add eax, dword [section_rawaddr]

    mov esp, ebp
    pop ebp
    ret

print_string_before_null_uncut:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]

    ;count num of character before null
    xor esi, esi
    xor ebx, ebx
.print_loop:
    mov bl, byte [eax + esi]
    cmp bl, 0
    je .exit
    inc esi
    jmp .print_loop

.exit:
    ;print string
    mov eax, dword [ebp + 8]
    mov dword [string_address], eax

    inc esi
    mov dword [string_size], esi

.print_name:
    call print_string

    cmp esi, 13
    jg .need_4_tab

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    jmp .exit_funct

.need_4_tab:
    cmp esi, 29
    jg .need_3_tab

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    jmp .exit_funct

.need_3_tab:
    cmp esi, 31
    jg .need_2_tab

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    jmp .exit_funct

.need_2_tab:
    cmp esi, 40
    jg .need_1_tab

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    jmp .exit_funct

.need_1_tab:
    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

.exit_funct:

    pop ebp
    ret

print_import_funct:
    push ebp
    mov ebp, esp

    mov dword [string_address], importFunctFirstLine
    mov dword [string_size], (exportDirectoryLable - importFunctFirstLine)
    call print_string

.print_import_funct_loop:
    mov eax,dword [impfunc_oft]
    add eax, buffer
    push eax
    push 8
    call little_to_big_endian
    pop ebx
    pop ebx

    cmp eax, 0
    je .print_import_funct_loop_exit

    mov dword [rva], eax
    mov eax, dword [section_import_rva]
    mov dword [section_rva], eax
    mov eax, dword [section_import_rawaddr]
    mov dword [section_import_rawaddr], eax
    call calculate_file_offset

    mov dword [impfunc_hint], eax

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    push dword [impfunc_oft]
    push 8
    call printxb
    pop ebx
    pop ebx

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    push dword [impfunc_oft]
    push 8
    call printxb
    pop ebx
    pop ebx

    mov dword [string_address], dtab
    mov dword [string_size], 2
    call print_string

    mov eax, dword [impfunc_hint]
    push eax
    push 6
    call printxb
    pop ebx
    pop ebx

    mov dword [string_address], dtab
    mov dword [string_size], 1
    call print_string

    ;impfunc_name = impfunc_hint + 2
    mov eax, dword [impfunc_hint]
    add eax, 2
    add eax, buffer
    push eax
    call print_string_before_null_uncut
    pop eax


    mov dword [string_address], newline
    mov dword [string_size], 1
    call print_string

    mov eax, dword [impfunc_oft]
    add eax, 8
    mov dword [impfunc_oft], eax

    jmp .print_import_funct_loop

.print_import_funct_loop_exit:
    mov esp, ebp
    pop ebp
    ret