[BITS 32]
global _start           ; ELF entry point
extern kmain           ; C function

section .text

; Export interrupt handlers for C code
 
    
_start:                ; This will be at 0x10000 when loaded
    ; Set up stack if needed
    mov esp, 0x9C00    ; Or wherever you want your kernel stack
    
    ; Call your C main function
    call kmain
    
    ; Halt if kmain returns
    cli
    hlt
    jmp $
