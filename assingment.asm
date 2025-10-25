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
    menu db '-----------------------------------------------', 0xA
         db '|         FOOD STOCK MANAGEMENT SYSTEM        |', 0xA
         db '|---------------------------------------------|', 0xA
         db '| 1) | Display list of items                  |', 0xA
         db '|----|----------------------------------------|', 0xA
         db '| 2) | Create new item                        |', 0xA
         db '|----|----------------------------------------|', 0xA
         db '| 3) | Add item stock                         |', 0xA
         db '|----|----------------------------------------|', 0xA
         db '| 4) | Reduce item stock                      |', 0xA
         db '|----|----------------------------------------|', 0xA
         db '| 5) | Delete item                            |', 0xA 
         db '|----|----------------------------------------|', 0xA
         db '| 6) | Quit                                   |', 0xA
         db '-----------------------------------------------', 0xA,0xA
         db 'Enter Choice : '
    len_menu equ $ - menu

    ; Choices display messages
    choice1 db  'LIST OF ITEMS', 0xA
    len_choice1 equ $ - choice1
    errorMsg db 'Error: cannot open file.', 0xA
    len_errorMsg equ $ - errorMsg

    tableTop db '-----------------------------------------------', 0xA
    len_tableTop equ $ - tableTop
    tableHeader db '|  Item Name                      |   Value   |', 0xA
    len_tableHeader equ $ - tableHeader
    tableDivider db '|---------------------------------|-----------|', 0xA
    len_tableDivider equ $ - tableDivider
    tableBottom db '-----------------------------------------------', 0xA
    len_tableBottom equ $ - tableBottom
    pipeStart db '|  '
    len_pipeStart equ $ - pipeStart
    pipeMiddle db '|'
    len_pipeMiddle equ $ - pipeMiddle
    pipeEnd db '|', 0xA
    len_pipeEnd equ $ - pipeEnd
    spaces db '                                        '  ; 40 spaces for padding

    choice2 db  'CREATE NEW ITEM', 0xA
            db  'Enter item name: ',
    len_choice2 equ $ - choice2
    createStockValueInput db 'Enter number of stock for new item: '
    len_createStockValueInput equ $ - createStockValueInput
    itemExists  db '-----------------------------------------------------', 0xA
                db '|                   ERROR MESSAGE                   |', 0xA
                db '|---------------------------------------------------|', 0xA
                db '| Item already exists! Please use a different name. |', 0xA
                db '-----------------------------------------------------', 0xA
    len_itemExists equ $ - itemExists
    comma db ', '
    len_comma equ $ - comma
    save db 'Item saved successfully!', 0xA
    len_save equ $ - save

    choice3 db  'ADD ITEM STOCK', 0xA
            db  'Enter item name: ',
    len_choice3 equ $ - choice3
    addStockValueInput db  'Enter number of stock to add: ',
    len_addStockValue equ $ - addStockValueInput

    choice4 db  'REDUCE ITEM STOCK', 0xA
            db  'Enter item name: ',
    len_choice4 equ $ - choice4
    reduceStockValueInput db  'Enter number of stock to reduce: ',
    len_reduceStockValue equ $ - reduceStockValueInput
    insufficientStockAlert db '--------------------------------------------------', 0xA
                           db '|                 ERROR MESSAGE                  |', 0xA
                           db '|------------------------------------------------|', 0xA
                           db '| Stock less than amount to be reduced, try again|', 0xA
                           db '--------------------------------------------------', 0xA
    len_insufficientStockAlert equ $ - insufficientStockAlert
    zeroStockAlert db '----------------------------------------------------', 0xA
                   db '|                 ERROR MESSAGE                    |', 0xA
                   db '|--------------------------------------------------|', 0xA
                   db '|    Zero stock left, please restock immediately   |', 0xA
                   db '----------------------------------------------------', 0xA
    len_zeroStockAlert equ $ - zeroStockAlert

    itemNotFound db '----------------------------------------------------', 0xA
                 db '|                 ERROR MESSAGE                    |', 0xA
                 db '|--------------------------------------------------|', 0xA
                 db '|        Item not found! Please try again.         |', 0xA
                 db '----------------------------------------------------', 0xA
    len_itemNotFound equ $ - itemNotFound
    invalidInputAlert db '--------------------------------------------------', 0xA
                       db '|                 ERROR MESSAGE                  |', 0xA
                       db '|------------------------------------------------|', 0xA
                       db '|   Only integers no alphabet input, try again   |', 0xA
                       db '--------------------------------------------------', 0xA
    len_invalidInputAlert equ $ - invalidInputAlert
    ngeativeInputAlert db '--------------------------------------------------', 0xA
                       db '|                 ERROR MESSAGE                  |', 0xA
                       db '|------------------------------------------------|', 0xA
                       db '|  Only positive number and not zero, try again  |', 0xA
                       db '--------------------------------------------------', 0xA
    len_ngeativeInputAlert equ $ - ngeativeInputAlert
    stockUpdated db 'Stock updated successfully!', 0xA
    len_stockUpdated equ $ - stockUpdated

    choice5 db  'DELETE ITEM', 0xA
    db  'Enter item name: ',
    len_choice5 equ $ - choice5
    itemDeleted db 'Item deleted successfully!', 0xA
    len_itemDeleted equ $ - itemDeleted

    undefined db '----------------------------------------------------', 0xA
              db '|                 ERROR MESSAGE                    |', 0xA
              db '|--------------------------------------------------|', 0xA
              db '|      Undefined Choice, Please Choose again       |', 0xA
              db '----------------------------------------------------', 0xA
    len_undefined equ $ - undefined

;-------------------------------------------------------------------------------------------
section .bss
;menu input
menuInput resb 10

;condition 1
itemNameBuf resb 64
itemValueBuf resb 16
itemNameLen resd 1
itemValueLen resd 1

;condition 2
newItemName resb 64       ; Buffer for item name
newItemValue resb 10      ; Buffer for item value
combinedItem resb 80      ; Buffer for "name, value"

;condition 3
addStockItem resb 64
addStockValue resb 10

;condition 4
reduceStockItem resb 64
reduceStockValue resb 10

;condition 5
deleteItemname resb 64

;file operations
fileBuffer resb 2048        ; buffer to hold entire file
fileBytesRead resd 1        ; total bytes read from file
outputBuffer resb 2048      ; buffer for modified content
outputLen resd 1            ; length of output
itemLen resd 1
tempNumBuf resb 16

;-------------------------------------------------------------------------------------------
section .text
    global _start

_start:
print_menu:
    print menu, len_menu

loop_read:
    input menuInput, 10

    mov al, [menuInput]
    cmp al, 0xA
    je loop_read         ; skip processing if Enter was pressed alone

    mov bl, [menuInput + 1]    ; Second character
    cmp bl, 0xA
    jne condition_undefined    ; If not newline, input was too long → reject

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
    input newItemName, 64

.check_newItemName:
    ; if Enter was pressed alone, ask for input again
    mov al, [newItemName]
    cmp al, 0xA
    je .ask_newItemName_again
    jmp .check_duplicate   

.ask_newItemName_again:
    input newItemName, 64
    jmp .check_newItemName

.check_duplicate:
    ; Check if item already exists
    call checkItemExists
    cmp eax, 1              ; 1 = exists, 0 = doesn't exist
    je .item_already_exists
    jmp .get_newItemStock_value

.item_already_exists:
    print itemExists, len_itemExists
    print newline, 1
    jmp condition2          ; Go back to menu

.get_newItemStock_value:
    print createStockValueInput, len_createStockValueInput
    input newItemValue, 10

.check_newItemStock_value:
    ; if Enter was pressed alone, ask for input again
    mov al, [newItemValue]
    cmp al, 0xA
    je .ask_newItemValue_again
    jmp .update_stock   

.ask_newItemValue_again:
    input newItemValue, 10
    jmp .check_newItemStock_value

; Pase input and check validation 
.update_stock:
    ; Parse the entire input string to a number
    mov esi, newItemValue
    xor eax, eax                ; Result accumulator
    xor ebx, ebx                ; Temp for digit
    
.parse_input_loop:
    mov bl, [esi]
    cmp bl, 0xA                 ; Check for newline
    je .combine_and_save
    cmp bl, 0                   ; Check for null
    je .combine_and_save

    ; Check input is integer of alphabets
    cmp bl, '0'                 
    jb .invalid_input
    cmp bl, '9'
    ja .invalid_input
    ;check whether input is zero
    cmp bl, '0'
    je .zero_input
    
    inc esi
    jmp .parse_input_loop

.invalid_input:
    print invalidInputAlert, len_invalidInputAlert
    jmp condition2

.zero_input:
    print ngeativeInputAlert, len_ngeativeInputAlert
    jmp condition2

.combine_and_save:
    ; Combine name and value into "name, value" format
    call combineItemData
    
    ; Save to file
    push eax                ; length returned from combineItemData
    push combinedItem       ; combined string
    call createItem
    add esp, 8
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
    print addStockValueInput, len_addStockValue
    input addStockValue, 10

.check_stock_value:
    mov al, [addStockValue]
    cmp al, 0xA
    je .ask_stock_value
    jmp .update_stock

.ask_stock_value:
    input addStockValue, 10
    jmp .check_stock_value

.update_stock:
    ; Parse the entire input string to a number
    mov esi, addStockValue
    xor eax, eax                ; Result accumulator
    xor ebx, ebx                ; Temp for digit
    
.parse_input_loop:
    mov bl, [esi]
    cmp bl, 0xA                 ; Check for newline
    je .done_parse_input
    cmp bl, 0                   ; Check for null
    je .done_parse_input

    ; Check input is integer of alphabets
    cmp bl, '0'                 
    jb .invalid_input
    cmp bl, '9'
    ja .invalid_input
    
    imul eax, 10                ; eax *= 10
    sub bl, '0'                 ; Convert ASCII to number
    add eax, ebx                ; Add digit
    inc esi
    jmp .parse_input_loop

.invalid_input:
    print invalidInputAlert, len_invalidInputAlert
    jmp condition3
    
.done_parse_input:
    push eax                    ; Push the NUMERIC value (not character)
    push addStockItem           
    call editStock
    add esp, 8

    print newline, 1
    jmp print_menu

condition4:
    print choice4, len_choice4
    input reduceStockItem, 64

.check_item_name:
    mov al, [reduceStockItem]
    cmp al, 0xA
    je .ask_item_name
    jmp .get_stock_value

.ask_item_name:
    input reduceStockItem, 64
    jmp .check_item_name

.get_stock_value:
    ; Get stock value to add
    print reduceStockValueInput, len_reduceStockValue
    input reduceStockValue, 10

.check_stock_value:
    mov al, [reduceStockValue]
    cmp al, 0xA
    je .ask_stock_value
    jmp .update_stock

.ask_stock_value:
    input reduceStockValue, 10
    jmp .check_stock_value

.update_stock:
    ; Parse the entire input string to a number
    mov esi, reduceStockValue
    xor eax, eax                ; Result accumulator
    xor ebx, ebx                ; Temp for digit
    
.parse_input_loop:
    mov bl, [esi]
    cmp bl, 0xA                 ; Check for newline
    je .done_parse_input
    cmp bl, 0                   ; Check for null
    je .done_parse_input
    ; Check input is integer of alphabets
    cmp bl, '0'                 
    jb .invalid_input
    cmp bl, '9'
    ja .invalid_input
    
    imul eax, 10                ; eax *= 10
    sub bl, '0'                 ; Convert ASCII to number
    add eax, ebx                ; Add digit
    inc esi
    jmp .parse_input_loop

.invalid_input:
    print invalidInputAlert, len_invalidInputAlert
    jmp condition4
    
.done_parse_input:
    push eax                    ; Push the NUMERIC value (not character)
    push reduceStockItem           
    call editStock
    add esp, 8

    print newline, 1
    jmp print_menu

condition5:
    print choice5, len_choice5
    input deleteItemname, 64

.check_item_name:
    mov al, [deleteItemname]
    cmp al, 0xA
    je .ask_item_name
    jmp .do_delete

.ask_item_name:
    input deleteItemname, 64
    jmp .check_item_name

.do_delete:
    ; Call deleteItem
    xor eax, eax               ; No numeric value needed
    push eax
    push deleteItemname
    call editStock
    add esp, 8

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
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    ; Print table top
    print tableTop, len_tableTop
    print tableHeader, len_tableHeader
    print tableDivider, len_tableDivider
    
    ; Open file
    openfile filename, 0, 0
    cmp eax, 0
    js .file_error
    mov ebx, eax                ; file descriptor
    
    ; Read entire file
    mov eax, 3
    mov ecx, fileBuffer
    mov edx, 2048
    int 0x80
    
    mov [fileBytesRead], eax
    
    mov eax, 6                  ; close file
    int 0x80
    
    cmp dword [fileBytesRead], 0
    jle .no_items
    
    ; Parse and display each line
    xor esi, esi                ; position in fileBuffer
    
.line_loop:
    cmp esi, [fileBytesRead]
    jge .done_display
    
    ; Parse one line (item name and value)
    call .parse_line
    
    ; Display formatted line
    call .display_formatted_line
    
    ; Print divider
    print tableDivider, len_tableDivider
    
    jmp .line_loop
    
.done_display:
    print tableBottom, len_tableBottom
    jmp .cleanup
    
.file_error:
    print errorMsg, len_errorMsg
    jmp .cleanup
    
.no_items:
    print tableBottom, len_tableBottom
    jmp .cleanup

; ========================================
; Parse one line from file
; Input: esi = position in fileBuffer
; Output: itemNameBuf, itemValueBuf filled
;         esi = position after this line
; ========================================
.parse_line:
    push ebp
    push ebx
    push edi
    
    ; Clear buffers
    mov edi, itemNameBuf
    mov ecx, 64
    xor al, al
    rep stosb
    
    mov edi, itemValueBuf
    mov ecx, 16
    xor al, al
    rep stosb
    
    ; Parse item name (until comma)
    xor edi, edi                ; index in itemNameBuf
.parse_name:
    mov al, [fileBuffer + esi]
    cmp al, ','
    je .found_comma
    cmp al, 0xA
    je .end_line
    cmp al, 0
    je .end_line
    
    mov [itemNameBuf + edi], al
    inc edi
    inc esi
    jmp .parse_name
    
.found_comma:
    mov [itemNameLen], edi
    inc esi                     ; skip comma
    
    ; Skip optional space after comma
    mov al, [fileBuffer + esi]
    cmp al, ' '
    jne .parse_value
    inc esi
    
.parse_value:
    ; Parse value (until newline)
    xor edi, edi                ; index in itemValueBuf
.parse_val_loop:
    mov al, [fileBuffer + esi]
    cmp al, 0xA
    je .end_line
    cmp al, 0
    je .end_line
    
    mov [itemValueBuf + edi], al
    inc edi
    inc esi
    jmp .parse_val_loop
    
.end_line:
    mov [itemValueLen], edi
    inc esi                     ; skip newline
    
    pop edi
    pop ebx
    pop ebp
    ret

; ========================================
; Display one formatted line
; Format: |  Item Name (padded to 32)      |   Value (padded)   |
; ========================================
.display_formatted_line:
    push ebp
    push ebx
    push esi
    push edi
    
    ; Print "|  "
    print pipeStart, len_pipeStart
    
    ; Print item name
    mov eax, 4
    mov ebx, 1
    mov ecx, itemNameBuf
    mov edx, [itemNameLen]
    int 0x80
    
    ; Calculate padding needed (32 - itemNameLen)
    mov eax, 32
    sub eax, [itemNameLen]
    sub eax, 1               ; -1 for the spaace after name/before pipe
    
    ; Print spaces for padding
    mov ebx, 1
    mov ecx, spaces
    mov edx, eax
    mov eax, 4
    int 0x80
    
    ; Print " |   "
    mov eax, 4
    mov ebx, 1
    lea ecx, [pipeMiddle]
    mov edx, 1
    int 0x80
    
    ; Print 3 spaces before value
    mov eax, 4
    mov ebx, 1
    mov ecx, spaces
    mov edx, 3
    int 0x80
    
    ; Print value
    mov eax, 4
    mov ebx, 1
    mov ecx, itemValueBuf
    mov edx, [itemValueLen]
    int 0x80
    
    ; Calculate padding after value (5 - itemValueLen)
    mov eax, 5
    sub eax, [itemValueLen]
    
    ; Print spaces after value
    mov ebx, 1
    mov ecx, spaces
    mov edx, eax
    mov eax, 4
    int 0x80
    
    ; Print "   |" and newline
    mov eax, 4
    mov ebx, 1
    lea ecx, [spaces]
    mov edx, 3                  ; 3 more spaces
    int 0x80
    
    print pipeEnd, len_pipeEnd
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

.cleanup:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

;-------------------------------------------------------------------------------------------
; ========================================
; CHECK IF ITEM EXISTS FUNCTION
; Returns: eax = 1 if exists, 0 if not
; ========================================
checkItemExists:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    ; Calculate item name length (without newline)
    xor ecx, ecx
.find_len:
    mov al, [newItemName + ecx]
    cmp al, 0xA
    je .found_len
    cmp al, 0
    je .found_len
    inc ecx
    jmp .find_len
.found_len:
    mov [itemLen], ecx      ; Store length for comparison
    
    ; Open and read file
    openfile filename, 0, 0
    cmp eax, 0
    js .file_error          ; File doesn't exist or error = item doesn't exist
    mov ebx, eax            ; Save file descriptor
    
    ; Read entire file
    mov eax, 3
    mov ecx, fileBuffer
    mov edx, 2048
    int 0x80
    
    mov [fileBytesRead], eax
    
    ; Close file
    mov eax, 6
    int 0x80
    
    cmp dword [fileBytesRead], 0
    jle .not_found          ; Empty file = item doesn't exist
    
    ; Parse file line by line
    xor esi, esi            ; Position in fileBuffer
    
.line_loop:
    cmp esi, [fileBytesRead]
    jge .not_found
    
    mov ebx, esi            ; Save line start
    
    ; Compare item name
    xor ecx, ecx
.compare_loop:
    cmp ecx, [itemLen]
    je .check_comma         ; All characters matched, check if followed by comma
    
    mov al, [fileBuffer + esi]
    mov dl, [newItemName + ecx]
    cmp al, dl
    jne .skip_line          ; Characters don't match
    
    inc ecx
    inc esi
    jmp .compare_loop
    
.check_comma:
    ; Check if next character is comma (exact match)
    mov al, [fileBuffer + esi]
    cmp al, ','
    je .found_match         ; Item exists!
    
.skip_line:
    ; Skip to next line
    mov esi, ebx
.skip_to_newline:
    mov al, [fileBuffer + esi]
    inc esi
    cmp al, 0xA
    jne .skip_to_newline
    jmp .line_loop
    
.found_match:
    ; Item exists
    mov eax, 1
    jmp .cleanup
    
.not_found:
    ; Item doesn't exist
    xor eax, eax            ; Return 0
    jmp .cleanup
    
.file_error:
    ; File doesn't exist = item doesn't exist
    xor eax, eax            ; Return 0
    
.cleanup:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Combine item name and stock value into "name, value" format
combineItemData:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    ; Clear combined buffer
    mov edi, combinedItem
    mov ecx, 80
    xor al, al
    rep stosb
    
    ; Copy item name (without newline)
    xor esi, esi            ; source index
    xor edi, edi            ; dest index

.copy_name:
    mov al, [newItemName + esi]
    cmp al, 0xA             ; stop at newline
    je .done_name
    cmp al, 0               ; stop at null
    je .done_name
    
    mov [combinedItem + edi], al
    inc esi
    inc edi
    jmp .copy_name
    
.done_name:
    ; Add comma and space
    mov byte [combinedItem + edi], ','
    inc edi
    mov byte [combinedItem + edi], ' '
    inc edi
    
    ; Copy item value (without newline)
    xor esi, esi
    
.copy_value:
    mov al, [newItemValue + esi]
    cmp al, 0xA             ; stop at newline
    je .done_value
    cmp al, 0               ; stop at null
    je .done_value
    
    mov [combinedItem + edi], al
    inc esi
    inc edi
    jmp .copy_value
    
.done_value:
    ; edi now contains total length
    mov eax, edi            ; return length in eax
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

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
editStock:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    ; Calculate item name length (without newline)
    mov esi, [ebp+8]
    xor ecx, ecx
.find_len:
    mov al, [esi + ecx]
    cmp al, 0xA
    je .found_len
    cmp al, 0
    je .found_len
    inc ecx
    jmp .find_len
.found_len:
    mov [itemLen], ecx
    
    ; Open and read file
    openfile filename, 0, 0
    cmp eax, 0
    js .file_error
    mov ebx, eax
    
    mov eax, 3
    mov ecx, fileBuffer
    mov edx, 2048
    int 0x80
    
    mov [fileBytesRead], eax
    
    mov eax, 6
    int 0x80
    
    cmp dword [fileBytesRead], 0
    jle .file_error
    
    ; Parse file
    xor esi, esi                ; input pos
    xor edi, edi                ; output pos
    
.line_loop:
    cmp esi, [fileBytesRead]
    jge .item_not_found
    
    mov ebx, esi                ; save line start
    
    ; Compare item name
    mov edx, [ebp+8]
    xor ecx, ecx
.cmp_loop:
    cmp ecx, [itemLen]
    je .check_comma
    
    mov al, [fileBuffer + esi]
    cmp al, [edx + ecx]
    jne .no_match
    
    inc ecx
    inc esi
    jmp .cmp_loop
    
.check_comma:
    mov al, [fileBuffer + esi]
    cmp al, ','
    je .found_match
    
.no_match:
    mov esi, ebx
.copy_line:
    mov al, [fileBuffer + esi]
    mov [outputBuffer + edi], al
    inc esi
    inc edi
    cmp al, 0xA
    jne .copy_line
    jmp .line_loop
    
.found_match:
    ;compare to see whether it is delete
    movzx edx, byte [menuInput]  ;  Use ebx instead of al
    cmp dl, '5'                  ;  Compare lower byte
    je .delete_item

    ; Copy name and comma
    mov esi, ebx
    mov ecx, [itemLen]

.copy_name:
    mov al, [fileBuffer + esi]
    mov [outputBuffer + edi], al
    inc esi
    inc edi
    loop .copy_name
    
    ; Copy comma and optional space
    mov al, [fileBuffer + esi]
    mov [outputBuffer + edi], al
    inc esi
    inc edi
    
    mov al, [fileBuffer + esi]
    cmp al, ' '
    jne .parse_num
    mov [outputBuffer + edi], al
    inc esi
    inc edi
    
.parse_num:
    ; Parse number
    xor eax, eax

.parse_loop:
    movzx ebx, byte [fileBuffer + esi]
    cmp bl, '0'
    jb .done_parse
    cmp bl, '9'
    ja .done_parse
    
    imul eax, 10
    sub bl, '0'
    add eax, ebx
    inc esi
    jmp .parse_loop
    
.done_parse:
    movzx ebx, byte [menuInput]  ;  Use ebx instead of al
    cmp bl, '3'                  ;  Compare lower byte
    je .add_stock
    cmp bl, '4'
    je .reduce_stock
    jmp .cleanup

.add_stock:
    ; Add new stock (already a number on stack)
    mov ebx, [ebp+12]         ; Get numeric value directly

    ; Validate value to add is positive
    cmp ebx, 0
    jg .safe_to_add 

    ; Negative number or zero, print error message
    print ngeativeInputAlert, len_ngeativeInputAlert
    jmp .input_again

.safe_to_add:
    add eax, ebx              ; Add it (no conversion needed!)
    
    ; Convert to string using tempNumBuf
    mov ebx, 10
    lea ecx, [tempNumBuf + 15]  ; point to end
    mov byte [ecx], 0           ; null terminator
    jmp .to_string

.reduce_stock:
    mov ebx, [ebp+12]         ; Value to reduce
    
    ; if less than or equal to zero, print error
    cmp ebx, 0
    jle .negativeNumber 

    ; Validate: current stock >= reduce amount
    cmp eax, ebx
    jge .safe_to_reduce       ; Jump if Greater or Equal (signed)
    
    ; Not enough stock
    print insufficientStockAlert, len_insufficientStockAlert
    jmp .input_again

.negativeNumber:
    print ngeativeInputAlert, len_ngeativeInputAlert
    jmp .input_again
    
.safe_to_reduce:
    sub eax, ebx
    
    ;check after reduce is it zero, if yes print message
    cmp eax, 0
    jz .zero_stock            ; Jump if zero (special message?)
    
    ; All good - convert to string
    mov ebx, 10
    lea ecx, [tempNumBuf + 15]
    mov byte [ecx], 0
    jmp .to_string

.zero_stock:
    ;print alert message
    push eax             ; save eax
    print zeroStockAlert, len_zeroStockAlert
    pop eax              ; restore eax

    mov ebx, 10
    lea ecx, [tempNumBuf + 15]
    mov byte [ecx], 0
    jmp .to_string

.to_string:
    dec ecx
    xor edx, edx
    div ebx
    add dl, '0'
    mov [ecx], dl
    test eax, eax
    jnz .to_string
    
    ; Copy number to output
.copy_number:
    mov al, [ecx]
    test al, al
    jz .done_number
    mov [outputBuffer + edi], al
    inc ecx
    inc edi
    jmp .copy_number
    
.done_number:
    ; Copy rest of current line
.copy_eol:
    cmp esi, [fileBytesRead]
    jge .copy_remaining
    mov al, [fileBuffer + esi]
    mov [outputBuffer + edi], al
    inc esi
    inc edi
    cmp al, 0xA
    jne .copy_eol
    jmp .copy_remaining

.delete_item:
    ; Skip rest of current line
    mov esi, ebx  
    
.skip_line:
    cmp esi, [fileBytesRead]
    jge .copy_remaining
    mov al, [fileBuffer + esi]
    inc esi
    cmp al, 0xA                 ; found newline?
    jne .skip_line
    ; Line skipped, continue with next line
    jmp .copy_remaining
    
.copy_remaining:
    ; Copy remaining lines
    cmp esi, [fileBytesRead]
    jge .write_file
    mov al, [fileBuffer + esi]
    mov [outputBuffer + edi], al
    inc esi
    inc edi
    jmp .copy_remaining
    
.write_file:
    ; Write back to file
    openfile filename, 0x241, 0o644
    cmp eax, 0
    js .file_error
    mov ebx, eax
    
    mov eax, 4
    mov ecx, outputBuffer
    mov edx, edi                ; use edi as length
    int 0x80
    
    mov eax, 6
    int 0x80
    
    ; Check what operation was done for appropriate message
    movzx eax, byte [menuInput]
    cmp al, '5'
    je .show_deleted
    print stockUpdated, len_stockUpdated
    jmp .cleanup

.show_deleted:
    print itemDeleted, len_itemDeleted
    jmp .cleanup
    
.item_not_found:
    print itemNotFound, len_itemNotFound
    jmp .cleanup
    
.file_error:
    print errorMsg, len_errorMsg

.input_again:
    pop edi
    pop esi
    pop ebx
    pop ebp
    
    movzx ebx, byte [menuInput]  ;  Use ebx instead of al
    cmp bl, '3'                  ;  Compare lower byte
    je condition3
    cmp bl, '4'
    je condition4
    
.cleanup:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret