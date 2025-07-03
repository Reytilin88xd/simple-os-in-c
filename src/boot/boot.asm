BITS 16
ORG 0x7C00

code_offset     equ 0x08
data_offset     equ 0x10
kernel_segment  equ 0x1000  ; ES
kernel_sectors  equ 8       ; # of sectors to read
kernel_offset   equ 0x0000  ; Offset into segment
kernel_start_addr equ 0x100000

start:
    cli
    xor ax, ax
    mov ds, ax

    ; Save boot drive number
    mov [boot_drive], dl

    mov ax, kernel_segment
    mov es, ax
    mov bx, kernel_offset

    mov ah, 0x02        ; read sectors
    mov al, kernel_sectors
    mov ch, 0x00        ; cylinder
    mov cl, 0x02        ; sector (start at 2; sector 1 is MBR)
    mov dh, 0x00        ; head
    mov dl, [boot_drive] ; use preserved drive number
    int 0x13
    jc disk_error

    ; Jump to protected mode setup instead of infinite loop
    jmp load_pm

disk_error:
    mov si, msg
.next:
    lodsb
    or al, al
    jz hang
    mov ah, 0x0E
    int 0x10
    jmp .next

hang:
    jmp $

msg db "Disk error", 0
boot_drive db 0

;setup gdt
gdt_start:
    dq 0x0000000000000000  ; null descriptor
    dq 0x00CF9A000000FFFF  ; code descriptor
    dq 0x00CF92000000FFFF  ; data descriptor
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

load_pm:
    lgdt [gdt_descriptor]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp code_offset:PModemain

[BITS 32]
PModemain:
    mov ax, data_offset
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x9C00
    mov esp, ebp

    ; A20
    in al, 0x92
    or al, 2
    out 0x92, al

    ; pene
    call clear_screen

    ; print string
    mov edi, 0xB8000
    mov esi, pm_msg
    call print_string_pm

 
    mov edi, 0xB8000 + (2 * 80 * 2)  ; Row 2, column 0
    mov esi, success_msg
    call print_string_pm

    mov esi, 0x10000                    ; Source
    mov edi, kernel_start_addr          ; Destination (0x100000)
    mov ecx, kernel_sectors * 512 / 4   ; Size in dwords (8 sectors * 512 bytes / 4)
    rep movsd                           ; Copy
    
    jmp kernel_start_addr               ; Now jump to copied kernel

clear_screen:
    mov edi, 0xB8000
    mov ecx, 80 * 25        ; 80 columns x 25 rows
    mov ax, 0x0720          ; Space character with light gray on black
    rep stosw
    ret

print_string_pm:
    mov ah, 0x0F            ; White text on black background
.loop:
    lodsb                   ; Load byte from [esi] into al
    test al, al             ; Check if null terminator
    jz .done
    mov [edi], ax           ; Write char (al) + attribute (ah)
    add edi, 2              ; Move to next character position (char + attribute)
    jmp .loop
.done:
    ret

pm_msg db "Protected Mode Active!", 0
success_msg db "Kernel sectors loaded successfully!", 0

times 510 - ($-$$) db 0
dw 0xAA55
