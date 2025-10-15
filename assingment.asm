; print macro
%macro print 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

; input macro
%macro input 2
    mov eax, 3
    mov ebx, 0
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

; openfile macro
%macro openfile 3
    mov eax, 5
    mov ebx, %1
    mov ecx, %2
    mov edx, %3
    int 0x80
%endmacro

; closefile macro
%macro closefile 1
    mov eax, 6
    mov ebx, %1
    int 0x80
%endmacro

;-------------------------------------------------------------------------------------------
section .data
    ; File name
    filename db "items.txt", 0
    ; add new line into file '\n'
    newline db 10   

    ; Menu
    menu db 'FOOD STOCK MANAGEMENT SYSTEM', 0xA
         db '1) Display list of items', 0xA
         db '2) Create new item', 0xA
         db '3) Add item stock', 0xA
         db '4) Reduce item stock', 0xA,
         db '5) Delete item', 0xA, 
         db '6) Quit', 0xA,0xA
         db 'Enter Choice : '
    len_menu equ $ - menu

    ; Choices display messages
    choice1 db  'LIST OF ITEMS', 0xA
    len_choice1 equ $ - choice1
    errorMsg db 'Error: cannot open file.', 0xA
    len_errorMsg equ $ - errorMsg

    choice2 db  'CREATE NEW ITEM', 0xA
            db  'Enter item name and value (apple, 10): ',
    len_choice2 equ $ - choice2
    save db 'Item saved successfully!', 0xA
    len_save equ $ - save

    choice3 db  'ADD ITEM STOCK', 0xA
            db  'Enter item name: ',
    len_choice3 equ $ - choice3
    stockValueInput db  'Enter stock to add: ',
    len_addStockValue equ $ - stockValueInput

    choice4 db  'Reduce item stock', 0xA
    len_choice4 equ $ - choice4

    choice5 db  'Delete item', 0xA
    len_choice5 equ $ - choice5

    undefined db 'Undefined Choice, Please Choose again', 0xA
    len_undefined equ $ - undefined

;-------------------------------------------------------------------------------------------
section .bss
menuInput resb 1
newmItem resb 64
readFileBuffer resb 128
editStockFileBuffer resb 1024
bytesRead resd 1
addStockItem resb 64
addStockValue resb 1
numStartESI resd 1
tempNum resb 32
;-------------------------------------------------------------------------------------------
section .text
    global _start

_start:
print_menu:
    print menu, len_menu

loop_read:
    input menuInput, 1

mov al, [menuInput]
cmp al, 0xA
je loop_read         ; skip processing if Enter was pressed alone

cmp al, '1'
je condition1
cmp al, '2'
je condition2
cmp al, '3'
je condition3
cmp al, '4'
je condition4
cmp al, '5'
je condition5
cmp al, '6'
je exit
; if none of the above, it's undefined
jmp condition_undefined

;-------------------------------------------------------------------------------------------
condition1:
    print choice1, len_choice1
    call displayItems
    print newline, 1
    jmp print_menu

condition2:
    ; Print prompt and get new item input
    print choice2, len_choice2
    input newmItem, 64

    ; if Enter was pressed alone, ask for input again
    mov al, [newmItem]
    cmp al, 0xA
    je input newmItem, 64   ; eax = bytes read
    
    ; Call createItem function to save new item to file
    push eax                ; 2nd argument = input length
    push newmItem           ; 1st argument = pointer to input
    call createItem
    add esp, 8              ; clean up the stack (2 arguments * 4 bytes each)
    print save, len_save

    print newline, 1
    jmp print_menu

condition3:
    ; Get item name
    print choice3, len_choice3
    input addStockItem, 64

.check_item_name:
    mov al, [addStockItem]
    cmp al, 0xA
    je .ask_item_name
    jmp .get_stock_value

.ask_item_name:
    input addStockItem, 64
    jmp .check_item_name

.get_stock_value:
    ; Get stock value to add
    print stockValueInput, len_addStockValue
    input addStockValue, 1

.check_stock_value:
    mov al, [addStockValue]
    cmp al, 0xA
    je .ask_stock_value
    jmp .update_stock

.ask_stock_value:
    input addStockValue, 1
    jmp .check_stock_value

.update_stock:
    ; Call addStock function to update stock value in file
    call addStock

    print newline, 1
    jmp print_menu

condition4:
    print choice4, len_choice4
    print newline, 1
    jmp print_menu

condition5:
    print choice5, len_choice5
    print newline, 1
    jmp print_menu

condition_undefined:
    print undefined, len_undefined
    print newline, 1
    jmp print_menu

exit:
    mov eax, 1          ; syscall: exit
    mov ebx, 0          ; status: 0
    int 0x80            ; call kernel

;-------------------------------------------------------------------------------------------
displayItems:
    push ebp        ; Save old base pointer
    mov ebp, esp    ; Create new stack frame

    ; ===== Open file for reading =====
    openfile filename, 0, 0
    cmp eax, 0
    js .file_error          ; if < 0, jump (file not found or error)
    mov esi, eax            ; save file descriptor

    ; ===== Read file (read 128 bytes each loop until 0) =====
.read_loop:
    mov eax, 3              ; sys_read
    mov ebx, esi            ; file descriptor
    mov ecx, readFileBuffer   ; where to store data
    mov edx, 128            ; how many bytes to read
    int 0x80

    ; if 0 or negative, end of file or error
    cmp eax, 0
    jle .done_reading       

    mov edi, eax            ; save number of bytes read

    ; print to screen
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    mov ecx, readFileBuffer ; buffer
    mov edx, edi            ; bytes read (saved value)
    int 0x80

    jmp .read_loop

.file_error:
    print errorMsg, len_errorMsg

.done_reading:
    ; ===== Close file =====
    closefile esi

    mov esp, ebp
    pop ebp
    ret

;-------------------------------------------------------------------------------------------
createItem:
    push ebp        ; Save old base pointer
    mov ebp, esp    ; Create new stack frame
    
    mov ecx, [ebp+8]     ; ptr to input buffer
    mov edx, [ebp+12]    ; length of input

    ; ===== Remove trailing newline if present =====
    mov esi, [ebp+8]     ; pointer to buffer
    mov ecx, [ebp+12]    ; input length
    dec ecx               ; point to last byte
    mov al, [esi + ecx]
    cmp al, 10            ; is it newline ('\n')?
    jne .no_trim
    mov byte [esi + ecx], 0   ; replace with NULL
    dec dword [ebp+12]        ; reduce input length

.no_trim:
    ; ===== Open file for appending =====
    openfile filename, 0x441, 0o644
    mov esi, eax         ; save file descriptor in esi

    ; ===== Write input to file =====
    mov eax, 4           ; sys_write
    mov ebx, esi
    mov ecx, [ebp+8]     ; pointer to buffer
    mov edx, [ebp+12]    ; length
    int 0x80

    ; ; ===== Add newline =====
    mov eax, 4
    mov ebx, esi
    mov ecx, newline
    mov edx, 1
    int 0x80

.done_writing:
    ; ===== Close file =====
    closefile esi

    mov esp, ebp
    pop ebp
    ret

;-------------------------------------------------------------------------------------------
scan_buffer:
    mov esi, editStockFileBuffer    ; start of buffer

.next_char:
    mov al, [esi]                   ; get current file byte
    cmp al, 0                       ; end of file buffer?
    je .not_found                   ; stop if reached end
    cmp al, [edi]                   ; first character matches first of input?
    jne .skip                       ; if not, continue searching

    ; now check the rest of the string
    push esi                        ; pass current file position
    push edi                        ; pass pointer to search term (input)
    call compare_strings
    add esp, 8                      ; clean up (we pushed esi, edi)
    cmp eax, 1                      ; if eax == 1, full match
    je .found                       ; match found 

.skip:
    inc esi                         ; move to next file byte
    jmp .next_char

.not_found:
    ; not found case
    jmp .done

.found:

.find_comma:
    mov al, [esi]
    cmp al, ','
    je .after_comma
    inc esi
    jmp .find_comma

.after_comma:
    inc esi       ; now ESI points to first digit ('1' in "10")
    mov [numStartESI], esi  ; save position of number start
    print numStartESI, 1

.done:
    ret

; Compare strings (ESI = position in file, EDI =  (input) pointer to search term) byte-by-byte
compare_strings:
.loop:
    mov al, [esi]
    mov bl, [edi]
    cmp bl, 0           ; end of search string?
    je .match           ; reached end => full match
    cmp al, bl
    jne .no_match
    inc esi             ; move to next char in file
    inc edi             ; move to next char in search term
    jmp .loop

.match:
    mov eax, 1          ; eax = 1 == match found
    ret

.no_match:
    xor eax, eax        ; eax = 0 == no match
    ret

; Convert ASCII string of digits at ESI to integer in EAX
ascii_to_int:
    xor eax, eax
.convert_loop:
    mov bl, [esi]
    cmp bl, '0'
    jb .done         ; if < '0' not digit
    cmp bl, '9'
    ja .done         ; if > '9' not digit
    sub bl, '0'
    and ebx, 0xFF
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .convert_loop
.done:
    ret

; Convert integer in EAX to ASCII string at address in EAX
int_to_ascii:
    mov ecx, 0

.reverse_loop:
    mov edx, 0
    mov ebx, 10
    div ebx              ; divide EAX by 10, remainder in EDX
    add dl, '0'
    push dx
    inc ecx
    test eax, eax
    jnz .reverse_loop

.write_loop:
    pop dx
    mov [edi], dl
    inc edi
    loop .write_loop
    mov byte [edi], 0
    ret

;----------------------------------------------------------------
openFileForEdit:
    push ebp
    mov ebp, esp

    ; ===== Open file for reading =====
    openfile filename, 0, 0
    cmp eax, 0
    js .file_error          ; if < 0, jump (file not found or error)
    mov esi, eax            ; save file descriptor

    ; ===== Read the whole file and saved it into editStockFileBuffer =====
    mov eax, 3              ; sys_read
    mov ebx, esi
    mov ecx, editStockFileBuffer
    mov edx, 1024
    int 0x80
    mov [bytesRead], eax

    ; ===== Close file =====
    closefile esi

    mov esp, ebp
    pop ebp
    ret

.file_error:
    print errorMsg, len_errorMsg

addStock:
    push ebp
    mov ebp, esp
    ; ===== Open file and read into buffer =====
    call openFileForEdit
    ; ===== Scan for item in buffer =====
    mov edi, addStockItem   ; pointer to input item name
    call scan_buffer

    ; Convert to integer and add the value
    call ascii_to_int           ; convert ASCII digits at ESI to integer in EAX
    movzx ebx, byte [addStockValue] ; get ASCII digit
    sub ebx, '0'                    ; convert to real integer (e.g. '1' -> 1)
    add eax, ebx                    ; now add it properly

    ; Convert back to ASCII and write it back to buffer
    mov edi, [numStartESI]      ; destination to write new digits
    call int_to_ascii           ; convert new value -> ASCII digits

    ; ===== Open file for writing (overwrite) =====
    openfile filename, 0x201, 0o644
    mov esi, eax                ; save file descriptor

    ; ===== Write updated buffer back to file =====
    mov eax, 4                      ; sys_write
    mov ebx, esi
    mov ecx, editStockFileBuffer
    mov edx, [bytesRead]             ; number of bytes read (saved value)
    int 0x80

    ; ===== Close file =====
    closefile esi

    mov esp, ebp
    pop ebp
    ret