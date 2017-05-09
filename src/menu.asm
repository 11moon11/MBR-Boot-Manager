bits 16     ; Usual 16 bit mode
org 0x7C00  ; Usual ram-mem offset

STI                          ; Enable interrupts

MOV AX, 0x0003               ; Set video mode to 0x03 (80x25, 4-bit)
INT 0x10                     ; Change video mode (function 0x00)

MOV AX, 0x0501               ; Set active display page to 0x01 (clear)
INT 0x10                     ; Switch display page (function 0x05)

MOV AX, 0x0600               ; Scroll window (0x00 lines => clear)
MOV BH, 0x43                 ; Color: red/cyan
MOV CX, 0x0000               ; Upper-left point (row: 0, column: 0)
MOV DX, 0x184F               ; Lower-right point (row: 24, column: 79)
INT 0x10                     ; Scroll up window (function 0x06)

MOV AX, 0x0103               ; Set cursor shape for video mode 0x03
MOV CX, 0x0105               ; Display lines 1-5 (max: 0-7)
INT 0x10                     ; Change cursor shape (function 0x01)

MOV AH, 0x02                 ; Set cursor position
MOV BH, 0x01                 ; Set page number to 0x01
MOV DX, 0x0505               ; Set row and column (starting from 0)
INT 0x10                     ; Move cursor


jmp next
db 0xFA, 0xFA
next:




xor dh, dh  ; ������� ��� ��������� �������
    
draw_loop:
    cmp dh, 4        ; ���������, ��� �� ���������� ������ 4 �������
    jae draw_finish ; �� ����� ���������� ������ ����
    
    mov dl, 0x04   ; ��������� ������ ������� 0 �� ��������� � 4 �� �����������
                   ; DH = Row, DL = Column
    
    mov bh, 0x01      ; BH = Page number
    mov ah, 0x02      ; Set cursor position
    int 0x10          ; ������� �������

    mov SI, part_template  ; ��������� �������
    call PRINT_STRING       ; �������� �������
    
    mov al, 0x31      ; ��� 1
    add al, dh        ; �������� �������� �����
    call PRINT_CHAR   ; ���������� ����� �������
    
    inc dh            ; ��������� � ����������
    jmp draw_loop





draw_finish:

;; body
xor cx, cx  ; �� ������ ������

main_loop:              ; �������� ������ ���������:
    call draw_screen    ; * ����������
    xor ax, ax  ; ������� �����
    int 0x16     ; ��������� ������ �� �����
    
    cmp ax, 0x4800 ; up     ���������, ��� ��� ������� �����
    je move_select_up     ; ������� ������ �����

    cmp ax, 0x5000 ; down   ���������, ��� ��� ������� ����
    je move_select_down   ; ������� ������ ����
    
    jmp main_loop       ; ����� ���������
    
;;;;;;;;;;;;;

move_select_up:      ; ��������� ������� ������ �����
    cmp cx, 0       ; ��������� �� �� ����� �� ��
    jle move_select_up_ret  ; ������ �������, ����� ������
    
    dec cx          ; ��������� ������
    move_select_up_ret:
    jmp main_loop             ; ��������� ���������
    
move_select_down:    ; ��������� ������� ������ ����
    cmp cx, 3       ; ��������� �� ����� �� ��
    jae move_select_down_ret  ; ������ �����, ����� ������
    
    inc cx          ; ����������� ������
    move_select_down_ret:
    jmp main_loop             ; ��������� ���������
    
    
draw_screen:               ; ������ ��������� �����
        mov dl, 0x01  ; ��������� ������ ������� 0 �� ��������� � 1 �� �����������
        mov dh, cl      ; ������ ������������ ������ �� �����������
        
        mov bh, 0x01    ; ��������� ��������
        mov ah, 0x02    ; �������, ��� ����� ������� �������
        int 0x10        ; ������� �������
        
        ret      ; ��������� ���������

DB 0xFA, 0xFA

PRINT_STRING:
    MOV BX, 0x0107              ; Display page 1, white on black
    LOAD_CHAR:
        LODSB                   ; Load character into AL from [SI]
        CMP AL, 0               ; Check for end of string
        JZ PRINT_STRING_RET     ; Return if string is printed
        CALL PRINT_CHAR
        JMP LOAD_CHAR           ; Go back for another character...
    PRINT_STRING_RET: RET

PRINT_CHAR:
    MOV AH, 0x0E            ; Character print function
    INT 0x10                ; Print character
    RET
    
    
part_template db "Partition ", 0 ; ��� ������ �������

times 510 - ($ - $$) db 0
dw 0xAA55