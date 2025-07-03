#include "include/kprint.h"
#include "include/terminal.h"

void kmain() {
    kprint_init();
    kprint("Booting my kernel...\n");

    // Initialize interrupts BEFORE enabling them
   // init_pic();
   // install_idt();

    // NOW it's safe to enable interrupts
   // asm volatile("sti");

    while(1) {
        kprint("hi\n");
        // Add a delay here to avoid spam
        for(volatile int i = 0; i < 10000000; i++);
    }
}
