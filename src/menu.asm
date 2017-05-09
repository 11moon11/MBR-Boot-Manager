bits 16     ; Usual 16 bit mode
org 0x7C00  ; Usual ram-mem offset

MOV AL, 0x03                 ; Set video mode to 0x03 (80x25, 4-bit)
INT 0x10                     ; Change video mode

MOV AX, 0x0501               ; Set active display page to 0x01 (clear)
INT 0x10                     ; Switch display page (function 0x05)

MOV AX, 0x0103               ; Set cursor shape
MOV CX, 0x0105
INT 0x10

jmp next
db 0xFA, 0xFA
next:


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
    push cx               ; ��������� ������� ������

    ; ������ �����
    mov ax, 0x0600   ; 06 - ���������, 00 - ��������� �� ���� ������
    mov bh, 0x07     ; 07 - �������� ����� ����
    mov cx, 0x0000   ; �� ����� (00h, 00h) �� ����� (10h, 10h)
    mov dx, 0x1010
    int 0x10         ; ������
    
    xor cx, cx  ; ������� ��� ��������� �������
    
    .draw_loop:
        cmp cx, 4        ; ���������, ��� �� ���������� ������ 4 �������
        jae .draw_finish ; �� ����� ���������� ������ ����
        
        mov dx, 0x0004   ; ��������� ������ ������� 0 �� ��������� � 4 �� �����������
        mov al, cl       ; �������� ������ ������
        add dh, al       ; ������ ������������ ������ �� �����������
        
        mov bh, 0x01      ; ��������� ��������
        mov ah, 0x02      ; �������, ��� ����� ������� �������
        int 0x10          ; ������� �������
    
        mov SI, part_template  ; ��������� �������
        call PRINT_STRING       ; �������� �������
        
        mov al, 0x31      ; ��� 1
        add al, cl        ; �������� �������� �����
        call PRINT_CHAR   ; ���������� ����� �������
        
        inc cx            ; ��������� � ����������
        jmp .draw_loop
    
    .draw_finish:       ; ��������� ���������
        pop cx          ; ��������� ������� �������
    
        mov dx, 0x0001  ; ��������� ������ ������� 0 �� ��������� � 1 �� �����������
        mov al, cl      ; �������� ������ ������
        add dh, al      ; ������ ������������ ������ �� �����������
        
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